package dao;

import model.ShippingAddress;
import util.DBContext; // Assuming this class manages your database connection
import java.sql.*;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.ArrayList;
import java.util.List;

public class ShippingAddressDAO {

    private static final Logger LOGGER = Logger.getLogger(ShippingAddressDAO.class.getName());

    /**
     * Thêm một địa chỉ mới vào database.
     *
     * @param address Đối tượng ShippingAddress chứa thông tin địa chỉ mới.
     * @return ID của địa chỉ vừa được thêm, hoặc -1 nếu có lỗi.
     */
    public long addAddress(ShippingAddress address) {
        String sql = "INSERT INTO shipping_addresses (customer_id, recipient_name, phone_number, address_details, city, country, postal_code, is_default) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        long generatedId = -1;
        DBContext db = new DBContext();
        try ( Connection conn = db.getConnection();  PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setLong(1, address.getCustomerId());
            ps.setString(2, address.getRecipientName());
            ps.setString(3, address.getPhoneNumber());
            ps.setString(4, address.getAddressDetails());
            ps.setString(5, address.getCity());
            ps.setString(6, address.getCountry());
            ps.setString(7, address.getPostalCode());
            ps.setBoolean(8, address.isIsDefault());

            int affectedRows = ps.executeUpdate();
            if (affectedRows > 0) {
                try ( ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        generatedId = rs.getLong(1);
                        LOGGER.log(Level.INFO, "Address added successfully with ID: {0}", generatedId);
                    }
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error adding address: " + address, e);
        }
        return generatedId;
    }

    /**
     * Lấy tất cả địa chỉ của một khách hàng.
     *
     * @param customerId ID của khách hàng.
     * @return Danh sách các địa chỉ giao hàng của khách hàng.
     */
    public List<ShippingAddress> getAddressesByCustomerId(long customerId) {
        List<ShippingAddress> addresses = new ArrayList<>();
        // Order by is_default DESC to show default address first, then by creation date
        String sql = "SELECT * FROM shipping_addresses WHERE customer_id = ? ORDER BY is_default DESC, created_at DESC";
        DBContext db = new DBContext();
        try ( Connection conn = db.getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, customerId);
            LOGGER.log(Level.INFO, "Executing query to get addresses for customerId: {0}", customerId);

            try ( ResultSet rs = ps.executeQuery()) {
                int count = 0;
                while (rs.next()) {
                    ShippingAddress address = mapResultSetToShippingAddress(rs);
                    addresses.add(address);
                    count++;
                    LOGGER.log(Level.FINE, "Found address (ID: {0}, City: {1}) for customer {2}",
                            new Object[]{address.getAddressId(), address.getCity(), customerId});
                }
                LOGGER.log(Level.INFO, "Total addresses found for customer {0}: {1}", new Object[]{customerId, count});
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting addresses for customerId: " + customerId, e);
        }
        return addresses;
    }

    /**
     * Lấy một địa chỉ theo ID.
     *
     * @param addressId ID của địa chỉ cần lấy.
     * @return Đối tượng ShippingAddress nếu tìm thấy, hoặc null nếu không tìm
     * thấy.
     */
    public ShippingAddress getAddressById(long addressId) {
        String sql = "SELECT * FROM shipping_addresses WHERE address_id = ?";
        DBContext db = new DBContext();
        try ( Connection conn = db.getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, addressId);
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    LOGGER.log(Level.INFO, "Address found by ID: {0}", addressId);
                    return mapResultSetToShippingAddress(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting address by ID: " + addressId, e);
        }
        LOGGER.log(Level.INFO, "No address found with ID: {0}", addressId);
        return null;
    }

    /**
     * Cập nhật thông tin địa chỉ.
     *
     * @param address Đối tượng ShippingAddress chứa thông tin cần cập nhật.
     * @return true nếu cập nhật thành công, false nếu không thành công.
     */
    public boolean updateAddress(ShippingAddress address) {
        // Note: is_default is included here but setDefaultAddress should be used for setting default status
        String sql = "UPDATE shipping_addresses SET recipient_name = ?, phone_number = ?, address_details = ?, city = ?, country = ?, postal_code = ? WHERE address_id = ? AND customer_id = ?";
        DBContext db = new DBContext();
        try ( Connection conn = db.getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, address.getRecipientName());
            ps.setString(2, address.getPhoneNumber());
            ps.setString(3, address.getAddressDetails());
            ps.setString(4, address.getCity());
            ps.setString(5, address.getCountry());
            ps.setString(6, address.getPostalCode());
            ps.setLong(7, address.getAddressId());
            ps.setLong(8, address.getCustomerId());

            int affectedRows = ps.executeUpdate();
            if (affectedRows > 0) {
                LOGGER.log(Level.INFO, "Address updated successfully: {0}", address.getAddressId());
                return true;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating address: " + address, e);
        }
        LOGGER.log(Level.WARNING, "Failed to update address: {0}", address.getAddressId());
        return false;
    }

    /**
     * Xóa một địa chỉ.
     *
     * @param addressId ID của địa chỉ cần xóa.
     * @return true nếu xóa thành công, false nếu không thành công.
     */
    public boolean deleteAddress(long addressId) {
        String sql = "DELETE FROM shipping_addresses WHERE address_id = ?";
        DBContext db = new DBContext();
        try ( Connection conn = db.getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, addressId);
            int affectedRows = ps.executeUpdate();
            if (affectedRows > 0) {
                LOGGER.log(Level.INFO, "Address deleted successfully: {0}", addressId);
                return true;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error deleting address with ID: " + addressId, e);
        }
        LOGGER.log(Level.WARNING, "Failed to delete address with ID: {0}", addressId);
        return false;
    }

    /**
     * Đặt một địa chỉ làm mặc định cho khách hàng, đồng thời bỏ đặt mặc định
     * cho các địa chỉ khác của cùng khách hàng.
     *
     * @param addressId ID của địa chỉ muốn đặt làm mặc định.
     * @param customerId ID của khách hàng sở hữu địa chỉ.
     * @return true nếu đặt mặc định thành công, false nếu không thành công.
     */
    public boolean setDefaultAddress(long addressId, long customerId) {
        DBContext db = new DBContext();
        Connection conn = null;
        try {
            conn = db.getConnection();
            conn.setAutoCommit(false); // Start transaction

            // 1. Set all addresses for this customer to not default
            String unsetDefaultSql = "UPDATE shipping_addresses SET is_default = 0 WHERE customer_id = ?";
            try ( PreparedStatement ps1 = conn.prepareStatement(unsetDefaultSql)) {
                ps1.setLong(1, customerId);
                ps1.executeUpdate();
                LOGGER.log(Level.INFO, "Unset default for all addresses of customer: {0}", customerId);
            }

            // 2. Set the specified address to default
            String setDefaultSql = "UPDATE shipping_addresses SET is_default = 1 WHERE address_id = ? AND customer_id = ?";
            try ( PreparedStatement ps2 = conn.prepareStatement(setDefaultSql)) {
                ps2.setLong(1, addressId);
                ps2.setLong(2, customerId);
                int rowsAffected = ps2.executeUpdate();
                if (rowsAffected > 0) {
                    conn.commit(); // Commit transaction
                    LOGGER.log(Level.INFO, "Set address {0} as default for customer {1}", new Object[]{addressId, customerId});
                    return true;
                } else {
                    conn.rollback(); // Rollback if no rows affected (address not found or not owned by customer)
                    LOGGER.log(Level.WARNING, "Failed to set address {0} as default for customer {1}. Rolling back.", new Object[]{addressId, customerId});
                    return false;
                }
            }
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback(); // Rollback on error
                } catch (SQLException ex) {
                    LOGGER.log(Level.SEVERE, "Error during rollback for setDefaultAddress", ex);
                }
            }
            LOGGER.log(Level.SEVERE, "Error setting default address for address ID: " + addressId + ", customer ID: " + customerId, e);
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true); // Reset auto-commit
                    conn.close();
                } catch (SQLException ex) {
                    LOGGER.log(Level.SEVERE, "Error closing connection in setDefaultAddress finally block", ex);
                }
            }
        }
    }

    /**
     * Helper method to map ResultSet to ShippingAddress object.
     *
     * @param rs ResultSet chứa dữ liệu địa chỉ.
     * @return Đối tượng ShippingAddress đã được populate.
     * @throws SQLException Nếu có lỗi khi đọc dữ liệu từ ResultSet.
     */
    private ShippingAddress mapResultSetToShippingAddress(ResultSet rs) throws SQLException {
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
