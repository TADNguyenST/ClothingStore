package dao;

import DTO.CombinedReportDTO;
import DTO.ProductReportDTO;
import DTO.CustomerSummaryDTO;
import DTO.CustomerOrderDTO;
import DTO.CustomerOrderItemDTO;
import util.DBContext;
import java.sql.*;
import java.math.BigDecimal;
import java.util.*;

public class ReportDAO {

    /** Gói dữ liệu cho dashboard */
    public CombinedReportDTO getCombinedReportData(
            String startDate, String endDate, String reportType,
            String productSortBy, String productSortOrder,
            String orderSortBy, String orderSortOrder) throws SQLException {

        CombinedReportDTO combinedData = new CombinedReportDTO();

        if ("revenue".equalsIgnoreCase(reportType)) {
            combinedData.setProductKpis(getRevenueKpis(startDate, endDate));
        } else { // bestselling
            combinedData.setProductKpis(getBestSellingKpis(startDate, endDate));
        }

        combinedData.setProductReportData(getProductReport(startDate, endDate, 0, productSortBy, productSortOrder));
        combinedData.setSystemKpis(getSystemRevenueKpis(startDate, endDate));
        // Nhóm theo ngày (đủ dùng cho YTD); tránh FORMAT() để nhanh hơn
        combinedData.setSystemRevenueChartData(getRevenueOverTime(startDate, endDate, "day"));
        combinedData.setOrdersReportData(getOrdersReport(startDate, endDate, orderSortBy, orderSortOrder));
        combinedData.setCustomerSummary(getCustomerSummary(startDate, endDate));

        return combinedData;
    }

    /** Danh sách sản phẩm (lọc & sort) */
    public List<ProductReportDTO> getProductReport(String startDate, String endDate, long categoryId, String sortBy, String sortOrder) throws SQLException {
        List<ProductReportDTO> reportList = new ArrayList<>();
        String orderByClause = "quantity".equalsIgnoreCase(sortBy) ? "TotalQuantitySold" : "TotalRevenue";
        String orderDirection = "ASC".equalsIgnoreCase(sortOrder) ? "ASC" : "DESC";

        String sql =
            "SELECT p.name AS ProductName, c.name AS CategoryName,\n" +
            "       SUM(oi.quantity) AS TotalQuantitySold,\n" +
            "       SUM(oi.total_price) AS TotalRevenue\n" +
            "FROM dbo.order_items oi\n" +
            "JOIN dbo.orders o           ON oi.order_id = o.order_id\n" +
            "JOIN dbo.product_variants pv ON oi.variant_id = pv.variant_id\n" +
            "JOIN dbo.products p         ON pv.product_id = p.product_id\n" +
            "JOIN dbo.categories c       ON p.category_id = c.category_id\n" +
            "WHERE o.status = 'COMPLETED'\n" +
            "  AND o.order_date >= ? AND o.order_date < DATEADD(day, 1, ?)\n" +
            (categoryId > 0 ? "  AND p.category_id = ?\n" : "") +
            "GROUP BY p.name, c.name\n" +
            "ORDER BY " + orderByClause + " " + orderDirection;

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            int idx = 1;
            ps.setString(idx++, startDate);
            ps.setString(idx++, endDate);
            if (categoryId > 0) ps.setLong(idx, categoryId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductReportDTO item = new ProductReportDTO();
                    item.setProductName(rs.getString("ProductName"));
                    item.setCategoryName(rs.getString("CategoryName"));
                    item.setTotalQuantitySold(rs.getInt("TotalQuantitySold"));
                    item.setTotalRevenue(rs.getBigDecimal("TotalRevenue"));
                    reportList.add(item);
                }
            }
        }
        return reportList;
    }

    /** KPI cho báo cáo doanh thu theo sản phẩm */
    public Map<String, Object> getRevenueKpis(String startDate, String endDate) throws SQLException {
        Map<String, Object> kpis = new HashMap<>();
        String sql =
            "SELECT ISNULL(SUM(oi.total_price), 0) AS TotalRevenue,\n" +
            "       COUNT(DISTINCT p.product_id) AS UniqueProductsSold\n" +
            "FROM dbo.order_items oi\n" +
            "JOIN dbo.orders o            ON oi.order_id = o.order_id\n" +
            "JOIN dbo.product_variants pv ON oi.variant_id = pv.variant_id\n" +
            "JOIN dbo.products p          ON pv.product_id = p.product_id\n" +
            "WHERE o.status = 'COMPLETED'\n" +
            "  AND o.order_date >= ? AND o.order_date < DATEADD(day, 1, ?);";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, startDate);
            ps.setString(2, endDate);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    kpis.put("totalRevenue", rs.getBigDecimal("TotalRevenue"));
                    kpis.put("uniqueProductsSold", rs.getInt("UniqueProductsSold"));
                }
            }
        }
        return kpis;
    }

    /** KPI cho báo cáo bestselling */
    public Map<String, Object> getBestSellingKpis(String startDate, String endDate) throws SQLException {
        Map<String, Object> kpis = new HashMap<>();
        String sql =
            "SELECT ISNULL(SUM(oi.quantity), 0) AS TotalQuantitySold,\n" +
            "       ISNULL(SUM(oi.total_price), 0) AS TotalRevenue\n" +
            "FROM dbo.order_items oi\n" +
            "JOIN dbo.orders o ON oi.order_id = o.order_id\n" +
            "WHERE o.status = 'COMPLETED'\n" +
            "  AND o.order_date >= ? AND o.order_date < DATEADD(day, 1, ?);";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, startDate);
            ps.setString(2, endDate);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    kpis.put("totalQuantitySold", rs.getInt("TotalQuantitySold"));
                    kpis.put("totalRevenue", rs.getBigDecimal("TotalRevenue"));
                }
            }
        }
        return kpis;
    }

    /** KPI toàn hệ thống */
    public Map<String, Object> getSystemRevenueKpis(String startDate, String endDate) throws SQLException {
        Map<String, Object> kpis = new HashMap<>();
        String sql =
            "SELECT ISNULL(SUM(total_price), 0) AS totalRevenue,\n" +
            "       COUNT(order_id) AS totalOrders,\n" +
            "       ISNULL(AVG(total_price), 0) AS averageOrderValue\n" +
            "FROM dbo.orders\n" +
            "WHERE status = 'COMPLETED'\n" +
            "  AND order_date >= ? AND order_date < DATEADD(day, 1, ?);";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, startDate);
            ps.setString(2, endDate);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    kpis.put("totalRevenue", rs.getBigDecimal("totalRevenue"));
                    kpis.put("totalOrders", rs.getInt("totalOrders"));
                    kpis.put("averageOrderValue", rs.getBigDecimal("averageOrderValue"));
                }
            }
        }
        return kpis;
    }

    /** Doanh thu theo thời gian (day|month|year) — tránh FORMAT() để nhanh */
   public Map<String, BigDecimal> getRevenueOverTime(String startDate, String endDate, String groupBy) throws SQLException {
    Map<String, BigDecimal> revenueData = new LinkedHashMap<>();

    // Xác định biểu thức group/order theo mức gộp
    String selectGroup;  // nhãn hiển thị (varchar)
    String groupExpr;    // biểu thức GROUP BY
    String orderExpr;    // biểu thức ORDER BY ổn định theo thời gian

    if ("month".equalsIgnoreCase(groupBy)) {
        // YYYY-MM, order theo (YEAR, MONTH)
        selectGroup = "CAST(YEAR(o.order_date) AS VARCHAR(4)) + '-' + RIGHT('0' + CAST(MONTH(o.order_date) AS VARCHAR(2)), 2)";
        groupExpr   = "YEAR(o.order_date), MONTH(o.order_date)";
        orderExpr   = "YEAR(o.order_date), MONTH(o.order_date)";
    } else if ("year".equalsIgnoreCase(groupBy)) {
        // YYYY, order theo YEAR
        selectGroup = "CAST(YEAR(o.order_date) AS VARCHAR(4))";
        groupExpr   = "YEAR(o.order_date)";
        orderExpr   = "YEAR(o.order_date)";
    } else {
        // Mặc định: theo NGÀY (yyyy-MM-dd)
        selectGroup = "CONVERT(VARCHAR(10), CAST(o.order_date AS DATE), 120)"; // 120 => yyyy-mm-dd
        groupExpr   = "CAST(o.order_date AS DATE)";
        orderExpr   = "CAST(o.order_date AS DATE)";
    }

    String sql =
        "SELECT " + selectGroup + " AS TimeGroup, " +
        "       SUM(o.total_price) AS TotalRevenue " +
        "FROM dbo.orders o " +
        "WHERE o.status = 'COMPLETED' " +
        "  AND o.order_date BETWEEN ? AND DATEADD(day, 1, ?) " +
        "GROUP BY " + groupExpr + " " +
        "ORDER BY " + orderExpr + " ASC;";

    try (Connection conn = new DBContext().getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setString(1, startDate);
        ps.setString(2, endDate);
        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                revenueData.put(rs.getString("TimeGroup"), rs.getBigDecimal("TotalRevenue"));
            }
        }
    }
    return revenueData;
}


    /** Danh sách orders (giữ Timestamp để client hiển thị đúng) */
    public List<Map<String, Object>> getOrdersReport(String startDate, String endDate, String sortBy, String sortOrder) throws SQLException {
        List<Map<String, Object>> orders = new ArrayList<>();
        String orderByClause = "total".equalsIgnoreCase(sortBy) ? "o.total_price" : "o.order_date";
        String orderDirection = "ASC".equalsIgnoreCase(sortOrder) ? "ASC" : "DESC";

        String sql =
            "SELECT o.order_id, u.full_name, o.order_date, o.total_price,\n" +
            "       (SELECT COUNT(*) FROM dbo.order_items oi WHERE oi.order_id = o.order_id) AS ItemCount\n" +
            "FROM dbo.orders o\n" +
            "JOIN dbo.customers c ON o.customer_id = c.customer_id\n" +
            "JOIN dbo.users u     ON c.user_id = u.user_id\n" +
            "WHERE o.status = 'COMPLETED'\n" +
            "  AND o.order_date >= ? AND o.order_date < DATEADD(day, 1, ?)\n" +
            "ORDER BY " + orderByClause + " " + orderDirection;

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, startDate);
            ps.setString(2, endDate);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> order = new HashMap<>();
                    order.put("orderId", rs.getLong("order_id"));
                    order.put("customerName", rs.getString("full_name"));
                    order.put("orderDate", rs.getTimestamp("order_date")); // giữ Timestamp
                    order.put("totalPrice", rs.getBigDecimal("total_price"));
                    order.put("itemCount", rs.getInt("ItemCount"));
                    orders.add(order);
                }
            }
        }
        return orders;
    }

    // ============================
    // =     CUSTOMER DRILLDOWN   =
    // ============================

    /** 1) Tổng hợp theo khách hàng: totalOrders, totalRevenue */
   public List<CustomerSummaryDTO> getCustomerSummary(String startDate, String endDate) throws SQLException {
    List<CustomerSummaryDTO> list = new ArrayList<>();
    String sql =
      "SELECT c.customer_id, u.full_name AS customer_name, " +
      "       COUNT(o.order_id) AS total_orders, " +
      "       ISNULL(SUM(o.total_price),0) AS total_revenue " +
      "FROM dbo.orders o " +
      "JOIN dbo.customers c ON o.customer_id=c.customer_id " +
      "JOIN dbo.users u ON c.user_id=u.user_id " +
      "WHERE o.status='COMPLETED' AND o.order_date BETWEEN ? AND DATEADD(day,1,?) " +
      "GROUP BY c.customer_id, u.full_name " +
      "ORDER BY total_revenue DESC";
    try (Connection conn = new DBContext().getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setString(1, startDate);
        ps.setString(2, endDate);
        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                CustomerSummaryDTO dto = new CustomerSummaryDTO();
                dto.setCustomerId(rs.getLong("customer_id"));
                dto.setCustomerName(rs.getString("customer_name"));
                dto.setTotalOrders(rs.getInt("total_orders"));
                dto.setTotalRevenue(rs.getBigDecimal("total_revenue"));
                list.add(dto);
            }
        }
    }
    return list;
}

// 2. Đơn hàng theo khách (khi expand)
public List<CustomerOrderDTO> getOrdersByCustomer(String startDate, String endDate, long customerId) throws SQLException {
    List<CustomerOrderDTO> list = new ArrayList<>();
    String sql =
      "SELECT o.order_id, o.order_date, o.total_price, " +
      " (SELECT COUNT(*) FROM dbo.order_items oi WHERE oi.order_id=o.order_id) AS item_count " +
      "FROM dbo.orders o " +
      "WHERE o.status='COMPLETED' AND o.customer_id=? " +
      "  AND o.order_date BETWEEN ? AND DATEADD(day,1,?) " +
      "ORDER BY o.total_price DESC";
    try (Connection conn = new DBContext().getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setLong(1, customerId);
        ps.setString(2, startDate);
        ps.setString(3, endDate);
        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                CustomerOrderDTO dto = new CustomerOrderDTO();
                dto.setOrderId(rs.getLong("order_id"));
                dto.setOrderDate(rs.getTimestamp("order_date"));
                dto.setTotalPrice(rs.getBigDecimal("total_price"));
                dto.setItemCount(rs.getInt("item_count"));
                list.add(dto);
            }
        }
    }
    return list;
}

// 3. Items của 1 order (expand cấp 2)
public List<CustomerOrderItemDTO> getOrderItems(long orderId) throws SQLException {
    List<CustomerOrderItemDTO> list = new ArrayList<>();
    String sql =
      "SELECT p.name AS product_name, pv.sku, oi.quantity, " +
      "       oi.price_at_purchase AS unit_price, oi.total_price " +
      "FROM dbo.order_items oi " +
      "JOIN dbo.product_variants pv ON oi.variant_id=pv.variant_id " +
      "JOIN dbo.products p ON pv.product_id=p.product_id " +
      "WHERE oi.order_id=? ORDER BY oi.order_item_id";
    try (Connection conn = new DBContext().getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setLong(1, orderId);
        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                CustomerOrderItemDTO dto = new CustomerOrderItemDTO();
                dto.setProductName(rs.getString("product_name"));
                dto.setSku(rs.getString("sku"));
                dto.setQuantity(rs.getInt("quantity"));
                dto.setUnitPrice(rs.getBigDecimal("unit_price"));
                dto.setTotalPrice(rs.getBigDecimal("total_price"));
                list.add(dto);
            }
        }
    }
    return list;
}
}
