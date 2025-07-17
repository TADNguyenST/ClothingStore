package dao;

import model.Brand;
import util.DBContext;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * @author DANGVUONGTHINH
 */
public class BrandDAO extends DBContext {

    // Lấy tất cả brands
    public List<Brand> getAll() {
        List<Brand> list = new ArrayList<>();
        String sql = "SELECT * FROM brands";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(new Brand(
                        rs.getLong("brand_id"),
                        rs.getString("name"),
                        rs.getString("description"),
                        rs.getString("logo_url"),
                        rs.getBoolean("is_active"),
                        rs.getTimestamp("created_at")
                ));
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Error fetching brands: " + e.getMessage());
        }
        return list;
    }

    // Thêm brand
    public void insertBrand(Brand brand) {
        // Kiểm tra trùng tên thương hiệu
        String checkSql = "SELECT COUNT(*) FROM brands WHERE LOWER(name) = LOWER(?)";
        try {
            PreparedStatement checkPs = conn.prepareStatement(checkSql);
            checkPs.setString(1, brand.getName().trim());
            ResultSet rs = checkPs.executeQuery();
            if (rs.next() && rs.getInt(1) > 0) {
                throw new IllegalArgumentException("Thương hiệu '" + brand.getName() + "' đã tồn tại.");
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi kiểm tra trùng tên thương hiệu: " + e.getMessage(), e);
        }

        String sql = "INSERT INTO brands (name, description, logo_url, is_active, created_at) VALUES (?, ?, ?, ?, ?)";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, brand.getName());
            ps.setString(2, brand.getDescription());
            ps.setString(3, brand.getLogoUrl());
            ps.setBoolean(4, brand.isActive());
            ps.setTimestamp(5, new Timestamp(brand.getCreatedAt().getTime()));
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi thêm thương hiệu: " + e.getMessage(), e);
        }
    }

    // Lấy brand theo ID
    public Brand getBrandById(Long brandId) {
        String sql = "SELECT * FROM brands WHERE brand_id = ?";
        Brand brand = null;

        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setLong(1, brandId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                brand = new Brand(
                        rs.getLong("brand_id"),
                        rs.getString("name"),
                        rs.getString("description"),
                        rs.getString("logo_url"),
                        rs.getBoolean("is_active"),
                        rs.getTimestamp("created_at")
                );
            }
            return brand;
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }
        return brand;
    }

    // Cập nhật brand
    public boolean updateBrand(Brand brand) {
        // Kiểm tra trùng tên thương hiệu
        String checkSql = "SELECT COUNT(*) FROM brands WHERE LOWER(name) = LOWER(?) AND brand_id != ?";
        try {
            PreparedStatement checkPs = conn.prepareStatement(checkSql);
            checkPs.setString(1, brand.getName().trim());
            checkPs.setLong(2, brand.getBrandId());
            ResultSet rs = checkPs.executeQuery();
            if (rs.next() && rs.getInt(1) > 0) {
                throw new IllegalArgumentException("Thương hiệu '" + brand.getName() + "' đã tồn tại.");
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi kiểm tra trùng tên thương hiệu: " + e.getMessage(), e);
        }

        String sql = "UPDATE brands SET name = ?, description = ?, logo_url = ?, is_active = ? WHERE brand_id = ?";
        boolean rowUpdated = false;

        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, brand.getName());
            ps.setString(2, brand.getDescription());
            ps.setString(3, brand.getLogoUrl());
            ps.setBoolean(4, brand.isActive());
            ps.setLong(5, brand.getBrandId());
            rowUpdated = ps.executeUpdate() > 0;
            return rowUpdated;
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }
        return rowUpdated;
    }

    // Xóa brand
    public boolean deleteBrand(Long brandId) {
        String checkSql = "SELECT COUNT(*) FROM products WHERE brand_id = ?";
        String sql = "DELETE FROM brands WHERE brand_id = ?";
        try {
            if (conn == null) {
                throw new SQLException("Database connection is null");
            }
            // Kiểm tra xem thương hiệu có được sử dụng bởi sản phẩm
            PreparedStatement psCheck = conn.prepareStatement(checkSql);
            psCheck.setLong(1, brandId);
            ResultSet rs = psCheck.executeQuery();
            if (rs.next() && rs.getInt(1) > 0) {
                throw new IllegalStateException("Không thể xóa thương hiệu: Thương hiệu đang được sử dụng bởi sản phẩm.");
            }

            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setLong(1, brandId);
            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi xóa thương hiệu: " + e.getMessage(), e);
        }
    }

    public static void main(String[] args) {
        BrandDAO brandDAO = new BrandDAO();
        List<Brand> brands = brandDAO.getAll();
        if (brands.isEmpty()) {
            System.out.println("No brands found!");
        } else {
            System.out.println("Brands retrieved from database:");
            for (Brand brand : brands) {
                System.out.printf("ID: %d, Name: %s, Description: %s, Logo URL: %s, Active: %b, Created At: %s%n",
                        brand.getBrandId(),
                        brand.getName(),
                        brand.getDescription() != null ? brand.getDescription() : "N/A",
                        brand.getLogoUrl() != null ? brand.getLogoUrl() : "N/A",
                        brand.isActive(),
                        brand.getCreatedAt());
            }
        }
    }
}