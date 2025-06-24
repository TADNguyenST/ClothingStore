package dao;

import model.ShippingAddress;
import util.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class ShippingAddressDAO extends DBContext {

    // Lấy tất cả địa chỉ của một khách hàng
    public List<ShippingAddress> getAddressesByCustomerId(long customerId) {
        List<ShippingAddress> list = new ArrayList<>();
        String sql = "SELECT * FROM shipping_addresses WHERE customer_id = ? ORDER BY is_default DESC, created_at DESC";
        try ( Connection conn = getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, customerId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRowToAddress(rs));
            }
        } catch (Exception e) {
            Logger.getLogger(ShippingAddressDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return list;
    }

    // Lấy một địa chỉ cụ thể bằng ID (có kiểm tra chủ sở hữu)
    public ShippingAddress getAddressById(long addressId, long customerId) {
        String sql = "SELECT * FROM shipping_addresses WHERE address_id = ? AND customer_id = ?";
        try ( Connection conn = getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, addressId);
            ps.setLong(2, customerId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapRowToAddress(rs);
            }
        } catch (Exception e) {
            Logger.getLogger(ShippingAddressDAO.class.getName()).log(Level.SEVERE, null, e);
        }
        return null;
    }

    // Thêm địa chỉ mới
    public void addAddress(ShippingAddress address) {
        String sql = "INSERT INTO shipping_addresses (customer_id, recipient_name, phone_number, address_details, city, country, postal_code, is_default) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try ( Connection conn = getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, address.getCustomerId());
            ps.setString(2, address.getRecipientName());
            ps.setString(3, address.getPhoneNumber());
            ps.setString(4, address.getAddressDetails());
            ps.setString(5, address.getCity());
            ps.setString(6, address.getCountry());
            ps.setString(7, address.getPostalCode());
            ps.setBoolean(8, address.isIsDefault());
            ps.executeUpdate();
        } catch (Exception e) {
            Logger.getLogger(ShippingAddressDAO.class.getName()).log(Level.SEVERE, null, e);
        }
    }

    // Cập nhật địa chỉ
    public boolean updateAddress(ShippingAddress address) {
        String sql = "UPDATE shipping_addresses SET recipient_name = ?, phone_number = ?, address_details = ?, city = ?, country = ?, postal_code = ? WHERE address_id = ? AND customer_id = ?";
        try ( Connection conn = getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, address.getRecipientName());
            ps.setString(2, address.getPhoneNumber());
            ps.setString(3, address.getAddressDetails());
            ps.setString(4, address.getCity());
            ps.setString(5, address.getCountry());
            ps.setString(6, address.getPostalCode());
            ps.setLong(7, address.getAddressId());
            ps.setLong(8, address.getCustomerId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            Logger.getLogger(ShippingAddressDAO.class.getName()).log(Level.SEVERE, null, e);
            return false;
        }
    }

    // Xóa địa chỉ
    public boolean deleteAddress(long addressId, long customerId) {
        String sql = "DELETE FROM shipping_addresses WHERE address_id = ? AND customer_id = ?";
        try ( Connection conn = getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, addressId);
            ps.setLong(2, customerId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            Logger.getLogger(ShippingAddressDAO.class.getName()).log(Level.SEVERE, null, e);
            return false;
        }
    }

    // Đặt làm mặc định (có transaction)
    public boolean setDefaultAddress(long addressId, long customerId) {
        String resetDefaultSQL = "UPDATE shipping_addresses SET is_default = 0 WHERE customer_id = ? AND is_default = 1";
        String setDefaultSQL = "UPDATE shipping_addresses SET is_default = 1 WHERE address_id = ? AND customer_id = ?";
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            try ( PreparedStatement psReset = conn.prepareStatement(resetDefaultSQL)) {
                psReset.setLong(1, customerId);
                psReset.executeUpdate();
            }
            try ( PreparedStatement psSet = conn.prepareStatement(setDefaultSQL)) {
                psSet.setLong(1, addressId);
                psSet.setLong(2, customerId);
                psSet.executeUpdate();
            }
            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            Logger.getLogger(ShippingAddressDAO.class.getName()).log(Level.SEVERE, null, e);
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    private ShippingAddress mapRowToAddress(ResultSet rs) throws SQLException {
        ShippingAddress address = new ShippingAddress();
        address.setAddressId(rs.getLong("address_id"));
        address.setCustomerId(rs.getLong("customer_id"));
        address.setRecipientName(rs.getString("recipient_name"));
        address.setPhoneNumber(rs.getString("phone_number"));
        address.setAddressDetails(rs.getString("address_details"));
        address.setCity(rs.getString("city"));
        address.setCountry(rs.getString("country"));
        address.setPostalCode(rs.getString("postal_code"));
        address.setIsDefault(rs.getBoolean("is_default"));
        address.setCreatedAt(rs.getTimestamp("created_at"));
        return address;
    }
}
