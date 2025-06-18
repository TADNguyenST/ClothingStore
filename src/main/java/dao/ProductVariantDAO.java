/*
 * Click nbproject://SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbproject://SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.Product;
import model.ProductVariant;
import util.DBContext;

/**
 *
 * @author DANGVUONGTHINH
 */
public class ProductVariantDAO extends DBContext {
    
    public List<ProductVariant> getAll() {
        List<ProductVariant> list = new ArrayList<>();
        String sql = "SELECT pv.variant_id, pv.product_id, pv.size, pv.color, pv.quantity, pv.price, pv.sku, pv.created_at, "
                + "p.product_id, p.name AS product_name "
                + "FROM product_variants pv "
                + "JOIN products p ON pv.product_id = p.product_id";

        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                long variantId = rs.getLong("variant_id");
                long productId = rs.getLong("product_id");
                String size = rs.getString("size");
                String color = rs.getString("color");
                int quantity = rs.getInt("quantity");
                double price = rs.getDouble("price");
                String sku = rs.getString("sku");
                java.sql.Timestamp createdAt = rs.getTimestamp("created_at");
                java.time.LocalDateTime createdAtLocal = createdAt != null ? createdAt.toLocalDateTime() : null;

                String productName = rs.getString("product_name");
                Product product = new Product();
                product.setProductId(productId);
                product.setName(productName);

                ProductVariant variant = new ProductVariant();
                variant.setVariantId(variantId);
                variant.setProductId(productId);
                variant.setProduct(product);
                variant.setSize(size);
                variant.setColor(color);
                variant.setQuantity(quantity);
                if (rs.wasNull()) {
                    variant.setPrice(0.0);
                } else {
                    variant.setPrice(price);
                }
                variant.setSku(sku);
                variant.setCreatedAt(createdAtLocal);

                list.add(variant);
            }
            return list;
        } catch (Exception e) {
            System.out.println("Error in getAll: " + e.getMessage());
        }
        return list;
    }

    public ProductVariant getProductVariantById(long variantId) {
        String sql = "SELECT pv.variant_id, pv.product_id, pv.size, pv.color, pv.quantity, pv.price, pv.sku, pv.created_at, "
                + "p.product_id, p.name AS product_name "
                + "FROM product_variants pv "
                + "JOIN products p ON pv.product_id = p.product_id "
                + "WHERE pv.variant_id = ?";

        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setLong(1, variantId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                long id = rs.getLong("variant_id");
                long productId = rs.getLong("product_id");
                String size = rs.getString("size");
                String color = rs.getString("color");
                int quantity = rs.getInt("quantity");
                double price = rs.getDouble("price");
                String sku = rs.getString("sku");
                java.sql.Timestamp createdAt = rs.getTimestamp("created_at");
                java.time.LocalDateTime createdAtLocal = createdAt != null ? createdAt.toLocalDateTime() : null;

                String productName = rs.getString("product_name");
                Product product = new Product();
                product.setProductId(productId);
                product.setName(productName);

                ProductVariant variant = new ProductVariant();
                variant.setVariantId(id);
                variant.setProductId(productId);
                variant.setProduct(product);
                variant.setSize(size);
                variant.setColor(color);
                variant.setQuantity(quantity);
                if (rs.wasNull()) {
                    variant.setPrice(0.0);
                } else {
                    variant.setPrice(price);
                }
                variant.setSku(sku);
                variant.setCreatedAt(createdAtLocal);
                return variant;
            }
        } catch (Exception e) {
            System.out.println("Error in getProductVariantById: " + e.getMessage());
        }
        return null;
    }
}