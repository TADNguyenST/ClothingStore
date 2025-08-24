package DTO;

import java.util.List;

public class SavedVouchersResponseDTO {

    private boolean success;
    private String message;
    private List<SavedVoucherDTO> vouchers;

    public SavedVouchersResponseDTO() {
    }

    public SavedVouchersResponseDTO(boolean success, String message, List<SavedVoucherDTO> vouchers) {
        this.success = success;
        this.message = message;
        this.vouchers = vouchers;
    }

    public static SavedVouchersResponseDTO ok(List<SavedVoucherDTO> list) {
        return new SavedVouchersResponseDTO(true, "OK", list);
    }

    public static SavedVouchersResponseDTO fail(String msg) {
        return new SavedVouchersResponseDTO(false, msg, null);
    }

    public boolean isSuccess() {
        return success;
    }

    public String getMessage() {
        return message;
    }

    public List<SavedVoucherDTO> getVouchers() {
        return vouchers;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public void setVouchers(List<SavedVoucherDTO> vouchers) {
        this.vouchers = vouchers;
    }
}
