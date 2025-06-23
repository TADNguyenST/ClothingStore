/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

/**
 *
 * @author Lenovo
 */
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

    public List<CartItem> getCartItemsByCustomerId(long customerId) {
        List<CartItem> cartItems = new ArrayList<>();
        String sql = "SELECT "
                + "ci.cart_item_id, ci.customer_id, ci.variant_id, ci.quantity, ci.date_added, "
                + "p.name AS product_name, pv.size, pv.color, pv.sku, "
                + "(p.price + pv.price_modifier) AS unit_price, "
                + "(SELECT TOP 1 pi.image_url FROM product_images pi WHERE pi.product_id = p.product_id ORDER BY pi.display_order ASC) AS product_image_url "
                + "FROM cart_items ci "
                + "JOIN product_variants pv ON ci.variant_id = pv.variant_id "
                + "JOIN products p ON pv.product_id = p.product_id "
                + "WHERE ci.customer_id = ? "
                + "ORDER BY ci.date_added DESC";

        DBContext db = new DBContext();
        try ( Connection conn = db.getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {

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
                    item.setUnitPrice(rs.getBigDecimal("unit_price"));
                    cartItems.add(item);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(CartItemDAO.class.getName()).log(Level.SEVERE, "Lỗi khi lấy giỏ hàng", ex);
        }
        return cartItems;
    }

    /**
     * Tìm một item trong giỏ hàng dựa trên customerId và variantId.
     *
     * @return CartItem nếu tìm thấy, null nếu không.
     */
    private CartItem findCartItem(long customerId, long variantId) {
        String sql = "SELECT * FROM cart_items WHERE customer_id = ? AND variant_id = ?";
        DBContext db = new DBContext();
        try ( Connection conn = db.getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, customerId);
            ps.setLong(2, variantId);
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    CartItem item = new CartItem();
                    item.setCartItemId(rs.getLong("cart_item_id"));
                    item.setCustomerId(rs.getLong("customer_id"));
                    item.setVariantId(rs.getLong("variant_id"));
                    item.setQuantity(rs.getInt("quantity"));
                    return item;
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(CartItemDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return null;
    }

    /**
     * Thêm sản phẩm vào giỏ hàng.Nếu sản phẩm đã có, sẽ cộng dồn số lượng.Nếu
     * chưa có, sẽ tạo mới.
     *
     * @param customerId
     * @param variantId
     * @param quantity
     */
    public void addToCart(long customerId, long variantId, int quantity) {
        CartItem existingItem = findCartItem(customerId, variantId);

        if (existingItem != null) {
            // Nếu đã tồn tại, cộng dồn số lượng
            int newQuantity = existingItem.getQuantity() + quantity;
            updateQuantity(existingItem.getCartItemId(), newQuantity);
        } else {
            // Nếu chưa tồn tại, thêm mới
            String sql = "INSERT INTO cart_items (customer_id, variant_id, quantity) VALUES (?, ?, ?)";
            DBContext db = new DBContext();
            try ( Connection conn = db.getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setLong(1, customerId);
                ps.setLong(2, variantId);
                ps.setInt(3, quantity);
                ps.executeUpdate();
            } catch (SQLException ex) {
                Logger.getLogger(CartItemDAO.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
    }

    /**
     * Cập nhật số lượng cho một món hàng trong giỏ.
     *
     * @param cartItemId
     * @param newQuantity
     */
    public void updateQuantity(long cartItemId, int newQuantity) {
        String sql = "UPDATE cart_items SET quantity = ? WHERE cart_item_id = ?";
        DBContext db = new DBContext();
        try ( Connection conn = db.getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, newQuantity);
            ps.setLong(2, cartItemId);
            ps.executeUpdate();
        } catch (SQLException ex) {
            Logger.getLogger(CartItemDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    /**
     * Xóa một món hàng khỏi giỏ.
     *
     * @param cartItemId
     */
    public void removeFromCart(long cartItemId) {
        String sql = "DELETE FROM cart_items WHERE cart_item_id = ?";
        DBContext db = new DBContext();
        try ( Connection conn = db.getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, cartItemId);
            ps.executeUpdate();
        } catch (SQLException ex) {
            Logger.getLogger(CartItemDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    /**
     * Đếm số lượng loại sản phẩm trong giỏ hàng.
     *
     * @param customerId
     * @return
     */
    public int getCartItemCount(long customerId) {
        String sql = "SELECT COUNT(*) FROM cart_items WHERE customer_id = ?";
        DBContext db = new DBContext();
        try ( Connection conn = db.getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, customerId);
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(CartItemDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return 0;
    }
}
