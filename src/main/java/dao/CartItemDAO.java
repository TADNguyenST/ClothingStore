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
            LOGGER.log(Level.SEVERE, "Error retrieving cart items for customerId: {0}", customerId);
            ex.printStackTrace();
            throw new RuntimeException("Failed to retrieve cart items", ex);
        }
        return cartItems;
    }

    public CartItem findCartItem(long customerId, long cartItemId) {
        String sql = "SELECT ci.cart_item_id, ci.customer_id, ci.variant_id, ci.quantity, ci.date_added "
                + "FROM cart_items ci WHERE ci.customer_id = ? AND ci.cart_item_id = ?";
        try ( Connection conn = DBContext.getNewConnection()) {
            if (conn == null) {
                LOGGER.log(Level.SEVERE, "Database connection is null for customerId: " + customerId + ", cartItemId: " + cartItemId, new SQLException("Failed to establish database connection"));
                throw new SQLException("Failed to establish database connection");
            }
            try ( PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setLong(1, customerId);
                ps.setLong(2, cartItemId);
                try ( ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        CartItem item = new CartItem();
                        item.setCartItemId(rs.getLong("cart_item_id"));
                        item.setCustomerId(rs.getLong("customer_id"));
                        long variantId = rs.getLong("variant_id");
                        if (rs.wasNull()) {
                            LOGGER.warning("variant_id is NULL for cartItemId: " + cartItemId + ", customerId: " + customerId);
                            item.setVariantId(0L); // Gán giá trị mặc định nếu NULL
                        } else {
                            item.setVariantId(variantId);
                        }
                        item.setQuantity(rs.getInt("quantity"));
                        item.setDateAdded(rs.getTimestamp("date_added"));
                        LOGGER.log(Level.INFO, "Found cart item with ID: {0} for customerId: {1}, variantId: {2}",
                                new Object[]{cartItemId, customerId, item.getVariantId()});
                        return item;
                    } else {
                        LOGGER.warning("No cart item found with ID: " + cartItemId + " for customerId: " + customerId);
                        return null;
                    }
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error finding cart item with ID: " + cartItemId + " for customerId: " + customerId, ex);
            throw new RuntimeException("Failed to find cart item", ex);
        }
    }

    public void addToCart(long customerId, long variantId, int quantity) {
        if (quantity <= 0) {
            LOGGER.log(Level.WARNING, "Invalid quantity: {0} for customerId: {1}, variantId: {2}", new Object[]{quantity, customerId, variantId});
            throw new IllegalArgumentException("Quantity must be greater than 0");
        }
        int availableQuantity = productDAO.getAvailableQuantityByVariantId(variantId);
        if (availableQuantity < 0 || quantity > availableQuantity) {
            LOGGER.log(Level.WARNING, "Requested quantity {0} exceeds available stock {1} for variantId: {2}", new Object[]{quantity, availableQuantity, variantId});
            throw new IllegalArgumentException("Requested quantity exceeds available stock: " + availableQuantity);
        }

        CartItem existingItem = findCartItem(customerId, -1); // Tạm thời, cần sửa logic tìm kiếm
        if (existingItem != null) {
            int newQuantity = existingItem.getQuantity() + quantity;
            if (newQuantity > availableQuantity) {
                LOGGER.log(Level.WARNING, "Total quantity {0} exceeds available stock {1} for variantId: {2}", new Object[]{newQuantity, availableQuantity, variantId});
                throw new IllegalArgumentException("Total quantity exceeds available stock");
            }
            updateQuantity(existingItem.getCartItemId(), newQuantity);
        } else {
            String sql = "INSERT INTO cart_items (customer_id, variant_id, quantity, date_added) VALUES (?, ?, ?, GETDATE())";
            try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setLong(1, customerId);
                ps.setLong(2, variantId);
                ps.setInt(3, quantity);
                int rowsAffected = ps.executeUpdate();
                LOGGER.log(Level.INFO, "Inserted {0} rows into cart_items for customerId: {1}, variantId: {2}", new Object[]{rowsAffected, customerId, variantId});
            } catch (SQLException ex) {
                LOGGER.log(Level.SEVERE, "Error adding to cart for customerId: {0}, variantId: {1}", new Object[]{customerId, variantId});
                throw new RuntimeException("Failed to add to cart", ex);
            }
        }
    }

    public void updateQuantity(long cartItemId, int newQuantity) {
        if (newQuantity <= 0) {
            removeFromCart(cartItemId);
            LOGGER.log(Level.INFO, "Removed cart item with ID: {0} due to quantity <= 0", cartItemId);
            return;
        }
        CartItem item = findCartItem(0, cartItemId); // Sửa lại logic tìm kiếm
        if (item == null) {
            LOGGER.log(Level.WARNING, "Cart item not found for ID: {0}", cartItemId);
            throw new IllegalArgumentException("Cart item not found");
        }
        int availableQuantity = productDAO.getAvailableQuantityByVariantId(item.getVariantId());
        if (availableQuantity < 0 || newQuantity > availableQuantity) {
            LOGGER.log(Level.WARNING, "Requested quantity {0} exceeds available stock {1} for variantId: {2}", new Object[]{newQuantity, availableQuantity, item.getVariantId()});
            throw new IllegalArgumentException("Requested quantity exceeds available stock");
        }

        String sql = "UPDATE cart_items SET quantity = ?, date_added = GETDATE() WHERE cart_item_id = ?";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, newQuantity);
            ps.setLong(2, cartItemId);
            int rowsAffected = ps.executeUpdate();
            LOGGER.log(Level.INFO, "Updated {0} rows in cart_items for cartItemId: {1}", new Object[]{rowsAffected, cartItemId});
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error updating quantity for cartItemId: {0}", cartItemId);
            throw new RuntimeException("Failed to update cart item quantity", ex);
        }
    }

    public void removeFromCart(long cartItemId) {
        String sql = "DELETE FROM cart_items WHERE cart_item_id = ?";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, cartItemId);
            int rowsAffected = ps.executeUpdate();
            LOGGER.log(Level.INFO, "Deleted {0} rows from cart_items for cartItemId: {1}", new Object[]{rowsAffected, cartItemId});
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error removing cart item with ID: {0}", cartItemId);
            throw new RuntimeException("Failed to remove cart item", ex);
        }
    }

    public int getCartItemCount(long customerId) {
        String sql = "SELECT COUNT(*) FROM cart_items WHERE customer_id = ?";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, customerId);
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int count = rs.getInt(1);
                    LOGGER.log(Level.INFO, "Counted {0} cart items for customerId: {1}", new Object[]{count, customerId});
                    return count;
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error counting cart items for customerId: {0}", customerId);
            throw new RuntimeException("Failed to count cart items", ex);
        }
        return 0;
    }
}
