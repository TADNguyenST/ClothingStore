package model;

import java.util.Date;

public class Category {
    private Long categoryId;
    private String name;
    private String description;
    private Long parentCategoryId;
    private boolean isActive;
    private Date createdAt;

    public Category() {
    }

    public Category(Long categoryId, String name, String description, Long parentCategoryId, 
                    boolean isActive, Date createdAt) {
        this.categoryId = categoryId;
        this.name = name;
        this.description = description;
        this.parentCategoryId = parentCategoryId;
        this.isActive = isActive;
        this.createdAt = createdAt;
    }

    public Long getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(Long categoryId) {
        this.categoryId = categoryId;
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

    public Long getParentCategoryId() {
        return parentCategoryId;
    }

    public void setParentCategoryId(Long parentCategoryId) {
        this.parentCategoryId = parentCategoryId;
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

    public String getSeoUrl() {
        String slug = name.toLowerCase().replaceAll("[^a-z0-9]+", "-");
        return "/category/" + categoryId + "/" + slug;
    }
}