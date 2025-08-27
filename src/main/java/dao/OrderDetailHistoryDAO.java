/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import model.OrderDetailHistory;
import util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class OrderDetailHistoryDAO {

    public List<OrderDetailHistory> getOrderDetailsByOrderId(int orderId) {
        List<OrderDetailHistory> list = new ArrayList<>();

        String sql = "SELECT c.customer_id, o.order_id, p.name AS product_name, "
                + "pv.size, pv.color, oi.quantity, oi.price_at_purchase, oi.total_price, "
                + "o.status AS order_status, o.payment_status, v.code AS voucher_code, v.name AS voucher_name, o.order_date "
                + "FROM orders o "
                + "JOIN customers c ON o.customer_id = c.customer_id "
                + "JOIN order_items oi ON o.order_id = oi.order_id "
                + "JOIN product_variants pv ON oi.variant_id = pv.variant_id "
                + "JOIN products p ON pv.product_id = p.product_id "
                + "LEFT JOIN vouchers v ON o.voucher_id = v.voucher_id "
                + "WHERE o.order_id = ? "
                + "ORDER BY o.order_date DESC";

        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                OrderDetailHistory detail = new OrderDetailHistory();
                detail.setCustomerId(rs.getInt("customer_id"));
                detail.setOrderId(rs.getInt("order_id"));
                detail.setProductName(rs.getString("product_name"));
                detail.setSize(rs.getString("size"));
                detail.setColor(rs.getString("color"));
                detail.setQuantity(rs.getInt("quantity"));
                detail.setPriceAtPurchase(rs.getDouble("price_at_purchase"));
                detail.setTotalPrice(rs.getDouble("total_price"));
                detail.setOrderStatus(rs.getString("order_status"));
                detail.setPaymentStatus(rs.getString("payment_status"));
                detail.setVoucherCode(rs.getString("voucher_code"));
                detail.setVoucherName(rs.getString("voucher_name"));
                detail.setOrderDate(rs.getTimestamp("order_date"));

                list.add(detail);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
