/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class OrderHistory {
    private long userId;
    private long customerId;
    private long orderId;
    private long productId;
    private long variantId;
    private long orderItemId;
    private String userName;
    private String email;
    private Timestamp orderDate;
    private BigDecimal totalPrice;
    private String orderStatus;
    private String paymentStatus;
    private String voucherCode;
    private String productName;
    private String size;
    private String color;

    public OrderHistory() {
    }

    public OrderHistory(long userId, long customerId, long orderId, long productId,
                        long variantId, long orderItemId, String userName, String email,
                        Timestamp orderDate, BigDecimal totalPrice, String orderStatus,
                        String paymentStatus, String voucherCode, String productName,
                        String size, String color) {
        this.userId = userId;
        this.customerId = customerId;
        this.orderId = orderId;
        this.productId = productId;
        this.variantId = variantId;
        this.orderItemId = orderItemId;
        this.userName = userName;
        this.email = email;
        this.orderDate = orderDate;
        this.totalPrice = totalPrice;
        this.orderStatus = orderStatus;
        this.paymentStatus = paymentStatus;
        this.voucherCode = voucherCode;
        this.productName = productName;
        this.size = size;
        this.color = color;
    }

    public long getUserId() {
        return userId;
    }

    public void setUserId(long userId) {
        this.userId = userId;
    }

    public long getCustomerId() {
        return customerId;
    }

    public void setCustomerId(long customerId) {
        this.customerId = customerId;
    }

    public long getOrderId() {
        return orderId;
    }

    public void setOrderId(long orderId) {
        this.orderId = orderId;
    }

    public long getProductId() {
        return productId;
    }

    public void setProductId(long productId) {
        this.productId = productId;
    }

    public long getVariantId() {
        return variantId;
    }

    public void setVariantId(long variantId) {
        this.variantId = variantId;
    }

    public long getOrderItemId() {
        return orderItemId;
    }

    public void setOrderItemId(long orderItemId) {
        this.orderItemId = orderItemId;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public Timestamp getOrderDate() {
        return orderDate;
    }

    public void setOrderDate(Timestamp orderDate) {
        this.orderDate = orderDate;
    }

    public BigDecimal getTotalPrice() {
        return totalPrice;
    }

    public void setTotalPrice(BigDecimal totalPrice) {
        this.totalPrice = totalPrice;
    }

    public String getOrderStatus() {
        return orderStatus;
    }

    public void setOrderStatus(String orderStatus) {
        this.orderStatus = orderStatus;
    }

    public String getPaymentStatus() {
        return paymentStatus;
    }

    public void setPaymentStatus(String paymentStatus) {
        this.paymentStatus = paymentStatus;
    }

    public String getVoucherCode() {
        return voucherCode;
    }

    public void setVoucherCode(String voucherCode) {
        this.voucherCode = voucherCode;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public String getSize() {
        return size;
    }

    public void setSize(String size) {
        this.size = size;
    }

    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
    }

    @Override
    public String toString() {
        return "OrderHistory{" +
                "userId=" + userId +
                ", customerId=" + customerId +
                ", orderId=" + orderId +
                ", productId=" + productId +
                ", variantId=" + variantId +
                ", orderItemId=" + orderItemId +
                ", userName='" + userName + '\'' +
                ", email='" + email + '\'' +
                ", orderDate=" + orderDate +
                ", totalPrice=" + totalPrice +
                ", orderStatus='" + orderStatus + '\'' +
                ", paymentStatus='" + paymentStatus + '\'' +
                ", voucherCode='" + voucherCode + '\'' +
                ", productName='" + productName + '\'' +
                ", size='" + size + '\'' +
                ", color='" + color + '\'' +
                '}';
    }
}

