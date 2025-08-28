/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller.admin;

import dao.OrderDetailHistoryDAO;
import model.OrderDetailHistory;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "OrderDetailHistoryController", urlPatterns = {"/OrderDetailHistoryController"})
public class OrderDetailHistoryController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

      
        jakarta.servlet.http.HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("admin") == null) {
            response.sendRedirect(request.getContextPath() + "/AdminLogin");
            return;
        }

        String orderIdStr = request.getParameter("orderId");
        if (orderIdStr != null && !orderIdStr.isEmpty()) {
            int orderId = Integer.parseInt(orderIdStr);

            OrderDetailHistoryDAO dao = new OrderDetailHistoryDAO();
            List<OrderDetailHistory> details = dao.getOrderDetailsByOrderId(orderId);

            request.setAttribute("details", details);
            request.setAttribute("orderId", orderId);
        }

        request.getRequestDispatcher("/WEB-INF/views/admin/managecustomer/history-details.jsp")
               .forward(request, response);
    }
}
