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
                    request.setAttribute("errorMessage", "Voucher with ID " + voucherId + " not found.");
                }
            } catch (NumberFormatException e) {
                LOGGER.log(Level.WARNING, "Invalid voucher ID format: " + voucherIdParam, e);
                request.setAttribute("errorMessage", "Invalid voucher ID.");
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "Database error while fetching voucher: " + voucherIdParam, e);
                request.setAttribute("errorMessage", "Database error when fetching voucher: " + e.getMessage());
            }
        } else {
            try {
                List<Voucher> voucherList = voucherDAO.getAllVouchers();
                request.setAttribute("voucherList", voucherList);
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "Database error while fetching voucher list", e);
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
            String voucherIdParam = request.getParameter("voucherId");
            long voucherId;
            try {
                voucherId = Long.parseLong(voucherIdParam);
            } catch (NumberFormatException e) {
                LOGGER.log(Level.WARNING, "Invalid voucher ID format: " + voucherIdParam, e);
                request.setAttribute("errorMessage", "Invalid voucher ID.");
                request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-edit.jsp").forward(request, response);
                return;
            }

            Voucher existingVoucher = voucherDAO.getVoucherById(voucherId);
            if (existingVoucher == null) {
                request.setAttribute("errorMessage", "Voucher with ID " + voucherId + " not found.");
                request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-edit.jsp").forward(request, response);
                return;
            }

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

            BigDecimal discountValue = existingVoucher.getDiscountValue();
            if (discountValueStr != null && !discountValueStr.trim().isEmpty()) {
                try {
                    discountValue = new BigDecimal(discountValueStr.trim());
                } catch (NumberFormatException e) {
                    LOGGER.log(Level.WARNING, "Invalid discount value: " + discountValueStr, e);
                }
            }

            BigDecimal minimumOrderAmount = existingVoucher.getMinimumOrderAmount();
            if (minimumOrderAmountStr != null && !minimumOrderAmountStr.trim().isEmpty()) {
                try {
                    minimumOrderAmount = new BigDecimal(minimumOrderAmountStr.trim());
                } catch (NumberFormatException e) {
                    LOGGER.log(Level.WARNING, "Invalid minimum order amount: " + minimumOrderAmountStr, e);
                }
            }

            BigDecimal maximumDiscountAmount = existingVoucher.getMaximumDiscountAmount();
            if (maximumDiscountAmountStr != null && !maximumDiscountAmountStr.trim().isEmpty()) {
                try {
                    maximumDiscountAmount = new BigDecimal(maximumDiscountAmountStr.trim());
                } catch (NumberFormatException e) {
                    LOGGER.log(Level.WARNING, "Invalid maximum discount amount: " + maximumDiscountAmountStr, e);
                }
            }

            Integer usageLimit = existingVoucher.getUsageLimit();
            if (usageLimitStr != null && !usageLimitStr.trim().isEmpty()) {
                try {
                    usageLimit = Integer.parseInt(usageLimitStr.trim());
                } catch (NumberFormatException e) {
                    LOGGER.log(Level.WARNING, "Invalid usage limit: " + usageLimitStr, e);
                }
            }

            java.sql.Date sqlExpirationDate = existingVoucher.getExpirationDate();
            if (expirationDateStr != null && !expirationDateStr.trim().isEmpty()) {
                try {
                    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
                    dateFormat.setLenient(false);
                    Date utilDate = dateFormat.parse(expirationDateStr.trim());
                    sqlExpirationDate = new java.sql.Date(utilDate.getTime());
                } catch (ParseException e) {
                    LOGGER.log(Level.WARNING, "Invalid expiration date format: " + expirationDateStr, e);
                }
            }

            boolean isActive = existingVoucher.isActive();
            if (isActiveStr != null && !isActiveStr.trim().isEmpty()) {
                try {
                    isActive = Boolean.parseBoolean(isActiveStr.trim());
                } catch (Exception e) {
                    LOGGER.log(Level.WARNING, "Invalid isActive value: " + isActiveStr, e);
                }
            }

            String finalCode = (code != null && !code.trim().isEmpty()) ? code.trim() : existingVoucher.getCode();
            String finalName = (name != null && !name.trim().isEmpty()) ? name.trim() : existingVoucher.getName();
            String finalDiscountType = (discountType != null && !discountType.trim().isEmpty()) ? discountType : existingVoucher.getDiscountType();

            Voucher voucher = new Voucher(
                voucherId,
                finalCode,
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
                existingVoucher.getCreatedAt()
            );

            boolean updated = voucherDAO.updateVoucher(voucher);
            if (updated) {
                response.sendRedirect(request.getContextPath() + "/vouchers?successMessage=Voucher+updated+successfully");
            } else {
                LOGGER.warning("Update failed for voucher ID: " + voucherId);
                request.setAttribute("errorMessage", "Unable to update voucher. Please check for duplicate voucher code or system error.");
                request.setAttribute("voucher", voucher);
                request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-edit.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error during voucher update", e);
            String errorMessage = "Database error: " + e.getMessage();
            if (e.getMessage().contains("UNIQUE") || e.getMessage().contains("unique")) {
                errorMessage = "Voucher code already exists. Please choose a different code.";
            }
            request.setAttribute("errorMessage", errorMessage);
            request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-edit.jsp").forward(request, response);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Unexpected error during voucher update: " + e.getMessage(), e);
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
