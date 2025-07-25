package DTO;

public class ProductVariantSelectionDTO {
    private long variantId;
    private String productName;
    private String sku;
    private String size;
    private String color;
    private int currentStock;

    // --- Getters and Setters ---
    public long getVariantId() { return variantId; }
    public void setVariantId(long variantId) { this.variantId = variantId; }
    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }
    public String getSku() { return sku; }
    public void setSku(String sku) { this.sku = sku; }
    public String getSize() { return size; }
    public void setSize(String size) { this.size = size; }
    public String getColor() { return color; }
    public void setColor(String color) { this.color = color; }
    public int getCurrentStock() { return currentStock; }
    public void setCurrentStock(int currentStock) { this.currentStock = currentStock; }
}