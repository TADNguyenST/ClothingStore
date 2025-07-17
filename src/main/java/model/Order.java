package model;

import com.google.gson.annotations.SerializedName;
import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;

public class Order {

    @SerializedName("orderId")
    private long orderId;
    @SerializedName("customerId")
    private long customerId;
    @SerializedName("shippingAddressId")
    private long shippingAddressId;
    @SerializedName("voucherId")
    private Long voucherId;
    @SerializedName("subtotal")
    private BigDecimal subtotal;
    @SerializedName("discountAmount")
    private BigDecimal discountAmount;
    @SerializedName("shippingFee")
    private BigDecimal shippingFee;
    @SerializedName("totalPrice")
    private BigDecimal totalPrice;
    @SerializedName("status")
    private String status;
    @SerializedName("paymentStatus")
    private String paymentStatus;
    @SerializedName("notes")
    private String notes;
    @SerializedName("estimatedDeliveryDate")
    private Date estimatedDeliveryDate;
    @SerializedName("actualDeliveryDate")
    private Date actualDeliveryDate;
    @SerializedName("createdAt")
    private Timestamp createdAt;
    @SerializedName("updatedAt")
    private Timestamp updatedAt;

    public long getOrderId() {
        return orderId;
    }

    public void setOrderId(long orderId) {
        this.orderId = orderId;
    }

    public long getCustomerId() {
        return customerId;
    }

    public void setCustomerId(long customerId) {
        this.customerId = customerId;
    }

    public long getShippingAddressId() {
        return shippingAddressId;
    }

    public void setShippingAddressId(long shippingAddressId) {
        this.shippingAddressId = shippingAddressId;
    }

    public Long getVoucherId() {
        return voucherId;
    }

    public void setVoucherId(Long voucherId) {
        this.voucherId = voucherId;
    }

    public BigDecimal getSubtotal() {
        return subtotal;
    }

    public void setSubtotal(BigDecimal subtotal) {
        this.subtotal = subtotal;
    }

    public BigDecimal getDiscountAmount() {
        return discountAmount;
    }

    public void setDiscountAmount(BigDecimal discountAmount) {
        this.discountAmount = discountAmount;
    }

    public BigDecimal getShippingFee() {
        return shippingFee;
    }

    public void setShippingFee(BigDecimal shippingFee) {
        this.shippingFee = shippingFee;
    }

    public BigDecimal getTotalPrice() {
        return totalPrice;
    }

    public void setTotalPrice(BigDecimal totalPrice) {
        this.totalPrice = totalPrice;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getPaymentStatus() {
        return paymentStatus;
    }

    public void setPaymentStatus(String paymentStatus) {
        this.paymentStatus = paymentStatus;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public Date getEstimatedDeliveryDate() {
        return estimatedDeliveryDate;
    }

    public void setEstimatedDeliveryDate(Date estimatedDeliveryDate) {
        this.estimatedDeliveryDate = estimatedDeliveryDate;
    }

    public Date getActualDeliveryDate() {
        return actualDeliveryDate;
    }

    public void setActualDeliveryDate(Date actualDeliveryDate) {
        this.actualDeliveryDate = actualDeliveryDate;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

}
