package controller.customer;

import dao.CartItemDAO;
import dao.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.CartItem;
import model.OrderHeader;

import java.io.IOException;
import java.util.List;

@WebServlet("/customer/orders/detail")
public class OrderDetailController extends HttpServlet {

    private CartItemDAO cartItemDAO;
    private OrderDAO orderDAO;

    @Override
    public void init() {
        cartItemDAO = new CartItemDAO();
        orderDAO = new OrderDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        Long userId = (session != null) ? (Long) session.getAttribute("userId") : null;
        if (userId == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String idStr = req.getParameter("orderId");
        if (idStr == null || idStr.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/customer/orders");
            return;
        }

        long orderId;
        try {
            orderId = Long.parseLong(idStr);
        } catch (NumberFormatException ex) {
            resp.sendRedirect(req.getContextPath() + "/customer/orders");
            return;
        }

        try {
            long customerId = cartItemDAO.getCustomerIdByUserId(userId);

            // header + items
            OrderHeader header = orderDAO.findOrderHeaderForCustomer(orderId, customerId);
            if (header == null) {
                resp.sendRedirect(req.getContextPath() + "/customer/orders");
                return;
            }
            List<CartItem> items = orderDAO.loadItemsViewForOrder(orderId);

            req.setAttribute("order", header);
            req.setAttribute("items", items);

            // ==> trỏ đúng file bạn đang dùng
            req.getRequestDispatcher("/WEB-INF/views/customer/order/order-details.jsp").forward(req, resp);

        } catch (Exception e) {
            throw new ServletException("Load order detail failed", e);
        }
    }
}
