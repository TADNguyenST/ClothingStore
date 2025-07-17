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
// View Profile

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
                customer.setAvatarUrl(rs.getString("avatar_url"));
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

    //Edit Profile
    public boolean updateCustomerProfile(Users user, Customer customer) {
        String updateUserSql = "UPDATE users SET full_name = ?, phone_number = ?, updated_at = GETDATE() WHERE user_id = ?";
        String updateCustomerSql = "UPDATE customers SET gender = ?, birth_date = ?, avatar_url = ? WHERE user_id = ?";
        try ( Connection conn = new DBContext().getConnection()) {
            conn.setAutoCommit(false);

            try (
                     PreparedStatement psUser = conn.prepareStatement(updateUserSql);  PreparedStatement psCustomer = conn.prepareStatement(updateCustomerSql)) {

                psUser.setString(1, user.getFullName());
                psUser.setString(2, user.getPhoneNumber());
                psUser.setLong(3, user.getUserId());
                psUser.executeUpdate();

                psCustomer.setString(1, customer.getGender());
                psCustomer.setDate(2, customer.getBirthDate());
                psCustomer.setString(3, customer.getAvatarUrl());
                psCustomer.setLong(4, customer.getUserId());
                psCustomer.executeUpdate();

                conn.commit();
                return true;
            } catch (Exception e) {
                conn.rollback();
                e.printStackTrace();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public java.util.List<Users> getAllCustomersWithUserDetails() {
        java.util.List<Users> customers = new java.util.ArrayList<>();
        String sql = "SELECT u.user_id, u.email, u.full_name, u.phone_number, c.customer_id " +
                     "FROM users u JOIN customers c ON u.user_id = c.user_id";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Users user = new Users();
                user.setUserId(rs.getLong("user_id"));
                user.setEmail(rs.getString("email"));
                user.setFullName(rs.getString("full_name"));
                user.setPhoneNumber(rs.getString("phone_number"));
                // You might want to set customer_id in the Users object if needed, or create a custom DTO
                customers.add(user);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return customers;
    }
//Login with Google
}

