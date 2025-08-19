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
import java.util.Date;

/**
 * Data Access Object for Product-related database operations.
 */
public class ProductDAO {

    public List<Product> getAll() {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT p.product_id, p.name, p.description, p.price, p.category_id, p.brand_id, p.material, p.status, "
                + "p.created_at, p.updated_at, c.category_id, c.name AS category_name, c.description AS category_description, "
                + "c.parent_category_id, c.is_active AS category_active, c.created_at AS category_created_at, "
                + "b.brand_id, b.name AS brand_name, b.description AS brand_description, b.logo_url, b.is_active AS brand_active, "
                + "b.created_at AS brand_created_at, "
                + "(SELECT TOP 1 image_url FROM product_images WHERE product_id = p.product_id AND is_main = 1) AS main_image_url "
                + "FROM products p "
                + "LEFT JOIN categories c ON p.category_id = c.category_id "
                + "LEFT JOIN brands b ON p.brand_id = b.brand_id";

        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql);  ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Product product = mapProduct(rs);
                product.setVariants(getVariantsByProductId(product.getProductId()));
                product.setImages(getImagesByProductId(product.getProductId()));
                list.add(product);
            }
            return list;
        } catch (SQLException e) {
            System.out.println("Error in getAll: " + e.getMessage());
            e.printStackTrace();
            return list;
        }
    }

    public Product getProductById(long productId) {
        String sql = "SELECT p.product_id, p.name, p.description, p.price, p.category_id, p.brand_id, p.material, p.status, "
                + "p.created_at, p.updated_at, c.category_id, c.name AS category_name, c.description AS category_description, "
                + "c.parent_category_id, c.is_active AS category_active, c.created_at AS category_created_at, "
                + "b.brand_id, b.name AS brand_name, b.description AS brand_description, b.logo_url, b.is_active AS brand_active, "
                + "b.created_at AS brand_created_at, "
                + "(SELECT TOP 1 image_url FROM product_images WHERE product_id = p.product_id AND is_main = 1) AS main_image_url "
                + "FROM products p "
                + "LEFT JOIN categories c ON p.category_id = c.category_id "
                + "LEFT JOIN brands b ON p.brand_id = b.brand_id "
                + "WHERE p.product_id = ?";

        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, productId);
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Product product = mapProduct(rs);
                    product.setVariants(getVariantsByProductId(productId));
                    product.setImages(getImagesByProductId(productId));
                    return product;
                }
            }
            return null;
        } catch (SQLException e) {
            System.out.println("Error in getProductById: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }

    public List<Product> filterProductsForShopWithSort(List<String> colors, List<String> sizes, BigDecimal maxPrice,
            List<Long> brandIds, Long parentCategoryId, Long categoryId, int page, int pageSize, String sort) {
        List<Product> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT p.product_id, p.name, p.price, p.created_at, p.category_id, p.brand_id, p.status, "
                + "c.name AS category_name, c.parent_category_id, c.is_active AS category_active, "
                + "b.name AS brand_name, b.is_active AS brand_active, "
                + "(SELECT TOP 1 image_url FROM product_images WHERE product_id = p.product_id AND is_main = 1) AS main_image_url, "
                + "(SELECT TOP 1 variant_id FROM product_variants WHERE product_id = p.product_id) AS default_variant_id "
                + "FROM products p "
                + "JOIN categories c ON p.category_id = c.category_id "
                + "LEFT JOIN brands b ON p.brand_id = b.brand_id "
                + "WHERE p.status = 'Active' AND c.is_active = 1"
        );

        List<Object> params = new ArrayList<>();
        int offset = (page - 1) * pageSize;

        if (categoryId != null) {
            sql.append(" AND p.category_id = ?");
            params.add(categoryId);
            if (parentCategoryId != null) {
                sql.append(" AND c.parent_category_id = ?");
                params.add(parentCategoryId);
            }
            System.out.println("filterProductsForShopWithSort - Filtering by categoryId: " + categoryId + ", parentCategoryId: " + parentCategoryId);
        } else if (parentCategoryId != null) {
            sql.append(" AND c.parent_category_id = ?");
            params.add(parentCategoryId);
            System.out.println("filterProductsForShopWithSort - Filtering by parentCategoryId: " + parentCategoryId);
        } else {
            System.out.println("filterProductsForShopWithSort - No category filter applied.");
        }

        if (colors != null && !colors.isEmpty()) {
            sql.append(" AND EXISTS (SELECT 1 FROM product_variants pv WHERE pv.product_id = p.product_id AND LOWER(pv.color) IN (");
            for (int i = 0; i < colors.size(); i++) {
                if (i > 0) {
                    sql.append(", ");
                }
                sql.append("?");
                params.add(colors.get(i).toLowerCase());
            }
            sql.append("))");
            System.out.println("filterProductsForShopWithSort - Filtering by colors: " + colors);
        }

        if (sizes != null && !sizes.isEmpty()) {
            sql.append(" AND EXISTS (SELECT 1 FROM product_variants pv WHERE pv.product_id = p.product_id AND LOWER(pv.size) IN (");
            for (int i = 0; i < sizes.size(); i++) {
                if (i > 0) {
                    sql.append(", ");
                }
                sql.append("?");
                params.add(sizes.get(i).toLowerCase());
            }
            sql.append("))");
            System.out.println("filterProductsForShopWithSort - Filtering by sizes: " + sizes);
        }

        if (maxPrice != null) {
            sql.append(" AND p.price <= ?");
            params.add(maxPrice);
            System.out.println("filterProductsForShopWithSort - Filtering by maxPrice: " + maxPrice);
        }

        if (brandIds != null && !brandIds.isEmpty()) {
            sql.append(" AND p.brand_id IN (");
            for (int i = 0; i < brandIds.size(); i++) {
                if (i > 0) {
                    sql.append(", ");
                }
                sql.append("?");
                params.add(brandIds.get(i));
            }
            sql.append(") AND p.brand_id IS NOT NULL");
            System.out.println("filterProductsForShopWithSort - Filtering by brandIds: " + brandIds);
        }

        System.out.println("filterProductsForShopWithSort - Applying sort: " + sort);
        switch (sort != null ? sort.toLowerCase() : "created_at_desc") {
            case "name_asc":
                sql.append(" ORDER BY p.name ASC");
                break;
            case "name_desc":
                sql.append(" ORDER BY p.name DESC");
                break;
            case "price_asc":
                sql.append(" ORDER BY p.price ASC");
                break;
            case "price_desc":
                sql.append(" ORDER BY p.price DESC");
                break;
            case "created_at_desc":
            default:
                sql.append(" ORDER BY p.created_at DESC");
                break;
        }

        sql.append(" OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add(offset);
        params.add(pageSize);

        System.out.println("filterProductsForShopWithSort - SQL Query: " + sql.toString());
        System.out.println("filterProductsForShopWithSort - Parameters: " + params);

        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try ( ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product product = new Product();
                    product.setProductId(rs.getLong("product_id"));
                    product.setName(rs.getString("name"));
                    product.setPrice(rs.getBigDecimal("price"));
                    product.setCreatedAt(rs.getTimestamp("created_at"));
                    product.setStatus(rs.getString("status"));
                    product.setImageUrl(rs.getString("main_image_url"));
                    product.setDefaultVariantId(rs.getLong("default_variant_id"));

                    Category category = new Category();
                    category.setCategoryId(rs.getLong("category_id"));
                    category.setName(rs.getString("category_name"));
                    category.setParentCategoryId(rs.getLong("parent_category_id"));
                    category.setActive(rs.getBoolean("category_active"));
                    product.setCategory(category);

                    Brand brand = new Brand();
                    brand.setBrandId(rs.getLong("brand_id"));
                    brand.setName(rs.getString("brand_name"));
                    brand.setActive(rs.getBoolean("brand_active"));
                    product.setBrand(brand);

                    product.setVariants(getVariantsByProductId(product.getProductId()));
                    product.setImages(getImagesByProductId(product.getProductId()));
                    list.add(product);

                    System.out.println("filterProductsForShopWithSort - Product ID: " + product.getProductId()
                            + ", Name: " + product.getName()
                            + ", Price: " + product.getPrice()
                            + ", Created At: " + product.getCreatedAt());
                }
            }
            System.out.println("filterProductsForShopWithSort - Returned " + list.size() + " products for sort: " + sort);
            return list;
        } catch (SQLException e) {
            System.err.println("filterProductsForShopWithSort - SQLException: " + e.getMessage());
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    public List<Product> getNewArrivals(int limit) {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT TOP (?) p.product_id, p.name, p.price, p.created_at, "
                + "(SELECT TOP 1 image_url FROM product_images WHERE product_id = p.product_id AND is_main = 1) AS main_image_url, "
                + "(SELECT TOP 1 pv.variant_id FROM product_variants pv "
                + " WHERE pv.product_id = p.product_id "
                + " AND (SELECT SUM(CASE WHEN movement_type = 'In' THEN quantity_changed "
                + "                     WHEN movement_type = 'Out' THEN -quantity_changed "
                + "                     WHEN movement_type = 'Adjustment' THEN quantity_changed "
                + "                     WHEN movement_type = 'Reserved' THEN -quantity_changed "
                + "                     WHEN movement_type = 'Released' THEN quantity_changed "
                + "                     ELSE 0 END) "
                + "      FROM stock_movements WHERE variant_id = pv.variant_id) > 0 "
                + " ORDER BY pv.variant_id) AS default_variant_id "
                + "FROM products p "
                + "WHERE p.status = 'Active' "
                + "ORDER BY p.created_at DESC";

        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try ( ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product product = new Product();
                    product.setProductId(rs.getLong("product_id"));
                    product.setName(rs.getString("name"));
                    product.setPrice(rs.getBigDecimal("price"));
                    product.setCreatedAt(rs.getTimestamp("created_at"));
                    product.setImageUrl(rs.getString("main_image_url"));
                    Long variantId = rs.getLong("default_variant_id");
                    product.setDefaultVariantId(rs.wasNull() ? null : variantId);
                    System.out.println("getNewArrivals - Product ID: " + product.getProductId() + ", variantId: " + variantId);
                    list.add(product);
                }
            }
            return list;
        } catch (SQLException e) {
            System.out.println("Error in getNewArrivals: " + e.getMessage());
            e.printStackTrace();
            return list;
        }
    }

    public List<Product> searchProducts(String keyword) {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT TOP 5 p.product_id, p.name, p.price, "
                + "(SELECT TOP 1 image_url FROM product_images WHERE product_id = p.product_id AND is_main = 1) AS main_image_url "
                + "FROM products p "
                + "WHERE p.status = 'Active' AND LOWER(p.name) LIKE LOWER(?)";

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
            System.out.println("Error in searchProducts: " + e.getMessage());
            e.printStackTrace();
            return list;
        }
    }

    public long insert(String name, String description, BigDecimal price, long categoryId, long brandId,
            String material, String status, List<ProductVariant> variants, List<ProductImage> images) {
        String sql = "INSERT INTO products (name, description, price, category_id, brand_id, material, status, created_at) "
                + "OUTPUT INSERTED.product_id VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        String checkSkuSql = "SELECT sku FROM product_variants WHERE sku = ?";
        String variantSql = "INSERT INTO product_variants (product_id, size, color, price_modifier, sku) "
                + "OUTPUT INSERTED.variant_id VALUES (?, ?, ?, ?, ?)";

        try ( Connection conn = DBContext.getNewConnection()) {
            conn.setAutoCommit(false);
            try ( PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, name);
                ps.setString(2, description);
                ps.setBigDecimal(3, price);
                ps.setLong(4, categoryId);
                ps.setLong(5, brandId);
                ps.setString(6, material);
                ps.setString(7, status);
                ps.setTimestamp(8, new java.sql.Timestamp(new Date().getTime()));
                try ( ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        long productId = rs.getLong("product_id");
                        try ( PreparedStatement psCheckSku = conn.prepareStatement(checkSkuSql);  PreparedStatement psVariant = conn.prepareStatement(variantSql)) {
                            for (int i = 0; i < variants.size(); i++) {
                                ProductVariant variant = variants.get(i);
                                String sku = variant.getSku();
                                if (sku == null || sku.length() > 100) {
                                    conn.rollback();
                                    System.out.println("Invalid SKU: " + (sku == null ? "null" : "exceeds 100 characters"));
                                    throw new IllegalArgumentException("Invalid SKU for variant " + (i + 1));
                                }

                                if (isVariantExists(productId, variant.getSize(), variant.getColor())) {
                                    conn.rollback();
                                    System.out.println("Duplicate variant: Size=" + variant.getSize() + ", Color=" + variant.getColor());
                                    throw new IllegalArgumentException("Duplicate variant with size '" + variant.getSize() + "' and color '" + variant.getColor() + "' for variant " + (i + 1));
                                }

                                BigDecimal priceModifier = variant.getPriceModifier();
                                if (priceModifier.compareTo(price) < 0) {
                                    conn.rollback();
                                    System.out.println("Price modifier less than base price: Price=" + price + ", Modifier=" + priceModifier);
                                    throw new IllegalArgumentException("Price modifier (" + priceModifier + ") for variant " + (i + 1) + " must be greater than or equal to base price (" + price + ")");
                                }

                                psCheckSku.setString(1, sku);
                                try ( ResultSet rsSku = psCheckSku.executeQuery()) {
                                    if (rsSku.next()) {
                                        conn.rollback();
                                        System.out.println("Duplicate SKU: " + sku);
                                        throw new IllegalArgumentException("SKU '" + sku + "' already exists for variant " + (i + 1));
                                    }
                                }

                                psVariant.setLong(1, productId);
                                psVariant.setString(2, variant.getSize());
                                psVariant.setString(3, variant.getColor());
                                psVariant.setBigDecimal(4, priceModifier);
                                psVariant.setString(5, sku);
                                try ( ResultSet rsVariant = psVariant.executeQuery()) {
                                    if (rsVariant.next()) {
                                        long variantId = rsVariant.getLong("variant_id");
                                        String inventorySql = "INSERT INTO inventory (variant_id, quantity, reserved_quantity) VALUES (?, 0, 0)";
                                        try ( PreparedStatement psInventory = conn.prepareStatement(inventorySql)) {
                                            psInventory.setLong(1, variantId);
                                            psInventory.executeUpdate();
                                        }
                                    } else {
                                        conn.rollback();
                                        System.out.println("Failed to retrieve variant_id for SKU: " + sku);
                                        return 0;
                                    }
                                }
                            }
                        }

                        for (ProductImage image : images) {
                            insertProductImage(productId, image, conn);
                        }

                        conn.commit();
                        return productId;
                    } else {
                        conn.rollback();
                        System.out.println("Failed to retrieve product_id after insert");
                        return 0;
                    }
                }
            }
        } catch (SQLException e) {
            System.out.println("Database error: " + e.getMessage());
            throw new RuntimeException("Database error: " + e.getMessage());
        } catch (IllegalArgumentException e) {
            System.out.println("Validation error: " + e.getMessage());
            throw e;
        }
    }

    private void insertProductImage(long productId, ProductImage image, Connection conn) throws SQLException {
        String sql = "INSERT INTO product_images (product_id, variant_id, image_url, display_order, is_main, created_at) "
                + "VALUES (?, ?, ?, ?, ?, ?)";
        try ( PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, productId);
            if (image.getVariantId() == null) {
                ps.setNull(2, java.sql.Types.BIGINT);
            } else {
                ps.setLong(2, image.getVariantId());
            }
            ps.setString(3, image.getImageUrl());
            ps.setInt(4, image.getDisplayOrder());
            ps.setBoolean(5, image.isMain());
            ps.setTimestamp(6, new java.sql.Timestamp(new Date().getTime()));
            ps.executeUpdate();
        }
    }

    public boolean update(long id, String name, String description, BigDecimal price, long categoryId, long brandId,
            String material, String status, List<ProductVariant> variants, List<ProductImage> images) {
        try ( Connection conn = DBContext.getNewConnection()) {
            conn.setAutoCommit(false);
            String productSql = "UPDATE products SET name = ?, description = ?, price = ?, category_id = ?, brand_id = ?, "
                    + "material = ?, status = ?, updated_at = ? WHERE product_id = ?";
            try ( PreparedStatement psProduct = conn.prepareStatement(productSql)) {
                psProduct.setString(1, name);
                psProduct.setString(2, description);
                psProduct.setBigDecimal(3, price);
                psProduct.setLong(4, categoryId);
                psProduct.setLong(5, brandId);
                psProduct.setString(6, material);
                psProduct.setString(7, status);
                psProduct.setTimestamp(8, new java.sql.Timestamp(new Date().getTime()));
                psProduct.setLong(9, id);
                int productRows = psProduct.executeUpdate();

                if (productRows == 0) {
                    conn.rollback();
                    System.out.println("Product update failed: No product found for ID " + id);
                    return false;
                }
            }

            List<Long> existingVariantIds = new ArrayList<>();
            String selectVariantsSql = "SELECT variant_id FROM product_variants WHERE product_id = ?";
            try ( PreparedStatement psSelectVariants = conn.prepareStatement(selectVariantsSql)) {
                psSelectVariants.setLong(1, id);
                try ( ResultSet rs = psSelectVariants.executeQuery()) {
                    while (rs.next()) {
                        existingVariantIds.add(rs.getLong("variant_id"));
                    }
                }
            }

            String checkSkuSql = "SELECT sku FROM product_variants WHERE sku = ? AND variant_id != ?";
            String updateVariantSql = "UPDATE product_variants SET size = ?, color = ?, price_modifier = ?, sku = ? "
                    + "WHERE variant_id = ? AND product_id = ?";
            String insertVariantSql = "INSERT INTO product_variants (product_id, size, color, price_modifier, sku) "
                    + "VALUES (?, ?, ?, ?, ?); SELECT SCOPE_IDENTITY() AS variant_id;";
            try ( PreparedStatement psCheckSku = conn.prepareStatement(checkSkuSql);  PreparedStatement psUpdateVariant = conn.prepareStatement(updateVariantSql);  PreparedStatement psInsertVariant = conn.prepareStatement(insertVariantSql)) {
                List<Long> submittedVariantIds = new ArrayList<>();
                for (ProductVariant variant : variants) {
                    String sku = variant.getSku();
                    if (sku == null || sku.trim().isEmpty() || sku.length() > 100) {
                        conn.rollback();
                        System.out.println("Invalid SKU for variant: " + (sku == null ? "null" : sku));
                        return false;
                    }

                    Long variantId = variant.getVariantId();
                    psCheckSku.setString(1, sku);
                    psCheckSku.setLong(2, variantId != null ? variantId : 0);
                    try ( ResultSet rsSku = psCheckSku.executeQuery()) {
                        if (rsSku.next()) {
                            conn.rollback();
                            System.out.println("Duplicate SKU: " + sku);
                            return false;
                        }
                    }

                    if (variantId != null) {
                        psUpdateVariant.setString(1, variant.getSize());
                        psUpdateVariant.setString(2, variant.getColor());
                        psUpdateVariant.setBigDecimal(3, variant.getPriceModifier());
                        psUpdateVariant.setString(4, sku);
                        psUpdateVariant.setLong(5, variantId);
                        psUpdateVariant.setLong(6, id);
                        psUpdateVariant.executeUpdate();
                        submittedVariantIds.add(variantId);
                    } else {
                        psInsertVariant.setLong(1, id);
                        psInsertVariant.setString(2, variant.getSize());
                        psInsertVariant.setString(3, variant.getColor());
                        psInsertVariant.setBigDecimal(4, variant.getPriceModifier());
                        psInsertVariant.setString(5, sku);
                        try ( ResultSet rsVariant = psInsertVariant.executeQuery()) {
                            if (rsVariant.next()) {
                                long newVariantId = rsVariant.getLong("variant_id");
                                String inventorySql = "INSERT INTO inventory (variant_id, quantity, reserved_quantity) VALUES (?, 0, 0)";
                                try ( PreparedStatement psInventory = conn.prepareStatement(inventorySql)) {
                                    psInventory.setLong(1, newVariantId);
                                    psInventory.executeUpdate();
                                }
                            } else {
                                conn.rollback();
                                System.out.println("Failed to retrieve variant_id for SKU: " + sku);
                                return false;
                            }
                        }
                    }
                }

                String deleteVariantSql = "DELETE FROM product_variants WHERE variant_id = ? AND product_id = ?";
                try ( PreparedStatement psDeleteVariant = conn.prepareStatement(deleteVariantSql)) {
                    for (Long existingId : existingVariantIds) {
                        if (!submittedVariantIds.contains(existingId)) {
                            psDeleteVariant.setLong(1, existingId);
                            psDeleteVariant.setLong(2, id);
                            psDeleteVariant.executeUpdate();
                        }
                    }
                }

                String deleteImageSql = "DELETE FROM product_images WHERE product_id = ?";
                try ( PreparedStatement psDeleteImage = conn.prepareStatement(deleteImageSql)) {
                    psDeleteImage.setLong(1, id);
                    psDeleteImage.executeUpdate();
                }

                if (images != null && !images.isEmpty()) {
                    for (ProductImage image : images) {
                        insertProductImage(id, image, conn);
                    }
                }
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            System.out.println("Database error in update: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public void clearMainImageFlags(long productId) {
        String sql = "UPDATE product_images SET is_main = false WHERE product_id = ?";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, productId);
            ps.executeUpdate();
        } catch (SQLException e) {
            System.out.println("Error clearing main image flags: " + e.getMessage());
            e.printStackTrace();
        }
    }

    public String getBrandNameById(long brandId) {
        String sql = "SELECT name FROM brands WHERE brand_id = ?";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, brandId);
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("name");
                }
                return null;
            }
        } catch (SQLException e) {
            System.out.println("Error fetching brand name: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }

    public int delete(long productId) {
        String sqlFavorites = "DELETE FROM product_favorites WHERE product_id = ?";
        String sqlViewHistory = "DELETE FROM product_view_history WHERE product_id = ?";
        String sqlFeedbacks = "DELETE FROM feedbacks WHERE product_id = ?";
        String sqlCartItems = "DELETE FROM cart_items WHERE variant_id IN (SELECT variant_id FROM product_variants WHERE product_id = ?)";
        String sqlPurchaseOrderDetails = "DELETE FROM purchase_order_details WHERE variant_id IN (SELECT variant_id FROM product_variants WHERE product_id = ?)";
        String sqlProductVariants = "DELETE FROM product_variants WHERE product_id = ?";
        String sqlProduct = "DELETE FROM products WHERE product_id = ?";

        try ( Connection conn = DBContext.getNewConnection()) {
            conn.setAutoCommit(false);
            System.out.println("Bắt đầu xóa sản phẩm ID: " + productId);

            try ( PreparedStatement ps = conn.prepareStatement(sqlFavorites)) {
                ps.setLong(1, productId);
                int rowsAffected = ps.executeUpdate();
                System.out.println("Đã xóa " + rowsAffected + " bản ghi từ product_favorites");
            }

            try ( PreparedStatement ps = conn.prepareStatement(sqlViewHistory)) {
                ps.setLong(1, productId);
                int rowsAffected = ps.executeUpdate();
                System.out.println("Đã xóa " + rowsAffected + " bản ghi từ product_view_history");
            }

            try ( PreparedStatement ps = conn.prepareStatement(sqlFeedbacks)) {
                ps.setLong(1, productId);
                int rowsAffected = ps.executeUpdate();
                System.out.println("Đã xóa " + rowsAffected + " bản ghi từ feedbacks");
            }

            try ( PreparedStatement ps = conn.prepareStatement(sqlCartItems)) {
                ps.setLong(1, productId);
                int rowsAffected = ps.executeUpdate();
                System.out.println("Đã xóa " + rowsAffected + " bản ghi từ cart_items");
            }

            try ( PreparedStatement ps = conn.prepareStatement(sqlPurchaseOrderDetails)) {
                ps.setLong(1, productId);
                int rowsAffected = ps.executeUpdate();
                System.out.println("Đã xóa " + rowsAffected + " bản ghi từ purchase_order_details");
            }

            try ( PreparedStatement ps = conn.prepareStatement(sqlProductVariants)) {
                ps.setLong(1, productId);
                int rowsAffected = ps.executeUpdate();
                System.out.println("Đã xóa " + rowsAffected + " bản ghi từ product_variants");
            }

            try ( PreparedStatement ps = conn.prepareStatement(sqlProduct)) {
                ps.setLong(1, productId);
                int num = ps.executeUpdate();
                System.out.println("Đã xóa " + num + " bản ghi từ products");
                if (num > 0) {
                    conn.commit();
                    System.out.println("Xóa sản phẩm ID " + productId + " thành công");
                    return 1;
                } else {
                    conn.rollback();
                    System.out.println("Không tìm thấy sản phẩm ID " + productId);
                    return 0;
                }
            }
        } catch (SQLException e) {
            System.err.println("Lỗi khi xóa sản phẩm ID " + productId + ": " + e.getMessage());
            throw new RuntimeException("Lỗi cơ sở dữ liệu: " + e.getMessage());
        }
    }

    public List<Category> getAllCategories() {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT category_id, name, description, parent_category_id, is_active, created_at "
                + "FROM categories WHERE is_active = 1";

        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql);  ResultSet rs = ps.executeQuery()) {
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
            System.out.println("Error in getAllCategories: " + e.getMessage());
            e.printStackTrace();
            return list;
        }
    }

    public List<Brand> getAllBrands() {
        List<Brand> list = new ArrayList<>();
        String sql = "SELECT brand_id, name, description, logo_url, is_active, created_at "
                + "FROM brands WHERE is_active = 1";

        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql);  ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Brand brand = new Brand(
                        rs.getLong("brand_id"),
                        rs.getString("name"),
                        rs.getString("description"),
                        rs.getString("logo_url"),
                        rs.getBoolean("is_active"),
                        rs.getTimestamp("created_at")
                );
                list.add(brand);
            }
            return list;
        } catch (SQLException e) {
            System.out.println("Error in getAllBrands: " + e.getMessage());
            e.printStackTrace();
            return list;
        }
    }

    public boolean categoryExists(long categoryId) {
        String sql = "SELECT COUNT(*) AS count FROM categories WHERE category_id = ? AND is_active = 1";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, categoryId);
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("count") > 0;
                }
            }
            return false;
        } catch (SQLException e) {
            System.out.println("Error in categoryExists: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public boolean brandExists(long brandId) {
        String sql = "SELECT COUNT(*) AS count FROM brands WHERE brand_id = ? AND is_active = 1";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, brandId);
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("count") > 0;
                }
            }
            return false;
        } catch (SQLException e) {
            System.out.println("Error in brandExists: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    private List<ProductVariant> getVariantsByProductId(long productId) {
        List<ProductVariant> variants = new ArrayList<>();
        String sql = "SELECT pv.variant_id, pv.product_id, pv.size, pv.color, pv.price_modifier, pv.sku, "
                + "b.name AS brand_name, p.name AS product_name "
                + "FROM product_variants pv "
                + "JOIN products p ON pv.product_id = p.product_id "
                + "JOIN brands b ON p.brand_id = b.brand_id "
                + "WHERE pv.product_id = ?";

        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, productId);
            try ( ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BigDecimal priceModifier = rs.getBigDecimal("price_modifier");
                    if (rs.wasNull()) {
                        priceModifier = null;
                    }
                    ProductVariant variant = new ProductVariant(
                            rs.getLong("variant_id"),
                            rs.getLong("product_id"),
                            rs.getString("size"),
                            rs.getString("color"),
                            priceModifier,
                            rs.getString("sku")
                    );
                    variant.setBrand(rs.getString("brand_name"));
                    variant.setProductName(rs.getString("product_name"));
                    variants.add(variant);
                }
            }
            return variants;
        } catch (SQLException e) {
            System.out.println("Error in getVariantsByProductId: " + e.getMessage());
            e.printStackTrace();
            return variants;
        }
    }

    private List<ProductImage> getImagesByProductId(long productId) {
        List<ProductImage> images = new ArrayList<>();
        String sql = "SELECT image_id, product_id, variant_id, image_url, display_order, created_at, is_main "
                + "FROM product_images WHERE product_id = ?";

        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, productId);
            try ( ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Long variantId = rs.getLong("variant_id");
                    if (rs.wasNull()) {
                        variantId = null;
                    }
                    ProductImage image = new ProductImage(
                            rs.getLong("image_id"),
                            rs.getLong("product_id"),
                            variantId,
                            rs.getString("image_url"),
                            rs.getInt("display_order"),
                            rs.getTimestamp("created_at"),
                            rs.getBoolean("is_main")
                    );
                    images.add(image);
                }
            }
            return images;
        } catch (SQLException e) {
            System.out.println("Error in getImagesByProductId: " + e.getMessage());
            e.printStackTrace();
            return images;
        }
    }

    private Product mapProduct(ResultSet rs) throws SQLException {
        BigDecimal price = rs.getBigDecimal("price");
        if (rs.wasNull()) {
            price = null;
        }
        Date createdAt = rs.getTimestamp("created_at");
        Date updatedAt = rs.getTimestamp("updated_at");
        if (rs.wasNull()) {
            updatedAt = null;
        }
        Product product = new Product(
                rs.getLong("product_id"),
                rs.getString("name"),
                rs.getString("description"),
                price,
                null,
                null,
                rs.getString("material"),
                rs.getString("status"),
                createdAt,
                updatedAt
        );

        String categoryName = rs.getString("category_name");
        if (categoryName != null) {
            Date categoryCreatedAt = rs.getTimestamp("category_created_at");
            if (categoryCreatedAt == null) {
                categoryCreatedAt = new Date();
                System.out.println("Warning: category_created_at is null for category_id: " + rs.getLong("category_id"));
            }
            Long parentCategoryId = rs.getLong("parent_category_id");
            if (rs.wasNull()) {
                parentCategoryId = null;
            }
            Category category = new Category(
                    rs.getLong("category_id"),
                    categoryName,
                    rs.getString("category_description"),
                    parentCategoryId,
                    rs.getBoolean("category_active"),
                    categoryCreatedAt
            );
            product.setCategory(category);
        }

        String brandName = rs.getString("brand_name");
        if (brandName != null) {
            Date brandCreatedAt = rs.getTimestamp("brand_created_at");
            Brand brand = new Brand(
                    rs.getLong("brand_id"),
                    brandName,
                    rs.getString("brand_description"),
                    rs.getString("logo_url"),
                    rs.getBoolean("brand_active"),
                    brandCreatedAt
            );
            product.setBrand(brand);
        }

        String imageUrl = rs.getString("main_image_url");
        product.setImageUrl(imageUrl != null ? imageUrl : "https://placehold.co/400x500/f0f0f0/333?text=No+Image");

        return product;
    }

    public boolean updateProductStatusByCategoryId(long categoryId, String status) {
        String sql = "UPDATE products SET status = ? WHERE category_id = ? AND status != ?";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setLong(2, categoryId);
            ps.setString(3, status);
            int rowsAffected = ps.executeUpdate();
            System.out.println("updateProductStatusByCategoryId: Updated " + rowsAffected + " products for categoryId=" + categoryId + " to status=" + status);
            return rowsAffected >= 0;
        } catch (SQLException e) {
            System.out.println("Error in updateProductStatusByCategoryId: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateProductStatusByBrandId(long brandId, String status) {
        String sql = "UPDATE products SET status = ? WHERE brand_id = ?";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setLong(2, brandId);
            int rowsAffected = ps.executeUpdate();
            System.out.println("updateProductStatusByBrandId: Updated " + rowsAffected + " products for brandId=" + brandId + " to status=" + status);
            return rowsAffected >= 0;
        } catch (SQLException e) {
            System.out.println("Error in updateProductStatusByBrandId: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public List<Product> getBestSellers(int limit) {
        List<Product> products = new ArrayList<>();
        String sql = "WITH StockLevels AS ("
                + "    SELECT variant_id, SUM(CASE "
                + "        WHEN movement_type = 'In' THEN quantity_changed "
                + "        WHEN movement_type = 'Out' THEN -quantity_changed "
                + "        WHEN movement_type = 'Adjustment' THEN quantity_changed "
                + "        WHEN movement_type = 'Reserved' THEN -quantity_changed "
                + "        WHEN movement_type = 'Released' THEN quantity_changed "
                + "        ELSE 0 END) AS current_stock "
                + "    FROM stock_movements "
                + "    GROUP BY variant_id "
                + "), ProductStock AS ("
                + "    SELECT pv.product_id, SUM(COALESCE(sl.current_stock, 0)) AS total_stock "
                + "    FROM product_variants pv "
                + "    LEFT JOIN StockLevels sl ON pv.variant_id = sl.variant_id "
                + "    GROUP BY pv.product_id "
                + "    HAVING SUM(COALESCE(sl.current_stock, 0)) > 0 "
                + "), DefaultVariants AS ("
                + "    SELECT pv.product_id, MIN(pv.variant_id) AS variant_id "
                + "    FROM product_variants pv "
                + "    JOIN StockLevels sl ON pv.variant_id = sl.variant_id "
                + "    WHERE sl.current_stock > 0 "
                + "    GROUP BY pv.product_id "
                + ") "
                + "SELECT TOP (?) p.product_id, p.name, p.price, p.created_at, "
                + "(SELECT TOP 1 image_url FROM product_images WHERE product_id = p.product_id AND is_main = 1) AS main_image_url, "
                + "dv.variant_id AS default_variant_id, ps.total_stock "
                + "FROM products p "
                + "INNER JOIN ProductStock ps ON p.product_id = ps.product_id "
                + "LEFT JOIN DefaultVariants dv ON p.product_id = dv.product_id "
                + "WHERE p.status = 'active' "
                + "ORDER BY ps.total_stock ASC, p.product_id DESC";

        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            System.out.println("Executing getBestSellers with limit: " + limit);
            ps.setInt(1, limit);
            try ( ResultSet rs = ps.executeQuery()) {
                int rowCount = 0;
                while (rs.next()) {
                    Product product = new Product();
                    product.setProductId(rs.getLong("product_id"));
                    product.setName(rs.getString("name"));
                    product.setPrice(rs.getBigDecimal("price"));
                    product.setCreatedAt(rs.getTimestamp("created_at"));
                    String imageUrl = rs.getString("main_image_url");
                    product.setImageUrl(imageUrl);
                    Long variantId = rs.getLong("default_variant_id");
                    product.setDefaultVariantId(rs.wasNull() ? null : variantId);
                    System.out.println("getBestSellers - Product ID: " + product.getProductId() + ", default_variant_id: " + variantId + ", total_stock: " + rs.getLong("total_stock"));
                    products.add(product);
                    rowCount++;
                }
                System.out.println("getBestSellers returned " + rowCount + " products");
            }
            return products;
        } catch (SQLException e) {
            System.err.println("SQLException in getBestSellers: " + e.getMessage());
            e.printStackTrace();
            return products;
        }
    }

    public int countProductsForShop(List<String> colors, List<String> sizes, BigDecimal maxPrice,
            List<Long> brandIds, Long parentCategoryId, Long categoryId) {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(DISTINCT p.product_id) AS total "
                + "FROM products p "
                + "JOIN categories c ON p.category_id = c.category_id "
                + "LEFT JOIN brands b ON p.brand_id = b.brand_id "
                + "LEFT JOIN product_variants pv ON p.product_id = pv.product_id "
                + "WHERE p.status = 'Active' AND c.is_active = 1"
        );

        List<Object> params = new ArrayList<>();

        if (categoryId != null) {
            sql.append(" AND p.category_id = ?");
            params.add(categoryId);
            if (parentCategoryId != null) {
                sql.append(" AND c.parent_category_id = ?");
                params.add(parentCategoryId);
            }
        } else if (parentCategoryId != null) {
            sql.append(" AND c.parent_category_id = ?");
            params.add(parentCategoryId);
        }

        if (colors != null && !colors.isEmpty()) {
            sql.append(" AND (pv.color IS NULL OR LOWER(pv.color) IN (");
            for (int i = 0; i < colors.size(); i++) {
                if (i > 0) {
                    sql.append(", ");
                }
                sql.append("?");
                params.add(colors.get(i).toLowerCase());
            }
            sql.append("))");
        }

        if (sizes != null && !sizes.isEmpty()) {
            sql.append(" AND (pv.size IS NULL OR LOWER(pv.size) IN (");
            for (int i = 0; i < sizes.size(); i++) {
                if (i > 0) {
                    sql.append(", ");
                }
                sql.append("?");
                params.add(sizes.get(i).toLowerCase());
            }
            sql.append("))");
        }

        if (maxPrice != null) {
            sql.append(" AND p.price <= ?");
            params.add(maxPrice);
        }

        if (brandIds != null && !brandIds.isEmpty()) {
            sql.append(" AND p.brand_id IN (");
            for (int i = 0; i < brandIds.size(); i++) {
                if (brandIds.get(i) != null) {
                    if (i > 0) {
                        sql.append(", ");
                    }
                    sql.append("?");
                    params.add(brandIds.get(i));
                }
            }
            sql.append(") AND p.brand_id IS NOT NULL");
        }

        System.out.println("countProductsForShop SQL: " + sql.toString());
        System.out.println("countProductsForShop Params: " + params);

        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int total = rs.getInt("total");
                    System.out.println("countProductsForShop returned: " + total);
                    return total;
                }
            }
            System.out.println("countProductsForShop returned 0 due to no results");
            return 0;
        } catch (SQLException e) {
            System.out.println("SQLException in countProductsForShop: " + e.getMessage());
            e.printStackTrace();
            return 0;
        }
    }

    public boolean isProductExists(String name, long brandId) {
        String sql = "SELECT COUNT(*) FROM Products WHERE TRIM(LOWER(name)) = TRIM(LOWER(?)) AND brand_id = ?";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            String normalizedName = name != null ? name.trim().toLowerCase().replaceAll("\\s+", " ") : "";
            System.out.println("isProductExists: Input - Original Name=" + name + ", Normalized Name=" + normalizedName + ", BrandId=" + brandId);
            ps.setString(1, normalizedName);
            ps.setLong(2, brandId);
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int count = rs.getInt(1);
                    System.out.println("isProductExists: Query Result - Name=" + normalizedName + ", BrandId=" + brandId + ", Exists=" + (count > 0));
                    return count > 0;
                }
            }
            System.out.println("isProductExists: No result found for Name=" + normalizedName + ", BrandId=" + brandId);
            return false;
        } catch (SQLException e) {
            System.out.println("Error in isProductExists: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public boolean isSKUExists(String sku) {
        String sql = "SELECT COUNT(*) FROM ProductVariants WHERE sku = ?";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            System.out.println("isSKUExists: Input - SKU=" + sku);
            ps.setString(1, sku);
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int count = rs.getInt(1);
                    System.out.println("isSKUExists: Query Result - SKU=" + sku + ", Exists=" + (count > 0));
                    return count > 0;
                }
            }
            System.out.println("isSKUExists: No result found for SKU=" + sku);
            return false;
        } catch (SQLException e) {
            System.out.println("Error in isSKUExists: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public boolean isVariantExists(long productId, String size, String color) {
        String sql = "SELECT COUNT(*) FROM ProductVariants WHERE product_id = ? AND TRIM(LOWER(size)) = TRIM(LOWER(?)) AND TRIM(LOWER(color)) = TRIM(LOWER(?))";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            String normalizedSize = size != null ? size.trim().toLowerCase() : "";
            String normalizedColor = color != null ? color.trim().toLowerCase() : "";
            System.out.println("isVariantExists: Input - ProductId=" + productId + ", Size=" + normalizedSize + ", Color=" + normalizedColor);
            ps.setLong(1, productId);
            ps.setString(2, normalizedSize);
            ps.setString(3, normalizedColor);
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int count = rs.getInt(1);
                    System.out.println("isVariantExists: Query Result - ProductId=" + productId + ", Size=" + normalizedSize + ", Color=" + normalizedColor + ", Exists=" + (count > 0));
                    return count > 0;
                }
            }
            System.out.println("isVariantExists: No result found for ProductId=" + productId + ", Size=" + normalizedSize + ", Color=" + normalizedColor);
            return false;
        } catch (SQLException e) {
            System.out.println("Error in isVariantExists: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public boolean isProductExistsExcludingId(String name, long brandId, long excludeProductId) {
        String sql = "SELECT COUNT(*) FROM Products WHERE TRIM(LOWER(name)) = TRIM(LOWER(?)) AND brand_id = ? AND product_id != ?";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            String normalizedName = name != null ? name.trim().toLowerCase().replaceAll("\\s+", " ") : "";
            System.out.println("isProductExistsExcludingId: Input - Original Name=" + name + ", Normalized Name=" + normalizedName + ", BrandId=" + brandId + ", ExcludeProductId=" + excludeProductId);
            ps.setString(1, normalizedName);
            ps.setLong(2, brandId);
            ps.setLong(3, excludeProductId);
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int count = rs.getInt(1);
                    System.out.println("isProductExistsExcludingId: Query Result - Name=" + normalizedName + ", BrandId=" + brandId + ", ExcludeProductId=" + excludeProductId + ", Exists=" + (count > 0));
                    return count > 0;
                }
            }
            System.out.println("isProductExistsExcludingId: No result found for Name=" + normalizedName + ", BrandId=" + brandId + ", ExcludeProductId=" + excludeProductId);
            return false;
        } catch (SQLException e) {
            System.out.println("Error in isProductExistsExcludingId: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public boolean isProductExistsForUpdate(String name, long brandId, long excludeProductId) {
        String sql = "SELECT COUNT(*) FROM Products WHERE TRIM(LOWER(name)) = TRIM(LOWER(?)) AND brand_id = ? AND product_id != ?";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            String normalizedName = name != null ? name.trim().toLowerCase().replaceAll("\\s+", " ") : "";
            System.out.println("isProductExistsForUpdate: Input - Original Name=" + name + ", Normalized Name=" + normalizedName + ", BrandId=" + brandId + ", ExcludeProductId=" + excludeProductId);
            ps.setString(1, normalizedName);
            ps.setLong(2, brandId);
            ps.setLong(3, excludeProductId);
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int count = rs.getInt(1);
                    System.out.println("isProductExistsForUpdate: Query Result - Name=" + normalizedName + ", BrandId=" + brandId + ", ExcludeProductId=" + excludeProductId + ", Exists=" + (count > 0));
                    return count > 0;
                }
            }
            System.out.println("isProductExistsForUpdate: No result found for Name=" + normalizedName + ", BrandId=" + brandId + ", ExcludeProductId=" + excludeProductId);
            return false;
        } catch (SQLException e) {
            System.out.println("Error in isProductExistsForUpdate: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public boolean isSKUExistsForUpdate(String sku, long excludeVariantId) {
        String sql = "SELECT COUNT(*) FROM ProductVariants WHERE sku = ? AND variant_id != ?";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            System.out.println("isSKUExistsForUpdate: Input - SKU=" + sku + ", ExcludeVariantId=" + excludeVariantId);
            ps.setString(1, sku);
            ps.setLong(2, excludeVariantId);
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int count = rs.getInt(1);
                    System.out.println("isSKUExistsForUpdate: Query Result - SKU=" + sku + ", ExcludeVariantId=" + excludeVariantId + ", Exists=" + (count > 0));
                    return count > 0;
                }
            }
            System.out.println("isSKUExistsForUpdate: No result found for SKU=" + sku + ", ExcludeVariantId=" + excludeVariantId);
            return false;
        } catch (SQLException e) {
            System.out.println("Error in isSKUExistsForUpdate: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public int getAvailableQuantityByVariantId(Long variantId) {
        if (variantId == null || variantId == 0) {
            return 0;
        }
        String sql = "SELECT SUM(CASE "
                + "    WHEN movement_type = 'In' THEN quantity_changed "
                + "    WHEN movement_type = 'Out' THEN -quantity_changed "
                + "    WHEN movement_type = 'Adjustment' THEN quantity_changed "
                + "    WHEN movement_type = 'Reserved' THEN -quantity_changed "
                + "    WHEN movement_type = 'Released' THEN quantity_changed "
                + "    ELSE 0 END) AS available "
                + "FROM stock_movements WHERE variant_id = ? "
                + "GROUP BY variant_id";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, variantId);
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int available = rs.getInt("available");
                    System.out.println("getAvailableQuantityByVariantId - Variant ID: " + variantId + ", Available: " + available);
                    return (available > 0) ? available : 0;
                }
            }
            return 0;
        } catch (SQLException e) {
            System.out.println("Error in getAvailableQuantityByVariantId: " + e.getMessage());
            e.printStackTrace();
            return 0;
        }
    }

    public List<Product> getAllPaginated(int offset, int pageSize, String sort) {
        List<Product> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT p.product_id, p.name, p.description, p.price, p.category_id, p.brand_id, p.material, p.status, "
                + "p.created_at, p.updated_at, c.category_id, c.name AS category_name, c.description AS category_description, "
                + "c.parent_category_id, c.is_active AS category_active, c.created_at AS category_created_at, "
                + "b.brand_id, b.name AS brand_name, b.description AS brand_description, b.logo_url, b.is_active AS brand_active, "
                + "b.created_at AS brand_created_at, "
                + "(SELECT TOP 1 image_url FROM product_images WHERE product_id = p.product_id AND is_main = 1) AS main_image_url "
                + "FROM products p "
                + "LEFT JOIN categories c ON p.category_id = c.category_id "
                + "LEFT JOIN brands b ON p.brand_id = b.brand_id"
        );

        switch (sort != null ? sort.toLowerCase() : "created_at_desc") {
            case "name_asc":
                sql.append(" ORDER BY p.name ASC");
                break;
            case "name_desc":
                sql.append(" ORDER BY p.name DESC");
                break;
            case "price_asc":
                sql.append(" ORDER BY p.price ASC");
                break;
            case "price_desc":
                sql.append(" ORDER BY p.price DESC");
                break;
            case "created_at_desc":
            default:
                sql.append(" ORDER BY p.created_at DESC");
                break;
        }
        sql.append(" OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            ps.setInt(1, offset);
            ps.setInt(2, pageSize);
            try ( ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product product = mapProduct(rs);
                    product.setVariants(getVariantsByProductId(product.getProductId()));
                    product.setImages(getImagesByProductId(product.getProductId()));
                    list.add(product);
                }
            }
            return list;
        } catch (SQLException e) {
            System.out.println("Error in getAllPaginated: " + e.getMessage());
            e.printStackTrace();
            return list;
        }
    }

    public int getTotalProductCount() {
        String sql = "SELECT COUNT(*) AS total FROM products";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql);  ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt("total");
            }
            return 0;
        } catch (SQLException e) {
            System.out.println("Error in getTotalProductCount: " + e.getMessage());
            e.printStackTrace();
            return 0;
        }
    }

    public List<Product> filterProductsPaginated(Long parentCategoryId, Long categoryId, Long brandId, String size, String color,
            String status, int offset, int pageSize, String sort) {
        List<Product> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT p.product_id, p.name, p.description, p.price, p.category_id, p.brand_id, p.material, p.status, "
                + "p.created_at, p.updated_at, c.category_id, c.name AS category_name, c.description AS category_description, "
                + "c.parent_category_id, c.is_active AS category_active, c.created_at AS category_created_at, "
                + "b.brand_id, b.name AS brand_name, b.description AS brand_description, b.logo_url, b.is_active AS brand_active, "
                + "b.created_at AS brand_created_at, "
                + "(SELECT TOP 1 image_url FROM product_images WHERE product_id = p.product_id AND is_main = 1) AS main_image_url "
                + "FROM products p "
                + "JOIN categories c ON p.category_id = c.category_id "
                + "LEFT JOIN brands b ON p.brand_id = b.brand_id "
                + "WHERE c.is_active = 1 AND p.status = ?"
        );

        List<Object> params = new ArrayList<>();
        params.add(status != null && !status.isEmpty() ? status : "Active");

        if (categoryId != null) {
            sql.append(" AND p.category_id = ?");
            params.add(categoryId);
            if (parentCategoryId != null) {
                sql.append(" AND c.parent_category_id = ?");
                params.add(parentCategoryId);
            }
        } else if (parentCategoryId != null) {
            sql.append(" AND c.parent_category_id = ?");
            params.add(parentCategoryId);
        }

        if (brandId != null) {
            sql.append(" AND p.brand_id = ?");
            params.add(brandId);
        }
        if (size != null && !size.isEmpty()) {
            sql.append(" AND EXISTS (SELECT 1 FROM product_variants pv WHERE pv.product_id = p.product_id AND LOWER(pv.size) LIKE LOWER(?))");
            params.add(size + "%");
        }
        if (color != null && !color.isEmpty()) {
            sql.append(" AND EXISTS (SELECT 1 FROM product_variants pv WHERE pv.product_id = p.product_id AND LOWER(pv.color) LIKE LOWER(?))");
            params.add(color + "%");
        }

        switch (sort != null ? sort.toLowerCase() : "created_at_desc") {
            case "name_asc":
                sql.append(" ORDER BY p.name ASC");
                break;
            case "name_desc":
                sql.append(" ORDER BY p.name DESC");
                break;
            case "price_asc":
                sql.append(" ORDER BY p.price ASC");
                break;
            case "price_desc":
                sql.append(" ORDER BY p.price DESC");
                break;
            case "created_at_desc":
            default:
                sql.append(" ORDER BY p.created_at DESC");
                break;
        }
        sql.append(" OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add(offset);
        params.add(pageSize);

        System.out.println("filterProductsPaginated SQL: " + sql.toString());
        System.out.println("filterProductsPaginated Params: " + params);

        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try ( ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product product = mapProduct(rs);
                    product.setVariants(getVariantsByProductId(product.getProductId()));
                    product.setImages(getImagesByProductId(product.getProductId()));
                    list.add(product);
                }
            }
            System.out.println("filterProductsPaginated returned " + list.size() + " products");
            return list;
        } catch (SQLException e) {
            System.out.println("SQLException in filterProductsPaginated: " + e.getMessage());
            e.printStackTrace();
            return list;
        }
    }

    public int getFilteredProductCount(Long parentCategoryId, Long categoryId, Long brandId, String size, String color,
            String status) {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) AS total "
                + "FROM products p "
                + "JOIN categories c ON p.category_id = c.category_id "
                + "LEFT JOIN brands b ON p.brand_id = b.brand_id "
                + "WHERE c.is_active = 1 AND p.status = ?"
        );

        List<Object> params = new ArrayList<>();
        params.add(status != null && !status.isEmpty() ? status : "Active");

        if (categoryId != null) {
            sql.append(" AND p.category_id = ?");
            params.add(categoryId);
            if (parentCategoryId != null) {
                sql.append(" AND c.parent_category_id = ?");
                params.add(parentCategoryId);
            }
        } else if (parentCategoryId != null) {
            sql.append(" AND c.parent_category_id = ?");
            params.add(parentCategoryId);
        }

        if (brandId != null) {
            sql.append(" AND p.brand_id = ?");
            params.add(brandId);
        }
        if (size != null && !size.isEmpty()) {
            sql.append(" AND EXISTS (SELECT 1 FROM product_variants pv WHERE pv.product_id = p.product_id AND LOWER(pv.size) LIKE LOWER(?))");
            params.add(size + "%");
        }
        if (color != null && !color.isEmpty()) {
            sql.append(" AND EXISTS (SELECT 1 FROM product_variants pv WHERE pv.product_id = p.product_id AND LOWER(pv.color) LIKE LOWER(?))");
            params.add(color + "%");
        }

        System.out.println("getFilteredProductCount SQL: " + sql.toString());
        System.out.println("getFilteredProductCount Params: " + params);

        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int total = rs.getInt("total");
                    System.out.println("getFilteredProductCount returned: " + total);
                    return total;
                }
            }
            return 0;
        } catch (SQLException e) {
            System.out.println("SQLException in getFilteredProductCount: " + e.getMessage());
            e.printStackTrace();
            return 0;
        }
    }

    public static void main(String[] args) {
        ProductDAO dao = new ProductDAO();
        List<Product> products = dao.getAll();

        if (products != null && !products.isEmpty()) {
            System.out.println("Retrieved " + products.size() + " products:");
            for (Product product : products) {
                System.out.println("-------------------");
                System.out.println("Product ID: " + product.getProductId());
                System.out.println("Name: " + (product.getName() != null ? product.getName() : "N/A"));
                System.out.println("Price: " + (product.getPrice() != null ? product.getPrice() : "N/A"));
                System.out.println("Category: " + (product.getCategory() != null ? product.getCategory().getName() : "N/A"));
                System.out.println("Brand: " + (product.getBrand() != null ? product.getBrand().getName() : "N/A"));
                System.out.println("Material: " + (product.getMaterial() != null ? product.getMaterial() : "N/A"));
                System.out.println("Status: " + (product.getStatus() != null ? product.getStatus() : "N/A"));
                System.out.println("Created At: " + (product.getCreatedAt() != null ? product.getCreatedAt() : "N/A"));
                System.out.println("Updated At: " + (product.getUpdatedAt() != null ? product.getUpdatedAt() : "N/A"));
                System.out.println("Image URL: " + (product.getImageUrl() != null ? product.getImageUrl() : "N/A"));

                List<ProductVariant> variants = product.getVariants();
                if (variants != null && !variants.isEmpty()) {
                    System.out.println("Variants (" + variants.size() + "):");
                    for (ProductVariant variant : variants) {
                        System.out.println("  - Variant ID: " + variant.getVariantId());
                        System.out.println("    Size: " + (variant.getSize() != null ? variant.getSize() : "N/A"));
                        System.out.println("    Color: " + (variant.getColor() != null ? variant.getColor() : "N/A"));
                        System.out.println("    Price Modifier: " + (variant.getPriceModifier() != null ? variant.getPriceModifier() : "N/A"));
                        System.out.println("    SKU: " + (variant.getSku() != null ? variant.getSku() : "N/A"));
                    }
                } else {
                    System.out.println("Variants: None");
                }

                List<ProductImage> images = product.getImages();
                if (images != null && !images.isEmpty()) {
                    System.out.println("Images (" + images.size() + "):");
                    for (ProductImage image : images) {
                        System.out.println("  - Image ID: " + image.getImageId());
                        System.out.println("    URL: " + (image.getImageUrl() != null ? image.getImageUrl() : "N/A"));
                        System.out.println("    Display Order: " + image.getDisplayOrder());
                        System.out.println("    Is Main: " + image.isMain());
                    }
                } else {
                    System.out.println("Images: None");
                }
            }
            System.out.println("-------------------");
        } else {
            System.out.println("No products found or database connection failed!");
        }
    }

    public BigDecimal getUnitPriceByVariantId(long variantId) {
        String sql = "SELECT COALESCE(p.price + ISNULL(pv.price_modifier, 0), p.price) AS unit_price "
                + "FROM product_variants pv "
                + "JOIN products p ON pv.product_id = p.product_id "
                + "WHERE pv.variant_id = ?";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, variantId);
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    BigDecimal unitPrice = rs.getBigDecimal("unit_price");
                    return unitPrice != null ? unitPrice : BigDecimal.ZERO;
                }
            }
            return BigDecimal.ZERO;
        } catch (SQLException e) {
            System.out.println("Error in getUnitPriceByVariantId: " + e.getMessage());
            e.printStackTrace();
            return BigDecimal.ZERO;
        }
    }
}
