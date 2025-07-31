/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import model.Users;
import model.Staff;
import util.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import util.PasswordUtil;

/**
 *
 * @author Khoa
 */
public class StaffDAO extends DBContext {
//  View list

    public static class StaffInfo {

        private Users user;
        private Staff staff;
        private long staffId; // Thêm field staffId

        public StaffInfo(Users user, Staff staff, long staffId) {
            this.user = user;
            this.staff = staff;
            this.staffId = staffId;
        }

        public Users getUser() {
            return user;
        }

        public Staff getStaff() {
            return staff;
        }

        public long getStaffId() {
            return staffId;
        }
    }

    public List<StaffInfo> getAllStaff() {
        List<StaffInfo> list = new ArrayList<>();
        String sql = "SELECT u.*, s.* FROM users u JOIN staff s ON u.user_id = s.user_id WHERE u.role = 'Staff'";

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

                Staff staff = new Staff();
                staff.setStaffId(rs.getLong("staff_id"));
                staff.setUserId(rs.getLong("user_id"));
                staff.setPosition(rs.getString("position"));
                staff.setNotes(rs.getString("notes"));

                long staffId = rs.getLong("staff_id");

                list.add(new StaffInfo(user, staff, staffId));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }
    //Detail

    public StaffInfo getStaffInfoByUserId(long userId) {
        String sql = "SELECT u.*, s.* FROM users u JOIN staff s ON u.user_id = s.user_id WHERE u.user_id = ?";
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

                Staff staff = new Staff();
                staff.setStaffId(rs.getLong("staff_id"));
                staff.setUserId(rs.getLong("user_id"));
                staff.setPosition(rs.getString("position"));
                staff.setNotes(rs.getString("notes"));
                staff.setCreatedAt(rs.getTimestamp("created_at"));

                return new StaffInfo(user, staff, staff.getStaffId());
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    // Create Account

    public boolean createStaffAccount(Users user, Staff staff) {
        String userSql = "INSERT INTO users (email, password, full_name, phone_number, role, status, created_at) "
                + "VALUES (?, ?, ?, ?, 'Staff', 'Active', GETDATE())";
        String staffSql = "INSERT INTO staff (user_id, position, notes, created_at) VALUES (?, ?, ?, GETDATE())";

        try ( Connection conn = getConnection()) {
            conn.setAutoCommit(false);

            try ( PreparedStatement psUser = conn.prepareStatement(userSql, Statement.RETURN_GENERATED_KEYS)) {
                String hashedPassword = PasswordUtil.hashPassword(user.getPassword());

                psUser.setString(1, user.getEmail());
                psUser.setString(2, hashedPassword);
                psUser.setString(3, user.getFullName());
                psUser.setString(4, user.getPhoneNumber());

                int rows = psUser.executeUpdate();
                if (rows == 0) {
                    conn.rollback();
                    return false;
                }

                ResultSet generatedKeys = psUser.getGeneratedKeys();
                if (generatedKeys.next()) {
                    long userId = generatedKeys.getLong(1);
                    try ( PreparedStatement psStaff = conn.prepareStatement(staffSql)) {
                        psStaff.setLong(1, userId);
                        psStaff.setString(2, staff.getPosition());
                        psStaff.setString(3, staff.getNotes());

                        if (psStaff.executeUpdate() > 0) {
                            conn.commit();
                            return true;
                        }
                    }
                }
                conn.rollback();
            } catch (SQLException ex) {
                conn.rollback();
                ex.printStackTrace();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    // Check if email already exists
    public boolean isEmailExists(String email) {
        String sql = "SELECT COUNT(*) FROM users WHERE email = ?";
        try ( PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    // Search

    public List<StaffInfo> searchStaffByKeyword(String keyword) {
        List<StaffInfo> list = new ArrayList<>();
        String sql = "SELECT u.*, s.* FROM users u "
                + "JOIN staff s ON u.user_id = s.user_id "
                + "WHERE u.role = 'Staff' AND (u.full_name LIKE ? OR u.email LIKE ?)";

        try ( PreparedStatement ps = getConnection().prepareStatement(sql)) {
            String likeKeyword = "%" + keyword + "%";
            ps.setString(1, likeKeyword);
            ps.setString(2, likeKeyword);
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

                Staff staff = new Staff();
                staff.setStaffId(rs.getLong("staff_id"));
                staff.setUserId(rs.getLong("user_id"));
                staff.setPosition(rs.getString("position"));
                staff.setNotes(rs.getString("notes"));

                long staffId = rs.getLong("staff_id");
                list.add(new StaffInfo(user, staff, staffId));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }
    // Edit Staff

    public boolean updateStaff(long userId, String fullName, String phoneNumber, String status, String position, String notes) {
        String userSql = "UPDATE users SET full_name = ?, phone_number = ?, status = ?, updated_at = GETDATE() WHERE user_id = ?";
        String staffSql = "UPDATE staff SET position = ?, notes = ? WHERE user_id = ?";
        try ( Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            try ( PreparedStatement psUser = conn.prepareStatement(userSql);  PreparedStatement psStaff = conn.prepareStatement(staffSql)) {
                psUser.setString(1, fullName);
                psUser.setString(2, phoneNumber);
                psUser.setString(3, status);
                psUser.setLong(4, userId);
                psStaff.setString(1, position);
                psStaff.setString(2, notes);
                psStaff.setLong(3, userId);
                int rowsUser = psUser.executeUpdate();
                int rowsStaff = psStaff.executeUpdate();
                if (rowsUser > 0 && rowsStaff > 0) {
                    conn.commit();
                    return true;
                } else {
                    conn.rollback();
                }
            } catch (SQLException ex) {
                conn.rollback();
                ex.printStackTrace();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Delete
    public boolean deleteStaffByUserId(long userId) {
        String deleteStaffSQL = "DELETE FROM staff WHERE user_id = ?";
        String deleteUserSQL = "DELETE FROM users WHERE user_id = ?";

        try ( Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            try (
                     PreparedStatement ps1 = conn.prepareStatement(deleteStaffSQL);  PreparedStatement ps2 = conn.prepareStatement(deleteUserSQL)) {
                ps1.setLong(1, userId);
                ps1.executeUpdate();

                ps2.setLong(1, userId);
                int affectedRows = ps2.executeUpdate();

                conn.commit();
                return affectedRows > 0;
            } catch (Exception ex) {
                conn.rollback();
                ex.printStackTrace();
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return false;
    }
    //StaffLogin

    public Users loginStaff(String email, String password) {
        String sql = "SELECT * FROM users WHERE email = ? AND role = 'Staff' AND status = 'Active'";
        try ( PreparedStatement ps = getConnection().prepareStatement(sql)) {
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                String hashedPassword = rs.getString("password");
                if (PasswordUtil.verifyPassword(password, hashedPassword)) { // dùng đúng hàm verifyPassword
                    return new Users(
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
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
}
