package dao;

import model.Order;
import model.OrderItem;
import model.Feedback;
import util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class OrderDAO {

    private static final String GET_ORDERS_FOR_FEEDBACK =
        "SELECT o.order_id, o.customer_id, o.order_date, o.total_price, o.status " +
        "FROM orders o " +
        "WHERE o.customer_id = ? AND o.status = 'PENDING' " +
        "AND NOT EXISTS (SELECT 1 FROM feedbacks f WHERE f.order_id = o.order_id)";

    private static final String GET_ORDERS_WITH_FEEDBACK =
        "SELECT o.order_id, o.customer_id, o.order_date, o.total_price, o.status " +
        "FROM orders o " +
        "WHERE o.customer_id = ? " +
        "AND EXISTS (SELECT 1 FROM feedbacks f WHERE f.order_id = o.order_id AND f.customer_id = o.customer_id)";

    private static final String GET_ORDER_ITEMS =
        "SELECT oi.order_item_id, oi.quantity, p.name AS product_name, pv.size, pv.color, p.product_id " +
        "FROM order_items oi " +
        "JOIN product_variants pv ON oi.variant_id = pv.variant_id " +
        "JOIN products p ON pv.product_id = p.product_id " +
        "WHERE oi.order_id = ?";

    private static final String GET_FEEDBACKS_FOR_ORDER_ITEM =
        "SELECT f.feedback_id, f.product_id, f.customer_id, f.order_id, f.rating, f.comments, f.creation_date, f.visibility, f.is_verified, " +
        "fr.content AS reply_content " +
        "FROM feedbacks f " +
        "LEFT JOIN feedback_replies fr ON f.feedback_id = fr.feedback_id " +
        "WHERE f.order_id = ? AND f.product_id = ? AND f.customer_id = ?";

    public List<Order> getOrdersForFeedback(long customerId) throws SQLException {
        List<Order> orders = new ArrayList<>();
        try (Connection conn = DBContext.getNewConnection();
             PreparedStatement ps = conn.prepareStatement(GET_ORDERS_FOR_FEEDBACK)) {
            ps.setLong(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order order = new Order();
                    order.setOrderId(rs.getLong("order_id"));
                    order.setCustomerId(rs.getLong("customer_id"));
                    order.setOrderDate(new java.sql.Date(rs.getTimestamp("order_date").getTime()));
                    order.setTotalPrice(rs.getDouble("total_price"));
                    order.setStatus(rs.getString("status"));
                    order.setOrderItems(getOrderItems(order.getOrderId(), customerId));
                    orders.add(order);
                }
            }
        } catch (SQLException ex) {
            throw new SQLException("Error getting orders for feedback: " + ex.getMessage(), ex);
        }
        return orders;
    }

    public List<Order> getOrdersWithFeedback(long customerId) throws SQLException {
        List<Order> orders = new ArrayList<>();
        try (Connection conn = DBContext.getNewConnection();
             PreparedStatement ps = conn.prepareStatement(GET_ORDERS_WITH_FEEDBACK)) {
            ps.setLong(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order order = new Order();
                    order.setOrderId(rs.getLong("order_id"));
                    order.setCustomerId(rs.getLong("customer_id"));
                    order.setOrderDate(new java.sql.Date(rs.getTimestamp("order_date").getTime()));
                    order.setTotalPrice(rs.getDouble("total_price"));
                    order.setStatus(rs.getString("status"));
                    order.setOrderItems(getOrderItems(order.getOrderId(), customerId));
                    orders.add(order);
                }
            }
        } catch (SQLException ex) {
            throw new SQLException("Error getting orders with feedback: " + ex.getMessage(), ex);
        }
        return orders;
    }

    private List<OrderItem> getOrderItems(long orderId, long customerId) throws SQLException {
        List<OrderItem> items = new ArrayList<>();
        try (Connection conn = DBContext.getNewConnection();
             PreparedStatement ps = conn.prepareStatement(GET_ORDER_ITEMS)) {
            ps.setLong(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrderItem item = new OrderItem();
                    item.setOrderItemId(rs.getLong("order_item_id"));
                    item.setQuantity(rs.getInt("quantity"));
                    item.setProductName(rs.getString("product_name"));
                    item.setSize(rs.getString("size"));
                    item.setColor(rs.getString("color"));
                    item.setProductId(rs.getLong("product_id"));
                    item.setFeedbacks(getFeedbacksForOrderItem(orderId, item.getProductId(), customerId));
                    items.add(item);
                }
            }
        } catch (SQLException ex) {
            throw new SQLException("Error getting order items: " + ex.getMessage(), ex);
        }
        return items;
    }

    private List<Feedback> getFeedbacksForOrderItem(long orderId, long productId, long customerId) throws SQLException {
        List<Feedback> feedbacks = new ArrayList<>();
        try (Connection conn = DBContext.getNewConnection();
             PreparedStatement ps = conn.prepareStatement(GET_FEEDBACKS_FOR_ORDER_ITEM)) {
            ps.setLong(1, orderId);
            ps.setLong(2, productId);
            ps.setLong(3, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Feedback feedback = new Feedback();
                    feedback.setFeedbackId(rs.getLong("feedback_id"));
                    feedback.setProductId(rs.getLong("product_id"));
                    feedback.setCustomerId(rs.getLong("customer_id"));
                    feedback.setOrderId(rs.getLong("order_id"));
                    feedback.setRating(rs.getInt("rating"));
                    feedback.setComments(rs.getString("comments"));
                    feedback.setCreationDate(rs.getTimestamp("creation_date"));
                    feedback.setVisibility(rs.getString("visibility"));
                    feedback.setIsVerified(rs.getBoolean("is_verified"));
                    feedback.setReplyContent(rs.getString("reply_content"));
                    feedbacks.add(feedback);
                }
            }
        } catch (SQLException ex) {
            throw new SQLException("Error getting feedbacks for order item: " + ex.getMessage(), ex);
        }
        return feedbacks;
    }
}