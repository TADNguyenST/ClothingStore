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

public class VoucherDAO {
    private DBContext dbContext;

    public VoucherDAO() {
        dbContext = new DBContext();
    }

    // Original method to get all vouchers
    public List<Voucher> getAllVouchers() throws SQLException {
        return getVouchersByFilter(null, null, false);
    }

    // New method to get vouchers with filters
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

    // Ensure connection is closed when DAO is no longer needed
    public void closeConnection() {
        dbContext.closeConnection();
    }
}