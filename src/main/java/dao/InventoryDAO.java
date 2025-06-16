package dao;

import model.Inventory;
import model.Product;
import model.ProductVariant;
import model.Category;
import model.Brand;

import util.DBContext;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.math.BigDecimal;

public class InventoryDAO {

    public List<Inventory> getAllProductVariantsWithStock() throws SQLException {
        return getAllProductVariantsWithStock(null, null, null, null); // Call the new method with nulls for no search/sort
    }

    public List<Inventory> getAllProductVariantsWithStock(String searchTerm, String sortBy, String sortOrder, String filterCategory) throws SQLException {
        List<Inventory> inventoryList = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT " +
                "i.inventory_id, i.product_id, i.variant_id, i.quantity, i.reserved_quantity, i.last_updated, " +
                "p.name AS product_name, p.description AS product_description, p.price AS product_price, p.material, p.status AS product_status, " +
                "pv.size, pv.color, pv.price AS variant_price, pv.sku, " +
                "c.name AS category_name, " +
                "b.name AS brand_name " +
                "FROM inventory i " +
                "JOIN products p ON i.product_id = p.product_id " +
                "JOIN product_variants pv ON i.variant_id = pv.variant_id " +
                "LEFT JOIN categories c ON p.category_id = c.category_id " +
                "LEFT JOIN brands b ON p.brand_id = b.brand_id ");

        // Add WHERE clause for search term
        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            sql.append("WHERE p.name LIKE ? OR pv.sku LIKE ? OR pv.color LIKE ? OR pv.size LIKE ? ");
        }

        // Add WHERE clause for category filter
        if (filterCategory != null && !filterCategory.trim().isEmpty()) {
            if (searchTerm != null && !searchTerm.trim().isEmpty()) {
                sql.append("AND ");
            } else {
                sql.append("WHERE ");
            }
            sql.append("c.name = ? ");
        }

        // Add ORDER BY clause for sorting
        if (sortBy != null && !sortBy.trim().isEmpty()) {
            sql.append("ORDER BY ");
            switch (sortBy) {
                case "productName":
                    sql.append("p.name");
                    break;
                case "sku":
                    sql.append("pv.sku");
                    break;
                case "quantity":
                    sql.append("i.quantity");
                    break;
                case "category":
                    sql.append("c.name");
                    break;
                case "brand":
                    sql.append("b.name");
                    break;
                default:
                    sql.append("p.name"); // Default sort
            }
            if (sortOrder != null && sortOrder.equalsIgnoreCase("desc")) {
                sql.append(" DESC");
            } else {
                sql.append(" ASC");
            }
            sql.append(", pv.size, pv.color"); // Secondary sort for consistency
        } else {
            sql.append("ORDER BY p.name, pv.size, pv.color"); // Default order
        }


        DBContext context = null;
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;

        try {
            context = new DBContext();
            connection = context.getConnection();

            preparedStatement = connection.prepareStatement(sql.toString());

            int paramIndex = 1;
            if (searchTerm != null && !searchTerm.trim().isEmpty()) {
                preparedStatement.setString(paramIndex++, "%" + searchTerm + "%");
                preparedStatement.setString(paramIndex++, "%" + searchTerm + "%");
                preparedStatement.setString(paramIndex++, "%" + searchTerm + "%");
                preparedStatement.setString(paramIndex++, "%" + searchTerm + "%");
            }
            if (filterCategory != null && !filterCategory.trim().isEmpty()) {
                preparedStatement.setString(paramIndex++, filterCategory);
            }

            resultSet = preparedStatement.executeQuery();

            while (resultSet.next()) {
                Product product = new Product();
                product.setProductId(resultSet.getLong("product_id"));
                product.setName(resultSet.getString("product_name"));
                product.setDescription(resultSet.getString("product_description"));
                product.setPrice(resultSet.getBigDecimal("product_price"));
                product.setMaterial(resultSet.getString("material"));
                product.setStatus(resultSet.getString("product_status"));

                Category category = new Category();
                category.setName(resultSet.getString("category_name"));
                product.setCategory(category);

                Brand brand = new Brand();
                brand.setName(resultSet.getString("brand_name"));
                product.setBrand(brand);

                ProductVariant variant = new ProductVariant();
                variant.setVariantId(resultSet.getLong("variant_id"));
                variant.setProductId(resultSet.getLong("product_id"));
                variant.setSize(resultSet.getString("size"));
                variant.setColor(resultSet.getString("color"));
                BigDecimal variantPrice = resultSet.getBigDecimal("variant_price");
                if (variantPrice == null) {
                    variant.setPrice(product.getPrice());
                } else {
                    variant.setPrice(variantPrice);
                }
                variant.setSku(resultSet.getString("sku"));
                variant.setProduct(product);

                Inventory inventory = new Inventory();
                inventory.setInventoryId(resultSet.getLong("inventory_id"));
                inventory.setProductId(resultSet.getLong("product_id"));
                inventory.setVariantId(resultSet.getLong("variant_id"));
                inventory.setQuantity(resultSet.getInt("quantity")); // Use getInt()
                inventory.setReservedQuantity(resultSet.getInt("reserved_quantity")); // Use getInt()
                Timestamp lastUpdatedTimestamp = resultSet.getTimestamp("last_updated");
                if (lastUpdatedTimestamp != null) {
                    inventory.setLastUpdated(lastUpdatedTimestamp.toLocalDateTime());
                }

                // Removed: inventory.setAvailableQuantity(...) as it's now a calculated getter in the model

                inventory.setProduct(product);
                inventory.setProductVariant(variant);

                inventoryList.add(inventory);
            }
        } finally {
            if (resultSet != null) {
                try {
                    resultSet.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
            if (preparedStatement != null) {
                try {
                    preparedStatement.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
            if (context != null) {
                context.closeConnection();
            }
        }
        return inventoryList;
    }
    // You'll also need a method to get all categories for the filter dropdown
    public List<Category> getAllCategories() throws SQLException {
        List<Category> categories = new ArrayList<>();
        String sql = "SELECT category_id, name FROM categories ORDER BY name";
        DBContext context = null;
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;

        try {
            context = new DBContext();
            connection = context.getConnection();
            preparedStatement = connection.prepareStatement(sql);
            resultSet = preparedStatement.executeQuery();

            while (resultSet.next()) {
                Category category = new Category();
                category.setCategoryId(resultSet.getLong("category_id"));
                category.setName(resultSet.getString("name"));
                categories.add(category);
            }
        } finally {
            if (resultSet != null) { try { resultSet.close(); } catch (SQLException e) { e.printStackTrace(); } }
            if (preparedStatement != null) { try { preparedStatement.close(); } catch (SQLException e) { e.printStackTrace(); } }
            if (context != null) { context.closeConnection(); }
        }
        return categories;
    }
}