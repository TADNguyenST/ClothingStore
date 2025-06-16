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

public class ProductImage implements Serializable {
    private static final long serialVersionUID = 1L;
    private Long imageId;
    private Long productId; // FK
    private String imageUrl;
    private String imageType; // 'Main', 'Detail', 'Thumbnail'
    private Integer displayOrder;
    private LocalDateTime createdAt;

    // Constructor
    public ProductImage() {}

    public ProductImage(Long imageId, Long productId, String imageUrl, String imageType, Integer displayOrder, LocalDateTime createdAt) {
        this.imageId = imageId;
        this.productId = productId;
        this.imageUrl = imageUrl;
        this.imageType = imageType;
        this.displayOrder = displayOrder;
        this.createdAt = createdAt;
    }

    // Getters and Setters
    public Long getImageId() { return imageId; }
    public void setImageId(Long imageId) { this.imageId = imageId; }
    public Long getProductId() { return productId; }
    public void setProductId(Long productId) { this.productId = productId; }
    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
    public String getImageType() { return imageType; }
    public void setImageType(String imageType) { this.imageType = imageType; }
    public Integer getDisplayOrder() { return displayOrder; }
    public void setDisplayOrder(Integer displayOrder) { this.displayOrder = displayOrder; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    @Override
    public String toString() {
        return "ProductImage{" +
               "imageId=" + imageId +
               ", productId=" + productId +
               ", imageUrl='" + imageUrl + '\'' +
               ", imageType='" + imageType + '\'' +
               '}';
    }
}