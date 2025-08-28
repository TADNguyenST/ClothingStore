package controller.staff;

import dao.FeedbackDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
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
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        LOGGER.log(Level.INFO, "Accessing feedback list page without authentication.");

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
        LOGGER.log(Level.INFO, "POST request received for feedback list. Redirecting to GET without authentication.");
        response.sendRedirect(request.getContextPath() + "/feedbackList");
    }

    private void exportToCsv(List<Feedback> feedbackList, HttpServletResponse response) throws IOException {
        // Set response headers for CSV download
        response.setContentType("text/csv");
        response.setHeader("Content-Disposition", "attachment; filename=\"feedback_list.csv\"");

        // Write CSV content
        try (PrintWriter writer = response.getWriter()) {
            // Write CSV header
            writer.write("Feedback ID,Product ID,Customer ID,Order ID,Rating,Comments,Creation Date,Visibility,Verified\n");

            // Write feedback data
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
                        feedback.isVerified()? "Yes" : "No"));
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error exporting feedback to CSV: {0}", e.getMessage());
            response.setContentType("text/html");
            response.getWriter().write("<h2>Error</h2><p>Failed to export feedback to CSV: " + e.getMessage() + "</p>");
        }
    }

    @Override
    public void destroy() {
        if (feedbackDAO != null) {
            feedbackDAO.closeConnection();
        }
    }
}