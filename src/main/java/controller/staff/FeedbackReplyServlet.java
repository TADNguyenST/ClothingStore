package controller.staff;

import dao.FeedbackDAO;
import dao.FeedbackReplyDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.FeedbackReply;
import model.Feedback;
import model.Users;
import java.io.IOException;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/feedbackReply")
public class FeedbackReplyServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(FeedbackReplyServlet.class.getName());
    private FeedbackReplyDAO feedbackReplyDAO;
    private FeedbackDAO feedbackDAO;

    @Override
    public void init() throws ServletException {
        feedbackReplyDAO = new FeedbackReplyDAO();
        feedbackDAO = new FeedbackDAO();
        LOGGER.log(Level.INFO, "Initializing FeedbackReplyServlet");
    }

    private boolean isAuthenticated(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        LOGGER.log(Level.INFO, "Checking session: {0}, Staff attribute: {1}", 
                   new Object[]{session != null, session != null ? session.getAttribute("staff") : null});
        if (session == null || session.getAttribute("staff") == null) {
            request.setAttribute("error", "Please log in to access this page.");
            LOGGER.log(Level.WARNING, "Not authenticated, redirecting to login page");
            try {
                request.getRequestDispatcher("/WEB-INF/views/staff/staff-login.jsp").forward(request, response);
            } catch (ServletException e) {
                LOGGER.log(Level.SEVERE, "Error redirecting to login page: {0}", e.getMessage());
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Server error during redirection");
                return false;
            }
            return false;
        }
        LOGGER.log(Level.INFO, "Authenticated, allowing access");
        return true;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        LOGGER.log(Level.INFO, "Received GET request for /feedbackReply");
        if (!isAuthenticated(request, response)) {
            return;
        }

        String feedbackId = request.getParameter("feedbackId");
        if (feedbackId == null || feedbackId.isEmpty()) {
            LOGGER.log(Level.WARNING, "Missing feedbackId in GET request");
            request.setAttribute("error", "Feedback ID is required");
            request.getRequestDispatcher("/WEB-INF/views/staff/feedback/feedbackList.jsp").forward(request, response);
            return;
        }
        try {
            long feedbackIdLong = Long.parseLong(feedbackId);
            String existingReply = feedbackDAO.getAllFeedback().stream()
                    .filter(f -> f.getFeedbackId() == feedbackIdLong)
                    .findFirst()
                    .map(Feedback::getReplyContent)
                    .orElse(null);
            if (existingReply != null && !existingReply.isEmpty()) {
                LOGGER.log(Level.WARNING, "Feedback {0} already has a reply", feedbackIdLong);
                request.setAttribute("error", "This feedback has already been replied to");
                request.getRequestDispatcher("/WEB-INF/views/staff/feedback/feedbackList.jsp").forward(request, response);
                return;
            }
            LOGGER.log(Level.INFO, "Forwarding to feedback reply page for feedbackId: {0}", feedbackIdLong);
            request.getRequestDispatcher("/WEB-INF/views/staff/feedback/feedbackReply.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            LOGGER.log(Level.SEVERE, "Invalid feedback ID: {0}", e.getMessage());
            request.setAttribute("error", "Invalid feedback ID");
            request.getRequestDispatcher("/WEB-INF/views/staff/feedback/feedbackList.jsp").forward(request, response);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error checking existing reply: {0}", e.getMessage());
            request.setAttribute("error", "Error checking existing reply: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/staff/feedback/feedbackList.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        LOGGER.log(Level.INFO, "Received POST request for /feedbackReply");
        if (!isAuthenticated(request, response)) {
            return;
        }

        try {
            HttpSession session = request.getSession(false);
            Users staff = (Users) session.getAttribute("staff");
            long staffId = staff.getUserId(); // Assumes Users has getUserId()

            long feedbackId = Long.parseLong(request.getParameter("feedbackId"));
            String content = request.getParameter("content");
            String visibility = request.getParameter("visibility");

            String existingReply = feedbackDAO.getAllFeedback().stream()
                    .filter(f -> f.getFeedbackId() == feedbackId)
                    .findFirst()
                    .map(Feedback::getReplyContent)
                    .orElse(null);
            if (existingReply != null && !existingReply.isEmpty()) {
                LOGGER.log(Level.WARNING, "Feedback {0} already has a reply", feedbackId);
                request.setAttribute("error", "This feedback has already been replied to");
                request.getRequestDispatcher("/WEB-INF/views/staff/feedback/feedbackReply.jsp").forward(request, response);
                return;
            }

            if (content == null || content.trim().isEmpty()) {
                LOGGER.log(Level.WARNING, "Empty reply content for feedbackId: {0}", feedbackId);
                request.setAttribute("error", "Reply content cannot be empty");
                request.getRequestDispatcher("/WEB-INF/views/staff/feedback/feedbackReply.jsp").forward(request, response);
                return;
            }

            FeedbackReply reply = new FeedbackReply(feedbackId, staffId, content, visibility);
            reply.setReplyDate(new Timestamp(System.currentTimeMillis()));

            boolean success = feedbackReplyDAO.addFeedbackReply(reply);
            if (success) {
                LOGGER.log(Level.INFO, "Successfully submitted reply for feedbackId: {0}", feedbackId);
                response.sendRedirect(request.getContextPath() + "/feedbackList");
            } else {
                LOGGER.log(Level.WARNING, "Failed to submit reply for feedbackId: {0}", feedbackId);
                request.setAttribute("error", "Failed to submit reply");
                request.getRequestDispatcher("/WEB-INF/views/staff/feedback/feedbackReply.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error submitting feedback reply: {0}", e.getMessage());
            request.setAttribute("error", "Error submitting reply: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/staff/feedback/feedbackReply.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            LOGGER.log(Level.SEVERE, "Invalid feedback ID: {0}", e.getMessage());
            request.setAttribute("error", "Invalid feedback ID");
            request.getRequestDispatcher("/WEB-INF/views/staff/feedback/feedbackReply.jsp").forward(request, response);
        }
    }

    @Override
    public void destroy() {
        if (feedbackReplyDAO != null) {
            feedbackReplyDAO.closeConnection();
        }
        if (feedbackDAO != null) {
            feedbackDAO.closeConnection();
        }
        LOGGER.log(Level.INFO, "Destroying FeedbackReplyServlet");
    }
}