
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
import java.util.List;
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
                List<Voucher> voucherList = voucherDAO.getAllVouchers();
                request.setAttribute("voucherList", voucherList);
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "Database error while retrieving voucher list", e);
                request.setAttribute("errorMessage", "Error while retrieving voucher list: " + e.getMessage());
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
            // Debug: Log input parameters
            String voucherIdParam = request.getParameter("voucherId");
            String code = request.getParameter("code");
            String name = request.getParameter("name");
            String discountType = request.getParameter("discountType");
            String discountValueStr = request.getParameter("discountValue");
            LOGGER.log(Level.INFO, "Parameters: voucherId={0}, code={1}, name={2}, discountType={3}, discountValue={4}", 
                       new Object[]{voucherIdParam, code, name, discountType, discountValueStr});

            // Validate voucherId
            long voucherId;
            try {
                voucherId = Long.parseLong(voucherIdParam);
            } catch (NumberFormatException e) {
                LOGGER.log(Level.WARNING, "Invalid voucher ID format: " + voucherIdParam, e);
                request.setAttribute("errorMessage", "Invalid voucher ID.");
                request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-edit.jsp").forward(request, response);
                return;
            }

            // Check if voucher exists
            Voucher existingVoucher = voucherDAO.getVoucherById(voucherId);
            if (existingVoucher == null) {
                request.setAttribute("errorMessage", "Voucher not found with ID: " + voucherId);
                request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-edit.jsp").forward(request, response);
                return;
            }

            // Prevent voucher code modification
            if (code != null && !code.trim().isEmpty() && !code.trim().equals(existingVoucher.getCode())) {
                request.setAttribute("errorMessage", "Cannot change the voucher code.");
                request.setAttribute("voucher", existingVoucher);
                request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-edit.jsp").forward(request, response);
                return;
            }

            // Get and validate parameters
            String description = request.getParameter("description");
            String minimumOrderAmountStr = request.getParameter("minimumOrderAmount");
            String maximumDiscountAmountStr = request.getParameter("maximumDiscountAmount");
            String usageLimitStr = request.getParameter("usageLimit");
            String expirationDateStr = request.getParameter("expirationDate");
            String isActiveStr = request.getParameter("isActive");
            String visibilityStr = request.getParameter("visibility");

            // Validate discountValue
            BigDecimal discountValue = existingVoucher.getDiscountValue();
            if (discountValueStr != null && !discountValueStr.trim().isEmpty()) {
                try {
                    discountValue = new BigDecimal(discountValueStr.trim());
                    if (discountType == null || discountType.trim().isEmpty()) {
                        request.setAttribute("errorMessage", "Discount type is required.");
                        request.setAttribute("voucher", existingVoucher);
                        request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-edit.jsp").forward(request, response);
                        return;
                    }
                    if (discountType.equals("Percentage") && (discountValue.compareTo(new BigDecimal("1")) < 0 || discountValue.compareTo(new BigDecimal("90")) > 0)) {
                        request.setAttribute("errorMessage", "Percentage discount value must be between 1 and 90.");
                        request.setAttribute("voucher", existingVoucher);
                        request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-edit.jsp").forward(request, response);
                        return;
                    } else if (discountType.equals("Fixed Amount") && (discountValue.compareTo(new BigDecimal("1000")) < 0 || discountValue.compareTo(new BigDecimal("10000000")) > 0)) {
                        request.setAttribute("errorMessage", "Fixed discount value must be between 1000 and 10000000.");
                        request.setAttribute("voucher", existingVoucher);
                        request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-edit.jsp").forward(request, response);
                        return;
                    }
                } catch (NumberFormatException e) {
                    LOGGER.log(Level.WARNING, "Invalid discount value: " + discountValueStr, e);
                    request.setAttribute("errorMessage", "Invalid discount value.");
                    request.setAttribute("voucher", existingVoucher);
                    request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-edit.jsp").forward(request, response);
                    return;
                }
            } else {
                request.setAttribute("errorMessage", "Discount value is required.");
                request.setAttribute("voucher", existingVoucher);
                request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-edit.jsp").forward(request, response);
                return;
            }

            // Validate minimumOrderAmount
            BigDecimal minimumOrderAmount = existingVoucher.getMinimumOrderAmount();
            if (minimumOrderAmountStr != null && !minimumOrderAmountStr.trim().isEmpty()) {
                try {
                    minimumOrderAmount = new BigDecimal(minimumOrderAmountStr.trim());
                    if (minimumOrderAmount.compareTo(BigDecimal.ZERO) < 0) {
                        request.setAttribute("errorMessage", "Minimum order amount cannot be negative.");
                        request.setAttribute("voucher", existingVoucher);
                        request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-edit.jsp").forward(request, response);
                        return;
                    }
                } catch (NumberFormatException e) {
                    LOGGER.log(Level.WARNING, "Invalid minimum order amount: " + minimumOrderAmountStr, e);
                    request.setAttribute("errorMessage", "Invalid minimum order amount.");
                    request.setAttribute("voucher", existingVoucher);
                    request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-edit.jsp").forward(request, response);
                    return;
                }
            }

            // Validate maximumDiscountAmount
            BigDecimal maximumDiscountAmount = existingVoucher.getMaximumDiscountAmount();
            if (maximumDiscountAmountStr != null && !maximumDiscountAmountStr.trim().isEmpty()) {
                try {
                    maximumDiscountAmount = new BigDecimal(maximumDiscountAmountStr.trim());
                    if (maximumDiscountAmount.compareTo(BigDecimal.ZERO) < 0) {
                        request.setAttribute("errorMessage", "Maximum discount amount cannot be negative.");
                        request.setAttribute("voucher", existingVoucher);
                        request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-edit.jsp").forward(request, response);
                        return;
                    }
                } catch (NumberFormatException e) {
                    LOGGER.log(Level.WARNING, "Invalid maximum discount amount: " + maximumDiscountAmountStr, e);
                    request.setAttribute("errorMessage", "Invalid maximum discount amount.");
                    request.setAttribute("voucher", existingVoucher);
                    request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-edit.jsp").forward(request, response);
                    return;
                }
            }

            // Validate usageLimit
            Integer usageLimit = existingVoucher.getUsageLimit();
            if (usageLimitStr != null && !usageLimitStr.trim().isEmpty()) {
                try {
                    usageLimit = Integer.parseInt(usageLimitStr.trim());
                    if (usageLimit < 0) {
                        request.setAttribute("errorMessage", "Usage limit cannot be negative.");
                        request.setAttribute("voucher", existingVoucher);
                        request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-edit.jsp").forward(request, response);
                        return;
                    }
                } catch (NumberFormatException e) {
                    LOGGER.log(Level.WARNING, "Invalid usage limit: " + usageLimitStr, e);
                    request.setAttribute("errorMessage", "Invalid usage limit.");
                    request.setAttribute("voucher", existingVoucher);
                    request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-edit.jsp").forward(request, response);
                    return;
                }
            }

            // Validate expirationDate
            java.sql.Date sqlExpirationDate = existingVoucher.getExpirationDate();
            if (expirationDateStr != null && !expirationDateStr.trim().isEmpty()) {
                try {
                    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
                    dateFormat.setLenient(false);
                    Date utilDate = dateFormat.parse(expirationDateStr.trim());
                    sqlExpirationDate = new java.sql.Date(utilDate.getTime());
                    if (sqlExpirationDate.before(new java.sql.Date(System.currentTimeMillis()))) {
                        request.setAttribute("errorMessage", "Expiration date cannot be in the past.");
                        request.setAttribute("voucher", existingVoucher);
                        request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-edit.jsp").forward(request, response);
                        return;
                    }
                } catch (ParseException e) {
                    LOGGER.log(Level.WARNING, "Invalid expiration date format: " + expirationDateStr, e);
                    request.setAttribute("errorMessage", "Invalid expiration date format.");
                    request.setAttribute("voucher", existingVoucher);
                    request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-edit.jsp").forward(request, response);
                    return;
                }
            }

            // Validate isActive
            boolean isActive = existingVoucher.isIsActive();
            if (isActiveStr != null && !isActiveStr.trim().isEmpty()) {
                try {
                    isActive = Boolean.parseBoolean(isActiveStr.trim());
                } catch (Exception e) {
                    LOGGER.log(Level.WARNING, "Invalid status value: " + isActiveStr, e);
                    request.setAttribute("errorMessage", "Invalid status.");
                    request.setAttribute("voucher", existingVoucher);
                    request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-edit.jsp").forward(request, response);
                    return;
                }
            }

            // Validate visibility
            boolean visibility = existingVoucher.isVisibility();
            if (visibilityStr != null && !visibilityStr.trim().isEmpty()) {
                try {
                    visibility = Boolean.parseBoolean(visibilityStr.trim());
                } catch (Exception e) {
                    LOGGER.log(Level.WARNING, "Invalid visibility value: " + visibilityStr, e);
                    request.setAttribute("errorMessage", "Invalid visibility.");
                    request.setAttribute("voucher", existingVoucher);
                    request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-edit.jsp").forward(request, response);
                    return;
                }
            }

            // Validate name
            String finalName = (name != null && !name.trim().isEmpty()) ? name.trim() : existingVoucher.getName();
            if (finalName.isEmpty()) {
                request.setAttribute("errorMessage", "Voucher name is required.");
                request.setAttribute("voucher", existingVoucher);
                request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-edit.jsp").forward(request, response);
                return;
            }

            // Validate discountType
            String finalDiscountType = (discountType != null && !discountType.trim().isEmpty()) ? discountType.trim() : existingVoucher.getDiscountType();
            if (finalDiscountType.isEmpty()) {
                request.setAttribute("errorMessage", "Discount type is required.");
                request.setAttribute("voucher", existingVoucher);
                request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-edit.jsp").forward(request, response);
                return;
            }

            // Create updated voucher object
            Voucher voucher = new Voucher(
                voucherId,
                existingVoucher.getCode(),
                finalName,
                description != null ? description.trim() : existingVoucher.getDescription(),
                finalDiscountType,
                discountValue,
                minimumOrderAmount,
                maximumDiscountAmount,
                usageLimit,
                existingVoucher.getUsedCount(),
                sqlExpirationDate,
                isActive,
                visibility,
                existingVoucher.getCreatedAt()
            );

            // Update voucher in database
            boolean updated = voucherDAO.updateVoucher(voucher);
            if (updated) {
                response.sendRedirect(request.getContextPath() + "/vouchers?successMessage=Voucher+updated+successfully");
            } else {
                LOGGER.warning("Update failed for voucher ID: " + voucherId);
                request.setAttribute("errorMessage", "Unable to update voucher. Please check system errors.");
                request.setAttribute("voucher", voucher);
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
