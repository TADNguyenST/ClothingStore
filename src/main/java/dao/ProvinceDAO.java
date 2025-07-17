package dao;

import model.Province;
import util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class ProvinceDAO extends DBContext {

    public List<Province> getAllProvinces() {
        List<Province> provinces = new ArrayList<>();
        String sql = "SELECT province_id, name, code FROM provinces ORDER BY name ASC";

        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql);  ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Province province = new Province();
                province.setProvinceId(rs.getLong("province_id"));
                province.setName(rs.getString("name"));
                province.setCode(rs.getString("code"));
                provinces.add(province);
            }
        } catch (SQLException e) {
            Logger.getLogger(ProvinceDAO.class.getName()).log(Level.SEVERE, "Error fetching all provinces", e);
        }
        return provinces;
    }

    public void save(List<Province> provinces) {
        String sql = "INSERT INTO provinces (name, code) VALUES (?, ?)";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            for (Province p : provinces) {
                ps.setString(1, p.getName());
                ps.setString(2, p.getCode());
                ps.addBatch();
            }
            ps.executeBatch();
        } catch (SQLException e) {
            Logger.getLogger(ProvinceDAO.class.getName()).log(Level.SEVERE, "Error saving provinces", e);
        }
    }

    public Province findByCode(String code) {
        String sql = "SELECT province_id, name, code FROM provinces WHERE code = ?";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code);
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Province province = new Province();
                    province.setProvinceId(rs.getLong("province_id"));
                    province.setName(rs.getString("name"));
                    province.setCode(rs.getString("code"));
                    return province;
                }
            }
        } catch (SQLException e) {
            Logger.getLogger(ProvinceDAO.class.getName()).log(Level.SEVERE, "Error finding province by code", e);
        }
        return null;
    }
}
