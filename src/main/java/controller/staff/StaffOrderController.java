package controller.staff;

import dao.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.Users;

import java.io.IOException;

@WebServlet(name = "StaffOrderController", urlPatterns = {"/StaffOrder", "/AdminOrder"})
public class StaffOrderController extends HttpServlet {

    private OrderDAO orderDAO;

    @Override
    public void init() {
        orderDAO = new OrderDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        String servletPath = req.getServletPath();
        String cpath = req.getContextPath();

        Users staff = (session != null) ? (Users) session.getAttribute("staff") : null;
        Users admin = (session != null) ? (Users) session.getAttribute("admin") : null;

        boolean isStaff = staff != null
                && "Staff".equalsIgnoreCase(staff.getRole())
                && "Active".equalsIgnoreCase(staff.getStatus());
        boolean isAdmin = admin != null
                && "Admin".equalsIgnoreCase(admin.getRole())
                && "Active".equalsIgnoreCase(admin.getStatus());

        if ("/StaffOrder".equalsIgnoreCase(servletPath)) {
            if (!isStaff) { // admin KHÔNG được “vào nhờ” URL Staff
                resp.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            resp.sendRedirect(cpath + "/Staffdashboard?action=orderList&module=order");
            return;
        }

        if ("/AdminOrder".equalsIgnoreCase(servletPath)) {
            if (!isAdmin) {
                resp.sendRedirect(cpath + "/AdminLogin");
                return;
            }
            resp.sendRedirect(cpath + "/Admindashboard?action=orderList&module=order");
            return;
        }

        resp.sendError(HttpServletResponse.SC_NOT_FOUND);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        String servletPath = req.getServletPath();
        String cpath = req.getContextPath();

        Users staff = (session != null) ? (Users) session.getAttribute("staff") : null;
        Users admin = (session != null) ? (Users) session.getAttribute("admin") : null;

        boolean isStaff = staff != null
                && "Staff".equalsIgnoreCase(staff.getRole())
                && "Active".equalsIgnoreCase(staff.getStatus());
        boolean isAdmin = admin != null
                && "Admin".equalsIgnoreCase(admin.getRole())
                && "Active".equalsIgnoreCase(admin.getStatus());

        // Bảo vệ theo URL (admin KHÔNG dùng Staff URL)
        if ("/StaffOrder".equalsIgnoreCase(servletPath)) {
            if (!isStaff) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
        } else if ("/AdminOrder".equalsIgnoreCase(servletPath)) {
            if (!isAdmin) {
                resp.sendRedirect(cpath + "/AdminLogin");
                return;
            }
        } else {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String action = req.getParameter("action");
        String idStr = req.getParameter("orderId");
        long orderId;
        try {
            orderId = Long.parseLong(idStr);
        } catch (Exception e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing or invalid orderId");
            return;
        }

        // Chọn dashboard ĐÚNG theo route
        String dashBase = "/Staffdashboard";
        if ("/AdminOrder".equalsIgnoreCase(servletPath)) {
            dashBase = "/Admindashboard";
        }

        try {
            if ("updateStatus".equalsIgnoreCase(action)) {
                String newStatus = req.getParameter("status");
                if (newStatus == null || newStatus.trim().isEmpty()) {
                    resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing status");
                    return;
                }
                orderDAO.updateStatusByStaff(orderId, newStatus.trim().toUpperCase());

            } else if ("markRefunded".equalsIgnoreCase(action)) {
                orderDAO.markRefundedByStaff(orderId, "Refund completed by backoffice user");

            } else {
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unknown action");
                return;
            }

            resp.sendRedirect(cpath + dashBase
                    + "?action=orderDetails&module=order&id=" + orderId + "&updated=1");

        } catch (Exception ex) {
            resp.sendRedirect(cpath + dashBase
                    + "?action=orderDetails&module=order&id=" + orderId + "&error=1");
        }
    }
}
