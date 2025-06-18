package model;

import java.time.LocalDateTime;

public class CustomerVoucher {
    private Long customerVoucherId;
    private Long customerId;
    private Long voucherId;
    private LocalDateTime sentDate;
    private boolean isUsed;
    private LocalDateTime usedDate;
    private Long orderId;

    // Constructors
    public CustomerVoucher() {
    }

    // Getters and Setters
    public Long getCustomerVoucherId() {
        return customerVoucherId;
    }

    public void setCustomerVoucherId(Long customerVoucherId) {
        this.customerVoucherId = customerVoucherId;
    }

    public Long getCustomerId() {
        return customerId;
    }

    public void setCustomerId(Long customerId) {
        this.customerId = customerId;
    }

    public Long getVoucherId() {
        return voucherId;
    }

    public void setVoucherId(Long voucherId) {
        this.voucherId = voucherId;
    }

    public LocalDateTime getSentDate() {
        return sentDate;
    }

    public void setSentDate(LocalDateTime sentDate) {
        this.sentDate = sentDate;
    }

    public boolean isUsed() {
        return isUsed;
    }

    public void setUsed(boolean used) {
        isUsed = used;
    }

    public LocalDateTime getUsedDate() {
        return usedDate;
    }

    public void setUsedDate(LocalDateTime usedDate) {
        this.usedDate = usedDate;
    }

    public Long getOrderId() {
        return orderId;
    }

    public void setOrderId(Long orderId) {
        this.orderId = orderId;
    }
}