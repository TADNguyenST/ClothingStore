/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.customer;

import dao.UserDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Users;

/**
 *
 * @author Khoa
 */
@WebServlet(name = "ChangePasswordController", urlPatterns = {"/ChangePassword"})
public class ChangePasswordController extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try ( PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet ChangePasswordController</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ChangePasswordController at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/customer/profile/change-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Lấy dữ liệu từ form
        String oldPassword = request.getParameter("oldPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        // Lấy user hiện tại từ session
        Users user = (Users) request.getSession().getAttribute("user");

        // Kiểm tra null
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // Kiểm tra mật khẩu cũ có đúng không
        if (!user.getPassword().equals(oldPassword)) {
            request.setAttribute("error", "Old password is incorrect.");
            request.getRequestDispatcher("/WEB-INF/views/customer/profile/change-password.jsp").forward(request, response);
            return;
        }

        // Kiểm tra mật khẩu mới hợp lệ
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

        // Gọi DAO để cập nhật mật khẩu
        UserDAO dao = new UserDAO();
        boolean success = dao.updatePassword(user.getUserId(), newPassword);
        if (success) {
            user.setPassword(newPassword); // Cập nhật lại session
            request.setAttribute("success", "Password changed successfully.");
        } else {
            request.setAttribute("error", "Failed to update password. Please try again.");
        }

        request.getRequestDispatcher("/WEB-INF/views/customer/profile/change-password.jsp").forward(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Change Password";
    }// </editor-fold>

}
