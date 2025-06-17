package model;

import java.io.Serializable;
import java.time.LocalDate;
import java.time.LocalDateTime;

public class PaymentMethod implements Serializable {
    private static final long serialVersionUID = 1L;
    private Long paymentMethodId;
    private Long customerId; // FK
    private String methodType; // 'Credit Card', 'Debit Card', 'Bank Transfer', 'E-wallet', 'Cash on Delivery'
    private String provider;
    private String accountNumber;
    private String accountName;
    private LocalDate expiryDate; // Nullable
    private Boolean isDefault;
    private Boolean isActive;
    private LocalDateTime createdAt;

    public PaymentMethod() {}

    public PaymentMethod(Long paymentMethodId, Long customerId, String methodType, String provider, String accountNumber, String accountName, LocalDate expiryDate, Boolean isDefault, Boolean isActive, LocalDateTime createdAt) {
        this.paymentMethodId = paymentMethodId;
        this.customerId = customerId;
        this.methodType = methodType;
        this.provider = provider;
        this.accountNumber = accountNumber;
        this.accountName = accountName;
        this.expiryDate = expiryDate;
        this.isDefault = isDefault;
        this.isActive = isActive;
        this.createdAt = createdAt;
    }

    // Getters and Setters
    public Long getPaymentMethodId() { return paymentMethodId; }
    public void setPaymentMethodId(Long paymentMethodId) { this.paymentMethodId = paymentMethodId; }
    public Long getCustomerId() { return customerId; }
    public void setCustomerId(Long customerId) { this.customerId = customerId; }
    public String getMethodType() { return methodType; }
    public void setMethodType(String methodType) { this.methodType = methodType; }
    public String getProvider() { return provider; }
    public void setProvider(String provider) { this.provider = provider; }
    public String getAccountNumber() { return accountNumber; }
    public void setAccountNumber(String accountNumber) { this.accountNumber = accountNumber; }
    public String getAccountName() { return accountName; }
    public void setAccountName(String accountName) { this.accountName = accountName; }
    public LocalDate getExpiryDate() { return expiryDate; }
    public void setExpiryDate(LocalDate expiryDate) { this.expiryDate = expiryDate; }
    public Boolean getIsDefault() { return isDefault; }
    public void setIsDefault(Boolean isDefault) { this.isDefault = isDefault; }
    public Boolean getIsActive() { return isActive; }
    public void setIsActive(Boolean active) { isActive = active; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    @Override
    public String toString() {
        return "PaymentMethod{" +
               "paymentMethodId=" + paymentMethodId +
               ", methodType='" + methodType + '\'' +
               ", provider='" + provider + '\'' +
               '}';
    }
}