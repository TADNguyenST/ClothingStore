package model;

import java.sql.Timestamp;

public class ProductFavorite {

    private int id; // favorite_id
    private long customerId; // customer_id
    private int productId;
    private Timestamp dateAdded;
    private boolean isActive;

    public ProductFavorite() {
    }

    public ProductFavorite(int id, long customerId, int productId, Timestamp dateAdded, boolean isActive) {
        this.id = id;
        this.customerId = customerId;
        this.productId = productId;
        this.dateAdded = dateAdded;
        this.isActive = isActive;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public long getCustomerId() {
        return customerId;
    }

    public void setCustomerId(long customerId) {
        this.customerId = customerId;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public Timestamp getDateAdded() {
        return dateAdded;
    }

    public void setDateAdded(Timestamp dateAdded) {
        this.dateAdded = dateAdded;
    }

    public boolean isActive() {
        return isActive;
    }

    public void setActive(boolean isActive) {
        this.isActive = isActive;
    }
}
