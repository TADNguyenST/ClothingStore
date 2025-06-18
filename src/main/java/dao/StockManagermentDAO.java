package dao;

import model.Inventory;
import model.Product;
import model.ProductVariant;
import model.Category;
import model.Brand;
import model.StockMovement; // Thêm import cho StockMovement
import util.DBContext;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

public class StockManagermentDAO {

    // --- CÁC PHƯƠNG THỨC LẤY DỮ LIỆU ĐÃ ĐƯỢC REFACTOR ---
    public List<Inventory> getAllInventories() throws SQLException {
        List<Inventory> inventoryList = new ArrayList<>();
        String sql = "SELECT * FROM inventory";
        try ( Connection conn = new DBContext().getConnection();  PreparedStatement ps = conn.prepareStatement(sql);  ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Inventory inventory = new Inventory();
                inventory.setInventoryId(rs.getLong("inventory_id"));
                inventory.setVariantId(rs.getLong("variant_id"));
                inventory.setQuantity(rs.getInt("quantity"));
                inventory.setReservedQuantity(rs.getInt("reserved_quantity"));
                inventory.setLastUpdated(rs.getTimestamp("last_updated").toLocalDateTime());
                inventoryList.add(inventory);
            }
        }
        return inventoryList;
    }

    public List<Product> getAllProducts() throws SQLException {
        List<Product> productList = new ArrayList<>();
        String sql = "SELECT * FROM products";
        try ( Connection conn = new DBContext().getConnection();  PreparedStatement ps = conn.prepareStatement(sql);  ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Product product = new Product();
                product.setProductId(rs.getLong("product_id"));
                product.setName(rs.getString("name"));
                product.setDescription(rs.getString("description"));
                product.setPrice(rs.getBigDecimal("price"));
                // 1. Lấy category_id, tạo đối tượng Category và set cho product
                Category category = new Category();
                category.setCategoryId(rs.getLong("category_id")); // Giả sử Category có phương thức setCategoryId()
                product.setCategory(category);

// 2. Tương tự, lấy brand_id, tạo đối tượng Brand và set cho product
                Brand brand = new Brand();
                brand.setBrandId(rs.getLong("brand_id")); // Giả sử Brand có phương thức setBrandId()
                product.setBrand(brand);
                product.setMaterial(rs.getString("material"));
                product.setStatus(rs.getString("status"));
                Timestamp createdAtTimestamp = rs.getTimestamp("created_at");
                if (createdAtTimestamp != null) {
                    product.setCreatedAt(createdAtTimestamp);
                }
                Timestamp updatedAtTimestamp = rs.getTimestamp("updated_at");
                if (updatedAtTimestamp != null) {
                    product.setUpdatedAt(updatedAtTimestamp);
                }
                productList.add(product);
            }
        }
        return productList;
    }

    public List<ProductVariant> getAllProductVariants() throws SQLException {
        List<ProductVariant> variantList = new ArrayList<>();
        String sql = "SELECT * FROM product_variants";
        try ( Connection conn = new DBContext().getConnection();  PreparedStatement ps = conn.prepareStatement(sql);  ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                ProductVariant variant = new ProductVariant();
                variant.setVariantId(rs.getLong("variant_id"));
                variant.setProductId(rs.getLong("product_id"));
                variant.setSize(rs.getString("size"));
                variant.setColor(rs.getString("color"));
                variant.setPriceModifier(rs.getBigDecimal("price_modifier"));
                variant.setSku(rs.getString("sku"));
                variantList.add(variant);
            }
        }
        return variantList;
    }

    public List<Category> getAllCategories() throws SQLException {
        List<Category> categories = new ArrayList<>();
        String sql = "SELECT * FROM categories ORDER BY name";
        try ( Connection conn = new DBContext().getConnection();  PreparedStatement ps = conn.prepareStatement(sql);  ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Category category = new Category();
                category.setCategoryId(rs.getLong("category_id"));
                category.setName(rs.getString("name"));
                // ... set các thuộc tính khác
                categories.add(category);
            }
        }
        return categories;
    }

    public List<Brand> getAllBrands() throws SQLException {
        List<Brand> brands = new ArrayList<>();
        String sql = "SELECT * FROM brands ORDER BY name";
        try ( Connection conn = new DBContext().getConnection();  PreparedStatement ps = conn.prepareStatement(sql);  ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Brand brand = new Brand();
                brand.setBrandId(rs.getLong("brand_id"));
                brand.setName(rs.getString("name"));
                // ... set các thuộc tính khác
                brands.add(brand);
            }
        }
        return brands;
    }

    public ProductVariant getProductVariantById(long variantId) throws SQLException {
        ProductVariant variant = null;
        String sql = "SELECT * FROM product_variants WHERE variant_id = ?";
        try ( Connection conn = new DBContext().getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, variantId);
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    variant = new ProductVariant();
                    variant.setVariantId(rs.getLong("variant_id"));
                    variant.setProductId(rs.getLong("product_id"));
                    variant.setSize(rs.getString("size"));
                    variant.setColor(rs.getString("color"));
                    variant.setPriceModifier(rs.getBigDecimal("price_modifier"));
                    variant.setSku(rs.getString("sku"));
                }
            }
        }
        return variant;
    }

    public Product getProductById(long productId) throws SQLException {
        Product product = null;
        // === SỬA LẠI CÂU SQL ĐỂ JOIN BẢNG ===
        String sql = "SELECT p.*, c.name as categoryName, b.name as brandName "
                + "FROM products p "
                + "LEFT JOIN categories c ON p.category_id = c.category_id "
                + "LEFT JOIN brands b ON p.brand_id = b.brand_id "
                + "WHERE p.product_id = ?";

        try ( Connection conn = new DBContext().getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, productId);
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    product = new Product();
                    product.setProductId(rs.getLong("product_id"));
                    product.setName(rs.getString("name"));
                    product.setDescription(rs.getString("description"));
                    product.setPrice(rs.getBigDecimal("price"));
                    product.setMaterial(rs.getString("material"));
                    product.setStatus(rs.getString("status"));
                    // Các trường created_at, updated_at...

                    // === TẠO ĐỐI TƯỢNG CATEGORY ĐẦY ĐỦ ===
                    Long categoryId = rs.getObject("category_id", Long.class);
                    if (categoryId != null) {
                        Category category = new Category();
                        category.setCategoryId(categoryId);
                        category.setName(rs.getString("categoryName")); // Lấy name từ kết quả JOIN
                        product.setCategory(category);
                    }

                    // === TẠO ĐỐI TƯỢNG BRAND ĐẦY ĐỦ ===
                    Long brandId = rs.getObject("brand_id", Long.class);
                    if (brandId != null) {
                        Brand brand = new Brand();
                        brand.setBrandId(brandId);
                        brand.setName(rs.getString("brandName")); // Lấy name từ kết quả JOIN
                        product.setBrand(brand);
                    }
                }
            }
        }
        return product;
    }

    // --- CÁC PHƯƠNG THỨC HIỆN CÓ CỦA BẠN (ĐÃ REFACTOR) ---
    public Inventory getInventoryByVariantId(long variantId) throws SQLException {
        try ( Connection conn = new DBContext().getConnection()) {
            return getInventoryByVariantId(variantId, conn); // Gọi phiên bản mới bên dưới
        }
    }

    // --- CÁC PHƯƠNG THỨC MỚI DÀNH CHO TRANSACTION (do Controller quản lý) ---
    /**
     * Lấy thông tin tồn kho bằng variantId, sử dụng một Connection đã có
     * sẵn.Dùng để đọc dữ liệu bên trong một transaction.
     *
     * @param variantId
     * @param conn
     * @return
     * @throws java.sql.SQLException
     */
    public Inventory getInventoryByVariantId(long variantId, Connection conn) throws SQLException {
        Inventory inventory = null;
        String sql = "SELECT * FROM inventory WHERE variant_id = ?";
        try ( PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, variantId);
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    inventory = new Inventory();
                    inventory.setInventoryId(rs.getLong("inventory_id"));
                    inventory.setVariantId(rs.getLong("variant_id"));
                    inventory.setQuantity(rs.getInt("quantity"));
                    inventory.setReservedQuantity(rs.getInt("reserved_quantity"));
                    inventory.setLastUpdated(rs.getTimestamp("last_updated").toLocalDateTime());
                }
            }
        }
        return inventory;
    }

    /**
     * Cập nhật số lượng tồn kho, sử dụng một Connection đã có sẵn.Dùng để thực
     * hiện UPDATE bên trong một transaction.
     *
     * @param inventory
     * @param conn
     * @return
     * @throws java.sql.SQLException
     */
    public boolean updateInventoryQuantities(Inventory inventory, Connection conn) throws SQLException {
        String sql = "UPDATE inventory SET quantity = ?, reserved_quantity = ?, last_updated = GETDATE() WHERE inventory_id = ?";
        try ( PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, inventory.getQuantity());
            ps.setInt(2, inventory.getReservedQuantity());
            ps.setLong(3, inventory.getInventoryId());
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Thêm một bản ghi mới vào lịch sử thay đổi kho, sử dụng Connection đã
     * có.Dùng để thực hiện INSERT bên trong một transaction.
     *
     * @param movement
     * @param conn
     * @throws java.sql.SQLException
     */
    public void addStockMovement(StockMovement movement, Connection conn) throws SQLException {
        String sql = "INSERT INTO stock_movements (variant_id, movement_type, quantity_changed, notes, created_by, reference_type, reference_id) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try ( PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, movement.getVariantId());
            ps.setString(2, movement.getMovementType());
            ps.setInt(3, movement.getQuantity());
            ps.setString(4, movement.getNotes());
            ps.setLong(5, movement.getCreatedBy());
            ps.setString(6, movement.getReferenceType());
            if (movement.getReferenceId() != null) {
                ps.setLong(7, movement.getReferenceId());
            } else {
                ps.setNull(7, java.sql.Types.BIGINT);
            }
            ps.executeUpdate();
        }
    }

    public int getTotalStockMovements() throws SQLException {
        String sql = "SELECT COUNT(*) FROM stock_movements";
        try ( Connection conn = new DBContext().getConnection();  PreparedStatement ps = conn.prepareStatement(sql);  ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }

    public List<Map<String, Object>> getPaginatedStockMovements(int offset, int limit) throws SQLException {
        List<Map<String, Object>> movementList = new ArrayList<>();
        String sql = "SELECT sm.*, p.name AS productName, pv.sku, pv.size, pv.color "
                + "FROM stock_movements sm "
                + "JOIN product_variants pv ON sm.variant_id = pv.variant_id "
                + "JOIN products p ON pv.product_id = p.product_id "
                + "ORDER BY sm.created_at DESC "
                + "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        try ( Connection conn = new DBContext().getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, offset);
            ps.setInt(2, limit);

            try ( ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    // Thay vì tạo DTO, chúng ta tạo một Map cho mỗi dòng
                    Map<String, Object> row = new HashMap<>();

                    // Đặt các giá trị vào Map với key là chuỗi
                    row.put("movementId", rs.getLong("movement_id"));
                    row.put("variantId", rs.getLong("variant_id"));
                    row.put("movementType", rs.getString("movement_type"));
                    row.put("quantityChanged", rs.getInt("quantity_changed"));
                    row.put("notes", rs.getString("notes"));
                    row.put("createdBy", rs.getLong("created_by"));

                    Timestamp ts = rs.getTimestamp("created_at");
                    if (ts != null) {
                        row.put("createdAt", ts.toLocalDateTime());
                    } else {
                        row.put("createdAt", null);
                    }

                    // Đặt các giá trị từ bảng join
                    row.put("productName", rs.getString("productName"));
                    row.put("sku", rs.getString("sku"));
                    row.put("size", rs.getString("size"));
                    row.put("color", rs.getString("color"));

                    movementList.add(row);
                }
            }
        }
        return movementList;
    }

    public Category getCategoryById(long categoryId) throws SQLException {
        Category category = null;
        String sql = "SELECT * FROM categories WHERE category_id = ?";
        try ( Connection conn = new DBContext().getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, categoryId);
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    category = new Category();
                    category.setCategoryId(rs.getLong("category_id"));
                    category.setName(rs.getString("name"));
                    category.setDescription(rs.getString("description"));
                    // ... set các thuộc tính khác nếu cần
                }
            }
        }
        return category;
    }

    public Brand getBrandById(long brandId) throws SQLException {
        Brand brand = null;
        String sql = "SELECT * FROM brands WHERE brand_id = ?";
        try ( Connection conn = new DBContext().getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, brandId);
            try ( ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    brand = new Brand();
                    brand.setBrandId(rs.getLong("brand_id"));
                    brand.setName(rs.getString("name"));
                    brand.setDescription(rs.getString("description"));
                }
            }
        }
        return brand;
    }

    public List<Map<String, Object>> getMovementHistoryByVariantId(long variantId) throws SQLException {
        List<Map<String, Object>> movementHistory = new ArrayList<>();

        // Câu lệnh SQL với JOIN và định dạng ngày tháng cho SQL Server
        String sql = "SELECT "
                + "   sm.movement_type, "
                + "   sm.quantity_changed, "
                + "   sm.notes, "
                + "   u.full_name AS staffName, "
                + "   FORMAT(sm.created_at, 'HH:mm:ss dd/MM/yyyy') AS createdAtFormatted "
                + "FROM stock_movements sm "
                + "LEFT JOIN staff s ON sm.created_by = s.staff_id "
                + "LEFT JOIN users u ON s.user_id = u.user_id "
                + "WHERE sm.variant_id = ? "
                + "ORDER BY sm.created_at DESC";

        try ( Connection conn = new DBContext().getConnection();  PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, variantId);

            try ( ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> movement = new HashMap<>();
                    movement.put("movementType", rs.getString("movement_type"));
                    movement.put("quantityChanged", rs.getInt("quantity_changed"));
                    movement.put("notes", rs.getString("notes"));
                    movement.put("staffName", rs.getString("staffName"));
                    movement.put("createdAtFormatted", rs.getString("createdAtFormatted"));

                    movementHistory.add(movement);
                }
            }
        }
        return movementHistory;
    }

}
