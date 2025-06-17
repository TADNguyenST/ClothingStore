package model;

import java.io.Serializable;
import java.time.LocalDateTime;

public class ProductViewHistory implements Serializable {
    private static final long serialVersionUID = 1L;
    private Long viewId;
    private Long customerId; // FK
    private Long productId; // FK
    private LocalDateTime viewDate;

    public ProductViewHistory() {}

    public ProductViewHistory(Long viewId, Long customerId, Long productId, LocalDateTime viewDate) {
        this.viewId = viewId;
        this.customerId = customerId;
        this.productId = productId;
        this.viewDate = viewDate;
    }

    // Getters and Setters
    public Long getViewId() { return viewId; }
    public void setViewId(Long viewId) { this.viewId = viewId; }
    public Long getCustomerId() { return customerId; }
    public void setCustomerId(Long customerId) { this.customerId = customerId; }
    public Long getProductId() { return productId; }
    public void setProductId(Long productId) { this.productId = productId; }
    public LocalDateTime getViewDate() { return viewDate; }
    public void setViewDate(LocalDateTime viewDate) { this.viewDate = viewDate; }

    @Override
    public String toString() {
        return "ProductViewHistory{" +
               "viewId=" + viewId +
               ", customerId=" + customerId +
               ", productId=" + productId +
               '}';
    }
}