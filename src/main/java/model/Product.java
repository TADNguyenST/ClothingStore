package model;

import java.math.BigDecimal;
import java.util.Date;
import java.util.List;

public class Product {

    private Long productId;
    private String name;
    private String description;
    private BigDecimal price;
    private Category category;
    private Long categoryId;
    private Brand brand;
    private Long brandId;
    private String material;
    private String status;
    private Date createdAt;
    private Date updatedAt;
    private List<ProductVariant> variants;
    private List<ProductImage> images;
    private String imageUrl;
    private Long defaultVariantId;
    private BigDecimal defaultVariantPrice;
    private String formattedPrice;
    private String parentCategoryName;
    private int quantity;
    private String stockStatus;
    private transient String color;
    private transient String size;

    public Product() {
    }

    public Product(Long productId, String name, String description, BigDecimal price,
            Category category, Brand brand, String material, String status,
            Date createdAt, Date updatedAt) {
        this.productId = productId;
        this.name = name;
        this.description = description;
        this.price = price;
        this.category = category;
        this.brand = brand;
        this.material = material;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public Product(Long productId, String name, String description, BigDecimal price,
            Category category, Brand brand, String material, String status,
            Date createdAt, Date updatedAt, List<ProductVariant> variants,
            List<ProductImage> images, String imageUrl, Long defaultVariantId,
            BigDecimal defaultVariantPrice, int quantity, String stockStatus) {
        this.productId = productId;
        this.name = name;
        this.description = description;
        this.price = price;
        this.category = category;
        this.brand = brand;
        this.material = material;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
        this.variants = variants;
        this.images = images;
        this.imageUrl = imageUrl;
        this.defaultVariantId = defaultVariantId;
        this.defaultVariantPrice = defaultVariantPrice;
        this.quantity = quantity;
        this.stockStatus = stockStatus;
    }

    public Long getProductId() {
        return productId;
    }

    public void setProductId(Long productId) {
        this.productId = productId;
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

    public BigDecimal getPrice() {
        return price;
    }

    public void setPrice(BigDecimal price) {
        this.price = price;
    }

    public Category getCategory() {
        return category;
    }

    public void setCategory(Category category) {
        this.category = category;
    }

    public Long getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(Long categoryId) {
        this.categoryId = categoryId;
    }

    public Brand getBrand() {
        return brand;
    }

    public void setBrand(Brand brand) {
        this.brand = brand;
    }

    public Long getBrandId() {
        return brandId;
    }

    public void setBrandId(Long brandId) {
        this.brandId = brandId;
    }

    public String getMaterial() {
        return material;
    }

    public void setMaterial(String material) {
        this.material = material;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }

    public Date getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Date updatedAt) {
        this.updatedAt = updatedAt;
    }

    public List<ProductVariant> getVariants() {
        return variants;
    }

    public void setVariants(List<ProductVariant> variants) {
        this.variants = variants;
    }

    public List<ProductImage> getImages() {
        return images;
    }

    public void setImages(List<ProductImage> images) {
        this.images = images;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public Long getDefaultVariantId() {
        return defaultVariantId;
    }

    public void setDefaultVariantId(Long defaultVariantId) {
        this.defaultVariantId = defaultVariantId;
    }

    public BigDecimal getDefaultVariantPrice() {
        return defaultVariantPrice;
    }

    public void setDefaultVariantPrice(BigDecimal defaultVariantPrice) {
        this.defaultVariantPrice = defaultVariantPrice;
    }

    public String getFormattedPrice() {
        return formattedPrice;
    }

    public void setFormattedPrice(String formattedPrice) {
        this.formattedPrice = formattedPrice;
    }

    public String getParentCategoryName() {
        return parentCategoryName;
    }

    public void setParentCategoryName(String parentCategoryName) {
        this.parentCategoryName = parentCategoryName;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public String getStockStatus() {
        return stockStatus;
    }

    public void setStockStatus(String stockStatus) {
        this.stockStatus = stockStatus;
    }

    public String getSeoUrl() {
        String slug = name != null ? name.toLowerCase().replaceAll("[^a-z0-9]+", "-") : "";
        return productId != null ? "/product/" + productId + "/" + slug : "#";
    }

    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
    }

    public String getSize() {
        return size;
    }

    public void setSize(String size) {
        this.size = size;
    }
}
