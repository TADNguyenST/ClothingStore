/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author DANGVUONGTHINH
 */
public class CategoryDetail {
    private Long categoryDetailId;
    private Long categoryId;
    private Category category;
    private String subCategoryName;
    private String description;

    // Getters and Setters
    public Long getCategoryDetailId() {
        return categoryDetailId;
    }

    public void setCategoryDetailId(Long categoryDetailId) {
        this.categoryDetailId = categoryDetailId;
    }

    public Long getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(Long categoryId) {
        this.categoryId = categoryId;
    }

    public Category getCategory() {
        return category;
    }

    public void setCategory(Category category) {
        this.category = category;
    }

    public String getSubCategoryName() {
        return subCategoryName;
    }

    public void setSubCategoryName(String subCategoryName) {
        this.subCategoryName = subCategoryName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

}
