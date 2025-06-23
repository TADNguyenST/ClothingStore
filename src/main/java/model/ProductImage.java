package model;

import java.util.Date;

public class ProductImage {
    private Long imageId;
    private Long productId;
    private Long variantId;
    private String imageUrl;
    private int displayOrder;
    private Date createdAt;
    private boolean isMain;

    public ProductImage() {
    }

    public ProductImage(Long imageId, Long productId, Long variantId, String imageUrl, 
                        int displayOrder, Date createdAt, boolean isMain) {
        this.imageId = imageId;
        this.productId = productId;
        this.variantId = variantId;
        this.imageUrl = imageUrl;
        this.displayOrder = displayOrder;
        this.createdAt = createdAt;
        this.isMain = isMain;
    }

    public Long getImageId() {
        return imageId;
    }

    public void setImageId(Long imageId) {
        this.imageId = imageId;
    }

    public Long getProductId() {
        return productId;
    }

    public void setProductId(Long productId) {
        this.productId = productId;
    }

    public Long getVariantId() {
        return variantId;
    }

    public void setVariantId(Long variantId) {
        this.variantId = variantId;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public int getDisplayOrder() {
        return displayOrder;
    }

    public void setDisplayOrder(int displayOrder) {
        this.displayOrder = displayOrder;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }

    public boolean isMain() {
        return isMain;
    }

    public void setMain(boolean isMain) {
        this.isMain = isMain;
    }
}