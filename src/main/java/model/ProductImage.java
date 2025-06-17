package model;

import java.io.Serializable;
import java.time.LocalDateTime;

public class ProductImage implements Serializable {
    private static final long serialVersionUID = 1L;
    private Long imageId;
    private Long productId; // FK
    private Long variantId; // Nullable FK
    private String imageUrl;
    private Integer displayOrder;
    private LocalDateTime createdAt;

    public ProductImage() {}

    public ProductImage(Long imageId, Long productId, Long variantId, String imageUrl, Integer displayOrder, LocalDateTime createdAt) {
        this.imageId = imageId;
        this.productId = productId;
        this.variantId = variantId;
        this.imageUrl = imageUrl;
        this.displayOrder = displayOrder;
        this.createdAt = createdAt;
    }

    // Getters and Setters
    public Long getImageId() { return imageId; }
    public void setImageId(Long imageId) { this.imageId = imageId; }
    public Long getProductId() { return productId; }
    public void setProductId(Long productId) { this.productId = productId; }
    public Long getVariantId() { return variantId; }
    public void setVariantId(Long variantId) { this.variantId = variantId; }
    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
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
               '}';
    }
}