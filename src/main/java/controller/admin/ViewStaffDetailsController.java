/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller.admin;

import dao.StaffDAO;
import dao.UserDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 *
 * @author Khoa
 */
@WebServlet(name = "ViewStaffDetailsController", urlPatterns = {"/viewStaff"})
public class ViewStaffDetailsController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 🔒 Kiểm tra session admin
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("admin") == null) {
            response.sendRedirect(request.getContextPath() + "/AdminLogin");
            return;
        }

        try {
            String userIdParam = request.getParameter("userId");
            if (userIdParam != null && !userIdParam.isEmpty()) {
                int userId = Integer.parseInt(userIdParam);
                StaffDAO staffDAO = new StaffDAO();
                StaffDAO.StaffInfo staffInfo = staffDAO.getStaffInfoByUserId(userId);

                if (staffInfo != null) {
                    request.setAttribute("staffInfo", staffInfo);
                    request.getRequestDispatcher("/WEB-INF/views/admin/mangestaff/staff-details.jsp").forward(request, response);
                    return;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Nếu có lỗi hoặc không có userId => redirect về danh sách
        response.sendRedirect(request.getContextPath() + "/StaffManagement");
    }
}
