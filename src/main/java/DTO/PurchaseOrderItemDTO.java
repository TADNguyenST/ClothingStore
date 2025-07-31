package DTO;

import java.math.BigDecimal;

public class PurchaseOrderItemDTO {
    private long podId;
    private long variantId;
    private String productName;
    private String sku;
    private String size;
    private String color;
    private int quantity;
    private BigDecimal unitPrice;
    private BigDecimal totalPrice;

    // --- Getters and Setters ---
    public long getPodId() { return podId; }
    public void setPodId(long podId) { this.podId = podId; }
    public long getVariantId() { return variantId; }
    public void setVariantId(long variantId) { this.variantId = variantId; }
    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }
    public String getSku() { return sku; }
    public void setSku(String sku) { this.sku = sku; }
    public String getSize() { return size; }
    public void setSize(String size) { this.size = size; }
    public String getColor() { return color; }
    public void setColor(String color) { this.color = color; }
    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }
    public BigDecimal getUnitPrice() { return unitPrice; }
    public void setUnitPrice(BigDecimal unitPrice) { this.unitPrice = unitPrice; }
    public BigDecimal getTotalPrice() { return totalPrice; }
    public void setTotalPrice(BigDecimal totalPrice) { this.totalPrice = totalPrice; }
}