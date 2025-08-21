package controller.admin;

import dao.UserDAO;
import model.Users;
import util.EmailUtil;
import util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.security.SecureRandom;

@WebServlet(name = "SendInfoStaffController", urlPatterns = {"/sendInfoStaff"})
public class SendInfoStaffController extends HttpServlet {

    private String generateRandomPassword(int length) {
        final String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789@#$%";
        SecureRandom rnd = new SecureRandom();
        StringBuilder sb = new StringBuilder(length);
        for (int i = 0; i < length; i++) {
            sb.append(chars.charAt(rnd.nextInt(chars.length())));
        }
        return sb.toString();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // show form send-infostaff.jsp
        String userId = request.getParameter("userId");
        if (userId == null || userId.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/StaffManagement");
            return;
        }
        request.setAttribute("userId", userId);
        request.getRequestDispatcher("/WEB-INF/views/admin/mangestaff/send-infostaff.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String userIdStr = request.getParameter("userId");
        String recipientEmail = request.getParameter("email");

        if (userIdStr == null || userIdStr.isEmpty() || recipientEmail == null || recipientEmail.isEmpty()) {
            request.setAttribute("error", "Missing userId or recipient email.");
            request.setAttribute("userId", userIdStr);
            request.getRequestDispatcher("/WEB-INF/views/admin/mangestaff/send-infostaff.jsp").forward(request, response);
            return;
        }

        try {
            long userId = Long.parseLong(userIdStr);
            UserDAO userDAO = new UserDAO();
            Users user = userDAO.getUserById(userId);

            if (user == null) {
                request.setAttribute("error", "User not found.");
            } else if (!"staff".equalsIgnoreCase(user.getRole())) {
                request.setAttribute("error", "This user is not a staff account.");
            } else {
                // 1) generate password
                String newPlain = generateRandomPassword(10);

                // 2) hash password
                String hashed = PasswordUtil.hashPassword(newPlain);

                // 3) update DB (dùng updatePasswordHashed)
                boolean updated = userDAO.updatePasswordHashed(userId, hashed);
                if (!updated) {
                    request.setAttribute("error", "Failed to update password in DB.");
                } else {
                    // 4) compose email HTML (recipientEmail receives staff account & new password)
                    String subject = "ClothingStore - New password for staff account";
                    String html = "<div style='font-family: Arial, Helvetica, sans-serif; font-size:14px; color:#333;'>"
                                + "<p>Hello,</p>"
                                + "<p>The account information you requested:</p>"
                                + "<p><b>Account (login email):</b> " + escape(user.getEmail()) + "</p>"
                                + "<p><b>New password:</b> " + escape(newPlain) + "</p>"
                                + "<p>You can login with this password immediately.</p>"
                                + "<br/><p>— ClothingStore Team</p>"
                                + "</div>";

                    boolean sent = EmailUtil.sendEmailHtml(recipientEmail, subject, html);
                    if (sent) {
                        request.setAttribute("success", "New password sent to " + recipientEmail);
                    } else {
                        request.setAttribute("error", "Password updated but failed to send email.");
                    }
                }
            }

        } catch (NumberFormatException ex) {
            request.setAttribute("error", "Invalid userId.");
        } catch (Exception ex) {
            ex.printStackTrace();
            request.setAttribute("error", "Unexpected error occurred.");
        }

        request.setAttribute("userId", userIdStr);
        request.getRequestDispatcher("/WEB-INF/views/admin/mangestaff/send-infostaff.jsp").forward(request, response);
    }

    private String escape(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;");
    }
}
