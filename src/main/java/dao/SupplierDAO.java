package dao;

import model.Supplier;
import util.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class SupplierDAO {

    /**
     * Lấy tất cả các nhà cung cấp từ database.
     */
    public List<Supplier> getAllSuppliers() throws SQLException {
        List<Supplier> list = new ArrayList<>();
        String sql = "SELECT * FROM suppliers ORDER BY name";
        try ( Connection conn = new DBContext().getConnection();  PreparedStatement ps = conn.prepareStatement(sql);  ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Supplier s = new Supplier();
                s.setSupplierId(rs.getLong("supplier_id"));
                s.setName(rs.getString("name"));
                s.setContactEmail(rs.getString("contact_email"));
                s.setPhoneNumber(rs.getString("phone_number"));
                s.setAddress(rs.getString("address"));
                s.setIsActive(rs.getBoolean("is_active"));
                list.add(s);
            }
        }
        return list;
    }

    /**
     * Lấy một nhà cung cấp bằng ID.
     */
    public Supplier getSupplierById(long id) throws SQLException {
        String sql = "SELECT * FROM suppliers WHERE supplier_id = ?";
        try ( Connection conn = new DBContext().getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Supplier s = new Supplier();
                    s.setSupplierId(rs.getLong("supplier_id"));
                    s.setName(rs.getString("name"));
                    s.setContactEmail(rs.getString("contact_email"));
                    s.setPhoneNumber(rs.getString("phone_number"));
                    s.setAddress(rs.getString("address"));
                    s.setIsActive(rs.getBoolean("is_active"));
                    return s;
                }
            }
        }
        return null;
    }

    /**
     * Thêm một nhà cung cấp mới.
     */
    public void addSupplier(Supplier supplier) throws SQLException {
        String sql = "INSERT INTO suppliers (name, contact_email, phone_number, address, is_active) VALUES (?, ?, ?, ?, ?)";
        try ( Connection conn = new DBContext().getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, supplier.getName());
            ps.setString(2, supplier.getContactEmail());
            ps.setString(3, supplier.getPhoneNumber());
            ps.setString(4, supplier.getAddress());
            ps.setBoolean(5, supplier.getIsActive());
            ps.executeUpdate();
        }
    }

    /**
     * Cập nhật thông tin một nhà cung cấp.
     */
    public boolean updateSupplier(Supplier supplier) throws SQLException {
        String sql = "UPDATE suppliers SET name = ?, contact_email = ?, phone_number = ?, address = ?, is_active = ? WHERE supplier_id = ?";
        try ( Connection conn = new DBContext().getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, supplier.getName());
            ps.setString(2, supplier.getContactEmail());
            ps.setString(3, supplier.getPhoneNumber());
            ps.setString(4, supplier.getAddress());
            ps.setBoolean(5, supplier.getIsActive());
            ps.setLong(6, supplier.getSupplierId());
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Xóa mềm một nhà cung cấp (chuyển is_active = 0). Đây là cách làm an toàn
     * để không ảnh hưởng đến các Purchase Order cũ.
     */
    public boolean softDeleteSupplier(long id) throws SQLException {
        String sql = "UPDATE suppliers SET is_active = 0 WHERE supplier_id = ?";
        try ( Connection conn = new DBContext().getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Lấy danh sách các Purchase Order thuộc về một nhà cung cấp.
     *
     * @param supplierId
     * @return
     * @throws java.sql.SQLException
     */
    public List<Map<String, Object>> getPurchaseOrdersBySupplierId(long supplierId) throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT purchase_order_id, notes, order_date, status FROM purchase_orders WHERE supplier_id = ? ORDER BY order_date DESC";
        try ( Connection conn = new DBContext().getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, supplierId);
            try ( ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> poData = new HashMap<>();
                    poData.put("poId", rs.getLong("purchase_order_id"));
                    poData.put("notes", rs.getString("notes"));
                    poData.put("orderDate", rs.getTimestamp("order_date"));
                    poData.put("status", rs.getString("status"));
                    list.add(poData);
                }
            }
        }
        return list;
    }

    public void setSupplierStatus(long supplierId, boolean isActive) throws SQLException {
        String sql = "UPDATE suppliers SET is_active = ? WHERE supplier_id = ?";
        try ( Connection conn = new DBContext().getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setBoolean(1, isActive);
            ps.setLong(2, supplierId);
            ps.executeUpdate();
        }
    }

    public Map<String, Object> getSupplierDashboardStats(long supplierId, String startDate, String endDate) throws SQLException {
        Map<String, Object> stats = new HashMap<>();
        String sql = "SELECT "
                + "COUNT(purchase_order_id) AS orderCount, "
                + "SUM(total_amount) AS totalValue "
                + "FROM purchase_orders "
                + "WHERE supplier_id = ? "
                + "AND status = 'Delivered' "
                + "AND (order_date >= ? AND order_date < DATEADD(day, 1, ?))";

        try ( Connection conn = new DBContext().getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, supplierId);
            ps.setString(2, startDate);
            ps.setString(3, endDate);
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    stats.put("orderCount", rs.getInt("orderCount"));
                    stats.put("totalValue", rs.getBigDecimal("totalValue"));
                }
            }
        }
        return stats;
    }

    public List<Map<String, Object>> getTopProductsBySupplier(long supplierId) throws SQLException {
        List<Map<String, Object>> productList = new ArrayList<>();
        String sql = "SELECT TOP 5 p.name, SUM(pod.quantity) as totalQuantity "
                + "FROM purchase_order_details pod "
                + "JOIN purchase_orders po ON pod.purchase_order_id = po.purchase_order_id "
                + "JOIN product_variants pv ON pod.variant_id = pv.variant_id "
                + "JOIN products p ON pv.product_id = p.product_id "
                + "WHERE po.supplier_id = ? AND po.status = 'Delivered' "
                + "GROUP BY p.name "
                + "ORDER BY totalQuantity DESC";

        try ( Connection conn = new DBContext().getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, supplierId);
            try ( ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> product = new HashMap<>();
                    product.put("name", rs.getString("name"));
                    product.put("totalQuantity", rs.getInt("totalQuantity"));
                    productList.add(product);
                }
            }
        }
        return productList;
    }
    // Lấy danh sách sản phẩm đã nhập từ một nhà cung cấp, sắp xếp theo số lượng

    public List<Map<String, Object>> getProductsSuppliedBySupplier(long supplierId, String startDate, String endDate) throws SQLException {
        List<Map<String, Object>> productList = new ArrayList<>();
        String sql = "SELECT p.name as productName, pv.sku, SUM(pod.quantity) as totalQuantity "
                + "FROM purchase_order_details pod "
                + "JOIN purchase_orders po ON pod.purchase_order_id = po.purchase_order_id "
                + "JOIN product_variants pv ON pod.variant_id = pv.variant_id "
                + "JOIN products p ON pv.product_id = p.product_id "
                + "WHERE po.supplier_id = ? "
                + "AND po.status = 'Delivered' "
                + // Chỉ tính các đơn đã nhập kho
                "AND (po.order_date >= ? AND po.order_date < DATEADD(day, 1, ?)) "
                + "GROUP BY p.name, pv.sku "
                + "ORDER BY totalQuantity DESC";

        try ( Connection conn = new DBContext().getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, supplierId);
            ps.setString(2, startDate);
            ps.setString(3, endDate);
            try ( ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> product = new HashMap<>();
                    product.put("productName", rs.getString("productName"));
                    product.put("sku", rs.getString("sku"));
                    product.put("totalQuantity", rs.getInt("totalQuantity"));
                    productList.add(product);
                }
            }
        }
        return productList;
    }
    // Thêm phương thức này vào file dao/PurchaseOrderDAO.java

public void updatePurchaseOrderTotalAmount(long poId, Connection conn) throws SQLException {
    String sql = "UPDATE po SET po.total_amount = ( " +
                 "  SELECT SUM(pod.total_price) " +
                 "  FROM purchase_order_details pod " +
                 "  WHERE pod.purchase_order_id = po.purchase_order_id " +
                 ") " +
                 "FROM purchase_orders po WHERE po.purchase_order_id = ?";
    
    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setLong(1, poId);
        ps.executeUpdate();
    }
}
public boolean isPhoneNumberExists(String phoneNumber, long currentSupplierId) throws SQLException {
    String sql = "SELECT COUNT(*) FROM suppliers WHERE phone_number = ? AND supplier_id <> ?";
    try (Connection conn = new DBContext().getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        
        ps.setString(1, phoneNumber);
        ps.setLong(2, currentSupplierId);
        
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        }
    }
    return false;
}
}
