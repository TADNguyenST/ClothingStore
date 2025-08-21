package model;

import java.math.BigDecimal;

public class ProductVariant {
    private Long variantId;
    private Long productId;
    private String size;
    private String color;
    private BigDecimal priceModifier;
    private String sku;
    private int quantity;
    private String stockStatus;
    private transient String brand;
    private transient String productName;

    public ProductVariant() {
    }

    public ProductVariant(Long variantId, Long productId, String size, String color,
                         BigDecimal priceModifier, String sku, int quantity, String stockStatus) {
        this.variantId = variantId;
        this.productId = productId;
        this.size = size;
        this.color = color;
        this.priceModifier = priceModifier;
        this.sku = sku;
        this.quantity = quantity;
        this.stockStatus = stockStatus;
    }

    // Constructor with SKU generation (used when creating new)
    public ProductVariant(Long productId, String size, String color,
                         BigDecimal priceModifier, String brand, String productName) {
        this.productId = productId;
        this.size = size;
        this.color = color;
        this.priceModifier = priceModifier;
        this.brand = brand;
        this.productName = productName;
        this.sku = generateSku();
        this.quantity = 0;
        this.stockStatus = "Out of Stock";
    }

    private String generateSku() {
        String brandSafe = (brand != null ? brand : "UNKNOWN").replaceAll("\\s+", "");
        String sizeSafe = (size != null ? size : "NOSIZE").replaceAll("\\s+", "");
        String colorSafe = (color != null ? color : "NOCOLOR").replaceAll("\\s+", "");
        String productNameSafe = (productName != null ? productName : "NOPRODUCT").replaceAll("\\s+", "");
        return String.format("%s-%s-%s-%s", brandSafe, sizeSafe, colorSafe, productNameSafe).toUpperCase();
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
        if (brand != null && productName != null && color != null) {
            this.sku = generateSku();
        }
    }

    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
        if (brand != null && productName != null && size != null) {
            this.sku = generateSku();
        }
    }

    public BigDecimal getPriceModifier() {
        return priceModifier;
    }

    public void setPriceModifier(BigDecimal priceModifier) {
        this.priceModifier = priceModifier;
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
        if (size != null && color != null && productName != null) {
            this.sku = generateSku();
        }
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
        if (size != null && color != null && brand != null) {
            this.sku = generateSku();
        }
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
        this.stockStatus = quantity > 0 ? "In Stock" : "Out of Stock";
    }

    public String getStockStatus() {
        return stockStatus;
    }

    public void setStockStatus(String stockStatus) {
        this.stockStatus = stockStatus;
    }
}