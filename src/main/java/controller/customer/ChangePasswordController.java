/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.customer;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import model.Users;

/**
 *
 * @author Khoa
 */
@WebServlet(name = "ChangePasswordController", urlPatterns = {"/ChangePassword"})
public class ChangePasswordController extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try ( PrintWriter out = response.getWriter()) {
            String method = request.getMethod();

            if ("GET".equalsIgnoreCase(method)) {
                request.getRequestDispatcher("/WEB-INF/views/customer/profile/change-password.jsp").forward(request, response);
                return;
            }

            // POST
            HttpSession session = request.getSession();
            Users user = (Users) session.getAttribute("user");

            if (user == null) {
                response.sendRedirect("login.jsp");
                return;
            }

            String oldPassword = request.getParameter("oldPassword");
            String newPassword = request.getParameter("newPassword");
            String confirmPassword = request.getParameter("confirmPassword");

            if (!user.getPassword().equals(oldPassword)) {
                request.setAttribute("error", "Old password is incorrect.");
                request.getRequestDispatcher("/WEB-INF/views/customer/profile/change-password.jsp").forward(request, response);
                return;
            }

            if (!newPassword.equals(confirmPassword)) {
                request.setAttribute("error", "New password and confirmation do not match.");
                request.getRequestDispatcher("/WEB-INF/views/customer/profile/change-password.jsp").forward(request, response);
                return;
            }

            if (newPassword.length() < 8 || !newPassword.matches(".*\\d.*") || !newPassword.matches(".*[A-Z].*") || !newPassword.matches(".*[a-z].*")) {
                request.setAttribute("error", "Password must be at least 8 characters and include digits, uppercase and lowercase letters.");
                request.getRequestDispatcher("/WEB-INF/views/customer/profile/change-password.jsp").forward(request, response);
                return;
            }

            UserDAO userDAO = new UserDAO();
            boolean updated = userDAO.updatePassword(user.getUserId(), newPassword);

            if (updated) {
                user.setPassword(newPassword);
                session.setAttribute("user", user);
                request.setAttribute("message", "Password changed successfully.");
            } else {
                request.setAttribute("error", "Failed to update password.");
            }
            request.getRequestDispatcher("/WEB-INF/views/customer/profile/change-password.jsp").forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ✅ Đã thêm đoạn kiểm tra session ở đây
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/Login");
            return;
        }

        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    public String getServletInfo() {
        return "ChangePassword";
    }

}
