/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.staff;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.Users;

/**
 *
 * @author Khoa
 */
@WebServlet(name = "StaffdashboardController", urlPatterns = {"/Staffdashboard"})
public class StaffdashboardController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        // Kiểm tra session và quyền truy cập
        HttpSession session = request.getSession(false);
        Users user = (session != null) ? (Users) session.getAttribute("staff") : null;

        if (user == null || !"Staff".equalsIgnoreCase(user.getRole()) || !"Active".equalsIgnoreCase(user.getStatus())) {
            response.sendRedirect(request.getContextPath() + "/StaffLogin");
            return;
        }

        // Lấy action/module/id
        String action = request.getParameter("action");
        String module = request.getParameter("module");
        String id = request.getParameter("id");

        if (action == null || action.isEmpty()) {
            action = "dashboard";
        }
        if (module == null || module.isEmpty()) {
            module = "staff";
        }

        request.setAttribute("currentAction", action);
        request.setAttribute("currentModule", module);
        if (id != null) {
            request.setAttribute("currentId", id);
        }

        String pageTitle = "Staff Dashboard";
        String targetJspPath = "/WEB-INF/views/staff/dashboard/staff-dashbroad.jsp"; // mặc định

        switch (module) {
            case "staff":
                if ("dashboard".equals(action)) {
                    pageTitle = "Staff Dashboard";
                }
                break;

            case "order":
                if ("orderList".equals(action)) {
                    pageTitle = "Order List";
                    targetJspPath = "/WEB-INF/views/staff/order/order-list.jsp";
                } else if ("orderDetails".equals(action)) {
                    pageTitle = "Order Details";
                    targetJspPath = "/WEB-INF/views/staff/order/order-details.jsp";
                }
                break;

            case "customer":
                switch (action) {
                    case "customerList":
                        pageTitle = "Customer Management";
                        targetJspPath = "/WEB-INF/views/staff/customer/customer-list.jsp";
                        break;
                    case "customerDetails":
                        pageTitle = "Customer Details";
                        targetJspPath = "/WEB-INF/views/staff/customer/customer-details.jsp";
                        break;
                    case "customerOrderHistory":
                        pageTitle = "Customer Order History";
                        targetJspPath = "/WEB-INF/views/staff/customer/customer-order-history.jsp";
                        break;
                }
                break;

            case "blog":
                switch (action) {
                    case "blogList":
                        pageTitle = "Blog Management";
                        targetJspPath = "/StaffBlogListController"; // forward sang controller riêng
                        break;
                    case "blogForm":
                        pageTitle = "Blog Form";
                        targetJspPath = "/StaffBlogController"; // forward sang controller riêng
                        break;
                }
                break;

            case "feedback":
                switch (action) {
                    case "feedbackList":
                        pageTitle = "Feedback List";
                        targetJspPath = "/WEB-INF/views/staff/feedback/feedback-list.jsp";
                        break;
                    case "viewFeedback":
                        pageTitle = "View Feedback";
                        targetJspPath = "/WEB-INF/views/staff/feedback/view-feedback.jsp";
                        break;
                    case "feedbackReplyForm":
                        pageTitle = "Reply Feedback";
                        targetJspPath = "/WEB-INF/views/staff/feedback/feedback-reply-form.jsp";
                        break;
                }
                break;

            default:
                pageTitle = "Page Not Found";
                targetJspPath = "/WEB-INF/views/common/404.jsp";
                break;
        }

        request.setAttribute("pageTitle", pageTitle);
        request.getRequestDispatcher(targetJspPath).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        doGet(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Staff Dashboard Controller";
    }
}
