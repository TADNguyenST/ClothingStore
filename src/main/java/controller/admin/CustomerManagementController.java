/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller.admin;

import dao.CustomerDAO;
import dao.CustomerDAO.CustomerInfo;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "CustomerManagementController", urlPatterns = {"/CustomerManagement"})
public class CustomerManagementController extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");

        // 🔒 Kiểm tra session admin
        HttpSession session = request.getSession(false); // không tạo mới
        if (session == null || session.getAttribute("admin") == null) {
            response.sendRedirect(request.getContextPath() + "/AdminLogin");
            return;
        }

        CustomerDAO dao = new CustomerDAO();
        List<CustomerInfo> customerList;

        String keyword = request.getParameter("keyword");
        if (keyword != null && !keyword.trim().isEmpty()) {
            customerList = dao.searchCustomerByKeyword(keyword); // nếu có thêm hàm search
        } else {
            customerList = dao.getAllCustomers();
        }

        request.setAttribute("customerList", customerList);
        request.setAttribute("pageTitle", "Customer List");
        request.getRequestDispatcher("/WEB-INF/views/admin/managecustomer/customer-list.jsp").forward(request, response);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Customer management servlet";
    }
}
