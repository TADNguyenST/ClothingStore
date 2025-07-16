/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import model.FeedbackReply;
import util.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class FeedbackReplyDAO extends DBContext {

    // Thêm phản hồi mới
    public void insertReply(FeedbackReply reply) throws SQLException {
        String sql = "INSERT INTO feedback_replies (feedback_id, staff_id, content, reply_date, visibility) "
                + "VALUES (?, ?, ?, ?, ?)";

        try ( Connection conn = getConnection();  PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, reply.getFeedbackId());
            stmt.setInt(2, reply.getStaffId());
            stmt.setString(3, reply.getContent());
            stmt.setTimestamp(4, new Timestamp(reply.getReplyDate().getTime()));
            stmt.setString(5, reply.getVisibility());

            stmt.executeUpdate();
        }
    }

    // Lấy tất cả phản hồi theo feedback_id
    public List<FeedbackReply> getRepliesByFeedbackId(int feedbackId) throws SQLException {
        List<FeedbackReply> list = new ArrayList<>();
        String sql = "SELECT * FROM feedback_replies WHERE feedback_id = ? ORDER BY reply_date DESC";

        try ( Connection conn = getConnection();  PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, feedbackId);
            try ( ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    FeedbackReply reply = new FeedbackReply(
                            rs.getInt("reply_id"),
                            rs.getInt("feedback_id"),
                            rs.getInt("staff_id"),
                            rs.getString("content"),
                            rs.getTimestamp("reply_date"),
                            rs.getString("visibility")
                    );
                    list.add(reply);
                }
            }
        }
        return list;
    }

    // Xóa phản hồi theo reply_id (nếu cần)
    public boolean deleteReply(int replyId) throws SQLException {
        String sql = "DELETE FROM feedback_replies WHERE reply_id = ?";
        try ( Connection conn = getConnection();  PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, replyId);
            return stmt.executeUpdate() > 0;
        }
    }
}
