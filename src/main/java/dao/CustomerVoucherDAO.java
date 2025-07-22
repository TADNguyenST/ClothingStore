package dao;

import model.CustomerVoucher;
import util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.math.BigDecimal;

public class CustomerVoucherDAO {
    private DBContext dbContext;
    private static final Logger LOGGER = Logger.getLogger(CustomerVoucherDAO.class.getName());

    public CustomerVoucherDAO() {
        dbContext = new DBContext();
    }

    public List<CustomerVoucher> getAllCustomerVouchers() throws SQLException {
        return getCustomerVouchersByFilter(null, null, false);
    }

    public List<CustomerVoucher> getCustomerVouchersByFilter(Long customerId, Boolean isUsed, boolean onlyNonUsed) throws SQLException {
        List<CustomerVoucher> vouchers = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT cv.customer_voucher_id, cv.customer_id, cv.voucher_id, cv.sent_date, cv.is_used, cv.used_date, cv.order_id, " +
            "v.code, v.name, v.discount_type, v.discount_value " +
            "FROM customer_vouchers cv JOIN vouchers v ON cv.voucher_id = v.voucher_id WHERE 1=1"
        );
        List<Object> params = new ArrayList<>();

        if (customerId != null) {
            sql.append(" AND cv.customer_id = ?");
            params.add(customerId);
        }
        if (isUsed != null) {
            sql.append(" AND cv.is_used = ?");
            params.add(isUsed ? 1 : 0);
        }
        if (onlyNonUsed) {
            sql.append(" AND cv.is_used = 0");
        }

        sql.append(" ORDER BY cv.sent_date DESC");

        try (Connection conn = dbContext.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            LOGGER.log(Level.INFO, "Executing getCustomerVouchersByFilter with SQL: {}", sql.toString());

            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    CustomerVoucher voucher = mapToCustomerVoucher(rs);
                    vouchers.add(voucher);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error retrieving customer vouchers: {0}", e.getMessage());
            throw e;
        }
        return vouchers;
    }

    public List<CustomerVoucher> getCustomerVouchers(long customerId) throws SQLException {
        return getCustomerVouchersByFilter(customerId, null, false);
    }

    private CustomerVoucher mapToCustomerVoucher(ResultSet rs) throws SQLException {
        return new CustomerVoucher(
            rs.getLong("customer_voucher_id"),
            rs.getLong("customer_id"),
            rs.getLong("voucher_id"),
            rs.getTimestamp("sent_date"),
            rs.getBoolean("is_used"),
            rs.getTimestamp("used_date"),
            rs.getObject("order_id") != null ? rs.getLong("order_id") : null,
            rs.getString("code"),
            rs.getString("name"),
            rs.getString("discount_type"),
            rs.getBigDecimal("discount_value")
        );
    }

    public boolean addCustomerVoucher(long customerId, int voucherId) throws SQLException {
        String sql = "INSERT INTO customer_vouchers (customer_id, voucher_id, is_used) VALUES (?, ?, 0)";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, customerId);
            stmt.setInt(2, voucherId);
            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error adding customer voucher: {0}", e.getMessage());
            throw e;
        }
    }

    public void closeConnection() {
        dbContext.closeConnection();
    }
}