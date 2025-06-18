/*
 * Click nbproject://SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbproject://SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.Supplier;
import util.DBContext;

/**
 *
 * @author DANGVUONGTHINH
 */
public class SupplierDAO extends DBContext {
    
  public List<Supplier> getAll() {
        List<Supplier> list = new ArrayList<>();
        String sql = "SELECT supplier_id, name, contact_email, phone_number, address, is_active, created_at FROM suppliers";

        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                long supplierId = rs.getLong("supplier_id");
                String name = rs.getString("name");
                String contactEmail = rs.getString("contact_email");
                String phoneNumber = rs.getString("phone_number");
                String address = rs.getString("address");
                Boolean isActive = rs.getBoolean("is_active");
                java.sql.Timestamp createdAt = rs.getTimestamp("created_at");
                java.time.LocalDateTime createdAtLocal = createdAt != null ? createdAt.toLocalDateTime() : null;

                Supplier supplier = new Supplier();
                supplier.setSupplierId(supplierId);
                supplier.setName(name);
                supplier.setContactEmail(contactEmail);
                supplier.setPhoneNumber(phoneNumber);
                supplier.setAddress(address);
                supplier.setIsActive(isActive);
                supplier.setCreatedAt(createdAtLocal);

                list.add(supplier);
            }
            return list;
        } catch (Exception e) {
            System.out.println("Error in getAll: " + e.getMessage());
        }
        return list;
    }

    public Supplier getSupplierById(long supplierId) {
        String sql = "SELECT supplier_id, name, contact_email, phone_number, address, is_active, created_at FROM suppliers WHERE supplier_id = ?";

        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setLong(1, supplierId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                long id = rs.getLong("supplier_id");
                String name = rs.getString("name");
                String contactEmail = rs.getString("contact_email");
                String phoneNumber = rs.getString("phone_number");
                String address = rs.getString("address");
                Boolean isActive = rs.getBoolean("is_active");
                java.sql.Timestamp createdAt = rs.getTimestamp("created_at");
                java.time.LocalDateTime createdAtLocal = createdAt != null ? createdAt.toLocalDateTime() : null;

                Supplier supplier = new Supplier();
                supplier.setSupplierId(id);
                supplier.setName(name);
                supplier.setContactEmail(contactEmail);
                supplier.setPhoneNumber(phoneNumber);
                supplier.setAddress(address);
                supplier.setIsActive(isActive);
                supplier.setCreatedAt(createdAtLocal);
                return supplier;
            }
        } catch (Exception e) {
            System.out.println("Error in getSupplierById: " + e.getMessage());
        }
        return null;
    }
}