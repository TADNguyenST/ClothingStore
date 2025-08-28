package controller.admin;

import dao.VoucherDAO;
import model.Voucher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.math.BigDecimal;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/editVoucher")
public class EditVoucherServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private VoucherDAO voucherDAO;
    private static final Logger LOGGER = Logger.getLogger(EditVoucherServlet.class.getName());

    @Override
    public void init() throws ServletException {
        voucherDAO = new VoucherDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        String voucherIdParam = request.getParameter("voucherId");
        if (voucherIdParam != null && !voucherIdParam.trim().isEmpty()) {
            try {
                long voucherId = Long.parseLong(voucherIdParam);
                Voucher voucher = voucherDAO.getVoucherById(voucherId);
                if (voucher != null) {
                    // Update isActive based on start_date and expiration_date
                    java.sql.Date currentDate = new java.sql.Date(System.currentTimeMillis());
                    boolean isActive = (voucher.getStartDate().before(currentDate) || voucher.getStartDate().equals(currentDate))
                            && voucher.getExpirationDate().after(currentDate);
                    if (isActive != voucher.isIsActive()) {
                        voucher.setIsActive(isActive);
                        voucherDAO.updateVoucher(voucher); // Update in database
                    }
                    request.setAttribute("voucher", voucher);
                } else {
                    request.setAttribute("errorMessage", "Voucher not found with ID: " + voucherId);
                }
            } catch (NumberFormatException e) {
                LOGGER.log(Level.WARNING, "Invalid voucher ID format: " + voucherIdParam, e);
                request.setAttribute("errorMessage", "Invalid voucher ID.");
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "Database error while retrieving voucher: " + voucherIdParam, e);
                request.setAttribute("errorMessage", "Database error while retrieving voucher: " + e.getMessage());
            }
        } else {
            try {
                java.util.List<Voucher> voucherList = voucherDAO.getAllVouchers();
                // Update isActive for each voucher in the list
                java.sql.Date currentDate = new java.sql.Date(System.currentTimeMillis());
                for (Voucher voucher : voucherList) {
                    boolean isActive = (voucher.getStartDate().before(currentDate) || voucher.getStartDate().equals(currentDate))
                            && voucher.getExpirationDate().after(currentDate);
                    if (isActive != voucher.isIsActive()) {
                        voucher.setIsActive(isActive);
                        voucherDAO.updateVoucher(voucher);
                    }
                }
                request.setAttribute("voucherList", voucherList);
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "Database error while retrieving voucher list", e);
                request.setAttribute("errorMessage", "Error retrieving voucher list: " + e.getMessage());
            }
        }
        request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-edit.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        try {
            // Extract form parameters
            String voucherIdParam = request.getParameter("voucherId");
            String code = request.getParameter("code");
            String name = request.getParameter("name");
            String description = request.getParameter("description");
            String discountType = request.getParameter("discountType");
            String discountValueStr = request.getParameter("discountValue");
            String minimumOrderAmountStr = request.getParameter("minimumOrderAmount");
            String maximumDiscountAmountStr = request.getParameter("maximumDiscountAmount");
            String usageLimitStr = request.getParameter("usageLimit");
            String expirationDateStr = request.getParameter("expirationDate");
            String startDateStr = request.getParameter("startDate");
            String isActiveStr = request.getParameter("isActive");
            String visibilityStr = request.getParameter("visibility");

            // Create a map to store form data
            Map<String, Object> formData = new HashMap<>();
            formData.put("voucherId", voucherIdParam);
            formData.put("code", code);
            formData.put("name", name);
            formData.put("description", description);
            formData.put("discountType", discountType);
            formData.put("discountValue", discountValueStr);
            formData.put("minimumOrderAmount", minimumOrderAmountStr);
            formData.put("maximumDiscountAmount", maximumDiscountAmountStr);
            formData.put("usageLimit", usageLimitStr);
            formData.put("expirationDate", expirationDateStr);
            formData.put("startDate", startDateStr);
            formData.put("isActive", isActiveStr != null ? Boolean.parseBoolean(isActiveStr) : false);
            formData.put("visibility", visibilityStr != null ? Boolean.parseBoolean(visibilityStr) : false);

            // Create a map to store errors
            Map<String, String> errors = new HashMap<>();

            // Debug: Log input parameters
            LOGGER.log(Level.INFO, "Parameters: voucherId={0}, code={1}, name={2}, discountType={3}, discountValue={4}, minimumOrderAmount={5}, maximumDiscountAmount={6}, usageLimit={7}, expirationDate={8}, startDate={9}",
                    new Object[]{voucherIdParam, code, name, discountType, discountValueStr, minimumOrderAmountStr, maximumDiscountAmountStr, usageLimitStr, expirationDateStr, startDateStr});

            // Validate voucherId
            long voucherId;
            try {
                voucherId = Long.parseLong(voucherIdParam);
            } catch (NumberFormatException e) {
                LOGGER.log(Level.WARNING, "Invalid voucher ID format: " + voucherIdParam, e);
                errors.put("voucherId", "Invalid voucher ID.");
                request.setAttribute("errors", errors);
                request.setAttribute("formData", formData);
                request.setAttribute("errorMessage", "Please correct the errors below.");
                request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-edit.jsp").forward(request, response);
                return;
            }

            // Check if voucher exists
            Voucher existingVoucher = voucherDAO.getVoucherById(voucherId);
            if (existingVoucher == null) {
                errors.put("voucherId", "Voucher not found with ID: " + voucherId);
                request.setAttribute("errors", errors);
                request.setAttribute("formData", formData);
                request.setAttribute("errorMessage", "Please correct the errors below.");
                request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-edit.jsp").forward(request, response);
                return;
            }

            // Prevent voucher code modification
            if (code != null && !code.trim().isEmpty() && !code.trim().equals(existingVoucher.getCode())) {
                errors.put("code", "The voucher code cannot be changed.");
                request.setAttribute("errors", errors);
                request.setAttribute("formData", formData);
                request.setAttribute("errorMessage", "Please correct the errors below.");
                request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-edit.jsp").forward(request, response);
                return;
            }

            // Validate required fields
            if (name == null || name.trim().isEmpty()) {
                errors.put("name", "Voucher Name is required.");
            } else if (name.length() < 3) {
                errors.put("name", "Voucher Name must be at least 3 characters long.");
            }

            if (discountType == null || discountType.trim().isEmpty()) {
                errors.put("discountType", "Discount Type is required.");
            } else if (!discountType.equals("Percentage") && !discountType.equals("Fixed Amount")) {
                errors.put("discountType", "Discount Type must be Percentage or Fixed Amount.");
            }

            BigDecimal discountValue = existingVoucher.getDiscountValue();
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

            BigDecimal minimumOrderAmount = existingVoucher.getMinimumOrderAmount();
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

            BigDecimal maximumDiscountAmount = existingVoucher.getMaximumDiscountAmount();
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

            Integer usageLimit = existingVoucher.getUsageLimit();
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

            java.sql.Date sqlExpirationDate = existingVoucher.getExpirationDate();
            if (expirationDateStr == null || expirationDateStr.trim().isEmpty()) {
                errors.put("expirationDate", "Expiration Date is required.");
            } else {
                try {
                    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
                    dateFormat.setLenient(false);
                    Date utilDate = dateFormat.parse(expirationDateStr.trim());
                    sqlExpirationDate = new java.sql.Date(utilDate.getTime());
                    if (sqlExpirationDate.before(new java.sql.Date(System.currentTimeMillis()))) {
                        errors.put("expirationDate", "Expiration Date cannot be in the past.");
                    }
                } catch (ParseException e) {
                    LOGGER.log(Level.WARNING, "Invalid expiration date format: " + expirationDateStr, e);
                    errors.put("expirationDate", "Invalid expiration date format.");
                }
            }

            java.sql.Date sqlStartDate = existingVoucher.getStartDate();
            if (startDateStr == null || startDateStr.trim().isEmpty()) {
                errors.put("startDate", "Start Date is required.");
            } else {
                try {
                    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
                    dateFormat.setLenient(false);
                    Date utilDate = dateFormat.parse(startDateStr.trim());
                    sqlStartDate = new java.sql.Date(utilDate.getTime());
                    if (sqlStartDate.before(existingVoucher.getCreatedAt()) || sqlStartDate.equals(existingVoucher.getCreatedAt())) {
                        errors.put("startDate", "Start Date must be after the creation date.");
                    }
                    if (sqlExpirationDate != null && sqlStartDate.after(sqlExpirationDate)) {
                        errors.put("startDate", "Start Date cannot be after the expiration date.");
                    }
                } catch (ParseException e) {
                    LOGGER.log(Level.WARNING, "Invalid start date format: " + startDateStr, e);
                    errors.put("startDate", "Invalid start date format.");
                }
            }

            boolean isActive = existingVoucher.isIsActive();
            if (isActiveStr == null || isActiveStr.trim().isEmpty()) {
                errors.put("isActive", "Status is required.");
            } else {
                try {
                    isActive = Boolean.parseBoolean(isActiveStr.trim());
                } catch (Exception e) {
                    LOGGER.log(Level.WARNING, "Invalid status value: " + isActiveStr, e);
                    errors.put("isActive", "Invalid status value.");
                }
            }

            boolean visibility = existingVoucher.isVisibility();
            if (visibilityStr == null || visibilityStr.trim().isEmpty()) {
                errors.put("visibility", "Visibility is required.");
            } else {
                try {
                    visibility = Boolean.parseBoolean(visibilityStr.trim());
                } catch (Exception e) {
                    LOGGER.log(Level.WARNING, "Invalid visibility value: " + visibilityStr, e);
                    errors.put("visibility", "Invalid visibility value.");
                }
            }

            // If there are errors, forward back to the form with the data
            if (!errors.isEmpty()) {
                request.setAttribute("errors", errors);
                request.setAttribute("formData", formData);
                request.setAttribute("errorMessage", "Please correct the errors below.");
                request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-edit.jsp").forward(request, response);
                return;
            }

            // Create updated voucher object
            Voucher voucher = new Voucher(
                voucherId,
                existingVoucher.getCode(),
                name.trim(),
                description != null ? description.trim() : existingVoucher.getDescription(),
                discountType,
                discountValue,
                minimumOrderAmount,
                maximumDiscountAmount,
                usageLimit,
                existingVoucher.getUsedCount(),
                sqlExpirationDate,
                isActive,
                visibility,
                existingVoucher.getCreatedAt(),
                sqlStartDate
            );

            // Update voucher in database
            boolean updated = voucherDAO.updateVoucher(voucher);
            if (updated) {
                response.sendRedirect(request.getContextPath() + "/vouchers?successMessage=" +
                        java.net.URLEncoder.encode("Voucher updated successfully!", "UTF-8"));
            } else {
                LOGGER.warning("Update failed for voucher ID: " + voucherId);
                request.setAttribute("errorMessage", "Unable to update voucher. Please check system errors.");
                request.setAttribute("formData", formData);
                request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-edit.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error while updating voucher", e);
            request.setAttribute("errorMessage", "Database error: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-edit.jsp").forward(request, response);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Unexpected error while updating voucher: " + e.getMessage(), e);
            request.setAttribute("errorMessage", "Unexpected error: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-edit.jsp").forward(request, response);
        }
    }

    @Override
    public void destroy() {
        if (voucherDAO != null) {
            voucherDAO.closeConnection();
        }
    }
}