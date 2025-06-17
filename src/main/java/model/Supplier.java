package model;

import java.io.Serializable;
import java.time.LocalDateTime;

public class Supplier implements Serializable {
    private static final long serialVersionUID = 1L;
    private Long supplierId;
    private String name;
    private String contactEmail;
    private String phoneNumber;
    private String address; // NTEXT
    private Boolean isActive;
    private LocalDateTime createdAt;

    public Supplier() {}

    public Supplier(Long supplierId, String name, String contactEmail, String phoneNumber, String address, Boolean isActive, LocalDateTime createdAt) {
        this.supplierId = supplierId;
        this.name = name;
        this.contactEmail = contactEmail;
        this.phoneNumber = phoneNumber;
        this.address = address;
        this.isActive = isActive;
        this.createdAt = createdAt;
    }

    // Getters and Setters
    public Long getSupplierId() { return supplierId; }
    public void setSupplierId(Long supplierId) { this.supplierId = supplierId; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getContactEmail() { return contactEmail; }
    public void setContactEmail(String contactEmail) { this.contactEmail = contactEmail; }
    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
    public Boolean getIsActive() { return isActive; }
    public void setIsActive(Boolean active) { isActive = active; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    @Override
    public String toString() {
        return "Supplier{" +
               "supplierId=" + supplierId +
               ", name='" + name + '\'' +
               '}';
    }
}