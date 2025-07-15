/*
 * Click nbproject://SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbproject://SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
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

    public List<Map<String, Object>> getFilteredAndPaginatedStockMovements(String startDate, String endDate, String filterType, int offset, int limit) throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();

        // SQL cơ bản
        String baseSql = "SELECT sm.movement_id, sm.created_at, p.name as productName, pv.size, pv.color, pv.sku, "
                + "sm.movement_type, sm.quantity_changed, sm.notes, sm.variant_id "
                + "FROM stock_movements sm "
                + "JOIN product_variants pv ON sm.variant_id = pv.variant_id "
                + "JOIN products p ON pv.product_id = p.product_id";

        StringBuilder whereClause = new StringBuilder();
        List<Object> params = new ArrayList<>();

        // Xây dựng điều kiện WHERE động
        if (startDate != null && !startDate.isEmpty()) {
            whereClause.append("sm.created_at >= ?");
            params.add(startDate);
        }
        if (endDate != null && !endDate.isEmpty()) {
            if (whereClause.length() > 0) {
                whereClause.append(" AND");
            }
            // Thêm 1 ngày để bao gồm cả ngày kết thúc
            whereClause.append(" sm.created_at < DATEADD(day, 1, ?)");
            params.add(endDate);
        }
        if (filterType != null && !filterType.isEmpty() && !filterType.equals("all")) {
            if (whereClause.length() > 0) {
                whereClause.append(" AND ");
            }
            whereClause.append("sm.movement_type = ?");
            params.add(filterType);
        }
        String finalSql = baseSql;
        if (whereClause.length() > 0) {
            finalSql += " WHERE " + whereClause.toString();
        }

        finalSql += " ORDER BY sm.created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        try ( Connection conn = new DBContext().getConnection(); // Mở connection mới ở đây
                  PreparedStatement ps = conn.prepareStatement(finalSql)) {

            // Set các tham số cho WHERE clause
            int paramIndex = 1;
            for (Object p : params) {
                ps.setObject(paramIndex++, p);
            }
            // Set các tham số cho OFFSET và FETCH
            ps.setInt(paramIndex++, offset);
            ps.setInt(paramIndex, limit);

            try ( ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> move = new HashMap<>();
                    move.put("createdAt", rs.getTimestamp("created_at").toLocalDateTime());
                    move.put("productName", rs.getString("productName"));
                    move.put("size", rs.getString("size"));
                    move.put("color", rs.getString("color"));
                    move.put("sku", rs.getString("sku"));
                    move.put("movementType", rs.getString("movement_type"));
                    move.put("quantityChanged", rs.getInt("quantity_changed"));
                    move.put("notes", rs.getString("notes"));
                    move.put("variantId", rs.getLong("variant_id"));
                    list.add(move);
                }
            }
        }
        return list;
    }

    /**
     * Phương thức mới để đếm tổng số bản ghi sau khi đã lọc.
     *
     * @param startDate
     * @param endDate
     */
    public int getTotalFilteredStockMovements(String startDate, String endDate, String filterType) throws SQLException {
        String baseSql = "SELECT COUNT(*) FROM stock_movements sm";

        StringBuilder whereClause = new StringBuilder();
        List<Object> params = new ArrayList<>();

        if (startDate != null && !startDate.isEmpty()) {
            whereClause.append("sm.created_at >= ?");
            params.add(startDate);
        }
        if (endDate != null && !endDate.isEmpty()) {
            if (whereClause.length() > 0) {
                whereClause.append(" AND");
            }
            whereClause.append(" sm.created_at < DATEADD(day, 1, ?)");
            params.add(endDate);
        }
        if (filterType != null && !filterType.isEmpty() && !filterType.equals("all")) {
            if (whereClause.length() > 0) {
                whereClause.append(" AND ");
            }
            whereClause.append("sm.movement_type = ?");
            params.add(filterType);
        }
        String finalSql = baseSql;
        if (whereClause.length() > 0) {
            finalSql += " WHERE " + whereClause.toString();
        }

        try ( Connection conn = new DBContext().getConnection();  PreparedStatement ps = conn.prepareStatement(finalSql)) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }
}
