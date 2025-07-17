package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.Category;
import util.DBContext;

public class CategoryDAO extends DBContext {

    public int insertCategory(String name, String description, Long parentCategoryId, boolean isActive) {
        String sql = "INSERT INTO categories (name, description, parent_category_id, is_active, created_at) "
                + "VALUES (?, ?, ?, ?, GETDATE())";
        try {
            if (conn == null) {
                throw new SQLException("Database connection is null");
            }
            PreparedStatement ps = conn.prepareStatement(sql);
            System.out.println("Inserting: name=" + name + ", parentId=" + parentCategoryId + ", isActive=" + isActive);
            ps.setString(1, name);
            ps.setString(2, description != null ? description : null);
            if (parentCategoryId != null) {
                ps.setLong(3, parentCategoryId);
            } else {
                ps.setNull(3, java.sql.Types.BIGINT);
            }
            ps.setBoolean(4, isActive);
            int result = ps.executeUpdate();
            System.out.println("Insert affected rows: " + result);
            return result;
        } catch (SQLException e) {
            throw new RuntimeException("Error inserting category: " + e.getMessage(), e);
        }
    }

    public Category getCategoryById(Long categoryId) {
        String sql = "SELECT category_id, name, description, parent_category_id, is_active, created_at "
                + "FROM categories WHERE category_id = ?";
        try {
            if (conn == null) {
                throw new SQLException("Database connection is null");
            }
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setLong(1, categoryId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Long parentCategoryId = rs.getLong("parent_category_id");
                if (rs.wasNull()) {
                    parentCategoryId = null;
                }
                return new Category(
                        rs.getLong("category_id"),
                        rs.getString("name"),
                        rs.getString("description"),
                        parentCategoryId,
                        rs.getBoolean("is_active"),
                        rs.getTimestamp("created_at")
                );
            }
            return null;
        } catch (SQLException e) {
            throw new RuntimeException("Error fetching category: " + e.getMessage(), e);
        }
    }

    public boolean deleteCategory(long categoryId) {
        String sql = "DELETE FROM categories WHERE category_id = ?";
        try {
            if (conn == null) {
                throw new SQLException("Database connection is null");
            }
            String checkSql = "SELECT COUNT(*) FROM products WHERE category_id = ?";
            PreparedStatement psCheck = conn.prepareStatement(checkSql);
            psCheck.setLong(1, categoryId);
            ResultSet rs = psCheck.executeQuery();
            if (rs.next() && rs.getInt(1) > 0) {
                throw new RuntimeException("Cannot delete category: It is used by products");
            }

            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setLong(1, categoryId);
            int rowsAffected = ps.executeUpdate();
            return rowsAffected == 1;
        } catch (SQLException e) {
            throw new RuntimeException("Error deleting category: " + e.getMessage(), e);
        }
    }

    public boolean updateCategory(long id, String name, String description, Long parentCategoryId, boolean isActive) {
        String sql = "UPDATE categories SET name = ?, description = ?, parent_category_id = ?, is_active = ? WHERE category_id = ?";
        try {
            if (conn == null) {
                throw new SQLException("Database connection is null");
            }
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, name);
            ps.setString(2, description);
            if (parentCategoryId == null) {
                ps.setNull(3, java.sql.Types.BIGINT);
            } else {
                ps.setLong(3, parentCategoryId);
            }
            ps.setBoolean(4, isActive);
            ps.setLong(5, id);
            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.out.println("Error in updateCategory: " + e.getMessage());
            return false;
        }
    }

    public List<Category> getAllCategories() {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT category_id, name, description, parent_category_id, is_active, created_at "
                + "FROM categories";
        try {
            if (conn == null) {
                throw new SQLException("Database connection is null");
            }
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Long parentCategoryId = rs.getLong("parent_category_id");
                if (rs.wasNull()) {
                    parentCategoryId = null;
                }
                Category category = new Category(
                        rs.getLong("category_id"),
                        rs.getString("name"),
                        rs.getString("description"),
                        parentCategoryId,
                        rs.getBoolean("is_active"),
                        rs.getTimestamp("created_at")
                );
                list.add(category);
            }
            return list;
        } catch (SQLException e) {
            throw new RuntimeException("Error fetching categories: " + e.getMessage(), e);
        }
    }

    public List<Category> getParentCategories() {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT category_id, name, description, parent_category_id, is_active, created_at "
                    + "FROM categories WHERE parent_category_id IS NULL";
        try {
            if (conn == null) {
                throw new SQLException("Database connection is null");
            }
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Long parentCategoryId = rs.getLong("parent_category_id");
                if (rs.wasNull()) {
                    parentCategoryId = null;
                }
                Category category = new Category(
                        rs.getLong("category_id"),
                        rs.getString("name"),
                        rs.getString("description"),
                        parentCategoryId,
                        rs.getBoolean("is_active"),
                        rs.getTimestamp("created_at")
                );
                list.add(category);
            }
            return list;
        } catch (SQLException e) {
            throw new RuntimeException("Error fetching parent categories: " + e.getMessage(), e);
        }
    }

    public static void main(String[] args) {
        CategoryDAO dao = new CategoryDAO();
        int result = dao.insertCategory("Test Category", "Test", null, true);
        System.out.println("Insert result: " + result);
    }
}