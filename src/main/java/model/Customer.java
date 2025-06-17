package model;

import java.io.Serializable;
import java.time.LocalDate;
import java.time.LocalDateTime;

public class Customer implements Serializable {
    private static final long serialVersionUID = 1L;
    private Long customerId;
    private Long userId;
    private Integer loyaltyPoints;
    private LocalDate birthDate;
    private String gender; // 'Male', 'Female', 'Non-binary', 'Prefer not to say'
    private LocalDateTime createdAt;

    public Customer() {}

    public Customer(Long customerId, Long userId, Integer loyaltyPoints, LocalDate birthDate, String gender, LocalDateTime createdAt) {
        this.customerId = customerId;
        this.userId = userId;
        this.loyaltyPoints = loyaltyPoints;
        this.birthDate = birthDate;
        this.gender = gender;
        this.createdAt = createdAt;
    }

    // Getters and Setters
    public Long getCustomerId() { return customerId; }
    public void setCustomerId(Long customerId) { this.customerId = customerId; }
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public Integer getLoyaltyPoints() { return loyaltyPoints; }
    public void setLoyaltyPoints(Integer loyaltyPoints) { this.loyaltyPoints = loyaltyPoints; }
    public LocalDate getBirthDate() { return birthDate; }
    public void setBirthDate(LocalDate birthDate) { this.birthDate = birthDate; }
    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    @Override
    public String toString() {
        return "Customer{" +
               "customerId=" + customerId +
               ", userId=" + userId +
               '}';
    }
}