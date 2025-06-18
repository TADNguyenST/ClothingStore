package model;

import java.time.LocalDateTime;

public class ProductViewHistory {
    private Long viewId;
    private Long customerId;
    private Long productId;
    private LocalDateTime viewDate;

    // Constructors
    public ProductViewHistory() {
    }

    // Getters and Setters
    public Long getViewId() {
        return viewId;
    }

    public void setViewId(Long viewId) {
        this.viewId = viewId;
    }

    public Long getCustomerId() {
        return customerId;
    }

    public void setCustomerId(Long customerId) {
        this.customerId = customerId;
    }

    public Long getProductId() {
        return productId;
    }

    public void setProductId(Long productId) {
        this.productId = productId;
    }

    public LocalDateTime getViewDate() {
        return viewDate;
    }

    public void setViewDate(LocalDateTime viewDate) {
        this.viewDate = viewDate;
    }
}