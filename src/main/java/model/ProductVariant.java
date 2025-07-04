package model;

import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.Date;

public class ProductVariant {
    private Long variantId;
    private Long productId;
    private String size;
    private String color;
    private BigDecimal priceModifier;
    private String sku;

    // Thuộc tính tạm thời để sinh SKU
    private transient String brand;
    private transient String productName;

    public ProductVariant() {
    }

    // Constructor không sinh SKU (dùng khi lấy từ DB)
    public ProductVariant(Long variantId, Long productId, String size, String color,
                          BigDecimal priceModifier, String sku) {
        this.variantId = variantId;
        this.productId = productId;
        this.size = size;
        this.color = color;
        this.priceModifier = priceModifier;
        this.sku = sku;
    }

    // Constructor sinh SKU (dùng khi tạo mới)
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

    // Hàm sinh SKU với xử lý null và định dạng priceModifier
    private String generateSku() {
        String brandSafe = (brand != null ? brand : "UNKNOWN").replaceAll("\\s+", "");
        String sizeSafe = (size != null ? size : "NOSIZE").replaceAll("\\s+", "");
        String colorSafe = (color != null ? color : "NOCOLOR").replaceAll("\\s+", "");
        String productNameSafe = (productName != null ? productName : "NOPRODUCT").replaceAll("\\s+", "");
        // Định dạng priceModifier với dấu chấm cứ 3 số
        DecimalFormat decimalFormat = new DecimalFormat("#,###");
        String priceSafe = (priceModifier != null ? decimalFormat.format(priceModifier) : "0");
        return String.format("%s-%s-%s-%s-%s", brandSafe, sizeSafe, colorSafe, 
                            productNameSafe, priceSafe.replace(",", ".")).toUpperCase();
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
        if (brand != null && productName != null) {
            this.sku = generateSku();
        }
    }

    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
        if (brand != null && productName != null) {
            this.sku = generateSku();
        }
    }

    public BigDecimal getPriceModifier() {
        return priceModifier;
    }

    public void setPriceModifier(BigDecimal priceModifier) {
        this.priceModifier = priceModifier;
        if (brand != null && productName != null) {
            this.sku = generateSku();
        }
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
}