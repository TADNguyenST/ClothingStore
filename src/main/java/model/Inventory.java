package model;

import com.google.gson.annotations.SerializedName;
import java.time.LocalDateTime;

public class Inventory {
    @SerializedName("inventoryId")
    private long inventoryId;

    @SerializedName("variantId")
    private long variantId;

    @SerializedName("quantity")
    private int quantity;

    @SerializedName("reservedQuantity")
    private int reservedQuantity;

    @SerializedName("lastUpdated")
    private LocalDateTime lastUpdated;

    @SerializedName("productName")
    private String productName; // For display purposes

    // Getters and Setters
    public long getInventoryId() {
        return inventoryId;
    }

    public void setInventoryId(long inventoryId) {
        this.inventoryId = inventoryId;
    }

    public long getVariantId() {
        return variantId;
    }

    public void setVariantId(long variantId) {
        this.variantId = variantId;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public int getReservedQuantity() {
        return reservedQuantity;
    }

    public void setReservedQuantity(int reservedQuantity) {
        this.reservedQuantity = reservedQuantity;
    }

    public LocalDateTime getLastUpdated() {
        return lastUpdated;
    }

    public void setLastUpdated(LocalDateTime lastUpdated) {
        this.lastUpdated = lastUpdated;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }
}
