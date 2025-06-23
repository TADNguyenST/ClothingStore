package model;

import java.math.BigDecimal;

public class ProductVariant {
    private Long variantId;
    private Long productId;
    private String size;
    private String color;
    private BigDecimal priceModifier;
    private String sku;

    // Thêm để sinh SKU
    private String brand;
    private String productName;

    public ProductVariant() {
    }

    // Constructor không sinh SKU (nếu muốn nhập tay)
    public ProductVariant(Long variantId, Long productId, String size, String color,
                          BigDecimal priceModifier, String sku) {
        this.variantId = variantId;
        this.productId = productId;
        this.size = size;
        this.color = color;
        this.priceModifier = priceModifier;
        this.sku = sku;
    }

    // Constructor có tự sinh SKU
    public ProductVariant(Long productId, String size, String color,
                          BigDecimal priceModifier, String brand, String productName) {
        this.productId = productId;
        this.size = size;
        this.color = color;
        this.priceModifier = priceModifier;
        this.brand = brand;
        this.productName = productName;
        this.sku = generateSku();
    }

    // Hàm tự động sinh SKU
    private String generateSku() {
        return (brand + "-" + size + "-" + color + "-" + productName + "-" + priceModifier)
                .toUpperCase()
                .replaceAll("\\s+", "");
    }

    public Long getVariantId() {
        return variantId;
    }

    public void setVariantId(Long variantId) {
        this.variantId = variantId;
    }

    public Long getProductId() {
        return productId;
    }

    public void setProductId(Long productId) {
        this.productId = productId;
    }

    public String getSize() {
        return size;
    }

    public void setSize(String size) {
        this.size = size;
        this.sku = generateSku(); // update SKU nếu có thay đổi
    }

    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
        this.sku = generateSku();
    }

    public BigDecimal getPriceModifier() {
        return priceModifier;
    }

    public void setPriceModifier(BigDecimal priceModifier) {
        this.priceModifier = priceModifier;
        this.sku = generateSku();
    }

    public String getSku() {
        return sku;
    }

    public void setSku(String sku) {
        this.sku = sku;
    }

    public String getBrand() {
        return brand;
    }

    public void setBrand(String brand) {
        this.brand = brand;
        this.sku = generateSku();
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
        this.sku = generateSku();
    }
}
