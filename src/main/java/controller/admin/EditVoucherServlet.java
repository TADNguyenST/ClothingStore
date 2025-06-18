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
        // Set character encoding to UTF-8
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
                    request.setAttribute("errorMessage", "Không tìm thấy voucher với ID: " + voucherId);
                }
            } catch (NumberFormatException e) {
                LOGGER.log(Level.WARNING, "Invalid voucher ID format: " + voucherIdParam, e);
                request.setAttribute("errorMessage", "ID voucher không hợp lệ.");
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "Database error while fetching voucher: " + voucherIdParam, e);
                request.setAttribute("errorMessage", "Lỗi cơ sở dữ liệu khi lấy voucher: " + e.getMessage());
            }
        } else {
            try {
                List<Voucher> voucherList = voucherDAO.getAllVouchers();
                request.setAttribute("voucherList", voucherList);
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "Database error while fetching voucher list", e);
                request.setAttribute("errorMessage", "Lỗi khi lấy danh sách voucher: " + e.getMessage());
            }
        }

        request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-edit.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Set character encoding to UTF-8
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        try {
            // Extract and validate voucher ID
            String voucherIdParam = request.getParameter("voucherId");
            if (voucherIdParam == null || voucherIdParam.trim().isEmpty()) {
                throw new IllegalArgumentException("ID voucher không được để trống.");
            }

            long voucherId;
            try {
                voucherId = Long.parseLong(voucherIdParam);
            } catch (NumberFormatException e) {
                throw new IllegalArgumentException("ID voucher không hợp lệ.");
            }

            // Fetch existing voucher to preserve unchanged fields
            Voucher existingVoucher = voucherDAO.getVoucherById(voucherId);
            if (existingVoucher == null) {
                throw new IllegalArgumentException("Không tìm thấy voucher với ID: " + voucherId);
            }

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

            // Validate required fields
            if (code == null || code.trim().isEmpty()) {
                throw new IllegalArgumentException("Mã voucher không được để trống.");
            }
            if (name == null || name.trim().isEmpty()) {
                throw new IllegalArgumentException("Tên voucher không được để trống.");
            }
            if (discountType == null || !discountType.matches("Percentage|Fixed Amount")) {
                throw new IllegalArgumentException("Loại giảm giá không hợp lệ.");
            }
            if (discountValueStr == null || discountValueStr.trim().isEmpty()) {
                throw new IllegalArgumentException("Giá trị giảm giá không được để trống.");
            }
            if (expirationDateStr == null || expirationDateStr.trim().isEmpty()) {
                throw new IllegalArgumentException("Ngày hết hạn không được để trống.");
            }
            if (isActiveStr == null || isActiveStr.trim().isEmpty()) {
                throw new IllegalArgumentException("Trạng thái không được để trống.");
            }

            // Parse and validate discount value
            BigDecimal discountValue;
            try {
                discountValue = new BigDecimal(discountValueStr.trim());
                if (discountValue.compareTo(BigDecimal.ZERO) <= 0) {
                    throw new IllegalArgumentException("Giá trị giảm giá phải lớn hơn 0.");
                }
            } catch (NumberFormatException e) {
                throw new IllegalArgumentException("Giá trị giảm giá không hợp lệ: " + discountValueStr);
            }

            // Parse optional numeric fields, retain existing values if not provided
            BigDecimal minimumOrderAmount = existingVoucher.getMinimumOrderAmount();
            if (minimumOrderAmountStr != null && !minimumOrderAmountStr.trim().isEmpty()) {
                try {
                    minimumOrderAmount = new BigDecimal(minimumOrderAmountStr.trim());
                    if (minimumOrderAmount.compareTo(BigDecimal.ZERO) < 0) {
                        throw new IllegalArgumentException("Số tiền đơn hàng tối thiểu không được âm.");
                    }
                } catch (NumberFormatException e) {
                    throw new IllegalArgumentException("Số tiền đơn hàng tối thiểu không hợp lệ: " + minimumOrderAmountStr);
                }
            }

            BigDecimal maximumDiscountAmount = existingVoucher.getMaximumDiscountAmount();
            if (maximumDiscountAmountStr != null && !maximumDiscountAmountStr.trim().isEmpty()) {
                try {
                    maximumDiscountAmount = new BigDecimal(maximumDiscountAmountStr.trim());
                    if (maximumDiscountAmount.compareTo(BigDecimal.ZERO) < 0) {
                        throw new IllegalArgumentException("Số tiền giảm tối đa không được âm.");
                    }
                } catch (NumberFormatException e) {
                    throw new IllegalArgumentException("Số tiền giảm tối đa không hợp lệ: " + maximumDiscountAmountStr);
                }
            }

            Integer usageLimit = existingVoucher.getUsageLimit();
            if (usageLimitStr != null && !usageLimitStr.trim().isEmpty()) {
                try {
                    usageLimit = Integer.parseInt(usageLimitStr.trim());
                    if (usageLimit <= 0) {
                        throw new IllegalArgumentException("Giới hạn sử dụng phải lớn hơn 0.");
                    }
                } catch (NumberFormatException e) {
                    throw new IllegalArgumentException("Giới hạn sử dụng không hợp lệ: " + usageLimitStr);
                }
            }

            // Parse expiration date
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
            dateFormat.setLenient(false);
            java.sql.Date sqlExpirationDate;
            try {
                Date utilDate = dateFormat.parse(expirationDateStr.trim());
                sqlExpirationDate = new java.sql.Date(utilDate.getTime());
                // Validate that expiration date is not in the past
                if (sqlExpirationDate.before(new java.sql.Date(System.currentTimeMillis()))) {
                    throw new IllegalArgumentException("Ngày hết hạn không được là ngày trong quá khứ.");
                }
            } catch (ParseException e) {
                throw new IllegalArgumentException("Định dạng ngày hết hạn không hợp lệ: " + expirationDateStr);
            }

            // Parse isActive
            boolean isActive;
            try {
                isActive = Boolean.parseBoolean(isActiveStr.trim());
            } catch (Exception e) {
                throw new IllegalArgumentException("Trạng thái không hợp lệ: " + isActiveStr);
            }

            // Create Voucher object with updated values
            Voucher voucher = new Voucher(
                voucherId,
                code.trim(),
                name.trim(),
                description != null && !description.trim().isEmpty() ? description.trim() : existingVoucher.getDescription(),
                discountType,
                discountValue,
                minimumOrderAmount,
                maximumDiscountAmount,
                usageLimit,
                existingVoucher.getUsedCount(), // Preserve used_count
                sqlExpirationDate,
                isActive,
                existingVoucher.getCreatedAt() // Preserve created_at
            );

            // Update voucher in database
            boolean updated = voucherDAO.updateVoucher(voucher);
            if (updated) {
                response.sendRedirect(request.getContextPath() + "/voucherList?successMessage=Voucher+cập+nhật+thành+công");
            } else {
                LOGGER.warning("Update failed for voucher ID: " + voucherId);
                request.setAttribute("errorMessage", "Không thể cập nhật voucher. Vui lòng kiểm tra mã voucher trùng lặp hoặc lỗi hệ thống.");
                request.setAttribute("voucher", voucher);
                request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-edit.jsp").forward(request, response);
            }
        } catch (IllegalArgumentException e) {
            LOGGER.log(Level.WARNING, "Validation error: " + e.getMessage(), e);
            request.setAttribute("errorMessage", e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-edit.jsp").forward(request, response);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error during voucher update", e);
            String errorMessage = "Lỗi cơ sở dữ liệu: " + e.getMessage();
            if (e.getMessage().contains("UNIQUE") || e.getMessage().contains("unique")) {
                errorMessage = "Mã voucher đã tồn tại. Vui lòng chọn mã khác.";
            }
            request.setAttribute("errorMessage", errorMessage);
            request.getRequestDispatcher("/WEB-INF/views/admin/voucher/voucher-edit.jsp").forward(request, response);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Unexpected error during voucher update: " + e.getMessage(), e);
            request.setAttribute("errorMessage", "Lỗi không xác định: " + e.getMessage());
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