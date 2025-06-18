package dao;

import model.Voucher;
import util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.math.BigDecimal;
import java.sql.Date;
import java.util.logging.Level;
import java.util.logging.Logger;

public class VoucherDAO {
    private DBContext dbContext;
    private static final Logger LOGGER = Logger.getLogger(VoucherDAO.class.getName());

    public VoucherDAO() {
        dbContext = new DBContext();
    }

    // Get all vouchers
    public List<Voucher> getAllVouchers() throws SQLException {
        return getVouchersByFilter(null, null, false);
    }

    // Get vouchers with filters
    public List<Voucher> getVouchersByFilter(String code, Boolean isActive, boolean onlyNonExpired) throws SQLException {
        List<Voucher> vouchers = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT voucher_id, code, name, description, discount_type, discount_value, " +
            "minimum_order_amount, maximum_discount_amount, usage_limit, used_count, " +
            "expiration_date, is_active, created_at FROM vouchers WHERE 1=1"
        );
        List<Object> params = new ArrayList<>();

        // Add filters based on provided parameters
        if (code != null && !code.trim().isEmpty()) {
            sql.append(" AND code = ?");
            params.add(code);
        }
        if (isActive != null) {
            sql.append(" AND is_active = ?");
            params.add(isActive ? 1 : 0);
        }
        if (onlyNonExpired) {
            sql.append(" AND expiration_date >= ?");
            params.add(new Date(System.currentTimeMillis()));
        }

        sql.append(" ORDER BY created_at DESC");

        try (Connection conn = dbContext.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            // Set parameters
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Voucher voucher = new Voucher(
                        rs.getLong("voucher_id"),
                        rs.getString("code"),
                        rs.getString("name"),
                        rs.getString("description"),
                        rs.getString("discount_type"),
                        rs.getBigDecimal("discount_value"),
                        rs.getBigDecimal("minimum_order_amount"),
                        rs.getBigDecimal("maximum_discount_amount"),
                        rs.getObject("usage_limit", Integer.class),
                        rs.getObject("used_count", Integer.class),
                        rs.getDate("expiration_date"),
                        rs.getBoolean("is_active"),
                        rs.getDate("created_at")
                    );
                    vouchers.add(voucher);
                }
            }
        }
        return vouchers;
    }

    // Get a voucher by ID
    public Voucher getVoucherById(long voucherId) throws SQLException {
        String sql = "SELECT voucher_id, code, name, description, discount_type, discount_value, " +
                     "minimum_order_amount, maximum_discount_amount, usage_limit, used_count, " +
                     "expiration_date, is_active, created_at FROM vouchers WHERE voucher_id = ?";
        
        try (Connection conn = dbContext.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, voucherId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return new Voucher(
                        rs.getLong("voucher_id"),
                        rs.getString("code"),
                        rs.getString("name"),
                        rs.getString("description"),
                        rs.getString("discount_type"),
                        rs.getBigDecimal("discount_value"),
                        rs.getBigDecimal("minimum_order_amount"),
                        rs.getBigDecimal("maximum_discount_amount"),
                        rs.getObject("usage_limit", Integer.class),
                        rs.getObject("used_count", Integer.class),
                        rs.getDate("expiration_date"),
                        rs.getBoolean("is_active"),
                        rs.getDate("created_at")
                    );
                }
            }
        }
        return null;
    }

    // Update a voucher
    public boolean updateVoucher(Voucher voucher) throws SQLException {
        String sql = "UPDATE vouchers SET code = ?, name = ?, description = ?, discount_type = ?, " +
                     "discount_value = ?, minimum_order_amount = ?, maximum_discount_amount = ?, " +
                     "usage_limit = ?, expiration_date = ?, is_active = ?, updated_at = GETDATE() " +
                     "WHERE voucher_id = ?";
        
        try (Connection conn = dbContext.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            // Log the SQL statement and voucher details for debugging
            LOGGER.log(Level.INFO, "Executing updateVoucher with SQL: {0}, Voucher: {1}", 
                       new Object[]{sql, voucher.toString()});

            // Set parameters, handling null values explicitly
            stmt.setString(1, voucher.getCode());
            stmt.setString(2, voucher.getName());
            stmt.setString(3, voucher.getDescription()); // Can be null
            stmt.setString(4, voucher.getDiscountType());
            stmt.setBigDecimal(5, voucher.getDiscountValue());
            stmt.setObject(6, voucher.getMinimumOrderAmount(), java.sql.Types.DECIMAL); // Handle null
            stmt.setObject(7, voucher.getMaximumDiscountAmount(), java.sql.Types.DECIMAL); // Handle null
            stmt.setObject(8, voucher.getUsageLimit(), java.sql.Types.INTEGER); // Handle null
            stmt.setDate(9, new java.sql.Date(voucher.getExpirationDate().getTime()));
            stmt.setBoolean(10, voucher.isActive());
            stmt.setLong(11, voucher.getVoucherId());

            int rowsAffected = stmt.executeUpdate();
            LOGGER.log(Level.INFO, "Rows affected by updateVoucher: {0}", rowsAffected);
            return rowsAffected > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating voucher with ID: {0}, Error: {1}", 
                       new Object[]{voucher.getVoucherId(), e.getMessage()});
            throw e; // Re-throw to let servlet handle the error
        }
    }

    // Ensure connection is closed when DAO is no longer needed
    public void closeConnection() {
        dbContext.closeConnection();
    }
}