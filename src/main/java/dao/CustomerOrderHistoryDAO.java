/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import model.CustomerOrderHistory;
import util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class CustomerOrderHistoryDAO {

    public List<CustomerOrderHistory> getOrderHistoryByCustomerId(int customerId) {
        List<CustomerOrderHistory> list = new ArrayList<>();

        String sql = "SELECT "
                   + " o.order_id, "
                   + " o.customer_id, "
                   + " SUM(oi.quantity * oi.price_at_purchase) AS total_amount, "
                   + " v.code AS voucher_code, "
                   + " o.order_date "
                   + "FROM orders o "
                   + "JOIN order_items oi ON o.order_id = oi.order_id "
                   + "LEFT JOIN vouchers v ON o.voucher_id = v.voucher_id "
                   + "WHERE o.customer_id = ? "
                   + "GROUP BY o.order_id, o.customer_id, v.code, o.order_date "
                   + "ORDER BY o.order_date DESC";

        try (Connection conn = DBContext.getNewConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, customerId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                CustomerOrderHistory history = new CustomerOrderHistory();
                history.setOrderId(rs.getInt("order_id"));
                history.setCustomerId(rs.getInt("customer_id"));
                history.setTotalAmount(rs.getDouble("total_amount"));
                history.setVoucherCode(rs.getString("voucher_code"));
                history.setOrderDate(rs.getTimestamp("order_date"));
                list.add(history);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}


