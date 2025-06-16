/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author Lenovo
 */
import java.io.Serializable;
import java.time.LocalDateTime;

public class Inventory implements Serializable {
    private static final long serialVersionUID = 1L;
    private Long inventoryId;
    private Long productId; // Foreign Key
    private Long variantId; // Foreign Key
    private Integer quantity; // Current available stock
    private Integer reservedQuantity; // Quantity held for pending orders
    private LocalDateTime lastUpdated;

    // Nested objects (for convenience)
    private Product product;
    private ProductVariant productVariant;

    // Constructor
    public Inventory() {}

    public Inventory(Long inventoryId, Long productId, Long variantId, Integer quantity, Integer reservedQuantity, LocalDateTime lastUpdated) {
        this.inventoryId = inventoryId;
        this.productId = productId;
        this.variantId = variantId;
        this.quantity = quantity;
        this.reservedQuantity = reservedQuantity;
        this.lastUpdated = lastUpdated;
    }

    // Getters and Setters
    public Long getInventoryId() { return inventoryId; }
    public void setInventoryId(Long inventoryId) { this.inventoryId = inventoryId; }
    public Long getProductId() { return productId; }
    public void setProductId(Long productId) { this.productId = productId; }
    public Long getVariantId() { return variantId; }
    public void setVariantId(Long variantId) { this.variantId = variantId; }
    public Integer getQuantity() { return quantity; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }
    public Integer getReservedQuantity() { return reservedQuantity; }
    public void setReservedQuantity(Integer reservedQuantity) { this.reservedQuantity = reservedQuantity; }
    public LocalDateTime getLastUpdated() { return lastUpdated; }
    public void setLastUpdated(LocalDateTime lastUpdated) { this.lastUpdated = lastUpdated; }

    // Nested object getters and setters
    public Product getProduct() { return product; }
    public void setProduct(Product product) { this.product = product; }
    public ProductVariant getProductVariant() { return productVariant; }
    public void setProductVariant(ProductVariant productVariant) { this.productVariant = productVariant; }

    public Integer getAvailableQuantity() {
        return (quantity != null ? quantity : 0) - (reservedQuantity != null ? reservedQuantity : 0);
    }

    @Override
    public String toString() {
        return "Inventory{" +
               "inventoryId=" + inventoryId +
               ", variantId=" + variantId +
               ", quantity=" + quantity +
               ", reservedQuantity=" + reservedQuantity +
               '}';
    }
}