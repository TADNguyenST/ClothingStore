package controller.admin;

import dao.VoucherDAO;
import model.Voucher;
import model.Users;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/vouchers")
public class VoucherServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(VoucherServlet.class.getName());
    private VoucherDAO voucherDAO;

    @Override
    public void init() throws ServletException {
        voucherDAO = new VoucherDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Check for valid admin session
        HttpSession session = request.getSession(false); // Get session without creating a new one
        Users admin = (session != null) ? (Users) session.getAttribute("admin") : null;

        if (admin == null || !"Admin".equalsIgnoreCase(admin.getRole())) {
            // If no valid admin session, redirect to login page
            request.setAttribute("error", "Please log in as an Admin to access this page.");
            request.getRequestDispatcher("/WEB-INF/views/admin/admin-login.jsp").forward(request, response);
            return;
        }

        try {
            // Get search parameters
            String code = request.getParameter("code");
            String name = request.getParameter("name");
            List<Voucher> voucherList;

            // Log parameters for debugging
            LOGGER.log(Level.INFO, "Received search parameters - code: {0}, name: {1}",
                    new Object[]{code, name});

            // Apply filter if code or name is provided
            if ((code != null && !code.trim().isEmpty()) || (name != null && !name.trim().isEmpty())) {
                voucherList = voucherDAO.getVouchersByFilter(code, name, null, false);
            } else {
                voucherList = voucherDAO.getAllVouchers();
            }

            // Update isActive for each voucher based on startDate and expirationDate
            java.sql.Date currentDate = new java.sql.Date(System.currentTimeMillis());
            for (Voucher voucher : voucherList) {
                boolean isActive = (voucher.getStartDate() != null && 
                        (voucher.getStartDate().before(currentDate) || voucher.getStartDate().equals(currentDate)) &&
                        voucher.getExpirationDate() != null && 
                        voucher.getExpirationDate().after(currentDate));
                if (isActive != voucher.isIsActive()) {
                    voucher.setIsActive(isActive);
                    voucherDAO.updateVoucher(voucher); // Update in database
                    LOGGER.log(Level.INFO, "Updated isActive to {0} for voucher ID: {1}", 
                            new Object[]{isActive, voucher.getVoucherId()});
                }
            }

            // Log the size of the result list
            LOGGER.log(Level.INFO, "Retrieved {0} vouchers", voucherList.size());
            request.setAttribute("voucherList", voucherList);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error retrieving voucher list: {0}", e.getMessage());
            request.setAttribute("errorMessage", "Lỗi khi lấy dữ liệu voucher: " + e.getMessage());
        }

        // Forward to JSP
        request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-list.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Check for valid admin session for POST requests as well
        HttpSession session = request.getSession(false);
        Users admin = (session != null) ? (Users) session.getAttribute("admin") : null;

        if (admin == null || !"Admin".equalsIgnoreCase(admin.getRole())) {
            request.setAttribute("error", "Please log in as an Admin to access this page.");
            request.getRequestDispatcher("/WEB-INF/views/admin/admin-login.jsp").forward(request, response);
            return;
        }

        // Add POST handling logic here if needed (e.g., creating/updating vouchers)
        doGet(request, response); // Fallback to doGet for now if no specific POST logic
    }

    @Override
    public void destroy() {
        if (voucherDAO != null) {
            voucherDAO.closeConnection();
        }
    }
}