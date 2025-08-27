/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import model.OrderHistory;
import util.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OrderHistoryDAO {

    public List<OrderHistory> getOrderHistoryByUserId(long userId) {
        List<OrderHistory> list = new ArrayList<>();
        String sql = "SELECT " +
                "    u.user_id, c.customer_id, o.order_id, p.product_id, pv.variant_id, " +
                "    oi.order_item_id, u.full_name AS user_name, u.email, o.order_date, " +
                "    o.total_price, o.status AS order_status, o.payment_status, " +
                "    v.code AS voucher_code, p.name AS product_name, pv.size, pv.color " +
                "FROM customers c " +
                "JOIN users u ON c.user_id = u.user_id " +
                "LEFT JOIN orders o ON c.customer_id = o.customer_id " +
                "LEFT JOIN vouchers v ON o.voucher_id = v.voucher_id " +
                "LEFT JOIN order_items oi ON o.order_id = oi.order_id " +
                "LEFT JOIN product_variants pv ON oi.variant_id = pv.variant_id " +
                "LEFT JOIN products p ON pv.product_id = p.product_id " +
                "WHERE u.user_id = ? " +
                "ORDER BY o.order_date DESC";

        try (Connection con = DBContext.getNewConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setLong(1, userId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                OrderHistory oh = new OrderHistory();
                oh.setUserId(rs.getLong("user_id"));
                oh.setCustomerId(rs.getLong("customer_id"));
                oh.setOrderId(rs.getLong("order_id"));
                oh.setProductId(rs.getLong("product_id"));
                oh.setVariantId(rs.getLong("variant_id"));
                oh.setOrderItemId(rs.getLong("order_item_id"));
                oh.setUserName(rs.getString("user_name"));
                oh.setEmail(rs.getString("email"));
                oh.setOrderDate(rs.getTimestamp("order_date"));
                oh.setTotalPrice(rs.getBigDecimal("total_price"));
                oh.setOrderStatus(rs.getString("order_status"));
                oh.setPaymentStatus(rs.getString("payment_status"));
                oh.setVoucherCode(rs.getString("voucher_code"));
                oh.setProductName(rs.getString("product_name"));
                oh.setSize(rs.getString("size"));
                oh.setColor(rs.getString("color"));
                list.add(oh);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}

