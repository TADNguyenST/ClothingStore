package model;

import java.io.Serializable;
import java.time.LocalDateTime;

public class Staff implements Serializable {
    private static final long serialVersionUID = 1L;
    private Long staffId;
    private Long userId;
    private String position;
    private String notes; // NTEXT
    private LocalDateTime createdAt;

    public Staff() {}

    public Staff(Long staffId, Long userId, String position, String notes, LocalDateTime createdAt) {
        this.staffId = staffId;
        this.userId = userId;
        this.position = position;
        this.notes = notes;
        this.createdAt = createdAt;
    }

    // Getters and Setters
    public Long getStaffId() { return staffId; }
    public void setStaffId(Long staffId) { this.staffId = staffId; }
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public String getPosition() { return position; }
    public void setPosition(String position) { this.position = position; }
    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    @Override
    public String toString() {
        return "Staff{" +
               "staffId=" + staffId +
               ", position='" + position + '\'' +
               '}';
    }
}