package controller.customer;

import dao.FeedbackDAO;
import dao.OrderDAO;
import model.Order;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/feedbackHistory")
public class FeedbackHistoryServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(FeedbackHistoryServlet.class.getName());
    private OrderDAO orderDAO;

    @Override
    public void init() throws ServletException {
        orderDAO = new OrderDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        LOGGER.log(Level.INFO, "Checking session for feedback history page access. Session exists: {0}", (session != null));
        if (session == null || session.getAttribute("userId") == null) {
            LOGGER.log(Level.WARNING, "Unauthorized access attempt to view feedback history. Redirecting to login.");
            String redirectAfterLogin = request.getRequestURI() + (request.getQueryString() != null ? "?" + request.getQueryString() : "");
            session = request.getSession(true);
            session.setAttribute("redirectAfterLogin", redirectAfterLogin);
            request.setAttribute("errorMessage", "Please log in to view your feedback history.");
            request.getRequestDispatcher("WEB-INF/views/auth/login.jsp").forward(request, response);
            return;
        }

        Long userId = (Long) session.getAttribute("userId");
        LOGGER.log(Level.INFO, "Accessing feedback history page for userId: {0}", userId);
        try {
            long customerId = new FeedbackDAO().getCustomerIdByUserId(userId);
            List<Order> orders = orderDAO.getOrdersWithFeedback(customerId);
            request.setAttribute("orders", orders);
            request.getRequestDispatcher("WEB-INF/views/customer/feedback/feedbackHistory.jsp").forward(request, response);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error retrieving feedback history: {0}", e.getMessage());
            request.setAttribute("errorMessage", "Error retrieving feedbacked orders: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/views/customer/feedback/feedbackHistory.jsp").forward(request, response);
        }
    }
}
