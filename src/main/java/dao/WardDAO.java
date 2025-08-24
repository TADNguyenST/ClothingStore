package dao;

import model.Ward;
import util.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class WardDAO {

    /**
     * Lấy danh sách phường theo provinceId (mô hình 2 cấp)
     */
    public List<Ward> getWardsByProvinceId(long provinceId) {
        List<Ward> list = new ArrayList<>();
        String sql = "SELECT ward_id, name, code, province_id FROM wards WHERE province_id = ? ORDER BY name";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, provinceId);
            try ( ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Ward w = new Ward();
                    w.setWardId(rs.getLong("ward_id"));
                    w.setName(rs.getString("name"));
                    w.setCode(rs.getString("code"));
                    w.setProvinceId(rs.getLong("province_id"));
                    list.add(w);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Tìm phường theo code (API v2 dùng chuỗi)
     */
    public Ward findByCode(String code) {
        if (code == null || code.trim().isEmpty()) {
            return null;
        }
        String sql = "SELECT ward_id, name, code, province_id FROM wards WHERE code = ?";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code);
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Ward w = new Ward();
                    w.setWardId(rs.getLong("ward_id"));
                    w.setName(rs.getString("name"));
                    w.setCode(rs.getString("code"));
                    w.setProvinceId(rs.getLong("province_id"));
                    return w;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Thêm/cập nhật theo code (để seed dữ liệu từ API)
     */
    public long upsertByCode(Ward w) throws SQLException {
        if (w == null || w.getCode() == null) {
            throw new SQLException("Ward code is required");
        }
        String get = "SELECT ward_id FROM wards WHERE code = ?";
        String ins = "INSERT INTO wards (name, code, province_id) VALUES (?, ?, ?)";
        String upd = "UPDATE wards SET name = ?, province_id = ? WHERE code = ?";
        try ( Connection conn = DBContext.getNewConnection()) {
            try ( PreparedStatement ps = conn.prepareStatement(get)) {
                ps.setString(1, w.getCode());
                try ( ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        try ( PreparedStatement up = conn.prepareStatement(upd)) {
                            up.setString(1, w.getName());
                            up.setLong(2, w.getProvinceId());
                            up.setString(3, w.getCode());
                            up.executeUpdate();
                        }
                        return rs.getLong(1);
                    }
                }
            }
            try ( PreparedStatement ps = conn.prepareStatement(ins, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, w.getName());
                ps.setString(2, w.getCode());
                ps.setLong(3, w.getProvinceId());
                ps.executeUpdate();
                try ( ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getLong(1);
                    }
                }
            }
        }
        throw new SQLException("upsertByCode(ward) failed");
    }

    // Upsert wards theo code, gắn cứng provinceId truyền vào (mô hình 2 cấp)
    public void save(List<Ward> wards, long provinceId) {
        if (wards == null || wards.isEmpty()) {
            return;
        }

        final String UPSERT
                = "UPDATE wards SET name = ?, province_id = ? WHERE code = ?; "
                + "IF @@ROWCOUNT = 0 "
                + "INSERT INTO wards (name, code, province_id) VALUES (?, ?, ?);";

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBContext.getNewConnection();
            conn.setAutoCommit(false);

            ps = conn.prepareStatement(UPSERT);

            java.util.HashSet<String> seen = new java.util.HashSet<>();

            for (Ward w : wards) {
                if (w == null) {
                    continue;
                }
                String code = (w.getCode() == null) ? null : w.getCode().trim();
                if (code == null || code.isEmpty()) {
                    continue;
                }
                if (!seen.add(code)) {
                    continue; // bỏ code trùng trong 1 lần gọi
                }
                ps.setString(1, w.getName());
                ps.setLong(2, provinceId);
                ps.setString(3, code);
                ps.setString(4, w.getName());
                ps.setString(5, code);
                ps.setLong(6, provinceId);
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
