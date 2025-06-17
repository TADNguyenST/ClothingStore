package model;

import java.io.Serializable;
import java.time.LocalDateTime;

public class Feedback implements Serializable {
    private static final long serialVersionUID = 1L;
    private Long feedbackId;
    private Long productId; // FK
    private Long customerId; // FK
    private Long orderId; // Nullable FK
    private Integer rating; // 1-5
    private String comments; // NTEXT
    private LocalDateTime creationDate;
    private String visibility; // 'Public', 'Private'
    private Boolean isVerified;

    public Feedback() {}

    public Feedback(Long feedbackId, Long productId, Long customerId, Long orderId, Integer rating, String comments, LocalDateTime creationDate, String visibility, Boolean isVerified) {
        this.feedbackId = feedbackId;
        this.productId = productId;
        this.customerId = customerId;
        this.orderId = orderId;
        this.rating = rating;
        this.comments = comments;
        this.creationDate = creationDate;
        this.visibility = visibility;
        this.isVerified = isVerified;
    }

    // Getters and Setters
    public Long getFeedbackId() { return feedbackId; }
    public void setFeedbackId(Long feedbackId) { this.feedbackId = feedbackId; }
    public Long getProductId() { return productId; }
    public void setProductId(Long productId) { this.productId = productId; }
    public Long getCustomerId() { return customerId; }
    public void setCustomerId(Long customerId) { this.customerId = customerId; }
    public Long getOrderId() { return orderId; }
    public void setOrderId(Long orderId) { this.orderId = orderId; }
    public Integer getRating() { return rating; }
    public void setRating(Integer rating) { this.rating = rating; }
    public String getComments() { return comments; }
    public void setComments(String comments) { this.comments = comments; }
    public LocalDateTime getCreationDate() { return creationDate; }
    public void setCreationDate(LocalDateTime creationDate) { this.creationDate = creationDate; }
    public String getVisibility() { return visibility; }
    public void setVisibility(String visibility) { this.visibility = visibility; }
    public Boolean getIsVerified() { return isVerified; }
    public void setIsVerified(Boolean verified) { isVerified = verified; }

    @Override
    public String toString() {
        return "Feedback{" +
               "feedbackId=" + feedbackId +
               ", productId=" + productId +
               ", rating=" + rating +
               '}';
    }
}