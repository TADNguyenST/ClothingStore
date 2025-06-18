/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import util.DBContext;
import model.Customer;
import model.Users;
import java.sql.*;

/**
 *
 * @author Khoa
 */
public class CustomerDAO {
//View Profile

    public Customer getCustomerByUserId(long userId) {
        String sql = "SELECT * FROM customers WHERE user_id = ?";
        try ( Connection conn = new DBContext().getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, userId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                Customer customer = new Customer();
                customer.setCustomerId(rs.getLong("customer_id"));
                customer.setUserId(rs.getLong("user_id"));
                customer.setLoyaltyPoints(rs.getInt("loyalty_points"));
                customer.setBirthDate(rs.getDate("birth_date"));
                customer.setGender(rs.getString("gender"));
                customer.setCreatedAt(rs.getTimestamp("created_at"));
                return customer;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public Users getUserById(long userId) {
        String sql = "SELECT * FROM users WHERE user_id = ?";
        try ( Connection conn = new DBContext().getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, userId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                Users user = new Users();
                user.setUserId(rs.getLong("user_id"));
                user.setEmail(rs.getString("email"));
                user.setPassword(rs.getString("password"));
                user.setFullName(rs.getString("full_name"));
                user.setPhoneNumber(rs.getString("phone_number"));
                user.setStatus(rs.getString("status"));
                user.setRole(rs.getString("role"));
                user.setCreatedAt(rs.getTimestamp("created_at"));
                user.setUpdatedAt(rs.getTimestamp("updated_at"));
                return user;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
