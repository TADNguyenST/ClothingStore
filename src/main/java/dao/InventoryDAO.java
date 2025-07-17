package dao;

import util.DBContext;
import model.Inventory;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class InventoryDAO {

    private static final Logger LOGGER = Logger.getLogger(InventoryDAO.class.getName());

    public List<Inventory> getAll() {
        List<Inventory> list = new ArrayList<>();
        String sql = "SELECT i.inventory_id, i.variant_id, i.quantity, i.reserved_quantity, i.last_updated, "
                + "p.name AS product_name "
                + "FROM inventory i "
                + "JOIN product_variants pv ON i.variant_id = pv.variant_id "
                + "JOIN products p ON pv.product_id = p.product_id";

        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql);  ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Inventory inventory = new Inventory();
                inventory.setInventoryId(rs.getLong("inventory_id"));
                inventory.setVariantId(rs.getLong("variant_id"));
                inventory.setQuantity(rs.getInt("quantity"));
                inventory.setReservedQuantity(rs.getInt("reserved_quantity"));
                inventory.setLastUpdated(rs.getTimestamp("last_updated") != null
                        ? rs.getTimestamp("last_updated").toLocalDateTime() : null);
                inventory.setProductName(rs.getString("product_name"));
                list.add(inventory);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in getAll", e);
        }
        return list;
    }

    public Inventory getInventoryById(long inventoryId) {
        String sql = "SELECT i.inventory_id, i.variant_id, i.quantity, i.reserved_quantity, i.last_updated, "
                + "p.name AS product_name "
                + "FROM inventory i "
                + "JOIN product_variants pv ON i.variant_id = pv.variant_id "
                + "JOIN products p ON pv.product_id = p.product_id "
                + "WHERE i.inventory_id = ?";

        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, inventoryId);
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Inventory inventory = new Inventory();
                    inventory.setInventoryId(rs.getLong("inventory_id"));
                    inventory.setVariantId(rs.getLong("variant_id"));
                    inventory.setQuantity(rs.getInt("quantity"));
                    inventory.setReservedQuantity(rs.getInt("reserved_quantity"));
                    inventory.setLastUpdated(rs.getTimestamp("last_updated") != null
                            ? rs.getTimestamp("last_updated").toLocalDateTime() : null);
                    inventory.setProductName(rs.getString("product_name"));
                    return inventory;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in getInventoryById", e);
        }
        return null;
    }

    public int getAvailableQuantity(long variantId) {
        String sql = "SELECT quantity - COALESCE(reserved_quantity, 0) AS available_quantity "
                + "FROM inventory WHERE variant_id = ?";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, variantId);
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("available_quantity");
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting available quantity for variantId: " + variantId, e);
        }
        return 0;
    }

    public boolean updateInventory(Inventory inventory) {
        String sql = "UPDATE inventory SET quantity = ?, reserved_quantity = ?, last_updated = ? WHERE inventory_id = ?";
        try ( Connection conn = DBContext.getNewConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, inventory.getQuantity());
            ps.setInt(2, inventory.getReservedQuantity());
            ps.setTimestamp(3, Timestamp.valueOf(LocalDateTime.now()));
            ps.setLong(4, inventory.getInventoryId());
            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating inventory for inventoryId: " + inventory.getInventoryId(), e);
            return false;
        }
    }
}

