package model;

import java.io.Serializable;
import java.time.LocalDateTime;

public class ProductFavorite implements Serializable {
    private static final long serialVersionUID = 1L;
    private Long favoriteId;
    private Long customerId; // FK
    private Long productId; // FK
    private LocalDateTime dateAdded;
    private Boolean isActive;

    public ProductFavorite() {}

    public ProductFavorite(Long favoriteId, Long customerId, Long productId, LocalDateTime dateAdded, Boolean isActive) {
        this.favoriteId = favoriteId;
        this.customerId = customerId;
        this.productId = productId;
        this.dateAdded = dateAdded;
        this.isActive = isActive;
    }

    // Getters and Setters
    public Long getFavoriteId() { return favoriteId; }
    public void setFavoriteId(Long favoriteId) { this.favoriteId = favoriteId; }
    public Long getCustomerId() { return customerId; }
    public void setCustomerId(Long customerId) { this.customerId = customerId; }
    public Long getProductId() { return productId; }
    public void setProductId(Long productId) { this.productId = productId; }
    public LocalDateTime getDateAdded() { return dateAdded; }
    public void setDateAdded(LocalDateTime dateAdded) { this.dateAdded = dateAdded; }
    public Boolean getIsActive() { return isActive; }
    public void setIsActive(Boolean active) { isActive = active; }

    @Override
    public String toString() {
        return "ProductFavorite{" +
               "favoriteId=" + favoriteId +
               ", customerId=" + customerId +
               ", productId=" + productId +
               '}';
    }
}