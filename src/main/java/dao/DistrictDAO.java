package dao;

import model.District;
import util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class DistrictDAO extends DBContext {

    /**
     * Lấy danh sách các quận/huyện dựa trên ID của tỉnh/thành phố. Đây là
     * phương thức được gọi bởi AddressController.
     *
     * @param provinceId ID của tỉnh/thành phố.
     * @return Danh sách các quận/huyện.
     */
    // Dán code này để thay thế cho toàn bộ phương thức getDistrictsByProvinceId
    public List<District> getDistrictsByProvinceId(long provinceId) {
        // Ghi log vào file C:/debug_log.txt
        try ( java.io.FileWriter fw = new java.io.FileWriter("C:/debug_log.txt", true);  java.io.PrintWriter pw = new java.io.PrintWriter(fw)) {
            pw.println("--------------------");
            pw.println("Timestamp: " + new java.util.Date());
            pw.println("DAO method is querying for provinceId: " + provinceId);
        } catch (java.io.IOException e) {
            e.printStackTrace();
        }

        List<District> districts = new ArrayList<>();
        String sql = "SELECT district_id, province_id, name, code FROM districts WHERE province_id = ?";

        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, provinceId);
            try ( ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    District district = new District();
                    district.setDistrictId(rs.getLong("district_id"));
                    district.setProvinceId(rs.getLong("province_id"));
                    district.setName(rs.getString("name"));
                    district.setCode(rs.getString("code"));
                    districts.add(district);
                }
            }
        } catch (SQLException e) {
            Logger.getLogger(DistrictDAO.class.getName()).log(Level.SEVERE, "Error fetching districts by ID", e);
        }

        // Ghi kết quả vào file
        try ( java.io.FileWriter fw = new java.io.FileWriter("C:/debug_log.txt", true);  java.io.PrintWriter pw = new java.io.PrintWriter(fw)) {
            pw.println("DAO found " + districts.size() + " districts.");
            pw.println("--------------------");
        } catch (java.io.IOException e) {
            e.printStackTrace();
        }

        return districts;
    }

    // --- CÁC PHƯƠNG THỨC DƯỚI ĐÂY DÙNG CHO DataInitializer ---
    public void save(List<District> districts) {
        String sql = "INSERT INTO districts (name, code, province_id) VALUES (?, ?, (SELECT province_id FROM provinces WHERE code = ?))";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            for (District d : districts) {
                ps.setString(1, d.getName());
                ps.setString(2, d.getCode());
                ps.setString(3, d.getProvince_code());
                ps.addBatch();
            }
            ps.executeBatch();
        } catch (SQLException e) {
            Logger.getLogger(DistrictDAO.class.getName()).log(Level.SEVERE, "Error saving districts", e);
        }
    }

    public List<District> getAllDistricts() {
        List<District> districts = new ArrayList<>();
        String sql = "SELECT district_id, name, code FROM districts";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql);  ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                District d = new District();
                d.setDistrictId(rs.getLong("district_id"));
                d.setName(rs.getString("name"));
                d.setCode(rs.getString("code"));
                districts.add(d);
            }
        } catch (SQLException e) {
            Logger.getLogger(DistrictDAO.class.getName()).log(Level.SEVERE, "Error getting all districts", e);
        }
        return districts;
    }

    public District findByCode(String code) {
        String sql = "SELECT district_id, province_id, name, code FROM districts WHERE code = ?";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code);
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    District district = new District();
                    district.setDistrictId(rs.getLong("district_id"));
                    district.setProvinceId(rs.getLong("province_id"));
                    district.setName(rs.getString("name"));
                    district.setCode(rs.getString("code"));
                    return district;
                }
            }
        } catch (SQLException e) {
            Logger.getLogger(DistrictDAO.class.getName()).log(Level.SEVERE, "Error finding district by code", e);
        }
        return null;
    }
}
