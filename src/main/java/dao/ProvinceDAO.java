package dao;

import model.Province;
import util.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ProvinceDAO {

    public List<Province> getAllProvinces() {
        List<Province> list = new ArrayList<>();
        String sql = "SELECT province_id, name, code FROM provinces ORDER BY name";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql);  ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Province p = new Province();
                p.setProvinceId(rs.getLong("province_id"));
                p.setName(rs.getString("name"));
                p.setCode(rs.getString("code"));
                list.add(p);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Tìm theo mã code (API v2 dùng chuỗi)
     */
    public Province findByCode(String code) {
        if (code == null || code.trim().isEmpty()) {
            return null;
        }
        String sql = "SELECT province_id, name, code FROM provinces WHERE code = ?";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code);
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Province p = new Province();
                    p.setProvinceId(rs.getLong("province_id"));
                    p.setName(rs.getString("name"));
                    p.setCode(rs.getString("code"));
                    return p;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Thêm nếu chưa có (dựa trên code)
     */
    public long insertIfNotExists(Province p) throws SQLException {
        if (p == null || p.getCode() == null) {
            throw new SQLException("Province code is required");
        }
        String check = "SELECT province_id FROM provinces WHERE code = ?";
        String insert = "INSERT INTO provinces (name, code) VALUES (?, ?)";
        try ( Connection conn = DBContext.getNewConnection()) {
            try ( PreparedStatement ps = conn.prepareStatement(check)) {
                ps.setString(1, p.getCode());
                try ( ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return rs.getLong(1);
                    }
                }
            }
            try ( PreparedStatement ps = conn.prepareStatement(insert, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, p.getName());
                ps.setString(2, p.getCode());
                ps.executeUpdate();
                try ( ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getLong(1);
                    }
                }
            }
        }
        throw new SQLException("insertIfNotExists(province) failed");
    }

    /**
     * Cập nhật tên theo code (đồng bộ khi API đổi tên)
     */
    public boolean updateNameByCode(String code, String newName) {
        String sql = "UPDATE provinces SET name = ? WHERE code = ?";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newName);
            ps.setString(2, code);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    // Upsert hàng loạt theo code, chạy trong 1 transaction
// ProvinceDAO.java

    public void save(List<Province> provinces) {
        if (provinces == null || provinces.isEmpty()) {
            return;
        }

        final String UPSERT
                = "UPDATE provinces SET name = ? WHERE code = ?; "
                + "IF @@ROWCOUNT = 0 "
                + "INSERT INTO provinces (name, code) VALUES (?, ?);";

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBContext.getNewConnection();
            conn.setAutoCommit(false);

            ps = conn.prepareStatement(UPSERT);

            // Dedup code ở tầng ứng dụng để tránh add 2 lần cùng code trong 1 call
            java.util.HashSet<String> seen = new java.util.HashSet<>();

            for (Province p : provinces) {
                if (p == null) {
                    continue;
                }
                String code = (p.getCode() == null) ? null : p.getCode().trim();
                if (code == null || code.isEmpty()) {
                    continue;
                }
                if (!seen.add(code)) {
                    continue; // bỏ qua code trùng trong input
                }
                ps.setString(1, p.getName());
                ps.setString(2, code);
                ps.setString(3, p.getName());
                ps.setString(4, code);
                ps.addBatch();
            }

            ps.executeBatch();
            conn.commit();
        } catch (SQLException e) {
            if (conn != null) try {
                conn.rollback();
            } catch (SQLException ignore) {
            }
            e.printStackTrace();
        } finally {
            if (ps != null) try {
                ps.close();
            } catch (SQLException ignore) {
            }
            if (conn != null) try {
                conn.close();
            } catch (SQLException ignore) {
            }
        }
    }

}
