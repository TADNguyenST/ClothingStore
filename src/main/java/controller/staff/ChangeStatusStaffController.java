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
import java.io.IOException;

@WebServlet("/ChangeStatusStaffController")
public class ChangeStatusStaffController extends HttpServlet {

    private StaffDAO staffDAO = new StaffDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            long userId = Long.parseLong(request.getParameter("userId"));

            // Lấy trạng thái hiện tại
            String currentStatus = staffDAO.getStaffStatusByUserId(userId);

            // Đảo trạng thái
            String newStatus = "Inactive";
            if ("Inactive".equalsIgnoreCase(currentStatus)) {
                newStatus = "Active";
            }

            // Cập nhật DB
            staffDAO.updateStaffStatus(userId, newStatus);

            // Redirect về trang StaffManagement (list staff)
            response.sendRedirect(request.getContextPath() + "/StaffManagement");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/StaffManagement?error=ChangeStatusFailed");
        }
    }
}

