package dao;
import model.Voucher;
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
import java.sql.Date;

public class VoucherDAO {
    private DBContext dbContext;
    private static final Logger LOGGER = Logger.getLogger(VoucherDAO.class.getName());

    public VoucherDAO() {
        dbContext = new DBContext();
    }

    public List<Voucher> getAllVouchers() throws SQLException {
        return getVouchersByFilter(null, null, null, false);
    }

    public List<Voucher> getPublicVouchers() throws SQLException {
        return getVouchersByFilter(null, null, null, true);
    }

    public List<Voucher> getVouchersByFilter(String code, Boolean isActive, boolean onlyNonExpired) throws SQLException {
        return getVouchersByFilter(code, null, isActive, onlyNonExpired);
    }

    public List<Voucher> getVouchersByFilter(String code, String name, Boolean isActive, boolean onlyNonExpired) throws SQLException {
        List<Voucher> vouchers = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT voucher_id, code, name, description, discount_type, discount_value, " +
            "minimum_order_amount, maximum_discount_amount, usage_limit, used_count, " +
            "expiration_date, is_active, visibility, created_at, start_date FROM vouchers WHERE 1=1"
        );
        List<Object> params = new ArrayList<>();
        if (code != null && !code.trim().isEmpty()) {
            sql.append(" AND LOWER(code) LIKE ?");
            params.add("%" + code.toLowerCase() + "%");
        }
        if (name != null && !name.trim().isEmpty()) {
            sql.append(" AND LOWER(name) LIKE ?");
            params.add("%" + name.toLowerCase() + "%");
        }
        if (isActive != null) {
            sql.append(" AND is_active = ?");
            params.add(isActive ? 1 : 0);
        }
        if (onlyNonExpired) {
            sql.append(" AND expiration_date >= ?");
            params.add(new Date(System.currentTimeMillis()));
            sql.append(" AND visibility = 1");
        }
        sql.append(" ORDER BY created_at DESC");
        try (Connection conn = dbContext.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            LOGGER.log(Level.INFO, "Executing getVouchersByFilter with SQL: {0}, Parameters: {1}",
                       new Object[]{sql.toString(), params});
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Voucher voucher = mapToVoucher(rs);
                    vouchers.add(voucher);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error retrieving vouchers: {0}", e.getMessage());
            throw e;
        }
        return vouchers;
    }

    public Voucher getVoucherById(long voucherId) throws SQLException {
        String sql = "SELECT voucher_id, code, name, description, discount_type, discount_value, " +
                     "minimum_order_amount, maximum_discount_amount, usage_limit, used_count, " +
                     "expiration_date, is_active, visibility, created_at, start_date FROM vouchers WHERE voucher_id = ?";

        try (Connection conn = dbContext.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, voucherId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapToVoucher(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error retrieving voucher with ID: {0}, Error: {1}",
                       new Object[]{voucherId, e.getMessage()});
            throw e;
        }
        return null;
    }

    public boolean isVoucherSavedByCustomer(long voucherId, long customerId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM customer_vouchers WHERE voucher_id = ? AND customer_id = ?";

        try (Connection conn = dbContext.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, voucherId);
            stmt.setLong(2, customerId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error checking if voucher is saved for customer, Voucher ID: {0}, Customer ID: {1}, Error: {2}",
                       new Object[]{voucherId, customerId, e.getMessage()});
            throw e;
        }
        return false;
    }

    public boolean saveVoucherForCustomer(long voucherId, long customerId) throws SQLException {
        String sql = "INSERT INTO customer_vouchers (customer_id, voucher_id, sent_date, is_used) VALUES (?, ?, GETDATE(), 0)";

        try (Connection conn = dbContext.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            LOGGER.log(Level.INFO, "Executing saveVoucherForCustomer with SQL: {0}, Voucher ID: {1}, Customer ID: {2}",
                       new Object[]{sql, voucherId, customerId});
            stmt.setLong(1, customerId);
            stmt.setLong(2, voucherId);
            int rowsAffected = stmt.executeUpdate();
            LOGGER.log(Level.INFO, "Rows affected by saveVoucherForCustomer: {0}", rowsAffected);
            return rowsAffected > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error saving voucher for customer, Voucher ID: {0}, Customer ID: {1}, Error: {2}",
                       new Object[]{voucherId, customerId, e.getMessage()});
            throw e;
        }
    }

    public boolean updateVoucher(Voucher voucher) throws SQLException {
        String sql = "UPDATE vouchers SET code = ?, name = ?, description = ?, discount_type = ?, " +
                     "discount_value = ?, minimum_order_amount = ?, maximum_discount_amount = ?, " +
                     "usage_limit = ?, expiration_date = ?, is_active = ?, visibility = ?, start_date = ? WHERE voucher_id = ?";

        try (Connection conn = dbContext.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            LOGGER.log(Level.INFO, "Executing updateVoucher with SQL: {0}, Voucher ID: {1}",
                       new Object[]{sql, voucher.getVoucherId()});
            stmt.setString(1, voucher.getCode());
            stmt.setString(2, voucher.getName());
            stmt.setString(3, voucher.getDescription());
            stmt.setString(4, voucher.getDiscountType());
            stmt.setObject(5, voucher.getDiscountValue(), java.sql.Types.DECIMAL);
            stmt.setObject(6, voucher.getMinimumOrderAmount(), java.sql.Types.DECIMAL);
            stmt.setObject(7, voucher.getMaximumDiscountAmount(), java.sql.Types.DECIMAL);
            stmt.setObject(8, voucher.getUsageLimit(), java.sql.Types.INTEGER);
            stmt.setObject(9, voucher.getExpirationDate(), java.sql.Types.DATE);
            stmt.setBoolean(10, voucher.isIsActive());
            stmt.setBoolean(11, voucher.isVisibility());
            stmt.setObject(12, voucher.getStartDate(), java.sql.Types.DATE);
            stmt.setLong(13, voucher.getVoucherId());
            int rowsAffected = stmt.executeUpdate();
            LOGGER.log(Level.INFO, "Rows affected by updateVoucher: {0}", rowsAffected);
            return rowsAffected > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating voucher with ID: {0}, Error: {1}",
                       new Object[]{voucher.getVoucherId(), e.getMessage()});
            throw e;
        }
    }

    public boolean addVoucher(Voucher voucher) throws SQLException {
        String sql = "INSERT INTO vouchers (code, name, description, discount_type, discount_value, " +
                     "minimum_order_amount, maximum_discount_amount, usage_limit, used_count, " +
                     "expiration_date, is_active, visibility, created_at, start_date) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = dbContext.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            LOGGER.log(Level.INFO, "Executing addVoucher with SQL: {0}", sql);
            stmt.setString(1, voucher.getCode());
            stmt.setString(2, voucher.getName());
            stmt.setString(3, voucher.getDescription());
            stmt.setString(4, voucher.getDiscountType());
            stmt.setBigDecimal(5, voucher.getDiscountValue());
            stmt.setObject(6, voucher.getMinimumOrderAmount(), java.sql.Types.DECIMAL);
            stmt.setObject(7, voucher.getMaximumDiscountAmount(), java.sql.Types.DECIMAL);
            stmt.setObject(8, voucher.getUsageLimit(), java.sql.Types.INTEGER);
            stmt.setInt(9, voucher.getUsedCount());
            stmt.setObject(10, voucher.getExpirationDate(), java.sql.Types.DATE);
            stmt.setBoolean(11, voucher.isIsActive());
            stmt.setBoolean(12, voucher.isVisibility());
            stmt.setDate(13, new java.sql.Date(voucher.getCreatedAt().getTime()));
            stmt.setObject(14, voucher.getStartDate(), java.sql.Types.DATE);
            int rowsAffected = stmt.executeUpdate();
            LOGGER.log(Level.INFO, "Rows affected by addVoucher: {0}", rowsAffected);
            return rowsAffected > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error adding voucher: {0}", e.getMessage());
            throw e;
        }
    }

    public boolean deleteVoucher(long voucherId) throws SQLException {
        String sql = "DELETE FROM vouchers WHERE voucher_id = ?";

        try (Connection conn = dbContext.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            LOGGER.log(Level.INFO, "Executing deleteVoucher with SQL: {0}, Voucher ID: {1}",
                       new Object[]{sql, voucherId});
            stmt.setLong(1, voucherId);
            int rowsAffected = stmt.executeUpdate();
            LOGGER.log(Level.INFO, "Rows affected by deleteVoucher: {0}", rowsAffected);
            return rowsAffected > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error deleting voucher with ID: {0}, Error: {1}",
                       new Object[]{voucherId, e.getMessage()});
            throw e;
        }
    }

    private Voucher mapToVoucher(ResultSet rs) throws SQLException {
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
            rs.getBoolean("visibility"),
            rs.getDate("created_at"),
            rs.getDate("start_date")
        );
    }

    public void closeConnection() {
        dbContext.closeConnection();
    }
}