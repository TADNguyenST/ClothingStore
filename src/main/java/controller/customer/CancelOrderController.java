package controller.customer;

import dao.OrderDAO;
import dao.CartItemDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/customer/orders/cancel")
public class CancelOrderController extends HttpServlet {

    private OrderDAO orderDAO;
    private CartItemDAO cartItemDAO;

    @Override
    public void init() {
        orderDAO = new OrderDAO();
        cartItemDAO = new CartItemDAO();
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        Long userId = (session != null) ? (Long) session.getAttribute("userId") : null;
        if (userId == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String orderStr = req.getParameter("orderId");
        if (orderStr == null) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing orderId");
            return;
        }

        long orderId;
        try {
            orderId = Long.parseLong(orderStr);
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid orderId");
            return;
        }

        String reason = req.getParameter("reason");
        try {
            long customerId = cartItemDAO.getCustomerIdByUserId(userId);
            int result = orderDAO.cancelPendingByCustomer(orderId, customerId, reason);
            String q;
            if (result == 1) {
                q = "&canceled=1";      // PENDING + UNPAID
            } else if (result == 2) {
                q = "&refund_req=1";    // PENDING + PAID -> REFUND_PENDING
            } else {
                q = "&cantCancel=1";    // Không hủy được
            }
            resp.sendRedirect(req.getContextPath()
                    + "/customer/orders/detail?orderId=" + orderId + q);
        } catch (Exception e) {
            throw new ServletException("Cancel order failed", e);
        }
    }
}
