// src/main/java/dao/StockMovementDAO.java
package dao;

import model.Product;
import model.ProductVariant;
import model.Inventory;
import model.StockMovement;
import model.Category;
import model.Brand;
import model.Supplier;
import util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.math.BigDecimal;

public class StockMovementDAO {
    private static final Logger LOGGER = Logger.getLogger(StockMovementDAO.class.getName());

    // --- Phương thức ánh xạ ResultSet sang Product ---
    // Phương thức này giờ sẽ đọc cả thông tin join từ Supplier, Category, Brand
    // Và tạo các đối tượng lồng nhau để JSP có thể truy cập product.supplier.supplierId
    private Product mapResultSetToProduct(ResultSet rs) throws SQLException {
        Product product = new Product();
        product.setProductId(rs.getLong("product_id"));
        product.setName(rs.getString("name")); // Hoặc rs.getString("product_name") nếu bạn dùng alias
        product.setDescription(rs.getString("description"));
        product.setPrice(rs.getBigDecimal("price"));
        
        // Cố gắng đọc stock_quantity. Nếu cột không tồn tại, sẽ bỏ qua lỗi và set 0.
        try {
            // Giả định bạn có setTotalStockQuantity trong Product model
            product.setStockQuantity(rs.getInt("stock_quantity"));
        } catch (SQLException e) {
            // Log ở mức FINE hoặc INFO, vì cột này có thể không có trong mọi query JOIN
            LOGGER.log(Level.FINE, "Column 'stock_quantity' not found for Product ID: " + product.getProductId() + ", defaulting to 0.");
            // Giả định bạn có setTotalStockQuantity trong Product model
            product.setStockQuantity(0); // Set default or handle as needed
        }

        product.setMaterial(rs.getString("material"));
        // Giả định bạn có setStatus trong Product model
        product.setStatus(rs.getString("status"));
        // Giả định bạn có setCreatedAt, setUpdatedAt trong Product model
        product.setCreatedAt(rs.getObject("created_at", LocalDateTime.class));
        product.setUpdatedAt(rs.getObject("updated_at", LocalDateTime.class));

        // Lấy ID của các khóa ngoại từ ResultSet
        Long supplierId = rs.getObject("supplier_id", Long.class);
        Long categoryId = rs.getObject("category_id", Long.class);
        Long brandId = rs.getObject("brand_id", Long.class);

        // Gán trực tiếp các ID vào Product model (nếu Product có các trường này)
        // Nếu Product của bạn KHÔNG có các trường supplierId, categoryId, brandId riêng, hãy bỏ các dòng này
        // (Nhưng thường thì có cả 2: ID và Object cho sự tiện lợi)
        // Giả định Product model của bạn có setSupplierId, setCategoryId, setBrandId
        product.setSupplierId(supplierId);
        product.setCategoryId(categoryId);
        product.setBrandId(brandId);

        // Tạo và gán các đối tượng lồng nhau để JSP có thể truy cập product.supplier.supplierId
        // Chỉ tạo đối tượng nếu ID không null, sau đó set ID và tên (nếu có từ JOIN)
        if (supplierId != null) {
            Supplier supplier = new Supplier(); // Dùng constructor mặc định của Supplier
            supplier.setSupplierId(supplierId); // Set ID
            try {
                // Cố gắng lấy tên nhà cung cấp nếu có trong ResultSet (từ JOIN)
                supplier.setName(rs.getString("supplier_name"));
            } catch (SQLException e) {
                LOGGER.log(Level.FINE, "Column 'supplier_name' not found in ResultSet for Supplier ID: " + supplierId);
            }
            product.setSupplier(supplier); // Giả định Product model có setSupplier(Supplier supplier)
        } else {
            product.setSupplier(null); // Set rõ ràng là null nếu không có supplier
        }

        if (categoryId != null) {
            Category category = new Category(); // Dùng constructor mặc định của Category
            category.setCategoryId(categoryId); // Set ID
            try {
                category.setName(rs.getString("category_name"));
            } catch (SQLException e) {
                LOGGER.log(Level.FINE, "Column 'category_name' not found in ResultSet for Category ID: " + categoryId);
            }
            product.setCategory(category); // Giả định Product model có setCategory(Category category)
        } else {
            product.setCategory(null);
        }

        if (brandId != null) {
            Brand brand = new Brand(); // Dùng constructor mặc định của Brand
            brand.setBrandId(brandId); // Set ID
            try {
                brand.setName(rs.getString("brand_name"));
            } catch (SQLException e) {
                LOGGER.log(Level.FINE, "Column 'brand_name' not found in ResultSet for Brand ID: " + brandId);
            }
            product.setBrand(brand); // Giả định Product model có setBrand(Brand brand)
        } else {
            product.setBrand(null);
        }

        return product;
    }

    // --- Các phương thức liên quan đến Product ---

    // Lấy Product theo Tên (có join để lấy đủ dữ liệu cho JSP và mapResultSetToProduct)
    public Product getProductByName(Connection conn, String productName) throws SQLException {
        String sql = "SELECT p.product_id, p.name, p.description, p.price, p.stock_quantity, p.material, p.status, p.created_at, p.updated_at, " +
                     "s.supplier_id, s.name AS supplier_name, " + // Đảm bảo có supplier_id, supplier_name
                     "c.category_id, c.name AS category_name, " + // Đảm bảo có category_id, category_name
                     "b.brand_id, b.name AS brand_name " +         // Đảm bảo có brand_id, brand_name
                     "FROM Products p " +
                     "LEFT JOIN Suppliers s ON p.supplier_id = s.supplier_id " +
                     "LEFT JOIN Categories c ON p.category_id = c.category_id " +
                     "LEFT JOIN Brands b ON p.brand_id = b.brand_id " +
                     "WHERE p.name = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, productName);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToProduct(rs);
                }
            }
        }
        return null;
    }

    // NEW: Lấy Product theo ID (có join để lấy đủ dữ liệu cho JSP và mapResultSetToProduct)
    public Product getProductById(Connection conn, Long productId) throws SQLException {
        String sql = "SELECT p.product_id, p.name, p.description, p.price, p.stock_quantity, p.material, p.status, p.created_at, p.updated_at, " +
                     "s.supplier_id, s.name AS supplier_name, " +
                     "c.category_id, c.name AS category_name, " +
                     "b.brand_id, b.name AS brand_name " +
                     "FROM Products p " +
                     "LEFT JOIN Suppliers s ON p.supplier_id = s.supplier_id " +
                     "LEFT JOIN Categories c ON p.category_id = c.category_id " +
                     "LEFT JOIN Brands b ON p.brand_id = b.brand_id " +
                     "WHERE p.product_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToProduct(rs); // Tái sử dụng mapResultSetToProduct
                }
            }
        }
        return null;
    }

    public Long createProduct(Connection conn, Product product) throws SQLException {
        String sql = "INSERT INTO products (name, description, price, stock_quantity, supplier_id, category_id, brand_id, material, status, created_at, updated_at) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, product.getName());
            ps.setString(2, product.getDescription());
            ps.setBigDecimal(3, product.getPrice());
            // Giả định Product model có getTotalStockQuantity() trả về Integer (có thể null)
            ps.setObject(4, product.getStockQuantity(), Types.INTEGER); 

            // Sử dụng các trường ID trực tiếp từ Product model
            // Giả định Product model có getSupplierId(), getCategoryId(), getBrandId()
            ps.setObject(5, product.getSupplierId(), Types.BIGINT);
            ps.setObject(6, product.getCategoryId(), Types.BIGINT);
            ps.setObject(7, product.getBrandId(), Types.BIGINT);

            ps.setString(8, product.getMaterial());
            ps.setString(9, product.getStatus());
            ps.setObject(10, product.getCreatedAt());
            ps.setObject(11, product.getUpdatedAt());

            int affectedRows = ps.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        return generatedKeys.getLong(1);
                    }
                }
            }
        }
        return null;
    }

    // NEW: Cập nhật thông tin Product
    public void updateProduct(Connection conn, Product product) throws SQLException {
        String sql = "UPDATE Products SET name = ?, description = ?, price = ?, supplier_id = ?, category_id = ?, brand_id = ?, material = ?, status = ?, updated_at = GETDATE() WHERE product_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, product.getName());
            ps.setString(2, product.getDescription());
            ps.setBigDecimal(3, product.getPrice());

            // Đảm bảo xử lý null cho các khóa ngoại
            // Giả định Product model có getSupplierId(), getCategoryId(), getBrandId()
            ps.setObject(4, product.getSupplierId(), Types.BIGINT);
            ps.setObject(5, product.getCategoryId(), Types.BIGINT);
            ps.setObject(6, product.getBrandId(), Types.BIGINT);

            ps.setString(7, product.getMaterial());
            ps.setString(8, product.getStatus());
            ps.setLong(9, product.getProductId());
            ps.executeUpdate();
        }
    }

    public void updateProductStock(Connection conn, Long productId, int newStockQuantity) throws SQLException {
        String sql = "UPDATE products SET stock_quantity = ?, updated_at = GETDATE() WHERE product_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, newStockQuantity);
            ps.setLong(2, productId);
            ps.executeUpdate();
        }
    }

    // NEW: Lấy tất cả Product (có join để lấy đủ dữ liệu cho JSP)
    public List<Product> getAllProducts(Connection conn) throws SQLException {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT p.product_id, p.name, p.description, p.price, p.stock_quantity, p.material, p.status, p.created_at, p.updated_at, " +
                     "s.supplier_id, s.name AS supplier_name, " +
                     "c.category_id, c.name AS category_name, " +
                     "b.brand_id, b.name AS brand_name " +
                     "FROM Products p " +
                     "LEFT JOIN Suppliers s ON p.supplier_id = s.supplier_id " +
                     "LEFT JOIN Categories c ON p.category_id = c.category_id " +
                     "LEFT JOIN Brands b ON p.brand_id = b.brand_id";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                products.add(mapResultSetToProduct(rs));
            }
        }
        return products;
    }

    // --- Các phương thức liên quan đến ProductVariant ---
    // Các phương thức này không thay đổi vì không liên quan đến cấu trúc model Brand/Category/Supplier

    private ProductVariant mapResultSetToProductVariant(ResultSet rs) throws SQLException {
        ProductVariant variant = new ProductVariant();
        variant.setVariantId(rs.getLong("variant_id"));
        variant.setProductId(rs.getLong("product_id"));
        variant.setSize(rs.getString("size"));
        variant.setColor(rs.getString("color"));
        variant.setQuantity(rs.getInt("quantity"));
        variant.setPrice(rs.getBigDecimal("price"));
        variant.setSku(rs.getString("sku"));
        variant.setCreatedAt(rs.getObject("created_at", LocalDateTime.class));
        return variant;
    }

    public ProductVariant getVariantByProductIdSizeColor(Connection conn, Long productId, String size, String color) throws SQLException {
        String sql = "SELECT * FROM product_variants WHERE product_id = ? AND size = ? AND color = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, productId);
            ps.setString(2, size);
            ps.setString(3, color);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToProductVariant(rs);
                }
            }
        }
        return null;
    }

    public Long createProductVariant(Connection conn, ProductVariant variant) throws SQLException {
        String sql = "INSERT INTO product_variants (product_id, size, color, quantity, price, sku, created_at) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setLong(1, variant.getProductId());
            ps.setString(2, variant.getSize());
            ps.setString(3, variant.getColor());
            ps.setInt(4, variant.getQuantity());
            if (variant.getPrice() != null) ps.setBigDecimal(5, variant.getPrice()); else ps.setNull(5, Types.DECIMAL);
            ps.setString(6, variant.getSku());
            ps.setObject(7, variant.getCreatedAt());

            int affectedRows = ps.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        return generatedKeys.getLong(1);
                    }
                }
            }
        }
        return null;
    }

    public void updateProductVariantQuantity(Connection conn, Long variantId, int newQuantity) throws SQLException {
        String sql = "UPDATE product_variants SET quantity = ? WHERE variant_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, newQuantity);
            ps.setLong(2, variantId);
            ps.executeUpdate();
        }
    }

    public int getTotalStockQuantityForProduct(Connection conn, Long productId) throws SQLException {
        String sql = "SELECT ISNULL(SUM(quantity), 0) FROM product_variants WHERE product_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    // --- Các phương thức liên quan đến Inventory ---
    // Các phương thức này không thay đổi

    private Inventory mapResultSetToInventory(ResultSet rs) throws SQLException {
        Inventory inventory = new Inventory();
        inventory.setInventoryId(rs.getLong("inventory_id"));
        inventory.setProductId(rs.getLong("product_id"));
        inventory.setVariantId(rs.getLong("variant_id"));
        inventory.setQuantity(rs.getInt("quantity"));
        inventory.setReservedQuantity(rs.getInt("reserved_quantity"));
        inventory.setLastUpdated(rs.getObject("last_updated", LocalDateTime.class));
        return inventory;
    }

    public Inventory getInventoryByProductVariant(Connection conn, Long productId, Long variantId) throws SQLException {
        String sql = "SELECT * FROM inventory WHERE product_id = ? AND variant_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, productId);
            ps.setLong(2, variantId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToInventory(rs);
                }
            }
        }
        return null;
    }

    public void createInventory(Connection conn, Inventory inventory) throws SQLException {
        String sql = "INSERT INTO inventory (product_id, variant_id, quantity, reserved_quantity, last_updated) VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, inventory.getProductId());
            ps.setLong(2, inventory.getVariantId());
            ps.setInt(3, inventory.getQuantity());
            ps.setInt(4, inventory.getReservedQuantity());
            ps.setObject(5, inventory.getLastUpdated());
            ps.executeUpdate();
        }
    }

    public void updateInventoryQuantity(Connection conn, Long inventoryId, int newQuantity) throws SQLException {
        String sql = "UPDATE inventory SET quantity = ?, last_updated = GETDATE() WHERE inventory_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, newQuantity);
            ps.setLong(2, inventoryId);
            ps.executeUpdate();
        }
    }

    // --- Các phương thức liên quan đến StockMovement ---
    // Các phương thức này không thay đổi

    public void createStockMovement(Connection conn, StockMovement movement) throws SQLException {
        String sql = "INSERT INTO stock_movements (product_id, variant_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, movement.getProductId());
            if (movement.getVariantId() != null) ps.setLong(2, movement.getVariantId()); else ps.setNull(2, Types.BIGINT);
            ps.setString(3, movement.getMovementType());
            ps.setInt(4, movement.getQuantity());
            ps.setString(5, movement.getReferenceType());
            if (movement.getReferenceId() != null) ps.setLong(6, movement.getReferenceId()); else ps.setNull(6, Types.BIGINT);
            ps.setString(7, movement.getNotes());
            if (movement.getCreatedBy() != null) ps.setLong(8, movement.getCreatedBy()); else ps.setNull(8, Types.BIGINT);
            ps.setObject(9, movement.getCreatedAt());
            ps.executeUpdate();
        }
    }

    // --- Các phương thức liên quan đến Category ---
    // Các phương thức này không thay đổi

    public List<Category> getAllCategories(Connection conn) throws SQLException {
        List<Category> categories = new ArrayList<>();
        String sql = "SELECT category_id, name FROM categories WHERE is_active = 1";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Category category = new Category();
                category.setCategoryId(rs.getLong("category_id"));
                category.setName(rs.getString("name"));
                categories.add(category);
            }
        }
        return categories;
    }

    public Category getCategoryByName(Connection conn, String name) throws SQLException {
        String sql = "SELECT category_id, name FROM categories WHERE name = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Category category = new Category();
                    category.setCategoryId(rs.getLong("category_id"));
                    category.setName(rs.getString("name"));
                    return category;
                }
            }
        }
        return null;
    }

    public Long createCategory(Connection conn, Category category) throws SQLException {
        String sql = "INSERT INTO categories (name, description, is_active, created_at) VALUES (?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, category.getName());
            ps.setString(2, category.getDescription() != null ? category.getDescription() : "Mô tả đang cập nhật");
            ps.setBoolean(3, category.getIsActive() != null ? category.getIsActive() : true);
            ps.setObject(4, category.getCreatedAt() != null ? category.getCreatedAt() : LocalDateTime.now());

            int affectedRows = ps.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        return generatedKeys.getLong(1);
                    }
                }
            }
        }
        return null;
    }

    // --- Các phương thức liên quan đến Brand ---
    // Các phương thức này không thay đổi

    public List<Brand> getAllBrands(Connection conn) throws SQLException {
        List<Brand> brands = new ArrayList<>();
        String sql = "SELECT brand_id, name FROM brands WHERE is_active = 1";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Brand brand = new Brand();
                brand.setBrandId(rs.getLong("brand_id"));
                brand.setName(rs.getString("name"));
                brands.add(brand);
            }
        }
        return brands;
    }

    public Brand getBrandByName(Connection conn, String name) throws SQLException {
        String sql = "SELECT brand_id, name FROM brands WHERE name = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Brand brand = new Brand();
                    brand.setBrandId(rs.getLong("brand_id"));
                    brand.setName(rs.getString("name"));
                    return brand;
                }
            }
        }
        return null;
    }

    public Long createBrand(Connection conn, Brand brand) throws SQLException {
        String sql = "INSERT INTO brands (name, description, logo_url, is_active, created_at) VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, brand.getName());
            ps.setString(2, brand.getDescription() != null ? brand.getDescription() : "Mô tả đang cập nhật");
            ps.setString(3, brand.getLogoUrl() != null ? brand.getLogoUrl() : "");
            ps.setBoolean(4, brand.getIsActive() != null ? brand.getIsActive() : true);
            ps.setObject(5, brand.getCreatedAt() != null ? brand.getCreatedAt() : LocalDateTime.now());

            int affectedRows = ps.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        return generatedKeys.getLong(1);
                    }
                }
            }
        }
        return null;
    }

    // --- Các phương thức liên quan đến Supplier ---
    // Các phương thức này không thay đổi

    public List<Supplier> getAllSuppliers(Connection conn) throws SQLException {
        List<Supplier> suppliers = new ArrayList<>();
        String sql = "SELECT supplier_id, name FROM suppliers WHERE is_active = 1";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Supplier supplier = new Supplier();
                supplier.setSupplierId(rs.getLong("supplier_id"));
                supplier.setName(rs.getString("name"));
                suppliers.add(supplier);
            }
        }
        return suppliers;
    }

    public Supplier getSupplierByName(Connection conn, String name) throws SQLException {
        String sql = "SELECT supplier_id, name FROM suppliers WHERE name = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Supplier supplier = new Supplier();
                    supplier.setSupplierId(rs.getLong("supplier_id"));
                    supplier.setName(rs.getString("name"));
                    return supplier;
                }
            }
        }
        return null;
    }

    public Long createSupplier(Connection conn, Supplier supplier) throws SQLException {
        String sql = "INSERT INTO suppliers (name, contact_email, phone_number, address, is_active, created_at) VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, supplier.getName());
            ps.setString(2, supplier.getContactEmail() != null ? supplier.getContactEmail() : "");
            ps.setString(3, supplier.getPhoneNumber() != null ? supplier.getPhoneNumber() : "");
            ps.setString(4, supplier.getAddress() != null ? supplier.getAddress() : "");
            ps.setBoolean(5, supplier.getIsActive() != null ? supplier.getIsActive() : true);
            ps.setObject(6, supplier.getCreatedAt() != null ? supplier.getCreatedAt() : LocalDateTime.now());

            int affectedRows = ps.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        return generatedKeys.getLong(1);
                    }
                }
            }
        }
        return null;
    }
}