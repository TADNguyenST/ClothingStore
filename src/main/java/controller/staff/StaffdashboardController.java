/*
 * StaffdashboardController - ĐÃ BỔ SUNG LOAD ORDER LIST & ORDER DETAILS
 */
package controller.staff;

import dao.OrderDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.CartItem;
import model.Users;
import model.OrderHeader;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

@WebServlet(name = "StaffdashboardController", urlPatterns = {"/Staffdashboard"})
public class StaffdashboardController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private OrderDAO orderDAO;

    @Override
    public void init() {
        orderDAO = new OrderDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Kiểm tra session & quyền
        HttpSession session = request.getSession(false);
        Users user = (session != null) ? (Users) session.getAttribute("staff") : null;
        if (user == null || !"Staff".equalsIgnoreCase(user.getRole()) || !"Active".equalsIgnoreCase(user.getStatus())) {
            response.sendRedirect(request.getContextPath() + "/StaffLogin");
            return;
        }

        String action = nvl(request.getParameter("action"), "dashboard");
        String module = nvl(request.getParameter("module"), "staff");
        String id = request.getParameter("id");

        request.setAttribute("currentAction", action);
        request.setAttribute("currentModule", module);
        if (id != null) {
            request.setAttribute("currentId", id);
        }

        String pageTitle = "Staff Dashboard";
        String targetJspPath = "/WEB-INF/views/staff/dashboard/staff-dashbroad.jsp";

        try {
            switch (module) {
                case "order": {
                    if ("orderList".equalsIgnoreCase(action)) {
                        pageTitle = "Order List";
                        targetJspPath = "/WEB-INF/views/staff/order/order-list.jsp";

                        // --- Đọc filter & phân trang ---
                        String q = trimToNull(request.getParameter("q"));
                        String status = trimToNull(request.getParameter("status"));
                        String pay = trimToNull(request.getParameter("pay"));

                        int page = parseIntOrDefault(request.getParameter("page"), 1);
                        int pageSize = parseIntOrDefault(request.getParameter("size"), 12);
                        if (page < 1) {
                            page = 1;
                        }
                        if (pageSize < 1 || pageSize > 100) {
                            pageSize = 12;
                        }

                        int offset = (page - 1) * pageSize;

                        // --- Query list + count ---
                        List<OrderHeader> orders = orderDAO.listOrdersForStaff(q, status, pay, offset, pageSize);
                        int total = orderDAO.countOrdersForStaff(q, status, pay);
                        int pageCount = (int) Math.ceil(total / (double) pageSize);

                        // --- Push sang JSP ---
                        request.setAttribute("orders", orders);
                        request.setAttribute("page", page);
                        request.setAttribute("pageCount", Math.max(pageCount, 1));
                        request.setAttribute("total", total);
                        request.setAttribute("size", pageSize);
                    } else if ("orderDetails".equalsIgnoreCase(action)) {
                        pageTitle = "Order Details";
                        targetJspPath = "/WEB-INF/views/staff/order/order-details.jsp";

                        long orderId = parseLongOrThrow(id, "Missing order id");
                        OrderHeader order = orderDAO.findOrderHeaderForStaff(orderId);
                        if (order == null) {
                            request.setAttribute("pageTitle", "Order Not Found");
                            request.getRequestDispatcher("/WEB-INF/views/common/404.jsp").forward(request, response);
                            return;
                        }

                        List<CartItem> items = orderDAO.loadItemsViewForOrder(orderId);
                        // Safeguard totals nếu DAO chưa set
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
                    }
                    break;
                }

                case "staff": {
                    // giữ nguyên dashboard mặc định
                    pageTitle = "Staff Dashboard";
                    break;
                }

                default: {
                    pageTitle = "Page Not Found";
                    targetJspPath = "/WEB-INF/views/common/404.jsp";
                    break;
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
        doGet(request, response);
    }

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
        } catch (Exception ignore) {
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
