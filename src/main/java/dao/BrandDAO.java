package dao;

import model.Brand;
import util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for Brand-related database operations.
 */
public class BrandDAO {

    public List<Brand> getAll() {
        List<Brand> list = new ArrayList<>();
        String sql = "SELECT * FROM brands";
        try (Connection conn = DBContext.getNewConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
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
            return list;
        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Error fetching brands: " + e.getMessage());
        }
    }

    public void insertBrand(Brand brand) {
        String checkSql = "SELECT COUNT(*) FROM brands WHERE LOWER(name) = LOWER(?)";
        try (Connection conn = DBContext.getNewConnection()) {
            try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
                checkPs.setString(1, brand.getName().trim());
                try (ResultSet rs = checkPs.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        throw new IllegalArgumentException("Thương hiệu '" + brand.getName() + "' đã tồn tại.");
                    }
                }
            }

            String sql = "INSERT INTO brands (name, description, logo_url, is_active, created_at) VALUES (?, ?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, brand.getName());
                ps.setString(2, brand.getDescription());
                ps.setString(3, brand.getLogoUrl());
                ps.setBoolean(4, brand.isActive());
                ps.setTimestamp(5, new Timestamp(brand.getCreatedAt().getTime()));
                ps.executeUpdate();
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi thêm thương hiệu: " + e.getMessage(), e);
        }
    }

    public Brand getBrandById(Long brandId) {
        String sql = "SELECT * FROM brands WHERE brand_id = ?";
        try (Connection conn = DBContext.getNewConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, brandId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Brand(
                            rs.getLong("brand_id"),
                            rs.getString("name"),
                            rs.getString("description"),
                            rs.getString("logo_url"),
                            rs.getBoolean("is_active"),
                            rs.getTimestamp("created_at")
                    );
                }
                return null;
            }
        } catch (SQLException e) {
            System.out.println("Error in getBrandById: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }

    public boolean updateBrand(Brand brand) {
        String checkSql = "SELECT COUNT(*) FROM brands WHERE LOWER(name) = LOWER(?) AND brand_id != ?";
        try (Connection conn = DBContext.getNewConnection()) {
            try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
                checkPs.setString(1, brand.getName().trim());
                checkPs.setLong(2, brand.getBrandId());
                try (ResultSet rs = checkPs.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        throw new IllegalArgumentException("Thương hiệu '" + brand.getName() + "' đã tồn tại.");
                    }
                }
            }

            String sql = "UPDATE brands SET name = ?, description = ?, logo_url = ?, is_active = ? WHERE brand_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, brand.getName());
                ps.setString(2, brand.getDescription());
                ps.setString(3, brand.getLogoUrl());
                ps.setBoolean(4, brand.isActive());
                ps.setLong(5, brand.getBrandId());
                return ps.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            System.out.println("Error in updateBrand: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteBrand(Long brandId) {
        String checkSql = "SELECT COUNT(*) FROM products WHERE brand_id = ?";
        String sql = "DELETE FROM brands WHERE brand_id = ?";
        try (Connection conn = DBContext.getNewConnection()) {
            try (PreparedStatement psCheck = conn.prepareStatement(checkSql)) {
                psCheck.setLong(1, brandId);
                try (ResultSet rs = psCheck.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        throw new IllegalStateException("Không thể xóa thương hiệu: Thương hiệu đang được sử dụng bởi sản phẩm.");
                    }
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setLong(1, brandId);
                int rowsAffected = ps.executeUpdate();
                return rowsAffected > 0;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi xóa thương hiệu: " + e.getMessage(), e);
        }
    }

    public boolean isBrandExists(String name, Long excludeBrandId) {
        String sql = "SELECT COUNT(*) FROM brands WHERE LOWER(name) = ? AND (brand_id != ? OR ? IS NULL)";
        try (Connection conn = DBContext.getNewConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name.trim().replaceAll("\\s+", " ").toLowerCase());
            if (excludeBrandId != null) {
                ps.setLong(2, excludeBrandId);
                ps.setLong(3, excludeBrandId);
            } else {
                ps.setNull(2, java.sql.Types.BIGINT);
                ps.setNull(3, java.sql.Types.BIGINT);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
                return false;
            }
        } catch (SQLException e) {
            System.out.println("Error in isBrandExists: " + e.getMessage());
            e.printStackTrace();
            return false;
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