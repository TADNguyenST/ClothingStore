package model;

import java.io.Serializable;
import java.time.LocalDateTime;

public class CartItem implements Serializable {
    private static final long serialVersionUID = 1L;
    private Long cartItemId;
    private Long customerId; // FK
    private Long variantId; // FK
    private Integer quantity;
    private LocalDateTime dateAdded;

    public CartItem() {}

    public CartItem(Long cartItemId, Long customerId, Long variantId, Integer quantity, LocalDateTime dateAdded) {
        this.cartItemId = cartItemId;
        this.customerId = customerId;
        this.variantId = variantId;
        this.quantity = quantity;
        this.dateAdded = dateAdded;
    }

    // Getters and Setters
    public Long getCartItemId() { return cartItemId; }
    public void setCartItemId(Long cartItemId) { this.cartItemId = cartItemId; }
    public Long getCustomerId() { return customerId; }
    public void setCustomerId(Long customerId) { this.customerId = customerId; }
    public Long getVariantId() { return variantId; }
    public void setVariantId(Long variantId) { this.variantId = variantId; }
    public Integer getQuantity() { return quantity; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }
    public LocalDateTime getDateAdded() { return dateAdded; }
    public void setDateAdded(LocalDateTime dateAdded) { this.dateAdded = dateAdded; }

    @Override
    public String toString() {
        return "CartItem{" +
               "cartItemId=" + cartItemId +
               ", customerId=" + customerId +
               ", variantId=" + variantId +
               ", quantity=" + quantity +
               '}';
    }
}