package model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

public class PurchaseOrder implements Serializable {
    private static final long serialVersionUID = 1L;
    private Long purchaseOrderId;
    private Long supplierId; // FK
    private Long staffId; // FK
    private LocalDateTime orderDate;
    private LocalDate expectedDeliveryDate;
    private LocalDate actualDeliveryDate; // Nullable
    private String status; // 'Draft', 'Sent', 'Confirmed', 'Delivered', 'Cancelled'
    private BigDecimal totalAmount;
    private String notes; // NTEXT

    public PurchaseOrder() {}

    public PurchaseOrder(Long purchaseOrderId, Long supplierId, Long staffId, LocalDateTime orderDate, LocalDate expectedDeliveryDate, LocalDate actualDeliveryDate, String status, BigDecimal totalAmount, String notes) {
        this.purchaseOrderId = purchaseOrderId;
        this.supplierId = supplierId;
        this.staffId = staffId;
        this.orderDate = orderDate;
        this.expectedDeliveryDate = expectedDeliveryDate;
        this.actualDeliveryDate = actualDeliveryDate;
        this.status = status;
        this.totalAmount = totalAmount;
        this.notes = notes;
    }

    // Getters and Setters
    public Long getPurchaseOrderId() { return purchaseOrderId; }
    public void setPurchaseOrderId(Long purchaseOrderId) { this.purchaseOrderId = purchaseOrderId; }
    public Long getSupplierId() { return supplierId; }
    public void setSupplierId(Long supplierId) { this.supplierId = supplierId; }
    public Long getStaffId() { return staffId; }
    public void setStaffId(Long staffId) { this.staffId = staffId; }
    public LocalDateTime getOrderDate() { return orderDate; }
    public void setOrderDate(LocalDateTime orderDate) { this.orderDate = orderDate; }
    public LocalDate getExpectedDeliveryDate() { return expectedDeliveryDate; }
    public void setExpectedDeliveryDate(LocalDate expectedDeliveryDate) { this.expectedDeliveryDate = expectedDeliveryDate; }
    public LocalDate getActualDeliveryDate() { return actualDeliveryDate; }
    public void setActualDeliveryDate(LocalDate actualDeliveryDate) { this.actualDeliveryDate = actualDeliveryDate; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }
    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    @Override
    public String toString() {
        return "PurchaseOrder{" +
               "purchaseOrderId=" + purchaseOrderId +
               ", supplierId=" + supplierId +
               ", status='" + status + '\'' +
               '}';
    }
}