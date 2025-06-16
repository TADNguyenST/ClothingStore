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

public class ProductVariant implements Serializable {
    private static final long serialVersionUID = 1L;
    private Long variantId;
    private Long productId; // Foreign Key
    private String size;
    private String color;
    private Integer quantity; // This should ideally be managed by Inventory table
    private BigDecimal price; // DECIMAL(18,2), can be null if it uses product's price
    private String sku;
    private LocalDateTime createdAt;

    // Nested object (for convenience)
    private Product product;

    // Constructor
    public ProductVariant() {}

    public ProductVariant(Long variantId, Long productId, String size, String color, Integer quantity, BigDecimal price, String sku, LocalDateTime createdAt) {
        this.variantId = variantId;
        this.productId = productId;
        this.size = size;
        this.color = color;
        this.quantity = quantity;
        this.price = price;
        this.sku = sku;
        this.createdAt = createdAt;
    }

    // Getters and Setters
    public Long getVariantId() { return variantId; }
    public void setVariantId(Long variantId) { this.variantId = variantId; }
    public Long getProductId() { return productId; }
    public void setProductId(Long productId) { this.productId = productId; }
    public String getSize() { return size; }
    public void setSize(String size) { this.size = size; }
    public String getColor() { return color; }
    public void setColor(String color) { this.color = color; }
    public Integer getQuantity() { return quantity; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }
    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }
    public String getSku() { return sku; }
    public void setSku(String sku) { this.sku = sku; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    // Nested object getters and setters
    public Product getProduct() { return product; }
    public void setProduct(Product product) { this.product = product; }

    @Override
    public String toString() {
        return "ProductVariant{" +
               "variantId=" + variantId +
               ", productId=" + productId +
               ", size='" + size + '\'' +
               ", color='" + color + '\'' +
               ", sku='" + sku + '\'' +
               '}';
    }
}