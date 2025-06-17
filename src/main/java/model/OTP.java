package model;

import java.io.Serializable;
import java.time.LocalDateTime;

public class Otp implements Serializable {
    private static final long serialVersionUID = 1L;
    private Long otpId;
    private Long userId;
    private String otpCode;
    private String purpose; // 'Registration', 'Password Reset', 'Login', 'Phone Verification'
    private LocalDateTime expiresAt;
    private Boolean isUsed;
    private LocalDateTime createdAt;

    public Otp() {}

    public Otp(Long otpId, Long userId, String otpCode, String purpose, LocalDateTime expiresAt, Boolean isUsed, LocalDateTime createdAt) {
        this.otpId = otpId;
        this.userId = userId;
        this.otpCode = otpCode;
        this.purpose = purpose;
        this.expiresAt = expiresAt;
        this.isUsed = isUsed;
        this.createdAt = createdAt;
    }

    // Getters and Setters
    public Long getOtpId() { return otpId; }
    public void setOtpId(Long otpId) { this.otpId = otpId; }
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public String getOtpCode() { return otpCode; }
    public void setOtpCode(String otpCode) { this.otpCode = otpCode; }
    public String getPurpose() { return purpose; }
    public void setPurpose(String purpose) { this.purpose = purpose; }
    public LocalDateTime getExpiresAt() { return expiresAt; }
    public void setExpiresAt(LocalDateTime expiresAt) { this.expiresAt = expiresAt; }
    public Boolean getIsUsed() { return isUsed; }
    public void setIsUsed(Boolean used) { isUsed = used; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    @Override
    public String toString() {
        return "Otp{" +
               "otpId=" + otpId +
               ", userId=" + userId +
               ", purpose='" + purpose + '\'' +
               '}';
    }
}