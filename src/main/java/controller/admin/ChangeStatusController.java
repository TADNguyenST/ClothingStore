/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.admin;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/ChangeStatusController")
public class ChangeStatusController extends HttpServlet {

    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            long userId = Long.parseLong(request.getParameter("userId"));

            // Lấy trạng thái hiện tại
            String currentStatus = userDAO.getUserStatusById(userId);

            // Đảo trạng thái
            String newStatus = "Inactive";
            if ("Inactive".equalsIgnoreCase(currentStatus)) {
                newStatus = "Active";
            }

            // Cập nhật DB
            userDAO.updateUserStatus(userId, newStatus);

            // Redirect về danh sách customer
            response.sendRedirect(request.getContextPath() + "/CustomerManagement");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/CustomerManagement?error=ChangeStatusFailed");
        }
    }
}



