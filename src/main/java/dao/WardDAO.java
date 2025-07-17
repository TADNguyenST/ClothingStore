package dao;

import model.Ward;
import util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class WardDAO extends DBContext {

    public List<Ward> getWardsByDistrictId(long districtId) {
        List<Ward> wards = new ArrayList<>();
        String sql = "SELECT ward_id, district_id, name, code FROM wards WHERE district_id = ? ORDER BY name ASC";

        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, districtId);
            try ( ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Ward ward = new Ward();
                    ward.setWardId(rs.getLong("ward_id"));
                    ward.setDistrictId(rs.getLong("district_id"));
                    ward.setName(rs.getString("name"));
                    ward.setCode(rs.getString("code"));
                    wards.add(ward);
                }
            }
        } catch (SQLException e) {
            Logger.getLogger(WardDAO.class.getName()).log(Level.SEVERE, "Error fetching wards by district ID", e);
        }
        return wards;
    }

    public void save(List<Ward> wards, long districtId) {
        String sql = "INSERT INTO wards (name, code, district_id) VALUES (?, ?, ?)";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            for (Ward w : wards) {
                ps.setString(1, w.getName());
                ps.setString(2, w.getCode());
                ps.setLong(3, districtId);
                ps.addBatch();
            }
            ps.executeBatch();
        } catch (SQLException e) {
            Logger.getLogger(WardDAO.class.getName()).log(Level.SEVERE, "Error saving wards", e);
        }
    }

    public Ward findByCode(String code) {
        String sql = "SELECT ward_id, district_id, name, code FROM wards WHERE code = ?";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code);
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Ward ward = new Ward();
                    ward.setWardId(rs.getLong("ward_id"));
                    ward.setDistrictId(rs.getLong("district_id"));
                    ward.setName(rs.getString("name"));
                    ward.setCode(rs.getString("code"));
                    return ward;
                }
            }
        } catch (SQLException e) {
            Logger.getLogger(WardDAO.class.getName()).log(Level.SEVERE, "Error finding ward by code", e);
        }
        return null;
    }
}
