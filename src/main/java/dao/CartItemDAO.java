package dao;

import java.math.BigDecimal;
import model.CartItem;
import util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class CartItemDAO {

    private static final Logger LOGGER = Logger.getLogger(CartItemDAO.class.getName());
    private final ProductDAO productDAO = new ProductDAO();

    public List<CartItem> getCartItemsByCustomerId(long customerId) {
        List<CartItem> cartItems = new ArrayList<>();
        String sql = "SELECT ci.cart_item_id, ci.customer_id, ci.variant_id, ci.quantity, ci.date_added, "
                + "p.name AS product_name, pv.size, pv.color, pv.sku, "
                + "COALESCE(p.price + ISNULL(pv.price_modifier, 0), p.price) AS unit_price, "
                + "(SELECT TOP 1 pi.image_url FROM product_images pi WHERE pi.product_id = p.product_id AND pi.is_main = 1) AS product_image_url "
                + "FROM cart_items ci "
                + "JOIN product_variants pv ON ci.variant_id = pv.variant_id "
                + "JOIN products p ON pv.product_id = p.product_id "
                + "WHERE ci.customer_id = ? AND p.status = 'Active' "
                + "ORDER BY ci.date_added DESC";

        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, customerId);
            try ( ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CartItem item = new CartItem();
                    item.setCartItemId(rs.getLong("cart_item_id"));
                    item.setCustomerId(rs.getLong("customer_id"));
                    item.setVariantId(rs.getLong("variant_id"));
                    item.setQuantity(rs.getInt("quantity"));
                    item.setDateAdded(rs.getTimestamp("date_added"));
                    item.setProductName(rs.getString("product_name"));
                    item.setProductImageUrl(rs.getString("product_image_url"));
                    item.setSize(rs.getString("size"));
                    item.setColor(rs.getString("color"));
                    item.setSku(rs.getString("sku"));
                    BigDecimal unitPrice = rs.getBigDecimal("unit_price");
                    item.setUnitPrice(unitPrice != null ? unitPrice : BigDecimal.ZERO);
                    cartItems.add(item);
                }
                LOGGER.log(Level.INFO, "Retrieved {0} cart items for customerId: {1}", new Object[]{cartItems.size(), customerId});
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error retrieving cart items for customerId: " + customerId, ex);
            throw new RuntimeException("Failed to retrieve cart items", ex);
        }
        return cartItems;
    }

    public CartItem findCartItem(long customerId, long cartItemId) {
        String sql = "SELECT ci.cart_item_id, ci.customer_id, ci.variant_id, ci.quantity, ci.date_added, "
                + "COALESCE(p.price + ISNULL(pv.price_modifier, 0), p.price) AS unit_price "
                + "FROM cart_items ci "
                + "JOIN product_variants pv ON ci.variant_id = pv.variant_id "
                + "JOIN products p ON pv.product_id = p.product_id "
                + "WHERE ci.customer_id = ? AND ci.cart_item_id = ?";

        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, customerId);
            ps.setLong(2, cartItemId);
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    CartItem item = new CartItem();
                    item.setCartItemId(rs.getLong("cart_item_id"));
                    item.setCustomerId(rs.getLong("customer_id"));
                    long variantId = rs.getLong("variant_id");
                    item.setVariantId(variantId);
                    item.setQuantity(rs.getInt("quantity"));
                    item.setDateAdded(rs.getTimestamp("date_added"));
                    BigDecimal unitPrice = rs.getBigDecimal("unit_price");
                    item.setUnitPrice(unitPrice != null ? unitPrice : BigDecimal.ZERO);
                    LOGGER.log(Level.INFO, "Found cart item with ID: {0} for customerId: {1}, variantId: {2}",
                            new Object[]{cartItemId, customerId, item.getVariantId()});
                    return item;
                } else {
                    LOGGER.warning("No cart item found with ID: " + cartItemId + " for customerId: " + customerId);
                    return null;
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error finding cart item with ID: " + cartItemId + " for customerId: " + customerId, ex);
            throw new RuntimeException("Failed to find cart item", ex);
        }
    }

    public CartItem findCartItemByVariantId(long customerId, long variantId) {
        String sql = "SELECT ci.cart_item_id, ci.customer_id, ci.variant_id, ci.quantity, ci.date_added, "
                + "COALESCE(p.price + ISNULL(pv.price_modifier, 0), p.price) AS unit_price "
                + "FROM cart_items ci "
                + "JOIN product_variants pv ON ci.variant_id = pv.variant_id "
                + "JOIN products p ON pv.product_id = p.product_id "
                + "WHERE ci.customer_id = ? AND ci.variant_id = ?";

        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, customerId);
            ps.setLong(2, variantId);
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    CartItem item = new CartItem();
                    item.setCartItemId(rs.getLong("cart_item_id"));
                    item.setCustomerId(rs.getLong("customer_id"));
                    item.setVariantId(rs.getLong("variant_id"));
                    item.setQuantity(rs.getInt("quantity"));
                    item.setDateAdded(rs.getTimestamp("date_added"));
                    BigDecimal unitPrice = rs.getBigDecimal("unit_price");
                    item.setUnitPrice(unitPrice != null ? unitPrice : BigDecimal.ZERO);
                    LOGGER.log(Level.INFO, "Found cart item for customerId: {0}, variantId: {1}", new Object[]{customerId, variantId});
                    return item;
                }
                return null;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error finding cart item for customerId: {0}, variantId: {1}", new Object[]{customerId, variantId});
            throw new RuntimeException("Failed to find cart item", ex);
        }
    }

    public void addToCart(long customerId, long variantId, int quantity) {
        String selectSql = "SELECT cart_item_id, quantity FROM cart_items WHERE customer_id = ? AND variant_id = ?";
        String updateSql = "UPDATE cart_items SET quantity = quantity + ?, date_added = GETDATE() WHERE cart_item_id = ?";
        String insertSql = "INSERT INTO cart_items (customer_id, variant_id, quantity) VALUES (?, ?, ?)";

        try ( Connection conn = DBContext.getNewConnection()) {
            conn.setAutoCommit(false);
            try {
                // FIXED: Lock inventory row with UPDLOCK and check available
                int available = getAvailableQuantityWithLock(conn, variantId);
                if (available < quantity) {
                    throw new RuntimeException("Requested quantity exceeds available stock: " + available);
                }

                // Check if item already exists
                try ( PreparedStatement selectPs = conn.prepareStatement(selectSql)) {
                    selectPs.setLong(1, customerId);
                    selectPs.setLong(2, variantId);
                    try ( ResultSet rs = selectPs.executeQuery()) {
                        if (rs.next()) {
                            // Item exists, update quantity
                            long cartItemId = rs.getLong("cart_item_id");
                            try ( PreparedStatement updatePs = conn.prepareStatement(updateSql)) {
                                updatePs.setInt(1, quantity);
                                updatePs.setLong(2, cartItemId);
                                updatePs.executeUpdate();
                                LOGGER.log(Level.INFO, "Updated quantity to by {0} for cartItemId: {1}, customerId: {2}, variantId: {3}",
                                        new Object[]{quantity, cartItemId, customerId, variantId});
                            }
                        } else {
                            // Item doesn't exist, insert new
                            try ( PreparedStatement insertPs = conn.prepareStatement(insertSql)) {
                                insertPs.setLong(1, customerId);
                                insertPs.setLong(2, variantId);
                                insertPs.setInt(3, quantity);
                                int rowsAffected = insertPs.executeUpdate();
                                if (rowsAffected > 0) {
                                    LOGGER.log(Level.INFO, "Added new cart item for customerId: {0}, variantId: {1}, quantity: {2}",
                                            new Object[]{customerId, variantId, quantity});
                                } else {
                                    throw new SQLException("No rows affected when adding to cart");
                                }
                            }
                        }
                    }
                }

                // FIXED: Update reserved_quantity
                updateReservedQuantity(conn, variantId, quantity);

                conn.commit();
            } catch (Exception ex) {
                conn.rollback();
                LOGGER.log(Level.SEVERE, "Rollback addToCart for customerId: " + customerId + ", variantId: " + variantId, ex);
                throw new RuntimeException(ex.getMessage(), ex);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error adding to cart for customerId: " + customerId + ", variantId: " + variantId, ex);
            throw new RuntimeException(ex.getMessage(), ex);
        }
    }

    public void updateQuantity(long cartItemId, int newQuantity, long customerId) {
        try ( Connection conn = DBContext.getNewConnection()) {
            conn.setAutoCommit(false);
            try {
                CartItem item = findCartItem(customerId, cartItemId);
                if (item == null) {
                    throw new IllegalArgumentException("Cart item not found");
                }
                int oldQuantity = item.getQuantity();
                int delta = newQuantity - oldQuantity;

                if (newQuantity <= 0) {
                    // Remove item
                    String deleteSql = "DELETE FROM cart_items WHERE cart_item_id = ?";
                    try ( PreparedStatement deletePs = conn.prepareStatement(deleteSql)) {
                        deletePs.setLong(1, cartItemId);
                        deletePs.executeUpdate();
                    }
                    delta = -oldQuantity; // Release all
                    LOGGER.log(Level.INFO, "Removed cart item with ID: {0} due to quantity <= 0", cartItemId);
                } else {
                    if (delta > 0) {
                        // FIXED: Lock and check available for increase
                        int available = getAvailableQuantityWithLock(conn, item.getVariantId());
                        if (available < delta) {
                            throw new IllegalArgumentException("Requested quantity exceeds available stock: " + available);
                        }
                    }
                    // Update quantity
                    String updateSql = "UPDATE cart_items SET quantity = ?, date_added = GETDATE() WHERE cart_item_id = ?";
                    try ( PreparedStatement updatePs = conn.prepareStatement(updateSql)) {
                        updatePs.setInt(1, newQuantity);
                        updatePs.setLong(2, cartItemId);
                        updatePs.executeUpdate();
                        LOGGER.log(Level.INFO, "Updated quantity to {0} for cartItemId: {1}", new Object[]{newQuantity, cartItemId});
                    }
                }

                // FIXED: Update reserved_quantity if delta != 0
                if (delta != 0) {
                    updateReservedQuantity(conn, item.getVariantId(), delta);
                }

                conn.commit();
            } catch (Exception ex) {
                conn.rollback();
                LOGGER.log(Level.SEVERE, "Rollback updateQuantity for cartItemId: " + cartItemId, ex);
                throw new RuntimeException("Failed to update cart item quantity", ex);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error updating quantity for cartItemId: " + cartItemId, ex);
            throw new RuntimeException("Failed to update cart item quantity", ex);
        }
    }

    public void removeFromCart(long cartItemId) {
        try ( Connection conn = DBContext.getNewConnection()) {
            conn.setAutoCommit(false);
            try {
                // FIXED: Get variantId and quantity before delete
                String selectSql = "SELECT variant_id, quantity FROM cart_items WHERE cart_item_id = ?";
                int quantity = 0;
                long variantId = 0;
                try ( PreparedStatement selectPs = conn.prepareStatement(selectSql)) {
                    selectPs.setLong(1, cartItemId);
                    try ( ResultSet rs = selectPs.executeQuery()) {
                        if (rs.next()) {
                            variantId = rs.getLong("variant_id");
                            quantity = rs.getInt("quantity");
                        }
                    }
                }

                // Delete
                String deleteSql = "DELETE FROM cart_items WHERE cart_item_id = ?";
                try ( PreparedStatement deletePs = conn.prepareStatement(deleteSql)) {
                    deletePs.setLong(1, cartItemId);
                    int rowsAffected = deletePs.executeUpdate();
                    LOGGER.log(Level.INFO, "Deleted {0} rows from cart_items for cartItemId: {1}", new Object[]{rowsAffected, cartItemId});
                }

                // FIXED: Release reserved_quantity
                if (quantity > 0) {
                    updateReservedQuantity(conn, variantId, -quantity);
                }

                conn.commit();
            } catch (Exception ex) {
                conn.rollback();
                LOGGER.log(Level.SEVERE, "Rollback removeFromCart for cartItemId: " + cartItemId, ex);
                throw new RuntimeException("Failed to remove cart item", ex);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error removing cart item with ID: " + cartItemId, ex);
            throw new RuntimeException("Failed to remove cart item", ex);
        }
    }

    public int getCartItemCount(long customerId) {
        String sql = "SELECT SUM(quantity) FROM cart_items WHERE customer_id = ?";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, customerId);
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int count = rs.getInt(1);
                    LOGGER.log(Level.INFO, "Counted total quantity {0} for customerId: {1}", new Object[]{count, customerId});
                    return count > 0 ? count : 0;
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error counting cart items for customerId: " + customerId, ex);
            throw new RuntimeException("Failed to count cart items", ex);
        }
        return 0;
    }

    // FIXED: Helper to get available with lock (UPDLOCK)
    private int getAvailableQuantityWithLock(Connection conn, long variantId) throws SQLException {
        String sql = "SELECT quantity - reserved_quantity AS available FROM inventory WITH (UPDLOCK) WHERE variant_id = ?";
        try ( PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, variantId);
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("available");
                }
            }
        }
        return 0;
    }

    // FIXED: Helper to update reserved
    private void updateReservedQuantity(Connection conn, long variantId, int delta) throws SQLException {
        if (delta == 0) {
            return;
        }
        String sql = "UPDATE inventory SET reserved_quantity = reserved_quantity + ? WHERE variant_id = ?";
        try ( PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, delta);
            ps.setLong(2, variantId);
            int rows = ps.executeUpdate();
            if (rows == 0) {
                throw new SQLException("No inventory row found for variantId: " + variantId);
            }
            LOGGER.log(Level.INFO, "Updated reserved_quantity by {0} for variantId: {1}", new Object[]{delta, variantId});
        }
    }
}
