package dao;

import model.Address;
import util.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class AddressDAO extends DBContext {

    private final String SELECT_ALL_FIELDS
            = "a.address_id, a.user_id, a.recipient_name, a.phone_number, a.street_address, "
            + "a.province_id, p.name AS province_name, p.code AS province_code, "
            + "a.ward_id, w.name AS ward_name, w.code AS ward_code, "
            + "a.is_default, a.created_at, a.updated_at ";

    private final String FROM_JOIN_TABLES
            = "FROM addresses a "
            + "LEFT JOIN provinces p ON a.province_id = p.province_id "
            + "LEFT JOIN wards w ON a.ward_id = w.ward_id ";

    public List<Address> getAddressesByUserId(long userId) {
        List<Address> list = new ArrayList<>();
        String sql = "SELECT " + SELECT_ALL_FIELDS + FROM_JOIN_TABLES
                + "WHERE a.user_id = ? ORDER BY a.is_default DESC, a.created_at DESC";

        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try ( ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToAddress(rs));
                }
            }
        } catch (SQLException e) {
            Logger.getLogger(AddressDAO.class.getName())
                    .log(Level.SEVERE, "Error getting addresses by user ID", e);
        }
        return list;
    }

    public Address getAddressById(long addressId, long userId) {
        String sql = "SELECT " + SELECT_ALL_FIELDS + FROM_JOIN_TABLES
                + "WHERE a.address_id = ? AND a.user_id = ?";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, addressId);
            ps.setLong(2, userId);
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToAddress(rs);
                }
            }
        } catch (SQLException e) {
            Logger.getLogger(AddressDAO.class.getName())
                    .log(Level.SEVERE, "Error getting address by ID", e);
        }
        return null;
    }

    public boolean addAddress(Address address) {
        String countSQL = "SELECT COUNT(*) FROM addresses WHERE user_id = ?";
        String resetDefaultSQL = "UPDATE addresses SET is_default = 0 WHERE user_id = ?";
        String insertSQL = "INSERT INTO addresses "
                + "(user_id, recipient_name, phone_number, street_address, province_id, ward_id, is_default) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?)";

        Connection conn = null;
        try {
            conn = DBContext.getNewConnection();
            conn.setAutoCommit(false);

            boolean shouldBeDefault = address.isDefault();
            try ( PreparedStatement psCount = conn.prepareStatement(countSQL)) {
                psCount.setLong(1, address.getUserId());
                try ( ResultSet rs = psCount.executeQuery()) {
                    if (rs.next() && rs.getInt(1) == 0) {
                        shouldBeDefault = true;
                    }
                }
            }

            if (shouldBeDefault) {
                try ( PreparedStatement psReset = conn.prepareStatement(resetDefaultSQL)) {
                    psReset.setLong(1, address.getUserId());
                    psReset.executeUpdate();
                }
            }

            try ( PreparedStatement psInsert = conn.prepareStatement(insertSQL, Statement.RETURN_GENERATED_KEYS)) {
                psInsert.setLong(1, address.getUserId());
                psInsert.setString(2, address.getRecipientName());
                psInsert.setString(3, address.getPhoneNumber());
                psInsert.setString(4, address.getStreetAddress());
                psInsert.setLong(5, address.getProvinceId());
                psInsert.setLong(6, address.getWardId());
                psInsert.setInt(7, shouldBeDefault ? 1 : 0);

                int affectedRows = psInsert.executeUpdate();
                if (affectedRows == 0) {
                    conn.rollback();
                    return false;
                }
                try ( ResultSet gk = psInsert.getGeneratedKeys()) {
                    if (!gk.next()) {
                        conn.rollback();
                        return false;
                    }
                }
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            Logger.getLogger(AddressDAO.class.getName()).log(Level.SEVERE, "Error adding address", e);
            if (conn != null) try {
                conn.rollback();
            } catch (SQLException ignored) {
            }
            return false;
        } finally {
            if (conn != null) try {
                conn.setAutoCommit(true);
                conn.close();
            } catch (SQLException ignored) {
            }
        }
    }

    public boolean updateAddress(Address address) {
        String sql = "UPDATE addresses SET recipient_name = ?, phone_number = ?, street_address = ?, "
                + "province_id = ?, ward_id = ?, is_default = ?, updated_at = GETDATE() "
                + "WHERE address_id = ? AND user_id = ?";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, address.getRecipientName());
            ps.setString(2, address.getPhoneNumber());
            ps.setString(3, address.getStreetAddress());
            ps.setLong(4, address.getProvinceId());
            ps.setLong(5, address.getWardId());
            ps.setBoolean(6, address.isDefault());
            ps.setLong(7, address.getAddressId());
            ps.setLong(8, address.getUserId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            Logger.getLogger(AddressDAO.class.getName()).log(Level.SEVERE, "Error updating address", e);
            return false;
        }
    }

    public boolean deleteAddress(long addressId, long userId) {
        String sql = "DELETE FROM addresses WHERE address_id = ? AND user_id = ?";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, addressId);
            ps.setLong(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            Logger.getLogger(AddressDAO.class.getName()).log(Level.SEVERE, "Error deleting address", e);
            return false;
        }
    }

    public boolean setDefaultAddress(long addressId, long userId) {
        String resetDefaultSQL = "UPDATE addresses SET is_default = 0 WHERE user_id = ? AND is_default = 1";
        String setDefaultSQL = "UPDATE addresses SET is_default = 1 WHERE address_id = ? AND user_id = ?";
        try ( Connection conn = DBContext.getNewConnection()) {
            conn.setAutoCommit(false);
            try ( PreparedStatement psReset = conn.prepareStatement(resetDefaultSQL)) {
                psReset.setLong(1, userId);
                psReset.executeUpdate();
            }
            if (addressId > 0) {
                try ( PreparedStatement psSet = conn.prepareStatement(setDefaultSQL)) {
                    psSet.setLong(1, addressId);
                    psSet.setLong(2, userId);
                    if (psSet.executeUpdate() == 0) {
                        conn.rollback();
                        return false;
                    }
                }
            }
            conn.commit();
            return true;
        } catch (SQLException e) {
            Logger.getLogger(AddressDAO.class.getName()).log(Level.SEVERE, "Error setting default address", e);
            return false;
        }
    }

    private Address mapRowToAddress(ResultSet rs) throws SQLException {
        Address a = new Address();
        a.setAddressId(rs.getLong("address_id"));
        a.setUserId(rs.getLong("user_id"));
        a.setRecipientName(rs.getString("recipient_name"));
        a.setPhoneNumber(rs.getString("phone_number"));
        a.setStreetAddress(rs.getString("street_address"));
        a.setProvinceId(rs.getLong("province_id"));
        a.setWardId(rs.getLong("ward_id"));
        a.setDefault(rs.getBoolean("is_default"));
        a.setCreatedAt(rs.getTimestamp("created_at"));
        a.setUpdatedAt(rs.getTimestamp("updated_at"));
        a.setProvinceName(rs.getString("province_name"));
        a.setWardName(rs.getString("ward_name"));
        a.setProvinceCode(rs.getString("province_code"));
        a.setWardCode(rs.getString("ward_code"));
        return a;
    }
}
