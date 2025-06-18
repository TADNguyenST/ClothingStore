/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import java.sql.*;
import java.util.*;
import model.Blog;

public class BlogDAO {
    private Connection conn;

    public BlogDAO(Connection conn) {
        this.conn = conn;
    }

    public List<Blog> getAll() throws SQLException {
        List<Blog> list = new ArrayList<>();
        String sql = "SELECT * FROM blogs ORDER BY published_at DESC";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToBlog(rs));
            }
        }
        return list;
    }

    public Blog getById(int blogId) throws SQLException {
        String sql = "SELECT * FROM blogs WHERE blog_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, blogId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToBlog(rs);
                }
            }
        }
        return null;
    }

    public void insert(Blog post) throws SQLException {
        String sql = "INSERT INTO blogs (staff_id, title, slug, content, excerpt, thumbnail_url, category, tags, view_count, created_at, updated_at, published_at, status) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, post.getStaffId());
            ps.setString(2, post.getTitle());
            ps.setString(3, post.getSlug());
            ps.setString(4, post.getContent());
            ps.setString(5, post.getExcerpt());
            ps.setString(6, post.getThumbnailUrl());
            ps.setString(7, post.getCategory());
            ps.setString(8, post.getTags());
            ps.setInt(9, post.getViewCount());
            ps.setTimestamp(10, new Timestamp(post.getCreatedAt().getTime()));
            ps.setTimestamp(11, new Timestamp(post.getUpdatedAt().getTime()));
            ps.setTimestamp(12, new Timestamp(post.getPublishedAt().getTime()));
            ps.setString(13, post.getStatus());

            ps.executeUpdate();
        }
    }

    private Blog mapResultSetToBlog(ResultSet rs) throws SQLException {
        Blog post = new Blog();
        post.setBlogId(rs.getInt("blog_id"));
        post.setStaffId(rs.getInt("staff_id"));
        post.setTitle(rs.getString("title"));
        post.setSlug(rs.getString("slug"));
        post.setContent(rs.getString("content"));
        post.setExcerpt(rs.getString("excerpt"));
        post.setThumbnailUrl(rs.getString("thumbnail_url"));
        post.setCategory(rs.getString("category"));
        post.setTags(rs.getString("tags"));
        post.setViewCount(rs.getInt("view_count"));
        post.setCreatedAt(rs.getTimestamp("created_at"));
        post.setUpdatedAt(rs.getTimestamp("updated_at"));
        post.setPublishedAt(rs.getTimestamp("published_at"));
        post.setStatus(rs.getString("status"));
        return post;
    }
}
