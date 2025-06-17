package model;

import java.io.Serializable;
import java.time.LocalDateTime;

public class CustomerVoucher implements Serializable {
    private static final long serialVersionUID = 1L;
    private Long customerVoucherId;
    private Long customerId; // FK
    private Long voucherId; // FK
    private LocalDateTime sentDate;
    private Boolean isUsed;
    private LocalDateTime usedDate; // Nullable
    private Long orderId; // Nullable FK

    public CustomerVoucher() {}

    public CustomerVoucher(Long customerVoucherId, Long customerId, Long voucherId, LocalDateTime sentDate, Boolean isUsed, LocalDateTime usedDate, Long orderId) {
        this.customerVoucherId = customerVoucherId;
        this.customerId = customerId;
        this.voucherId = voucherId;
        this.sentDate = sentDate;
        this.isUsed = isUsed;
        this.usedDate = usedDate;
        this.orderId = orderId;
    }

    // Getters and Setters
    public Long getCustomerVoucherId() { return customerVoucherId; }
    public void setCustomerVoucherId(Long customerVoucherId) { this.customerVoucherId = customerVoucherId; }
    public Long getCustomerId() { return customerId; }
    public void setCustomerId(Long customerId) { this.customerId = customerId; }
    public Long getVoucherId() { return voucherId; }
    public void setVoucherId(Long voucherId) { this.voucherId = voucherId; }
    public LocalDateTime getSentDate() { return sentDate; }
    public void setSentDate(LocalDateTime sentDate) { this.sentDate = sentDate; }
    public Boolean getIsUsed() { return isUsed; }
    public void setIsUsed(Boolean used) { isUsed = used; }
    public LocalDateTime getUsedDate() { return usedDate; }
    public void setUsedDate(LocalDateTime usedDate) { this.usedDate = usedDate; }
    public Long getOrderId() { return orderId; }
    public void setOrderId(Long orderId) { this.orderId = orderId; }

    @Override
    public String toString() {
        return "CustomerVoucher{" +
               "customerVoucherId=" + customerVoucherId +
               ", customerId=" + customerId +
               ", voucherId=" + voucherId +
               '}';
    }
}