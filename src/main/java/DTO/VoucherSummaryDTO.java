package DTO;

import java.math.BigDecimal;

public class VoucherSummaryDTO {

    private long id;
    private String code;
    private String name;
    private String type;              // "Percentage" | "Fixed Amount"
    private BigDecimal value;         // % hoặc số tiền
    private BigDecimal minOrder;
    private BigDecimal maxDiscount;
    private boolean visibility;       // public/private

    public VoucherSummaryDTO() {
    }

    public VoucherSummaryDTO(long id, String code, String name, String type,
            BigDecimal value, BigDecimal minOrder,
            BigDecimal maxDiscount, boolean visibility) {
        this.id = id;
        this.code = code;
        this.name = name;
        this.type = type;
        this.value = value;
        this.minOrder = minOrder;
        this.maxDiscount = maxDiscount;
        this.visibility = visibility;
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

    public boolean isVisibility() {
        return visibility;
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

    public void setVisibility(boolean visibility) {
        this.visibility = visibility;
    }
}
