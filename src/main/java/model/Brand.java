/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author Lenovo
 */
import java.io.Serializable;
import java.time.LocalDateTime;

public class Brand implements Serializable {
    private static final long serialVersionUID = 1L;
    private Long brandId;
    private String name;
    private String description;
    private String logoUrl;
    private Boolean isActive;
    private LocalDateTime createdAt;

    // Constructor
    public Brand() {}

    public Brand(Long brandId, String name, String description, String logoUrl, Boolean isActive, LocalDateTime createdAt) {
        this.brandId = brandId;
        this.name = name;
        this.description = description;
        this.logoUrl = logoUrl;
        this.isActive = isActive;
        this.createdAt = createdAt;
    }

    // Getters and Setters
    public Long getBrandId() { return brandId; }
    public void setBrandId(Long brandId) { this.brandId = brandId; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getLogoUrl() { return logoUrl; }
    public void setLogoUrl(String logoUrl) { this.logoUrl = logoUrl; }
    public Boolean getIsActive() { return isActive; }
    public void setIsActive(Boolean isActive) { this.isActive = isActive; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    @Override
    public String toString() {
        return "Brand{" +
               "brandId=" + brandId +
               ", name='" + name + '\'' +
               '}';
    }
}