package controller.customer;

import DTO.SavedVoucherDTO;
import DTO.SavedVouchersResponseDTO;
import dao.VoucherLookupDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet(urlPatterns = {
    "/customer/voucher/wallet", // endpoint chính
})
public class WalletVouchersController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json; charset=UTF-8");
        PrintWriter out = resp.getWriter();

        HttpSession session = req.getSession(false);
        Long userId = (session != null) ? (Long) session.getAttribute("userId") : null;

        if (userId == null) {
            out.print(toJson(SavedVouchersResponseDTO.fail("Please login to view voucher wallet.")));
            return;
        }

        VoucherLookupDAO dao = new VoucherLookupDAO();
        try {
            List<SavedVoucherDTO> list = dao.listSavedAvailableVouchersByUserId(userId);
            out.print(toJson(SavedVouchersResponseDTO.ok(list)));
        } catch (Exception e) {
            out.print(toJson(SavedVouchersResponseDTO.fail("System error: " + e.getMessage())));
        } finally {
            dao.close();
        }
    }

    // ===== simple JSON serializer =====
    private static String esc(String s) {
        if (s == null) {
            return "";
        }
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", " ")
                .replace("\r", " ");
    }

    private static String toJson(SavedVouchersResponseDTO dto) {
        StringBuilder sb = new StringBuilder();
        sb.append("{");
        sb.append("\"success\":").append(dto.isSuccess()).append(",");
        sb.append("\"message\":\"").append(esc(dto.getMessage())).append("\"");
        if (dto.getVouchers() != null) {
            sb.append(",\"vouchers\":[");
            boolean first = true;
            for (SavedVoucherDTO v : dto.getVouchers()) {
                if (!first) {
                    sb.append(",");
                }
                first = false;
                sb.append("{")
                        .append("\"id\":").append(v.getId()).append(",")
                        .append("\"code\":\"").append(esc(v.getCode())).append("\",")
                        .append("\"name\":\"").append(esc(v.getName())).append("\",")
                        .append("\"type\":\"").append(esc(v.getType())).append("\",")
                        .append("\"value\":\"").append(v.getValue() == null ? "0" : v.getValue().toPlainString()).append("\",")
                        .append("\"minOrder\":\"").append(v.getMinOrder() == null ? "0" : v.getMinOrder().toPlainString()).append("\",")
                        .append("\"maxDiscount\":\"").append(v.getMaxDiscount() == null ? "0" : v.getMaxDiscount().toPlainString()).append("\",")
                        .append("\"active\":").append(v.isActive()).append(",")
                        .append("\"visibility\":").append(v.isVisibility()).append(",")
                        .append("\"used\":").append(v.isUsed()).append(",")
                        .append("\"expirationDate\":\"").append(v.getExpirationDate() == null ? "" : v.getExpirationDate().toString()).append("\"")
                        .append("}");
            }
            sb.append("]");
        }
        sb.append("}");
        return sb.toString();
    }
}
