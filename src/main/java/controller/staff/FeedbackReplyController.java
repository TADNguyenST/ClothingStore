package controller.staff;

import dao.FeedbackDAO;
import dao.FeedbackReplyDAO;
import model.Feedback;
import model.FeedbackReply;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;

import java.io.IOException;
import java.util.Date;
import java.util.List;

@WebServlet(name = "FeedbackReplyController", urlPatterns = {"/staff/feedback-reply"})
public class FeedbackReplyController extends HttpServlet {

    private FeedbackReplyDAO replyDAO;
    private FeedbackDAO feedbackDAO;

    @Override
    public void init() {
        replyDAO = new FeedbackReplyDAO();
        feedbackDAO = new FeedbackDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String idParam = request.getParameter("feedback_id");
            String action = request.getParameter("action"); // "reply" or "view"

            if (idParam == null) {
                response.sendRedirect("feedback-list");
                return;
            }

            int feedbackId = Integer.parseInt(idParam);
            Feedback feedback = feedbackDAO.getFeedbackById(feedbackId);

            if (feedback == null) {
                request.setAttribute("message", "Feedback not found.");
                response.sendRedirect("feedback-list");
                return;
            }

            request.setAttribute("feedback", feedback);

            if ("view".equals(action)) {
                List<FeedbackReply> replyList = replyDAO.getRepliesByFeedbackId(feedbackId);
                request.setAttribute("replyList", replyList);
                request.getRequestDispatcher("/WEB-INF/views/staff/feedback/view-feedback.jsp").forward(request, response);
            } else {
                request.getRequestDispatcher("/WEB-INF/views/staff/feedback/feedback-reply-form.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("feedback-list");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int feedbackId = Integer.parseInt(request.getParameter("feedback_id"));
            int staffId = Integer.parseInt(request.getParameter("staff_id"));
            String content = request.getParameter("content");
            String visibility = request.getParameter("visibility");
            Date replyDate = new Date();

            FeedbackReply reply = new FeedbackReply(0, feedbackId, staffId, content, replyDate, visibility);
            replyDAO.insertReply(reply);

            response.sendRedirect("feedback-list");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("message", "Failed to submit reply: " + e.getMessage());

            int feedbackId = Integer.parseInt(request.getParameter("feedback_id"));
            Feedback feedback = feedbackDAO.getFeedbackById(feedbackId);
            request.setAttribute("feedback", feedback);

            request.getRequestDispatcher("/WEB-INF/views/staff/feedback/feedback-reply-form.jsp").forward(request, response);
        }
    }
}
