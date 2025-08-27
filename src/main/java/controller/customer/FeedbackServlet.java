package controller.customer;
import dao.FeedbackDAO;
import dao.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Feedback;
import model.Order;
import java.io.IOException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/feedback")
public class FeedbackServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(FeedbackServlet.class.getName());
    private FeedbackDAO feedbackDAO;
    private OrderDAO orderDAO;

    @Override
    public void init() throws ServletException {
        feedbackDAO = new FeedbackDAO();
        orderDAO = new OrderDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        LOGGER.log(Level.INFO, "Checking session for feedback page access. Session exists: {0}", (session != null));
        if (session == null || session.getAttribute("userId") == null) {
            LOGGER.log(Level.WARNING, "Unauthorized access attempt to view feedback form. Redirecting to login.");
            String redirectAfterLogin = request.getRequestURI() + (request.getQueryString() != null ? "?" + request.getQueryString() : "");
            session = request.getSession(true);
            session.setAttribute("redirectAfterLogin", redirectAfterLogin);
            request.setAttribute("errorMessage", "Please log in to submit feedback.");
            request.getRequestDispatcher("WEB-INF/views/auth/login.jsp").forward(request, response);
            return;
        }
        Long userId = (Long) session.getAttribute("userId");
        LOGGER.log(Level.INFO, "Accessing feedback page for userId: {0}", userId);
        try {
            List<Order> orders = orderDAO.getOrdersForFeedback(userId);
            request.setAttribute("orders", orders);
            request.getRequestDispatcher("WEB-INF/views/customer/feedback/feedbackForm.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error retrieving order list: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/views/customer/feedback/feedbackForm.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        LOGGER.log(Level.INFO, "Checking session for feedback submission. Session exists: {0}", (session != null));
        if (session == null || session.getAttribute("userId") == null) {
            LOGGER.log(Level.WARNING, "Unauthorized access attempt to submit feedback. Redirecting to login.");
            String redirectAfterLogin = request.getRequestURI();
            session = request.getSession(true);
            session.setAttribute("redirectAfterLogin", redirectAfterLogin);
            request.setAttribute("errorMessage", "Please log in to submit feedback.");
            request.getRequestDispatcher("WEB-INF/views/auth/login.jsp").forward(request, response);
            return;
        }
        Long userId = (Long) session.getAttribute("userId");
        LOGGER.log(Level.INFO, "Processing feedback submission for userId: {0}", userId);
        try {
            String orderIdParam = request.getParameter("orderId");
            String ratingParam = request.getParameter("rating");
            String comments = request.getParameter("comments");
            String visibility = request.getParameter("visibility") != null ? request.getParameter("visibility") : "Public";
            if (orderIdParam == null || ratingParam == null || comments == null || comments.trim().isEmpty()) {
                LOGGER.log(Level.WARNING, "Missing required feedback fields");
                request.setAttribute("errorMessage", "Please fill in all required feedback information.");
                request.getRequestDispatcher("WEB-INF/views/customer/feedback/feedbackForm.jsp").forward(request, response);
                return;
            }
            long orderId = Long.parseLong(orderIdParam);
            int rating = Integer.parseInt(ratingParam);
            if (rating < 1 || rating > 5) {
                LOGGER.log(Level.WARNING, "Invalid rating value: {0}", rating);
                request.setAttribute("errorMessage", "Rating must be between 1 and 5.");
                request.getRequestDispatcher("WEB-INF/views/customer/feedback/feedbackForm.jsp").forward(request, response);
                return;
            }
            if (!visibility.equals("Public") && !visibility.equals("Private")) {
                visibility = "Public";
            }
            // Lấy customerId từ userId
            long customerId = feedbackDAO.getCustomerIdByUserId(userId);
            // Get product_id list from order_items
            List<Long> productIds = feedbackDAO.getProductIdsByOrderId(orderId);
            if (productIds.isEmpty()) {
                LOGGER.log(Level.WARNING, "No products found for orderId: {0}", orderId);
                request.setAttribute("errorMessage", "No products found in this order.");
                request.getRequestDispatcher("WEB-INF/views/customer/feedback/feedbackForm.jsp").forward(request, response);
                return;
            }
            boolean success = true;
            // Create feedback for each product
            for (Long productId : productIds) {
                Feedback feedback = new Feedback(0, customerId, orderId, rating, comments, visibility, true);
                feedback.setProductId(productId);
                success &= feedbackDAO.addFeedback(feedback);
            }
            if (success) {
                LOGGER.log(Level.INFO, "Feedback submitted successfully for orderId: {0}", orderId);
                session.setAttribute("message", "Feedback was successfully submitted for all products in the order!");
                response.sendRedirect(request.getContextPath() + "/feedback");
            } else {
                LOGGER.log(Level.SEVERE, "Failed to submit feedback for some products in orderId: {0}", orderId);
                request.setAttribute("errorMessage", "Failed to submit feedback for some products. Please try again.");
                request.getRequestDispatcher("WEB-INF/views/customer/feedback/feedbackForm.jsp").forward(request, response);
            }
        } catch (NumberFormatException e) {
            LOGGER.log(Level.SEVERE, "Invalid input format: {0}", e.getMessage());
            request.setAttribute("errorMessage", "Invalid input data: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/views/customer/feedback/feedbackForm.jsp").forward(request, response);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error submitting feedback: {0}", e.getMessage());
            request.setAttribute("errorMessage", "Unexpected error while submitting feedback: " + e.getMessage());
            request.getRequestDispatcher("WEB-INF/views/customer/feedback/feedbackForm.jsp").forward(request, response);
        }
    }

    @Override
    public void destroy() {
        if (feedbackDAO != null) {
            feedbackDAO.closeConnection();
        }
    }
}