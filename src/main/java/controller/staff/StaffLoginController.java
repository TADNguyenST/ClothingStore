/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.staff;

import dao.StaffDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Users;

import java.io.IOException;

/**
 * Controller xử lý đăng nhập cho nhân viên
 */
@WebServlet(name = "StaffLoginController", urlPatterns = {"/StaffLogin"})
public class StaffLoginController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Hiển thị trang đăng nhập cho nhân viên
        request.getRequestDispatcher("/WEB-INF/views/staff/staff-login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Lấy thông tin từ form
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        // Kiểm tra đăng nhập
        StaffDAO dao = new StaffDAO();
        Users user = dao.loginStaff(email, password);

        if (user != null && "Staff".equalsIgnoreCase(user.getRole()) && "Active".equalsIgnoreCase(user.getStatus())) {
            HttpSession session = request.getSession();
            session.setAttribute("staff", user); // lưu thông tin nhân viên vào session
            response.sendRedirect(request.getContextPath() + "/Reports"); // chuyển đến dashboard
        } else {
            request.setAttribute("error", "Incorrect email or password, or invalid account.");
            request.getRequestDispatcher("/WEB-INF/views/staff/staff-login.jsp").forward(request, response);
        }
    }
}
