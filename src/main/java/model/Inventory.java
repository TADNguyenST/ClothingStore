package model;

import java.io.Serializable;
import java.time.LocalDateTime;

public class Inventory implements Serializable {
    private static final long serialVersionUID = 1L;
    private Long inventoryId;
    private Long variantId; // Unique FK
    private Integer quantity;
    private Integer reservedQuantity;
    private LocalDateTime lastUpdated;

    public Inventory() {}

    public Inventory(Long inventoryId, Long variantId, Integer quantity, Integer reservedQuantity, LocalDateTime lastUpdated) {
        this.inventoryId = inventoryId;
        this.variantId = variantId;
        this.quantity = quantity;
        this.reservedQuantity = reservedQuantity;
        this.lastUpdated = lastUpdated;
    }

    // Getters and Setters
    public Long getInventoryId() { return inventoryId; }
    public void setInventoryId(Long inventoryId) { this.inventoryId = inventoryId; }
    public Long getVariantId() { return variantId; }
    public void setVariantId(Long variantId) { this.variantId = variantId; }
    public Integer getQuantity() { return quantity; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }
    public Integer getReservedQuantity() { return reservedQuantity; }
    public void setReservedQuantity(Integer reservedQuantity) { this.reservedQuantity = reservedQuantity; }
    public LocalDateTime getLastUpdated() { return lastUpdated; }
    public void setLastUpdated(LocalDateTime lastUpdated) { this.lastUpdated = lastUpdated; }

    @Override
    public String toString() {
        return "Inventory{" +
               "inventoryId=" + inventoryId +
               ", variantId=" + variantId +
               ", quantity=" + quantity +
               '}';
    }
}