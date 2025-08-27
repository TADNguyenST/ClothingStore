package dao;

import model.Feedback;
import util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class FeedbackDAO {
    private static final Logger LOGGER = Logger.getLogger(FeedbackDAO.class.getName());
    private static final String INSERT_FEEDBACK =
        "INSERT INTO feedbacks (product_id, customer_id, order_id, rating, comments, creation_date, visibility, is_verified) " +
        "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
    private static final String GET_PRODUCTS_BY_ORDER =
        "SELECT oi.variant_id, p.product_id " +
        "FROM order_items oi " +
        "JOIN product_variants pv ON oi.variant_id = pv.variant_id " +
        "JOIN products p ON pv.product_id = p.product_id " +
        "WHERE oi.order_id = ?";
    private static final String GET_ALL_FEEDBACK =
        "SELECT f.feedback_id, f.product_id, f.customer_id, f.order_id, f.rating, f.comments, " +
        "f.creation_date, f.visibility, f.is_verified, fr.content AS reply_content " +
        "FROM feedbacks f " +
        "LEFT JOIN feedback_replies fr ON f.feedback_id = fr.feedback_id " +
        "ORDER BY f.creation_date DESC";
    private static final String GET_FEEDBACK_BY_PRODUCT =
        "SELECT f.feedback_id, f.product_id, f.customer_id, f.order_id, f.rating, f.comments, " +
        "f.creation_date, f.visibility, f.is_verified, fr.content AS reply_content, u.full_name AS customer_name " +
        "FROM feedbacks f " +
        "LEFT JOIN feedback_replies fr ON f.feedback_id = fr.feedback_id " +
        "JOIN customers c ON f.customer_id = c.customer_id " +
        "JOIN users u ON c.user_id = u.user_id " +
        "WHERE f.product_id = ? " +
        "ORDER BY f.creation_date DESC";
    private static final String GET_CUSTOMER_ID_BY_USER_ID =
        "SELECT c.customer_id " +
        "FROM customers c " +
        "JOIN users u ON c.user_id = u.user_id " +
        "WHERE u.user_id = ?";

    public List<Long> getProductIdsByOrderId(long orderId) throws SQLException {
        List<Long> productIds = new ArrayList<>();
        try (Connection conn = DBContext.getNewConnection();
             PreparedStatement ps = conn.prepareStatement(GET_PRODUCTS_BY_ORDER)) {
            ps.setLong(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    productIds.add(rs.getLong("product_id"));
                }
            }
            LOGGER.log(Level.INFO, "Retrieved product IDs for order {0}: {1}", new Object[]{orderId, productIds});
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting product IDs for order {0}: {1}", new Object[]{orderId, ex.getMessage()});
            throw new SQLException("Error getting product IDs for order: " + ex.getMessage(), ex);
        }
        return productIds;
    }

    public boolean addFeedback(Feedback feedback) throws SQLException {
        try (Connection conn = DBContext.getNewConnection();
             PreparedStatement ps = conn.prepareStatement(INSERT_FEEDBACK)) {
            ps.setLong(1, feedback.getProductId());
            ps.setLong(2, feedback.getCustomerId());
            if (feedback.getOrderId() != null) {
                ps.setLong(3, feedback.getOrderId());
            } else {
                ps.setNull(3, java.sql.Types.BIGINT);
            }
            ps.setInt(4, feedback.getRating());
            ps.setString(5, feedback.getComments());
            ps.setTimestamp(6, new Timestamp(feedback.getCreationDate().getTime()));
            ps.setString(7, feedback.getVisibility());
            ps.setBoolean(8, feedback.isVerified());
            int rowsAffected = ps.executeUpdate();
            LOGGER.log(Level.INFO, "Feedback added for product {0} by customer {1}: {2} rows affected",
                    new Object[]{feedback.getProductId(), feedback.getCustomerId(), rowsAffected});
            return rowsAffected > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error adding feedback for product {0}: {1}",
                    new Object[]{feedback.getProductId(), ex.getMessage()});
            throw new SQLException("Error adding feedback: " + ex.getMessage(), ex);
        }
    }

    public List<Feedback> getAllFeedback() throws SQLException {
        List<Feedback> feedbackList = new ArrayList<>();
        try (Connection conn = DBContext.getNewConnection();
             PreparedStatement ps = conn.prepareStatement(GET_ALL_FEEDBACK);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Feedback feedback = new Feedback();
                feedback.setFeedbackId(rs.getLong("feedback_id"));
                feedback.setProductId(rs.getLong("product_id"));
                feedback.setCustomerId(rs.getLong("customer_id"));
                feedback.setOrderId(rs.getLong("order_id") == 0 ? null : rs.getLong("order_id"));
                feedback.setRating(rs.getInt("rating"));
                feedback.setComments(rs.getString("comments"));
                feedback.setCreationDate(rs.getTimestamp("creation_date"));
                feedback.setVisibility(rs.getString("visibility"));
                feedback.setIsVerified(rs.getBoolean("is_verified"));
                feedback.setReplyContent(rs.getString("reply_content"));
                feedbackList.add(feedback);
            }
            LOGGER.log(Level.INFO, "Retrieved {0} feedbacks", feedbackList.size());
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error retrieving all feedbacks: {0}", ex.getMessage());
            throw new SQLException("Error retrieving feedback: " + ex.getMessage(), ex);
        }
        return feedbackList;
    }

    public List<Feedback> getFeedbackByProductId(long productId) throws SQLException {
        List<Feedback> feedbackList = new ArrayList<>();
        try (Connection conn = DBContext.getNewConnection();
             PreparedStatement ps = conn.prepareStatement(GET_FEEDBACK_BY_PRODUCT)) {
            ps.setLong(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Feedback feedback = new Feedback();
                    feedback.setFeedbackId(rs.getLong("feedback_id"));
                    feedback.setProductId(rs.getLong("product_id"));
                    feedback.setCustomerId(rs.getLong("customer_id"));
                    feedback.setOrderId(rs.getLong("order_id") == 0 ? null : rs.getLong("order_id"));
                    feedback.setRating(rs.getInt("rating"));
                    feedback.setComments(rs.getString("comments"));
                    feedback.setCreationDate(rs.getTimestamp("creation_date"));
                    feedback.setVisibility(rs.getString("visibility"));
                    feedback.setIsVerified(rs.getBoolean("is_verified"));
                    feedback.setReplyContent(rs.getString("reply_content"));
                    feedback.setCustomerName(rs.getString("customer_name"));
                    feedbackList.add(feedback);
                }
                LOGGER.log(Level.INFO, "Retrieved {0} feedbacks for product {1}", new Object[]{feedbackList.size(), productId});
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error retrieving feedback for product {0}: {1}", new Object[]{productId, ex.getMessage()});
            throw new SQLException("Error retrieving feedback by product ID: " + ex.getMessage(), ex);
        }
        return feedbackList;
    }

    public long getCustomerIdByUserId(long userId) throws SQLException {
        try (Connection conn = DBContext.getNewConnection();
             PreparedStatement ps = conn.prepareStatement(GET_CUSTOMER_ID_BY_USER_ID)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getLong("customer_id");
                } else {
                    throw new SQLException("No customer found for userId: " + userId);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting customerId for userId {0}: {1}", new Object[]{userId, ex.getMessage()});
            throw ex;
        }
    }

    public void closeConnection() {
        LOGGER.log(Level.INFO, "closeConnection called, no action needed with try-with-resources");
    }
}