// Model: FeedbackReply.java
// Đặt trong package model

package model;

import java.sql.Timestamp;

public class FeedbackReply {
    private long replyId;
    private long feedbackId;
    private long staffId;
    private String content;
    private Timestamp replyDate;
    private String visibility;

    // Constructors
    public FeedbackReply() {}

    public FeedbackReply(long feedbackId, long staffId, String content, String visibility) {
        this.feedbackId = feedbackId;
        this.staffId = staffId;
        this.content = content;
        this.visibility = visibility;
    }

    // Getters and Setters
    public long getReplyId() {
        return replyId;
    }

    public void setReplyId(long replyId) {
        this.replyId = replyId;
    }

    public long getFeedbackId() {
        return feedbackId;
    }

    public void setFeedbackId(long feedbackId) {
        this.feedbackId = feedbackId;
    }

    public long getStaffId() {
        return staffId;
    }

    public void setStaffId(long staffId) {
        this.staffId = staffId;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public Timestamp getReplyDate() {
        return replyDate;
    }

    public void setReplyDate(Timestamp replyDate) {
        this.replyDate = replyDate;
    }

    public String getVisibility() {
        return visibility;
    }

    public void setVisibility(String visibility) {
        this.visibility = visibility;
    }
}