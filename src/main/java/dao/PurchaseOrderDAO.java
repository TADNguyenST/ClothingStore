package dao;

import model.*;
import DTO.*;
import util.DBContext;
import DTO.PurchaseOrderHeaderDTO;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

public class PurchaseOrderDAO {

    // ================================================================
    // CÁC PHƯƠNG THỨC LẤY DỮ LIỆU
    // ================================================================
    /**
     * Lấy thông tin đầu trang của một Purchase Order.
     *
     * @param poId
     * @return PurchaseOrderHeaderDTO chứa thông tin cần thiết.
     * @throws java.sql.SQLException
     */
    public PurchaseOrderHeaderDTO getPurchaseOrderHeader(long poId) throws SQLException {
        String sql = "SELECT po.*, s.name as supplierName FROM purchase_orders po "
                + "LEFT JOIN suppliers s ON po.supplier_id = s.supplier_id WHERE po.purchase_order_id = ?";
        try ( Connection conn = new DBContext().getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, poId);
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    PurchaseOrderHeaderDTO poData = new PurchaseOrderHeaderDTO();
                    poData.setPoId(rs.getLong("purchase_order_id"));
                    long supplierId = rs.getLong("supplier_id");
                    if (!rs.wasNull()) {
                        poData.setSupplierId(supplierId);
                    }
                    poData.setSupplierName(rs.getString("supplierName"));
                    poData.setStatus(rs.getString("status"));
                    poData.setNotes(rs.getString("notes"));
                    poData.setOrderDate(rs.getTimestamp("order_date"));
                    return poData;
                }
            }
        }
        return null;
    }

    /**
     * Lấy danh sách các sản phẩm có trong một Purchase Order.
     *
     * @return List<PurchaseOrderItemDTO> chứa danh sách sản phẩm.
     */
    public List<PurchaseOrderItemDTO> getItemsInPurchaseOrder(long poId) throws SQLException {
        List<PurchaseOrderItemDTO> list = new ArrayList<>();
        String sql = "SELECT pod.purchase_order_detail_id as podId, pod.variant_id, pod.quantity, pod.unit_price, pod.total_price, "
                + "p.name as productName, pv.sku, pv.size, pv.color "
                + "FROM purchase_order_details pod "
                + "JOIN product_variants pv ON pod.variant_id = pv.variant_id "
                + "JOIN products p ON pv.product_id = p.product_id "
                + "WHERE pod.purchase_order_id = ? ORDER BY pod.purchase_order_detail_id";
        try ( Connection conn = new DBContext().getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, poId);
            try ( ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    PurchaseOrderItemDTO item = new PurchaseOrderItemDTO();
                    item.setPodId(rs.getLong("podId"));
                    item.setVariantId(rs.getLong("variant_id"));
                    item.setProductName(rs.getString("productName"));
                    item.setSku(rs.getString("sku"));
                    item.setSize(rs.getString("size"));
                    item.setColor(rs.getString("color"));
                    item.setQuantity(rs.getInt("quantity"));
                    item.setUnitPrice(rs.getBigDecimal("unit_price"));
                    item.setTotalPrice(rs.getBigDecimal("total_price"));
                    list.add(item);
                }
            }
        }
        return list;
    }

    /**
     * Lấy danh sách tất cả nhà cung cấp đang hoạt động.
     */
    public List<Supplier> getAllActiveSuppliers() throws SQLException {
        List<Supplier> list = new ArrayList<>();
        String sql = "SELECT supplier_id, name FROM suppliers WHERE is_active = 1 ORDER BY name";
        try ( Connection conn = new DBContext().getConnection();  PreparedStatement ps = conn.prepareStatement(sql);  ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Supplier s = new Supplier();
                s.setSupplierId(rs.getLong("supplier_id"));
                s.setName(rs.getString("name"));
                list.add(s);
            }
        }
        return list;
    }

    /**
     * [TRANSACTIONAL] Lấy thông tin ngữ cảnh (tên nhân viên, tên NCC) để tạo
     * ghi chú.
     */
    public PurchaseOrderContextDTO getContextForNotes(long poId, Connection conn) throws SQLException {
        String sql = "SELECT u.full_name, s.name as supplierName "
                + "FROM purchase_orders po "
                + "JOIN staff st ON po.staff_id = st.staff_id "
                + "JOIN users u ON st.user_id = u.user_id "
                + "JOIN suppliers s ON po.supplier_id = s.supplier_id "
                + "WHERE po.purchase_order_id = ?";
        try ( PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, poId);
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    PurchaseOrderContextDTO context = new PurchaseOrderContextDTO();
                    context.setStaffName(rs.getString("full_name"));
                    context.setSupplierName(rs.getString("supplierName"));
                    return context;
                }
            }
        }
        return null;
    }

    // ================================================================
    // CÁC PHƯƠNG THỨC TẠO VÀ XÓA
    // ================================================================
    /**
     * Tạo một Purchase Order mới ở trạng thái 'Draft'.
     *
     * @return ID của PO vừa được tạo.
     */
    public long createDraftPO(String notes, long staffId) throws SQLException {
        String sql = "INSERT INTO purchase_orders (notes, staff_id, order_date, status) VALUES (?, ?, SYSDATETIMEOFFSET() AT TIME ZONE 'SE Asia Standard Time', 'Draft')";
        try ( Connection conn = new DBContext().getConnection();  PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, notes);
            ps.setLong(2, staffId);
            ps.executeUpdate();
            try ( ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getLong(1);
                }
            }
        }
        throw new SQLException("Creating draft PO failed, no ID obtained.");
    }

    /**
     * Thêm nhiều sản phẩm vào chi tiết của một PO.
     */
    public void addVariantsToPODetails(long poId, List<Long> variantIds) throws SQLException {
    // Khử trùng ID client gửi lặp
    java.util.LinkedHashSet<Long> uniq = new java.util.LinkedHashSet<>(variantIds);

    String mergeSql =
        "MERGE INTO purchase_order_details AS target " +
        "USING (SELECT ? AS purchase_order_id, ? AS variant_id) AS src " +
        "ON (target.purchase_order_id = src.purchase_order_id AND target.variant_id = src.variant_id) " +
        "WHEN MATCHED THEN " +
        "  UPDATE SET quantity = target.quantity + 1, " +
        "             total_price = (target.quantity + 1) * target.unit_price " +
        "WHEN NOT MATCHED THEN " +
        "  INSERT (purchase_order_id, variant_id, quantity, unit_price, total_price) " +
        "  VALUES (src.purchase_order_id, src.variant_id, 1, 0, 0);";

    try (Connection conn = new DBContext().getConnection();
         PreparedStatement ps = conn.prepareStatement(mergeSql)) {
        conn.setAutoCommit(false);
        for (Long vid : uniq) {
            ps.setLong(1, poId);
            ps.setLong(2, vid);
            ps.addBatch();
        }
        ps.executeBatch();
        conn.commit();
    }
}

    /**
     * Xóa một dòng sản phẩm khỏi chi tiết PO.
     */
    public void deleteItemFromPO(long podId) throws SQLException {
        String sql = "DELETE FROM purchase_order_details WHERE purchase_order_detail_id = ?";
        try ( Connection conn = new DBContext().getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, podId);
            ps.executeUpdate();
        }
    }

    // ================================================================
    // CÁC PHƯƠNG THỨC CẬP NHẬT (BAO GỒM CÁC HÀM CHO AUTO-SAVE)
    // ================================================================
    /**
     * Cập nhật số lượng và tự tính lại tổng tiền cho một dòng chi tiết.
     *
     * @param podId
     */
    public void updateItemQuantity(long podId, int quantity) throws SQLException {
        String sql = "UPDATE purchase_order_details SET quantity = ?, total_price = unit_price * ? "
                + "WHERE purchase_order_detail_id = ?"; // <-- PHẢI LÀ ID CỦA DÒNG CHI TIẾT

        try ( Connection conn = new DBContext().getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, quantity);
            ps.setInt(2, quantity);
            ps.setLong(3, podId); // <-- Truyền vào podId (purchase_order_detail_id)
            ps.executeUpdate();
        }
    }

    /**
     * Cập nhật đơn giá và tự tính lại tổng tiền cho một dòng chi tiết.
     */
    // Trong file dao/PurchaseOrderDAO.java
    public void updateItemPrice(long podId, BigDecimal unitPrice) throws SQLException {
        String sql = "UPDATE purchase_order_details SET unit_price = ?, total_price = quantity * ? "
                + "WHERE purchase_order_detail_id = ?"; // <-- PHẢI LÀ ID CỦA DÒNG CHI TIẾT

        try ( Connection conn = new DBContext().getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBigDecimal(1, unitPrice);
            ps.setBigDecimal(2, unitPrice);
            ps.setLong(3, podId); // <-- Truyền vào podId (purchase_order_detail_id)
            ps.executeUpdate();
        }
    }

    /**
     * Cập nhật ghi chú cho một PO.
     */
    public void updatePONotes(long poId, String notes) throws SQLException {
        String sql = "UPDATE purchase_orders SET notes = ? WHERE purchase_order_id = ?";
        try ( Connection conn = new DBContext().getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, notes);
            ps.setLong(2, poId);
            ps.executeUpdate();
        }
    }

    /**
     * Cập nhật nhà cung cấp cho một PO (khi ở trạng thái Draft hoặc Sent).
     */
    public void updateDraftPOSupplier(long poId, long supplierId) throws SQLException {
        String sql = "UPDATE purchase_orders SET supplier_id = ? WHERE purchase_order_id = ? AND status IN ('Draft', 'Sent')";
        try ( Connection conn = new DBContext().getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, supplierId);
            ps.setLong(2, poId);
            ps.executeUpdate();
        }
    }

    public void clearPOSupplier(long poId) throws SQLException {
        String sql = "UPDATE purchase_orders SET supplier_id = NULL WHERE purchase_order_id = ? AND status IN ('Draft', 'Sent')";
        try ( Connection conn = new DBContext().getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, poId);
            ps.executeUpdate();
        }
    }

    // ================================================================
    // CÁC PHƯƠNG THỨC DÙNG TRONG TRANSACTION
    // ================================================================
    /**
     * [TRANSACTIONAL] Cập nhật trạng thái của một PO.
     */
    public void updatePOStatus(long poId, String newStatus, Connection conn) throws SQLException {
        String sql = "UPDATE purchase_orders SET status = ? WHERE purchase_order_id = ?";
        try ( PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setLong(2, poId);
            ps.executeUpdate();
        }
    }

    /**
     * [TRANSACTIONAL] Lấy các sản phẩm để xác nhận và cập nhật kho.
     */
    public List<PurchaseOrderDetail> getItemsForConfirmation(long poId, Connection conn) throws SQLException {
        List<PurchaseOrderDetail> list = new ArrayList<>();
        String sql = "SELECT variant_id, quantity FROM purchase_order_details WHERE purchase_order_id = ?";
        try ( PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, poId);
            try ( ResultSet rs = ps.executeQuery()) {
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
     * [TRANSACTIONAL] Tăng số lượng tồn kho cho một sản phẩm (logic Upsert).
     */
    public void increaseInventoryForVariant(long variantId, int quantity, Connection conn) throws SQLException {
        String mergeSql
                = "MERGE INTO inventory AS target "
                + "USING (SELECT ? AS variant_id) AS source "
                + "ON (target.variant_id = source.variant_id) "
                + "WHEN MATCHED THEN "
                + "    UPDATE SET quantity = target.quantity + ? "
                + "WHEN NOT MATCHED THEN "
                + "    INSERT (variant_id, quantity, reserved_quantity) VALUES (?, ?, 0);";

        try ( PreparedStatement ps = conn.prepareStatement(mergeSql)) {
            ps.setLong(1, variantId);
            ps.setInt(2, quantity);
            ps.setLong(3, variantId);
            ps.setInt(4, quantity);
            ps.executeUpdate();
        }
    }

    /**
     * [TRANSACTIONAL] Thêm một bản ghi lịch sử xuất/nhập kho.
     */
    public void addStockMovement(StockMovement sm, Connection conn) throws SQLException {
        String sql = "INSERT INTO stock_movements (variant_id, movement_type, quantity_changed, reference_type, reference_id, notes, created_by, created_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, SYSDATETIMEOFFSET() AT TIME ZONE 'SE Asia Standard Time')";
        try ( PreparedStatement ps = conn.prepareStatement(sql)) {
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

    public List<ProductVariantSelectionDTO> getAllVariantsForSelection() throws SQLException {
        List<ProductVariantSelectionDTO> list = new ArrayList<>();
        String sql = "SELECT pv.variant_id, pv.sku, pv.size, pv.color, p.name as productName, ISNULL(i.quantity, 0) as currentStock "
                + "FROM product_variants pv "
                + "JOIN products p ON pv.product_id = p.product_id "
                + "LEFT JOIN inventory i ON pv.variant_id = i.variant_id "
                + "ORDER BY p.name, pv.size, pv.color";

        try ( Connection conn = new DBContext().getConnection();  PreparedStatement ps = conn.prepareStatement(sql);  ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                ProductVariantSelectionDTO item = new ProductVariantSelectionDTO();
                item.setVariantId(rs.getLong("variant_id"));
                item.setProductName(rs.getString("productName"));
                item.setSku(rs.getString("sku"));
                item.setSize(rs.getString("size"));
                item.setColor(rs.getString("color"));
                item.setCurrentStock(rs.getInt("currentStock"));
                list.add(item);
            }
        }
        return list;
    }

    // ================================================================
    // CÁC PHƯƠNG THỨC CHO TRANG DANH SÁCH (ĐÃ HOÀN THIỆN)
    // ================================================================
    public List<Map<String, Object>> getFilteredAndPaginatedPurchaseOrders(String searchTerm, String startDate, String endDate, String status, int offset, int limit) throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();
        String baseSql = "SELECT po.purchase_order_id, po.notes, po.order_date, po.status, s.name as supplierName "
                + "FROM purchase_orders po "
                + "LEFT JOIN suppliers s ON po.supplier_id = s.supplier_id";

        StringBuilder whereClause = new StringBuilder();
        List<Object> params = new ArrayList<>();

        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            whereClause.append("(po.notes LIKE ? OR s.name LIKE ?)");
            params.add("%" + searchTerm.trim() + "%");
            params.add("%" + searchTerm.trim() + "%");
        }
        if (startDate != null && !startDate.isEmpty()) {
            if (whereClause.length() > 0) {
                whereClause.append(" AND ");
            }
            whereClause.append("po.order_date >= ?");
            params.add(startDate);
        }
        if (endDate != null && !endDate.isEmpty()) {
            if (whereClause.length() > 0) {
                whereClause.append(" AND ");
            }
            whereClause.append("po.order_date <= ?");
            params.add(endDate + " 23:59:59");
        }
        if (status != null && !status.isEmpty() && !status.equalsIgnoreCase("all")) {
            if (whereClause.length() > 0) {
                whereClause.append(" AND ");
            }
            whereClause.append("po.status = ?");
            params.add(status);
        }

        String finalSql = baseSql;
        if (whereClause.length() > 0) {
            finalSql += " WHERE " + whereClause.toString();
        }
        finalSql += " ORDER BY po.order_date DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        try ( Connection conn = new DBContext().getConnection();  PreparedStatement ps = conn.prepareStatement(finalSql)) {
            int paramIndex = 1;
            for (Object p : params) {
                ps.setObject(paramIndex++, p);
            }
            ps.setInt(paramIndex++, offset);
            ps.setInt(paramIndex, limit);

            try ( ResultSet rs = ps.executeQuery()) {
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

    public int getTotalFilteredPurchaseOrders(String searchTerm, String startDate, String endDate, String status) throws SQLException {
        String baseSql = "SELECT COUNT(*) FROM purchase_orders po LEFT JOIN suppliers s ON po.supplier_id = s.supplier_id";
        StringBuilder whereClause = new StringBuilder();
        List<Object> params = new ArrayList<>();

        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            whereClause.append("(po.notes LIKE ? OR s.name LIKE ?)");
            params.add("%" + searchTerm.trim() + "%");
            params.add("%" + searchTerm.trim() + "%");
        }
        if (startDate != null && !startDate.isEmpty()) {
            if (whereClause.length() > 0) {
                whereClause.append(" AND ");
            }
            whereClause.append("po.order_date >= ?");
            params.add(startDate);
        }
        if (endDate != null && !endDate.isEmpty()) {
            if (whereClause.length() > 0) {
                whereClause.append(" AND ");
            }
            whereClause.append("po.order_date <= ?");
            params.add(endDate + " 23:59:59");
        }
        if (status != null && !status.isEmpty() && !status.equalsIgnoreCase("all")) {
            if (whereClause.length() > 0) {
                whereClause.append(" AND ");
            }
            whereClause.append("po.status = ?");
            params.add(status);
        }

        String finalSql = baseSql;
        if (whereClause.length() > 0) {
            finalSql += " WHERE " + whereClause.toString();
        }

        try ( Connection conn = new DBContext().getConnection();  PreparedStatement ps = conn.prepareStatement(finalSql)) {
            int paramIndex = 1;
            for (Object p : params) {
                ps.setObject(paramIndex++, p);
            }
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    public int deleteDraftPO(long poId) throws SQLException {
        String deleteDetailsSql = "DELETE FROM purchase_order_details WHERE purchase_order_id = ?";
        String deletePoSql = "DELETE FROM purchase_orders WHERE purchase_order_id = ? AND status = 'Draft'";
        Connection conn = null;
        int result = 0;
        try {
            conn = new DBContext().getConnection();
            conn.setAutoCommit(false); // Bắt đầu transaction

            // 1. Xóa các chi tiết trước
            try ( PreparedStatement psDetails = conn.prepareStatement(deleteDetailsSql)) {
                psDetails.setLong(1, poId);
                psDetails.executeUpdate();
            }

            // 2. Xóa PO header sau
            try ( PreparedStatement psPo = conn.prepareStatement(deletePoSql)) {
                psPo.setLong(1, poId);
                result = psPo.executeUpdate();
            }

            conn.commit(); // Hoàn tất transaction
        } catch (SQLException e) {
            if (conn != null) {
                conn.rollback(); // Hoàn tác nếu có lỗi
            }
            throw e; // Ném lỗi ra ngoài để Controller xử lý
        } finally {
            if (conn != null) {
                conn.close();
            }
        }
        return result;
    }
    public Long getStaffIdByUserId(Long userId) throws SQLException {
    String sql = "SELECT staff_id FROM staff WHERE user_id = ?";
    try (Connection conn = new DBContext().getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setLong(1, userId);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getLong("staff_id");
            }
        }
    }
    return null; // Trả null nếu user_id không có trong staff
}

}
