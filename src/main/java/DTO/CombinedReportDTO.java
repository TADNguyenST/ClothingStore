package DTO;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

public class CombinedReportDTO {

    private Map<String, Object> productKpis;
    private List<ProductReportDTO> productReportData;
    private Map<String, Object> systemKpis;
    private Map<String, BigDecimal> systemRevenueChartData;
    private List<Map<String, Object>> ordersReportData;
    private List<CustomerSummaryDTO> customerSummary;

    public List<CustomerSummaryDTO> getCustomerSummary() {
        return customerSummary;
    }

    public void setCustomerSummary(List<CustomerSummaryDTO> customerSummary) {
        this.customerSummary = customerSummary;
    }

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
