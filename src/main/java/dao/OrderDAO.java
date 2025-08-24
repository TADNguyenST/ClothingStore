package dao;

import model.CartItem;
import util.DBContext;

import java.math.BigDecimal;
import java.sql.*;
import java.util.List;

public class OrderDAO {

    /**
     * Tạo đơn + ghi chi tiết + (tuỳ chọn) mark voucher used + xoá cart items
     * Tất cả chạy trong 1 transaction.
     *
     * @param customerId bắt buộc
     * @param shippingAddressId có thể null (đã ALTER COLUMN cho phép NULL)
     * @param voucherId có thể null
     * @param subtotal bắt buộc
     * @param discountAmount bắt buộc (có thể = 0)
     * @param totalPrice bắt buộc
     * @param notes có thể null/empty
     * @param items danh sách item đã chọn để chốt sang order_items
     * @param cartItemIds danh sách cart_item_id cần xoá sau khi tạo đơn
     * @return order_id mới tạo
     */
    public long createOrderAndClearCart(
            long customerId,
            Long shippingAddressId,
            Long voucherId,
            BigDecimal subtotal,
            BigDecimal discountAmount,
            BigDecimal totalPrice,
            String notes,
            List<CartItem> items,
            List<Long> cartItemIds
    ) throws SQLException {

        if (items == null || items.isEmpty()) {
            throw new SQLException("No items to place order.");
        }
        if (subtotal == null) {
            subtotal = BigDecimal.ZERO;
        }
        if (discountAmount == null) {
            discountAmount = BigDecimal.ZERO;
        }
        if (totalPrice == null) {
            totalPrice = BigDecimal.ZERO;
        }

        String sqlOrder = "INSERT INTO orders "
                + " (customer_id, shipping_address_id, voucher_id, subtotal, discount_amount, "
                + "  shipping_fee, total_price, status, payment_status, notes, created_at, updated_at) "
                + " VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE(), GETDATE())";

        String sqlItem = "INSERT INTO order_items "
                + " (order_id, variant_id, quantity, price_at_purchase, discount_amount, total_price) "
                + " VALUES (?, ?, ?, ?, ?, ?)";

        // OPTIONAL: update vouchers
        String sqlMarkVoucherCustomer = "UPDATE cv SET cv.is_used = 1 "
                + "FROM customer_vouchers cv "
                + "JOIN customers c ON c.customer_id = cv.customer_id "
                + "WHERE cv.voucher_id = ? AND c.customer_id = ?";
        String sqlIncVoucherUsed = "UPDATE vouchers SET used_count = ISNULL(used_count,0) + 1 WHERE voucher_id = ?";

        // Delete cart items (bulk)
        // sẽ build IN (?, ?, ...)
        Connection conn = null;
        try {
            conn = DBContext.getNewConnection();
            conn.setAutoCommit(false);

            long orderId;
            try ( PreparedStatement ps = conn.prepareStatement(sqlOrder, Statement.RETURN_GENERATED_KEYS)) {
                int i = 1;
                ps.setLong(i++, customerId);

                if (shippingAddressId == null) {
                    ps.setNull(i++, Types.BIGINT);
                } else {
                    ps.setLong(i++, shippingAddressId);
                }

                if (voucherId == null) {
                    ps.setNull(i++, Types.BIGINT);
                } else {
                    ps.setLong(i++, voucherId);
                }

                ps.setBigDecimal(i++, subtotal);
                ps.setBigDecimal(i++, discountAmount);
                ps.setBigDecimal(i++, BigDecimal.ZERO); // shipping_fee = 0 (free ship)
                ps.setBigDecimal(i++, totalPrice);
                ps.setString(i++, "PENDING"); // tuỳ nghiệp vụ
                ps.setString(i++, "UNPAID");  // tuỳ nghiệp vụ
                ps.setString(i++, notes);

                ps.executeUpdate();

                try ( ResultSet rs = ps.getGeneratedKeys()) {
                    if (!rs.next()) {
                        throw new SQLException("Failed to create order: no id returned.");
                    }
                    orderId = rs.getLong(1);
                }
            }

            // Ghi order_items
            try ( PreparedStatement psi = conn.prepareStatement(sqlItem)) {
                for (CartItem it : items) {
                    BigDecimal unit = it.getUnitPrice() == null ? BigDecimal.ZERO : it.getUnitPrice();
                    int qty = it.getQuantity();
                    if (qty <= 0) {
                        qty = 1;
                    }
                    BigDecimal lineTotal = unit.multiply(BigDecimal.valueOf(qty));

                    int i = 1;
                    psi.setLong(i++, orderId);
                    psi.setLong(i++, it.getVariantId());
                    psi.setInt(i++, qty);
                    psi.setBigDecimal(i++, unit);
                    psi.setBigDecimal(i++, BigDecimal.ZERO); // discount per-line (đang không tách)
                    psi.setBigDecimal(i++, lineTotal);
                    psi.addBatch();
                }
                psi.executeBatch();
            }

            // OPTIONAL: đánh dấu voucher đã dùng
            if (voucherId != null) {
                try ( PreparedStatement p1 = conn.prepareStatement(sqlMarkVoucherCustomer)) {
                    p1.setLong(1, voucherId);
                    p1.setLong(2, customerId);
                    p1.executeUpdate();
                }
                try ( PreparedStatement p2 = conn.prepareStatement(sqlIncVoucherUsed)) {
                    p2.setLong(1, voucherId);
                    p2.executeUpdate();
                }
            }

            // Xoá cart items đã checkout
            if (cartItemIds != null && !cartItemIds.isEmpty()) {
                StringBuilder sb = new StringBuilder("DELETE FROM cart_items WHERE customer_id = ? AND cart_item_id IN (");
                for (int k = 0; k < cartItemIds.size(); k++) {
                    if (k > 0) {
                        sb.append(',');
                    }
                    sb.append('?');
                }
                sb.append(')');

                try ( PreparedStatement psd = conn.prepareStatement(sb.toString())) {
                    int i = 1;
                    psd.setLong(i++, customerId);
                    for (Long id : cartItemIds) {
                        psd.setLong(i++, id);
                    }
                    psd.executeUpdate();
                }
            }

            conn.commit();
            return orderId;

        } catch (SQLException e) {
            if (conn != null) try {
                conn.rollback();
            } catch (Exception ignore) {
            }
            throw e;
        } finally {
            if (conn != null) try {
                conn.close();
            } catch (Exception ignore) {
            }
        }
    }
}
