package model;

import java.io.Serializable;
import java.time.LocalDateTime;

public class FeedbackReply implements Serializable {
    private static final long serialVersionUID = 1L;
    private Long replyId;
    private Long feedbackId; // FK
    private Long staffId; // FK
    private String content; // NTEXT
    private LocalDateTime replyDate;
    private String visibility; // 'Public', 'Private'

    public FeedbackReply() {}

    public FeedbackReply(Long replyId, Long feedbackId, Long staffId, String content, LocalDateTime replyDate, String visibility) {
        this.replyId = replyId;
        this.feedbackId = feedbackId;
        this.staffId = staffId;
        this.content = content;
        this.replyDate = replyDate;
        this.visibility = visibility;
    }

    // Getters and Setters
    public Long getReplyId() { return replyId; }
    public void setReplyId(Long replyId) { this.replyId = replyId; }
    public Long getFeedbackId() { return feedbackId; }
    public void setFeedbackId(Long feedbackId) { this.feedbackId = feedbackId; }
    public Long getStaffId() { return staffId; }
    public void setStaffId(Long staffId) { this.staffId = staffId; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    public LocalDateTime getReplyDate() { return replyDate; }
    public void setReplyDate(LocalDateTime replyDate) { this.replyDate = replyDate; }
    public String getVisibility() { return visibility; }
    public void setVisibility(String visibility) { this.visibility = visibility; }

    @Override
    public String toString() {
        return "FeedbackReply{" +
               "replyId=" + replyId +
               ", feedbackId=" + feedbackId +
               ", staffId=" + staffId +
               '}';
    }
}