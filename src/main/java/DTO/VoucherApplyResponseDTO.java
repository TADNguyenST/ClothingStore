package DTO;

import java.math.BigDecimal;

public class VoucherApplyResponseDTO {

    private boolean success;
    private String message;
    private BigDecimal discount;
    private BigDecimal newTotal;
    private VoucherSummaryDTO voucher;

    public VoucherApplyResponseDTO() {
    }

    public static VoucherApplyResponseDTO ok(String message,
            BigDecimal discount,
            BigDecimal newTotal,
            VoucherSummaryDTO v) {
        VoucherApplyResponseDTO r = new VoucherApplyResponseDTO();
        r.success = true;
        r.message = message;
        r.discount = discount;
        r.newTotal = newTotal;
        r.voucher = v;
        return r;
    }

    public static VoucherApplyResponseDTO fail(String message) {
        VoucherApplyResponseDTO r = new VoucherApplyResponseDTO();
        r.success = false;
        r.message = message;
        r.discount = BigDecimal.ZERO;
        r.newTotal = BigDecimal.ZERO;
        r.voucher = null;
        return r;
    }

    public boolean isSuccess() {
        return success;
    }

    public String getMessage() {
        return message;
    }

    public BigDecimal getDiscount() {
        return discount;
    }

    public BigDecimal getNewTotal() {
        return newTotal;
    }

    public VoucherSummaryDTO getVoucher() {
        return voucher;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public void setDiscount(BigDecimal discount) {
        this.discount = discount;
    }

    public void setNewTotal(BigDecimal newTotal) {
        this.newTotal = newTotal;
    }

    public void setVoucher(VoucherSummaryDTO voucher) {
        this.voucher = voucher;
    }
}
