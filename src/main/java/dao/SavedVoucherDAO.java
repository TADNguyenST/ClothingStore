package dao;

import util.DBContext;

import java.sql.*;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

public class SavedVoucherDAO implements AutoCloseable {

    private final DBContext db = new DBContext();
    private Connection conn;

    private Connection getConn() throws SQLException {
        if (conn == null || conn.isClosed()) {
            conn = db.getConnection();
        }
        return conn;
    }

    public static class Row {

        public String code;
        public String name;
        public String type;             // Percentage | Fixed Amount
        public BigDecimal value;        // % hoặc số tiền
        public BigDecimal minOrder;     // có thể null
        public BigDecimal maxDiscount;  // có thể null
        public Date expirationDate;     // có thể null
        public boolean isActive;
        public boolean isUsed;
    }

    public List<Row> listForCustomer(long customerId) throws SQLException {
        String sql
                = "SELECT v.code, v.name, v.discount_type, v.discount_value, "
                + "       v.minimum_order_amount, v.maximum_discount_amount, "
                + "       v.expiration_date, v.is_active, cv.is_used "
                + "FROM customer_vouchers cv "
                + "JOIN vouchers v ON v.voucher_id = cv.voucher_id "
                + "WHERE cv.customer_id = ? "
                + "ORDER BY v.voucher_id DESC";

        List<Row> out = new ArrayList<>();
        try ( PreparedStatement ps = getConn().prepareStatement(sql)) {
            ps.setLong(1, customerId);
            try ( ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Row r = new Row();
                    r.code = rs.getString("code");
                    r.name = rs.getString("name");
                    r.type = rs.getString("discount_type");
                    r.value = rs.getBigDecimal("discount_value");
                    r.minOrder = rs.getBigDecimal("minimum_order_amount");
                    r.maxDiscount = rs.getBigDecimal("maximum_discount_amount");
                    r.expirationDate = rs.getDate("expiration_date");
                    r.isActive = rs.getBoolean("is_active");
                    r.isUsed = rs.getBoolean("is_used");
                    out.add(r);
                }
            }
        }
        return out;
    }

    @Override
    public void close() {
        db.closeConnection();
        if (conn != null) try {
            conn.close();
        } catch (Exception ignore) {
        }
    }
}
