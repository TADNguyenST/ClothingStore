package dao;

import java.sql.*;
import java.util.*;
import model.Feedback;
import util.DBContext;

public class FeedbackDAO {

    public double getAverageRatingByProductId(long productId) {
        double avg = 0;
        String sql = "SELECT AVG(rating * 1.0) AS average_rating "
                + "FROM feedbacks "
                + "WHERE product_id = ? AND visibility = 'Public' AND is_verified = 1";
        try ( Connection con = DBContext.getNewConnection();  PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setLong(1, productId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                avg = rs.getDouble("average_rating");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return avg;
    }

    public List<Feedback> getAllFeedbacks() {
        List<Feedback> list = new ArrayList<>();
        String sql = "SELECT * FROM feedbacks";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql);  ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapResultSetToFeedback(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public void addFeedback(Feedback fb) {
        String sql = "INSERT INTO feedbacks "
                + "(product_id, customer_id, order_id, rating, comments, creation_date, visibility, is_verified) "
                + "VALUES (?, ?, ?, ?, ?, GETDATE(), ?, ?)";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, fb.getProductId());
            ps.setLong(2, fb.getCustomerId());
            ps.setLong(3, fb.getOrderId());
            ps.setInt(4, fb.getRating());
            ps.setString(5, fb.getComments());
            ps.setString(6, fb.getVisibility()); // now String
            ps.setBoolean(7, fb.isVerified());
            ps.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public List<Feedback> getFeedbackByProductId(long productId) {
        List<Feedback> list = new ArrayList<>();
        String sql = "SELECT * FROM feedbacks "
                + "WHERE product_id = ? AND is_verified = 1 AND visibility = 'Public'";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, productId);
            try ( ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToFeedback(rs));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public Feedback getFeedbackById(long feedbackId) {
        String sql = "SELECT * FROM feedbacks WHERE feedback_id = ?";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, feedbackId);
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToFeedback(rs);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // ✅ Helper method: clean mapping logic
    private Feedback mapResultSetToFeedback(ResultSet rs) throws SQLException {
        Feedback fb = new Feedback();
        fb.setFeedbackId(rs.getLong("feedback_id"));
        fb.setProductId(rs.getLong("product_id"));
        fb.setCustomerId(rs.getLong("customer_id"));
        fb.setOrderId(rs.getLong("order_id"));
        fb.setRating(rs.getInt("rating"));
        fb.setComments(rs.getString("comments"));
        fb.setCreationDate(rs.getTimestamp("creation_date"));
        fb.setVisibility(rs.getString("visibility"));
        fb.setVerified(rs.getBoolean("is_verified"));
        return fb;
    }
}
