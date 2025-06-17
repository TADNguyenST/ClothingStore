package model;

import java.io.Serializable;
import java.math.BigDecimal;

public class PurchaseOrderDetail implements Serializable {
    private static final long serialVersionUID = 1L;
    private Long purchaseOrderDetailId;
    private Long purchaseOrderId; // FK
    private Long productId; // FK
    private Integer quantity;
    private BigDecimal unitPrice;
    private BigDecimal totalPrice;
    private Integer receivedQuantity;

    public PurchaseOrderDetail() {}

    public PurchaseOrderDetail(Long purchaseOrderDetailId, Long purchaseOrderId, Long productId, Integer quantity, BigDecimal unitPrice, BigDecimal totalPrice, Integer receivedQuantity) {
        this.purchaseOrderDetailId = purchaseOrderDetailId;
        this.purchaseOrderId = purchaseOrderId;
        this.productId = productId;
        this.quantity = quantity;
        this.unitPrice = unitPrice;
        this.totalPrice = totalPrice;
        this.receivedQuantity = receivedQuantity;
    }

    // Getters and Setters
    public Long getPurchaseOrderDetailId() { return purchaseOrderDetailId; }
    public void setPurchaseOrderDetailId(Long purchaseOrderDetailId) { this.purchaseOrderDetailId = purchaseOrderDetailId; }
    public Long getPurchaseOrderId() { return purchaseOrderId; }
    public void setPurchaseOrderId(Long purchaseOrderId) { this.purchaseOrderId = purchaseOrderId; }
    public Long getProductId() { return productId; }
    public void setProductId(Long productId) { this.productId = productId; }
    public Integer getQuantity() { return quantity; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }
    public BigDecimal getUnitPrice() { return unitPrice; }
    public void setUnitPrice(BigDecimal unitPrice) { this.unitPrice = unitPrice; }
    public BigDecimal getTotalPrice() { return totalPrice; }
    public void setTotalPrice(BigDecimal totalPrice) { this.totalPrice = totalPrice; }
    public Integer getReceivedQuantity() { return receivedQuantity; }
    public void setReceivedQuantity(Integer receivedQuantity) { this.receivedQuantity = receivedQuantity; }

    @Override
    public String toString() {
        return "PurchaseOrderDetail{" +
               "purchaseOrderDetailId=" + purchaseOrderDetailId +
               ", purchaseOrderId=" + purchaseOrderId +
               ", productId=" + productId +
               ", quantity=" + quantity +
               '}';
    }
}