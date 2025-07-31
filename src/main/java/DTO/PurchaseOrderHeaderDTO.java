package DTO;

import java.util.Date;

public class PurchaseOrderHeaderDTO {

    private long poId;
    private Long supplierId;
    private String supplierName;
    private String status;
    private String notes;
    private String notePrefix;
    private String userNotes;
    private Date orderDate;

    // --- Getters and Setters ---
    public long getPoId() {
        return poId;
    }

    public void setPoId(long poId) {
        this.poId = poId;
    }

    public Long getSupplierId() {
        return supplierId;
    }

    public void setSupplierId(Long supplierId) {
        this.supplierId = supplierId;
    }

    public String getSupplierName() {
        return supplierName;
    }

    public void setSupplierName(String supplierName) {
        this.supplierName = supplierName;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public Date getOrderDate() {
        return orderDate;
    }

    public void setOrderDate(Date orderDate) {
        this.orderDate = orderDate;
    }

    public String getNotePrefix() {
        return notePrefix;
    }

    public void setNotePrefix(String notePrefix) {
        this.notePrefix = notePrefix;
    }

    public String getUserNotes() {
        return userNotes;
    }

    public void setUserNotes(String userNotes) {
        this.userNotes = userNotes;
    }
}
