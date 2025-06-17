package model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

public class Payment implements Serializable {
    private static final long serialVersionUID = 1L;
    private Long paymentId;
    private Long orderId; // FK
    private Long paymentMethodId; // Nullable FK
    private BigDecimal amount;
    private String paymentStatus; // 'Success', 'Failed', 'Pending', 'Cancelled', 'Refunded'
    private String transactionId; // Nullable
    private LocalDateTime paymentDate;
    private String notes; // NTEXT

    public Payment() {}

    public Payment(Long paymentId, Long orderId, Long paymentMethodId, BigDecimal amount, String paymentStatus, String transactionId, LocalDateTime paymentDate, String notes) {
        this.paymentId = paymentId;
        this.orderId = orderId;
        this.paymentMethodId = paymentMethodId;
        this.amount = amount;
        this.paymentStatus = paymentStatus;
        this.transactionId = transactionId;
        this.paymentDate = paymentDate;
        this.notes = notes;
    }

    // Getters and Setters
    public Long getPaymentId() { return paymentId; }
    public void setPaymentId(Long paymentId) { this.paymentId = paymentId; }
    public Long getOrderId() { return orderId; }
    public void setOrderId(Long orderId) { this.orderId = orderId; }
    public Long getPaymentMethodId() { return paymentMethodId; }
    public void setPaymentMethodId(Long paymentMethodId) { this.paymentMethodId = paymentMethodId; }
    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }
    public String getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }
    public String getTransactionId() { return transactionId; }
    public void setTransactionId(String transactionId) { this.transactionId = transactionId; }
    public LocalDateTime getPaymentDate() { return paymentDate; }
    public void setPaymentDate(LocalDateTime paymentDate) { this.paymentDate = paymentDate; }
    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    @Override
    public String toString() {
        return "Payment{" +
               "paymentId=" + paymentId +
               ", orderId=" + orderId +
               ", amount=" + amount +
               ", status='" + paymentStatus + '\'' +
               '}';
    }
}