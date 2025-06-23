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
import model.Staff;
import model.StockMovement;
import util.DBContext;

/**
 *
 * @author DANGVUONGTHINH
 */
public class StockMovementDAO extends DBContext {
    
    public List<StockMovement> getAll() {
        List<StockMovement> list = new ArrayList<>();
        String sql = "SELECT sm.movement_id, sm.product_id, sm.variant_id, sm.movement_type, sm.quantity, sm.reference_type, "
                + "sm.reference_id, sm.notes, sm.created_by, sm.created_at, "
                + "p.product_id, p.name AS product_name, pv.variant_id, pv.size, s.staff_id, s.position "
                + "FROM stock_movements sm "
                + "JOIN products p ON sm.product_id = p.product_id "
                + "LEFT JOIN product_variants pv ON sm.variant_id = pv.variant_id "
                + "JOIN staff s ON sm.created_by = s.staff_id";

        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                long movementId = rs.getLong("movement_id");
                long productId = rs.getLong("product_id");
                Long variantId = rs.getLong("variant_id");
                String movementType = rs.getString("movement_type");
                int quantity = rs.getInt("quantity");
                String referenceType = rs.getString("reference_type");
                Long referenceId = rs.getLong("reference_id");
                String notes = rs.getString("notes");
                long createdBy = rs.getLong("created_by");
                java.sql.Timestamp createdAt = rs.getTimestamp("created_at");
                java.time.LocalDateTime createdAtLocal = createdAt != null ? createdAt.toLocalDateTime() : null;

                String productName = rs.getString("product_name");
                Product product = new Product();
                product.setProductId(productId);
                product.setName(productName);

                ProductVariant variant = null;
                if (variantId != null) {
                    String size = rs.getString("size");
                    variant = new ProductVariant();
                    variant.setVariantId(variantId);
                    variant.setSize(size);
                }

                String position = rs.getString("position");
                Staff staff = new Staff();
                staff.setStaffId(createdBy);
                staff.setPosition(position);

                StockMovement movement = new StockMovement();
                movement.setMovementId(movementId);
                movement.setProductId(productId);
                movement.setProduct(product);
                movement.setVariantId(variantId);
                movement.setVariant(variant);
                movement.setMovementType(movementType);
                movement.setQuantity(quantity);
                movement.setReferenceType(referenceType);
                movement.setReferenceId(referenceId);
                movement.setNotes(notes);
                movement.setCreatedBy(createdBy);
                movement.setStaff(staff);
                movement.setCreatedAt(createdAtLocal);

                list.add(movement);
            }
            return list;
        } catch (Exception e) {
            System.out.println("Error in getAll: " + e.getMessage());
        }
        return list;
    }

    public StockMovement getStockMovementById(long movementId) {
        String sql = "SELECT sm.movement_id, sm.product_id, sm.variant_id, sm.movement_type, sm.quantity, sm.reference_type, "
                + "sm.reference_id, sm.notes, sm.created_by, sm.created_at, "
                + "p.product_id, p.name AS product_name, pv.variant_id, pv.size, s.staff_id, s.position "
                + "FROM stock_movements sm "
                + "JOIN products p ON sm.product_id = p.product_id "
                + "LEFT JOIN product_variants pv ON sm.variant_id = pv.variant_id "
                + "JOIN staff s ON sm.created_by = s.staff_id "
                + "WHERE sm.movement_id = ?";

        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setLong(1, movementId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                long id = rs.getLong("movement_id");
                long productId = rs.getLong("product_id");
                Long variantId = rs.getLong("variant_id");
                String movementType = rs.getString("movement_type");
                int quantity = rs.getInt("quantity");
                String referenceType = rs.getString("reference_type");
                Long referenceId = rs.getLong("reference_id");
                String notes = rs.getString("notes");
                long createdBy = rs.getLong("created_by");
                java.sql.Timestamp createdAt = rs.getTimestamp("created_at");
                java.time.LocalDateTime createdAtLocal = createdAt != null ? createdAt.toLocalDateTime() : null;

                String productName = rs.getString("product_name");
                Product product = new Product();
                product.setProductId(productId);
                product.setName(productName);

                ProductVariant variant = null;
                if (variantId != null) {
                    String size = rs.getString("size");
                    variant = new ProductVariant();
                    variant.setVariantId(variantId);
                    variant.setSize(size);
                }

                String position = rs.getString("position");
                Staff staff = new Staff();
                staff.setStaffId(createdBy);
                staff.setPosition(position);

                StockMovement movement = new StockMovement();
                movement.setMovementId(id);
                movement.setProductId(productId);
                movement.setProduct(product);
                movement.setVariantId(variantId);
                movement.setVariant(variant);
                movement.setMovementType(movementType);
                movement.setQuantity(quantity);
                movement.setReferenceType(referenceType);
                movement.setReferenceId(referenceId);
                movement.setNotes(notes);
                movement.setCreatedBy(createdBy);
                movement.setStaff(staff);
                movement.setCreatedAt(createdAtLocal);
                return movement;
            }
        } catch (Exception e) {
            System.out.println("Error in getStockMovementById: " + e.getMessage());
        }
        return null;
    }
}