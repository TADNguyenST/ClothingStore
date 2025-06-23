/*
 * Click nbproject://SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbproject://SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.Inventory;
import model.Product;
import util.DBContext;

/**
 *
 * @author DANGVUONGTHINH
 */
public class InventoryDAO extends DBContext {
    
    public List<Inventory> getAll() {
        List<Inventory> list = new ArrayList<>();
        String sql = "SELECT i.inventory_id, i.product_id, i.variant_id, i.quantity, i.reserved_quantity, i.last_updated, "
                + "p.product_id, p.name AS product_name "
                + "FROM inventory i "
                + "JOIN products p ON i.product_id = p.product_id";

        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                long inventoryId = rs.getLong("inventory_id");
                long productId = rs.getLong("product_id");
                Long variantId = rs.getLong("variant_id");
                int quantity = rs.getInt("quantity");
                int reservedQuantity = rs.getInt("reserved_quantity");
                java.sql.Timestamp lastUpdated = rs.getTimestamp("last_updated");
                java.time.LocalDateTime lastUpdatedLocal = lastUpdated != null ? lastUpdated.toLocalDateTime() : null;

                String productName = rs.getString("product_name");
                Product product = new Product();
                product.setProductId(productId);
                product.setName(productName);

                Inventory inventory = new Inventory();
                inventory.setInventoryId(inventoryId);
                inventory.setProductId(productId);
                inventory.setProduct(product);
                inventory.setVariantId(variantId);
                inventory.setQuantity(quantity);
                inventory.setReservedQuantity(reservedQuantity);
                inventory.setLastUpdated(lastUpdatedLocal);

                list.add(inventory);
            }
            return list;
        } catch (Exception e) {
            System.out.println("Error in getAll: " + e.getMessage());
        }
        return list;
    }

    public Inventory getInventoryById(long inventoryId) {
        String sql = "SELECT i.inventory_id, i.product_id, i.variant_id, i.quantity, i.reserved_quantity, i.last_updated, "
                + "p.product_id, p.name AS product_name "
                + "FROM inventory i "
                + "JOIN products p ON i.product_id = p.product_id "
                + "WHERE i.inventory_id = ?";

        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setLong(1, inventoryId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                long id = rs.getLong("inventory_id");
                long productId = rs.getLong("product_id");
                Long variantId = rs.getLong("variant_id");
                int quantity = rs.getInt("quantity");
                int reservedQuantity = rs.getInt("reserved_quantity");
                java.sql.Timestamp lastUpdated = rs.getTimestamp("last_updated");
                java.time.LocalDateTime lastUpdatedLocal = lastUpdated != null ? lastUpdated.toLocalDateTime() : null;

                String productName = rs.getString("product_name");
                Product product = new Product();
                product.setProductId(productId);
                product.setName(productName);

                Inventory inventory = new Inventory();
                inventory.setInventoryId(id);
                inventory.setProductId(productId);
                inventory.setProduct(product);
                inventory.setVariantId(variantId);
                inventory.setQuantity(quantity);
                inventory.setReservedQuantity(reservedQuantity);
                inventory.setLastUpdated(lastUpdatedLocal);
                return inventory;
            }
        } catch (Exception e) {
            System.out.println("Error in getInventoryById: " + e.getMessage());
        }
        return null;
    }
}