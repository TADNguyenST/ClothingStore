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
        } catch (Exception e) {
            System.out.println(e.getMessage());
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
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }
        return product;
    }
/*
    public boolean update(long productId, String name, String description, BigDecimal price, long categoryId, 
                          long brandId, String material, String status) {
        String sql = "UPDATE products SET name = ?, description = ?, price = ?, category_id = ?, brand_id = ?, "
                   + "material = ?, status = ?, updated_at = ? WHERE product_id = ?";

        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, name);
            ps.setString(2, description);
            ps.setBigDecimal(3, price);
            ps.setLong(4, categoryId);
            ps.setLong(5, brandId);
            ps.setString(6, material);
            ps.setString(7, status);
            ps.setTimestamp(8, new java.sql.Timestamp(new Date().getTime()));
            ps.setLong(9, productId);
            int num = ps.executeUpdate();
            if (num > 0) {
                return true;
            } else {
                return false;
            }
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }
        return false;
    }
*/
   public int insert(String name, String description, BigDecimal price, long categoryId, long brandId, 
                     String material, String status, List<ProductVariant> variants) {
        String getMaxId = "SELECT MAX(product_id) AS maxid FROM products";
        long nextId;
        try {
            PreparedStatement psGetMaxId = conn.prepareStatement(getMaxId);
            ResultSet rsGetMaxId = psGetMaxId.executeQuery();
            if (rsGetMaxId.next()) {
                nextId = rsGetMaxId.getLong("maxid") + 1;
            } else {
                nextId = 1;
            }
            String sql = "SET IDENTITY_INSERT products ON; "
                       + "INSERT INTO products (product_id, name, description, price, category_id, brand_id, material, status, created_at) "
                       + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?); "
                       + "SET IDENTITY_INSERT products OFF;";

            try {
                conn.setAutoCommit(false);
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setLong(1, nextId);
                ps.setString(2, name);
                ps.setString(3, description);
                ps.setBigDecimal(4, price);
                ps.setLong(5, categoryId);
                ps.setLong(6, brandId);
                ps.setString(7, material);
                ps.setString(8, status);
                ps.setTimestamp(9, new java.sql.Timestamp(new Date().getTime()));
                int row = ps.executeUpdate();
                
                if (row > 0) {
                    String checkSkuSql = "SELECT sku FROM product_variants WHERE sku = ?";
                    PreparedStatement psCheckSku = conn.prepareStatement(checkSkuSql);
                    String variantSql = "INSERT INTO product_variants (product_id, size, color, price_modifier, sku) "
                                     + "VALUES (?, ?, ?, ?, ?)";
                    PreparedStatement psVariant = conn.prepareStatement(variantSql);
                    
                    for (ProductVariant variant : variants) {
                        String sku = variant.getSku();
                        if (sku == null || sku.length() > 100) {
                            conn.rollback();
                            System.out.println("Invalid SKU: " + (sku == null ? "null" : "exceeds 100 characters"));
                            return 0;
                        }
                        
                        psCheckSku.setString(1, sku);
                        ResultSet rs = psCheckSku.executeQuery();
                        if (rs.next()) {
                            conn.rollback();
                            System.out.println("Duplicate SKU: " + sku);
                            return 0;
                        }
                        
                        psVariant.setLong(1, nextId);
                        psVariant.setString(2, variant.getSize());
                        psVariant.setString(3, variant.getColor());
                        psVariant.setBigDecimal(4, variant.getPriceModifier());
                        psVariant.setString(5, sku);
                        psVariant.executeUpdate();
                    }
                    conn.commit();
                    return 1;
                } else {
                    conn.rollback();
                    return 0;
                }
            } catch (SQLException e) {
                conn.rollback();
                System.out.println("Database error: " + e.getMessage());
                return 0;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (Exception e) {
            System.out.println("Error: " + e.getMessage());
            return 0;
        }
    }

    public boolean update(long id, String name, String description, BigDecimal price, long categoryId, long brandId, 
                         String material, String status, List<ProductVariant> variants) {
        try {
            conn.setAutoCommit(false);

            // Update product
            String productSql = "UPDATE products SET name = ?, description = ?, price = ?, category_id = ?, brand_id = ?, " +
                               "material = ?, status = ?, updated_at = ? WHERE product_id = ?";
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
            String updateVariantSql = "UPDATE product_variants SET size = ?, color = ?, price_modifier = ?, sku = ? " +
                                     "WHERE variant_id = ? AND product_id = ?";
            String insertVariantSql = "INSERT INTO product_variants (product_id, size, color, price_modifier, sku) " +
                                     "VALUES (?, ?, ?, ?, ?)";
            PreparedStatement psCheckSku = conn.prepareStatement(checkSkuSql);
            PreparedStatement psUpdateVariant = conn.prepareStatement(updateVariantSql);
            PreparedStatement psInsertVariant = conn.prepareStatement(insertVariantSql);

            List<Long> submittedVariantIds = new ArrayList<>();
            for (ProductVariant variant : variants) {
                String sku = variant.getSku();
                if (sku == null || sku.length() > 100) {
                    conn.rollback();
                    System.out.println("Invalid SKU: " + (sku == null ? "null" : "exceeds 100 characters"));
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
                    psInsertVariant.executeUpdate();
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

            conn.commit();
            return true;
        } catch (SQLException e) {
            try {
                conn.rollback();
            } catch (SQLException ex) {
                System.out.println("Rollback error: " + ex.getMessage());
            }
            System.out.println("Database error: " + e.getMessage());
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

   public List<Product> filterProducts(Long categoryId, Long brandId, String size, String color, 
                                    BigDecimal minPrice, BigDecimal maxPrice) {
    List<Product> list = new ArrayList<>();
    StringBuilder sql = new StringBuilder(
        "SELECT p.product_id, p.name, p.description, p.price, p.category_id, p.brand_id, p.material, p.status, "
        + "p.created_at, p.updated_at, c.category_id, c.name AS category_name, c.description AS category_description, "
        + "c.parent_category_id, c.is_active AS category_active, c.created_at AS category_created_at, "
        + "b.brand_id, b.name AS brand_name, b.description AS brand_description, b.logo_url, b.is_active AS brand_active, "
        + "b.created_at AS brand_created_at "
        + "FROM products p "
        + "LEFT JOIN categories c ON p.category_id = c.category_id "
        + "LEFT JOIN brands b ON p.brand_id = b.brand_id "
    );

    List<Object> params = new ArrayList<>();
    if (categoryId != null) {
        sql.append("WHERE p.category_id = ? ");
        params.add(categoryId);
    } else if (brandId != null) {
        sql.append("WHERE p.brand_id = ? ");
        params.add(brandId);
    } else {
        sql.append("WHERE 1=1 "); // Default to all products if no category or brand
    }
    if (minPrice != null) {
        sql.append("AND p.price >= ? ");
        params.add(minPrice);
    }
    if (maxPrice != null) {
        sql.append("AND p.price <= ? ");
        params.add(maxPrice);
    }
    // Only join and filter by product_variants if size or color is provided
    if (size != null && !size.isEmpty() || color != null && !color.isEmpty()) {
        sql.append("LEFT JOIN product_variants pv ON p.product_id = pv.product_id ");
        if (size != null && !size.isEmpty()) {
            sql.append("AND LOWER(pv.size) LIKE LOWER(?) ");
            params.add(size + "%");
        }
        if (color != null && !color.isEmpty()) {
            sql.append("AND LOWER(pv.color) LIKE LOWER(?) ");
            params.add(color + "%");
        }
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
        }
        System.out.println("Rows returned: " + rowCount); // Log number of rows
        return list;
    } catch (Exception e) {
        System.out.println("Error in filterProducts: " + e.getMessage());
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
        String sql = "SELECT variant_id, product_id, size, color, price_modifier, sku "
                   + "FROM product_variants WHERE product_id = ?";

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
                variants.add(variant);
            }
            return variants;
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }
        return variants;
    }

    private List<ProductImage> getImagesByProductId(long productId) {
        List<ProductImage> images = new ArrayList<>();
        String sql = "SELECT image_id, product_id, variant_id, image_url, display_order, created_at "
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
                    rs.getTimestamp("created_at")
                );
                images.add(image);
            }
            return images;
        } catch (Exception e) {
            System.out.println(e.getMessage());
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