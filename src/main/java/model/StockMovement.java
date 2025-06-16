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

public class StockMovement implements Serializable {
    private static final long serialVersionUID = 1L;
    private Long movementId;
    private Long productId; // Foreign Key
    private Long variantId; // Foreign Key
    private String movementType; // 'In', 'Out', 'Adjustment', 'Reserved', 'Released'
    private Integer quantity;
    private String referenceType; // 'Purchase Order', 'Sale Order', 'Adjustment', 'Return'
    private Long referenceId; // ID of the referenced order/transaction
    private String notes;
    private Long createdBy; // Foreign Key to Staff table
    private LocalDateTime createdAt;

    // Nested objects (for convenience)
    private Product product;
    private ProductVariant productVariant;
    private Staff staff; // The staff who created this movement

    // Constructor
    public StockMovement() {}

    public StockMovement(Long movementId, Long productId, Long variantId, String movementType, Integer quantity, String referenceType, Long referenceId, String notes, Long createdBy, LocalDateTime createdAt) {
        this.movementId = movementId;
        this.productId = productId;
        this.variantId = variantId;
        this.movementType = movementType;
        this.quantity = quantity;
        this.referenceType = referenceType;
        this.referenceId = referenceId;
        this.notes = notes;
        this.createdBy = createdBy;
        this.createdAt = createdAt;
    }

    // Getters and Setters
    public Long getMovementId() { return movementId; }
    public void setMovementId(Long movementId) { this.movementId = movementId; }
    public Long getProductId() { return productId; }
    public void setProductId(Long productId) { this.productId = productId; }
    public Long getVariantId() { return variantId; }
    public void setVariantId(Long variantId) { this.variantId = variantId; }
    public String getMovementType() { return movementType; }
    public void setMovementType(String movementType) { this.movementType = movementType; }
    public Integer getQuantity() { return quantity; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }
    public String getReferenceType() { return referenceType; }
    public void setReferenceType(String referenceType) { this.referenceType = referenceType; }
    public Long getReferenceId() { return referenceId; }
    public void setReferenceId(Long referenceId) { this.referenceId = referenceId; }
    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
    public Long getCreatedBy() { return createdBy; }
    public void setCreatedBy(Long createdBy) { this.createdBy = createdBy; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    // Nested object getters and setters
    public Product getProduct() { return product; }
    public void setProduct(Product product) { this.product = product; }
    public ProductVariant getProductVariant() { return productVariant; }
    public void setProductVariant(ProductVariant productVariant) { this.productVariant = productVariant; }
    public Staff getStaff() { return staff; }
    public void setStaff(Staff staff) { this.staff = staff; }

    @Override
    public String toString() {
        return "StockMovement{" +
               "movementId=" + movementId +
               ", variantId=" + variantId +
               ", type='" + movementType + '\'' +
               ", quantity=" + quantity +
               '}';
    }
}