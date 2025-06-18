/*
 * Click nbproject://SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbproject://SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.Category;
import util.DBContext;

/**
 *
 * @author DANGVUONGTHINH
 */
public class CategoryDAO extends DBContext {
    
    public List<Category> getAll() {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT category_id, name, description, parent_category_id, is_active, created_at FROM categories";

        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                long categoryId = rs.getLong("category_id");
                String name = rs.getString("name");
                String description = rs.getString("description");
                Long parentCategoryId = rs.getLong("parent_category_id");
                Boolean isActive = rs.getBoolean("is_active");
                java.sql.Timestamp createdAt = rs.getTimestamp("created_at");
                java.time.LocalDateTime createdAtLocal = createdAt != null ? createdAt.toLocalDateTime() : null;

                Category category = new Category();
                category.setCategoryId(categoryId);
                category.setName(name);
                category.setDescription(description);
                category.setParentCategoryId(parentCategoryId);
                category.setIsActive(isActive);
                category.setCreatedAt(createdAtLocal);

                list.add(category);
            }
            return list;
        } catch (Exception e) {
            System.out.println("Error in getAll: " + e.getMessage());
        }
        return list;
    }

    public Category getCategoryById(long categoryId) {
        String sql = "SELECT category_id, name, description, parent_category_id, is_active, created_at FROM categories WHERE category_id = ?";
        
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setLong(1, categoryId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                long id = rs.getLong("category_id");
                String name = rs.getString("name");
                String description = rs.getString("description");
                Long parentCategoryId = rs.getLong("parent_category_id");
                Boolean isActive = rs.getBoolean("is_active");
                java.sql.Timestamp createdAt = rs.getTimestamp("created_at");
                java.time.LocalDateTime createdAtLocal = createdAt != null ? createdAt.toLocalDateTime() : null;

                Category category = new Category();
                category.setCategoryId(id);
                category.setName(name);
                category.setDescription(description);
                category.setParentCategoryId(parentCategoryId);
                category.setIsActive(isActive);
                category.setCreatedAt(createdAtLocal);
                return category;
            }
        } catch (Exception e) {
            System.out.println("Error in getCategoryById: " + e.getMessage());
        }
        return null;
    }
}