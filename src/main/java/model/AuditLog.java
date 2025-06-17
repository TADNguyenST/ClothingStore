package model;

import java.io.Serializable;
import java.time.LocalDateTime;

public class AuditLog implements Serializable {
    private static final long serialVersionUID = 1L;
    private Long auditId;
    private String tableName;
    private Long recordId;
    private String action; // 'INSERT', 'UPDATE', 'DELETE'
    private String oldValues; // NVARCHAR(MAX)
    private String newValues; // NVARCHAR(MAX)
    private Long userId; // Nullable FK
    private String ipAddress;
    private String userAgent; // NVARCHAR(MAX)
    private LocalDateTime createdAt;

    public AuditLog() {}

    public AuditLog(Long auditId, String tableName, Long recordId, String action, String oldValues, String newValues, Long userId, String ipAddress, String userAgent, LocalDateTime createdAt) {
        this.auditId = auditId;
        this.tableName = tableName;
        this.recordId = recordId;
        this.action = action;
        this.oldValues = oldValues;
        this.newValues = newValues;
        this.userId = userId;
        this.ipAddress = ipAddress;
        this.userAgent = userAgent;
        this.createdAt = createdAt;
    }

    // Getters and Setters
    public Long getAuditId() { return auditId; }
    public void setAuditId(Long auditId) { this.auditId = auditId; }
    public String getTableName() { return tableName; }
    public void setTableName(String tableName) { this.tableName = tableName; }
    public Long getRecordId() { return recordId; }
    public void setRecordId(Long recordId) { this.recordId = recordId; }
    public String getAction() { return action; }
    public void setAction(String action) { this.action = action; }
    public String getOldValues() { return oldValues; }
    public void setOldValues(String oldValues) { this.oldValues = oldValues; }
    public String getNewValues() { return newValues; }
    public void setNewValues(String newValues) { this.newValues = newValues; }
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public String getIpAddress() { return ipAddress; }
    public void setIpAddress(String ipAddress) { this.ipAddress = ipAddress; }
    public String getUserAgent() { return userAgent; }
    public void setUserAgent(String userAgent) { this.userAgent = userAgent; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    @Override
    public String toString() {
        return "AuditLog{" +
               "auditId=" + auditId +
               ", tableName='" + tableName + '\'' +
               ", action='" + action + '\'' +
               '}';
    }
}