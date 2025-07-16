package model;

import java.util.Date;
import java.util.List;

public class Feedback {

    private long feedbackId;
    private long productId;
    private long customerId;
    private long orderId;
    private int rating;
    private String comments;
    private Date creationDate;

    // 🔁 Sửa từ boolean -> String
    private String visibility;  // 'Public', 'Hidden', etc.
    private boolean isVerified;

    // 👇 Các field mở rộng
    private String customerName;          // Tên người đánh giá
    private String variantInfo;           // Ví dụ: Màu sắc, size
    private String sellerReply;           // Phản hồi từ người bán
    private List<String> mediaUrls;       // Danh sách ảnh hoặc video

    // Getters and Setters
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

    public long getOrderId() {
        return orderId;
    }

    public void setOrderId(long orderId) {
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

    // ✅ visibility kiểu String
    public String getVisibility() {
        return visibility;
    }

    public void setVisibility(String visibility) {
        this.visibility = visibility;
    }

    public boolean isVerified() {
        return isVerified;
    }

    public void setVerified(boolean isVerified) {
        this.isVerified = isVerified;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public String getVariantInfo() {
        return variantInfo;
    }

    public void setVariantInfo(String variantInfo) {
        this.variantInfo = variantInfo;
    }

    public String getSellerReply() {
        return sellerReply;
    }

    public void setSellerReply(String sellerReply) {
        this.sellerReply = sellerReply;
    }

    public List<String> getMediaUrls() {
        return mediaUrls;
    }

    public void setMediaUrls(List<String> mediaUrls) {
        this.mediaUrls = mediaUrls;
    }
}
