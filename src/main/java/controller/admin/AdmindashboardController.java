package controller.admin;

import dao.OrderDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import model.CartItem;
import model.OrderHeader;
import model.Users;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

@WebServlet(name = "AdmindashboardController", urlPatterns = {"/Admindashboard"})
public class AdmindashboardController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private OrderDAO orderDAO;

    @Override
    public void init() {
        orderDAO = new OrderDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ✅ Auth: chỉ Admin
        HttpSession session = request.getSession(false);
        Users admin = (session != null) ? (Users) session.getAttribute("admin") : null;
        if (admin == null || !"Admin".equalsIgnoreCase(admin.getRole())
                || !"Active".equalsIgnoreCase(String.valueOf(admin.getStatus()))) {
            response.sendRedirect(request.getContextPath() + "/AdminLogin");
            return;
        }

        // ✅ Biến môi trường để JSP dùng chung cho Staff/Admin
        String cpath = request.getContextPath();
        request.setAttribute("sidebarJsp", "/WEB-INF/includes/admin-sidebar.jsp");
        request.setAttribute("basePath", "/Admindashboard");      // KHÔNG cộng cpath
        request.setAttribute("actionUrl", cpath + "/AdminOrder"); // CÓ cộng cpath

        String action = nvl(request.getParameter("action"), "dashboard");
        String module = nvl(request.getParameter("module"), "admin");
        String id = request.getParameter("id");

        request.setAttribute("currentAction", action);
        request.setAttribute("currentModule", module);
        if (id != null) {
            request.setAttribute("currentId", id);
        }

        String pageTitle = "Admin Dashboard";
        String targetJspPath = "/WEB-INF/views/admin/dashboard/admin-dashboard.jsp"; // mặc định

        try {
            if ("order".equalsIgnoreCase(module)) {
                if ("orderList".equalsIgnoreCase(action)) {
                    pageTitle = "Order List";
                    // ♻️ Dùng lại JSP của staff/order
                    targetJspPath = "/WEB-INF/views/staff/order/order-list.jsp";

                    // --- Filters & paging ---
                    String q = trimToNull(request.getParameter("q"));
                    String status = trimToNull(request.getParameter("status"));
                    String pay = trimToNull(request.getParameter("pay"));

                    int page = parseIntOrDefault(request.getParameter("page"), 1);
                    int pageSize = parseIntOrDefault(request.getParameter("size"), 12);
                    page = Math.max(page, 1);
                    if (pageSize < 1 || pageSize > 100) {
                        pageSize = 12;
                    }

                    int offset = (page - 1) * pageSize;

                    // --- Load data (y chang Staff) ---
                    List<OrderHeader> orders = orderDAO.listOrdersForStaff(q, status, pay, offset, pageSize);
                    int total = orderDAO.countOrdersForStaff(q, status, pay);
                    int pageCount = (int) Math.ceil(total / (double) pageSize);

                    request.setAttribute("orders", orders);
                    request.setAttribute("page", page);
                    request.setAttribute("pageCount", Math.max(pageCount, 1));
                    request.setAttribute("total", total);
                    request.setAttribute("size", pageSize);

                } else if ("orderDetails".equalsIgnoreCase(action)) {
                    pageTitle = "Order Details";
                    // ♻️ Dùng lại JSP của staff/order
                    targetJspPath = "/WEB-INF/views/staff/order/order-details.jsp";

                    long orderId = parseLongOrThrow(id, "Missing order id");
                    OrderHeader order = orderDAO.findOrderHeaderForStaff(orderId);
                    if (order == null) {
                        request.setAttribute("pageTitle", "Order Not Found");
                        request.getRequestDispatcher("/WEB-INF/views/common/404.jsp").forward(request, response);
                        return;
                    }

                    List<CartItem> items = orderDAO.loadItemsViewForOrder(orderId);
                    if (order.getSubtotal() == null) {
                        order.setSubtotal(BigDecimal.ZERO);
                    }
                    if (order.getDiscountAmount() == null) {
                        order.setDiscountAmount(BigDecimal.ZERO);
                    }
                    if (order.getShippingFee() == null) {
                        order.setShippingFee(BigDecimal.ZERO);
                    }
                    if (order.getTotalPrice() == null) {
                        order.setTotalPrice(BigDecimal.ZERO);
                    }

                    request.setAttribute("order", order);
                    request.setAttribute("items", items);
                    request.setAttribute("nextStatuses",
                            OrderDAO.getAllowedNextStatusesForStaff(order.getStatus(), order.getPaymentStatus()));
                    request.setAttribute("statusLocked", "CANCELED".equalsIgnoreCase(order.getStatus()));
                    request.setAttribute("canMarkRefunded",
                            "CANCELED".equalsIgnoreCase(order.getStatus())
                            && "REFUND_PENDING".equalsIgnoreCase(order.getPaymentStatus()));
                } else {
                    // action khác trong module order -> 404
                    pageTitle = "Page Not Found";
                    targetJspPath = "/WEB-INF/views/common/404.jsp";
                }

            } else {
                // Giữ nguyên các module khác của bạn (rút gọn từ bản gửi)
                switch (module) {
                    case "admin":
                        if ("dashboard".equalsIgnoreCase(action)) {
                            pageTitle = "Admin Dashboard";
                            targetJspPath = "/WEB-INF/views/admin/dashboard/admin-dashboard.jsp";
                        }
                        break;

                    case "category":
                        switch (action) {
                            case "categoryList":
                                response.sendRedirect(cpath + "/CategoryManager?action=list&module=category");
                                return;
                            case "categoryForm":
                                response.sendRedirect(cpath + "/CategoryManager?action=create&module=category");
                                return;
                            case "categoryDetails":
                                response.sendRedirect(cpath + "/CategoryManager?action=detail" + (id != null ? "&id=" + id : "") + "&module=category");
                                return;
                        }
                        break;

                    case "brand":
                        switch (action) {
                            case "brandList":
                                response.sendRedirect(cpath + "/BrandManager?action=list&module=brand");
                                return;
                            case "brandForm":
                                response.sendRedirect(cpath + "/BrandManager?action=create&module=brand");
                                return;
                            case "brandDetails":
                                response.sendRedirect(cpath + "/BrandManager?action=detail" + (id != null ? "&id=" + id : "") + "&module=brand");
                                return;
                            default:
                                pageTitle = "Page Not Found";
                                targetJspPath = "/WEB-INF/views/common/404.jsp";
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
                                targetJspPath = "/vouchers";
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
                                response.sendRedirect(cpath + "/ProductManager?action=list");
                                return;
                            case "productForm":
                                response.sendRedirect(cpath + "/ProductManager?action=create");
                                return;
                            case "productDetails":
                                response.sendRedirect(cpath + "/ProductManager?action=detail&id=" + id);
                                return;
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
                            case "stockmovement":
                                pageTitle = "Import Stock";
                                targetJspPath = "/StockMovement";
                                break;
                            case "purchaseorder":
                                pageTitle = "Purchase Order List";
                                targetJspPath = "/PurchaseOrderList";
                                break;
                        }
                        break;

                    case "supplier":
                        if ("supplierList".equalsIgnoreCase(action)) {
                            pageTitle = "Supplier List";
                            targetJspPath = "/Supplier";
                        }
                        break;

                    default:
                        pageTitle = "Page Not Found";
                        targetJspPath = "/WEB-INF/views/common/404.jsp";
                }
            }

        } catch (Exception ex) {
            throw new ServletException(ex);
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

    // Helpers
    private static String nvl(String s, String dft) {
        return (s == null || s.isEmpty()) ? dft : s;
    }

    private static String trimToNull(String s) {
        if (s == null) {
            return null;
        }
        String t = s.trim();
        return t.isEmpty() ? null : t;
    }

    private static int parseIntOrDefault(String s, int dft) {
        try {
            return Integer.parseInt(s);
        } catch (Exception e) {
            return dft;
        }
    }

    private static long parseLongOrThrow(String s, String msg) {
        try {
            return Long.parseLong(s);
        } catch (Exception e) {
            throw new IllegalArgumentException(msg);
        }
    }
}
