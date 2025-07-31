/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;
import java.sql.Date;
import java.sql.Timestamp;
/**
 *
 * @author Lenovo
 */
public class Customer {
    private long customerId;
    private long userId;
    private int loyaltyPoints;
    private Date birthDate;
    private String gender;
    private Timestamp createdAt;
    private String avatarUrl;
    private String email;
    private String fullName;
    private String phoneNumber;

    // Default constructor
    public Customer() {
    }

    // Parameterized constructor
    public Customer(long customerId, long userId, int loyaltyPoints, Date birthDate, String gender, Timestamp createdAt) {
        this.customerId = customerId;
        this.userId = userId;
        this.loyaltyPoints = loyaltyPoints;
        this.birthDate = birthDate;
        this.gender = gender;
        this.createdAt = createdAt;
    }

    // Getters and Setters
    public long getCustomerId() {
        return customerId;
    }

    public void setCustomerId(long customerId) {
        this.customerId = customerId;
    }

    public long getUserId() {
        return userId;
    }

    public void setUserId(long userId) {
        this.userId = userId;
    }

    public int getLoyaltyPoints() {
        return loyaltyPoints;
    }

    public void setLoyaltyPoints(int loyaltyPoints) {
        this.loyaltyPoints = loyaltyPoints;
    }

    public Date getBirthDate() {
        return birthDate;
    }

    public void setBirthDate(Date birthDate) {
        this.birthDate = birthDate;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
    public String getAvatarUrl() {
    return avatarUrl;
}

public void setAvatarUrl(String avatarUrl) {
    this.avatarUrl = avatarUrl;
}

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }
}
