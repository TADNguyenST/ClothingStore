/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import util.DBContext;
import model.Customer;
import model.Users;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

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
        String sql = "SELECT u.user_id, u.email, u.full_name, u.phone_number, c.customer_id "
                + "FROM users u JOIN customers c ON u.user_id = c.user_id";
        try ( Connection conn = new DBContext().getConnection();  PreparedStatement ps = conn.prepareStatement(sql);  ResultSet rs = ps.executeQuery()) {
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
//List

    public static class CustomerInfo {

        private Users user;
        private Customer customer;
        private long customerId;

        public CustomerInfo(Users user, Customer customer, long customerId) {
            this.user = user;
            this.customer = customer;
            this.customerId = customerId;
        }

        public Users getUser() {
            return user;
        }

        public Customer getCustomer() {
            return customer;
        }

        public long getCustomerId() {
            return customerId;
        }
    }

    public List<CustomerInfo> getAllCustomers() {
        List<CustomerInfo> list = new ArrayList<>();
        String sql = "SELECT u.*, c.* FROM users u JOIN customers c ON u.user_id = c.user_id WHERE u.role = 'Customer'";

        try ( PreparedStatement ps = getConnection().prepareStatement(sql);  ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Users user = new Users(
                        rs.getLong("user_id"),
                        rs.getString("email"),
                        rs.getString("password"),
                        rs.getString("full_name"),
                        rs.getString("phone_number"),
                        rs.getString("status"),
                        rs.getString("role"),
                        rs.getTimestamp("created_at"),
                        rs.getTimestamp("updated_at")
                );

                Customer customer = new Customer();
                customer.setCustomerId(rs.getLong("customer_id"));
                customer.setUserId(rs.getLong("user_id"));
                customer.setLoyaltyPoints(rs.getInt("loyalty_points"));
                customer.setBirthDate(rs.getDate("birth_date"));
                customer.setGender(rs.getString("gender"));
                customer.setAvatarUrl(rs.getString("avatar_url"));

                list.add(new CustomerInfo(user, customer, customer.getCustomerId()));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // Hàm bổ sung để tránh lỗi thiếu getConnection()
    private Connection getConnection() throws SQLException {
        return new DBContext().getConnection();
    }

    public List<CustomerInfo> searchCustomerByKeyword(String keyword) {
        List<CustomerInfo> list = new ArrayList<>();
        String sql = "SELECT u.*, c.* FROM users u JOIN customers c ON u.user_id = c.user_id "
                + "WHERE u.role = 'Customer' AND (u.full_name LIKE ? OR u.email LIKE ?)";
        try ( PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setString(1, "%" + keyword + "%");
            ps.setString(2, "%" + keyword + "%");
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Users user = new Users(
                        rs.getLong("user_id"),
                        rs.getString("email"),
                        rs.getString("password"),
                        rs.getString("full_name"),
                        rs.getString("phone_number"),
                        rs.getString("status"),
                        rs.getString("role"),
                        rs.getTimestamp("created_at"),
                        rs.getTimestamp("updated_at")
                );
                Customer customer = new Customer();
                customer.setCustomerId(rs.getLong("customer_id"));
                customer.setUserId(rs.getLong("user_id"));
                customer.setLoyaltyPoints(rs.getInt("loyalty_points"));
                customer.setBirthDate(rs.getDate("birth_date"));
                customer.setGender(rs.getString("gender"));
                customer.setAvatarUrl(rs.getString("avatar_url"));
                list.add(new CustomerInfo(user, customer, customer.getCustomerId()));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
    //Detail

    public CustomerInfo getCustomerInfoByUserId(long userId) {
        String sql = "SELECT u.*, c.* FROM users u JOIN customers c ON u.user_id = c.user_id WHERE u.user_id = ?";
        try ( PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setLong(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Users user = new Users(
                        rs.getLong("user_id"),
                        rs.getString("email"),
                        rs.getString("password"),
                        rs.getString("full_name"),
                        rs.getString("phone_number"),
                        rs.getString("status"),
                        rs.getString("role"),
                        rs.getTimestamp("created_at"),
                        rs.getTimestamp("updated_at")
                );

                Customer customer = new Customer();
                customer.setCustomerId(rs.getLong("customer_id"));
                customer.setUserId(rs.getLong("user_id"));
                customer.setLoyaltyPoints(rs.getInt("loyalty_points"));
                customer.setBirthDate(rs.getDate("birth_date"));
                customer.setGender(rs.getString("gender"));
                customer.setAvatarUrl(rs.getString("avatar_url"));
                customer.setCreatedAt(rs.getTimestamp("created_at"));

                return new CustomerInfo(user, customer, customer.getCustomerId());
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    //History Order

    public int getCustomerIdByUserId(long userId) {
        String sql = "SELECT customer_id FROM customers WHERE user_id = ?";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("customer_id");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1; // không tìm thấy
    }
}
