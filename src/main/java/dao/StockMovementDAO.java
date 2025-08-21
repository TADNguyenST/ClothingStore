/*
 * Click nbproject://SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbproject://SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
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

                    // Luôn thêm key, kể cả khi giá trị có thể là null
                    Timestamp ts = rs.getTimestamp("created_at");
                    move.put("createdAtFormatted", ts != null ? new java.text.SimpleDateFormat("HH:mm:ss dd/MM/yyyy").format(ts) : "N/A");

                    move.put("productName", rs.getString("productName"));
                    move.put("size", rs.getString("size"));
                    move.put("color", rs.getString("color"));
                    move.put("sku", rs.getString("sku"));
                    move.put("movementType", rs.getString("movement_type"));
                    move.put("quantityChanged", rs.getInt("quantity_changed"));
                    move.put("notes", rs.getString("notes")); // Sẽ là null nếu không có ghi chú
                    move.put("variantId", rs.getLong("variant_id"));
                    move.put("staffName", rs.getString("staffName")); // Sẽ là null nếu không có staff

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

    private void buildWhereClause(StringBuilder whereClause, List<Object> params, String startDate, String endDate, String filterType, String searchTerm) {

        // Xử lý ngày bắt đầu
        if (startDate != null && !startDate.isEmpty()) {
            if (whereClause.length() > 0) { // Luôn kiểm tra trước khi thêm
                whereClause.append(" AND ");
            }
            whereClause.append("sm.created_at >= ?");
            params.add(startDate);
        }

        // Xử lý ngày kết thúc
        if (endDate != null && !endDate.isEmpty()) {
            if (whereClause.length() > 0) { // Luôn kiểm tra trước khi thêm
                whereClause.append(" AND ");
            }
            whereClause.append("sm.created_at < DATEADD(day, 1, ?)");
            params.add(endDate);
        }

        // Xử lý loại thay đổi
        if (filterType != null && !filterType.isEmpty() && !"all".equals(filterType)) {
            if (whereClause.length() > 0) { // Luôn kiểm tra trước khi thêm
                whereClause.append(" AND ");
            }
            whereClause.append("sm.movement_type = ?");
            params.add(filterType);
        }

        // Xử lý từ khóa tìm kiếm
        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            if (whereClause.length() > 0) { // Luôn kiểm tra trước khi thêm
                whereClause.append(" AND ");
            }
            whereClause.append("(p.name LIKE ? OR pv.sku LIKE ?)");
            String searchTermLike = "%" + searchTerm.trim() + "%";
            params.add(searchTermLike);
            params.add(searchTermLike);
        }
    }

    // Lấy danh sách Lịch sử kho (có lọc và phân trang)
    public List<Map<String, Object>> getFilteredAndPaginatedStockMovements(String startDate, String endDate, String filterType, String searchTerm, int offset, int limit) throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();
        String baseSql = "SELECT sm.movement_id, sm.created_at, p.name as productName, pv.size, pv.color, pv.sku, "
                + "sm.movement_type, sm.quantity_changed, sm.notes, sm.variant_id, u.full_name as staffName, "
                + "sm.reference_type, sm.reference_id "
                + "FROM stock_movements sm "
                + "JOIN product_variants pv ON sm.variant_id = pv.variant_id "
                + "JOIN products p ON pv.product_id = p.product_id "
                + "LEFT JOIN staff s ON sm.created_by = s.staff_id "
                + "LEFT JOIN users u ON s.user_id = u.user_id";

        StringBuilder whereClause = new StringBuilder();
        List<Object> params = new ArrayList<>();
        buildWhereClause(whereClause, params, startDate, endDate, filterType, searchTerm);

        String finalSql = baseSql;
        if (whereClause.length() > 0) {
            finalSql += " WHERE " + whereClause.toString();
        }

        finalSql += " ORDER BY sm.created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        try ( Connection conn = new DBContext().getConnection();  PreparedStatement ps = conn.prepareStatement(finalSql)) {

            int paramIndex = 1;
            for (Object p : params) {
                ps.setObject(paramIndex++, p);
            }
            ps.setInt(paramIndex++, offset);
            ps.setInt(paramIndex, limit);

            try ( ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> move = new HashMap<>();
                    Timestamp ts = rs.getTimestamp("created_at");
                    if (ts != null) {
                        move.put("createdAtFormatted", new java.text.SimpleDateFormat("HH:mm:ss dd/MM/yyyy").format(ts));
                    }
                    move.put("productName", rs.getString("productName"));
                    move.put("size", rs.getString("size"));
                    move.put("color", rs.getString("color"));
                    move.put("sku", rs.getString("sku"));
                    move.put("movementType", rs.getString("movement_type"));
                    move.put("quantityChanged", rs.getInt("quantity_changed"));
                    move.put("notes", rs.getString("notes"));
                    move.put("variantId", rs.getLong("variant_id"));
                    move.put("staffName", rs.getString("staffName"));
                    move.put("referenceType", rs.getString("reference_type"));
                    move.put("referenceId", rs.getLong("reference_id"));
                    list.add(move);
                }
            }
        }
        return list;
    }

    // Lấy tổng số bản ghi (có lọc)
    public int getTotalFilteredStockMovements(String startDate, String endDate, String filterType, String searchTerm) throws SQLException {
        String baseSql = "SELECT COUNT(DISTINCT sm.movement_id) "
                + "FROM stock_movements sm "
                + "JOIN product_variants pv ON sm.variant_id = pv.variant_id "
                + "JOIN products p ON pv.product_id = p.product_id";

        StringBuilder whereClause = new StringBuilder();
        List<Object> params = new ArrayList<>();
        buildWhereClause(whereClause, params, startDate, endDate, filterType, searchTerm);

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

    // Lấy dữ liệu đã gộp nhóm
    public Map<String, List<Map<String, Object>>> getGroupedMovements(String startDate, String endDate, String filterType, String searchTerm, String groupBy) throws SQLException {
        Map<String, List<Map<String, Object>>> groupedMovements = new LinkedHashMap<>();

        String groupColumn = "";
        String purchaseOrderJoin = "";
        String saleOrderJoin = "";
        String additionalWhere = "";

        switch (groupBy) {
            case "all_references":
                groupColumn = "CASE "
                        + // Ép kiểu po.notes sang NVARCHAR(4000) để có thể sắp xếp
                        "  WHEN sm.reference_type = 'Purchase Order' THEN CAST(ISNULL(po.notes, CONCAT('Purchase Order #', sm.reference_id)) AS NVARCHAR(4000)) "
                        + // Tương tự cho so.notes
                        "  WHEN sm.reference_type = 'Sale Order' THEN CAST(ISNULL(so.notes, CONCAT('Sale Order #', sm.reference_id)) AS NVARCHAR(4000)) "
                        + "  WHEN sm.reference_type = 'Adjustment' THEN 'Manual Adjustment' "
                        + "  ELSE CONCAT(sm.reference_type, ' #', sm.reference_id) "
                        + "END";
                purchaseOrderJoin = "LEFT JOIN purchase_orders po ON sm.reference_id = po.purchase_order_id AND sm.reference_type = 'Purchase Order'";
                saleOrderJoin = "LEFT JOIN orders so ON sm.reference_id = so.order_id AND sm.reference_type = 'Sale Order'";
                additionalWhere = "";
                break;

            case "purchase_order":
                groupColumn = "CAST(ISNULL(po.notes, CONCAT('Purchase Order #', po.purchase_order_id)) AS NVARCHAR(4000))";
                purchaseOrderJoin = "LEFT JOIN purchase_orders po ON sm.reference_id = po.purchase_order_id AND sm.reference_type = 'Purchase Order'";
                additionalWhere = "sm.reference_type = 'Purchase Order'";
                break;

            case "sale_order":
                groupColumn = "CAST(ISNULL(so.notes, CONCAT('Sale Order #', sm.reference_id)) AS NVARCHAR(4000))";
                saleOrderJoin = "LEFT JOIN orders so ON sm.reference_id = so.order_id AND sm.reference_type = 'Sale Order'";
                additionalWhere = "sm.reference_type = 'Sale Order'";
                break;
            default:
                groupColumn = "'Manual Adjustment'";
                additionalWhere = "sm.reference_type = 'Adjustment'";
                break;
        }

        String sql = "SELECT "
                + groupColumn + " as group_key, "
                + "p.name as productName, pv.size, pv.color, pv.sku, "
                + "sm.quantity_changed, sm.notes "
                + "FROM stock_movements sm "
                + "JOIN product_variants pv ON sm.variant_id = pv.variant_id "
                + "JOIN products p ON pv.product_id = p.product_id "
                + purchaseOrderJoin + " " + saleOrderJoin; // Thêm các JOIN vào câu SQL chính

        StringBuilder whereClause = new StringBuilder(additionalWhere);
        List<Object> params = new ArrayList<>();
        buildWhereClause(whereClause, params, startDate, endDate, filterType, searchTerm);

        if (whereClause.length() > 0) {
            sql += " WHERE " + whereClause.toString();
        }
        sql += " ORDER BY group_key, sm.created_at DESC";

        try ( Connection conn = new DBContext().getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try ( ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String key = rs.getString("group_key");
                    // THAY THẾ BẰNG 3 DÒNG NÀY
                    List<Map<String, Object>> movementsInGroup = groupedMovements.get(key);
                    if (movementsInGroup == null) {
                        movementsInGroup = new ArrayList<>();
                        groupedMovements.put(key, movementsInGroup);
                    }
                    Map<String, Object> move = new HashMap<>();
                    move.put("productName", rs.getString("productName"));
                    move.put("sku", rs.getString("sku"));
                    move.put("size", rs.getString("size"));
                    move.put("color", rs.getString("color"));
                    move.put("quantityChanged", rs.getInt("quantity_changed"));
                    move.put("notes", rs.getString("notes"));
                    movementsInGroup.add(move);
                }
            }
        }
        return groupedMovements;
    }
}
