package model;
import java.math.BigDecimal;
import java.sql.Timestamp;

public class CustomerVoucher {
    private long customerVoucherId;
    private long customerId;
    private long voucherId;
    private Timestamp sentDate;
    private boolean isUsed;
    private Timestamp usedDate;
    private Long orderId;
    private String voucherCode;
    private String voucherName;
    private String discountType;
    private BigDecimal discountValue;
    private boolean isActive;
    private Timestamp startDate;
    private Timestamp expirationDate;

    public long getCustomerVoucherId() {
        return customerVoucherId;
    }

    public void setCustomerVoucherId(long customerVoucherId) {
        this.customerVoucherId = customerVoucherId;
    }

    public long getCustomerId() {
        return customerId;
    }

    public void setCustomerId(long customerId) {
        this.customerId = customerId;
    }

    public long getVoucherId() {
        return voucherId;
    }

    public void setVoucherId(long voucherId) {
        this.voucherId = voucherId;
    }

    public Timestamp getSentDate() {
        return sentDate;
    }

    public void setSentDate(Timestamp sentDate) {
        this.sentDate = sentDate;
    }

    public boolean isIsUsed() {
        return isUsed;
    }

    public void setIsUsed(boolean isUsed) {
        this.isUsed = isUsed;
    }

    public Timestamp getUsedDate() {
        return usedDate;
    }

    public void setUsedDate(Timestamp usedDate) {
        this.usedDate = usedDate;
    }

    public Long getOrderId() {
        return orderId;
    }

    public void setOrderId(Long orderId) {
        this.orderId = orderId;
    }

    public String getVoucherCode() {
        return voucherCode;
    }

    public void setVoucherCode(String voucherCode) {
        this.voucherCode = voucherCode;
    }

    public String getVoucherName() {
        return voucherName;
    }

    public void setVoucherName(String voucherName) {
        this.voucherName = voucherName;
    }

    public String getDiscountType() {
        return discountType;
    }

    public void setDiscountType(String discountType) {
        this.discountType = discountType;
    }

    public BigDecimal getDiscountValue() {
        return discountValue;
    }

    public void setDiscountValue(BigDecimal discountValue) {
        this.discountValue = discountValue;
    }

    public boolean isActive() {
        return isActive;
    }

    public void setActive(boolean active) {
        isActive = active;
    }

    public Timestamp getStartDate() {
        return startDate;
    }

    public void setStartDate(Timestamp startDate) {
        this.startDate = startDate;
    }

    public Timestamp getExpirationDate() {
        return expirationDate;
    }

    public void setExpirationDate(Timestamp expirationDate) {
        this.expirationDate = expirationDate;
    }

    public CustomerVoucher(long customerVoucherId, long customerId, long voucherId, Timestamp sentDate, boolean isUsed, Timestamp usedDate, Long orderId, String voucherCode, String voucherName, String discountType, BigDecimal discountValue, boolean isActive, Timestamp startDate, Timestamp expirationDate) {
        this.customerVoucherId = customerVoucherId;
        this.customerId = customerId;
        this.voucherId = voucherId;
        this.sentDate = sentDate;
        this.isUsed = isUsed;
        this.usedDate = usedDate;
        this.orderId = orderId;
        this.voucherCode = voucherCode;
        this.voucherName = voucherName;
        this.discountType = discountType;
        this.discountValue = discountValue;
        this.isActive = isActive;
        this.startDate = startDate;
        this.expirationDate = expirationDate;
    }
}