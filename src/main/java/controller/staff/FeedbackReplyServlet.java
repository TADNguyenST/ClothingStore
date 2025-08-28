package controller.staff;

import dao.FeedbackDAO;
import dao.FeedbackReplyDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.FeedbackReply;
import java.io.IOException;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.Feedback;

@WebServlet("/feedbackReply")
public class FeedbackReplyServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(FeedbackReplyServlet.class.getName());
    private FeedbackReplyDAO feedbackReplyDAO;
    private FeedbackDAO feedbackDAO;

    @Override
    public void init() throws ServletException {
        feedbackReplyDAO = new FeedbackReplyDAO();
        feedbackDAO = new FeedbackDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String feedbackId = request.getParameter("feedbackId");
        if (feedbackId == null || feedbackId.isEmpty()) {
            request.setAttribute("error", "Feedback ID is required");
            request.getRequestDispatcher("/WEB-INF/views/staff/feedback/feedbackList.jsp").forward(request, response);
            return;
        }
        try {
            long feedbackIdLong = Long.parseLong(feedbackId);
            // Check if feedback already has a reply
            String existingReply = feedbackDAO.getAllFeedback().stream()
                    .filter(f -> f.getFeedbackId() == feedbackIdLong)
                    .findFirst()
                    .map(Feedback::getReplyContent)
                    .orElse(null);
            if (existingReply != null && !existingReply.isEmpty()) {
                request.setAttribute("error", "This feedback has already been replied to");
                request.getRequestDispatcher("/WEB-INF/views/staff/feedback/feedbackList.jsp").forward(request, response);
                return;
            }
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
        try {
            long feedbackId = Long.parseLong(request.getParameter("feedbackId"));
            String content = request.getParameter("content");
            String visibility = request.getParameter("visibility");
            // Assuming staffId is obtained from session or authentication context
            long staffId = 1; // Replace with actual staff ID from session

            // Check if feedback already has a reply
            String existingReply = feedbackDAO.getAllFeedback().stream()
                    .filter(f -> f.getFeedbackId() == feedbackId)
                    .findFirst()
                    .map(Feedback::getReplyContent)
                    .orElse(null);
            if (existingReply != null && !existingReply.isEmpty()) {
                request.setAttribute("error", "This feedback has already been replied to");
                request.getRequestDispatcher("/WEB-INF/views/staff/feedback/feedbackReply.jsp").forward(request, response);
                return;
            }

            if (content == null || content.trim().isEmpty()) {
                request.setAttribute("error", "Reply content cannot be empty");
                request.getRequestDispatcher("/WEB-INF/views/staff/feedback/feedbackReply.jsp").forward(request, response);
                return;
            }

            FeedbackReply reply = new FeedbackReply(feedbackId, staffId, content, visibility);
            reply.setReplyDate(new Timestamp(System.currentTimeMillis()));

            boolean success = feedbackReplyDAO.addFeedbackReply(reply);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/feedbackList");
            } else {
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
    }
}