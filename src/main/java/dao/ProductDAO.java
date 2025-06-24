package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.Product;
import model.Category;
import model.Brand;
import model.ProductVariant;
import model.ProductImage;
import util.DBContext;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.Date;

/**
 *
 * @author DANGVUONGTHINH
 */
public class ProductDAO extends DBContext {

    public ProductDAO() {
        super();
    }

    public List<Product> getAll() {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT p.product_id, p.name, p.description, p.price, p.category_id, p.brand_id, p.material, p.status, "
                + "p.created_at, p.updated_at, c.category_id, c.name AS category_name, c.description AS category_description, "
                + "c.parent_category_id, c.is_active AS category_active, c.created_at AS category_created_at, "
                + "b.brand_id, b.name AS brand_name, b.description AS brand_description, b.logo_url, b.is_active AS brand_active, "
                + "b.created_at AS brand_created_at "
                + "FROM products p "
                + "LEFT JOIN categories c ON p.category_id = c.category_id "
                + "LEFT JOIN brands b ON p.brand_id = b.brand_id";

        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Product product = mapProduct(rs);
                product.setVariants(getVariantsByProductId(product.getProductId()));
                product.setImages(getImagesByProductId(product.getProductId()));
                list.add(product);
            }
            return list;
        } catch (SQLException e) {
            System.out.println("Error in getAll: " + e.getMessage());
        }
        return list;
    }

    public Product getProductById(long productId) {
        Product product = null;
        String sql = "SELECT p.product_id, p.name, p.description, p.price, p.category_id, p.brand_id, p.material, p.status, "
                + "p.created_at, p.updated_at, c.category_id, c.name AS category_name, c.description AS category_description, "
                + "c.parent_category_id, c.is_active AS category_active, c.created_at AS category_created_at, "
                + "b.brand_id, b.name AS brand_name, b.description AS brand_description, b.logo_url, b.is_active AS brand_active, "
                + "b.created_at AS brand_created_at "
                + "FROM products p "
                + "LEFT JOIN categories c ON p.category_id = c.category_id "
                + "LEFT JOIN brands b ON p.brand_id = b.brand_id "
                + "WHERE p.product_id = ?";

        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setLong(1, productId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                product = mapProduct(rs);
                product.setVariants(getVariantsByProductId(productId));
                product.setImages(getImagesByProductId(productId));
                return product;
            }
        } catch (SQLException e) {
            System.out.println("Error in getProductById: " + e.getMessage());
        }
        return product;
    }

    public long insert(String name, String description, BigDecimal price, long categoryId, long brandId,
            String material, String status, List<ProductVariant> variants, List<ProductImage> images) {
        String sql = "INSERT INTO products (name, description, price, category_id, brand_id, material, status, created_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?); SELECT SCOPE_IDENTITY() AS product_id;";

        try {
            conn.setAutoCommit(false);
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, name);
            ps.setString(2, description);
            ps.setBigDecimal(3, price);
            ps.setLong(4, categoryId);
            ps.setLong(5, brandId);
            ps.setString(6, material);
            ps.setString(7, status);
            ps.setTimestamp(8, new java.sql.Timestamp(new Date().getTime()));

            ResultSet rs = ps.executeQuery();
            long productId = 0;
            if (rs.next()) {
                productId = rs.getLong("product_id");
            } else {
                conn.rollback();
                return 0;
            }

            // Insert variants
            String checkSkuSql = "SELECT sku FROM product_variants WHERE sku = ?";
            String variantSql = "INSERT INTO product_variants (product_id, size, color, price_modifier, sku) "
                    + "VALUES (?, ?, ?, ?, ?); SELECT SCOPE_IDENTITY() AS variant_id;";
            PreparedStatement psCheckSku = conn.prepareStatement(checkSkuSql);
            PreparedStatement psVariant = conn.prepareStatement(variantSql);

            for (ProductVariant variant : variants) {
                String sku = variant.getSku();
                if (sku == null || sku.length() > 100) {
                    conn.rollback();
                    System.out.println("Invalid SKU: " + (sku == null ? "null" : "exceeds 100 characters"));
                    return 0;
                }

                psCheckSku.setString(1, sku);
                ResultSet rsSku = psCheckSku.executeQuery();
                if (rsSku.next()) {
                    conn.rollback();
                    System.out.println("Duplicate SKU: " + sku);
                    return 0;
                }

                psVariant.setLong(1, productId);
                psVariant.setString(2, variant.getSize());
                psVariant.setString(3, variant.getColor());
                psVariant.setBigDecimal(4, variant.getPriceModifier());
                psVariant.setString(5, sku);
                ResultSet rsVariant = psVariant.executeQuery();
                if (rsVariant.next()) {
                    long variantId = rsVariant.getLong("variant_id");
                    String inventorySql = "INSERT INTO inventory (variant_id, quantity, reserved_quantity) VALUES (?, 0, 0)";
                    PreparedStatement psInventory = conn.prepareStatement(inventorySql);
                    psInventory.setLong(1, variantId);
                    psInventory.executeUpdate();
                }
            }

            // Insert images
            for (ProductImage image : images) {
                insertProductImage(productId, image);
            }

            conn.commit();
            return productId;
        } catch (SQLException e) {
            try {
                conn.rollback();
            } catch (SQLException ex) {
                System.out.println("Rollback error: " + ex.getMessage());
            }
            System.out.println("Database error: " + e.getMessage());
            return 0;
        } finally {
            try {
                conn.setAutoCommit(true);
            } catch (SQLException e) {
                System.out.println("AutoCommit reset error: " + e.getMessage());
            }
        }
    }

    private void insertProductImage(long productId, ProductImage image) throws SQLException {
        String sql = "INSERT INTO product_images (product_id, variant_id, image_url, display_order, is_main, created_at) "
                + "VALUES (?, ?, ?, ?, ?, ?)";
        PreparedStatement ps = conn.prepareStatement(sql);
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

    public boolean update(long id, String name, String description, BigDecimal price, long categoryId, long brandId,
            String material, String status, List<ProductVariant> variants, List<ProductImage> images) {
        try {
            conn.setAutoCommit(false);

            // Update product
            String productSql = "UPDATE products SET name = ?, description = ?, price = ?, category_id = ?, brand_id = ?, "
                    + "material = ?, status = ?, updated_at = ? WHERE product_id = ?";
            PreparedStatement psProduct = conn.prepareStatement(productSql);
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

            // Get existing variant IDs
            List<Long> existingVariantIds = new ArrayList<>();
            String selectVariantsSql = "SELECT variant_id FROM product_variants WHERE product_id = ?";
            PreparedStatement psSelectVariants = conn.prepareStatement(selectVariantsSql);
            psSelectVariants.setLong(1, id);
            ResultSet rs = psSelectVariants.executeQuery();
            while (rs.next()) {
                existingVariantIds.add(rs.getLong("variant_id"));
            }

            // Process variants
            String checkSkuSql = "SELECT sku FROM product_variants WHERE sku = ? AND variant_id != ?";
            String updateVariantSql = "UPDATE product_variants SET size = ?, color = ?, price_modifier = ?, sku = ? "
                    + "WHERE variant_id = ? AND product_id = ?";
            String insertVariantSql = "INSERT INTO product_variants (product_id, size, color, price_modifier, sku) "
                    + "VALUES (?, ?, ?, ?, ?); SELECT SCOPE_IDENTITY() AS variant_id;";
            PreparedStatement psCheckSku = conn.prepareStatement(checkSkuSql);
            PreparedStatement psUpdateVariant = conn.prepareStatement(updateVariantSql);
            PreparedStatement psInsertVariant = conn.prepareStatement(insertVariantSql);

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
                ResultSet rsSku = psCheckSku.executeQuery();
                if (rsSku.next()) {
                    conn.rollback();
                    System.out.println("Duplicate SKU: " + sku);
                    return false;
                }

                if (variantId != null) {
                    // Update existing variant
                    psUpdateVariant.setString(1, variant.getSize());
                    psUpdateVariant.setString(2, variant.getColor());
                    psUpdateVariant.setBigDecimal(3, variant.getPriceModifier());
                    psUpdateVariant.setString(4, sku);
                    psUpdateVariant.setLong(5, variantId);
                    psUpdateVariant.setLong(6, id);
                    psUpdateVariant.executeUpdate();
                    submittedVariantIds.add(variantId);
                } else {
                    // Insert new variant
                    psInsertVariant.setLong(1, id);
                    psInsertVariant.setString(2, variant.getSize());
                    psInsertVariant.setString(3, variant.getColor());
                    psInsertVariant.setBigDecimal(4, variant.getPriceModifier());
                    psInsertVariant.setString(5, sku);
                    ResultSet rsVariant = psInsertVariant.executeQuery();
                    if (rsVariant.next()) {
                        long newVariantId = rsVariant.getLong("variant_id");
                        // Insert into inventory with default quantity
                        String inventorySql = "INSERT INTO inventory (variant_id, quantity, reserved_quantity) VALUES (?, 0, 0)";
                        PreparedStatement psInventory = conn.prepareStatement(inventorySql);
                        psInventory.setLong(1, newVariantId);
                        psInventory.executeUpdate();
                    } else {
                        conn.rollback();
                        System.out.println("Failed to retrieve variant_id for SKU: " + sku);
                        return false;
                    }
                }
            }

            // Delete removed variants
            String deleteVariantSql = "DELETE FROM product_variants WHERE variant_id = ? AND product_id = ?";
            PreparedStatement psDeleteVariant = conn.prepareStatement(deleteVariantSql);
            for (Long existingId : existingVariantIds) {
                if (!submittedVariantIds.contains(existingId)) {
                    psDeleteVariant.setLong(1, existingId);
                    psDeleteVariant.setLong(2, id);
                    psDeleteVariant.executeUpdate();
                }
            }

            // Process images
            // Delete existing images
            String deleteImageSql = "DELETE FROM product_images WHERE product_id = ?";
            PreparedStatement psDeleteImage = conn.prepareStatement(deleteImageSql);
            psDeleteImage.setLong(1, id);
            psDeleteImage.executeUpdate();

            // Insert new images
            if (images != null && !images.isEmpty()) {
                for (ProductImage image : images) {
                    insertProductImage(id, image);
                }
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            try {
                conn.rollback();
            } catch (SQLException ex) {
                System.out.println("Rollback error: " + ex.getMessage());
            }
            System.out.println("Database error in update: " + e.getMessage());
            return false;
        } finally {
            try {
                conn.setAutoCommit(true);
            } catch (SQLException e) {
                System.out.println("AutoCommit reset error: " + e.getMessage());
            }
        }
    }

    public String getBrandNameById(long brandId) {
        String sql = "SELECT name FROM brands WHERE brand_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setLong(1, brandId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getString("name");
            }
            return null;
        } catch (SQLException e) {
            System.out.println("Error fetching brand name: " + e.getMessage());
            return null;
        }
    }

    public int delete(long productId) {
        String sql = "DELETE FROM products WHERE product_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setLong(1, productId);
            int num = ps.executeUpdate();
            if (num > 0) {
                return 1;
            } else {
                return 0;
            }
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }
        return 0;
    }

    public List<Product> filterProducts(Long parentCategoryId, Long categoryId, Long brandId, String size, String color,
            BigDecimal minPrice, BigDecimal maxPrice, String status) {
        List<Product> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT p.product_id, p.name, p.description, p.price, p.category_id, p.brand_id, p.material, p.status, "
                + "p.created_at, p.updated_at, c.category_id, c.name AS category_name, c.description AS category_description, "
                + "c.parent_category_id, c.is_active AS category_active, c.created_at AS category_created_at, "
                + "b.brand_id, b.name AS brand_name, b.description AS brand_description, b.logo_url, b.is_active AS brand_active, "
                + "b.created_at AS brand_created_at "
                + "FROM products p "
                + "JOIN categories c ON p.category_id = c.category_id " // Đảm bảo category_id hợp lệ
                + "LEFT JOIN brands b ON p.brand_id = b.brand_id "
                + "WHERE 1=1"
        );

        List<Object> params = new ArrayList<>();

        // Xử lý khi cả parentCategoryId và categoryId được chọn
        if (parentCategoryId != null && categoryId != null) {
            sql.append(" AND p.category_id = ? AND c.parent_category_id = ?");
            params.add(categoryId);
            params.add(parentCategoryId);
        } else if (categoryId != null) {
            sql.append(" AND p.category_id = ?");
            params.add(categoryId);
        } else if (parentCategoryId != null) {
            sql.append(" AND c.parent_category_id = ?");
            params.add(parentCategoryId);
        }

        // Xử lý trạng thái linh hoạt
        if (status != null && !status.isEmpty()) {
            sql.append(" AND p.status = ?");
            params.add(status);
        }

        if (brandId != null) {
            sql.append(" AND p.brand_id = ?");
            params.add(brandId);
        }
        if (minPrice != null) {
            sql.append(" AND p.price >= ?");
            params.add(minPrice);
        }
        if (maxPrice != null) {
            sql.append(" AND p.price <= ?");
            params.add(maxPrice);
        }
        if (size != null && !size.isEmpty()) {
            sql.append(" AND EXISTS (SELECT 1 FROM product_variants pv WHERE pv.product_id = p.product_id AND LOWER(pv.size) LIKE LOWER(?))");
            params.add(size + "%");
        }
        if (color != null && !color.isEmpty()) {
            sql.append(" AND EXISTS (SELECT 1 FROM product_variants pv WHERE pv.product_id = p.product_id AND LOWER(pv.color) LIKE LOWER(?))");
            params.add(color + "%");
        }

        // Debug logging
        System.out.println("Filter SQL: " + sql.toString());
        System.out.println("Filter Params: " + params);

        try {
            PreparedStatement ps = conn.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            ResultSet rs = ps.executeQuery();
            int rowCount = 0;
            while (rs.next()) {
                Product product = mapProduct(rs);
                product.setVariants(getVariantsByProductId(product.getProductId()));
                product.setImages(getImagesByProductId(product.getProductId()));
                list.add(product);
                rowCount++;
                System.out.println("Product ID: " + product.getProductId() + ", Category: " + (product.getCategory() != null ? product.getCategory().getName() : "N/A")
                        + ", Parent Category ID: " + (product.getCategory() != null && product.getCategory().getParentCategoryId() != null ? product.getCategory().getParentCategoryId() : "N/A")
                        + ", Status: " + product.getStatus());
            }
            System.out.println("Rows returned: " + rowCount); // Log number of rows
            return list;
        } catch (SQLException e) {
            System.out.println("Error in filterProducts: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    public List<Category> getAllCategories() {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT category_id, name, description, parent_category_id, is_active, created_at "
                + "FROM categories WHERE is_active = 1";

        try {
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
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }
        return list;
    }

    public List<Brand> getAllBrands() {
        List<Brand> list = new ArrayList<>();
        String sql = "SELECT brand_id, name, description, logo_url, is_active, created_at "
                + "FROM brands WHERE is_active = 1";

        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
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
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }
        return list;
    }

    public boolean categoryExists(long categoryId) {
        String sql = "SELECT COUNT(*) AS count FROM categories WHERE category_id = ? AND is_active = 1";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setLong(1, categoryId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("count") > 0;
            }
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }
        return false;
    }

    public boolean brandExists(long brandId) {
        String sql = "SELECT COUNT(*) AS count FROM brands WHERE brand_id = ? AND is_active = 1";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setLong(1, brandId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("count") > 0;
            }
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }
        return false;
    }

    private List<ProductVariant> getVariantsByProductId(long productId) {
        List<ProductVariant> variants = new ArrayList<>();
        String sql = "SELECT pv.variant_id, pv.product_id, pv.size, pv.color, pv.price_modifier, pv.sku, "
                + "b.name AS brand_name, p.name AS product_name "
                + "FROM product_variants pv "
                + "JOIN products p ON pv.product_id = p.product_id "
                + "JOIN brands b ON p.brand_id = b.brand_id "
                + "WHERE pv.product_id = ?";

        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setLong(1, productId);
            ResultSet rs = ps.executeQuery();
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
            return variants;
        } catch (SQLException e) {
            System.out.println("Error in getVariantsByProductId: " + e.getMessage());
        }
        return variants;
    }

    private List<ProductImage> getImagesByProductId(long productId) {
        List<ProductImage> images = new ArrayList<>();
        String sql = "SELECT image_id, product_id, variant_id, image_url, display_order, created_at, is_main "
                + "FROM product_images WHERE product_id = ?";

        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setLong(1, productId);
            ResultSet rs = ps.executeQuery();
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
            return images;
        } catch (SQLException e) {
            System.out.println("Error in getImagesByProductId: " + e.getMessage());
            e.printStackTrace();
        }
        return images;
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
                null, // Category sẽ được set sau
                null, // Brand sẽ được set sau
                rs.getString("material"),
                rs.getString("status"),
                createdAt,
                updatedAt
        );

        String categoryName = rs.getString("category_name");
        if (categoryName != null) {
            Date categoryCreatedAt = rs.getTimestamp("category_created_at");
            if (categoryCreatedAt == null) {
                categoryCreatedAt = new Date(); // Default to current date if null
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

        return product;
    }

    public boolean updateProductStatusByCategoryId(long categoryId, String status) {
        String sql = "UPDATE products SET status = ? WHERE category_id = ? AND status != ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, status);
            ps.setLong(2, categoryId);
            ps.setString(3, status); // Chỉ cập nhật nếu trạng thái khác với trạng thái mới
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
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
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

    /**
     * Lấy danh sách sản phẩm mới nhất cho trang chủ (đã được tối ưu).
     *
     * @param limit Số lượng sản phẩm muốn lấy.
     * @return Danh sách các sản phẩm.
     */
    public List<Product> getNewArrivals(int limit) {
        List<Product> list = new ArrayList<>();
        // Câu lệnh SQL này dùng CTE và ROW_NUMBER để lấy đúng 1 ảnh đại diện và 1 biến thể mặc định trong 1 lần chạy
        String sql = "WITH RankedImages AS ("
                + "    SELECT *, ROW_NUMBER() OVER(PARTITION BY product_id ORDER BY display_order, image_id) as rn "
                + "    FROM product_images"
                + "), DefaultVariants AS ("
                + "    SELECT *, ROW_NUMBER() OVER(PARTITION BY product_id ORDER BY variant_id) as rn_variant "
                + "    FROM product_variants"
                + ") "
                + "SELECT TOP (?) p.product_id, p.name, p.price, p.created_at, ri.image_url, dv.variant_id AS default_variant_id "
                + "FROM products p "
                + "LEFT JOIN RankedImages ri ON p.product_id = ri.product_id AND ri.rn = 1 "
                + "LEFT JOIN DefaultVariants dv ON p.product_id = dv.product_id AND dv.rn_variant = 1 "
                + "WHERE p.status = 'Active' "
                + "ORDER BY p.created_at DESC";

        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, limit);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Product product = new Product();
                product.setProductId(rs.getLong("product_id"));
                product.setName(rs.getString("name"));
                product.setPrice(rs.getBigDecimal("price"));
                product.setCreatedAt(rs.getTimestamp("created_at"));
                product.setImageUrl(rs.getString("image_url"));
                product.setDefaultVariantId(rs.getLong("default_variant_id"));
                list.add(product);
            }
        } catch (Exception e) {
            System.out.println("Error in getNewArrivals: " + e.getMessage());
        }
        return list;
    }

    /**
     * Lấy danh sách sản phẩm bán chạy nhất cho trang chủ (đã được tối ưu).
     *
     * @param limit Số lượng sản phẩm muốn lấy.
     * @return Danh sách các sản phẩm.
     */
    public List<Product> getBestSellers(int limit) {
        // TODO: Logic ORDER BY cần được thay thế bằng logic dựa trên số lượng bán ra từ bảng order_items
        List<Product> list = new ArrayList<>();
        String sql = "WITH RankedImages AS ("
                + "    SELECT *, ROW_NUMBER() OVER(PARTITION BY product_id ORDER BY display_order, image_id) as rn "
                + "    FROM product_images"
                + "), DefaultVariants AS ("
                + "    SELECT *, ROW_NUMBER() OVER(PARTITION BY product_id ORDER BY variant_id) as rn_variant "
                + "    FROM product_variants"
                + ") "
                + "SELECT TOP (?) p.product_id, p.name, p.price, p.created_at, ri.image_url, dv.variant_id AS default_variant_id "
                + "FROM products p "
                + "LEFT JOIN RankedImages ri ON p.product_id = ri.product_id AND ri.rn = 1 "
                + "LEFT JOIN DefaultVariants dv ON p.product_id = dv.product_id AND dv.rn_variant = 1 "
                + "WHERE p.status = 'Active' "
                + "ORDER BY NEWID()"; // Tạm thời lấy ngẫu nhiên

        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, limit);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Product product = new Product();
                product.setProductId(rs.getLong("product_id"));
                product.setName(rs.getString("name"));
                product.setPrice(rs.getBigDecimal("price"));
                product.setCreatedAt(rs.getTimestamp("created_at"));
                product.setImageUrl(rs.getString("image_url"));
                product.setDefaultVariantId(rs.getLong("default_variant_id"));
                list.add(product);
            }
        } catch (Exception e) {
            System.out.println("Error in getBestSellers: " + e.getMessage());
        }
        return list;
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
}
