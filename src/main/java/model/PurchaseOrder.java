package model;

import java.math.BigDecimal;
import java.util.Date;

public class PurchaseOrder {
    private Long purchaseOrderId;
    private Long supplierId;
    private Long staffId;
    private Date orderDate;
    private String status;
    private String notes;

    // Constructors
    public PurchaseOrder() {
        this.orderDate = new Date(); // Mặc định ngày tạo phiếu là hiện tại
    }

    // Getters and Setters
    public Long getPurchaseOrderId() { return purchaseOrderId; }
    public void setPurchaseOrderId(Long purchaseOrderId) { this.purchaseOrderId = purchaseOrderId; }
    public Long getSupplierId() { return supplierId; }
    public void setSupplierId(Long supplierId) { this.supplierId = supplierId; }
    public Long getStaffId() { return staffId; }
    public void setStaffId(Long staffId) { this.staffId = staffId; }
    public Date getOrderDate() { return orderDate; }
    public void setOrderDate(Date orderDate) { this.orderDate = orderDate; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
}