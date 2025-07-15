package model;

import java.math.BigDecimal;

public class PurchaseOrderDetail {

    private Long purchaseOrderDetailId;
    private Long purchaseOrderId;
    private Long variantId; // <<< THAY ĐỔI TỪ productId THÀNH variantId
    private int quantity;
    private BigDecimal unitPrice;
    private BigDecimal totalPrice;

    // Getters and Setters
    public Long getPurchaseOrderDetailId() {
        return purchaseOrderDetailId;
    }

    public void setPurchaseOrderDetailId(Long id) {
        this.purchaseOrderDetailId = id;
    }

    public Long getPurchaseOrderId() {
        return purchaseOrderId;
    }

    public void setPurchaseOrderId(Long purchaseOrderId) {
        this.purchaseOrderId = purchaseOrderId;
    }

    // <<< SỬA LẠI GETTER VÀ SETTER TƯƠNG ỨNG >>>
    public Long getVariantId() {
        return variantId;
    }

    public void setVariantId(Long variantId) {
        this.variantId = variantId;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public BigDecimal getUnitPrice() {
        return unitPrice;
    }

    public void setUnitPrice(BigDecimal unitPrice) {
        this.unitPrice = unitPrice;
    }

    public BigDecimal getTotalPrice() {
        return totalPrice;
    }

    public void setTotalPrice(BigDecimal totalPrice) {
        this.totalPrice = totalPrice;
    }
}
