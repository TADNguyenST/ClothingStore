package controller.staff;

import dao.FeedbackDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Feedback;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/feedbackList")
public class StaffFeedbackListServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(StaffFeedbackListServlet.class.getName());
    private FeedbackDAO feedbackDAO;

    @Override
    public void init() throws ServletException {
        feedbackDAO = new FeedbackDAO();
        LOGGER.log(Level.INFO, "Initializing StaffFeedbackListServlet");
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
        LOGGER.log(Level.INFO, "Received GET request for /feedbackList");
        if (!isAuthenticated(request, response)) {
            return;
        }

        try {
            List<Feedback> feedbackList = feedbackDAO.getAllFeedback();

            // Check if export to CSV is requested
            String export = request.getParameter("export");
            if ("csv".equalsIgnoreCase(export)) {
                exportToCsv(feedbackList, response);
                return;
            }

            // Regular display request
            request.setAttribute("feedbackList", feedbackList);
            LOGGER.log(Level.INFO, "Forwarding to feedback list page");
            request.getRequestDispatcher("/WEB-INF/views/staff/feedback/feedbackList.jsp").forward(request, response);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error retrieving feedback list: {0}", e.getMessage());
            request.setAttribute("error", "Error retrieving feedback list: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/staff/feedback/feedbackList.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        LOGGER.log(Level.INFO, "Received POST request for /feedbackList");
        if (!isAuthenticated(request, response)) {
            return;
        }
        LOGGER.log(Level.INFO, "Redirecting POST to GET");
        response.sendRedirect(request.getContextPath() + "/feedbackList");
    }

    private void exportToCsv(List<Feedback> feedbackList, HttpServletResponse response) throws IOException {
        LOGGER.log(Level.INFO, "Exporting feedback list to CSV");
        response.setContentType("text/csv; charset=UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=\"feedback_list.csv\"");

        try (PrintWriter writer = response.getWriter()) {
            writer.write("Feedback ID,Product ID,Customer ID,Order ID,Rating,Comments,Creation Date,Visibility,Verified\n");

            SimpleDateFormat dateFormat = new SimpleDateFormat("dd-MM-yyyy HH:mm");
            for (Feedback feedback : feedbackList) {
                String orderId = feedback.getOrderId() != null ? feedback.getOrderId().toString() : "N/A";
                String comments = feedback.getComments() != null ? "\"" + feedback.getComments().replace("\"", "\"\"") + "\"" : "N/A";
                String visibility = feedback.getVisibility() != null ? feedback.getVisibility() : "N/A";
                String creationDate = feedback.getCreationDate() != null ? dateFormat.format(feedback.getCreationDate()) : "N/A";

                writer.write(String.format("%d,%d,%d,%s,%d/5,%s,%s,%s,%s\n",
                        feedback.getFeedbackId(),
                        feedback.getProductId(),
                        feedback.getCustomerId(),
                        orderId,
                        feedback.getRating(),
                        comments,
                        creationDate,
                        visibility,
                        feedback.isVerified() ? "Yes" : "No"));
            }
            LOGGER.log(Level.INFO, "Successfully exported CSV");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error exporting feedback to CSV: {0}", e.getMessage());
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().write("<h2>Error</h2><p>Failed to export feedback to CSV: " + e.getMessage() + "</p>");
        }
    }

    @Override
    public void destroy() {
        if (feedbackDAO != null) {
            feedbackDAO.closeConnection();
        }
        LOGGER.log(Level.INFO, "Destroying StaffFeedbackListServlet");
    }
}