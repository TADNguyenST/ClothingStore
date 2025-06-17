package model;

import java.io.Serializable;
import java.math.BigDecimal;

public class OrderItem implements Serializable {
    private static final long serialVersionUID = 1L;
    private Long orderItemId;
    private Long orderId; // FK
    private Long variantId; // FK
    private Integer quantity;
    private BigDecimal priceAtPurchase;
    private BigDecimal discountAmount;
    private BigDecimal totalPrice;

    public OrderItem() {}

    public OrderItem(Long orderItemId, Long orderId, Long variantId, Integer quantity, BigDecimal priceAtPurchase, BigDecimal discountAmount, BigDecimal totalPrice) {
        this.orderItemId = orderItemId;
        this.orderId = orderId;
        this.variantId = variantId;
        this.quantity = quantity;
        this.priceAtPurchase = priceAtPurchase;
        this.discountAmount = discountAmount;
        this.totalPrice = totalPrice;
    }

    // Getters and Setters
    public Long getOrderItemId() { return orderItemId; }
    public void setOrderItemId(Long orderItemId) { this.orderItemId = orderItemId; }
    public Long getOrderId() { return orderId; }
    public void setOrderId(Long orderId) { this.orderId = orderId; }
    public Long getVariantId() { return variantId; }
    public void setVariantId(Long variantId) { this.variantId = variantId; }
    public Integer getQuantity() { return quantity; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }
    public BigDecimal getPriceAtPurchase() { return priceAtPurchase; }
    public void setPriceAtPurchase(BigDecimal priceAtPurchase) { this.priceAtPurchase = priceAtPurchase; }
    public BigDecimal getDiscountAmount() { return discountAmount; }
    public void setDiscountAmount(BigDecimal discountAmount) { this.discountAmount = discountAmount; }
    public BigDecimal getTotalPrice() { return totalPrice; }
    public void setTotalPrice(BigDecimal totalPrice) { this.totalPrice = totalPrice; }

    @Override
    public String toString() {
        return "OrderItem{" +
               "orderItemId=" + orderItemId +
               ", orderId=" + orderId +
               ", variantId=" + variantId +
               ", quantity=" + quantity +
               '}';
    }
}