/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.admin;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import dao.UserDAO;
import model.Users;

@WebServlet(name = "AdminLoginController", urlPatterns = {"/AdminLogin"})
public class AdminLoginController extends HttpServlet {

    /**
     * Handles the HTTP <code>GET</code> method.
     * Chuyển hướng đến trang login cho admin.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/admin/admin-login.jsp").forward(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     * Xử lý logic đăng nhập admin.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        UserDAO dao = new UserDAO();
        Users admin = dao.checkLoginAdmin(email, password); // gọi phương thức mới

        if (admin != null && "Admin".equalsIgnoreCase(admin.getRole())) {
            // Nếu đăng nhập thành công và đúng role Admin
            HttpSession session = request.getSession();
            session.setAttribute("admin", admin);
            response.sendRedirect(request.getContextPath() + "/Reports");
        } else {
            // Sai tài khoản/mật khẩu hoặc không phải admin
            request.setAttribute("error", "Invalid credentials or not an Admin account.");
            request.getRequestDispatcher("/WEB-INF/views/admin/admin-login.jsp").forward(request, response);
        }
    }

    @Override
    public String getServletInfo() {
        return "Admin Login Controller";
    }
}
