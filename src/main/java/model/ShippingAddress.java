package model;

import java.io.Serializable;
import java.time.LocalDateTime;

public class ShippingAddress implements Serializable {
    private static final long serialVersionUID = 1L;
    private Long addressId;
    private Long customerId; // FK
    private String recipientName;
    private String phoneNumber;
    private String addressDetails; // NTEXT
    private String city;
    private String country;
    private String postalCode;
    private Boolean isDefault;
    private LocalDateTime createdAt;

    public ShippingAddress() {}

    public ShippingAddress(Long addressId, Long customerId, String recipientName, String phoneNumber, String addressDetails, String city, String country, String postalCode, Boolean isDefault, LocalDateTime createdAt) {
        this.addressId = addressId;
        this.customerId = customerId;
        this.recipientName = recipientName;
        this.phoneNumber = phoneNumber;
        this.addressDetails = addressDetails;
        this.city = city;
        this.country = country;
        this.postalCode = postalCode;
        this.isDefault = isDefault;
        this.createdAt = createdAt;
    }

    // Getters and Setters
    public Long getAddressId() { return addressId; }
    public void setAddressId(Long addressId) { this.addressId = addressId; }
    public Long getCustomerId() { return customerId; }
    public void setCustomerId(Long customerId) { this.customerId = customerId; }
    public String getRecipientName() { return recipientName; }
    public void setRecipientName(String recipientName) { this.recipientName = recipientName; }
    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }
    public String getAddressDetails() { return addressDetails; }
    public void setAddressDetails(String addressDetails) { this.addressDetails = addressDetails; }
    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }
    public String getCountry() { return country; }
    public void setCountry(String country) { this.country = country; }
    public String getPostalCode() { return postalCode; }
    public void setPostalCode(String postalCode) { this.postalCode = postalCode; }
    public Boolean getIsDefault() { return isDefault; }
    public void setIsDefault(Boolean isDefault) { this.isDefault = isDefault; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    @Override
    public String toString() {
        return "ShippingAddress{" +
               "addressId=" + addressId +
               ", recipientName='" + recipientName + '\'' +
               ", city='" + city + '\'' +
               '}';
    }
}