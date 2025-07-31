package DTO;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

// DTO này chứa tất cả dữ liệu cần thiết cho trang báo cáo tổng hợp
public class CombinedReportDTO {
    // Dữ liệu cho báo cáo hiệu suất sản phẩm
    private Map<String, Object> productKpis;
    private List<ProductReportDTO> productReportData;

    // Dữ liệu cho báo cáo doanh thu hệ thống
    private Map<String, Object> systemKpis;
    private Map<String, BigDecimal> systemRevenueChartData;
    
    // Dữ liệu cho bảng danh sách đơn hàng
    private List<Map<String, Object>> ordersReportData;


    // Getters and Setters
    public Map<String, Object> getProductKpis() {
        return productKpis;
    }

    public void setProductKpis(Map<String, Object> productKpis) {
        this.productKpis = productKpis;
    }

    public List<ProductReportDTO> getProductReportData() {
        return productReportData;
    }

    public void setProductReportData(List<ProductReportDTO> productReportData) {
        this.productReportData = productReportData;
    }

    public Map<String, Object> getSystemKpis() {
        return systemKpis;
    }

    public void setSystemKpis(Map<String, Object> systemKpis) {
        this.systemKpis = systemKpis;
    }

    public Map<String, BigDecimal> getSystemRevenueChartData() {
        return systemRevenueChartData;
    }

    public void setSystemRevenueChartData(Map<String, BigDecimal> systemRevenueChartData) {
        this.systemRevenueChartData = systemRevenueChartData;
    }

    public List<Map<String, Object>> getOrdersReportData() {
        return ordersReportData;
    }

    public void setOrdersReportData(List<Map<String, Object>> ordersReportData) {
        this.ordersReportData = ordersReportData;
    }
}