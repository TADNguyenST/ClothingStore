package dao;

import model.ProductFavorite;
import util.DBContext;

import java.sql.*;
import java.util.*;

public class ProductFavoriteDAO {

    // Lấy danh sách wishlist của người dùng
    public List<ProductFavorite> getWishlistByUserId(long customerId) {
        List<ProductFavorite> list = new ArrayList<>();
        String sql = "SELECT * FROM product_favorites WHERE customer_id = ?";

        try ( Connection conn = new DBContext().getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, customerId);
            try ( ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductFavorite pf = new ProductFavorite();
                    pf.setId(rs.getInt("favorite_id"));
                    pf.setCustomerId(rs.getLong("customer_id"));
                    pf.setProductId(rs.getInt("product_id"));
                    pf.setDateAdded(rs.getTimestamp("date_added"));
                    pf.setActive(rs.getBoolean("is_active"));
                    list.add(pf);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in getWishlistByUserId: " + e.getMessage());
            e.printStackTrace();
        }

        return list;
    }

    // Kiểm tra sản phẩm đã có trong wishlist chưa
    public boolean isProductInWishlist(long customerId, int productId) {
        String sql = "SELECT 1 FROM product_favorites WHERE customer_id = ? AND product_id = ?";
        try ( Connection conn = new DBContext().getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, customerId);
            ps.setInt(2, productId);

            try ( ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            System.err.println("Error in isProductInWishlist: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    // Thêm sản phẩm vào wishlist
    public void addToWishlist(ProductFavorite pf) {
        if (pf == null || pf.getCustomerId() == 0 || pf.getProductId() == 0) {
            System.err.println("Invalid ProductFavorite object: " + pf);
            return;
        }

        if (isProductInWishlist(pf.getCustomerId(), pf.getProductId())) {
            System.out.println("Product already in wishlist, skipping insert.");
            return;
        }

        String sql = "INSERT INTO product_favorites (customer_id, product_id, date_added, is_active) VALUES (?, ?, GETDATE(), 1)";
        try ( Connection conn = new DBContext().getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, pf.getCustomerId());
            ps.setInt(2, pf.getProductId());
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("Error in addToWishlist: " + e.getMessage());
            e.printStackTrace();
        }
    }

    // Xoá sản phẩm khỏi wishlist
    public void deleteFromWishlist(long customerId, int productId) {
        String sql = "DELETE FROM product_favorites WHERE customer_id = ? AND product_id = ?";
        try ( Connection conn = new DBContext().getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, customerId);
            ps.setInt(2, productId);
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("Error in deleteFromWishlist: " + e.getMessage());
            e.printStackTrace();
        }
    }

    // Trả về danh sách ID các sản phẩm yêu thích
    public Set<Integer> getWishlistProductIds(long customerId) {
        Set<Integer> ids = new HashSet<>();
        String sql = "SELECT product_id FROM product_favorites WHERE customer_id = ?";

        try ( Connection conn = new DBContext().getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, customerId);
            try ( ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ids.add(rs.getInt("product_id"));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in getWishlistProductIds: " + e.getMessage());
            e.printStackTrace();
        }

        return ids;
    }
}
