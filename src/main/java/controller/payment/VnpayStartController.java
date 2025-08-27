package controller.payment;

import dao.CartItemDAO;            // NEW: map userId -> customerId
import dao.OrderDAO;
import dao.PaymentDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import util.VnpayService;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;

import model.Payment;

// NEW: direct DB check for order status/payment_status by customer
import util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/payments/vnpay-start")
public class VnpayStartController extends HttpServlet {

    private OrderDAO orderDAO;
    private PaymentDAO paymentDAO;

    @Override
    public void init() {
        orderDAO = new OrderDAO();
        paymentDAO = new PaymentDAO();
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
        if (orderStr == null || orderStr.trim().isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing orderId.");
            return;
        }

        long orderId;
        try {
            orderId = Long.parseLong(orderStr.trim());
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid orderId.");
            return;
        }

        try {
            // Validate ownership + block DRAFT / non-UNPAID
            long customerId = new CartItemDAO().getCustomerIdByUserId(userId);
            String status = null, payStatus = null;

            try ( Connection c = DBContext.getNewConnection();  PreparedStatement ps = c.prepareStatement(
                    "SELECT status, payment_status FROM orders WHERE order_id = ? AND customer_id = ?")) {
                ps.setLong(1, orderId);
                ps.setLong(2, customerId);
                try ( ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        status = rs.getString("status");
                        payStatus = rs.getString("payment_status");
                    }
                }
            }

            if (status == null) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Order not found or not owned by current user.");
                return;
            }
            if ("DRAFT".equalsIgnoreCase(status)) {
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Order is still DRAFT. Please place the order before paying.");
                return;
            }
            if (!"UNPAID".equalsIgnoreCase(payStatus)) {
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Order is not in UNPAID status.");
                return;
            }

            BigDecimal total = orderDAO.getOrderTotal(orderId);
            if (total == null) {
                total = BigDecimal.ZERO;
            }
            long amountVnd = total.setScale(0, RoundingMode.DOWN).longValue();

            Payment payment = paymentDAO.createInitPayment(orderId, total);

            String txnRef = util.VnpayService.buildTxnRef(orderId);
            paymentDAO.insertVnpInitTxn(payment.getPaymentId(), txnRef, total);

            String ip = clientIp(req);
            String orderInfo = "Pay order #" + orderId; // English
            String payUrl = VnpayService.buildPaymentUrl(txnRef, amountVnd, ip, orderInfo);

            resp.sendRedirect(payUrl);

        } catch (Exception ex) {
            throw new ServletException("Start VNPAY failed", ex);
        }
    }

    private String clientIp(HttpServletRequest req) {
        String ip = req.getHeader("X-FORWARDED-FOR");
        if (ip == null || ip.isEmpty()) {
            ip = req.getRemoteAddr();
        }
        return ip;
    }
}
