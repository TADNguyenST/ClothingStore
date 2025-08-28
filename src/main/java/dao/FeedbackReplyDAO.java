package dao;

import model.FeedbackReply;
import util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Timestamp;

public class FeedbackReplyDAO {
    private static final String INSERT_FEEDBACK_REPLY =
        "INSERT INTO feedback_replies (feedback_id, staff_id, content, reply_date, visibility) " +
        "VALUES (?, ?, ?, ?, ?)";

    public boolean addFeedbackReply(FeedbackReply reply) throws SQLException {
        try (Connection conn = DBContext.getNewConnection();
             PreparedStatement ps = conn.prepareStatement(INSERT_FEEDBACK_REPLY)) {
            ps.setLong(1, reply.getFeedbackId());
            ps.setLong(2, reply.getStaffId());
            ps.setString(3, reply.getContent());
            ps.setTimestamp(4, reply.getReplyDate());
            ps.setString(5, reply.getVisibility());
            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException ex) {
            throw new SQLException("Error adding feedback reply: " + ex.getMessage(), ex);
        }
    }

    public void closeConnection() {
        // Không cần thực hiện vì sử dụng getNewConnection() với try-with-resources
    }
}