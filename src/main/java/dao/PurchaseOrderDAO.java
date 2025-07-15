package dao;

import model.PurchaseOrder;
import model.PurchaseOrderDetail;
import model.StockMovement;
import model.Supplier;
import util.DBContext;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class PurchaseOrderDAO {

    /**
     * Gets all active suppliers to display in a dropdown.
     *
     * @return A list of Supplier objects.
     * @throws SQLException
     */
    public List<Supplier> getAllActiveSuppliers() throws SQLException {
        List<Supplier> list = new ArrayList<>();
        String sql = "SELECT supplier_id, name FROM suppliers WHERE is_active = 1 ORDER BY name";
        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Supplier s = new Supplier();
                s.setSupplierId(rs.getLong("supplier_id"));
                s.setName(rs.getString("name"));
                list.add(s);
            }
        }
        return list;
    }

    public List<Map<String, Object>> getAllVariantsForSelection() throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();
        // Use LEFT JOIN to get products not yet in inventory (quantity = 0)
        String sql = "SELECT pv.variant_id, pv.sku, pv.size, pv.color, p.name as productName, ISNULL(i.quantity, 0) as currentStock "
                + "FROM product_variants pv "
                + "JOIN products p ON pv.product_id = p.product_id "
                + "LEFT JOIN inventory i ON pv.variant_id = i.variant_id "
                + "ORDER BY p.name, pv.size, pv.color";

        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> item = new HashMap<>();
                item.put("variantId", rs.getLong("variant_id"));
                item.put("productName", rs.getString("productName"));
                item.put("sku", rs.getString("sku"));
                item.put("size", rs.getString("size"));
                item.put("color", rs.getString("color"));
                item.put("currentStock", rs.getInt("currentStock"));
                list.add(item);
            }
        }
        return list;
    }

    /**
     * Creates a draft purchase order in the database.
     *
     * @param notes   The name/notes of the PO.
     * @param staffId The ID of the staff creating the PO.
     * @return The ID of the newly created purchase order.
     * @throws SQLException
     */
    public long createDraftPO(String notes, long staffId) throws SQLException {
        String sql = "INSERT INTO purchase_orders (notes, staff_id, order_date, status) VALUES (?, ?, GETDATE(), 'Draft')";
        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, notes);
            ps.setLong(2, staffId);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getLong(1);
                }
            }
        }
        throw new SQLException("Creating draft PO failed, no ID obtained.");
    }

    /**
     * Gets the header information of a purchase order.
     *
     * @param poId The ID of the PO to retrieve.
     * @return A Map containing the PO's information.
     * @throws java.sql.SQLException
     */
    public Map<String, Object> getPurchaseOrderHeader(long poId) throws SQLException {
        String sql = "SELECT po.*, s.name as supplierName FROM purchase_orders po "
                + "LEFT JOIN suppliers s ON po.supplier_id = s.supplier_id WHERE po.purchase_order_id = ?";
        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, poId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> poData = new HashMap<>();
                    poData.put("poId", rs.getLong("purchase_order_id"));
                    poData.put("supplierId", rs.getObject("supplier_id"));
                    poData.put("supplierName", rs.getString("supplierName"));
                    poData.put("status", rs.getString("status"));
                    poData.put("notes", rs.getString("notes"));
                    poData.put("orderDate", rs.getTimestamp("order_date"));
                    return poData;
                }
            }
        }
        return null;
    }

    /**
     * Gets the list of products (details) already in a purchase order.
     *
     * @param poId The ID of the purchase order.
     * @return A List of Maps, where each Map is the information of a product line.
     * @throws java.sql.SQLException
     */
    public List<Map<String, Object>> getItemsInPurchaseOrder(long poId) throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT pod.purchase_order_detail_id as podId, pod.variant_id, pod.quantity, pod.unit_price, pod.total_price, "
                + "p.name as productName, pv.sku, pv.size, pv.color "
                + "FROM purchase_order_details pod "
                + "JOIN product_variants pv ON pod.variant_id = pv.variant_id "
                + "JOIN products p ON pv.product_id = p.product_id "
                + "WHERE pod.purchase_order_id = ? ORDER BY pod.purchase_order_detail_id";
        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, poId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> item = new HashMap<>();
                    item.put("podId", rs.getLong("podId"));
                    item.put("variantId", rs.getLong("variant_id"));
                    item.put("productName", rs.getString("productName"));
                    item.put("sku", rs.getString("sku"));
                    item.put("size", rs.getString("size"));
                    item.put("color", rs.getString("color"));
                    item.put("quantity", rs.getInt("quantity"));
                    item.put("unitPrice", rs.getBigDecimal("unit_price"));
                    item.put("totalPrice", rs.getBigDecimal("total_price"));
                    list.add(item);
                }
            }
        }
        return list;
    }

    /**
     * Adds multiple product variants to a purchase order's details.
     *
     * @param poId       The ID of the purchase order.
     * @param variantIds A list of product_variant IDs to add.
     * @throws java.sql.SQLException
     */
    public void addVariantsToPODetails(long poId, List<Long> variantIds) throws SQLException {
        String checkSql = "SELECT COUNT(*) FROM purchase_order_details WHERE purchase_order_id = ? AND variant_id = ?";
        String insertSql = "INSERT INTO purchase_order_details (purchase_order_id, variant_id, quantity, unit_price, total_price) VALUES (?, ?, 1, 0, 0)";

        try (Connection conn = new DBContext().getConnection()) {
            for (Long variantId : variantIds) {
                // Check to avoid duplicates
                try (PreparedStatement psCheck = conn.prepareStatement(checkSql)) {
                    psCheck.setLong(1, poId);
                    psCheck.setLong(2, variantId);
                    try (ResultSet rs = psCheck.executeQuery()) {
                        if (rs.next() && rs.getInt(1) > 0) {
                            continue; // Skip if already exists
                        }
                    }
                }
                // Insert new item
                try (PreparedStatement psInsert = conn.prepareStatement(insertSql)) {
                    psInsert.setLong(1, poId);
                    psInsert.setLong(2, variantId);
                    psInsert.executeUpdate();
                }
            }
        }
    }

    /**
     * Deletes a product line from a purchase order detail (when the PO is still a draft).
     *
     * @param podId The ID of the purchase_order_detail to delete.
     */
    public void deleteItemFromPO(long podId) throws SQLException {
        String sql = "DELETE FROM purchase_order_details WHERE purchase_order_detail_id = ?";
        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, podId);
            ps.executeUpdate();
        }
    }

    /**
     * Cancels and completely deletes a draft purchase order.
     *
     * @param poId The ID of the draft PO to delete.
     */
    public void deleteDraftPO(long poId) throws SQLException {
        String deleteDetailsSql = "DELETE FROM purchase_order_details WHERE purchase_order_id = ?";
        String deletePoSql = "DELETE FROM purchase_orders WHERE purchase_order_id = ? AND status = 'Draft'";
        try (Connection conn = new DBContext().getConnection()) {
            conn.setAutoCommit(false); // Start internal transaction
            try {
                // Delete details first
                try (PreparedStatement psDetails = conn.prepareStatement(deleteDetailsSql)) {
                    psDetails.setLong(1, poId);
                    psDetails.executeUpdate();
                }
                // Delete main PO later
                try (PreparedStatement psPo = conn.prepareStatement(deletePoSql)) {
                    psPo.setLong(1, poId);
                    psPo.executeUpdate();
                }
                conn.commit(); // Finalize
            } catch (SQLException e) {
                conn.rollback(); // Rollback on error
                throw e;
            }
        }
    }
    
    // ================== START: NEW METHODS FOR NOTES AND SUPPLIER UPDATE ==================

    /**
     * Updates the notes for a given Purchase Order. Manages its own connection.
     * @param poId The ID of the PO to update.
     * @param notes The new notes text.
     * @throws SQLException
     */
    public void updatePONotes(long poId, String notes) throws SQLException {
        String sql = "UPDATE purchase_orders SET notes = ? WHERE purchase_order_id = ?";
        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, notes);
            ps.setLong(2, poId);
            ps.executeUpdate();
        }
    }
    
    /**
     * Updates the supplier for a draft Purchase Order. Manages its own connection.
     * @param poId The ID of the PO to update.
     * @param supplierId The ID of the new supplier.
     * @throws SQLException
     */
    public void updateDraftPOSupplier(long poId, long supplierId) throws SQLException {
        String sql = "UPDATE purchase_orders SET supplier_id = ? WHERE purchase_order_id = ? AND status = 'Draft'";
        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, supplierId);
            ps.setLong(2, poId);
            ps.executeUpdate();
        }
    }
    // ================== END: NEW METHODS ==================


    // ================================================================
    // METHODS USED WITHIN A CONTROLLER-MANAGED TRANSACTION
    // ================================================================
    
    /**
     * [TRANSACTIONAL] Updates the notes for a given Purchase Order.
     * @param conn The Connection managed by the Controller.
     * @param poId The ID of the PO to update.
     * @param notes The new notes text.
     * @throws SQLException
     */
    public void updatePONotes(long poId, String notes, Connection conn) throws SQLException {
        String sql = "UPDATE purchase_orders SET notes = ? WHERE purchase_order_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, notes);
            ps.setLong(2, poId);
            ps.executeUpdate();
        }
    }
    
    /**
     * [TRANSACTIONAL] Updates the supplier for a draft Purchase Order.
     * @param conn The Connection managed by the Controller.
     * @param poId The ID of the PO to update.
     * @param supplierId The ID of the new supplier.
     * @throws SQLException
     */
    public void updateDraftPOSupplier(long poId, long supplierId, Connection conn) throws SQLException {
        String sql = "UPDATE purchase_orders SET supplier_id = ? WHERE purchase_order_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, supplierId);
            ps.setLong(2, poId);
            ps.executeUpdate();
        }
    }

    /**
     * [TRANSACTIONAL] Updates the quantity and price for a detail line.
     * @param conn Connection managed by the Controller.
     */
    public void updatePODetail(long podId, int quantity, BigDecimal unitPrice, Connection conn) throws SQLException {
        String sql = "UPDATE purchase_order_details SET quantity = ?, unit_price = ?, total_price = ? * ? WHERE purchase_order_detail_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, quantity);
            ps.setBigDecimal(2, unitPrice);
            ps.setInt(3, quantity);
            ps.setBigDecimal(4, unitPrice);
            ps.setLong(5, podId);
            ps.executeUpdate();
        }
    }

    public void updatePODetail(long podId, int quantity, BigDecimal unitPrice) throws SQLException {
        String sql = "UPDATE purchase_order_details SET quantity = ?, unit_price = ?, total_price = ? * ? WHERE purchase_order_detail_id = ?";
        // Manages its own connection for this single operation
        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, quantity);
            ps.setBigDecimal(2, unitPrice);
            ps.setInt(3, quantity);
            ps.setBigDecimal(4, unitPrice);
            ps.setLong(5, podId);
            ps.executeUpdate();
        }
    }

    /**
     * [TRANSACTIONAL] Gets items for processing in the final transaction. Returns List<PurchaseOrderDetail> for cleaner Controller code.
     * @param conn Connection managed by the Controller.
     */
    public List<PurchaseOrderDetail> getItemsForConfirmation(long poId, Connection conn) throws SQLException {
        List<PurchaseOrderDetail> list = new ArrayList<>();
        String sql = "SELECT variant_id, quantity FROM purchase_order_details WHERE purchase_order_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, poId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    PurchaseOrderDetail pod = new PurchaseOrderDetail();
                    pod.setVariantId(rs.getLong("variant_id"));
                    pod.setQuantity(rs.getInt("quantity"));
                    list.add(pod);
                }
            }
        }
        return list;
    }

    /**
     * [TRANSACTIONAL] Finalizes the purchase order: updates supplier, status, and delivery date.
     * @param conn Connection managed by the Controller.
     */
    public void finalizePO(long poId, long supplierId, String status, Connection conn) throws SQLException {
        String sql = "UPDATE purchase_orders SET supplier_id = ?, status = ?, actual_delivery_date = GETDATE() WHERE purchase_order_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, supplierId);
            ps.setString(2, status);
            ps.setLong(3, poId);
            ps.executeUpdate();
        }
    }

    /**
     * [TRANSACTIONAL] Increases the inventory quantity for a product variant.
     * @param conn Connection managed by the Controller.
     */
    public void increaseInventoryForVariant(long variantId, int quantity, Connection conn) throws SQLException {
        String checkSql = "SELECT COUNT(*) FROM inventory WHERE variant_id = ?";
        String updateSql = "UPDATE inventory SET quantity = quantity + ? WHERE variant_id = ?";
        String insertSql = "INSERT INTO inventory (variant_id, quantity, reserved_quantity) VALUES (?, ?, 0)";

        try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
            checkPs.setLong(1, variantId);
            try (ResultSet rs = checkPs.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    try (PreparedStatement updatePs = conn.prepareStatement(updateSql)) {
                        updatePs.setInt(1, quantity);
                        updatePs.setLong(2, variantId);
                        updatePs.executeUpdate();
                    }
                } else {
                    try (PreparedStatement insertPs = conn.prepareStatement(insertSql)) {
                        insertPs.setLong(1, variantId);
                        insertPs.setInt(2, quantity);
                        insertPs.executeUpdate();
                    }
                }
            }
        }
    }

    /**
     * [TRANSACTIONAL] Records a stock movement history.
     * @param conn Connection managed by the Controller.
     */
    public void addStockMovement(StockMovement sm, Connection conn) throws SQLException {
        String sql = "INSERT INTO stock_movements (variant_id, movement_type, quantity_changed, reference_type, reference_id, notes, created_by, created_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, GETDATE())";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, sm.getVariantId());
            ps.setString(2, sm.getMovementType());
            ps.setInt(3, sm.getQuantity());
            ps.setString(4, sm.getReferenceType());
            ps.setLong(5, sm.getReferenceId());
            ps.setString(6, sm.getNotes());
            ps.setLong(7, sm.getCreatedBy());
            ps.executeUpdate();
        }
    }

    /**
     * Gets a list of all purchase orders for display, with filtering and pagination.
     *
     * @return A List of Maps, where each Map contains the information of a PO.
     * @throws SQLException
     */
    public List<Map<String, Object>> getFilteredAndPaginatedPurchaseOrders(String searchTerm, String startDate, String endDate, String status, int offset, int limit) throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();

        String baseSql = "SELECT po.purchase_order_id, po.notes, po.order_date, po.status, s.name as supplierName "
                + "FROM purchase_orders po "
                + "LEFT JOIN suppliers s ON po.supplier_id = s.supplier_id";

        StringBuilder whereClause = new StringBuilder();
        List<Object> params = new ArrayList<>();

        // Dynamically build the WHERE clause
        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            whereClause.append("(po.notes LIKE ? OR s.name LIKE ?)");
            params.add("%" + searchTerm + "%");
            params.add("%" + searchTerm + "%");
        }
        if (startDate != null && !startDate.isEmpty()) {
            if (whereClause.length() > 0) whereClause.append(" AND ");
            whereClause.append("po.order_date >= ?");
            params.add(startDate);
        }
        if (endDate != null && !endDate.isEmpty()) {
            if (whereClause.length() > 0) whereClause.append(" AND ");
            whereClause.append("po.order_date <= ?");
            params.add(endDate + " 23:59:59");
        }
        if (status != null && !status.isEmpty() && !status.equalsIgnoreCase("all")) {
            if (whereClause.length() > 0) whereClause.append(" AND ");
            whereClause.append("po.status = ?");
            params.add(status);
        }

        String finalSql = baseSql;
        if (whereClause.length() > 0) {
            finalSql += " WHERE " + whereClause.toString();
        }
        finalSql += " ORDER BY po.order_date DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(finalSql)) {
            int paramIndex = 1;
            for (Object p : params) {
                ps.setObject(paramIndex++, p);
            }
            ps.setInt(paramIndex++, offset);
            ps.setInt(paramIndex, limit);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> poData = new HashMap<>();
                    poData.put("poId", rs.getLong("purchase_order_id"));
                    poData.put("notes", rs.getString("notes"));
                    poData.put("orderDate", rs.getTimestamp("order_date"));
                    poData.put("status", rs.getString("status"));
                    poData.put("supplierName", rs.getString("supplierName"));
                    list.add(poData);
                }
            }
        }
        return list;
    }

    /**
     * Counts the total number of filtered purchase orders for pagination.
     */
    public int getTotalFilteredPurchaseOrders(String searchTerm, String startDate, String endDate, String status) throws SQLException {
        String baseSql = "SELECT COUNT(*) FROM purchase_orders po LEFT JOIN suppliers s ON po.supplier_id = s.supplier_id";
        StringBuilder whereClause = new StringBuilder();
        List<Object> params = new ArrayList<>();

        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            whereClause.append("(po.notes LIKE ? OR s.name LIKE ?)");
            params.add("%" + searchTerm + "%");
            params.add("%" + searchTerm + "%");
        }
        if (startDate != null && !startDate.isEmpty()) {
            if (whereClause.length() > 0) whereClause.append(" AND ");
            whereClause.append("po.order_date >= ?");
            params.add(startDate);
        }
        if (endDate != null && !endDate.isEmpty()) {
            if (whereClause.length() > 0) whereClause.append(" AND ");
            whereClause.append("po.order_date <= ?");
            params.add(endDate + " 23:59:59");
        }
        if (status != null && !status.isEmpty() && !status.equalsIgnoreCase("all")) {
            if (whereClause.length() > 0) whereClause.append(" AND ");
            whereClause.append("po.status = ?");
            params.add(status);
        }

        String finalSql = baseSql;
        if (whereClause.length() > 0) {
            finalSql += " WHERE " + whereClause.toString();
        }

        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(finalSql)) {
            int paramIndex = 1;
            for (Object p : params) {
                ps.setObject(paramIndex++, p);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }
}