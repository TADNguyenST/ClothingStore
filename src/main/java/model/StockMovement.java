package model;

import java.io.Serializable;
import java.time.LocalDateTime;

public class StockMovement implements Serializable {
    private static final long serialVersionUID = 1L;
    private Long movementId;
    private Long variantId; // FK
    private String movementType; // 'In', 'Out', 'Adjustment', 'Reserved', 'Released'
    private Integer quantityChanged;
    private String referenceType; // 'Purchase Order', 'Sale Order', 'Adjustment', 'Return'
    private Long referenceId; // Nullable
    private String notes; // NTEXT
    private Long createdBy; // FK staff_id
    private LocalDateTime createdAt;

    public StockMovement() {}

    public StockMovement(Long movementId, Long variantId, String movementType, Integer quantityChanged, String referenceType, Long referenceId, String notes, Long createdBy, LocalDateTime createdAt) {
        this.movementId = movementId;
        this.variantId = variantId;
        this.movementType = movementType;
        this.quantityChanged = quantityChanged;
        this.referenceType = referenceType;
        this.referenceId = referenceId;
        this.notes = notes;
        this.createdBy = createdBy;
        this.createdAt = createdAt;
    }

    // Getters and Setters
    public Long getMovementId() { return movementId; }
    public void setMovementId(Long movementId) { this.movementId = movementId; }
    public Long getVariantId() { return variantId; }
    public void setVariantId(Long variantId) { this.variantId = variantId; }
    public String getMovementType() { return movementType; }
    public void setMovementType(String movementType) { this.movementType = movementType; }
    public Integer getQuantityChanged() { return quantityChanged; }
    public void setQuantityChanged(Integer quantityChanged) { this.quantityChanged = quantityChanged; }
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

    @Override
    public String toString() {
        return "StockMovement{" +
               "movementId=" + movementId +
               ", variantId=" + variantId +
               ", quantityChanged=" + quantityChanged +
               '}';
    }
}