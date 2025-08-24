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
import java.util.HashMap;
import java.util.Map;
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

            // Create a map to store form data
            Map<String, Object> formData = new HashMap<>();
            formData.put("code", code);
            formData.put("name", name);
            formData.put("description", description);
            formData.put("discountType", discountType);
            formData.put("discountValue", discountValueStr);
            formData.put("minimumOrderAmount", minimumOrderAmountStr);
            formData.put("maximumDiscountAmount", maximumDiscountAmountStr);
            formData.put("usageLimit", usageLimitStr);
            formData.put("expirationDate", expirationDateStr);
            formData.put("isActive", isActiveStr != null);
            formData.put("visibility", visibilityStr != null ? Boolean.parseBoolean(visibilityStr) : false);

            // Create a map to store errors
            Map<String, String> errors = new HashMap<>();

            // Debug: Log input parameters
            LOGGER.log(Level.INFO, "Parameters: code={0}, name={1}, discountType={2}, discountValue={3}, minimumOrderAmount={4}, maximumDiscountAmount={5}, usageLimit={6}, expirationDate={7}",
                    new Object[]{code, name, discountType, discountValueStr, minimumOrderAmountStr, maximumDiscountAmountStr, usageLimitStr, expirationDateStr});

            // Validate required fields
            if (code == null || code.trim().isEmpty()) {
                errors.put("code", "Voucher Code is required.");
            } else if (code.length() < 3) {
                errors.put("code", "Voucher Code must be at least 3 characters long.");
            }

            if (name == null || name.trim().isEmpty()) {
                errors.put("name", "Voucher Name is required.");
            } else if (name.length() < 3) {
                errors.put("name", "Voucher Name must be at least 3 characters long.");
            }

            if (discountType == null || discountType.trim().isEmpty()) {
                errors.put("discountType", "Discount Type is required.");
            } else if (!discountType.equals("Percentage") && !discountType.equals("Fixed Amount")) {
                errors.put("discountType", "Discount Type must be 'Percentage' or 'Fixed Amount'.");
            }

            BigDecimal discountValue = null;
            if (discountValueStr == null || discountValueStr.trim().isEmpty()) {
                errors.put("discountValue", "Discount Value is required.");
            } else {
                try {
                    discountValue = new BigDecimal(discountValueStr.trim());
                    if (discountType != null && discountType.equals("Percentage") && (discountValue.compareTo(new BigDecimal("1")) < 0 || discountValue.compareTo(new BigDecimal("90")) > 0)) {
                        errors.put("discountValue", "Percentage discount value must be between 1 and 90.");
                    } else if (discountType != null && discountType.equals("Fixed Amount") && (discountValue.compareTo(new BigDecimal("1000")) < 0 || discountValue.compareTo(new BigDecimal("10000000")) > 0)) {
                        errors.put("discountValue", "Fixed Amount discount value must be between 1000 and 10000000.");
                    }
                } catch (NumberFormatException e) {
                    LOGGER.log(Level.WARNING, "Invalid discount value format: " + discountValueStr, e);
                    errors.put("discountValue", "Invalid discount value format.");
                }
            }

            BigDecimal minimumOrderAmount = null;
            if (minimumOrderAmountStr == null || minimumOrderAmountStr.trim().isEmpty()) {
                errors.put("minimumOrderAmount", "Minimum Order Amount is required.");
            } else {
                try {
                    minimumOrderAmount = new BigDecimal(minimumOrderAmountStr.trim());
                    if (minimumOrderAmount.compareTo(BigDecimal.ZERO) < 0) {
                        errors.put("minimumOrderAmount", "Minimum Order Amount cannot be negative.");
                    }
                } catch (NumberFormatException e) {
                    LOGGER.log(Level.WARNING, "Invalid minimum order amount format: " + minimumOrderAmountStr, e);
                    errors.put("minimumOrderAmount", "Invalid minimum order amount format.");
                }
            }

            BigDecimal maximumDiscountAmount = null;
            if (maximumDiscountAmountStr == null || maximumDiscountAmountStr.trim().isEmpty()) {
                errors.put("maximumDiscountAmount", "Maximum Discount Amount is required.");
            } else {
                try {
                    maximumDiscountAmount = new BigDecimal(maximumDiscountAmountStr.trim());
                    if (maximumDiscountAmount.compareTo(BigDecimal.ZERO) < 0) {
                        errors.put("maximumDiscountAmount", "Maximum Discount Amount cannot be negative.");
                    }
                } catch (NumberFormatException e) {
                    LOGGER.log(Level.WARNING, "Invalid maximum discount amount format: " + maximumDiscountAmountStr, e);
                    errors.put("maximumDiscountAmount", "Invalid maximum discount amount format.");
                }
            }

            Integer usageLimit = null;
            if (usageLimitStr == null || usageLimitStr.trim().isEmpty()) {
                errors.put("usageLimit", "Usage Limit is required.");
            } else {
                try {
                    usageLimit = Integer.parseInt(usageLimitStr.trim());
                    if (usageLimit < 0) {
                        errors.put("usageLimit", "Usage Limit cannot be negative.");
                    }
                } catch (NumberFormatException e) {
                    LOGGER.log(Level.WARNING, "Invalid usage limit format: " + usageLimitStr, e);
                    errors.put("usageLimit", "Invalid usage limit format.");
                }
            }

            Date expirationDate = null;
            if (expirationDateStr == null || expirationDateStr.trim().isEmpty()) {
                errors.put("expirationDate", "Expiration Date is required.");
            } else {
                try {
                    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
                    dateFormat.setLenient(false);
                    java.util.Date utilDate = dateFormat.parse(expirationDateStr.trim());
                    expirationDate = new Date(utilDate.getTime());
                    if (expirationDate.before(new Date(System.currentTimeMillis()))) {
                        errors.put("expirationDate", "Expiration Date cannot be in the past.");
                    }
                } catch (ParseException e) {
                    LOGGER.log(Level.WARNING, "Invalid expiration date format: " + expirationDateStr, e);
                    errors.put("expirationDate", "Invalid expiration date format.");
                }
            }

            boolean isActive = isActiveStr != null && Boolean.parseBoolean(isActiveStr.trim());

            boolean visibility = Boolean.parseBoolean(visibilityStr != null ? visibilityStr.trim() : "false");

            // If there are errors, forward back to the form with the data
            if (!errors.isEmpty()) {
                request.setAttribute("errors", errors);
                request.setAttribute("formData", formData);
                request.setAttribute("errorMessage", "Please correct the errors below.");
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
                LOGGER.warning("Unable to add voucher with code: " + code);
                request.setAttribute("errorMessage", "Unable to add voucher. Please check system errors.");
                request.setAttribute("formData", formData);
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