/*
 * Click nbproject://SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbproject://SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import model.Brand;
import util.DBContext;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 *
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
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Error fetching brands: " + e.getMessage());
        }
        return list;
    }

    // Thêm brand
    public void insertBrand(Brand brand) {
        String sql = "INSERT INTO brands (name, description, logo_url, is_active, created_at) VALUES (?, ?, ?, ?, ?)";

        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, brand.getName());
            ps.setString(2, brand.getDescription());
            ps.setString(3, brand.getLogoUrl());
            ps.setBoolean(4, brand.isActive());
            ps.setTimestamp(5, new Timestamp(brand.getCreatedAt().getTime()));
            ps.executeUpdate();
        } catch (Exception e) {
            System.out.println(e.getMessage());
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
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }
        return brand;
    }

    // Cập nhật brand
    public boolean updateBrand(Brand brand) {
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
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }
        return rowUpdated;
    }

    // Xóa brand
    public boolean deleteBrand(Long brandId) {
        String sql = "DELETE FROM brands WHERE brand_id = ?";
        boolean rowDeleted = false;

        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setLong(1, brandId);
            rowDeleted = ps.executeUpdate() > 0;
            return rowDeleted;
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }
        return rowDeleted;
    }

    public List<Brand> searchBrandsByName(String name) {
        List<Brand> list = new ArrayList<>();
        String sql = "SELECT brand_id, name, description, logo_url, is_active, created_at FROM brands WHERE LOWER(name) LIKE LOWER(?)";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, "%" + (name != null ? name.trim() : "") + "%");
            ResultSet rs = ps.executeQuery();
            int rowCount = 0;
            while (rs.next()) {
                list.add(new Brand(
                        rs.getLong("brand_id"),
                        rs.getString("name"),
                        rs.getString("description"),
                        rs.getString("logo_url"),
                        rs.getBoolean("is_active"),
                        rs.getTimestamp("created_at")
                ));
                rowCount++;
            }
            System.out.println("Search brands rows returned: " + rowCount);
        } catch (Exception e) {
            System.out.println("Error in searchBrandsByName: " + e.getMessage());
            throw new RuntimeException("Error searching brands: " + e.getMessage(), e);
        }
        return list;
    }

    public List<Brand> getBrandsByStatus(boolean isActive) {
        List<Brand> list = new ArrayList<>();
        String sql = "SELECT brand_id, name, description, logo_url, is_active, created_at FROM brands WHERE is_active = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setBoolean(1, isActive);
            ResultSet rs = ps.executeQuery();
            int rowCount = 0;
            while (rs.next()) {
                list.add(new Brand(
                        rs.getLong("brand_id"),
                        rs.getString("name"),
                        rs.getString("description"),
                        rs.getString("logo_url"),
                        rs.getBoolean("is_active"),
                        rs.getTimestamp("created_at")
                ));
                rowCount++;
            }
            System.out.println("Filter brands rows returned: " + rowCount);
        } catch (Exception e) {
            System.out.println("Error in getBrandsByStatus: " + e.getMessage());
            throw new RuntimeException("Error filtering brands by status: " + e.getMessage(), e);
        }
        return list;
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
