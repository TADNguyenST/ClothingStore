package model;

import java.io.Serializable;
import java.math.BigDecimal;

public class ProductVariant implements Serializable {
    private static final long serialVersionUID = 1L;
    private Long variantId;
    private Long productId; // FK
    private String size;
    private String color;
    private BigDecimal priceModifier;
    private String sku; // Unique

    public ProductVariant() {}

    public ProductVariant(Long variantId, Long productId, String size, String color, BigDecimal priceModifier, String sku) {
        this.variantId = variantId;
        this.productId = productId;
        this.size = size;
        this.color = color;
        this.priceModifier = priceModifier;
        this.sku = sku;
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
    public BigDecimal getPriceModifier() { return priceModifier; }
    public void setPriceModifier(BigDecimal priceModifier) { this.priceModifier = priceModifier; }
    public String getSku() { return sku; }
    public void setSku(String sku) { this.sku = sku; }

    @Override
    public String toString() {
        return "ProductVariant{" +
               "variantId=" + variantId +
               ", productId=" + productId +
               ", size='" + size + '\'' +
               ", color='" + color + '\'' +
               '}';
    }
}