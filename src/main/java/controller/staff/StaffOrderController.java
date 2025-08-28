package controller.staff;

import dao.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.Users;

import java.io.IOException;

@WebServlet(name = "StaffOrderController", urlPatterns = {"/StaffOrder"})
public class StaffOrderController extends HttpServlet {

    private OrderDAO orderDAO;

    @Override
    public void init() {
        orderDAO = new OrderDAO();
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // Kiểm tra session & quyền
        HttpSession session = req.getSession(false);
        Users user = (session != null) ? (Users) session.getAttribute("staff") : null;
        if (user == null || !"Staff".equalsIgnoreCase(user.getRole()) || !"Active".equalsIgnoreCase(user.getStatus())) {
            resp.sendRedirect(req.getContextPath() + "/StaffLogin");
            return;
        }

        String action = req.getParameter("action");
        String idStr = req.getParameter("orderId");
        long orderId;
        try {
            orderId = Long.parseLong(idStr);
        } catch (Exception e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing or invalid orderId");
            return;
        }

        try {
            if ("updateStatus".equalsIgnoreCase(action)) {
                String newStatus = req.getParameter("status");
                if (newStatus == null || newStatus.trim().isEmpty()) {
                    resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing status");
                    return;
                }
                // Cho phép: PENDING -> PROCESSING/SHIPPED/CANCELED; PROCESSING -> SHIPPED/CANCELED; SHIPPED -> COMPLETED
                // (Chi tiết rule đã xử lý trong OrderDAO.updateStatusByStaff)
                orderDAO.updateStatusByStaff(orderId, newStatus.trim());
                
            } else if ("markRefunded".equalsIgnoreCase(action)) {
                // Hoàn tất refund
                orderDAO.markRefundedByStaff(orderId, "Refund completed by staff");

            } else {
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unknown action");
                return;
            }

            // Redirect lại trang chi tiết
            resp.sendRedirect(req.getContextPath()
                    + "/Staffdashboard?action=orderDetails&module=order&id=" + orderId + "&updated=1");

        } catch (Exception ex) {
            // Có thể log thêm tại đây
            resp.sendRedirect(req.getContextPath()
                    + "/Staffdashboard?action=orderDetails&module=order&id=" + orderId + "&error=1");
        }
    }
}
