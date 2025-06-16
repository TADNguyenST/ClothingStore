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
import java.math.BigDecimal;
import java.time.LocalDateTime;

public class Product implements Serializable {
    private static final long serialVersionUID = 1L;
    private Long productId;
    private String name;
    private String description;
    private BigDecimal price; // DECIMAL(18,2)
    private Integer stockQuantity; // INT (Lưu ý: Bạn có thể loại bỏ hoặc dùng nó như tổng các variant quantity)
    private Long supplierId; // FK
    private Long categoryId; // FK
    private Long brandId; // FK
    private String material;
    private String status; // 'Active', 'Discontinued'
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Nested objects (for convenience when retrieving product details)
    private Category category;
    private Brand brand;
    private Supplier supplier;

    // Constructor
    public Product() {}

    public Product(Long productId, String name, String description, BigDecimal price, Integer stockQuantity, Long supplierId, Long categoryId, Long brandId, String material, String status, LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.productId = productId;
        this.name = name;
        this.description = description;
        this.price = price;
        this.stockQuantity = stockQuantity;
        this.supplierId = supplierId;
        this.categoryId = categoryId;
        this.brandId = brandId;
        this.material = material;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    // Getters and Setters
    public Long getProductId() { return productId; }
    public void setProductId(Long productId) { this.productId = productId; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }
    public Integer getStockQuantity() { return stockQuantity; }
    public void setStockQuantity(Integer stockQuantity) { this.stockQuantity = stockQuantity; }
    public Long getSupplierId() { return supplierId; }
    public void setSupplierId(Long supplierId) { this.supplierId = supplierId; }
    public Long getCategoryId() { return categoryId; }
    public void setCategoryId(Long categoryId) { this.categoryId = categoryId; }
    public Long getBrandId() { return brandId; }
    public void setBrandId(Long brandId) { this.brandId = brandId; }
    public String getMaterial() { return material; }
    public void setMaterial(String material) { this.material = material; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    // Nested object getters and setters
    public Category getCategory() { return category; }
    public void setCategory(Category category) { this.category = category; }
    public Brand getBrand() { return brand; }
    public void setBrand(Brand brand) { this.brand = brand; }
    public Supplier getSupplier() { return supplier; }
    public void setSupplier(Supplier supplier) { this.supplier = supplier; }

    @Override
    public String toString() {
        return "Product{" +
               "productId=" + productId +
               ", name='" + name + '\'' +
               ", price=" + price +
               ", stockQuantity=" + stockQuantity +
               '}';
    }
}