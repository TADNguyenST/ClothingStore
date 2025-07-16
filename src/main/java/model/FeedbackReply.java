/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.util.Date;

public class FeedbackReply {

    private int replyId;
    private int feedbackId;
    private int staffId;
    private String content;
    private Date replyDate;
    private String visibility;

    public FeedbackReply() {
    }

    public FeedbackReply(int replyId, int feedbackId, int staffId, String content, Date replyDate, String visibility) {
        this.replyId = replyId;
        this.feedbackId = feedbackId;
        this.staffId = staffId;
        this.content = content;
        this.replyDate = replyDate;
        this.visibility = visibility;
    }

    // Getters và Setters
    public int getReplyId() {
        return replyId;
    }

    public void setReplyId(int replyId) {
        this.replyId = replyId;
    }

    public int getFeedbackId() {
        return feedbackId;
    }

    public void setFeedbackId(int feedbackId) {
        this.feedbackId = feedbackId;
    }

    public int getStaffId() {
        return staffId;
    }

    public void setStaffId(int staffId) {
        this.staffId = staffId;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public Date getReplyDate() {
        return replyDate;
    }

    public void setReplyDate(Date replyDate) {
        this.replyDate = replyDate;
    }

    public String getVisibility() {
        return visibility;
    }

    public void setVisibility(String visibility) {
        this.visibility = visibility;
    }
}
