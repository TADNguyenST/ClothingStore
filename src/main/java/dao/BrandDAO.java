/*
 * Click nbproject://SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbproject://SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.Brand;
import util.DBContext;

/**
 *
 * @author DANGVUONGTHINH
 */
public class BrandDAO extends DBContext {
    
    public List<Brand> getAll() {
        List<Brand> list = new ArrayList<>();
        String sql = "SELECT brand_id, name, description, logo_url, is_active, created_at FROM brands";

        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                long brandId = rs.getLong("brand_id");
                String name = rs.getString("name");
                String description = rs.getString("description");
                String logoUrl = rs.getString("logo_url");
                Boolean isActive = rs.getBoolean("is_active");
                java.sql.Timestamp createdAt = rs.getTimestamp("created_at");
                java.time.LocalDateTime createdAtLocal = createdAt != null ? createdAt.toLocalDateTime() : null;

                Brand brand = new Brand();
                brand.setBrandId(brandId);
                brand.setName(name);
                brand.setDescription(description);
                brand.setLogoUrl(logoUrl);
                brand.setIsActive(isActive);
                brand.setCreatedAt(createdAtLocal);

                list.add(brand);
            }
            return list;
        } catch (Exception e) {
            System.out.println("Error in getAll: " + e.getMessage());
        }
        return list;
    }

    public Brand getBrandById(int brandId) {
        String sql = "SELECT brand_id, name, description, logo_url, is_active, created_at FROM brands WHERE brand_id = ?";
        
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, brandId); // Use setInt to match int type in servlet
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                long id = rs.getLong("brand_id");
                String name = rs.getString("name");
                String description = rs.getString("description");
                String logoUrl = rs.getString("logo_url");
                Boolean isActive = rs.getBoolean("is_active");
                java.sql.Timestamp createdAt = rs.getTimestamp("created_at");
                java.time.LocalDateTime createdAtLocal = createdAt != null ? createdAt.toLocalDateTime() : null;

                Brand brand = new Brand();
                brand.setBrandId(id);
                brand.setName(name);
                brand.setDescription(description);
                brand.setLogoUrl(logoUrl);
                brand.setIsActive(isActive);
                brand.setCreatedAt(createdAtLocal);
                return brand;
            }
        } catch (Exception e) {
            System.out.println("Error in getBrandById: " + e.getMessage());
        }
        return null;
    }
}