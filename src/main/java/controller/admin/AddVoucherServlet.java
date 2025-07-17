
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
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/addVoucher")
public class AddVoucherServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private VoucherDAO voucherDAO;
    private static final Logger LOGGER = Logger.getLogger(AddVoucherServlet.class.getName());

    @Override
    public void init() throws ServletException {
        voucherDAO = new VoucherDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-add.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

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
            String isActiveStr = request.getParameter("isActive");
            String visibilityStr = request.getParameter("visibility");

            // Debug: Log input parameters
            LOGGER.log(Level.INFO, "Parameters: code={0}, name={1}, discountType={2}, discountValue={3}, expirationDate={4}",
                    new Object[]{code, name, discountType, discountValueStr, expirationDateStr});

            // Validate required fields
            if (code == null || code.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Voucher Code is required.");
                request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-add.jsp").forward(request, response);
                return;
            }
            if (name == null || name.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Name is required.");
                request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-add.jsp").forward(request, response);
                return;
            }
            if (discountType == null || discountType.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Discount Type is required.");
                request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-add.jsp").forward(request, response);
                return;
            }
            if (discountValueStr == null || discountValueStr.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Discount Value is required.");
                request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-add.jsp").forward(request, response);
                return;
            }
            if (expirationDateStr == null || expirationDateStr.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Expiration Date is required.");
                request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-add.jsp").forward(request, response);
                return;
            }

            // Validate discountType
            if (!discountType.equals("Percentage") && !discountType.equals("Fixed Amount")) {
                request.setAttribute("errorMessage", "Discount Type must be 'Percentage' or 'Fixed Amount'.");
                request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-add.jsp").forward(request, response);
                return;
            }

            // Parse and validate discountValue
            BigDecimal discountValue;
            try {
                discountValue = new BigDecimal(discountValueStr.trim());
                if (discountType.equals("Percentage") && (discountValue.compareTo(new BigDecimal("1")) < 0 || discountValue.compareTo(new BigDecimal("90")) > 0)) {
                    request.setAttribute("errorMessage", "Percentage discount value must be between 1 and 90.");
                    request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-add.jsp").forward(request, response);
                    return;
                } else if (discountType.equals("Fixed Amount") && (discountValue.compareTo(new BigDecimal("1000")) < 0 || discountValue.compareTo(new BigDecimal("10000000")) > 0)) {
                    request.setAttribute("errorMessage", "Fixed Amount discount value must be between 1000 and 10000000.");
                    request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-add.jsp").forward(request, response);
                    return;
                }
            } catch (NumberFormatException e) {
                LOGGER.log(Level.WARNING, "Invalid discount value format: " + discountValueStr, e);
                request.setAttribute("errorMessage", "Invalid discount value format.");
                request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-add.jsp").forward(request, response);
                return;
            }

            // Parse and validate minimumOrderAmount
            BigDecimal minimumOrderAmount = null;
            if (minimumOrderAmountStr != null && !minimumOrderAmountStr.trim().isEmpty()) {
                try {
                    minimumOrderAmount = new BigDecimal(minimumOrderAmountStr.trim());
                    if (minimumOrderAmount.compareTo(BigDecimal.ZERO) < 0) {
                        request.setAttribute("errorMessage", "Minimum Order Amount cannot be negative.");
                        request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-add.jsp").forward(request, response);
                        return;
                    }
                } catch (NumberFormatException e) {
                    LOGGER.log(Level.WARNING, "Invalid minimum order amount format: " + minimumOrderAmountStr, e);
                    request.setAttribute("errorMessage", "Invalid minimum order amount format.");
                    request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-add.jsp").forward(request, response);
                    return;
                }
            }

            // Parse and validate maximumDiscountAmount
            BigDecimal maximumDiscountAmount = null;
            if (maximumDiscountAmountStr != null && !maximumDiscountAmountStr.trim().isEmpty()) {
                try {
                    maximumDiscountAmount = new BigDecimal(maximumDiscountAmountStr.trim());
                    if (maximumDiscountAmount.compareTo(BigDecimal.ZERO) < 0) {
                        request.setAttribute("errorMessage", "Maximum Discount Amount cannot be negative.");
                        request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-add.jsp").forward(request, response);
                        return;
                    }
                } catch (NumberFormatException e) {
                    LOGGER.log(Level.WARNING, "Invalid maximum discount amount format: " + maximumDiscountAmountStr, e);
                    request.setAttribute("errorMessage", "Invalid maximum discount amount format.");
                    request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-add.jsp").forward(request, response);
                    return;
                }
            }

            // Parse and validate usageLimit
            Integer usageLimit = null;
            if (usageLimitStr != null && !usageLimitStr.trim().isEmpty()) {
                try {
                    usageLimit = Integer.parseInt(usageLimitStr.trim());
                    if (usageLimit < 0) {
                        request.setAttribute("errorMessage", "Usage Limit cannot be negative.");
                        request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-add.jsp").forward(request, response);
                        return;
                    }
                } catch (NumberFormatException e) {
                    LOGGER.log(Level.WARNING, "Invalid usage limit format: " + usageLimitStr, e);
                    request.setAttribute("errorMessage", "Invalid usage limit format.");
                    request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-add.jsp").forward(request, response);
                    return;
                }
            }

            // Parse and validate expirationDate
            Date expirationDate;
            try {
                SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
                dateFormat.setLenient(false);
                java.util.Date utilDate = dateFormat.parse(expirationDateStr.trim());
                expirationDate = new Date(utilDate.getTime());
                if (expirationDate.before(new Date(System.currentTimeMillis()))) {
                    request.setAttribute("errorMessage", "Expiration Date cannot be in the past.");
                    request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-add.jsp").forward(request, response);
                    return;
                }
            } catch (ParseException e) {
                LOGGER.log(Level.WARNING, "Invalid expiration date format: " + expirationDateStr, e);
                request.setAttribute("errorMessage", "Invalid expiration date format.");
                request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-add.jsp").forward(request, response);
                return;
            }

            // Parse isActive
            boolean isActive = isActiveStr != null && Boolean.parseBoolean(isActiveStr.trim());

            // Parse visibility
            boolean visibility;
            if (visibilityStr == null || visibilityStr.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Visibility is required.");
                request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-add.jsp").forward(request, response);
                return;
            }
            try {
                visibility = Boolean.parseBoolean(visibilityStr.trim());
            } catch (Exception e) {
                LOGGER.log(Level.WARNING, "Invalid visibility format: " + visibilityStr, e);
                request.setAttribute("errorMessage", "Invalid visibility format.");
                request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-add.jsp").forward(request, response);
                return;
            }

            // Create Voucher object
            Voucher voucher = new Voucher(
                    0, // voucherId will be auto-generated
                    code.trim(),
                    name.trim(),
                    description != null ? description.trim() : null,
                    discountType,
                    discountValue,
                    minimumOrderAmount,
                    maximumDiscountAmount,
                    usageLimit,
                    0, // usedCount starts at 0
                    expirationDate,
                    isActive,
                    visibility,
                    new Date(System.currentTimeMillis())
            );

            // Save to database
            boolean saved = voucherDAO.addVoucher(voucher);
            if (saved) {
                response.sendRedirect(request.getContextPath() + "/vouchers?successMessage=" +
                        java.net.URLEncoder.encode("Voucher added successfully!", "UTF-8"));
            } else {
                LOGGER.warning("Failed to add voucher with code: " + code);
                request.setAttribute("errorMessage", "Failed to add voucher. Please check system errors.");
                request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-add.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error while adding voucher: " + e.getMessage(), e);
            request.setAttribute("errorMessage", "Database error: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-add.jsp").forward(request, response);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Unexpected error while adding voucher: " + e.getMessage(), e);
            request.setAttribute("errorMessage", "Unexpected error: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-add.jsp").forward(request, response);
        }
    }

    @Override
    public void destroy() {
        if (voucherDAO != null) {
            voucherDAO.closeConnection();
        }
    }
}
