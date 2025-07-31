package dao;

import DTO.CombinedReportDTO;
import DTO.ProductReportDTO;
import util.DBContext;
import java.sql.*;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class ReportDAO {

    /**
     * Phương thức tổng hợp, gọi tất cả các phương thức con để lấy dữ liệu cho dashboard.
     */
    public CombinedReportDTO getCombinedReportData(String startDate, String endDate, String reportType, String productSortBy, String productSortOrder, String orderSortBy, String orderSortOrder) throws SQLException {
        CombinedReportDTO combinedData = new CombinedReportDTO();
        
        if ("revenue".equals(reportType)) {
            combinedData.setProductKpis(getRevenueKpis(startDate, endDate));
        } else { // "bestselling"
            combinedData.setProductKpis(getBestSellingKpis(startDate, endDate));
        }
        
        combinedData.setProductReportData(getProductReport(startDate, endDate, 0, productSortBy, productSortOrder));
        combinedData.setSystemKpis(getSystemRevenueKpis(startDate, endDate));
        combinedData.setSystemRevenueChartData(getRevenueOverTime(startDate, endDate, "day"));
        combinedData.setOrdersReportData(getOrdersReport(startDate, endDate, orderSortBy, orderSortOrder));

        return combinedData;
    }
    
    /**
     * Lấy danh sách sản phẩm đầy đủ, có sắp xếp và lọc.
     */
    public List<ProductReportDTO> getProductReport(String startDate, String endDate, long categoryId, String sortBy, String sortOrder) throws SQLException {
        List<ProductReportDTO> reportList = new ArrayList<>();
        String orderByClause = "quantity".equalsIgnoreCase(sortBy) ? "TotalQuantitySold" : "TotalRevenue";
        String orderDirection = "ASC".equalsIgnoreCase(sortOrder) ? "ASC" : "DESC";

        String sql = "SELECT p.name AS ProductName, c.name AS CategoryName, SUM(oi.quantity) AS TotalQuantitySold, SUM(oi.total_price) AS TotalRevenue FROM dbo.order_items oi JOIN dbo.orders o ON oi.order_id = o.order_id JOIN dbo.product_variants pv ON oi.variant_id = pv.variant_id JOIN dbo.products p ON pv.product_id = p.product_id JOIN dbo.categories c ON p.category_id = c.category_id WHERE o.status = 'Delivered' AND o.order_date BETWEEN ? AND DATEADD(day, 1, ?) " +
                     (categoryId > 0 ? "AND p.category_id = ? " : "") +
                     "GROUP BY p.name, c.name ORDER BY " + orderByClause + " " + orderDirection;

        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            int paramIndex = 1;
            ps.setString(paramIndex++, startDate);
            ps.setString(paramIndex++, endDate);
            if (categoryId > 0) ps.setLong(paramIndex, categoryId);
            
            try(ResultSet rs = ps.executeQuery()) {
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

    /**
     * Lấy các chỉ số KPI cho báo cáo doanh thu theo sản phẩm.
     */
    public Map<String, Object> getRevenueKpis(String startDate, String endDate) throws SQLException {
        Map<String, Object> kpis = new HashMap<>();
        String sql = "SELECT ISNULL(SUM(oi.total_price), 0) AS TotalRevenue, COUNT(DISTINCT p.product_id) AS UniqueProductsSold FROM dbo.order_items oi JOIN dbo.orders o ON oi.order_id = o.order_id JOIN dbo.product_variants pv ON oi.variant_id = pv.variant_id JOIN dbo.products p ON pv.product_id = p.product_id WHERE o.status = 'Delivered' AND o.order_date BETWEEN ? AND DATEADD(day, 1, ?);";
        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, startDate);
            ps.setString(2, endDate);
            try(ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    kpis.put("totalRevenue", rs.getBigDecimal("TotalRevenue"));
                    kpis.put("uniqueProductsSold", rs.getInt("UniqueProductsSold"));
                }
            }
        }
        return kpis;
    }

    /**
     * Lấy các chỉ số KPI cho báo cáo sản phẩm bán chạy.
     */
    public Map<String, Object> getBestSellingKpis(String startDate, String endDate) throws SQLException {
        Map<String, Object> kpis = new HashMap<>();
        String sql = "SELECT ISNULL(SUM(oi.quantity), 0) AS TotalQuantitySold, ISNULL(SUM(oi.total_price), 0) AS TotalRevenue FROM dbo.order_items oi JOIN dbo.orders o ON oi.order_id = o.order_id WHERE o.status = 'Delivered' AND o.order_date BETWEEN ? AND DATEADD(day, 1, ?);";
        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, startDate);
            ps.setString(2, endDate);
            try(ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    kpis.put("totalQuantitySold", rs.getInt("TotalQuantitySold"));
                    kpis.put("totalRevenue", rs.getBigDecimal("TotalRevenue"));
                }
            }
        }
        return kpis;
    }

    /**
     * Lấy các chỉ số KPI cho toàn hệ thống.
     */
    public Map<String, Object> getSystemRevenueKpis(String startDate, String endDate) throws SQLException {
        Map<String, Object> kpis = new HashMap<>();
        String sql = "SELECT ISNULL(SUM(total_price), 0) AS totalRevenue, COUNT(order_id) AS totalOrders, ISNULL(AVG(total_price), 0) AS averageOrderValue FROM dbo.orders WHERE status = 'Delivered' AND order_date BETWEEN ? AND DATEADD(day, 1, ?);";
        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, startDate);
            ps.setString(2, endDate);
            try(ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    kpis.put("totalRevenue", rs.getBigDecimal("totalRevenue"));
                    kpis.put("totalOrders", rs.getInt("totalOrders"));
                    kpis.put("averageOrderValue", rs.getBigDecimal("averageOrderValue"));
                }
            }
        }
        return kpis;
    }

    /**
     * Lấy dữ liệu doanh thu theo thời gian cho biểu đồ.
     */
    public Map<String, BigDecimal> getRevenueOverTime(String startDate, String endDate, String groupBy) throws SQLException {
        Map<String, BigDecimal> revenueData = new LinkedHashMap<>();
        String dateGroupClause = "CONVERT(date, o.order_date)";
        if ("month".equals(groupBy)) {
            dateGroupClause = "FORMAT(o.order_date, 'yyyy-MM')";
        } else if ("year".equals(groupBy)) {
            dateGroupClause = "YEAR(o.order_date)";
        }
        String sql = "SELECT " + dateGroupClause + " AS TimeGroup, SUM(o.total_price) AS TotalRevenue FROM dbo.orders o WHERE o.status = 'Delivered' AND o.order_date BETWEEN ? AND DATEADD(day, 1, ?) GROUP BY " + dateGroupClause + " ORDER BY TimeGroup ASC;";
        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, startDate);
            ps.setString(2, endDate);
            try(ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    revenueData.put(rs.getString("TimeGroup"), rs.getBigDecimal("TotalRevenue"));
                }
            }
        }
        return revenueData;
    }
    
    /**
     * Lấy danh sách chi tiết các đơn hàng, có sắp xếp.
     */
    public List<Map<String, Object>> getOrdersReport(String startDate, String endDate, String sortBy, String sortOrder) throws SQLException {
        List<Map<String, Object>> orders = new ArrayList<>();
        String orderByClause = "total".equalsIgnoreCase(sortBy) ? "o.total_price" : "o.order_date";
        String orderDirection = "ASC".equalsIgnoreCase(sortOrder) ? "ASC" : "DESC";

        String sql = "SELECT o.order_id, u.full_name, o.order_date, o.total_price, (SELECT COUNT(*) FROM dbo.order_items oi WHERE oi.order_id = o.order_id) as ItemCount FROM dbo.orders o JOIN dbo.customers c ON o.customer_id = c.customer_id JOIN dbo.users u ON c.user_id = u.user_id WHERE o.status = 'Delivered' AND o.order_date BETWEEN ? AND DATEADD(day, 1, ?) ORDER BY " + orderByClause + " " + orderDirection;
        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, startDate);
            ps.setString(2, endDate);
            try(ResultSet rs = ps.executeQuery()) {
                while(rs.next()){
                    Map<String, Object> order = new HashMap<>();
                    order.put("orderId", rs.getLong("order_id"));
                    order.put("customerName", rs.getString("full_name"));
                    order.put("orderDate", rs.getTimestamp("order_date"));
                    order.put("totalPrice", rs.getBigDecimal("total_price"));
                    order.put("itemCount", rs.getInt("ItemCount"));
                    orders.add(order);
                }
            }
        }
        return orders;
    }
}