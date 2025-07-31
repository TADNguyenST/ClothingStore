package DTO;

import java.math.BigDecimal;

public class ProductReportDTO {
    // Thông tin cơ bản
    private String productName;
    private int totalQuantitySold;
    private BigDecimal totalRevenue;

    // Thêm trường mới
    private String categoryName;

    // Constructors (nếu cần)
    public ProductReportDTO() {
    }

    // Getters and Setters
    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public int getTotalQuantitySold() {
        return totalQuantitySold;
    }

    public void setTotalQuantitySold(int totalQuantitySold) {
        this.totalQuantitySold = totalQuantitySold;
    }

    public BigDecimal getTotalRevenue() {
        return totalRevenue;
    }

    public void setTotalRevenue(BigDecimal totalRevenue) {
        this.totalRevenue = totalRevenue;
    }

    // Thêm getter và setter cho categoryName
    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }
}