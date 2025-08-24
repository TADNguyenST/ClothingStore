package dao;

import model.Voucher;
import DTO.SavedVoucherDTO;
import util.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class VoucherLookupDAO {

    private final DBContext db;
    private Connection conn;

    public VoucherLookupDAO() {
        this.db = new DBContext();
    }

    private Connection getConn() throws SQLException {
        if (conn == null || conn.isClosed()) {
            conn = db.getConnection();
        }
        return conn;
    }

    /* ==================== LOOKUP VOUCHER ==================== */
    public Voucher findByCodeExact(String code) throws SQLException {
        String sql
                = "SELECT voucher_id, code, name, description, discount_type, discount_value, "
                + "       minimum_order_amount, maximum_discount_amount, usage_limit, used_count, "
                + "       expiration_date, is_active, visibility, created_at "
                + "FROM vouchers WHERE LOWER(code)=LOWER(?)";
        try ( PreparedStatement ps = getConn().prepareStatement(sql)) {
            ps.setString(1, code);
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return map(rs);
                }
            }
        }
        return null;
    }

    /* ==================== ELIGIBILITY CHECK ==================== */
    /**
     * Kiểm tra theo customer_id (giữ nguyên cho nơi khác nếu có dùng)
     */
    public boolean isUsableByCustomer(long voucherId, long customerId) throws SQLException {
        String sql
                = "SELECT TOP 1 is_used FROM customer_vouchers WHERE voucher_id=? AND customer_id=?";
        try ( PreparedStatement ps = getConn().prepareStatement(sql)) {
            ps.setLong(1, voucherId);
            ps.setLong(2, customerId);
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return !rs.getBoolean("is_used");
                }
            }
        }
        return false;
    }

    /**
     * DÙNG CHO CONTROLLER: kiểm tra theo user_id (JOIN sang customers)
     */
    public boolean isUsableByUserId(long voucherId, long userId) throws SQLException {
        String sql
                = "SELECT TOP 1 cv.is_used "
                + "FROM customer_vouchers cv "
                + "JOIN customers c ON c.customer_id = cv.customer_id "
                + "WHERE cv.voucher_id = ? AND c.user_id = ?";
        try ( PreparedStatement ps = getConn().prepareStatement(sql)) {
            ps.setLong(1, voucherId);
            ps.setLong(2, userId);
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return !rs.getBoolean("is_used");
                }
            }
        }
        return false;
    }

    /* ==================== WALLET / SAVED VOUCHERS ==================== */
    /**
     * Lấy ví voucher theo customer_id (giữ nguyên)
     */
    public List<SavedVoucherDTO> listSavedAvailableVouchers(long customerId) throws SQLException {
        String sql
                = "SELECT v.voucher_id, v.code, v.name, v.discount_type, v.discount_value, "
                + "       v.minimum_order_amount, v.maximum_discount_amount, v.expiration_date, "
                + "       v.is_active, v.visibility, cv.is_used "
                + "FROM customer_vouchers cv "
                + "JOIN vouchers v ON v.voucher_id = cv.voucher_id "
                + "WHERE cv.customer_id = ? "
                + "  AND cv.is_used = 0 "
                + // chỉ voucher chưa dùng
                "  AND v.is_active = 1 "
                + "  AND (v.expiration_date IS NULL OR v.expiration_date >= CAST(GETDATE() AS DATE)) "
                + "ORDER BY v.created_at DESC";

        List<SavedVoucherDTO> list = new ArrayList<>();
        try ( PreparedStatement ps = getConn().prepareStatement(sql)) {
            ps.setLong(1, customerId);
            try ( ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapSaved(rs));
                }
            }
        }
        return list;
    }

    /**
     * DÙNG CHO CONTROLLER: lấy ví voucher theo user_id (JOIN sang customers)
     */
    public List<SavedVoucherDTO> listSavedAvailableVouchersByUserId(long userId) throws SQLException {
        String sql
                = "SELECT v.voucher_id, v.code, v.name, v.discount_type, v.discount_value, "
                + "       v.minimum_order_amount, v.maximum_discount_amount, v.expiration_date, "
                + "       v.is_active, v.visibility, cv.is_used "
                + "FROM customer_vouchers cv "
                + "JOIN customers c ON c.customer_id = cv.customer_id "
                + "JOIN vouchers v ON v.voucher_id = cv.voucher_id "
                + "WHERE c.user_id = ? "
                + "  AND cv.is_used = 0 "
                + "  AND v.is_active = 1 "
                + "  AND (v.expiration_date IS NULL OR v.expiration_date >= CAST(GETDATE() AS DATE)) "
                + "ORDER BY v.created_at DESC";

        List<SavedVoucherDTO> list = new ArrayList<>();
        try ( PreparedStatement ps = getConn().prepareStatement(sql)) {
            ps.setLong(1, userId);
            try ( ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapSaved(rs));
                }
            }
        }
        return list;
    }

    /* ==================== MAPPERS ==================== */
    private SavedVoucherDTO mapSaved(ResultSet rs) throws SQLException {
        return new SavedVoucherDTO(
                rs.getLong("voucher_id"),
                rs.getString("code"),
                rs.getString("name"),
                rs.getString("discount_type"),
                rs.getBigDecimal("discount_value"),
                rs.getBigDecimal("minimum_order_amount"),
                rs.getBigDecimal("maximum_discount_amount"),
                rs.getDate("expiration_date"),
                rs.getBoolean("is_active"),
                rs.getBoolean("visibility"),
                rs.getBoolean("is_used")
        );
    }

    private Voucher map(ResultSet rs) throws SQLException {
        Voucher v = new Voucher();
        v.setVoucherId(rs.getLong("voucher_id"));
        v.setCode(rs.getString("code"));
        v.setName(rs.getString("name"));
        v.setDescription(rs.getString("description"));
        v.setDiscountType(rs.getString("discount_type"));
        v.setDiscountValue(rs.getBigDecimal("discount_value"));
        v.setMinimumOrderAmount(rs.getBigDecimal("minimum_order_amount"));
        v.setMaximumDiscountAmount(rs.getBigDecimal("maximum_discount_amount"));
        v.setUsageLimit((Integer) rs.getObject("usage_limit"));
        v.setUsedCount((Integer) rs.getObject("used_count"));
        v.setExpirationDate(rs.getDate("expiration_date"));
        v.setIsActive(rs.getBoolean("is_active"));
        v.setVisibility(rs.getBoolean("visibility"));
        v.setCreatedAt(rs.getDate("created_at"));
        return v;
    }

    /* ==================== HOUSEKEEPING ==================== */
    public void close() {
        db.closeConnection();
        if (conn != null) {
            try {
                conn.close();
            } catch (Exception ignore) {
            }
        }
    }
}
