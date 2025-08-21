/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller.admin;

import dao.CustomerDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 *
 * @author Khoa
 */
@WebServlet(name = "ViewCustomerDetailsController", urlPatterns = {"/viewCustomer"})
public class ViewCustomerDetailsController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String userIdParam = request.getParameter("userId");
            if (userIdParam != null && !userIdParam.isEmpty()) {
                int userId = Integer.parseInt(userIdParam);
                CustomerDAO customerDAO = new CustomerDAO();
                CustomerDAO.CustomerInfo customerInfo = customerDAO.getCustomerInfoByUserId(userId);

                if (customerInfo != null) {
                    request.setAttribute("customerInfo", customerInfo);
                    request.getRequestDispatcher("/WEB-INF/views/admin/managecustomer/customer-detail.jsp").forward(request, response);
                    return;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Nếu có lỗi hoặc không có userId => redirect về danh sách
        response.sendRedirect(request.getContextPath() + "/admindashboard?action=customerList&module=customer");
    }
}

