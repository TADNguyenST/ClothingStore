package DTO;

import java.math.BigDecimal;
import java.sql.Date;

public class SavedVoucherDTO {

    private long id;
    private String code;
    private String name;
    private String type;              // "Percentage" | "Fixed Amount"
    private BigDecimal value;
    private BigDecimal minOrder;
    private BigDecimal maxDiscount;
    private Date expirationDate;
    private boolean active;
    private boolean visibility;       // public/private
    private boolean used;             // từ customer_vouchers.is_used

    public SavedVoucherDTO() {
    }

    public SavedVoucherDTO(long id, String code, String name, String type,
            BigDecimal value, BigDecimal minOrder, BigDecimal maxDiscount,
            Date expirationDate, boolean active, boolean visibility, boolean used) {
        this.id = id;
        this.code = code;
        this.name = name;
        this.type = type;
        this.value = value;
        this.minOrder = minOrder;
        this.maxDiscount = maxDiscount;
        this.expirationDate = expirationDate;
        this.active = active;
        this.visibility = visibility;
        this.used = used;
    }

    public long getId() {
        return id;
    }

    public String getCode() {
        return code;
    }

    public String getName() {
        return name;
    }

    public String getType() {
        return type;
    }

    public BigDecimal getValue() {
        return value;
    }

    public BigDecimal getMinOrder() {
        return minOrder;
    }

    public BigDecimal getMaxDiscount() {
        return maxDiscount;
    }

    public Date getExpirationDate() {
        return expirationDate;
    }

    public boolean isActive() {
        return active;
    }

    public boolean isVisibility() {
        return visibility;
    }

    public boolean isUsed() {
        return used;
    }

    public void setId(long id) {
        this.id = id;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setType(String type) {
        this.type = type;
    }

    public void setValue(BigDecimal value) {
        this.value = value;
    }

    public void setMinOrder(BigDecimal minOrder) {
        this.minOrder = minOrder;
    }

    public void setMaxDiscount(BigDecimal maxDiscount) {
        this.maxDiscount = maxDiscount;
    }

    public void setExpirationDate(Date expirationDate) {
        this.expirationDate = expirationDate;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    public void setVisibility(boolean visibility) {
        this.visibility = visibility;
    }

    public void setUsed(boolean used) {
        this.used = used;
    }
}
