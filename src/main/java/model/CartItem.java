package model;

import java.math.BigDecimal;

public class CartItem {

    private long cartItemId;
    private long variantId;
    private long productId;
    private int quantity;
    private BigDecimal unitPrice;
    private String productName;
    private String size;
    private String color;
    private String imageUrl;
    private int availableStock;

    // --- thêm field không map DB, chỉ dùng hiển thị/tính toán ---
    private BigDecimal totalPrice;

    public long getCartItemId() {
        return cartItemId;
    }

    public void setCartItemId(long cartItemId) {
        this.cartItemId = cartItemId;
    }

    public long getVariantId() {
        return variantId;
    }

    public void setVariantId(long variantId) {
        this.variantId = variantId;
    }

    public long getProductId() {
        return productId;
    }

    public void setProductId(long productId) {
        this.productId = productId;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public BigDecimal getUnitPrice() {
        return unitPrice;
    }

    public void setUnitPrice(BigDecimal unitPrice) {
        this.unitPrice = unitPrice;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public String getSize() {
        return size;
    }

    public void setSize(String size) {
        this.size = size;
    }

    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public int getAvailableStock() {
        return availableStock;
    }

    public void setAvailableStock(int availableStock) {
        this.availableStock = availableStock;
    }

    /**
     * Nếu totalPrice đã được set từ DAO/Service thì trả về giá trị đó. Nếu
     * chưa, tự tính từ unitPrice * quantity (an toàn null).
     */
    public BigDecimal getTotalPrice() {
        if (totalPrice != null) {
            return totalPrice;
        }
        BigDecimal up = (unitPrice != null) ? unitPrice : BigDecimal.ZERO;
        int qty = Math.max(0, quantity);
        return up.multiply(BigDecimal.valueOf(qty));
    }

    /**
     * Cho phép DAO/Service set sẵn tổng tiền để hiển thị
     */
    public void setTotalPrice(BigDecimal totalPrice) {
        this.totalPrice = totalPrice;
    }
}
