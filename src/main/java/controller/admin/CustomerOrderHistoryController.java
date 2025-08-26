/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller.admin;

import dao.CustomerOrderHistoryDAO;
import dao.OrderDAO;
import model.Order;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.CustomerOrderHistory;

@WebServlet(name = "CustomerOrderHistoryController", urlPatterns = {"/CustomerOrderHistoryController"})
public class CustomerOrderHistoryController extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String customerIdStr = request.getParameter("customerId");
        if (customerIdStr != null && !customerIdStr.isEmpty()) {
            int customerId = Integer.parseInt(customerIdStr);

            CustomerOrderHistoryDAO dao = new CustomerOrderHistoryDAO();
            List<CustomerOrderHistory> historyList = dao.getOrderHistoryByCustomerId(customerId);

            request.setAttribute("historyList", historyList);
            request.setAttribute("customerId", customerId);
        }

        request.getRequestDispatcher("/WEB-INF/views/admin/managecustomer/order-history.jsp")
               .forward(request, response);
    }
}
