package dao;

import model.CartItem;
import util.DBContext;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OrderDAO {

    /**
     * Tạo đơn + ghi chi tiết + (tuỳ chọn) mark voucher used + xoá cart items —
     * tất cả trong 1 transaction. LƯU Ý: KHÔNG reserve tồn ở bước này. Reserve
     * CHỈ thực hiện khi payment_status chuyển sang PAID.
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
                + " (customer_id, order_date, shipping_address_id, voucher_id, subtotal, discount_amount, "
                + "  shipping_fee, total_price, status, payment_status, notes, created_at, updated_at) "
                + " VALUES (?, DATEADD(HOUR,7,SYSUTCDATETIME()), ?, ?, ?, ?, ?, ?, ?, ?, ?, "
                + "         DATEADD(HOUR,7,SYSUTCDATETIME()), DATEADD(HOUR,7,SYSUTCDATETIME()))";

        String sqlItem = "INSERT INTO order_items "
                + " (order_id, variant_id, quantity, price_at_purchase, discount_amount, total_price) "
                + " VALUES (?, ?, ?, ?, ?, ?)";

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
                ps.setBigDecimal(i++, BigDecimal.ZERO);  // shipping_fee = 0
                ps.setBigDecimal(i++, totalPrice);
                ps.setString(i++, "PENDING");
                ps.setString(i++, "UNPAID");
                ps.setString(i++, notes);
                ps.executeUpdate();

                try ( ResultSet rs = ps.getGeneratedKeys()) {
                    if (!rs.next()) {
                        throw new SQLException("Failed to create order: no id returned.");
                    }
                    orderId = rs.getLong(1);
                }
            }

            // Items
            try ( PreparedStatement psi = conn.prepareStatement(sqlItem)) {
                for (CartItem it : items) {
                    BigDecimal unit = it.getUnitPrice() == null ? BigDecimal.ZERO : it.getUnitPrice();
                    int qty = Math.max(1, it.getQuantity());
                    BigDecimal lineTotal = unit.multiply(BigDecimal.valueOf(qty));

                    int i = 1;
                    psi.setLong(i++, orderId);
                    psi.setLong(i++, it.getVariantId());
                    psi.setInt(i++, qty);
                    psi.setBigDecimal(i++, unit);
                    psi.setBigDecimal(i++, BigDecimal.ZERO);
                    psi.setBigDecimal(i++, lineTotal);
                    psi.addBatch();
                }
                psi.executeBatch();
            }

            // KHÔNG reserve ở đây.
            // Xoá cart items
            if (cartItemIds != null && !cartItemIds.isEmpty()) {
                StringBuilder sb = new StringBuilder("DELETE FROM cart_items WHERE customer_id = ? AND cart_item_id IN (");
                for (int k = 0; k < cartItemIds.size(); k++) {
                    sb.append(k == 0 ? "?" : ",?");
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

    /**
     * Tạo DRAFT rỗng (giữ tương thích)
     */
    public long createDraftOrder(long customerId) throws SQLException {
        String sql = "INSERT INTO orders "
                + "(customer_id, order_date, status, payment_status, subtotal, discount_amount, shipping_fee, total_price, created_at, updated_at) "
                + "VALUES (?, DATEADD(HOUR,7,SYSUTCDATETIME()), 'DRAFT', 'UNPAID', 0, 0, 0, 0, "
                + "        DATEADD(HOUR,7,SYSUTCDATETIME()), DATEADD(HOUR,7,SYSUTCDATETIME()))";

        try ( Connection c = DBContext.getNewConnection();  PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setLong(1, customerId);
            ps.executeUpdate();
            try ( ResultSet rs = ps.getGeneratedKeys()) {
                rs.next();
                return rs.getLong(1);
            }
        }
    }

    public void insertOrderItem(long orderId, long variantId, int qty) throws SQLException {
        final String qPrice = "SELECT ISNULL(pv.price_modifier, p.price) AS unit "
                + "FROM product_variants pv JOIN products p ON pv.product_id = p.product_id "
                + "WHERE pv.variant_id = ?";
        final String ins = "INSERT INTO order_items "
                + "(order_id, variant_id, quantity, price_at_purchase, discount_amount, total_price) VALUES (?, ?, ?, ?, ?, ?)";

        try ( Connection c = DBContext.getNewConnection()) {
            BigDecimal unit = BigDecimal.ZERO;
            try ( PreparedStatement psPrice = c.prepareStatement(qPrice)) {
                psPrice.setLong(1, variantId);
                try ( ResultSet rs = psPrice.executeQuery()) {
                    if (rs.next()) {
                        unit = rs.getBigDecimal("unit");
                    }
                }
            }
            if (unit == null) {
                unit = BigDecimal.ZERO;
            }

            int q = Math.max(1, qty);
            BigDecimal line = unit.multiply(BigDecimal.valueOf(q));

            try ( PreparedStatement psIns = c.prepareStatement(ins)) {
                psIns.setLong(1, orderId);
                psIns.setLong(2, variantId);
                psIns.setInt(3, q);
                psIns.setBigDecimal(4, unit);
                psIns.setBigDecimal(5, BigDecimal.ZERO);
                psIns.setBigDecimal(6, line);
                psIns.executeUpdate();
            }
        }
    }

    public List<CartItem> loadItemsViewForOrder(long orderId) throws SQLException {
        String sql = "SELECT oi.variant_id, oi.quantity, oi.price_at_purchase AS unit_price, oi.total_price, "
                + "       p.product_id, p.name, pv.size, pv.color, "
                + "       COALESCE( "
                + "         (SELECT TOP 1 pi.image_url FROM product_images pi WHERE pi.variant_id = pv.variant_id ORDER BY pi.is_main DESC, pi.display_order ASC), "
                + "         (SELECT TOP 1 pi.image_url FROM product_images pi WHERE pi.product_id = p.product_id AND pi.is_main = 1 ORDER BY pi.display_order ASC) "
                + "       ) AS image_url "
                + "FROM order_items oi "
                + "JOIN product_variants pv ON oi.variant_id = pv.variant_id "
                + "JOIN products p ON pv.product_id = p.product_id "
                + "WHERE oi.order_id = ?";

        List<CartItem> out = new ArrayList<>();
        try ( Connection c = DBContext.getNewConnection();  PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, orderId);
            try ( ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CartItem it = new CartItem();
                    it.setVariantId(rs.getLong("variant_id"));
                    it.setProductId(rs.getLong("product_id"));
                    it.setProductName(rs.getString("name"));
                    it.setSize(rs.getString("size"));
                    it.setColor(rs.getString("color"));
                    it.setQuantity(rs.getInt("quantity"));
                    it.setUnitPrice(rs.getBigDecimal("unit_price"));
                    it.setTotalPrice(rs.getBigDecimal("total_price"));

                    String imageUrl = rs.getString("image_url");
                    if (imageUrl != null && imageUrl.contains("/image/upload/")) {
                        imageUrl = imageUrl.replace("/image/upload/", "/image/upload/w_100,h_100,c_fill,f_auto,q_auto/");
                    }
                    if (imageUrl == null || imageUrl.trim().isEmpty()) {
                        imageUrl = "https://placehold.co/100x100/eee/333?text=No+Image";
                    }
                    it.setImageUrl(imageUrl);
                    out.add(it);
                }
            }
        }
        return out;
    }

    public void finalizeDraftOrder(long orderId,
            Long shippingAddressId,
            Long voucherId,
            BigDecimal subtotal,
            BigDecimal discount,
            BigDecimal total,
            String notes) throws SQLException {
        String sql = "UPDATE orders SET "
                + "shipping_address_id=?, voucher_id=?, subtotal=?, discount_amount=?, shipping_fee=0, total_price=?, "
                + "status='PENDING', payment_status='UNPAID', notes=?, updated_at=DATEADD(HOUR,7,SYSUTCDATETIME()) "
                + "WHERE order_id=? AND status='DRAFT'";
        try ( Connection c = DBContext.getNewConnection();  PreparedStatement ps = c.prepareStatement(sql)) {
            int i = 1;
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
            ps.setBigDecimal(i++, subtotal == null ? BigDecimal.ZERO : subtotal);
            ps.setBigDecimal(i++, discount == null ? BigDecimal.ZERO : discount);
            ps.setBigDecimal(i++, total == null ? BigDecimal.ZERO : total);
            ps.setString(i++, notes);
            ps.setLong(i, orderId);
            ps.executeUpdate();
        }
    }

    public BigDecimal getOrderTotal(long orderId) throws SQLException {
        String sql = "SELECT total_price FROM orders WHERE order_id=?";
        try ( Connection c = DBContext.getNewConnection();  PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, orderId);
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getBigDecimal(1);
                }
            }
        }
        return BigDecimal.ZERO;
    }

    /**
     * Mark PAID – reserve kho NGAY TRONG transaction này, nhưng KHÔNG ghi log
     * Reserved. - Không set PAID nếu đơn đã CANCELED hoặc đã PAID. - Nếu
     * reserve thiếu tồn hoặc trạng thái thay đổi giữa chừng: rollback.
     */
    public void markOrderPaid(long orderId, BigDecimal ignored) throws SQLException {
        final String sel = "SELECT status, payment_status FROM orders WITH (UPDLOCK, ROWLOCK) WHERE order_id=?";
        final String qItems = "SELECT variant_id, quantity FROM order_items WHERE order_id=?";
        final String updReserve = "UPDATE i SET reserved_quantity = ISNULL(i.reserved_quantity,0) + ?, "
                + "last_updated=DATEADD(HOUR,7,SYSUTCDATETIME()) "
                + "FROM inventory i WHERE i.variant_id=? AND (i.quantity - ISNULL(i.reserved_quantity,0)) >= ?";
        final String updPaid = "UPDATE orders SET payment_status='PAID', "
                + "updated_at=DATEADD(HOUR,7,SYSUTCDATETIME()) "
                + "WHERE order_id=? AND status <> 'CANCELED' AND payment_status IN ('UNPAID','FAILED')";

        try ( Connection c = DBContext.getNewConnection()) {
            c.setAutoCommit(false);

            String st, pst;
            try ( PreparedStatement ps = c.prepareStatement(sel)) {
                ps.setLong(1, orderId);
                try ( ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        c.rollback();
                        throw new SQLException("Order not found");
                    }
                    st = rs.getString(1);
                    pst = rs.getString(2);
                }
            }

            if ("CANCELED".equalsIgnoreCase(st)) {
                c.rollback();
                throw new SQLException("Cannot mark PAID: order is canceled.");
            }
            if ("PAID".equalsIgnoreCase(pst)) {
                c.rollback();
                return;
            } // idempotent

            // Reserve all lines (no log)
            try ( PreparedStatement psIt = c.prepareStatement(qItems);  PreparedStatement psUpd = c.prepareStatement(updReserve)) {
                psIt.setLong(1, orderId);
                try ( ResultSet rs = psIt.executeQuery()) {
                    while (rs.next()) {
                        long v = rs.getLong(1);
                        int qty = rs.getInt(2);

                        psUpd.setInt(1, qty);
                        psUpd.setLong(2, v);
                        psUpd.setInt(3, qty);
                        int rows = psUpd.executeUpdate();
                        if (rows == 0) {
                            c.rollback();
                            throw new SQLException("Insufficient stock to reserve variant " + v);
                        }
                    }
                }
            }

            int updated;
            try ( PreparedStatement ps = c.prepareStatement(updPaid)) {
                ps.setLong(1, orderId);
                updated = ps.executeUpdate();
            }
            if (updated == 0) {
                c.rollback();
                throw new SQLException("Order changed during payment; cannot mark PAID.");
            }

            c.commit();
        }
    }

    /**
     * Payment FAILED → set FAILED và nhả reserve (không log Released).
     */
    public void markOrderFailed(long orderId, String reason) throws SQLException {
        String sql = "UPDATE orders SET payment_status='FAILED', "
                + "notes = CONCAT(ISNULL(notes,''), CHAR(10), ?), updated_at=DATEADD(HOUR,7,SYSUTCDATETIME()) "
                + "WHERE order_id=?";
        try ( Connection c = DBContext.getNewConnection();  PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, "[PAYMENT] " + (reason == null ? "FAILED" : reason));
            ps.setLong(2, orderId);
            ps.executeUpdate();
        }
        releaseReservation(orderId, null);
    }

    public model.OrderHeader findOrderHeaderForCustomer(long orderId, long customerId) throws SQLException {
        String sql = "SELECT o.order_id, o.customer_id, o.shipping_address_id, o.voucher_id, "
                + "       o.subtotal, o.discount_amount, o.shipping_fee, o.total_price, "
                + "       o.status, o.payment_status, o.notes, o.created_at, o.updated_at, "
                + "       a.recipient_name, a.phone_number, a.street_address, "
                + "       w.name AS ward_name, p.name AS province_name "
                + "FROM orders o "
                + "LEFT JOIN addresses a ON o.shipping_address_id = a.address_id "
                + "LEFT JOIN wards w ON a.ward_id = w.ward_id "
                + "LEFT JOIN provinces p ON a.province_id = p.province_id "
                + "WHERE o.order_id = ? AND o.customer_id = ?";
        try ( Connection c = DBContext.getNewConnection();  PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, orderId);
            ps.setLong(2, customerId);
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    model.OrderHeader h = new model.OrderHeader();
                    h.setOrderId(rs.getLong("order_id"));
                    h.setCustomerId(rs.getLong("customer_id"));
                    long addr = rs.getLong("shipping_address_id");
                    h.setShippingAddressId(rs.wasNull() ? null : addr);
                    long vid = rs.getLong("voucher_id");
                    h.setVoucherId(rs.wasNull() ? null : vid);
                    h.setSubtotal(rs.getBigDecimal("subtotal"));
                    h.setDiscountAmount(rs.getBigDecimal("discount_amount"));
                    h.setShippingFee(rs.getBigDecimal("shipping_fee"));
                    h.setTotalPrice(rs.getBigDecimal("total_price"));
                    h.setStatus(rs.getString("status"));
                    h.setPaymentStatus(rs.getString("payment_status"));
                    h.setNotes(rs.getString("notes"));
                    h.setCreatedAt(rs.getTimestamp("created_at"));
                    h.setUpdatedAt(rs.getTimestamp("updated_at"));
                    h.setRecipientName(rs.getString("recipient_name"));
                    h.setPhoneNumber(rs.getString("phone_number"));
                    h.setStreetAddress(rs.getString("street_address"));
                    h.setWardName(rs.getString("ward_name"));
                    h.setProvinceName(rs.getString("province_name"));
                    return h;
                }
            }
        }
        return null;
    }

    // ====== Danh sách đơn khách — ẨN toàn bộ UNPAID ======
    public List<model.OrderHeader> listOrdersForCustomer(long customerId, String statusFilter, int offset, int limit)
            throws SQLException {

        String base = "SELECT o.order_id, o.customer_id, o.total_price, o.status, o.payment_status, o.created_at, "
                + "       COUNT(oi.order_item_id) AS item_count "
                + "FROM orders o "
                + "LEFT JOIN order_items oi ON oi.order_id = o.order_id "
                + "WHERE o.customer_id = ? AND o.payment_status <> 'UNPAID' ";

        String filter = "";
        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"all".equalsIgnoreCase(statusFilter)) {
            filter = " AND o.status = ? ";
        }

        String tail = "GROUP BY o.order_id, o.customer_id, o.total_price, o.status, o.payment_status, o.created_at "
                + "ORDER BY o.created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        String sql = base + filter + tail;

        List<model.OrderHeader> out = new ArrayList<>();
        try ( Connection c = DBContext.getNewConnection();  PreparedStatement ps = c.prepareStatement(sql)) {
            int i = 1;
            ps.setLong(i++, customerId);
            if (!filter.isEmpty()) {
                ps.setString(i++, statusFilter.trim());
            }
            ps.setInt(i++, Math.max(0, offset));
            ps.setInt(i, Math.max(1, limit));
            try ( ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    model.OrderHeader h = new model.OrderHeader();
                    h.setOrderId(rs.getLong("order_id"));
                    h.setCustomerId(rs.getLong("customer_id"));
                    h.setTotalPrice(rs.getBigDecimal("total_price"));
                    h.setStatus(rs.getString("status"));
                    h.setPaymentStatus(rs.getString("payment_status"));
                    h.setCreatedAt(rs.getTimestamp("created_at"));
                    h.setItemCount(rs.getInt("item_count"));
                    out.add(h);
                }
            }
        }
        return out;
    }

    public int countOrdersForCustomer(long customerId, String statusFilter) throws SQLException {
        String base = "SELECT COUNT(*) FROM orders o WHERE o.customer_id = ? AND o.payment_status <> 'UNPAID' ";
        String filter = "";
        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"all".equalsIgnoreCase(statusFilter)) {
            filter = " AND o.status = ? ";
        }
        String sql = base + filter;

        try ( Connection c = DBContext.getNewConnection();  PreparedStatement ps = c.prepareStatement(sql)) {
            int i = 1;
            ps.setLong(i++, customerId);
            if (!filter.isEmpty()) {
                ps.setString(i++, statusFilter.trim());
            }
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    public void consumeVoucherIfAny(long orderId) throws SQLException {
        String updCv = "UPDATE TOP (1) cv SET cv.is_used = 1, cv.used_date = DATEADD(HOUR,7,SYSUTCDATETIME()), cv.order_id = ? "
                + "FROM customer_vouchers cv JOIN orders o ON o.customer_id = cv.customer_id AND o.voucher_id = cv.voucher_id "
                + "WHERE o.order_id = ? AND cv.is_used = 0 AND cv.order_id IS NULL AND o.voucher_id IS NOT NULL";

        String incUsed = "UPDATE v SET v.used_count = ISNULL(v.used_count,0) + 1 "
                + "FROM vouchers v JOIN orders o ON o.voucher_id = v.voucher_id WHERE o.order_id = ?";

        try ( Connection c = DBContext.getNewConnection()) {
            c.setAutoCommit(false);
            try ( PreparedStatement ps = c.prepareStatement(updCv)) {
                ps.setLong(1, orderId);
                ps.setLong(2, orderId);
                ps.executeUpdate();
            }
            try ( PreparedStatement ps2 = c.prepareStatement(incUsed)) {
                ps2.setLong(1, orderId);
                ps2.executeUpdate();
            }
            c.commit();
        }
    }

    // ===== STOCK HELPERS =====
    /**
     * Reserve kho cho toàn bộ item (KHÔNG ghi movement 'Reserved').
     */
    public void reserveStockForOrder(long orderId) throws SQLException {
        String q = "SELECT variant_id, quantity FROM order_items WHERE order_id=?";
        String upd = "UPDATE i SET reserved_quantity = ISNULL(i.reserved_quantity,0) + ?, "
                + "last_updated=DATEADD(HOUR,7,SYSUTCDATETIME()) "
                + "FROM inventory i WHERE i.variant_id=? AND (i.quantity - ISNULL(i.reserved_quantity,0)) >= ?";

        try ( Connection c = DBContext.getNewConnection()) {
            c.setAutoCommit(false);
            try ( PreparedStatement ps = c.prepareStatement(q)) {
                ps.setLong(1, orderId);
                try ( ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        long v = rs.getLong(1);
                        int qty = rs.getInt(2);

                        try ( PreparedStatement u = c.prepareStatement(upd)) {
                            u.setInt(1, qty);
                            u.setLong(2, v);
                            u.setInt(3, qty);
                            int rows = u.executeUpdate();
                            if (rows == 0) {
                                c.rollback();
                                throw new SQLException("Insufficient stock to reserve for variant " + v);
                            }
                        }
                    }
                }
            }
            c.commit();
        }
    }

    /**
     * Xuất kho khi staff hoàn tất (COMPLETED) — GHI movement 'Out' (số âm).
     */
    public void commitStockAfterPaid(long orderId) throws SQLException {
        String q = "SELECT variant_id, quantity FROM order_items WHERE order_id=?";
        String upd = "UPDATE i SET quantity = i.quantity - ?, reserved_quantity = ISNULL(i.reserved_quantity,0) - ?, "
                + "last_updated=DATEADD(HOUR,7,SYSUTCDATETIME()) "
                + "FROM inventory i WHERE i.variant_id=? AND i.quantity >= ? AND ISNULL(i.reserved_quantity,0) >= ?";

        String insMove = "INSERT INTO stock_movements "
                + "(variant_id, movement_type, quantity_changed, reference_type, reference_id, notes, created_at) "
                + "VALUES (?, 'Out', ?, 'Sale Order', ?, 'Ship/Invoice after payment', DATEADD(HOUR,7,SYSUTCDATETIME()))";

        try ( Connection c = DBContext.getNewConnection()) {
            c.setAutoCommit(false);
            try ( PreparedStatement ps = c.prepareStatement(q)) {
                ps.setLong(1, orderId);
                try ( ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        long v = rs.getLong(1);
                        int qty = rs.getInt(2);

                        try ( PreparedStatement u = c.prepareStatement(upd)) {
                            u.setInt(1, qty);
                            u.setInt(2, qty);
                            u.setLong(3, v);
                            u.setInt(4, qty);
                            u.setInt(5, qty);
                            u.executeUpdate();
                        }
                        try ( PreparedStatement sm = c.prepareStatement(insMove)) {
                            sm.setLong(1, v);
                            sm.setInt(2, -qty); // Out = số âm
                            sm.setLong(3, orderId);
                            sm.executeUpdate();
                        }
                    }
                }
            }
            c.commit();
        }
    }

    /**
     * Nhả giữ kho khi hủy/ thất bại (KHÔNG ghi movement 'Released').
     */
    public void releaseReservation(long orderId, String reason) throws SQLException {
        String q = "SELECT variant_id, quantity FROM order_items WHERE order_id=?";
        String upd = "UPDATE i SET reserved_quantity = CASE "
                + "WHEN ISNULL(i.reserved_quantity,0) >= ? THEN ISNULL(i.reserved_quantity,0) - ? "
                + "ELSE ISNULL(i.reserved_quantity,0) END, last_updated=DATEADD(HOUR,7,SYSUTCDATETIME()) "
                + "FROM inventory i WHERE i.variant_id=?";

        try ( Connection c = DBContext.getNewConnection()) {
            c.setAutoCommit(false);
            try ( PreparedStatement ps = c.prepareStatement(q)) {
                ps.setLong(1, orderId);
                try ( ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        long v = rs.getLong(1);
                        int qty = rs.getInt(2);

                        try ( PreparedStatement u = c.prepareStatement(upd)) {
                            u.setInt(1, qty);
                            u.setInt(2, qty);
                            u.setLong(3, v);
                            u.executeUpdate();
                        }
                    }
                }
            }
            c.commit();
        }
    }

    // ========= HỦY ĐƠN (KHÁCH) =========
    /**
     * Khách tự hủy đơn khi đang PENDING.
     *
     * @return 1 = UNPAID → CANCELED + release ngay 2 = PAID → CANCELED +
     * REFUND_PENDING (giữ reserve; nhả khi REFUNDED) 0 = không hủy được
     */
    public int cancelPendingByCustomer(long orderId, long customerId, String reason) throws SQLException {
        String sel = "SELECT status, payment_status FROM orders WHERE order_id=? AND customer_id=?";
        String updUnpaid = "UPDATE orders SET status='CANCELED', "
                + "notes = CONCAT(ISNULL(notes,''), CHAR(10), ?), "
                + "updated_at=DATEADD(HOUR,7,SYSUTCDATETIME()) "
                + "WHERE order_id=? AND customer_id=? AND status='PENDING' AND payment_status='UNPAID'";
        String updPaid = "UPDATE orders SET status='CANCELED', payment_status='REFUND_PENDING', "
                + "notes = CONCAT(ISNULL(notes,''), CHAR(10), ?), "
                + "updated_at=DATEADD(HOUR,7,SYSUTCDATETIME()) "
                + "WHERE order_id=? AND customer_id=? AND status='PENDING' AND payment_status='PAID'";

        try ( Connection c = DBContext.getNewConnection()) {
            c.setAutoCommit(false);

            String st = null, pst = null;
            try ( PreparedStatement ps = c.prepareStatement(sel)) {
                ps.setLong(1, orderId);
                ps.setLong(2, customerId);
                try ( ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        st = rs.getString(1);
                        pst = rs.getString(2);
                    } else {
                        c.rollback();
                        return 0;
                    }
                }
            }

            if (!"PENDING".equalsIgnoreCase(st)) {
                c.rollback();
                return 0;
            }

            int result = 0;
            if ("UNPAID".equalsIgnoreCase(pst)) {
                try ( PreparedStatement pu = c.prepareStatement(updUnpaid)) {
                    pu.setString(1, "[CUSTOMER CANCEL] " + (reason == null ? "" : reason));
                    pu.setLong(2, orderId);
                    pu.setLong(3, customerId);
                    if (pu.executeUpdate() > 0) {
                        result = 1;
                    }
                }
            } else if ("PAID".equalsIgnoreCase(pst)) {
                try ( PreparedStatement pu = c.prepareStatement(updPaid)) {
                    pu.setString(1, "[CUSTOMER CANCEL - REFUND REQUESTED] " + (reason == null ? "" : reason));
                    pu.setLong(2, orderId);
                    pu.setLong(3, customerId);
                    if (pu.executeUpdate() > 0) {
                        result = 2;
                    }
                }
            } else {
                c.rollback();
                return 0;
            }

            if (result == 0) {
                c.rollback();
                return 0;
            }

            c.commit();

            // Chỉ nhả khi UNPAID; PAID->REFUND_PENDING giữ reserve, sẽ nhả khi markRefundedByStaff()
            if (result == 1) {
                releaseReservation(orderId, "Release after customer cancel (UNPAID)");
            }
            return result;
        }
    }

    // ===================== CÁC HÀM MỚI CHO STAFF =====================
    // ===================== STAFF LIST (hide DRAFT; hide UNPAID/FAILED) =====================
    public List<model.OrderHeader> listOrdersForStaff(String q, String status, String pay, int offset, int limit)
            throws SQLException {

        StringBuilder sb = new StringBuilder();
        sb.append("SELECT o.order_id, o.customer_id, o.total_price, o.status, o.payment_status, o.created_at, ")
                .append("       COUNT(oi.order_item_id) AS item_count ")
                .append("FROM orders o ")
                .append("LEFT JOIN order_items oi ON oi.order_id = o.order_id ")
                .append("LEFT JOIN addresses a ON o.shipping_address_id = a.address_id ")
                .append("WHERE 1=1 ")
                .append("  AND o.status <> 'DRAFT' ")
                .append("  AND o.payment_status NOT IN ('UNPAID','FAILED') ");

        List<Object> params = new ArrayList<>();

        if (q != null && !q.trim().isEmpty()) {
            String like = "%" + q.trim() + "%";
            sb.append(" AND (CAST(o.order_id AS NVARCHAR(50)) LIKE ? ")
                    .append("  OR a.recipient_name LIKE ? ")
                    .append("  OR a.phone_number LIKE ?) ");
            params.add(like);
            params.add(like);
            params.add(like);
        }
        if (status != null && !status.trim().isEmpty() && !"all".equalsIgnoreCase(status)) {
            sb.append(" AND o.status = ? ");
            params.add(status.trim());
        }
        if (pay != null && !pay.trim().isEmpty() && !"all".equalsIgnoreCase(pay)) {
            sb.append(" AND o.payment_status = ? ");
            params.add(pay.trim());
        }

        sb.append(" GROUP BY o.order_id, o.customer_id, o.total_price, o.status, o.payment_status, o.created_at ")
                .append(" ORDER BY o.created_at DESC ")
                .append(" OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        List<model.OrderHeader> out = new ArrayList<>();
        try ( Connection c = DBContext.getNewConnection();  PreparedStatement ps = c.prepareStatement(sb.toString())) {
            int i = 1;
            for (Object p : params) {
                ps.setObject(i++, p);
            }
            ps.setInt(i++, Math.max(0, offset));
            ps.setInt(i, Math.max(1, limit));

            try ( ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    model.OrderHeader h = new model.OrderHeader();
                    h.setOrderId(rs.getLong("order_id"));
                    h.setCustomerId(rs.getLong("customer_id"));
                    h.setTotalPrice(rs.getBigDecimal("total_price"));
                    h.setStatus(rs.getString("status"));
                    h.setPaymentStatus(rs.getString("payment_status"));
                    h.setCreatedAt(rs.getTimestamp("created_at"));
                    h.setItemCount(rs.getInt("item_count"));
                    out.add(h);
                }
            }
        }
        return out;
    }

    public int countOrdersForStaff(String q, String status, String pay) throws SQLException {
        StringBuilder sb = new StringBuilder();
        sb.append("SELECT COUNT(DISTINCT o.order_id) ")
                .append("FROM orders o ")
                .append("LEFT JOIN addresses a ON o.shipping_address_id = a.address_id ")
                .append("WHERE 1=1 ")
                .append("  AND o.status <> 'DRAFT' ")
                .append("  AND o.payment_status NOT IN ('UNPAID','FAILED') ");

        List<Object> params = new ArrayList<>();

        if (q != null && !q.trim().isEmpty()) {
            String like = "%" + q.trim() + "%";
            sb.append(" AND (CAST(o.order_id AS NVARCHAR(50)) LIKE ? ")
                    .append("  OR a.recipient_name LIKE ? ")
                    .append("  OR a.phone_number LIKE ?) ");
            params.add(like);
            params.add(like);
            params.add(like);
        }
        if (status != null && !status.trim().isEmpty() && !"all".equalsIgnoreCase(status)) {
            sb.append(" AND o.status = ? ");
            params.add(status.trim());
        }
        if (pay != null && !pay.trim().isEmpty() && !"all".equalsIgnoreCase(pay)) {
            sb.append(" AND o.payment_status = ? ");
            params.add(pay.trim());
        }

        try ( Connection c = DBContext.getNewConnection();  PreparedStatement ps = c.prepareStatement(sb.toString())) {
            int i = 1;
            for (Object p : params) {
                ps.setObject(i++, p);
            }
            try ( ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    /**
     * Staff: xem header chi tiết không ràng buộc customer
     */
    public model.OrderHeader findOrderHeaderForStaff(long orderId) throws SQLException {
        String sql = "SELECT o.order_id, o.customer_id, o.shipping_address_id, o.voucher_id, "
                + "       o.subtotal, o.discount_amount, o.shipping_fee, o.total_price, "
                + "       o.status, o.payment_status, o.notes, o.created_at, o.updated_at, "
                + "       a.recipient_name, a.phone_number, a.street_address, "
                + "       w.name AS ward_name, p.name AS province_name "
                + "FROM orders o "
                + "LEFT JOIN addresses a ON o.shipping_address_id = a.address_id "
                + "LEFT JOIN wards w ON a.ward_id = w.ward_id "
                + "LEFT JOIN provinces p ON a.province_id = p.province_id "
                + "WHERE o.order_id = ?";
        try ( Connection c = DBContext.getNewConnection();  PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, orderId);
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    model.OrderHeader h = new model.OrderHeader();
                    h.setOrderId(rs.getLong("order_id"));
                    h.setCustomerId(rs.getLong("customer_id"));
                    long addr = rs.getLong("shipping_address_id");
                    h.setShippingAddressId(rs.wasNull() ? null : addr);
                    long vid = rs.getLong("voucher_id");
                    h.setVoucherId(rs.wasNull() ? null : vid);
                    h.setSubtotal(rs.getBigDecimal("subtotal"));
                    h.setDiscountAmount(rs.getBigDecimal("discount_amount"));
                    h.setShippingFee(rs.getBigDecimal("shipping_fee"));
                    h.setTotalPrice(rs.getBigDecimal("total_price"));
                    h.setStatus(rs.getString("status"));
                    h.setPaymentStatus(rs.getString("payment_status"));
                    h.setNotes(rs.getString("notes"));
                    h.setCreatedAt(rs.getTimestamp("created_at"));
                    h.setUpdatedAt(rs.getTimestamp("updated_at"));
                    h.setRecipientName(rs.getString("recipient_name"));
                    h.setPhoneNumber(rs.getString("phone_number"));
                    h.setStreetAddress(rs.getString("street_address"));
                    h.setWardName(rs.getString("ward_name"));
                    h.setProvinceName(rs.getString("province_name"));
                    return h;
                }
            }
        }
        return null;
    }

    /**
     * Quy tắc chuyển trạng thái cho staff (one-way).
     */
    public void updateStatusByStaff(long orderId, String newStatus) throws SQLException {
        final String sel = "SELECT status, payment_status FROM orders WHERE order_id=?";
        final String updStatusOnly = "UPDATE orders SET status=?, "
                + "notes = CONCAT(ISNULL(notes,''), CHAR(10), ?), "
                + "updated_at=DATEADD(HOUR,7,SYSUTCDATETIME()) WHERE order_id=?";

        String cur, pay;

        try ( Connection c = DBContext.getNewConnection()) {
            c.setAutoCommit(false);

            // Đọc trạng thái hiện tại
            try ( PreparedStatement ps = c.prepareStatement(sel)) {
                ps.setLong(1, orderId);
                try ( ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        c.rollback();
                        throw new SQLException("Order not found");
                    }
                    cur = rs.getString(1);
                    pay = rs.getString(2);
                }
            }

            // Đơn đã bị cancel (do customer) => KHÓA status
            if ("CANCELED".equalsIgnoreCase(cur)) {
                c.rollback();
                throw new SQLException("Order was canceled by customer. Status is locked. You can only update payment to REFUNDED.");
            }

            String ns = (newStatus == null ? "" : newStatus.trim().toUpperCase());
            if (ns.isEmpty() || ns.equalsIgnoreCase(cur)) {
                c.rollback();
                throw new SQLException("Invalid or duplicate status change.");
            }
            if ("CANCELED".equalsIgnoreCase(ns)) {
                c.rollback();
                throw new SQLException("Staff is not allowed to cancel orders.");
            }

            // Luồng hợp lệ “chỉ tiến lên”
            boolean ok = false;
            String note = "[STAFF] Set status to " + ns;

            if ("PENDING".equalsIgnoreCase(cur)) {
                if ("PROCESSING".equals(ns)) {
                    ok = true;
                } else if ("SHIPPED".equals(ns)) {
                    if (!"PAID".equalsIgnoreCase(pay)) {
                        c.rollback();
                        throw new SQLException("Cannot SHIP an unpaid order.");
                    }
                    ok = true;
                }
            } else if ("PROCESSING".equalsIgnoreCase(cur)) {
                if ("SHIPPED".equals(ns)) {
                    if (!"PAID".equalsIgnoreCase(pay)) {
                        c.rollback();
                        throw new SQLException("Cannot SHIP an unpaid order.");
                    }
                    ok = true;
                }
            } else if ("SHIPPED".equalsIgnoreCase(cur)) {
                if ("COMPLETED".equals(ns)) {
                    ok = true;
                }
            } else if ("COMPLETED".equalsIgnoreCase(cur)) {
                c.rollback();
                throw new SQLException("Completed order cannot change status.");
            } else if ("DRAFT".equalsIgnoreCase(cur)) {
                c.rollback();
                throw new SQLException("Draft order is not manageable here.");
            }

            if (!ok) {
                c.rollback();
                throw new SQLException("Invalid transition from " + cur + " -> " + ns);
            }

            // Cập nhật
            try ( PreparedStatement pu = c.prepareStatement(updStatusOnly)) {
                pu.setString(1, ns);
                pu.setString(2, note);
                pu.setLong(3, orderId);
                pu.executeUpdate();
            }

            c.commit();
        }

        // Hậu xử lý kho khi COMPLETED
        if ("COMPLETED".equalsIgnoreCase(newStatus)) {
            commitStockAfterPaid(orderId);
        }
    }

    /**
     * Staff: đánh dấu REFUND_PENDING (khi đã PAID)
     */
    public void markRefundPendingByStaff(long orderId, String reason) throws SQLException {
        String sql = "UPDATE orders SET payment_status='REFUND_PENDING', "
                + "notes = CONCAT(ISNULL(notes,''), CHAR(10), ?), "
                + "updated_at=DATEADD(HOUR,7,SYSUTCDATETIME()) "
                + "WHERE order_id=? AND payment_status='PAID'";
        try ( Connection c = DBContext.getNewConnection();  PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, "[STAFF] " + (reason == null ? "REFUND_PENDING" : reason));
            ps.setLong(2, orderId);
            ps.executeUpdate();
        }
    }

    /**
     * Staff: đánh dấu REFUNDED chỉ khi đơn đã CANCELED (do customer) và đang
     * REFUND_PENDING). Khi chuyển sang REFUNDED → nhả reserve (KHÔNG log).
     */
    public void markRefundedByStaff(long orderId, String reason) throws SQLException {
        String sql = "UPDATE orders SET payment_status='REFUNDED', "
                + "notes = CONCAT(ISNULL(notes,''), CHAR(10), ?), "
                + "updated_at=DATEADD(HOUR,7,SYSUTCDATETIME()) "
                + "WHERE order_id=? AND status='CANCELED' AND payment_status IN ('REFUND_PENDING')";
        try ( Connection c = DBContext.getNewConnection();  PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, "[STAFF] " + (reason == null ? "REFUNDED" : reason));
            ps.setLong(2, orderId);
            ps.executeUpdate();
        }
        releaseReservation(orderId, "Release after REFUNDED");
    }

    public static List<String> getAllowedNextStatusesForStaff(String current, String payment) {
        List<String> next = new ArrayList<>();
        String cur = current == null ? "" : current.toUpperCase();
        String pay = payment == null ? "" : payment.toUpperCase();

        if ("CANCELED".equals(cur) || "COMPLETED".equals(cur) || "DRAFT".equals(cur)) {
            return next; // locked
        }
        if ("PENDING".equals(cur)) {
            next.add("PROCESSING");
            if ("PAID".equals(pay)) {
                next.add("SHIPPED");
            }
        } else if ("PROCESSING".equals(cur)) {
            if ("PAID".equals(pay)) {
                next.add("SHIPPED");
            }
        } else if ("SHIPPED".equals(cur)) {
            next.add("COMPLETED");
        }
        return next;
    }
}
