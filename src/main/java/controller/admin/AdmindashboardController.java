package controller.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

public class AdmindashboardController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // ... (authentication and authorization part, if any) ...

        String action = request.getParameter("action");
        String module = request.getParameter("module");
        String id = request.getParameter("id");

        if (action == null || action.isEmpty()) {
            action = "dashboard";
            module = "admin";
        }
        if (module == null || module.isEmpty()) {
            module = "admin";
        }

        request.setAttribute("currentAction", action);
        request.setAttribute("currentModule", module);
        if (id != null) {
            request.setAttribute("currentId", id);
        }

        String pageTitle = "Admin Dashboard";
        String targetJspPath = "/WEB-INF/views/admin/dashboard/admin-dashboard.jsp"; // Default target JSP

        // Determine page title and target JSP path
        if (module != null && action != null) {
            switch (module) {
                case "admin":
                    if ("dashboard".equals(action)) {
                        pageTitle = "Admin Dashboard";
                        targetJspPath = "/WEB-INF/views/admin/dashboard/admin-dashboard.jsp";
                    }
                    break;
                case "category":
                    switch (action) {
                        case "categoryList":
                            pageTitle = "Category List";
                            response.sendRedirect(request.getContextPath() + "/CategoryManager?action=list&module=category");
                            return;
                        case "categoryForm":
                            pageTitle = "Category Form";
                            response.sendRedirect(request.getContextPath() + "/CategoryManager?action=create&module=category");
                            return;
                        case "categoryDetails":
                            pageTitle = "Category Details";
                            response.sendRedirect(request.getContextPath() + "/CategoryManager?action=detail" + (id != null ? "&id=" + id : "") + "&module=category");
                            return;
                    }
                    break;
                case "brand":
                    switch (action) {
                        case "brandList":
                            pageTitle = "Brand List";
                            response.sendRedirect(request.getContextPath() + "/BrandManager?action=list&module=brand");
                            break;
                        case "brandForm":
                            pageTitle = "Brand Form";
                            response.sendRedirect(request.getContextPath() + "/BrandManager?action=create&module=brand");
                            break;
                        case "brandDetails":
                            pageTitle = "Brand Details";
                            response.sendRedirect(request.getContextPath() + "/BrandManager?action=detail" + (id != null ? "&id=" + id : "") + "&module=brand");
                            break;
                        default:
                            pageTitle = "Page Not Found";
                            targetJspPath = "/WEB-INF/views/common/404.jsp";
                            break;
                    }
                    break;
                case "mangestaff":
                    switch (action) {
                        case "staffList":
                            pageTitle = "Staff Account Management";
                            targetJspPath = "/WEB-INF/views/admin/mangestaff/staff-list.jsp";
                            break;
                        case "staffForm":
                            pageTitle = "Staff Account Form";
                            targetJspPath = "/WEB-INF/views/admin/mangestaff/staff-form.jsp";
                            break;
                        case "staffDetails":
                            pageTitle = "Staff Account Details";
                            targetJspPath = "/WEB-INF/views/admin/mangestaff/staff-details.jsp";
                            break;
                    }
                    break;
                case "voucher":
                    switch (action) {
                        case "voucherList":
                            pageTitle = "Voucher List";
                            targetJspPath = "/WEB-INF/views/admin/voucher/voucher-list.jsp";
                            break;
                        case "voucherForm":
                            pageTitle = "Voucher Form";
                            targetJspPath = "/WEB-INF/views/admin/voucher/voucher-form.jsp";
                            break;
                        case "sendVoucher":
                            pageTitle = "Send Voucher";
                            targetJspPath = "/WEB-INF/views/admin/voucher/send-voucher.jsp";
                            break;
                        case "voucherDetails":
                            pageTitle = "Voucher Details";
                            targetJspPath = "/WEB-INF/views/admin/voucher/voucher-details.jsp";
                            break;
                    }
                    break;
                case "product":
                    switch (action) {
                        case "productList":
                            pageTitle = "Product List";
                            response.sendRedirect(request.getContextPath() + "/ProductManager?action=list");
                            return;
                        case "productForm":
                            pageTitle = "Product Form";
                            response.sendRedirect(request.getContextPath() + "/ProductManager?action=create");
                            return;
                        case "productDetails":
                            pageTitle = "Product Details";
                            response.sendRedirect(request.getContextPath() + "/ProductManager?action=detail&id=" + id);
                            return;
                    }
                    break;
                case "order":
                    switch (action) {
                        case "orderList":
                            pageTitle = "Order List";
                            targetJspPath = "/WEB-INF/views/staff/order/order-list.jsp";
                            break;
                        case "orderDetails":
                            pageTitle = "Order Details";
                            targetJspPath = "/WEB-INF/views/staff/order/order-details.jsp";
                            break;
                    }
                    break;
                case "blog":
                    switch (action) {
                        case "blogList":
                            pageTitle = "Blog Management";
                            targetJspPath = "/StaffBlogListController";
                            break;
                        case "blogForm":
                            pageTitle = "Blog Form";
                            targetJspPath = "/StaffBlogController";
                            break;
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
                case "feedback":
                    switch (action) {
                        case "feedbackList":
                            pageTitle = "Feedback Management";
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
                case "revenue":
                    switch (action) {
                        case "bestSellingProducts":
                            pageTitle = "Best Selling Products";
                            targetJspPath = "/WEB-INF/views/staff/revenue/best-selling-products.jsp";
                            break;
                        case "revenueByProduct":
                            pageTitle = "Revenue by Product";
                            targetJspPath = "/WEB-INF/views/staff/revenue/revenue-by-product.jsp";
                            break;
                    }
                    break;
                case "stock":
                    switch (action) {
                        case "stockList":
                            pageTitle = "Stock List";
                            targetJspPath = "/Stock";
                            break;
                        case "importStock":
                            pageTitle = "Import Stock";
                            targetJspPath = "/StockMovement";
                            break;
                        case "stockDetails":
                            pageTitle = "Stock Details";
                            targetJspPath = "/WEB-INF/views/staff/stock/stock-details.jsp";
                            break;
                        case "stockStatistics":
                            pageTitle = "Stock Statistics";
                            targetJspPath = "/StockController";
                            break;
                    }
                    break;
                case "supplier":
                    switch (action) {
                        case "supplierList":
                            pageTitle = "Supplier List";
                            targetJspPath = "/WEB-INF/views/staff/supplier/supplier-list.jsp";
                            break;
                        case "supplierForm":
                            pageTitle = "Supplier Form";
                            targetJspPath = "/WEB-INF/views/staff/supplier/supplier-form.jsp";
                            break;
                        case "supplierDetails":
                            pageTitle = "Supplier Details";
                            targetJspPath = "/WEB-INF/views/staff/supplier/supplier-details.jsp";
                            break;
                    }
                    break;
                default:
                    pageTitle = "Page Not Found";
                    targetJspPath = "/WEB-INF/views/common/404.jsp"; // Assuming you have a common 404 page
                    break;
            }
        }
        request.setAttribute("pageTitle", pageTitle);

        // Forward trực tiếp đến trang JSP cụ thể
        request.getRequestDispatcher(targetJspPath).forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        doGet(request, response);
    }
}
