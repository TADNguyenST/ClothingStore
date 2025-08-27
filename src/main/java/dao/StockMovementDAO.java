package dao;

import java.sql.*;
import java.util.*;
import util.DBContext;

public class StockMovementDAO extends DBContext {

    /* -------------------------------------------------
     *  HÀM DÙNG CHUNG: build where
     * ------------------------------------------------- */
    private void buildWhereClause(StringBuilder whereClause, List<Object> params,
                                  String startDate, String endDate,
                                  String filterType, String searchTerm) {

        if (startDate != null && !startDate.isEmpty()) {
            if (whereClause.length() > 0) whereClause.append(" AND ");
            whereClause.append("sm.created_at >= ?");
            params.add(startDate);
        }
        if (endDate != null && !endDate.isEmpty()) {
            if (whereClause.length() > 0) whereClause.append(" AND ");
            // < endDate + 1 day
            whereClause.append("sm.created_at < DATEADD(day, 1, ?)");
            params.add(endDate);
        }
        // filterType: có thể để null (vì đã bỏ UI)
        if (filterType != null && !filterType.isEmpty() && !"all".equalsIgnoreCase(filterType)) {
            if (whereClause.length() > 0) whereClause.append(" AND ");
            whereClause.append("sm.movement_type = ?");
            params.add(filterType);
        }
        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            if (whereClause.length() > 0) whereClause.append(" AND ");
            whereClause.append("(p.name LIKE ? OR pv.sku LIKE ?)");
            String like = "%" + searchTerm.trim() + "%";
            params.add(like);
            params.add(like);
        }
    }

    /* -------------------------------------------------
     *  LIST PHẲNG (không group)
     * ------------------------------------------------- */
    public List<Map<String, Object>> getFilteredAndPaginatedStockMovements(
            String startDate, String endDate, String filterType, String searchTerm,
            int offset, int limit) throws SQLException {

        List<Map<String, Object>> list = new ArrayList<>();

        String baseSql =
            "SELECT sm.movement_id, sm.created_at, p.name AS productName, pv.size, pv.color, pv.sku, " +
            "       sm.movement_type, sm.quantity_changed, sm.notes, sm.variant_id, " +
            "       u.full_name AS staffName " +
            "FROM stock_movements sm " +
            "JOIN product_variants pv ON sm.variant_id = pv.variant_id " +
            "JOIN products p ON pv.product_id = p.product_id " +
            "LEFT JOIN staff s ON sm.created_by = s.staff_id " +
            "LEFT JOIN users u ON s.user_id = u.user_id";

        StringBuilder where = new StringBuilder();
        List<Object> params = new ArrayList<>();
        buildWhereClause(where, params, startDate, endDate, filterType, searchTerm);

        String finalSql = baseSql + (where.length() > 0 ? " WHERE " + where : "")
                + " ORDER BY sm.created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(finalSql)) {

            int idx = 1;
            for (Object p : params) ps.setObject(idx++, p);
            ps.setInt(idx++, offset);
            ps.setInt(idx,   limit);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> m = new HashMap<>();
                    Timestamp ts = rs.getTimestamp("created_at");
                    m.put("createdAtFormatted", ts != null ? new java.text.SimpleDateFormat("HH:mm:ss dd/MM/yyyy").format(ts) : "N/A");
                    m.put("productName", rs.getString("productName"));
                    m.put("size", rs.getString("size"));
                    m.put("color", rs.getString("color"));
                    m.put("sku", rs.getString("sku"));
                    m.put("movementType", rs.getString("movement_type"));
                    m.put("quantityChanged", rs.getInt("quantity_changed"));
                    m.put("notes", rs.getString("notes"));
                    m.put("variantId", rs.getLong("variant_id"));
                    m.put("staffName", rs.getString("staffName"));
                    list.add(m);
                }
            }
        }
        return list;
    }

    public int getTotalFilteredStockMovements(String startDate, String endDate,
                                              String filterType, String searchTerm) throws SQLException {
        String baseSql =
            "SELECT COUNT(DISTINCT sm.movement_id) " +
            "FROM stock_movements sm " +
            "JOIN product_variants pv ON sm.variant_id = pv.variant_id " +
            "JOIN products p ON pv.product_id = p.product_id";

        StringBuilder where = new StringBuilder();
        List<Object> params = new ArrayList<>();
        buildWhereClause(where, params, startDate, endDate, filterType, searchTerm);

        String finalSql = baseSql + (where.length() > 0 ? " WHERE " + where : "");

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(finalSql)) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    /* -------------------------------------------------
     *  GROUPED (purchase_order / sale_order / adjustment)
     * ------------------------------------------------- */
    public Map<String, List<Map<String, Object>>> getGroupedMovements(
            String startDate, String endDate, String filterType, String searchTerm, String groupBy) throws SQLException {

        // Xác định join/where theo groupBy
        String groupColumn, joins = "", addWhere;
        if (groupBy == null) groupBy = "purchase_order";

        switch (groupBy) {
            case "sale_order":
                groupColumn = "CAST(ISNULL(so.notes, CONCAT('Sale Order #', sm.reference_id)) AS NVARCHAR(4000))";
                joins = " LEFT JOIN orders so ON sm.reference_id = so.order_id AND sm.reference_type = 'Sale Order' ";
                addWhere = "sm.reference_type = 'Sale Order'";
                break;
            case "adjustment":
                groupColumn = "'Manual Adjustment'";
                addWhere = "sm.reference_type = 'Adjustment'";
                break;
            case "purchase_order":
            default:
                groupColumn = "CAST(ISNULL(po.notes, CONCAT('Purchase Order #', po.purchase_order_id)) AS NVARCHAR(4000))";
                joins = " LEFT JOIN purchase_orders po ON sm.reference_id = po.purchase_order_id AND sm.reference_type = 'Purchase Order' ";
                addWhere = "sm.reference_type = 'Purchase Order'";
                break;
        }

        String sql =
            "SELECT " + groupColumn + " AS group_key, sm.created_at, p.name AS productName, pv.size, pv.color, pv.sku, sm.quantity_changed " +
            "FROM stock_movements sm " +
            "JOIN product_variants pv ON sm.variant_id = pv.variant_id " +
            "JOIN products p ON pv.product_id = p.product_id " +
            joins;

        StringBuilder where = new StringBuilder(addWhere);
        List<Object> params = new ArrayList<>();
        buildWhereClause(where, params, startDate, endDate, filterType, searchTerm);

        if (where.length() > 0) sql += " WHERE " + where;
        sql += " ORDER BY sm.created_at DESC";

        // Gom nhóm trong Java và sort nhóm theo latest timestamp
        class Bucket { List<Map<String, Object>> items = new ArrayList<>(); long latest = Long.MIN_VALUE; }
        Map<String, Bucket> temp = new HashMap<>();

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String key = rs.getString("group_key");
                    Bucket b = temp.computeIfAbsent(key, k -> new Bucket());

                    Timestamp ts = rs.getTimestamp("created_at");
                    long epoch = (ts != null) ? ts.getTime() : 0L;

                    Map<String, Object> m = new HashMap<>();
                    m.put("createdAtFormatted", ts != null ? new java.text.SimpleDateFormat("HH:mm:ss dd/MM/yyyy").format(ts) : "N/A");
                    m.put("productName", rs.getString("productName"));
                    m.put("sku", rs.getString("sku"));
                    m.put("size", rs.getString("size"));
                    m.put("color", rs.getString("color"));
                    m.put("quantityChanged", rs.getInt("quantity_changed"));
                    b.items.add(m);
                    if (epoch > b.latest) b.latest = epoch;
                }
            }
        }

        List<Map.Entry<String, Bucket>> arr = new ArrayList<>(temp.entrySet());
        arr.sort((a, b) -> Long.compare(b.getValue().latest, a.getValue().latest));

        LinkedHashMap<String, List<Map<String, Object>>> result = new LinkedHashMap<>();
        for (Map.Entry<String, Bucket> e : arr) result.put(e.getKey(), e.getValue().items);
        return result;
    }

    /* -------------------------------------------------
     *  BY PRODUCT (summary In/Out/Net + totals)
     * ------------------------------------------------- */
    public Map<String, Object> getProductMovementSummary(String startDate, String endDate, String searchTerm) throws SQLException {
        String sql =
            "SELECT p.name AS productName, pv.sku, pv.size, pv.color, " +
            "SUM(CASE WHEN sm.quantity_changed > 0 THEN sm.quantity_changed ELSE 0 END) AS inQty, " +
            "SUM(CASE WHEN sm.quantity_changed < 0 THEN -sm.quantity_changed ELSE 0 END) AS outQty, " +
            "SUM(sm.quantity_changed) AS netQty " +
            "FROM stock_movements sm " +
            "JOIN product_variants pv ON sm.variant_id = pv.variant_id " +
            "JOIN products p ON pv.product_id = p.product_id ";

        StringBuilder where = new StringBuilder(" WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (startDate != null && !startDate.isEmpty()) {
            where.append(" AND sm.created_at >= ? ");
            params.add(startDate);
        }
        if (endDate != null && !endDate.isEmpty()) {
            where.append(" AND sm.created_at < DATEADD(day, 1, ?) ");
            params.add(endDate);
        }
        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            where.append(" AND (p.name LIKE ? OR pv.sku LIKE ?) ");
            String like = "%" + searchTerm.trim() + "%";
            params.add(like); params.add(like);
        }

        String groupOrder = " GROUP BY p.name, pv.sku, pv.size, pv.color " +
                            " ORDER BY p.name ASC, pv.sku ASC";

        List<Map<String, Object>> rows = new ArrayList<>();
        long totalIn = 0, totalOut = 0, net = 0;

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql + where + groupOrder)) {
            int idx = 1; for (Object o : params) ps.setObject(idx++, o);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> r = new HashMap<>();
                    int in  = rs.getInt("inQty");
                    int out = rs.getInt("outQty");
                    int n   = rs.getInt("netQty");
                    r.put("productName", rs.getString("productName"));
                    r.put("sku",         rs.getString("sku"));
                    r.put("size",        rs.getString("size"));
                    r.put("color",       rs.getString("color"));
                    r.put("inQty",  in);
                    r.put("outQty", out);
                    r.put("netQty", n);
                    rows.add(r);
                    totalIn  += in;
                    totalOut += out;
                    net      += n;
                }
            }
        }

        Map<String, Object> result = new HashMap<>();
        result.put("rows", rows);
        result.put("totalIn", totalIn);
        result.put("totalOut", totalOut);
        result.put("net", net);
        return result;
    }
}
