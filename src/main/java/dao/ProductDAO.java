package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.Product;
import model.Category;
import model.Brand;
import model.ProductVariant;
import model.ProductImage;
import util.DBContext;
import java.math.BigDecimal;
import java.sql.Statement;
import java.sql.Timestamp;
import java.sql.Types;
import java.util.Collections;

/**
 * Data Access Object for Product-related database operations.
 */
public class ProductDAO {

    // List san pham va sap xep(Admin, home)
public List<Product> getAll(String sort) {
    List<Product> list = new ArrayList<>();
    StringBuilder sql = new StringBuilder(
        "SELECT p.product_id, p.name AS ProductName, p.price, p.status, "
      + "pi.image_url AS ImageURL, c.category_id, c.name AS CategoryName, c.parent_category_id, "
      + "pc.name AS ParentCategoryName, b.brand_id, b.name AS BrandName, "
      + "(SELECT SUM(i.quantity) "
      + " FROM inventory i "
      + " JOIN product_variants pv2 ON i.variant_id = pv2.variant_id "
      + " WHERE pv2.product_id = p.product_id) AS total_quantity "
      + "FROM products p "
      + "LEFT JOIN product_images pi ON p.product_id = pi.product_id AND pi.is_main = 1 "
      + "LEFT JOIN categories c ON p.category_id = c.category_id "
      + "LEFT JOIN categories pc ON c.parent_category_id = pc.category_id "
      + "LEFT JOIN brands b ON p.brand_id = b.brand_id "
      + "WHERE b.is_active = 1 "
      + "AND (c.is_active = 1 OR c.category_id IS NULL) "
      + "AND (pc.is_active = 1 OR pc.category_id IS NULL) "
    );

    if (sort != null) {
        switch (sort) {
            case "name_asc":
                sql.append("ORDER BY p.name ASC");
                break;
            case "name_desc":
                sql.append("ORDER BY p.name DESC");
                break;
            case "price_asc":
                sql.append("ORDER BY p.price ASC");
                break;
            case "price_desc":
                sql.append("ORDER BY p.price DESC");
                break;
            default:
                sql.append("ORDER BY p.product_id DESC");
                break;
        }
    } else {
        sql.append("ORDER BY p.product_id DESC");
    }

    try (Connection conn = DBContext.getNewConnection();
         PreparedStatement ps = conn.prepareStatement(sql.toString());
         ResultSet rs = ps.executeQuery()) {

        while (rs.next()) {
            Long productId = rs.getLong("product_id");
            String productName = rs.getString("ProductName");
            BigDecimal price = rs.getBigDecimal("price");
            String status = rs.getString("status");
            String imageUrl = rs.getString("ImageURL");
            Long categoryId = rs.getLong("category_id");
            if (rs.wasNull()) categoryId = null;
            String categoryName = rs.getString("CategoryName");
            Long parentCategoryId = rs.getLong("parent_category_id");
            if (rs.wasNull()) parentCategoryId = null;
            String parentCategoryName = rs.getString("ParentCategoryName");
            Long brandId = rs.getLong("brand_id");
            if (rs.wasNull()) brandId = null;
            String brandName = rs.getString("BrandName");

            // 👉 lấy tồn kho
            int quantity = rs.getInt("total_quantity");
            if (rs.wasNull()) quantity = 0;

            Category category = null;
            if (categoryId != null && categoryName != null) {
                category = new Category();
                category.setCategoryId(categoryId);
                category.setName(categoryName);
                category.setParentCategoryId(parentCategoryId);
            }

            Brand brand = null;
            if (brandId != null && brandName != null) {
                brand = new Brand();
                brand.setBrandId(brandId);
                brand.setName(brandName);
            }

            Product product = new Product(productId, productName, null, price,
                    category, brand, null, status, null, null);
            product.setImageUrl(imageUrl);
            product.setParentCategoryName(parentCategoryName);
            product.setQuantity(quantity);
            product.setStockStatus(quantity > 0 ? "In Stock" : "Out of Stock");

            list.add(product);
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    return list;
}


    // Search ten va bo loc (Admin)
    public List<Product> searchProductByNameAndFilter(String keyword, String filter) {
        List<Product> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT p.product_id, p.name AS ProductName, p.description, p.price, p.status, "
                + "pi.image_url AS ImageURL, c.category_id, c.name AS CategoryName, c.parent_category_id, "
                + "pc.name AS ParentCategoryName, b.brand_id, b.name AS BrandName "
                + "FROM products p "
                + "LEFT JOIN product_images pi ON p.product_id = pi.product_id AND pi.is_main = 1 "
                + "LEFT JOIN categories c ON p.category_id = c.category_id "
                + "LEFT JOIN categories pc ON c.parent_category_id = pc.category_id "
                + "LEFT JOIN brands b ON p.brand_id = b.brand_id "
                + "WHERE LOWER(p.name) LIKE ? AND b.is_active = 1 AND (c.is_active = 1 OR c.category_id IS NULL) AND (pc.is_active = 1 OR pc.category_id IS NULL)");
        if (filter != null && !filter.equals("All")) {
            if (filter.equals("Active") || filter.equals("Discontinued")) {
                sql.append(" AND p.status = ?");
            }
        }
        sql.append(" ORDER BY p.product_id DESC");
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            ps.setString(1, "%" + (keyword != null ? keyword.toLowerCase() : "") + "%");
            if (filter != null && (filter.equals("Active") || filter.equals("Discontinued"))) {
                ps.setString(2, filter);
            }
            try ( ResultSet rs = ps.executeQuery()) {
                int rowCount = 0;
                while (rs.next()) {
                    rowCount++;
                    Long productId = rs.getLong("product_id");
                    String productName = rs.getString("ProductName");
                    String description = rs.getString("description");
                    BigDecimal price = rs.getBigDecimal("price");
                    String productStatus = rs.getString("status");
                    String imageUrl = rs.getString("ImageURL");
                    Long categoryId = rs.getLong("category_id");
                    if (rs.wasNull()) {
                        categoryId = null;
                    }
                    String categoryName = rs.getString("CategoryName");
                    Long parentCategoryId = rs.getLong("parent_category_id");
                    if (rs.wasNull()) {
                        parentCategoryId = null;
                    }
                    String parentCategoryName = rs.getString("ParentCategoryName");
                    Long brandId = rs.getLong("brand_id");
                    if (rs.wasNull()) {
                        brandId = null;
                    }
                    String brandName = rs.getString("BrandName");
                    Category category = null;
                    if (categoryId != null && categoryName != null) {
                        category = new Category();
                        category.setCategoryId(categoryId);
                        category.setName(categoryName);
                        category.setParentCategoryId(parentCategoryId);
                    }
                    Brand brand = null;
                    if (brandId != null && brandName != null) {
                        brand = new Brand();
                        brand.setBrandId(brandId);
                        brand.setName(brandName);
                    }
                    Product product = new Product(productId, productName, description, price,
                            category, brand, null, productStatus, null, null);
                    product.setImageUrl(imageUrl);
                    product.setParentCategoryName(parentCategoryName);
                    list.add(product);
                    System.out.println("ProductDAO.searchProductByNameAndFilter: Added product ID " + productId + ", Image URL: " + (imageUrl != null ? imageUrl : "null"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Lay san pham co trang thai(Admin)
    public List<Product> getProductsByStatus(String status) {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT p.product_id, p.name AS ProductName, p.description, p.price, p.status, "
                + "pi.image_url AS ImageURL, c.category_id, c.name AS CategoryName, c.parent_category_id, "
                + "pc.name AS ParentCategoryName, b.brand_id, b.name AS BrandName "
                + "FROM products p "
                + "LEFT JOIN product_images pi ON p.product_id = pi.product_id AND pi.is_main = 1 "
                + "LEFT JOIN categories c ON p.category_id = c.category_id "
                + "LEFT JOIN categories pc ON c.parent_category_id = pc.category_id "
                + "LEFT JOIN brands b ON p.brand_id = b.brand_id "
                + "WHERE p.status = ? AND b.is_active = 1 AND (c.is_active = 1 OR c.category_id IS NULL) AND (pc.is_active = 1 OR pc.category_id IS NULL) "
                + "ORDER BY p.product_id DESC";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            try ( ResultSet rs = ps.executeQuery()) {
                int rowCount = 0;
                while (rs.next()) {
                    rowCount++;
                    Long productId = rs.getLong("product_id");
                    String productName = rs.getString("ProductName");
                    String description = rs.getString("description");
                    BigDecimal price = rs.getBigDecimal("price");
                    String productStatus = rs.getString("status");
                    String imageUrl = rs.getString("ImageURL");
                    Long categoryId = rs.getLong("category_id");
                    if (rs.wasNull()) {
                        categoryId = null;
                    }
                    String categoryName = rs.getString("CategoryName");
                    Long parentCategoryId = rs.getLong("parent_category_id");
                    if (rs.wasNull()) {
                        parentCategoryId = null;
                    }
                    String parentCategoryName = rs.getString("ParentCategoryName");
                    Long brandId = rs.getLong("brand_id");
                    if (rs.wasNull()) {
                        brandId = null;
                    }
                    String brandName = rs.getString("BrandName");
                    Category category = null;
                    if (categoryId != null && categoryName != null) {
                        category = new Category();
                        category.setCategoryId(categoryId);
                        category.setName(categoryName);
                        category.setParentCategoryId(parentCategoryId);
                    }
                    Brand brand = null;
                    if (brandId != null && brandName != null) {
                        brand = new Brand();
                        brand.setBrandId(brandId);
                        brand.setName(brandName);
                    }
                    Product product = new Product(productId, productName, description, price,
                            category, brand, null, productStatus, null, null);
                    product.setImageUrl(imageUrl);
                    product.setParentCategoryName(parentCategoryName);
                    list.add(product);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Lay san pham moi (Frontend, Admin)
    public List<Product> getProductIsNew() {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT p.product_id, p.name AS ProductName, p.description, p.price, p.status, "
                + "pi.image_url AS ImageURL, c.category_id, c.name AS CategoryName, c.parent_category_id, "
                + "pc.name AS ParentCategoryName, b.brand_id, b.name AS BrandName, "
                + "(SELECT SUM(i.quantity) FROM inventory i JOIN product_variants pv ON i.variant_id = pv.variant_id WHERE pv.product_id = p.product_id) AS total_quantity "
                + "FROM products p "
                + "LEFT JOIN product_images pi ON p.product_id = pi.product_id AND pi.is_main = 1 "
                + "LEFT JOIN categories c ON p.category_id = c.category_id "
                + "LEFT JOIN categories pc ON c.parent_category_id = pc.category_id "
                + "LEFT JOIN brands b ON p.brand_id = b.brand_id "
                + "WHERE DATEDIFF(day, p.created_at, GETDATE()) <= 30 "
                + "AND p.status = 'Active' AND b.is_active = 1 AND (c.is_active = 1 OR c.category_id IS NULL) AND (pc.is_active = 1 OR pc.category_id IS NULL) "
                + "ORDER BY p.product_id DESC "
                + "OFFSET 0 ROWS FETCH NEXT 8 ROWS ONLY";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql);  ResultSet rs = ps.executeQuery()) {
            int rowCount = 0;
            while (rs.next()) {
                rowCount++;
                Long productId = rs.getLong("product_id");
                String productName = rs.getString("ProductName");
                String description = rs.getString("description");
                BigDecimal price = rs.getBigDecimal("price");
                String status = rs.getString("status");
                String imageUrl = rs.getString("ImageURL");
                Long categoryId = rs.getLong("category_id");
                if (rs.wasNull()) {
                    categoryId = null;
                }
                String categoryName = rs.getString("CategoryName");
                Long parentCategoryId = rs.getLong("parent_category_id");
                if (rs.wasNull()) {
                    parentCategoryId = null;
                }
                String parentCategoryName = rs.getString("ParentCategoryName");
                Long brandId = rs.getLong("brand_id");
                if (rs.wasNull()) {
                    brandId = null;
                }
                String brandName = rs.getString("BrandName");
                int quantity = rs.getInt("total_quantity");
                Category category = null;
                if (categoryId != null && categoryName != null) {
                    category = new Category();
                    category.setCategoryId(categoryId);
                    category.setName(categoryName);
                    category.setParentCategoryId(parentCategoryId);
                }
                Brand brand = null;
                if (brandId != null && brandName != null) {
                    brand = new Brand();
                    brand.setBrandId(brandId);
                    brand.setName(brandName);
                }
                Product product = new Product(productId, productName, description, price,
                        category, brand, null, status, null, null);
                product.setImageUrl(imageUrl);
                product.setParentCategoryName(parentCategoryName);
                product.setQuantity(quantity);
                product.setStockStatus(quantity > 0 ? "In Stock" : "Out of Stock");
                list.add(product);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Xoa san pham
    public int deleteProduct(long productId) {
        String sqlFavorites = "DELETE FROM product_favorites WHERE product_id = ?";
        String sqlViewHistory = "DELETE FROM product_view_history WHERE product_id = ?";
        String sqlFeedbacks = "DELETE FROM feedbacks WHERE product_id = ?";
        String sqlCartItems = "DELETE FROM cart_items WHERE variant_id IN (SELECT variant_id FROM product_variants WHERE product_id = ?)";
        String sqlPurchaseOrderDetails = "DELETE FROM purchase_order_details WHERE variant_id IN (SELECT variant_id FROM product_variants WHERE product_id = ?)";
        String sqlProductVariants = "DELETE FROM product_variants WHERE product_id = ?";
        String sqlProduct = "DELETE FROM products WHERE product_id = ?";
        try ( Connection conn = DBContext.getNewConnection()) {
            conn.setAutoCommit(false);
            try ( PreparedStatement ps = conn.prepareStatement(sqlFavorites)) {
                ps.setLong(1, productId);
                int rowsAffected = ps.executeUpdate();
            }
            try ( PreparedStatement ps = conn.prepareStatement(sqlViewHistory)) {
                ps.setLong(1, productId);
                int rowsAffected = ps.executeUpdate();
            }
            try ( PreparedStatement ps = conn.prepareStatement(sqlFeedbacks)) {
                ps.setLong(1, productId);
                int rowsAffected = ps.executeUpdate();
            }
            try ( PreparedStatement ps = conn.prepareStatement(sqlCartItems)) {
                ps.setLong(1, productId);
                int rowsAffected = ps.executeUpdate();
            }
            try ( PreparedStatement ps = conn.prepareStatement(sqlPurchaseOrderDetails)) {
                ps.setLong(1, productId);
                int rowsAffected = ps.executeUpdate();
            }
            try ( PreparedStatement ps = conn.prepareStatement(sqlProductVariants)) {
                ps.setLong(1, productId);
                int rowsAffected = ps.executeUpdate();
            }
            try ( PreparedStatement ps = conn.prepareStatement(sqlProduct)) {
                ps.setLong(1, productId);
                int num = ps.executeUpdate();
                if (num > 0) {
                    conn.commit();
                    return 1;
                } else {
                    conn.rollback();
                    return 0;
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Database error: " + e.getMessage());
        }
    }

    // Them san pham(Admin)
    public long addProduct(Product product) throws SQLException {
        String sql = "INSERT INTO products (name, price, status, category_id, brand_id, material, description, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?,GETDATE(), GETDATE())";
        String sqlFindCategory = "SELECT category_id FROM categories WHERE name = ? AND is_active = 1";
        String sqlFindBrand = "SELECT brand_id FROM brands WHERE name = ? AND is_active = 1";
        try ( Connection conn = DBContext.getNewConnection()) {
            conn.setAutoCommit(false);
            Long categoryId = null;
            if (product.getCategory() != null) {
                if (product.getCategory().getCategoryId() != null) {
                    categoryId = product.getCategory().getCategoryId();
                } else if (product.getCategory().getName() != null && !product.getCategory().getName().isEmpty()) {
                    try ( PreparedStatement psFindCategory = conn.prepareStatement(sqlFindCategory)) {
                        psFindCategory.setString(1, product.getCategory().getName());
                        ResultSet rs = psFindCategory.executeQuery();
                        if (rs.next()) {
                            categoryId = rs.getLong("category_id");
                        } else {
                            conn.rollback();
                            throw new SQLException("Category does not exist or has been disabled: " + product.getCategory().getName());
                        }
                    }
                }
            }
            Long brandId = null;
            if (product.getBrand() != null) {
                if (product.getBrand().getBrandId() != null) {
                    brandId = product.getBrand().getBrandId();
                } else if (product.getBrand().getName() != null && !product.getBrand().getName().isEmpty()) {
                    try ( PreparedStatement psFindBrand = conn.prepareStatement(sqlFindBrand)) {
                        psFindBrand.setString(1, product.getBrand().getName());
                        ResultSet rs = psFindBrand.executeQuery();
                        if (rs.next()) {
                            brandId = rs.getLong("brand_id");
                        } else {
                            conn.rollback();
                            throw new SQLException("Trademark does not exist or has been disabled: " + product.getBrand().getName());
                        }
                    }
                }
            }
            try ( PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, product.getName());
                ps.setBigDecimal(2, product.getPrice());
                ps.setString(3, product.getStatus() != null ? product.getStatus() : "Active");
                ps.setObject(4, categoryId, Types.BIGINT);
                ps.setObject(5, brandId, Types.BIGINT);
                ps.setString(6, product.getMaterial());
                ps.setString(7, product.getDescription());
                int affectedRows = ps.executeUpdate();
                if (affectedRows == 0) {
                    conn.rollback();
                    throw new SQLException("Cannot add product.");
                }
                try ( ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        long productId = rs.getLong(1);
                        conn.commit();
                        return productId;
                    } else {
                        conn.rollback();
                        throw new SQLException("Unable to get product ID.");
                    }
                }
            }
        }
    }

    // Check trung ten san pham (Admin)
    public boolean isProductNameExists(String name) throws SQLException {
        String sql = "SELECT COUNT(*) FROM products WHERE name = ? AND status = 'Active'";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
            return false;
        }
    }

    // Them bien the
    public long addProductVariant(ProductVariant variant) throws SQLException {
        String sql = "INSERT INTO product_variants (product_id, size, color, price_modifier, sku) VALUES (?, ?, ?, ?, ?)";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setLong(1, variant.getProductId());
            ps.setString(2, variant.getSize());
            ps.setString(3, variant.getColor());
            ps.setBigDecimal(4, variant.getPriceModifier());
            ps.setString(5, generateSKU(variant));
            int affectedRows = ps.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Unable to add product variations.");
            }
            try ( ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getLong(1);
                } else {
                    throw new SQLException("Unable to get variation ID.");
                }
            }
        }
    }

    // Lam sku tu dong
    private String generateSKU(ProductVariant variant) {
        String brand = variant.getBrand() != null ? variant.getBrand().replaceAll("\\s+", "") : "UNKNOWN";
        String productName = variant.getProductName() != null ? variant.getProductName().replaceAll("\\s+", "") : "PRODUCT";
        String size = variant.getSize() != null ? variant.getSize() : "NS";
        String color = variant.getColor() != null ? variant.getColor().replaceAll("\\s+", "") : "NC";
        return String.format("%s-%s-%s-%s", brand, productName, size, color).toUpperCase();
    }

    // Them so luong
    public void addInventory(long variantId) throws SQLException {
        String sql = "INSERT INTO inventory (variant_id, quantity) VALUES (?, 0)";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, variantId);
            ps.executeUpdate();
        }
    }

    // Chen anh(Update)
    public void insertProductImage(long productId, String url, boolean isMain) throws SQLException {
        String sql = "INSERT INTO product_images (product_id, image_url, is_main) VALUES (?, ?, ?)";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, productId);
            ps.setString(2, url);
            ps.setBoolean(3, isMain);
            ps.executeUpdate();
        }
    }

    // Them anh moi(create)
    public void addProductImage(ProductImage image) throws SQLException {
        String sql = "INSERT INTO product_images (product_id, image_url, is_main, display_order) VALUES (?, ?, ?, ?)";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, image.getProductId());
            ps.setString(2, image.getImageUrl());
            ps.setBoolean(3, image.isMain());
            ps.setInt(4, image.getDisplayOrder());
            ps.executeUpdate();
        }
    }

    // Lay brand
    public List<Brand> getBrands() throws SQLException {
        List<Brand> brands = new ArrayList<>();
        String sql = "SELECT brand_id, name FROM brands WHERE is_active = 1 ORDER BY name";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql);  ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Brand brand = new Brand();
                brand.setBrandId(rs.getLong("brand_id"));
                brand.setName(rs.getString("name"));
                brands.add(brand);
            }
        }
        return brands;
    }

    // Lay category
    public List<Category> getCategories() throws SQLException {
        List<Category> categories = new ArrayList<>();
        String sql = "SELECT c.category_id, c.name, c.parent_category_id, p.name AS parent_category_name "
                + "FROM categories c "
                + "LEFT JOIN categories p ON c.parent_category_id = p.category_id "
                + "WHERE c.is_active = 1 AND (p.is_active = 1 OR p.category_id IS NULL) "
                + "ORDER BY COALESCE(p.name, ''), c.name";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql);  ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Category category = new Category();
                category.setCategoryId(rs.getLong("category_id"));
                category.setName(rs.getString("name"));
                category.setParentCategoryId(rs.getLong("parent_category_id"));
                category.setParentCategoryName(rs.getString("parent_category_name"));
                categories.add(category);
            }
        }
        return categories;
    }

    // size
    public List<String> getSizes() throws SQLException {
        List<String> sizes = new ArrayList<>();
        String sql = "SELECT DISTINCT CAST(size AS NVARCHAR(100)) AS size "
                + "FROM product_variants "
                + "WHERE size IS NOT NULL "
                + "ORDER BY CAST(size AS NVARCHAR(100))";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql);  ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                sizes.add(rs.getString("size"));
            }
        }
        return sizes;
    }

    // lay mau
    public List<String> getColors() throws SQLException {
        List<String> colors = new ArrayList<>();
        String sql = "SELECT DISTINCT CAST(color AS NVARCHAR(100)) AS color "
                + "FROM product_variants "
                + "WHERE color IS NOT NULL "
                + "ORDER BY CAST(color AS NVARCHAR(100))";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql);  ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                colors.add(rs.getString("color"));
            }
        }
        return colors;
    }

    // Lay brand name theo ID
    public String getBrandName(long brandId) throws SQLException {
        String sql = "SELECT name FROM brands WHERE brand_id = ? AND is_active = 1";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, brandId);
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("name");
                }
                return null;
            }
        }
    }

    // Lay san pham theo ID
    public Product getProductById(long productId) throws SQLException {
        String sql = "SELECT p.product_id, p.name, p.price, p.status, p.material, p.description, "
                + "p.created_at, p.updated_at, "
                + "c.category_id, c.name AS category_name, c.parent_category_id, pc.name AS parent_category_name, "
                + "b.brand_id, b.name AS brand_name "
                + "FROM products p "
                + "LEFT JOIN categories c ON p.category_id = c.category_id "
                + "LEFT JOIN categories pc ON c.parent_category_id = pc.category_id "
                + "LEFT JOIN brands b ON p.brand_id = b.brand_id "
                + "WHERE p.product_id = ? AND b.is_active = 1 AND (c.is_active = 1 OR c.category_id IS NULL) AND (pc.is_active = 1 OR pc.category_id IS NULL)";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, productId);
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Product product = new Product();
                    product.setProductId(rs.getLong("product_id"));
                    product.setName(rs.getString("name"));
                    product.setPrice(rs.getBigDecimal("price"));
                    product.setStatus(rs.getString("status"));
                    product.setMaterial(rs.getString("material"));
                    product.setDescription(rs.getString("description"));

                    // convert Timestamp từ DB (UTC) sang giờ VN
                    Timestamp createdTs = rs.getTimestamp("created_at");
                    if (createdTs != null) {
                        product.setCreatedAt(new java.util.Date(createdTs.getTime() + 7 * 60 * 60 * 1000));
                    }

                    Timestamp updatedTs = rs.getTimestamp("updated_at");
                    if (updatedTs != null) {
                        product.setUpdatedAt(new java.util.Date(updatedTs.getTime() + 7 * 60 * 60 * 1000));
                    }

                    Category category = null;
                    long categoryId = rs.getLong("category_id");
                    if (!rs.wasNull()) {
                        category = new Category();
                        category.setCategoryId(categoryId);
                        category.setName(rs.getString("category_name"));
                        long parentCategoryId = rs.getLong("parent_category_id");
                        if (!rs.wasNull()) {
                            category.setParentCategoryId(parentCategoryId);
                            category.setParentCategoryName(rs.getString("parent_category_name"));
                        }
                    }
                    product.setCategory(category);
                    Brand brand = null;
                    long brandId = rs.getLong("brand_id");
                    if (!rs.wasNull()) {
                        brand = new Brand();
                        brand.setBrandId(brandId);
                        brand.setName(rs.getString("brand_name"));
                    }
                    product.setBrand(brand);
                    return product;
                } else {
                    return null;
                }
            }
        } catch (SQLException e) {
            throw e;
        }
    }

    // update san pham
    public void updateProduct(Product product) throws SQLException {
        String sql = "UPDATE products "
                + "SET name = ?, price = ?, status = ?, category_id = ?, brand_id = ?, "
                + "material = ?, description = ?, updated_at = GETDATE() "
                + "WHERE product_id = ?";
        String sqlFindBrand = "SELECT brand_id FROM brands WHERE name = ? AND is_active = 1";
        String sqlFindCategory = "SELECT category_id FROM categories WHERE name = ? AND is_active = 1";
        try ( Connection conn = DBContext.getNewConnection()) {
            conn.setAutoCommit(false);
            Long brandId = null;
            if (product.getBrand() != null && product.getBrand().getName() != null && !product.getBrand().getName().isEmpty()) {
                try ( PreparedStatement psFindBrand = conn.prepareStatement(sqlFindBrand)) {
                    psFindBrand.setString(1, product.getBrand().getName());
                    ResultSet rs = psFindBrand.executeQuery();
                    if (rs.next()) {
                        brandId = rs.getLong("brand_id");
                    } else {
                        conn.rollback();
                        throw new SQLException("Trademark does not exist or has been disabled: " + product.getBrand().getName());
                    }
                }
            }
            Long categoryId = null;
            if (product.getCategory() != null && product.getCategory().getName() != null && !product.getCategory().getName().isEmpty()) {
                try ( PreparedStatement psFindCategory = conn.prepareStatement(sqlFindCategory)) {
                    psFindCategory.setString(1, product.getCategory().getName());
                    ResultSet rs = psFindCategory.executeQuery();
                    if (rs.next()) {
                        categoryId = rs.getLong("category_id");
                    } else {
                        conn.rollback();
                        throw new SQLException("Category does not exist or has been disabled: " + product.getCategory().getName());
                    }
                }
            }
            try ( PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, product.getName());
                ps.setBigDecimal(2, product.getPrice());
                ps.setString(3, product.getStatus());
                ps.setObject(4, categoryId != null ? categoryId
                        : product.getCategory() != null ? product.getCategory().getCategoryId() : null, Types.BIGINT);
                ps.setObject(5, brandId != null ? brandId
                        : product.getBrand() != null ? product.getBrand().getBrandId() : null, Types.BIGINT);
                ps.setString(6, product.getMaterial());
                ps.setString(7, product.getDescription());
                ps.setLong(8, product.getProductId()); 

                int affectedRows = ps.executeUpdate();
                if (affectedRows == 0) {
                    conn.rollback();
                    throw new SQLException("Unable to update product.");
                }
                conn.commit();
            }
        }
    }

    // set anh chinh(Update)
    public void updateImageMainFlag(long imageId, boolean isMain) throws SQLException {
        String sql = "UPDATE product_images SET is_main = ? WHERE image_id = ?";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, isMain);
            ps.setLong(2, imageId);
            ps.executeUpdate();
        }
    }

    // Lay bien the theo productId
    public List<ProductVariant> getProductVariantsByProductId(long productId) throws SQLException {
        List<ProductVariant> variants = new ArrayList<>();
        String sql = "SELECT pv.variant_id, pv.product_id, pv.size, pv.color, pv.price_modifier, pv.sku, "
                + "(SELECT i.quantity FROM inventory i WHERE i.variant_id = pv.variant_id) AS quantity "
                + "FROM product_variants pv "
                + "WHERE pv.product_id = ?";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, productId);
            try ( ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductVariant variant = new ProductVariant();
                    variant.setVariantId(rs.getLong("variant_id"));
                    variant.setProductId(rs.getLong("product_id"));
                    variant.setSize(rs.getString("size"));
                    variant.setColor(rs.getString("color"));
                    variant.setPriceModifier(rs.getBigDecimal("price_modifier"));
                    variant.setSku(rs.getString("sku"));
                    int quantity = rs.getInt("quantity");
                    variant.setQuantity(quantity);
                    variant.setStockStatus(quantity > 0 ? "In Stock" : "Out of Stock");
                    variants.add(variant);
                    System.out.println("ProductDAO.getProductVariantsByProductId: Variant ID " + variant.getVariantId()
                            + ", Quantity: " + quantity
                            + ", Stock Status: " + variant.getStockStatus());
                }
            }
        } catch (SQLException e) {
            throw e;
        }
        return variants;
    }

    // Cáº­p nháº­t biáº¿n thá»ƒ sáº£n pháº©m
    public void updateProductVariant(ProductVariant variant) throws SQLException {
        String sql = "UPDATE product_variants SET size = ?, color = ?, price_modifier = ?, sku = ? WHERE variant_id = ?";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, variant.getSize());
            ps.setString(2, variant.getColor());
            ps.setBigDecimal(3, variant.getPriceModifier());
            ps.setString(4, generateSKU(variant));
            ps.setLong(5, variant.getVariantId());
            int affectedRows = ps.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Unable to update product variation.");
            }
        }
    }

    public boolean variantExists(long productId, String size, String color, Long excludeVariantId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM product_variants "
                + "WHERE product_id = ? AND size = ? AND color = ? "
                + (excludeVariantId != null ? "AND variant_id <> ?" : "");
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, productId);
            ps.setString(2, size);
            ps.setString(3, color);
            if (excludeVariantId != null) {
                ps.setLong(4, excludeVariantId);
            }
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0; // true
                }
            }
        }
        return false;
    }

    // XÃ³a biáº¿n thá»ƒ sáº£n pháº©m
    public void deleteProductVariant(long variantId) throws SQLException {
        String sqlCheckInventory = "SELECT quantity FROM inventory WHERE variant_id = ?";
        String sqlInventory = "DELETE FROM inventory WHERE variant_id = ?";
        String sqlVariant = "DELETE FROM product_variants WHERE variant_id = ?";
        try ( Connection conn = DBContext.getNewConnection()) {
            conn.setAutoCommit(false);
            try ( PreparedStatement psCheck = conn.prepareStatement(sqlCheckInventory)) {
                psCheck.setLong(1, variantId);
                ResultSet rs = psCheck.executeQuery();
                if (rs.next() && rs.getInt("quantity") > 0) {
                    conn.rollback();
                    throw new SQLException("Cannot delete variant because it is still in stock.");
                }
            }
            try ( PreparedStatement psInventory = conn.prepareStatement(sqlInventory)) {
                psInventory.setLong(1, variantId);
                psInventory.executeUpdate();
            }
            try ( PreparedStatement psVariant = conn.prepareStatement(sqlVariant)) {
                psVariant.setLong(1, variantId);
                psVariant.executeUpdate();
            }
            conn.commit();
        }
    }

    // Láº¥y danh sÃ¡ch áº£nh theo productId
    public List<ProductImage> getProductImagesByProductId(long productId) throws SQLException {
        List<ProductImage> images = new ArrayList<>();
        String sql = "SELECT image_id, product_id, image_url, is_main, display_order FROM product_images WHERE product_id = ?";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, productId);
            try ( ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductImage image = new ProductImage();
                    image.setImageId(rs.getLong("image_id"));
                    image.setProductId(rs.getLong("product_id"));
                    image.setImageUrl(rs.getString("image_url"));
                    image.setMain(rs.getBoolean("is_main"));
                    image.setDisplayOrder(rs.getInt("display_order"));
                    images.add(image);
                }
            }
        }
        return images;
    }

    // XÃ³a áº£nh sáº£n pháº©m
    public void deleteProductImage(long imageId) throws SQLException {
        String sql = "DELETE FROM product_images WHERE image_id = ?";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, imageId);
            ps.executeUpdate();
        }
    }

    // san pham theo category_id (PRODUCT LIST)
    public List<Product> getProductsByCategories(List<Long> categoryIds, int offset) throws SQLException {
        List<Product> products = new ArrayList<>();
        if (categoryIds == null || categoryIds.isEmpty()) {
            return products;
        }
        StringBuilder placeholders = new StringBuilder();
        for (int i = 0; i < categoryIds.size(); i++) {
            placeholders.append("?");
            if (i < categoryIds.size() - 1) {
                placeholders.append(",");
            }
        }
        String sql = "SELECT p.product_id, p.name, p.description, p.price, p.category_id, p.brand_id, "
                + "p.material, p.status, p.created_at, p.updated_at, "
                + "c.name AS category_name, c.parent_category_id, pc.name AS parent_category_name, "
                + "(SELECT TOP 1 image_url FROM product_images pi WHERE pi.product_id = p.product_id AND pi.is_main = 1) AS image_url, "
                + "(SELECT SUM(i.quantity) FROM inventory i JOIN product_variants pv ON i.variant_id = pv.variant_id WHERE pv.product_id = p.product_id) AS total_quantity "
                + "FROM products p "
                + "JOIN categories c ON p.category_id = c.category_id "
                + "LEFT JOIN categories pc ON c.parent_category_id = pc.category_id "
                + "LEFT JOIN brands b ON p.brand_id = b.brand_id "
                + "WHERE p.category_id IN (" + placeholders.toString() + ") AND p.status = 'Active' AND c.is_active = 1 AND b.is_active = 1 AND (pc.is_active = 1 OR pc.category_id IS NULL) "
                + "ORDER BY p.product_id "
                + "OFFSET ? ROWS FETCH NEXT 100 ROWS ONLY";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement stmt = conn.prepareStatement(sql)) {
            for (int i = 0; i < categoryIds.size(); i++) {
                stmt.setLong(i + 1, categoryIds.get(i));
            }
            stmt.setInt(categoryIds.size() + 1, offset);
            try ( ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Product product = new Product();
                    product.setProductId(rs.getLong("product_id"));
                    product.setName(rs.getString("name"));
                    product.setDescription(rs.getString("description"));
                    product.setPrice(rs.getBigDecimal("price"));
                    product.setCategoryId(rs.getLong("category_id"));
                    product.setBrandId(rs.getLong("brand_id"));
                    product.setMaterial(rs.getString("material"));
                    product.setStatus(rs.getString("status"));
                    product.setCreatedAt(rs.getTimestamp("created_at"));
                    product.setUpdatedAt(rs.getTimestamp("updated_at"));
                    product.setImageUrl(rs.getString("image_url"));
                    int quantity = rs.getInt("total_quantity");
                    product.setQuantity(quantity);
                    product.setStockStatus(quantity > 0 ? "In Stock" : "Out of Stock");
                    Category category = new Category();
                    category.setCategoryId(rs.getLong("category_id"));
                    category.setName(rs.getString("category_name"));
                    category.setParentCategoryId(rs.getLong("parent_category_id"));
                    product.setCategory(category);
                    product.setParentCategoryName(rs.getString("parent_category_name"));
                    products.add(product);
                }
            }
        } catch (SQLException e) {
            throw e;
        }
        return products;
    }

    // search home page
    public List<Product> searchProductsForHomePage(String keyword) {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT TOP 5 p.product_id, p.name, p.price, "
                + "(SELECT TOP 1 image_url FROM product_images WHERE product_id = p.product_id AND is_main = 1) AS main_image_url "
                + "FROM products p "
                + "LEFT JOIN categories c ON p.category_id = c.category_id "
                + "LEFT JOIN categories pc ON c.parent_category_id = pc.category_id "
                + "LEFT JOIN brands b ON p.brand_id = b.brand_id "
                + "WHERE p.status = 'Active' AND LOWER(p.name) LIKE LOWER(?) AND b.is_active = 1 AND (c.is_active = 1 OR c.category_id IS NULL) AND (pc.is_active = 1 OR pc.category_id IS NULL)";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "%" + keyword + "%");
            try ( ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product product = new Product();
                    product.setProductId(rs.getLong("product_id"));
                    product.setName(rs.getString("name"));
                    product.setPrice(rs.getBigDecimal("price"));
                    String imageUrl = rs.getString("main_image_url");
                    product.setImageUrl(imageUrl != null ? imageUrl : "https://placehold.co/50x50");
                    list.add(product);
                }
            }
            return list;
        } catch (SQLException e) {
            e.printStackTrace();
            return list;
        }
    }

    // loc product
    public List<Product> filterProducts(List<Long> categoryIds, List<Long> brandIds, List<String> sizes, List<String> colors, BigDecimal minPrice, BigDecimal maxPrice, String sort) throws SQLException {
        List<Product> products = new ArrayList<>();
        if (categoryIds == null || categoryIds.isEmpty()) {
            return products;
        }

        String sql = "SELECT DISTINCT "
                + "p.product_id, p.name, CAST(p.description AS NVARCHAR(MAX)) AS description, "
                + "p.price, p.category_id, p.brand_id, CAST(p.material AS NVARCHAR(MAX)) AS material, "
                + "p.status, p.created_at, p.updated_at, "
                + "(SELECT TOP 1 image_url FROM product_images pi "
                + " WHERE pi.product_id = p.product_id AND pi.is_main = 1) AS main_image, "
                + "(SELECT SUM(i.quantity) FROM inventory i "
                + " JOIN product_variants pv2 ON i.variant_id = pv2.variant_id "
                + " WHERE pv2.product_id = p.product_id) AS total_quantity "
                + "FROM products p "
                + "JOIN categories c ON p.category_id = c.category_id "
                + "LEFT JOIN categories pc ON c.parent_category_id = pc.category_id "
                + "LEFT JOIN brands b ON p.brand_id = b.brand_id "
                + "WHERE p.status = 'Active' AND c.is_active = 1 AND b.is_active = 1 "
                + "AND (pc.is_active = 1 OR pc.category_id IS NULL) "
                + "AND p.category_id IN (" + String.join(",", Collections.nCopies(categoryIds.size(), "?")) + ")";

        if (brandIds != null && !brandIds.isEmpty()) {
            sql += " AND p.brand_id IN (" + String.join(",", Collections.nCopies(brandIds.size(), "?")) + ")";
        }
        if (sizes != null && !sizes.isEmpty()) {
            sql += " AND EXISTS (SELECT 1 FROM product_variants pv_s "
                    + "WHERE pv_s.product_id = p.product_id AND pv_s.size IN ("
                    + String.join(",", Collections.nCopies(sizes.size(), "?")) + "))";
        }
        if (colors != null && !colors.isEmpty()) {
            sql += " AND EXISTS (SELECT 1 FROM product_variants pv_c "
                    + "WHERE pv_c.product_id = p.product_id AND pv_c.color IN ("
                    + String.join(",", Collections.nCopies(colors.size(), "?")) + "))";
        }
        if (minPrice != null) {
            sql += " AND p.price >= ?";
        }
        if (maxPrice != null) {
            sql += " AND p.price <= ?";
        }

        if ("price_asc".equals(sort)) {
            sql += " ORDER BY p.price ASC";
        } else if ("price_desc".equals(sort)) {
            sql += " ORDER BY p.price DESC";
        } else {
            sql += " ORDER BY p.product_id DESC";
        }

        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {

            int idx = 1;
            for (Long cid : categoryIds) {
                ps.setLong(idx++, cid);
            }
            if (brandIds != null && !brandIds.isEmpty()) {
                for (Long bid : brandIds) {
                    ps.setLong(idx++, bid);
                }
            }
            if (sizes != null && !sizes.isEmpty()) {
                for (String s : sizes) {
                    ps.setString(idx++, s);
                }
            }
            if (colors != null && !colors.isEmpty()) {
                for (String c : colors) {
                    ps.setString(idx++, c);
                }
            }
            if (minPrice != null) {
                ps.setBigDecimal(idx++, minPrice);
            }
            if (maxPrice != null) {
                ps.setBigDecimal(idx++, maxPrice);
            }

            try ( ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product p = new Product();
                    p.setProductId(rs.getLong("product_id"));
                    p.setName(rs.getString("name"));
                    p.setDescription(rs.getString("description"));
                    p.setPrice(rs.getBigDecimal("price"));
                    p.setCategoryId(rs.getLong("category_id"));
                    p.setBrandId(rs.getLong("brand_id"));
                    p.setMaterial(rs.getString("material"));
                    p.setStatus(rs.getString("status"));
                    p.setCreatedAt(rs.getTimestamp("created_at"));
                    p.setUpdatedAt(rs.getTimestamp("updated_at"));

                    String mainImage = rs.getString("main_image");
                    p.setImageUrl(mainImage != null ? mainImage
                            : "https://placehold.co/400x500/f0f0f0/333?text=No+Image");

                    int quantity = rs.getInt("total_quantity");
                    p.setQuantity(quantity);
                    p.setStockStatus(quantity > 0 ? "In Stock" : "Out of Stock");

                    List<ProductImage> imgs = getProductImagesByProductId(conn, p.getProductId());
                    p.setImages(imgs);

                    products.add(p);
                }
            }
        }
        return products;
    }

    public List<ProductImage> getProductImagesByProductId(Connection conn, long productId) throws SQLException {
        List<ProductImage> images = new ArrayList<>();
        String sql = "SELECT image_id, product_id, image_url, is_main, display_order "
                + "FROM product_images WHERE product_id = ?";
        try ( PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, productId);
            try ( ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductImage image = new ProductImage();
                    image.setImageId(rs.getLong("image_id"));
                    image.setProductId(rs.getLong("product_id"));
                    image.setImageUrl(rs.getString("image_url"));
                    image.setMain(rs.getBoolean("is_main"));
                    image.setDisplayOrder(rs.getInt("display_order"));
                    images.add(image);
                }
            }
        }
        return images;
    }
    
    // Lấy sản phẩm Best Seller (Frontend)
public List<Product> getBestSellers(int limit) {
    List<Product> list = new ArrayList<>();
    String sql = "SELECT TOP (?) p.product_id, p.name, p.price, p.status, " +
                 "       (SELECT TOP 1 image_url " +
                 "        FROM product_images pi " +
                 "        WHERE pi.product_id = p.product_id AND pi.is_main = 1) AS main_image, " +
                 "       SUM(oi.quantity) AS total_sold, " +
                 "       (SELECT SUM(i.quantity) " +
                 "        FROM inventory i " +
                 "        JOIN product_variants pv2 ON i.variant_id = pv2.variant_id " +
                 "        WHERE pv2.product_id = p.product_id) AS total_quantity " +
                 "FROM products p " +
                 "JOIN product_variants pv ON p.product_id = pv.product_id " +
                 "JOIN order_items oi ON pv.variant_id = oi.variant_id " +
                 "JOIN orders o ON oi.order_id = o.order_id " +
                 "JOIN brands b ON p.brand_id = b.brand_id " +
                 "JOIN categories c ON p.category_id = c.category_id " +
                 "LEFT JOIN categories pc ON c.parent_category_id = pc.category_id " +
                 "WHERE p.status = 'Active' " +
                 "  AND b.is_active = 1 " +
                 "  AND c.is_active = 1 " +
                 "  AND (pc.is_active = 1 OR pc.category_id IS NULL) " +
                 "  AND o.status IN ('SHIPPED', 'COMPLETED') " + // chỉ tính đơn đã giao/hoàn tất
                 "  AND o.order_date >= DATEADD(MONTH, -1, GETDATE()) " + // 1 tháng gần nhất
                 "GROUP BY p.product_id, p.name, p.price, p.status " +
                 "ORDER BY total_sold DESC";

    try (Connection conn = DBContext.getNewConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, limit);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Product product = new Product();
            product.setProductId(rs.getLong("product_id"));
            product.setName(rs.getString("name"));
            product.setPrice(rs.getBigDecimal("price"));
            product.setStatus(rs.getString("status"));
            product.setImageUrl(rs.getString("main_image"));

            int totalSold = rs.getInt("total_sold");
            int totalQuantity = rs.getInt("total_quantity");

            product.setQuantity(totalQuantity);
            product.setStockStatus(totalQuantity > 0 ? "In Stock" : "Out of Stock");
            product.setDescription("Đã bán " + totalSold);

            list.add(product);
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    return list;
}



    // lay so luong kho theo variantId (dat)
    public int getAvailableQuantityByVariantId(Long variantId) {
        if (variantId == null || variantId == 0) {
            return 0;
        }
        String sql = "SELECT quantity FROM inventory WHERE variant_id = ?";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, variantId);
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("quantity");
                }
            }
        } catch (SQLException e) {
            System.err.println("ProductDAO.getAvailableQuantityByVariantId: Error - " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }
}
