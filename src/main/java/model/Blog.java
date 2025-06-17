package model;

import java.io.Serializable;
import java.time.LocalDateTime;

public class Blog implements Serializable {
    private static final long serialVersionUID = 1L;
    private Long blogId;
    private Long staffId; // Nullable FK
    private String title;
    private String slug; // Unique
    private String content; // NTEXT
    private String excerpt; // NTEXT
    private String thumbnailUrl;
    private String category;
    private String tags; // NVARCHAR(MAX)
    private Integer viewCount;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt; // Nullable
    private LocalDateTime publishedAt; // Nullable
    private String status; // 'Draft', 'Published', 'Archived'

    public Blog() {}

    public Blog(Long blogId, Long staffId, String title, String slug, String content, String excerpt, String thumbnailUrl, String category, String tags, Integer viewCount, LocalDateTime createdAt, LocalDateTime updatedAt, LocalDateTime publishedAt, String status) {
        this.blogId = blogId;
        this.staffId = staffId;
        this.title = title;
        this.slug = slug;
        this.content = content;
        this.excerpt = excerpt;
        this.thumbnailUrl = thumbnailUrl;
        this.category = category;
        this.tags = tags;
        this.viewCount = viewCount;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
        this.publishedAt = publishedAt;
        this.status = status;
    }

    // Getters and Setters
    public Long getBlogId() { return blogId; }
    public void setBlogId(Long blogId) { this.blogId = blogId; }
    public Long getStaffId() { return staffId; }
    public void setStaffId(Long staffId) { this.staffId = staffId; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getSlug() { return slug; }
    public void setSlug(String slug) { this.slug = slug; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    public String getExcerpt() { return excerpt; }
    public void setExcerpt(String excerpt) { this.excerpt = excerpt; }
    public String getThumbnailUrl() { return thumbnailUrl; }
    public void setThumbnailUrl(String thumbnailUrl) { this.thumbnailUrl = thumbnailUrl; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public String getTags() { return tags; }
    public void setTags(String tags) { this.tags = tags; }
    public Integer getViewCount() { return viewCount; }
    public void setViewCount(Integer viewCount) { this.viewCount = viewCount; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
    public LocalDateTime getPublishedAt() { return publishedAt; }
    public void setPublishedAt(LocalDateTime publishedAt) { this.publishedAt = publishedAt; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    @Override
    public String toString() {
        return "Blog{" +
               "blogId=" + blogId +
               ", title='" + title + '\'' +
               ", status='" + status + '\'' +
               '}';
    }
}