package dao;

import model.CartItem;
import util.DBContext;

import java.math.BigDecimal;
import java.sql.*;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.stream.Collectors;

public class CartItemDAO {

    private static final Logger LOGGER = Logger.getLogger(CartItemDAO.class.getName());

    /**
     * Thêm vào giỏ: kiểm tra kho, cộng dồn và chốt unit_price hiện tại
     */
    public boolean addToCart(long customerId, long variantId, int quantity) throws SQLException {
        String sqlAvailable = "SELECT ISNULL(quantity,0) - ISNULL(reserved_quantity,0) AS available FROM inventory WHERE variant_id = ?";
        String sqlExisting = "SELECT cart_item_id, quantity FROM cart_items WHERE customer_id = ? AND variant_id = ?";
        String sqlFinalPrice = "SELECT ISNULL(pv.price_modifier, p.price) AS final_price "
                + "FROM product_variants pv JOIN products p ON pv.product_id = p.product_id "
                + "WHERE pv.variant_id = ?";
        String sqlUpdate = "UPDATE cart_items SET quantity = ?, unit_price = ? WHERE cart_item_id = ?";
        String sqlInsert = "INSERT INTO cart_items (customer_id, variant_id, quantity, unit_price) VALUES (?, ?, ?, ?)";

        try ( Connection conn = DBContext.getNewConnection()) {
            conn.setAutoCommit(false);

            int available = 0;
            try ( PreparedStatement ps = conn.prepareStatement(sqlAvailable)) {
                ps.setLong(1, variantId);
                try ( ResultSet rs = ps.executeQuery()) {
                    available = rs.next() ? rs.getInt("available") : 0;
                }
            }

            long existingItemId = -1L;
            int existingQty = 0;
            try ( PreparedStatement ps = conn.prepareStatement(sqlExisting)) {
                ps.setLong(1, customerId);
                ps.setLong(2, variantId);
                try ( ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        existingItemId = rs.getLong("cart_item_id");
                        existingQty = rs.getInt("quantity");
                    }
                }
            }

            BigDecimal finalPrice = BigDecimal.ZERO;
            try ( PreparedStatement ps = conn.prepareStatement(sqlFinalPrice)) {
                ps.setLong(1, variantId);
                try ( ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        finalPrice = rs.getBigDecimal("final_price");
                        if (finalPrice == null) {
                            finalPrice = BigDecimal.ZERO;
                        }
                    }
                }
            }

            int newQty = Math.max(1, existingQty + quantity);
            if (available < newQty) {
                conn.rollback();
                return false;
            }

            if (existingItemId > 0) {
                try ( PreparedStatement ps = conn.prepareStatement(sqlUpdate)) {
                    ps.setInt(1, newQty);
                    ps.setBigDecimal(2, finalPrice);
                    ps.setLong(3, existingItemId);
                    boolean ok = ps.executeUpdate() > 0;
                    conn.commit();
                    return ok;
                }
            } else {
                try ( PreparedStatement ps = conn.prepareStatement(sqlInsert)) {
                    ps.setLong(1, customerId);
                    ps.setLong(2, variantId);
                    ps.setInt(3, newQty);
                    ps.setBigDecimal(4, finalPrice);
                    boolean ok = ps.executeUpdate() > 0;
                    conn.commit();
                    return ok;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error addToCart(customerId=" + customerId + ", variantId=" + variantId + ")", e);
            throw e;
        }
    }

    /**
     * ========== MỚI: Upsert cho BUY NOW ========== Đặt đúng số lượng (không
     * cộng dồn), chốt unit_price tại thời điểm bấm Buy Now. Trả về cart_item_id
     * của dòng được dùng cho checkout.
     */
    public long upsertForBuyNow(long customerId, long variantId, int quantity) throws SQLException {
        String sqlAvailable = "SELECT ISNULL(quantity,0) - ISNULL(reserved_quantity,0) AS available FROM inventory WHERE variant_id = ?";
        String sqlExisting = "SELECT cart_item_id FROM cart_items WHERE customer_id = ? AND variant_id = ?";
        String sqlFinalPrice = "SELECT ISNULL(pv.price_modifier, p.price) AS final_price "
                + "FROM product_variants pv JOIN products p ON pv.product_id = p.product_id WHERE pv.variant_id = ?";
        String sqlUpdate = "UPDATE cart_items SET quantity = ?, unit_price = ? WHERE cart_item_id = ?";
        String sqlInsert = "INSERT INTO cart_items (customer_id, variant_id, quantity, unit_price) VALUES (?, ?, ?, ?)";

        try ( Connection conn = DBContext.getNewConnection()) {
            conn.setAutoCommit(false);

            int available = 0;
            try ( PreparedStatement ps = conn.prepareStatement(sqlAvailable)) {
                ps.setLong(1, variantId);
                try ( ResultSet rs = ps.executeQuery()) {
                    available = rs.next() ? rs.getInt("available") : 0;
                }
            }
            if (available <= 0) {
                conn.rollback();
                throw new SQLException("Variant out of stock");
            }

            BigDecimal finalPrice = BigDecimal.ZERO;
            try ( PreparedStatement ps = conn.prepareStatement(sqlFinalPrice)) {
                ps.setLong(1, variantId);
                try ( ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        finalPrice = rs.getBigDecimal("final_price");
                        if (finalPrice == null) {
                            finalPrice = BigDecimal.ZERO;
                        }
                    }
                }
            }

            int qty = Math.max(1, Math.min(quantity, available));

            Long existingId = null;
            try ( PreparedStatement ps = conn.prepareStatement(sqlExisting)) {
                ps.setLong(1, customerId);
                ps.setLong(2, variantId);
                try ( ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        existingId = rs.getLong("cart_item_id");
                    }
                }
            }

            if (existingId != null) {
                try ( PreparedStatement ps = conn.prepareStatement(sqlUpdate)) {
                    ps.setInt(1, qty);
                    ps.setBigDecimal(2, finalPrice);
                    ps.setLong(3, existingId);
                    ps.executeUpdate();
                }
                conn.commit();
                return existingId;
            } else {
                try ( PreparedStatement ps = conn.prepareStatement(sqlInsert, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setLong(1, customerId);
                    ps.setLong(2, variantId);
                    ps.setInt(3, qty);
                    ps.setBigDecimal(4, finalPrice);
                    ps.executeUpdate();
                    try ( ResultSet rs = ps.getGeneratedKeys()) {
                        if (rs.next()) {
                            long id = rs.getLong(1);
                            conn.commit();
                            return id;
                        }
                    }
                }
                conn.rollback();
                throw new SQLException("Insert cart item failed");
            }
        }
    }

    /**
     * Lấy cart đầy đủ thông tin hiển thị
     */
    public List<CartItem> getCartItems(long customerId) throws SQLException {
        List<CartItem> list = new ArrayList<>();
        String sql
                = "SELECT ci.cart_item_id, ci.variant_id, ci.quantity, "
                + "       COALESCE(ci.unit_price, ISNULL(pv.price_modifier, p.price)) AS unit_price, "
                + "       p.product_id, p.name, pv.size, pv.color, "
                + "       (SELECT TOP 1 pi.image_url FROM product_images pi "
                + "        WHERE pi.variant_id = ci.variant_id "
                + "        ORDER BY pi.is_main DESC, pi.display_order ASC) AS variant_image_url, "
                + "       (SELECT TOP 1 pi.image_url FROM product_images pi "
                + "        WHERE pi.product_id = p.product_id AND pi.is_main = 1 "
                + "        ORDER BY pi.display_order ASC) AS product_image_url, "
                + "       ISNULL((SELECT i.quantity - i.reserved_quantity FROM inventory i WHERE i.variant_id = ci.variant_id), 0) AS available_stock "
                + "FROM cart_items ci "
                + "JOIN product_variants pv ON ci.variant_id = pv.variant_id "
                + "JOIN products p ON pv.product_id = p.product_id "
                + "WHERE ci.customer_id = ?";

        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, customerId);
            try ( ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CartItem item = new CartItem();
                    item.setCartItemId(rs.getLong("cart_item_id"));
                    item.setVariantId(rs.getLong("variant_id"));
                    item.setProductId(rs.getLong("product_id"));
                    item.setQuantity(rs.getInt("quantity"));
                    item.setUnitPrice(rs.getBigDecimal("unit_price"));
                    item.setProductName(rs.getString("name"));
                    item.setSize(rs.getString("size"));
                    item.setColor(rs.getString("color"));

                    String imgVariant = rs.getString("variant_image_url");
                    String imgProduct = rs.getString("product_image_url");
                    String imageUrl = (imgVariant != null && !imgVariant.trim().isEmpty()) ? imgVariant : imgProduct;
                    if (imageUrl != null && imageUrl.contains("/image/upload/")) {
                        imageUrl = imageUrl.replace("/image/upload/", "/image/upload/w_100,h_100,c_fill,f_auto,q_auto/");
                    } else if (imageUrl == null) {
                        imageUrl = "https://placehold.co/100x100/eee/333?text=No+Image";
                    }
                    item.setImageUrl(imageUrl);

                    item.setAvailableStock(rs.getInt("available_stock"));
                    list.add(item);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getCartItems(customerId=" + customerId + ")", e);
            throw e;
        }
        return list;
    }

    /**
     * Cập nhật số lượng (ràng buộc theo customer) + vá unit_price nếu NULL
     */
    public boolean updateCartItem(long cartItemId, long customerId, int quantity) throws SQLException {
        String sqlAvailable
                = "SELECT ISNULL(i.quantity,0) - ISNULL(i.reserved_quantity,0) AS available "
                + "FROM cart_items ci JOIN inventory i ON i.variant_id = ci.variant_id "
                + "WHERE ci.cart_item_id = ? AND ci.customer_id = ?";

        String sqlFinalPriceByItem
                = "SELECT ISNULL(pv.price_modifier, p.price) AS final_price "
                + "FROM cart_items ci "
                + "JOIN product_variants pv ON ci.variant_id = pv.variant_id "
                + "JOIN products p ON pv.product_id = p.product_id "
                + "WHERE ci.cart_item_id = ? AND ci.customer_id = ?";

        String sqlUpdate
                = "UPDATE cart_items SET quantity = ?, unit_price = ISNULL(unit_price, ?) "
                + "WHERE cart_item_id = ? AND customer_id = ?";

        try ( Connection conn = DBContext.getNewConnection()) {
            int available = 0;
            try ( PreparedStatement ps = conn.prepareStatement(sqlAvailable)) {
                ps.setLong(1, cartItemId);
                ps.setLong(2, customerId);
                try ( ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        available = rs.getInt("available");
                    } else {
                        return false;
                    }
                }
            }

            if (quantity < 1) {
                quantity = 1;
            }
            if (quantity > available) {
                LOGGER.warning("Insufficient stock update cartItemId=" + cartItemId + " to qty=" + quantity + ", available=" + available);
                return false;
            }

            BigDecimal finalPrice = BigDecimal.ZERO;
            try ( PreparedStatement ps = conn.prepareStatement(sqlFinalPriceByItem)) {
                ps.setLong(1, cartItemId);
                ps.setLong(2, customerId);
                try ( ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        finalPrice = rs.getBigDecimal("final_price");
                        if (finalPrice == null) {
                            finalPrice = BigDecimal.ZERO;
                        }
                    }
                }
            }

            try ( PreparedStatement ps = conn.prepareStatement(sqlUpdate)) {
                ps.setInt(1, quantity);
                ps.setBigDecimal(2, finalPrice);
                ps.setLong(3, cartItemId);
                ps.setLong(4, customerId);
                return ps.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updateCartItem(cartItemId=" + cartItemId + ", customerId=" + customerId + ")", e);
            throw e;
        }
    }

    /**
     * Xoá 1 dòng (ràng buộc theo customer)
     */
    public boolean removeCartItem(long cartItemId, long customerId) throws SQLException {
        String sql = "DELETE FROM cart_items WHERE cart_item_id = ? AND customer_id = ?";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, cartItemId);
            ps.setLong(2, customerId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error removeCartItem(cartItemId=" + cartItemId + ", customerId=" + customerId + ")", e);
            throw e;
        }
    }

    /**
     * Lấy customer_id từ users.user_id
     */
    public long getCustomerIdByUserId(long userId) throws SQLException {
        String sql = "SELECT customer_id FROM customers WHERE user_id = ?";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getLong("customer_id");
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getCustomerIdByUserId(userId=" + userId + ")", e);
            throw e;
        }
        throw new SQLException("Customer not found for userId: " + userId);
    }

    /**
     * Tổng số lượng item trong cart
     */
    public int getCartItemCount(long customerId) throws SQLException {
        String sql = "SELECT ISNULL(SUM(quantity),0) AS total_quantity FROM cart_items WHERE customer_id = ?";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, customerId);
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("total_quantity");
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getCartItemCount(customerId=" + customerId + ")", e);
            throw e;
        }
        return 0;
    }

    /* =================== TIỆN ÍCH CHO CHECKOUT =================== */
    /**
     * Lọc các dòng đã chọn theo danh sách cartItemIds
     */
    public List<CartItem> findSelectedForCustomer(long customerId, List<Long> cartItemIds) throws SQLException {
        if (cartItemIds == null || cartItemIds.isEmpty()) {
            return Collections.emptyList();
        }
        List<CartItem> all = getCartItems(customerId);
        Set<Long> wanted = new HashSet<>(cartItemIds);
        return all.stream().filter(ci -> wanted.contains(ci.getCartItemId())).collect(Collectors.toList());
    }

    /**
     * Xoá nhiều dòng – an toàn (vòng lặp).
     */
    public int removeMany(long customerId, List<Long> cartItemIds) throws SQLException {
        if (cartItemIds == null || cartItemIds.isEmpty()) {
            return 0;
        }
        int ok = 0;
        for (Long id : cartItemIds) {
            if (removeCartItem(id, customerId)) {
                ok++;
            }
        }
        return ok;
    }

    /**
     * Xoá nhiều dòng bulk bằng 1 câu SQL
     */
    public int removeManyBulk(long customerId, List<Long> cartItemIds) throws SQLException {
        if (cartItemIds == null || cartItemIds.isEmpty()) {
            return 0;
        }
        StringBuilder sb = new StringBuilder("DELETE FROM cart_items WHERE customer_id = ? AND cart_item_id IN (");
        for (int i = 0; i < cartItemIds.size(); i++) {
            if (i > 0) {
                sb.append(',');
            }
            sb.append('?');
        }
        sb.append(')');
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sb.toString())) {
            int idx = 1;
            ps.setLong(idx++, customerId);
            for (Long id : cartItemIds) {
                ps.setLong(idx++, id);
            }
            return ps.executeUpdate();
        }
    }

    /**
     * (MỚI) Lấy danh sách cart item theo list ID (phục vụ checkout)
     */
    public List<CartItem> getCartItemsByIds(long customerId, List<Long> ids) throws SQLException {
        if (ids == null || ids.isEmpty()) {
            return new ArrayList<>();
        }

        String placeholders = ids.stream().map(x -> "?").collect(Collectors.joining(","));
        String sql
                = "SELECT ci.cart_item_id, ci.variant_id, ci.quantity, "
                + "       COALESCE(ci.unit_price, ISNULL(pv.price_modifier, p.price)) AS unit_price, "
                + "       p.product_id, p.name, pv.size, pv.color, "
                + "       (SELECT TOP 1 pi.image_url FROM product_images pi "
                + "        WHERE pi.variant_id = ci.variant_id "
                + "        ORDER BY pi.is_main DESC, pi.display_order ASC) AS variant_image_url, "
                + "       (SELECT TOP 1 pi.image_url FROM product_images pi "
                + "        WHERE pi.product_id = p.product_id AND pi.is_main = 1 "
                + "        ORDER BY pi.display_order ASC) AS product_image_url, "
                + "       ISNULL((SELECT i.quantity - i.reserved_quantity FROM inventory i WHERE i.variant_id = ci.variant_id), 0) AS available_stock "
                + "FROM cart_items ci "
                + "JOIN product_variants pv ON ci.variant_id = pv.variant_id "
                + "JOIN products p ON pv.product_id = p.product_id "
                + "WHERE ci.customer_id = ? AND ci.cart_item_id IN (" + placeholders + ")";

        List<CartItem> list = new ArrayList<>();
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            int idx = 1;
            ps.setLong(idx++, customerId);
            for (Long id : ids) {
                ps.setLong(idx++, id);
            }

            try ( ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CartItem item = new CartItem();
                    item.setCartItemId(rs.getLong("cart_item_id"));
                    item.setVariantId(rs.getLong("variant_id"));
                    item.setProductId(rs.getLong("product_id"));
                    item.setQuantity(rs.getInt("quantity"));
                    item.setUnitPrice(rs.getBigDecimal("unit_price"));
                    item.setProductName(rs.getString("name"));
                    item.setSize(rs.getString("size"));
                    item.setColor(rs.getString("color"));

                    String imgVariant = rs.getString("variant_image_url");
                    String imgProduct = rs.getString("product_image_url");
                    String imageUrl = (imgVariant != null && !imgVariant.trim().isEmpty()) ? imgVariant : imgProduct;
                    if (imageUrl != null && imageUrl.contains("/image/upload/")) {
                        imageUrl = imageUrl.replace("/image/upload/", "/image/upload/w_100,h_100,c_fill,f_auto,q_auto/");
                    } else if (imageUrl == null) {
                        imageUrl = "https://placehold.co/100x100/eee/333?text=No+Image";
                    }
                    item.setImageUrl(imageUrl);

                    item.setAvailableStock(rs.getInt("available_stock"));
                    list.add(item);
                }
            }
        }
        return list;
    }
}
