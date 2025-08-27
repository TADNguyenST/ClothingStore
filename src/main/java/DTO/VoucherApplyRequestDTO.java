package DTO;

import java.math.BigDecimal;

public class VoucherApplyRequestDTO {

    private String code;
    private BigDecimal subtotal;
    private Long userId;

    public VoucherApplyRequestDTO() {
    }

    public VoucherApplyRequestDTO(String code, BigDecimal subtotal, Long userId) {
        this.code = code;
        this.subtotal = subtotal;
        this.userId = userId;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public BigDecimal getSubtotal() {
        return subtotal;
    }

    public void setSubtotal(BigDecimal subtotal) {
        this.subtotal = subtotal;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }
}
