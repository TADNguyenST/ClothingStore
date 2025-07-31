/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import model.Customer;
import model.Users;
import util.DBContext;
import util.PasswordUtil;

public class UserDAO extends DBContext {
//Login

    public Users checkLogin(String email, String password) {
        String sql = "SELECT * FROM users WHERE email = ? AND password = ? AND status = 'Active'";
        try ( Connection conn = getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {

            // Mã hóa mật khẩu trước khi kiểm tra
            String hashedPassword = PasswordUtil.hashPassword(password);

            ps.setString(1, email);
            ps.setString(2, hashedPassword);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return map(rs);                 // gom vào hàm map()
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean isEmailExists(String email) {
        String sql = "SELECT user_id FROM users WHERE email = ?";
        try ( Connection conn = getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            return rs.next();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

// Change Password
    public boolean updatePassword(long userId, String newPassword) {
        String sql = "UPDATE users SET password = ?, updated_at = GETDATE() WHERE user_id = ?";
        try ( Connection conn = getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {

            // Mã hóa mật khẩu mới trước khi lưu
            String hashedPassword = PasswordUtil.hashPassword(newPassword);

            ps.setString(1, hashedPassword);
            ps.setLong(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Dang ky
    private final DBContext dbContext = new DBContext();

    // Thêm người dùng vào bảng users và customers
    public boolean registerCustomer(Users user, Customer customer) {
        String insertUser = "INSERT INTO users (email, password, full_name, phone_number) VALUES (?, ?, ?, ?)";
        String insertCustomer = "INSERT INTO customers (user_id, birth_date, gender) VALUES (?, ?, ?)";

        try ( Connection conn = dbContext.getConnection();  PreparedStatement psUser = conn.prepareStatement(insertUser, Statement.RETURN_GENERATED_KEYS)) {

            // Mã hóa mật khẩu trước khi lưu vào DB
            String hashedPassword = PasswordUtil.hashPassword(user.getPassword());

            // Insert users
            psUser.setString(1, user.getEmail());
            psUser.setString(2, hashedPassword);
            psUser.setString(3, user.getFullName());
            psUser.setString(4, user.getPhoneNumber());
            int rows = psUser.executeUpdate();

            if (rows > 0) {
                ResultSet rs = psUser.getGeneratedKeys();
                if (rs.next()) {
                    long userId = rs.getLong(1);

                    try ( PreparedStatement psCustomer = conn.prepareStatement(insertCustomer)) {
                        psCustomer.setLong(1, userId);
                        psCustomer.setDate(2, customer.getBirthDate());
                        psCustomer.setString(3, customer.getGender());
                        return psCustomer.executeUpdate() > 0;
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Kiểm tra email đã tồn tại (đổi tên phương thức)
    public boolean checkEmailExists(String email) {
        String query = "SELECT 1 FROM users WHERE email = ?";
        try ( Connection conn = dbContext.getConnection();  PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, email);
            try ( ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    //Forgot Password 
    public Users getUserByEmail(String email) {
        String sql = "SELECT * FROM users WHERE email = ?";
        try ( Connection c = getConnection();  PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return map(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // ====== Mapping ResultSet -=> Users ======
    private Users map(ResultSet rs) throws SQLException {
        Users u = new Users();
        u.setUserId(rs.getLong("user_id"));
        u.setEmail(rs.getString("email"));
        u.setPassword(rs.getString("password"));
        u.setFullName(rs.getString("full_name"));
        u.setPhoneNumber(rs.getString("phone_number"));
        u.setStatus(rs.getString("status"));
        u.setRole(rs.getString("role"));
        u.setCreatedAt(rs.getTimestamp("created_at"));
        u.setUpdatedAt(rs.getTimestamp("updated_at"));
        return u;
    }
//Detail

    public Users getUserById(long userId) {
        String sql = "SELECT * FROM users WHERE user_id = ?";
        try ( Connection conn = getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return map(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

//Login Admin
    public Users checkAdminLogin(String email, String password) {
        String sql = "SELECT * FROM users WHERE email = ? AND password = ? AND role = 'Admin' AND status = 'Active'";
        try ( Connection conn = getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, password); // KHÔNG mã hóa password
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return map(rs); // Sử dụng phương thức map có sẵn
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
    //GoogleLogin

// Thêm người dùng bằng Google (không có mật khẩu)
    public long insertGoogleUser(String email, String fullName) {
        String sql = "INSERT INTO users (email, full_name, status, role, created_at) VALUES (?, ?, 'Active', 'Customer', GETDATE())";
        try ( Connection conn = getConnection();  PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, email);
            ps.setString(2, fullName);
            int rows = ps.executeUpdate();
            if (rows > 0) {
                ResultSet rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    return rs.getLong(1); // Trả về user_id mới được tạo
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1; // Thêm thất bại
    }

    public Users getUserByEmailGoogle(String email) {
        String sql = "SELECT * FROM users WHERE email = ? AND status = 'Active'";
        try ( Connection conn = getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return map(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
}
