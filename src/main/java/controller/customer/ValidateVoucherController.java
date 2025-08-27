package controller.customer;

import dao.VoucherLookupDAO;
import DTO.VoucherApplyRequestDTO;
import DTO.VoucherApplyResponseDTO;
import DTO.VoucherSummaryDTO;
import model.Voucher;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Date;

@WebServlet(urlPatterns = {
    "/customer/voucher/validate",
    "/customer/voucher/apply"
})
public class ValidateVoucherController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        // Chỉ cho POST
        resp.setStatus(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
        resp.setContentType("application/json; charset=UTF-8");
        resp.getWriter().print("{\"success\":false,\"message\":\"Method Not Allowed\"}");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json; charset=UTF-8");
        PrintWriter out = resp.getWriter();

        // ===== LOG NHẬN REQUEST =====
        getServletContext().log("[Voucher DEBUG] doPost uri=" + req.getRequestURI()
                + " code=" + req.getParameter("code")
                + " subtotalStr=" + req.getParameter("subtotal"));

        String code = req.getParameter("code");
        String subtotalStr = req.getParameter("subtotal");

        HttpSession session = req.getSession(false);
        Long userId = (session != null) ? (Long) session.getAttribute("userId") : null;

        VoucherApplyRequestDTO requestDTO = new VoucherApplyRequestDTO(
                code, safeBigDecimal(subtotalStr), userId
        );

        if (isBlank(requestDTO.getCode())) {
            out.print(toJson(VoucherApplyResponseDTO.fail("Please enter voucher code.")));
            return;
        }
        if (requestDTO.getSubtotal().compareTo(BigDecimal.ZERO) <= 0) {
            out.print(toJson(VoucherApplyResponseDTO.fail("Please select product before applying voucher.")));
            return;
        }

        VoucherLookupDAO dao = new VoucherLookupDAO();
        try {
            Voucher v = dao.findByCodeExact(requestDTO.getCode().trim());
            if (v == null) {
                out.print(toJson(VoucherApplyResponseDTO.fail("Voucher code does not exist.")));
                return;
            }
            if (!v.isIsActive()) {
                out.print(toJson(VoucherApplyResponseDTO.fail("Voucher is not working.")));
                return;
            }
            if (v.getExpirationDate() != null
                    && v.getExpirationDate().before(new java.sql.Date(new Date().getTime()))) {
                out.print(toJson(VoucherApplyResponseDTO.fail("Voucher has expired.")));
                return;
            }
            if (v.getUsageLimit() != null && v.getUsedCount() != null
                    && v.getUsedCount() >= v.getUsageLimit()) {
                out.print(toJson(VoucherApplyResponseDTO.fail("Voucher has reached its usage limit.")));
                return;
            }
            // Private voucher -> phải có trong customer_vouchers và chưa dùng
            if (!v.isVisibility()) {
                if (requestDTO.getUserId() == null) {
                    out.print(toJson(VoucherApplyResponseDTO.fail("Please login to use this voucher.")));
                    return;
                }
                boolean ok = dao.isUsableByUserId(v.getVoucherId(), requestDTO.getUserId());
                if (!ok) {
                    out.print(toJson(VoucherApplyResponseDTO.fail("You are not eligible for this voucher or have already used it.")));
                    return;
                }
            }
            if (v.getMinimumOrderAmount() != null
                    && requestDTO.getSubtotal().compareTo(v.getMinimumOrderAmount()) < 0) {
                out.print(toJson(VoucherApplyResponseDTO.fail("Order has not reached minimum to apply voucher.")));
                return;
            }
            if (v.getDiscountValue() == null) {
                out.print(toJson(VoucherApplyResponseDTO.fail("Voucher is invalid (missing discount).")));
                return;
            }

            // ===== TÍNH GIẢM =====
            String type = safe(v.getDiscountType()).trim();
            BigDecimal subtotal = requestDTO.getSubtotal();
            BigDecimal discount = BigDecimal.ZERO;

            if ("percentage".equalsIgnoreCase(type)) {
                BigDecimal pct = v.getDiscountValue() == null ? BigDecimal.ZERO : v.getDiscountValue();
                // 0 < pct <= 1  => 0.12 = 12%
                // pct > 1       => 12 = 12%
                if (pct.compareTo(BigDecimal.ONE) <= 0 && pct.compareTo(BigDecimal.ZERO) > 0) {
                    discount = subtotal.multiply(pct);
                } else {
                    discount = subtotal.multiply(pct).divide(new BigDecimal("100"), 0, RoundingMode.DOWN);
                }
            } else {
                discount = v.getDiscountValue() == null ? BigDecimal.ZERO : v.getDiscountValue();
            }

            // Cap theo maxDiscount (nếu có)
            if (v.getMaximumDiscountAmount() != null
                    && discount.compareTo(v.getMaximumDiscountAmount()) > 0) {
                discount = v.getMaximumDiscountAmount();
            }

            // Không vượt subtotal & không âm
            if (discount.compareTo(subtotal) > 0) {
                discount = subtotal;
            }
            if (discount.signum() < 0) {
                discount = BigDecimal.ZERO;
            }

            // Làm tròn về VND
            discount = discount.setScale(0, RoundingMode.DOWN);

            BigDecimal newTotal = subtotal.subtract(discount);
            if (newTotal.signum() < 0) {
                newTotal = BigDecimal.ZERO;
            }
            newTotal = newTotal.setScale(0, RoundingMode.DOWN);

            VoucherSummaryDTO vs = new VoucherSummaryDTO(
                    v.getVoucherId(),
                    safe(v.getCode()),
                    safe(v.getName()),
                    safe(v.getDiscountType()),
                    v.getDiscountValue(),
                    v.getMinimumOrderAmount(),
                    v.getMaximumDiscountAmount(),
                    v.isVisibility()
            );

            out.print(toJson(VoucherApplyResponseDTO.ok(
                    "Voucher applied successfully.", discount, newTotal, vs
            )));
        } catch (Exception e) {
            getServletContext().log("[Voucher DEBUG] EXCEPTION: " + e.getMessage(), e);
            out.print(toJson(VoucherApplyResponseDTO.fail("System error: " + e.getMessage())));
        } finally {
            dao.close();
        }
    }

    // ===== helpers =====
    private static BigDecimal safeBigDecimal(String s) {
        try {
            return new BigDecimal(s == null ? "0" : s);
        } catch (Exception e) {
            return BigDecimal.ZERO;
        }
    }

    private static boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    private static String safe(String s) {
        return s == null ? "" : s;
    }

    // Serializer JSON đơn giản (in number cho discount/newTotal)
    private static String esc(String s) {
        if (s == null) {
            return "";
        }
        return s.replace("\\", "\\\\").replace("\"", "\\\"")
                .replace("\n", " ").replace("\r", " ");
    }

    private static String toJson(VoucherApplyResponseDTO dto) {
        StringBuilder sb = new StringBuilder();
        sb.append("{");
        sb.append("\"success\":").append(dto.isSuccess()).append(",");
        sb.append("\"message\":\"").append(esc(dto.getMessage())).append("\",");
        sb.append("\"discount\":").append(dto.getDiscount() == null ? "0" : dto.getDiscount().toPlainString()).append(",");
        sb.append("\"newTotal\":").append(dto.getNewTotal() == null ? "0" : dto.getNewTotal().toPlainString());
        if (dto.getVoucher() != null) {
            VoucherSummaryDTO v = dto.getVoucher();
            sb.append(",\"voucher\":{")
                    .append("\"id\":").append(v.getId()).append(",")
                    .append("\"code\":\"").append(esc(v.getCode())).append("\",")
                    .append("\"name\":\"").append(esc(v.getName())).append("\",")
                    .append("\"type\":\"").append(esc(v.getType())).append("\",")
                    .append("\"value\":").append(v.getValue() == null ? "0" : v.getValue().toPlainString()).append(",")
                    .append("\"minOrder\":").append(v.getMinOrder() == null ? "null" : v.getMinOrder().toPlainString()).append(",")
                    .append("\"maxDiscount\":").append(v.getMaxDiscount() == null ? "null" : v.getMaxDiscount().toPlainString()).append(",")
                    .append("\"visibility\":").append(v.isVisibility())
                    .append("}");
        }
        sb.append("}");
        return sb.toString();
    }
}
