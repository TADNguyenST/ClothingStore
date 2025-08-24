package controller.admin;

import dao.VoucherDAO;
import model.Voucher;
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

@WebServlet("/VoucherPublic")
public class VoucherPublicServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(VoucherPublicServlet.class.getName());
    private VoucherDAO voucherDAO;

    @Override
    public void init() throws ServletException {
        voucherDAO = new VoucherDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Get search parameters
            String code = request.getParameter("code");
            String name = request.getParameter("name");
            List<Voucher> voucherList;
            // Log parameters for debugging
            LOGGER.log(Level.INFO, "Received search parameters - code: {0}, name: {1}",
                       new Object[]{code, name});
            // Apply filter for public vouchers (visibility = 1)
            if ((code != null && !code.trim().isEmpty()) || (name != null && !name.trim().isEmpty())) {
                voucherList = voucherDAO.getVouchersByFilter(code, name, null, false);
            } else {
                voucherList = voucherDAO.getPublicVouchers();
            }
            // Log the size of the result list
            LOGGER.log(Level.INFO, "Retrieved {0} public vouchers", voucherList.size());
            request.setAttribute("voucherList", voucherList);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error retrieving public voucher list: {0}", e.getMessage());
            request.setAttribute("errorMessage", "Error retrieving public voucher data: " + e.getMessage());
        }
        // Forward to JSP
        request.getRequestDispatcher("/WEB-INF/views/customer/voucher/public-voucher-list.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        Long userId = (session != null && session.getAttribute("userId") != null)
                ? (Long) session.getAttribute("userId") : null;
        // Check if user is logged in
        if (userId == null) {
            LOGGER.log(Level.INFO, "Unauthorized save attempt to VoucherPublicServlet");
            request.setAttribute("errorMessage", "Please log in to save the voucher!");
            response.sendRedirect(request.getContextPath() + "/Login");
            return;
        }
        try {
            String voucherIdStr = request.getParameter("voucherId");
            if (voucherIdStr == null) {
                request.setAttribute("errorMessage", "Please select a valid voucher!");
            } else {
                long voucherId = Long.parseLong(voucherIdStr);
              
                // Check if voucher is already saved by the customer
                if (voucherDAO.isVoucherSavedByCustomer(voucherId, userId)) {
                    request.setAttribute("errorMessage", "You have already saved this voucher!");
                } else {
                    boolean saved = voucherDAO.saveVoucherForCustomer(voucherId, userId);
                    if (saved) {
                        request.setAttribute("successMessage", "Voucher saved successfully!");
                    } else {
                        request.setAttribute("errorMessage", "Error saving voucher!");
                    }
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error saving voucher: {0}", e.getMessage());
            request.setAttribute("errorMessage", "Error saving voucher: " + e.getMessage());
        } catch (NumberFormatException e) {
            LOGGER.log(Level.SEVERE, "Invalid voucher ID format: {0}", e.getMessage());
            request.setAttribute("errorMessage", "Invalid voucher ID!");
        }
      
        // Refresh the voucher list after saving
        doGet(request, response);
    }

    @Override
    public void destroy() {
        if (voucherDAO != null) {
            voucherDAO.closeConnection();
        }
    }
}