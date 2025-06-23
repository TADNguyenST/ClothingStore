package controller.admin;

import dao.VoucherDAO;
import model.Voucher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.sql.Date;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/addVoucher")
public class AddVoucherServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(AddVoucherServlet.class.getName());
    private VoucherDAO voucherDAO;

    @Override
    public void init() throws ServletException {
        voucherDAO = new VoucherDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("WEB-INF/views/admin/voucher/voucher-add.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Extract form parameters
            String code = request.getParameter("code");
            String name = request.getParameter("name");
            String description = request.getParameter("description");
            String discountType = request.getParameter("discountType");
            String discountValueStr = request.getParameter("discountValue");
            String minimumOrderAmountStr = request.getParameter("minimumOrderAmount");
            String maximumDiscountAmountStr = request.getParameter("maximumDiscountAmount");
            String usageLimitStr = request.getParameter("usageLimit");
            String expirationDateStr = request.getParameter("expirationDate");
            boolean isActive = request.getParameter("isActive") != null;

            // Validate required fields
            if (code == null || code.trim().isEmpty() || name == null || name.trim().isEmpty() ||
                discountType == null || discountType.trim().isEmpty() || discountValueStr == null || discountValueStr.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/addVoucher?errorMessage=" + 
                    java.net.URLEncoder.encode("Missing required fields.", "UTF-8"));
                return;
            }

            // Parse numeric and date fields
            BigDecimal discountValue = new BigDecimal(discountValueStr);
            BigDecimal minimumOrderAmount = minimumOrderAmountStr != null && !minimumOrderAmountStr.trim().isEmpty() ?
                new BigDecimal(minimumOrderAmountStr) : null;
            BigDecimal maximumDiscountAmount = maximumDiscountAmountStr != null && !maximumDiscountAmountStr.trim().isEmpty() ?
                new BigDecimal(maximumDiscountAmountStr) : null;
            Integer usageLimit = usageLimitStr != null && !usageLimitStr.trim().isEmpty() ?
                Integer.parseInt(usageLimitStr) : null;
            Date expirationDate = expirationDateStr != null && !expirationDateStr.trim().isEmpty() ?
                Date.valueOf(expirationDateStr) : null;

            // Create Voucher object
            Voucher voucher = new Voucher(0, code, name, description, discountType, discountValue,
                minimumOrderAmount, maximumDiscountAmount, usageLimit, 0, expirationDate, isActive, new Date(System.currentTimeMillis()));

            // Save to database
            boolean saved = voucherDAO.addVoucher(voucher);
            if (saved) {
                response.sendRedirect(request.getContextPath() + "/vouchers?successMessage=" + 
                    java.net.URLEncoder.encode("Voucher added successfully!", "UTF-8"));
            } else {
                response.sendRedirect(request.getContextPath() + "/addVoucher?errorMessage=" + 
                    java.net.URLEncoder.encode("Failed to add voucher.", "UTF-8"));
            }
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Invalid number format: {0}", e.getMessage());
            response.sendRedirect(request.getContextPath() + "/addVoucher?errorMessage=" + 
                java.net.URLEncoder.encode("Invalid number format in form fields.", "UTF-8"));
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error adding voucher: {0}", e.getMessage());
            response.sendRedirect(request.getContextPath() + "/addVoucher?errorMessage=" + 
                java.net.URLEncoder.encode("Database error occurred while adding voucher.", "UTF-8"));
        }
    }

    @Override
    public void destroy() {
        if (voucherDAO != null) {
            voucherDAO.closeConnection();
        }
    }
}