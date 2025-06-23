package model;

import java.sql.Timestamp;

public class ShippingAddress {

    private long addressId;
    private long customerId;
    private String recipientName;
    private String phoneNumber;
    private String addressDetails;
    private String city;
    private String country;
    private String postalCode;
    private boolean isDefault;
    private Timestamp createdAt;

    public ShippingAddress() {
    }

    // Getters and Setters
    public long getAddressId() {
        return addressId;
    }

    public void setAddressId(long addressId) {
        this.addressId = addressId;
    }

    public long getCustomerId() {
        return customerId;
    }

    public void setCustomerId(long customerId) {
        this.customerId = customerId;
    }

    public String getRecipientName() {
        return recipientName;
    }

    public void setRecipientName(String recipientName) {
        this.recipientName = recipientName;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public String getAddressDetails() {
        return addressDetails;
    }

    public void setAddressDetails(String addressDetails) {
        this.addressDetails = addressDetails;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public String getCountry() {
        return country;
    }

    public void setCountry(String country) {
        this.country = country;
    }

    public String getPostalCode() {
        return postalCode;
    }

    public void setPostalCode(String postalCode) {
        this.postalCode = postalCode;
    }

    public boolean isIsDefault() { // Corrected getter for boolean 'isDefault'
        return isDefault;
    }

    public void setIsDefault(boolean isDefault) { // Corrected setter for boolean 'isDefault'
        this.isDefault = isDefault;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    @Override
    public String toString() {
        return "ShippingAddress{"
                + "addressId=" + addressId
                + ", customerId=" + customerId
                + ", recipientName='" + recipientName + '\''
                + ", phoneNumber='" + phoneNumber + '\''
                + ", addressDetails='" + addressDetails + '\''
                + ", city='" + city + '\''
                + ", country='" + country + '\''
                + ", postalCode='" + postalCode + '\''
                + ", isDefault=" + isDefault
                + ", createdAt=" + createdAt
                + '}';
    }
}
