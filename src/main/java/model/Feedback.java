package model;
import java.util.Date;

public class Feedback {
    private long feedbackId;
    private long productId;
    private long customerId;
    private Long orderId;
    private int rating;
    private String comments;
    private Date creationDate;
    private String visibility;
    private boolean isVerified;
    private String replyContent;
    private String customerName;

    // Constructor mặc định
    public Feedback() {
        this.creationDate = new Date();
    }

    // Constructor khớp với FeedbackServlet
    public Feedback(long feedbackId, long customerId, long orderId, int rating, String comments, String visibility, boolean isVerified) {
        this.feedbackId = feedbackId;
        this.productId = 0;
        this.customerId = customerId;
        this.orderId = orderId;
        this.rating = rating;
        this.comments = comments;
        this.creationDate = new Date();
        this.visibility = visibility;
        this.isVerified = isVerified;
    }

    // Getters và setters
    public long getFeedbackId() {
        return feedbackId;
    }

    public void setFeedbackId(long feedbackId) {
        this.feedbackId = feedbackId;
    }

    public long getProductId() {
        return productId;
    }

    public void setProductId(long productId) {
        this.productId = productId;
    }

    public long getCustomerId() {
        return customerId;
    }

    public void setCustomerId(long customerId) {
        this.customerId = customerId;
    }

    public Long getOrderId() {
        return orderId;
    }

    public void setOrderId(Long orderId) {
        this.orderId = orderId;
    }

    public int getRating() {
        return rating;
    }

    public void setRating(int rating) {
        this.rating = rating;
    }

    public String getComments() {
        return comments;
    }

    public void setComments(String comments) {
        this.comments = comments;
    }

    public Date getCreationDate() {
        return creationDate;
    }

    public void setCreationDate(Date creationDate) {
        this.creationDate = creationDate;
    }

    public String getVisibility() {
        return visibility;
    }

    public void setVisibility(String visibility) {
        this.visibility = visibility;
    }

    public boolean isVerified() {
        return isVerified;
    }

    public void setIsVerified(boolean isVerified) {
        this.isVerified = isVerified;
    }

    public String getReplyContent() {
        return replyContent;
    }

    public void setReplyContent(String replyContent) {
        this.replyContent = replyContent;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }
}