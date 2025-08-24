/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import util.DBContext;
import model.Order;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class OrderDAO {
//ViewCustomerOrderHistory
    // Lấy tất cả đơn hàng theo customer_id (không chọn 4 cột bạn không muốn hiển thị)
    private static final String SELECT_BY_CUSTOMER =
            "SELECT order_id, customer_id, order_date, shipping_address_id, voucher_id, " +
            "subtotal, discount_amount, shipping_fee, total_price, status, payment_status, notes " +
            "FROM orders WHERE customer_id = ? ORDER BY order_date DESC";

    // Lấy 1 đơn theo order_id (nếu cần dùng chỗ khác)
    private static final String SELECT_BY_ID =
            "SELECT order_id, customer_id, order_date, shipping_address_id, voucher_id, " +
            "subtotal, discount_amount, shipping_fee, total_price, status, payment_status, notes " +
            "FROM orders WHERE order_id = ?";

    public List<Order> getOrdersByCustomerId(long customerId) {
        List<Order> orders = new ArrayList<>();

        try (Connection conn = DBContext.getNewConnection();
             PreparedStatement ps = conn.prepareStatement(SELECT_BY_CUSTOMER)) {

            ps.setLong(1, customerId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    orders.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace(); // có thể log thay vì printStackTrace
        }
        return orders;
    }

    public Order getOrderById(long orderId) {
        try (Connection conn = DBContext.getNewConnection();
             PreparedStatement ps = conn.prepareStatement(SELECT_BY_ID)) {

            ps.setLong(1, orderId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // Map ResultSet -> Order (khớp model; map order_date -> createdAt)
    private Order mapRow(ResultSet rs) throws SQLException {
        Order o = new Order();
        o.setOrderId(rs.getLong("order_id"));
        o.setCustomerId(rs.getLong("customer_id"));

        // model không có orderDate -> dùng createdAt để hiển thị Order Date
        o.setCreatedAt(rs.getTimestamp("order_date"));

        o.setShippingAddressId(rs.getLong("shipping_address_id"));

        Object vObj = rs.getObject("voucher_id");
        o.setVoucherId(vObj != null ? rs.getLong("voucher_id") : null);

        o.setSubtotal(rs.getBigDecimal("subtotal"));
        o.setDiscountAmount(rs.getBigDecimal("discount_amount"));
        o.setShippingFee(rs.getBigDecimal("shipping_fee"));
        o.setTotalPrice(rs.getBigDecimal("total_price"));
        o.setStatus(rs.getString("status"));
        o.setPaymentStatus(rs.getString("payment_status"));
        o.setNotes(rs.getString("notes"));

        // các trường estimatedDeliveryDate, actualDeliveryDate, updatedAt không cần map ở đây
        // vì yêu cầu không hiển thị (có thể bổ sung nếu bạn cần dùng ở chỗ khác)

        return o;
    }
}

