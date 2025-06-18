package model;

import java.util.Date;

public class Brand {
    private Long brandId;
    private String name;
    private String description;
    private String logoUrl;
    private boolean isActive;
    private Date createdAt;

    public Brand() {
    }

    public Brand(Long brandId, String name, String description, String logoUrl, 
                 boolean isActive, Date createdAt) {
        this.brandId = brandId;
        this.name = name;
        this.description = description;
        this.logoUrl = logoUrl;
        this.isActive = isActive;
        this.createdAt = createdAt;
    }

    public Long getBrandId() {
        return brandId;
    }

    public void setBrandId(Long brandId) {
        this.brandId = brandId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getLogoUrl() {
        return logoUrl;
    }

    public void setLogoUrl(String logoUrl) {
        this.logoUrl = logoUrl;
    }

    public boolean isActive() {
        return isActive;
    }

    public void setActive(boolean isActive) {
        this.isActive = isActive;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }
}