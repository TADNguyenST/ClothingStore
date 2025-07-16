package dao;

import model.Blog;
import util.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BlogDAO {

    // ✅ Lấy tất cả blogs (không phân trang, dành cho admin/staff)
    public List<Blog> getAllBlogs() {
        List<Blog> blogs = new ArrayList<>();
        String sql = "SELECT * FROM blogs ORDER BY created_at DESC";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql);  ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                blogs.add(extractFromResultSet(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return blogs;
    }

    // ✅ Lấy danh sách blog đã xuất bản (có phân trang)
    public List<Blog> getPublishedBlogsByPage(int offset, int limit) {
        List<Blog> blogs = new ArrayList<>();
        String sql = "SELECT * FROM blogs WHERE status = 'Published' ORDER BY published_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, offset);
            ps.setInt(2, limit);

            try ( ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    blogs.add(extractFromResultSet(rs));
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return blogs;
    }

    // ✅ Đếm số lượng bài viết đã xuất bản
    public int countPublishedBlogs() {
        String sql = "SELECT COUNT(*) FROM blogs WHERE status = 'Published'";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql);  ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ✅ Lấy blog theo ID
    public Blog getBlogById(long id) {
        String sql = "SELECT * FROM blogs WHERE blog_id = ?";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, id);
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return extractFromResultSet(rs);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // ✅ Thêm blog mới
    public void insert(Blog blog) {
        String sql = "INSERT INTO blogs (staff_id, title, slug, content, excerpt, thumbnail_url, category, tags, view_count, created_at, updated_at, published_at, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, blog.getStaffId());
            ps.setString(2, blog.getTitle());
            ps.setString(3, blog.getSlug());
            ps.setString(4, blog.getContent());
            ps.setString(5, blog.getExcerpt());
            ps.setString(6, blog.getThumbnailUrl());
            ps.setString(7, blog.getCategory());
            ps.setString(8, blog.getTags());
            ps.setInt(9, blog.getViewCount());
            ps.setTimestamp(10, blog.getCreatedAt());
            ps.setTimestamp(11, blog.getUpdatedAt());
            ps.setTimestamp(12, blog.getPublishedAt());
            ps.setString(13, blog.getStatus());
            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // ✅ Cập nhật blog
    public void update(Blog blog) {
        String sql = "UPDATE blogs SET title=?, slug=?, content=?, excerpt=?, thumbnail_url=?, category=?, tags=?, view_count=?, updated_at=?, published_at=?, status=? WHERE blog_id=?";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, blog.getTitle());
            ps.setString(2, blog.getSlug());
            ps.setString(3, blog.getContent());
            ps.setString(4, blog.getExcerpt());
            ps.setString(5, blog.getThumbnailUrl());
            ps.setString(6, blog.getCategory());
            ps.setString(7, blog.getTags());
            ps.setInt(8, blog.getViewCount());
            ps.setTimestamp(9, blog.getUpdatedAt());
            ps.setTimestamp(10, blog.getPublishedAt());
            ps.setString(11, blog.getStatus());
            ps.setLong(12, blog.getBlogId());
            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // ✅ Xóa blog
    public void delete(long blogId) {
        String sql = "DELETE FROM blogs WHERE blog_id = ?";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, blogId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // ✅ Hàm tái sử dụng để tạo đối tượng Blog từ ResultSet
    private Blog extractFromResultSet(ResultSet rs) throws SQLException {
        Blog blog = new Blog();
        blog.setBlogId(rs.getLong("blog_id"));
        blog.setStaffId(rs.getLong("staff_id"));
        blog.setTitle(rs.getString("title"));
        blog.setSlug(rs.getString("slug"));
        blog.setContent(rs.getString("content"));
        blog.setExcerpt(rs.getString("excerpt"));
        blog.setThumbnailUrl(rs.getString("thumbnail_url"));
        blog.setCategory(rs.getString("category"));
        blog.setTags(rs.getString("tags"));
        blog.setViewCount(rs.getInt("view_count"));
        blog.setCreatedAt(rs.getTimestamp("created_at"));
        blog.setUpdatedAt(rs.getTimestamp("updated_at"));
        blog.setPublishedAt(rs.getTimestamp("published_at"));
        blog.setStatus(rs.getString("status"));
        return blog;
    }
}
