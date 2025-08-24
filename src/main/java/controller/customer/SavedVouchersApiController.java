package controller.customer;

import dao.SavedVoucherDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.util.Date;
import java.util.List;

@WebServlet("/customer/voucher/saved")
public class SavedVouchersApiController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json; charset=UTF-8");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();

        HttpSession session = req.getSession(false);
        Long userId = (session != null) ? (Long) session.getAttribute("userId") : null;

        if (userId == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"error\":\"Please log in to view your saved vouchers.\"}");
            return;
        }

        try ( SavedVoucherDAO dao = new SavedVoucherDAO()) {
            List<SavedVoucherDAO.Row> rows = dao.listForCustomer(userId);

            StringBuilder sb = new StringBuilder();
            sb.append("{\"vouchers\":[");
            boolean first = true;
            long now = System.currentTimeMillis();

            for (SavedVoucherDAO.Row r : rows) {
                if (!first) {
                    sb.append(",");
                }
                first = false;

                boolean isExpired = !r.isActive
                        || (r.expirationDate != null && r.expirationDate.getTime() < now);

                sb.append("{")
                        .append("\"code\":\"").append(esc(r.code)).append("\",")
                        .append("\"name\":\"").append(esc(r.name)).append("\",")
                        .append("\"type\":\"").append(esc(r.type)).append("\",")
                        .append("\"value\":\"").append(toNum(r.value)).append("\",")
                        .append("\"minOrder\":\"").append(toNum(r.minOrder)).append("\",")
                        .append("\"maxDiscount\":\"").append(toNum(r.maxDiscount)).append("\",")
                        .append("\"isUsed\":").append(r.isUsed).append(",")
                        .append("\"isExpired\":").append(isExpired)
                        .append("}");
            }
            sb.append("]}");

            out.print(sb.toString());
        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\":\"Failed to load vouchers: " + esc(e.getMessage()) + "\"}");
        }
    }

    // ===== helpers =====
    private static String toNum(BigDecimal v) {
        return (v == null) ? "0" : v.stripTrailingZeros().toPlainString();
    }

    private static String esc(String s) {
        if (s == null) {
            return "";
        }
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", " ").replace("\r", " ");
    }
}
