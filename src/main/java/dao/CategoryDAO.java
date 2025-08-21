package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.Category;
import util.DBContext;

public class CategoryDAO {

    public int insertCategory(String name, String description, Long parentCategoryId, boolean isActive) {
        String sql = "INSERT INTO categories (name, description, parent_category_id, is_active, created_at) "
                + "VALUES (?, ?, ?, ?, SYSDATETIMEOFFSET() AT TIME ZONE 'SE Asia Standard Time')";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            name = (name == null || name.trim().isEmpty()) ? "Unnamed Category" : name.trim();
            ps.setString(1, name);
            ps.setString(2, description != null ? description : null);
            if (parentCategoryId != null) {
                ps.setLong(3, parentCategoryId);
            } else {
                ps.setNull(3, java.sql.Types.BIGINT);
            }
            ps.setBoolean(4, isActive);
            int result = ps.executeUpdate();
            return result;
        } catch (SQLException e) {
            throw new RuntimeException("Error inserting category", e);
        }
    }

    public Category getCategoryById(Long categoryId) {
        String sql = "SELECT c.category_id, c.name, c.description, c.parent_category_id, c.is_active, c.created_at, p.name AS parentCategoryName "
                + "FROM categories c LEFT JOIN categories p ON c.parent_category_id = p.category_id WHERE c.category_id = ?";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, categoryId);
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Long parentCategoryId = rs.getLong("parent_category_id");
                    if (rs.wasNull()) {
                        parentCategoryId = null;
                    }
                    String name = rs.getString("name");
                    name = (name == null || name.trim().isEmpty()) ? "Unnamed Category" : name.trim().replaceAll("[^\\p{L}\\p{N}\\s-]", "");
                    Category category = new Category(
                            rs.getLong("category_id"),
                            name,
                            rs.getString("description"),
                            parentCategoryId,
                            rs.getString("parentCategoryName"),
                            rs.getBoolean("is_active"),
                            rs.getTimestamp("created_at")
                    );
                    return category;
                }
                return null;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error fetching category", e);
        }
    }

    public boolean deleteCategory(long categoryId) {
        String checkProductsSql = "SELECT COUNT(*) "
                + "FROM products p "
                + "JOIN product_variants pv ON p.product_id = pv.product_id "
                + "JOIN inventory i ON pv.variant_id = i.variant_id "
                + "WHERE p.category_id = ? AND i.quantity > 0";

        String deleteInventorySql = "DELETE i "
                + "FROM inventory i "
                + "JOIN product_variants pv ON i.variant_id = pv.variant_id "
                + "JOIN products p ON pv.product_id = p.product_id "
                + "WHERE p.category_id = ?";

        String deleteVariantsSql = "DELETE pv "
                + "FROM product_variants pv "
                + "JOIN products p ON pv.product_id = p.product_id "
                + "WHERE p.category_id = ?";

        String deleteProductsSql = "DELETE FROM products WHERE category_id = ?";

        String updateSubCategoriesSql = "UPDATE categories SET parent_category_id = NULL WHERE parent_category_id = ?";
        String deleteCategorySql = "DELETE FROM categories WHERE category_id = ?";

        try ( Connection conn = DBContext.getNewConnection()) {
            conn.setAutoCommit(false);

            //check ton kho
            try ( PreparedStatement psCheckProducts = conn.prepareStatement(checkProductsSql)) {
                psCheckProducts.setLong(1, categoryId);
                try ( ResultSet rs = psCheckProducts.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        conn.rollback();
                        throw new RuntimeException("Cannot delete: Category has products in stock");
                    }
                }
            }

            try ( PreparedStatement psDeleteInventory = conn.prepareStatement(deleteInventorySql)) {
                psDeleteInventory.setLong(1, categoryId);
                psDeleteInventory.executeUpdate();
            }

            try ( PreparedStatement psDeleteVariants = conn.prepareStatement(deleteVariantsSql)) {
                psDeleteVariants.setLong(1, categoryId);
                psDeleteVariants.executeUpdate();
            }

            try ( PreparedStatement psDeleteProducts = conn.prepareStatement(deleteProductsSql)) {
                psDeleteProducts.setLong(1, categoryId);
                psDeleteProducts.executeUpdate();
            }

            try ( PreparedStatement psUpdateSub = conn.prepareStatement(updateSubCategoriesSql)) {
                psUpdateSub.setLong(1, categoryId);
                psUpdateSub.executeUpdate();
            }

            int rowsAffected;
            try ( PreparedStatement psDeleteCat = conn.prepareStatement(deleteCategorySql)) {
                psDeleteCat.setLong(1, categoryId);
                rowsAffected = psDeleteCat.executeUpdate();
            }

            conn.commit();
            return rowsAffected == 1;

        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Error deleting category: " + e.getMessage(), e);
        }
    }

    public boolean updateCategory(long id, String name, String description, Long parentCategoryId, boolean isActive) {
        String sql = "UPDATE categories SET name = ?, description = ?, parent_category_id = ?, is_active = ? "
                + "WHERE category_id = ?";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            name = (name == null || name.trim().isEmpty()) ? "Unnamed Category" : name.trim();
            ps.setString(1, name);
            ps.setString(2, description);
            if (parentCategoryId != null) {
                ps.setLong(3, parentCategoryId);
            } else {
                ps.setNull(3, java.sql.Types.BIGINT);
            }
            ps.setBoolean(4, isActive);
            ps.setLong(5, id);
            int result = ps.executeUpdate();
            return result == 1;
        } catch (SQLException e) {
            return false;
        }
    }

    public List<Category> getAllCategories() {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT c.category_id, c.name, c.description, c.parent_category_id, c.is_active, c.created_at, p.name AS parentCategoryName "
                + "FROM categories c LEFT JOIN categories p ON c.parent_category_id = p.category_id "
                + "ORDER BY ISNULL(c.parent_category_id, c.category_id), c.parent_category_id, c.name";
        try ( Connection conn = DBContext.getNewConnection()) {
            if (conn == null) {
                throw new RuntimeException("Database connection failed");
            }
            try ( PreparedStatement ps = conn.prepareStatement(sql);  ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Long parentCategoryId = rs.getLong("parent_category_id");
                    if (rs.wasNull()) {
                        parentCategoryId = null;
                    }
                    String name = rs.getString("name");
                    name = (name == null || name.trim().isEmpty()) ? "Unnamed Category" : name.trim().replaceAll("[^\\p{L}\\p{N}\\s-]", "");
                    Category category = new Category(
                            rs.getLong("category_id"),
                            name,
                            rs.getString("description"),
                            parentCategoryId,
                            rs.getString("parentCategoryName"),
                            rs.getBoolean("is_active"),
                            rs.getTimestamp("created_at")
                    );
                    list.add(category);
                }
                return list;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error fetching categories", e);
        }
    }

    public List<Category> getParentCategories() {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT category_id, name, description, parent_category_id, is_active, created_at "
                + "FROM categories WHERE parent_category_id IS NULL ORDER BY name";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql);  ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Long parentCategoryId = rs.getLong("parent_category_id");
                if (rs.wasNull()) {
                    parentCategoryId = null;
                }
                String name = rs.getString("name");
                name = (name == null || name.trim().isEmpty()) ? "Unnamed Category" : name.trim().replaceAll("[^\\p{L}\\p{N}\\s-]", "");
                Category category = new Category(
                        rs.getLong("category_id"),
                        name,
                        rs.getString("description"),
                        parentCategoryId,
                        null,
                        rs.getBoolean("is_active"),
                        rs.getTimestamp("created_at")
                );
                list.add(category);
            }
            return list;
        } catch (SQLException e) {
            throw new RuntimeException("Error fetching parent categories", e);
        }
    }

    public boolean isCategoryExists(String name, Long parentCategoryId, Long excludeCategoryId) {
        String sql = "SELECT COUNT(*) AS count FROM categories WHERE LOWER(name) = ? AND "
                + "(parent_category_id = ? OR (? IS NULL AND parent_category_id IS NULL)) "
                + "AND (category_id != ? OR ? IS NULL)";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            name = (name == null || name.trim().isEmpty()) ? "Unnamed Category" : name.trim().replaceAll("[^\\p{L}\\p{N}\\s-]", "");
            ps.setString(1, name.toLowerCase());
            if (parentCategoryId != null) {
                ps.setLong(2, parentCategoryId);
                ps.setLong(3, parentCategoryId);
            } else {
                ps.setNull(2, java.sql.Types.BIGINT);
                ps.setNull(3, java.sql.Types.BIGINT);
            }
            if (excludeCategoryId != null) {
                ps.setLong(4, excludeCategoryId);
                ps.setLong(5, excludeCategoryId);
            } else {
                ps.setNull(4, java.sql.Types.BIGINT);
                ps.setNull(5, java.sql.Types.BIGINT);
            }
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    boolean exists = rs.getInt("count") > 0;
                    return exists;
                }
            }
        } catch (SQLException e) {
        }
        return false;
    }

    //Tim ten voi trang thai
    public List<Category> searchCategoriesByName(String keyword, String filter) {
        List<Category> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT c.category_id, c.name, c.description, c.parent_category_id, c.is_active, c.created_at, p.name AS parentCategoryName "
                + "FROM categories c LEFT JOIN categories p ON c.parent_category_id = p.category_id WHERE 1=1"
        );
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND LOWER(c.name) LIKE ?");
        }
        if (filter != null && !filter.equals("All")) {
            sql.append(" AND c.is_active = ?");
        }
        sql.append(" ORDER BY ISNULL(c.parent_category_id, c.category_id), c.parent_category_id, c.name");

        try ( Connection conn = DBContext.getNewConnection()) {
            if (conn == null) {
                throw new RuntimeException("Database connection failed");
            }
            try ( PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                int paramIndex = 1;
                if (keyword != null && !keyword.trim().isEmpty()) {
                    ps.setString(paramIndex++, "%" + keyword.trim().toLowerCase() + "%");
                }
                if (filter != null && !filter.equals("All")) {
                    ps.setBoolean(paramIndex, filter.equals("Active"));
                }
                try ( ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Long parentCategoryId = rs.getLong("parent_category_id");
                        if (rs.wasNull()) {
                            parentCategoryId = null;
                        }
                        String name = rs.getString("name");
                        name = (name == null || name.trim().isEmpty()) ? "Unnamed Category" : name.trim().replaceAll("[^\\p{L}\\p{N}\\s-]", "");
                        Category category = new Category(
                                rs.getLong("category_id"),
                                name,
                                rs.getString("description"),
                                parentCategoryId,
                                rs.getString("parentCategoryName"),
                                rs.getBoolean("is_active"),
                                rs.getTimestamp("created_at")
                        );
                        list.add(category);
                    }
                    return list;
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error searching categories", e);
        }
    }

    public Category getCategoryBySlug(String slug) {
        // Assuming slug is in the format "/category/{categoryId}/{slug}" or just "{slug}"
        String categoryIdStr = null;
        String cleanSlug = slug;
        if (slug.startsWith("/category/")) {
            String[] parts = slug.split("/");
            if (parts.length >= 3) {
                categoryIdStr = parts[2];
                cleanSlug = parts.length > 3 ? parts[3] : "";
            }
        }

        String sql = "SELECT category_id, name, description, parent_category_id, is_active, created_at "
                + "FROM categories WHERE is_active = 1";
        List<Object> params = new ArrayList<>();

        if (categoryIdStr != null && !categoryIdStr.isEmpty()) {
            sql += " AND category_id = ?";
            params.add(Long.parseLong(categoryIdStr));
        } else {
            sql += " AND LOWER(name) LIKE ?";
            params.add("%" + cleanSlug.replace("-", " ").toLowerCase() + "%");
        }

        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Category(
                            rs.getLong("category_id"),
                            rs.getString("name"),
                            rs.getString("description"),
                            rs.getLong("parent_category_id") != 0 ? rs.getLong("parent_category_id") : null,
                            rs.getBoolean("is_active"),
                            rs.getTimestamp("created_at")
                    );
                }
            }
        } catch (SQLException e) {
            System.out.println("SQLException in getCategoryBySlug: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    public List<Long> getSubCategoryIds(Long parentCategoryId) throws SQLException {
        List<Long> subCategoryIds = new ArrayList<>();
        String sql = "SELECT category_id FROM categories WHERE parent_category_id = ? AND is_active = 1";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, parentCategoryId);
            try ( ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    subCategoryIds.add(rs.getLong("category_id"));
                }
            }
        }
        return subCategoryIds;
    }

//    public static void main(String[] args) {
//        CategoryDAO dao = new CategoryDAO();
//        try {
//            int result = dao.insertCategory("Test Category", "Test Description", null, true);
//            List<Category> categories = dao.searchCategoriesByName("test", "All");
//            for (Category category : categories) {
//            }
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//    }
}
