package controller.customer;

import dao.CartItemDAO;
import dao.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.OrderHeader;

import java.io.IOException;
import java.util.List;

@WebServlet("/customer/orders")
public class OrderListController extends HttpServlet {

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

        String status = req.getParameter("status");
        if (status == null || status.trim().isEmpty()) {
            status = "all";
        }

        int page = 1, size = 10;
        try {
            page = Math.max(1, Integer.parseInt(req.getParameter("page")));
        } catch (Exception ignore) {
        }
        try {
            size = Math.max(1, Math.min(50, Integer.parseInt(req.getParameter("size"))));
        } catch (Exception ignore) {
        }
        int offset = (page - 1) * size;

        try {
            long customerId = cartItemDAO.getCustomerIdByUserId(userId);
            int total = orderDAO.countOrdersForCustomer(customerId, status);
            int totalPages = (int) Math.ceil(total / (double) size);
            List<OrderHeader> orders = orderDAO.listOrdersForCustomer(customerId, status, offset, size);

            req.setAttribute("orders", orders);
            req.setAttribute("page", page);
            req.setAttribute("size", size);
            req.setAttribute("total", total);
            req.setAttribute("totalPages", totalPages);
            req.setAttribute("status", status);

            // ==> trỏ đúng file bạn đang dùng
            req.getRequestDispatcher("/WEB-INF/views/customer/order/order-list.jsp").forward(req, resp);
        } catch (Exception e) {
            throw new ServletException("Load order list failed", e);
        }
    }
}
