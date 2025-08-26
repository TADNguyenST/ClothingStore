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

@WebServlet(name = "SendMailStaffController", urlPatterns = {"/sendMailStaff"})
public class SendMailStaffController extends HttpServlet {

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

        String userIdStr = request.getParameter("userId");
        if (userIdStr == null || userIdStr.isEmpty()) {
            response.sendRedirect("StaffManagement?errorMessage=Missing userId");
            return;
        }

        try {
            long userId = Long.parseLong(userIdStr);
            UserDAO userDAO = new UserDAO();
            Users user = userDAO.getUserById(userId);

            if (user == null) {
                response.sendRedirect("StaffManagement?errorMessage=User not found");
                return;
            }

            if (!"staff".equalsIgnoreCase(user.getRole())) {
                response.sendRedirect("StaffManagement?errorMessage=This is not a staff account");
                return;
            }

            // 1. Random mật khẩu mới
            String newPlainPassword = generateRandomPassword(10);

            // 2. Hash mật khẩu
            String hashed = PasswordUtil.hashPassword(newPlainPassword);

            // 3. Update vào DB
            boolean updated = userDAO.updatePasswordHashed(userId, hashed);
            if (!updated) {
                response.sendRedirect("StaffManagement?errorMessage=Failed to update password");
                return;
            }

            // 4. Soạn mail
            String subject = "ClothingStore - Staff Account Information";
            String html = "<div style='font-family: Arial, sans-serif; font-size:14px; color:#333;'>"
                        + "<p>Hello <b>" + escape(user.getFullName()) + "</b>,</p>"
                        + "<p>Your staff account information:</p>"
                        + "<p><b>Email:</b> " + escape(user.getEmail()) + "</p>"
                        + "<p><b>Password:</b> " + escape(newPlainPassword) + "</p>"
                        + "<p>Please log in and do not share this information with anyone.</p>"
                        + "<br/><p>— ClothingStore Team</p>"
                        + "</div>";

            // 5. Gửi mail
            boolean sent = EmailUtil.sendEmailHtml(user.getEmail(), subject, html);

            if (sent) {
                response.sendRedirect("StaffManagement?successMessage=Mail sent successfully to " + user.getEmail());
            } else {
                response.sendRedirect("StaffManagement?errorMessage=Password updated but failed to send email");
            }

        } catch (NumberFormatException ex) {
            response.sendRedirect("StaffManagement?errorMessage=Invalid userId");
        } catch (Exception ex) {
            ex.printStackTrace();
            response.sendRedirect("StaffManagement?errorMessage=Unexpected error");
        }
    }

    private String escape(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;");
    }
}

