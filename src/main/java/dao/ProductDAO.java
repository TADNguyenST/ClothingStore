/*
 * Click nbproject://SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbproject://SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.Brand;
import model.Category;
import model.Product;
import model.Supplier;
import util.DBContext;

/**
 *
 * @author DANGVUONGTHINH
 */
public class ProductDAO extends DBContext {

    public List<Product> getAll() {
        List<Product> list = new ArrayList<>();
        Connection conn = null;
        try {
            System.out.println("Attempting to get connection...");
            conn = getConnection();
            if (conn == null) {
                System.out.println("Connection failed: conn is null after getConnection()");
                return list;
            }
            System.out.println("Connection successful, executing query...");

            String sql = "SELECT p.product_id, p.name, p.description, p.price, p.stock_quantity, p.supplier_id, p.category_id, "
                    + "p.brand_id, p.material, p.status, s.supplier_id, s.name AS supplier_name, "
                    + "c.category_id, c.name AS category_name, b.brand_id, b.name AS brand_name "
                    + "FROM products p "
                    + "LEFT JOIN suppliers s ON p.supplier_id = s.supplier_id "
                    + "LEFT JOIN categories c ON p.category_id = c.category_id "
                    + "LEFT JOIN brands b ON p.brand_id = b.brand_id";

            System.out.println("SQL Query: " + sql);
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            System.out.println("Query executed, reading data...");

            while (rs.next()) {
                long productId = rs.getLong("product_id");
                String productName = rs.getString("name");
                String description = rs.getString("description");
                double price = rs.getDouble("price");
                int stockQuantity = rs.getInt("stock_quantity");
                long supplierId = rs.getLong("supplier_id");
                long categoryId = rs.getLong("category_id");
                long brandId = rs.getLong("brand_id");
                String material = rs.getString("material");
                String status = rs.getString("status");

                System.out.println("Reading record - Product ID: " + productId);

                // Create Supplier object (may be null if LEFT JOIN)
                String supplierName = rs.getString("supplier_name");
                Supplier supplier = (supplierName != null) ? new Supplier() : null;
                if (supplier != null) {
                    supplier.setSupplierId(supplierId);
                    supplier.setName(supplierName);
                }

                // Create Category object (may be null if LEFT JOIN)
                String categoryName = rs.getString("category_name");
                Category category = (categoryName != null) ? new Category() : null;
                if (category != null) {
                    category.setCategoryId(categoryId);
                    category.setName(categoryName);
                }

                // Create Brand object (may be null if LEFT JOIN)
                String brandName = rs.getString("brand_name");
                Brand brand = (brandName != null) ? new Brand() : null;
                if (brand != null) {
                    brand.setBrandId(brandId);
                    brand.setName(brandName);
                }

                // Create Product object
                Product product = new Product();
                product.setProductId(productId);
                product.setName(productName);
                product.setDescription(description);
                product.setPrice(price);
                product.setStockQuantity(stockQuantity);
                product.setSupplier(supplier);
                product.setCategory(category);
                product.setBrand(brand);
                product.setMaterial(material);
                product.setStatus(status);

                list.add(product);
            }
            System.out.println("Number of products retrieved: " + list.size());
        } catch (Exception e) {
            System.out.println("Error in getAll: " + e.getMessage());
        } finally {
            try {
                if (conn != null && !conn.isClosed()) {
                    conn.close();
                    System.out.println("Connection closed.");
                }
            } catch (Exception e) {
                System.out.println("Error closing connection: " + e.getMessage());
            }
        }
        return list;
    }

    public Product getProductById(long productId) {
        String sql = "SELECT p.product_id, p.name, p.description, p.price, p.stock_quantity, p.supplier_id, p.category_id, "
                + "p.brand_id, p.material, p.status, s.supplier_id, s.name AS supplier_name, "
                + "c.category_id, c.name AS category_name, b.brand_id, b.name AS brand_name "
                + "FROM products p "
                + "LEFT JOIN suppliers s ON p.supplier_id = s.supplier_id "
                + "LEFT JOIN categories c ON p.category_id = c.category_id "
                + "LEFT JOIN brands b ON p.brand_id = b.brand_id "
                + "WHERE p.product_id = ?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, productId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                long id = rs.getLong("product_id");
                String name = rs.getString("name");
                String description = rs.getString("description");
                double price = rs.getDouble("price");
                int stockQuantity = rs.getInt("stock_quantity");
                long supplierId = rs.getLong("supplier_id");
                long categoryId = rs.getLong("category_id");
                long brandId = rs.getLong("brand_id");
                String material = rs.getString("material");
                String status = rs.getString("status");

                // Create Supplier object (may be null if LEFT JOIN)
                String supplierName = rs.getString("supplier_name");
                Supplier supplier = (supplierName != null) ? new Supplier() : null;
                if (supplier != null) {
                    supplier.setSupplierId(supplierId);
                    supplier.setName(supplierName);
                }

                // Create Category object (may be null if LEFT JOIN)
                String categoryName = rs.getString("category_name");
                Category category = (categoryName != null) ? new Category() : null;
                if (category != null) {
                    category.setCategoryId(categoryId);
                    category.setName(categoryName);
                }

                // Create Brand object (may be null if LEFT JOIN)
                String brandName = rs.getString("brand_name");
                Brand brand = (brandName != null) ? new Brand() : null;
                if (brand != null) {
                    brand.setBrandId(brandId);
                    brand.setName(brandName);
                }

                // Create Product object
                Product product = new Product();
                product.setProductId(id);
                product.setName(name);
                product.setDescription(description);
                product.setPrice(price);
                product.setStockQuantity(stockQuantity);
                product.setSupplier(supplier);
                product.setCategory(category);
                product.setBrand(brand);
                product.setMaterial(material);
                product.setStatus(status);
                return product;
            }
        } catch (Exception e) {
            System.out.println("Error in getProductById: " + e.getMessage());
        }
        return null;
    }

    public int insert(String name, String description, double price, int stockQuantity, Long supplierId, Long categoryId, Long brandId, String material, String status) {
        String getMaxId = "SELECT MAX(product_id) as maxid FROM products";
        long nextId;
        try {
            System.out.println("Starting insert - Getting max ID...");
            PreparedStatement psGetMaxId = conn.prepareStatement(getMaxId);
            ResultSet rsGetMaxId = psGetMaxId.executeQuery();
            if (rsGetMaxId.next()) {
                nextId = rsGetMaxId.getLong("maxid") + 1;
                System.out.println("Max ID found: " + (rsGetMaxId.getLong("maxid")) + ", Next ID: " + nextId);
            } else {
                nextId = 1;
                System.out.println("Table empty, setting Next ID to: " + nextId);
            }
            String sql = "SET IDENTITY_INSERT products ON; " +
                         "INSERT INTO products (product_id, name, description, price, stock_quantity, supplier_id, category_id, brand_id, material, status) " +
                         "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?); " +
                         "SET IDENTITY_INSERT products OFF;";
            try {
                System.out.println("Executing insert with ID: " + nextId);
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setLong(1, nextId);
                ps.setString(2, name);
                ps.setString(3, description != null && !description.isEmpty() ? description : null);
                ps.setDouble(4, price);
                ps.setInt(5, stockQuantity);
                ps.setObject(6, supplierId, java.sql.Types.BIGINT);
                ps.setObject(7, categoryId, java.sql.Types.BIGINT);
                ps.setObject(8, brandId, java.sql.Types.BIGINT);
                ps.setString(9, material);
                ps.setString(10, status);
                int row = ps.executeUpdate();
                System.out.println("Insert executed, rows affected: " + row);
                if (row > 0) {
                    return 1;
                } else {
                    System.out.println("No rows affected by insert.");
                    return 0;
                }
            } catch (Exception e) {
                System.out.println("Insert error: " + e.getMessage());
                return 0;
            }
        } catch (Exception e) {
            System.out.println("Max ID query error: " + e.getMessage());
            return 0;
        }
    }
   
    public int delete(long productId) {
        String sql = "DELETE FROM products WHERE product_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setLong(1, productId);
            int num = ps.executeUpdate();
            if (num > 0) {
                System.out.println("Deleted product with ID " + productId);
                return 1;
            } else {
                System.out.println("No product found with ID " + productId);
                return 0;
            }
        } catch (Exception e) {
            System.out.println("Delete error: " + e.getMessage());
            return 0;
        }
    }

    public static void main(String[] args) {
        ProductDAO dao = new ProductDAO();
        List<Product> products = dao.getAll();

        if (products != null) {
            System.out.println("Database connection successful!");
            System.out.println("Number of products in list: " + products.size());
            for (Product product : products) {
                System.out.println("ID: " + product.getProductId());
                System.out.println("Name: " + product.getName());
                System.out.println("Price: " + product.getPrice());
                System.out.println("Quantity: " + product.getStockQuantity());
                System.out.println("Supplier: " + (product.getSupplier() != null ? product.getSupplier().getName() : "Not available"));
                System.out.println("Category: " + (product.getCategory() != null ? product.getCategory().getName() : "Not available"));
                System.out.println("Brand: " + (product.getBrand() != null ? product.getBrand().getName() : "Not available"));
                System.out.println("Material: " + product.getMaterial());
                System.out.println("Status: " + product.getStatus());
                System.out.println("-------------------");
            }
        } else {
            System.out.println("Unable to retrieve data or list is empty!");
        }
    }
}