// src/main/java/controller/stock/StockImportController.java
package controller.stock;

import dao.StockMovementDAO;
import model.Product;
import model.ProductVariant;
import model.Inventory;
import model.StockMovement;
import model.Category;
import model.Brand;
import model.Supplier;
import util.DBContext;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/stock/import")
public class StockImportController extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(StockImportController.class.getName());
    private StockMovementDAO stockMovementDAO;

    public StockImportController() {
        this.stockMovementDAO = new StockMovementDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Connection conn = null;
        try {
            DBContext dbContext = new DBContext();
            conn = dbContext.getConnection();

            List<Category> categories = stockMovementDAO.getAllCategories(conn);
            List<Brand> brands = stockMovementDAO.getAllBrands(conn);
            List<Supplier> suppliers = stockMovementDAO.getAllSuppliers(conn);
            List<Product> products = stockMovementDAO.getAllProducts(conn);


            request.setAttribute("categories", categories);
            request.setAttribute("brands", brands);
            request.setAttribute("suppliers", suppliers);
            request.setAttribute("products", products);

            request.setAttribute("currentAction", "stock-import");
            request.setAttribute("currentModule", "stock");
            request.setAttribute("pageTitle", "Nhập Kho Sản Phẩm");

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi khi tải dữ liệu cho form nhập kho: {0}", e.getMessage());
            request.setAttribute("errorMessage", "Lỗi khi tải dữ liệu: " + e.getMessage());
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    LOGGER.log(Level.SEVERE, "Lỗi khi đóng kết nối DB: {0}", e.getMessage());
                }
            }
        }
        request.getRequestDispatcher("/WEB-INF/views/staff/stock/import-stock.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        // ⭐ ĐỌC DỮ LIỆU TỪ CÁC HIDDEN FIELDS VÀ selectedProductId (CHÍNH XÁC) ⭐
        // productId_selected sẽ cho biết người dùng có chọn sản phẩm có sẵn hay không
        String productIdSelectedStr = request.getParameter("productId_selected"); 
        
        // Các trường thông tin sản phẩm chính
        String productName = request.getParameter("productName"); // Tên sản phẩm input (active khi là SP mới)
        String productNameHidden = request.getParameter("productName_hidden"); // Hidden field
        
        String productDescription = request.getParameter("productDescription");
        String productDescriptionHidden = request.getParameter("productDescription_hidden");

        String productPriceStr = request.getParameter("productPrice");
        String productPriceHiddenStr = request.getParameter("productPrice_hidden");
        
        String material = request.getParameter("material");
        String materialHidden = request.getParameter("material_hidden");

        // Các trường Supplier, Category, Brand
        String selectedSupplierId = request.getParameter("supplierId"); // Từ dropdown (active khi là SP mới)
        String selectedSupplierIdHidden = request.getParameter("supplierId_hidden"); // Hidden field
        String newSupplierName = request.getParameter("newSupplierName"); // Từ input text (active khi là SP mới)
        String newSupplierNameHidden = request.getParameter("newSupplierName_hidden"); // Hidden field

        String selectedCategoryId = request.getParameter("categoryId");
        String selectedCategoryIdHidden = request.getParameter("categoryId_hidden");
        String newCategoryName = request.getParameter("newCategoryName");
        String newCategoryNameHidden = request.getParameter("newCategoryName_hidden");

        String selectedBrandId = request.getParameter("brandId");
        String selectedBrandIdHidden = request.getParameter("brandId_hidden");
        String newBrandName = request.getParameter("newBrandName");
        String newBrandNameHidden = request.getParameter("newBrandName_hidden");

        // Thông tin biến thể (không bị ảnh hưởng bởi disable)
        String variantSize = request.getParameter("variantSize");
        String variantColor = request.getParameter("variantColor");
        String importQuantityStr = request.getParameter("importQuantity");
        String variantPriceStr = request.getParameter("variantPrice");
        String sku = request.getParameter("sku");
        String notes = request.getParameter("notes");

        HttpSession session = request.getSession();
        Long staffId = 1L;

        // --- Logic để chọn giá trị đúng từ các cặp input/hidden fields ---
        // Nếu productId_selected có giá trị, tức là người dùng đã chọn SP có sẵn.
        // Khi đó, các trường input/select gốc bị disabled, ta lấy giá trị từ hidden_fields.
        // Nếu productId_selected rỗng, tức là người dùng nhập SP mới, ta lấy từ input/select gốc.
        String finalProductName = (productIdSelectedStr != null && !productIdSelectedStr.trim().isEmpty()) ? productNameHidden : productName;
        String finalProductDescription = (productIdSelectedStr != null && !productIdSelectedStr.trim().isEmpty()) ? productDescriptionHidden : productDescription;
        String finalProductPriceStr = (productIdSelectedStr != null && !productIdSelectedStr.trim().isEmpty()) ? productPriceHiddenStr : productPriceStr;
        String finalMaterial = (productIdSelectedStr != null && !productIdSelectedStr.trim().isEmpty()) ? materialHidden : material;

        // Đối với Supplier/Category/Brand, logic phức tạp hơn một chút vì có 2 cặp input/select
        Long finalSupplierId = null;
        String finalNewSupplierName = null;
        if (productIdSelectedStr != null && !productIdSelectedStr.trim().isEmpty()) {
            // Nếu đã chọn sản phẩm có sẵn, lấy từ hidden (select hoặc new name)
            finalSupplierId = (selectedSupplierIdHidden != null && !selectedSupplierIdHidden.trim().isEmpty()) ? Long.parseLong(selectedSupplierIdHidden) : null;
            finalNewSupplierName = newSupplierNameHidden;
        } else {
            // Nếu nhập sản phẩm mới
            if (newSupplierName != null && !newSupplierName.trim().isEmpty()) {
                finalNewSupplierName = newSupplierName;
            } else if (selectedSupplierId != null && !selectedSupplierId.trim().isEmpty()) {
                finalSupplierId = Long.parseLong(selectedSupplierId);
            }
        }
        
        Long finalCategoryId = null;
        String finalNewCategoryName = null;
        if (productIdSelectedStr != null && !productIdSelectedStr.trim().isEmpty()) {
            finalCategoryId = (selectedCategoryIdHidden != null && !selectedCategoryIdHidden.trim().isEmpty()) ? Long.parseLong(selectedCategoryIdHidden) : null;
            finalNewCategoryName = newCategoryNameHidden;
        } else {
            if (newCategoryName != null && !newCategoryName.trim().isEmpty()) {
                finalNewCategoryName = newCategoryName;
            } else if (selectedCategoryId != null && !selectedCategoryId.trim().isEmpty()) {
                finalCategoryId = Long.parseLong(selectedCategoryId);
            }
        }

        Long finalBrandId = null;
        String finalNewBrandName = null;
        if (productIdSelectedStr != null && !productIdSelectedStr.trim().isEmpty()) {
            finalBrandId = (selectedBrandIdHidden != null && !selectedBrandIdHidden.trim().isEmpty()) ? Long.parseLong(selectedBrandIdHidden) : null;
            finalNewBrandName = newBrandNameHidden;
        } else {
            if (newBrandName != null && !newBrandName.trim().isEmpty()) {
                finalNewBrandName = newBrandName;
            } else if (selectedBrandId != null && !selectedBrandId.trim().isEmpty()) {
                finalBrandId = Long.parseLong(selectedBrandId);
            }
        }

        // --- Validate các trường BẮT BUỘC bằng các giá trị ĐÚNG ĐẮN đã chọn ---
        if (finalProductName == null || finalProductName.trim().isEmpty() ||
            variantSize == null || variantSize.trim().isEmpty() ||
            variantColor == null || variantColor.trim().isEmpty() ||
            importQuantityStr == null || importQuantityStr.trim().isEmpty() ||
            (finalSupplierId == null && (finalNewSupplierName == null || finalNewSupplierName.trim().isEmpty())) ||
            (finalCategoryId == null && (finalNewCategoryName == null || finalNewCategoryName.trim().isEmpty())) ||
            (finalBrandId == null && (finalNewBrandName == null || finalNewBrandName.trim().isEmpty()))
        ) {
            request.setAttribute("errorMessage", "Vui lòng điền đầy đủ các trường bắt buộc (*).");
            // Gán lại các giá trị form để người dùng không phải nhập lại sau khi lỗi
            request.setAttribute("selectedProductId", productIdSelectedStr); // Để JSP có thể set lại dropdown sản phẩm
            request.setAttribute("productName", finalProductName);
            request.setAttribute("productDescription", finalProductDescription);
            request.setAttribute("productPrice", finalProductPriceStr);
            request.setAttribute("material", finalMaterial);
            request.setAttribute("supplierId", finalSupplierId != null ? String.valueOf(finalSupplierId) : "");
            request.setAttribute("newSupplierName", finalNewSupplierName);
            request.setAttribute("categoryId", finalCategoryId != null ? String.valueOf(finalCategoryId) : "");
            request.setAttribute("newCategoryName", finalNewCategoryName);
            request.setAttribute("brandId", finalBrandId != null ? String.valueOf(finalBrandId) : "");
            request.setAttribute("newBrandName", finalNewBrandName);
            request.setAttribute("variantSize", variantSize);
            request.setAttribute("variantColor", variantColor);
            request.setAttribute("importQuantity", importQuantityStr);
            request.setAttribute("variantPrice", variantPriceStr);
            request.setAttribute("sku", sku);
            request.setAttribute("notes", notes);

            doGet(request, response);
            return;
        }

        BigDecimal productPrice = null;
        if (finalProductPriceStr != null && !finalProductPriceStr.trim().isEmpty()) {
            try {
                productPrice = new BigDecimal(finalProductPriceStr);
            } catch (NumberFormatException e) {
                request.setAttribute("errorMessage", "Giá sản phẩm không hợp lệ.");
                doGet(request, response);
                return;
            }
        }
        // ... (phần code parse importQuantity và variantPrice giữ nguyên) ...
        int importQuantity = 0;
        try {
            importQuantity = Integer.parseInt(importQuantityStr);
            if (importQuantity <= 0) {
                request.setAttribute("errorMessage", "Số lượng nhập phải lớn hơn 0.");
                doGet(request, response);
                return;
            }
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Số lượng nhập không hợp lệ.");
            doGet(request, response);
            return;
        }

        BigDecimal variantPrice = null;
        if (variantPriceStr != null && !variantPriceStr.trim().isEmpty()) {
            try {
                variantPrice = new BigDecimal(variantPriceStr);
            } catch (NumberFormatException e) {
                request.setAttribute("errorMessage", "Giá biến thể không hợp lệ.");
                doGet(request, response);
                return;
            }
        }


        Connection conn = null;

        try {
            DBContext dbContext = new DBContext();
            conn = dbContext.getConnection();
            conn.setAutoCommit(false);

            // --- Xử lý Supplier ---
            // finalNewSupplierName và finalSupplierId đã được xác định ở trên
            if (finalNewSupplierName != null && !finalNewSupplierName.trim().isEmpty()) {
                Supplier existingSupplier = stockMovementDAO.getSupplierByName(conn, finalNewSupplierName.trim());
                if (existingSupplier != null) {
                    finalSupplierId = existingSupplier.getSupplierId();
                    LOGGER.log(Level.INFO, "Đã tìm thấy nhà cung cấp '{0}' với ID: {1}", new Object[]{finalNewSupplierName, finalSupplierId});
                } else {
                    Supplier newSupplier = new Supplier();
                    newSupplier.setName(finalNewSupplierName.trim());
                    finalSupplierId = stockMovementDAO.createSupplier(conn, newSupplier);
                    if (finalSupplierId == null) throw new SQLException("Không thể tạo nhà cung cấp mới.");
                    LOGGER.log(Level.INFO, "Đã tạo nhà cung cấp mới '{0}' với ID: {1}", new Object[]{finalNewSupplierName, finalSupplierId});
                }
            } else if (finalSupplierId == null) { // Nếu cả 2 đều rỗng hoặc null
                throw new IllegalArgumentException("Nhà cung cấp là bắt buộc.");
            }

            // --- Xử lý Category ---
            if (finalNewCategoryName != null && !finalNewCategoryName.trim().isEmpty()) {
                Category existingCategory = stockMovementDAO.getCategoryByName(conn, finalNewCategoryName.trim());
                if (existingCategory != null) {
                    finalCategoryId = existingCategory.getCategoryId();
                    LOGGER.log(Level.INFO, "Đã tìm thấy danh mục '{0}' với ID: {1}", new Object[]{finalNewCategoryName, finalCategoryId});
                } else {
                    Category newCategory = new Category();
                    newCategory.setName(finalNewCategoryName.trim());
                    finalCategoryId = stockMovementDAO.createCategory(conn, newCategory);
                    if (finalCategoryId == null) throw new SQLException("Không thể tạo danh mục mới.");
                    LOGGER.log(Level.INFO, "Đã tạo danh mục mới '{0}' với ID: {1}", new Object[]{finalNewCategoryName, finalCategoryId});
                }
            } else if (finalCategoryId == null) {
                throw new IllegalArgumentException("Danh mục là bắt buộc.");
            }

            // --- Xử lý Brand ---
            if (finalNewBrandName != null && !finalNewBrandName.trim().isEmpty()) {
                Brand existingBrand = stockMovementDAO.getBrandByName(conn, finalNewBrandName.trim());
                if (existingBrand != null) {
                    finalBrandId = existingBrand.getBrandId();
                    LOGGER.log(Level.INFO, "Đã tìm thấy thương hiệu '{0}' với ID: {1}", new Object[]{finalNewBrandName, finalBrandId});
                } else {
                    Brand newBrand = new Brand();
                    newBrand.setName(finalNewBrandName.trim());
                    finalBrandId = stockMovementDAO.createBrand(conn, newBrand);
                    if (finalBrandId == null) throw new SQLException("Không thể tạo thương hiệu mới.");
                    LOGGER.log(Level.INFO, "Đã tạo thương hiệu mới '{0}' với ID: {1}", new Object[]{finalNewBrandName, finalBrandId});
                }
            } else if (finalBrandId == null) {
                throw new IllegalArgumentException("Thương hiệu là bắt buộc.");
            }

            Long productId;
            Product product;

            if (productIdSelectedStr != null && !productIdSelectedStr.trim().isEmpty()) {
                // Người dùng đã chọn một sản phẩm hiện có từ dropdown
                productId = Long.parseLong(productIdSelectedStr); // Lấy ID từ productId_selected
                product = stockMovementDAO.getProductById(conn, productId);
                if (product == null) {
                    throw new IllegalArgumentException("Sản phẩm được chọn không tồn tại.");
                }

                // Cập nhật thông tin sản phẩm bằng giá trị từ finalProductName/Description/Price/Material
                product.setName(finalProductName);
                product.setDescription(finalProductDescription != null ? finalProductDescription : product.getDescription());
                product.setPrice(productPrice != null ? productPrice : product.getPrice()); // productPrice đã được parse từ finalProductPriceStr
                product.setMaterial(finalMaterial != null ? finalMaterial : product.getMaterial());
                
                // Cập nhật các ID khóa ngoại
                product.setSupplierId(finalSupplierId);
                product.setCategoryId(finalCategoryId);
                product.setBrandId(finalBrandId);

                // Cập nhật các đối tượng lồng nhau (để đảm bảo tính nhất quán nếu sau này có dùng)
                Supplier tempSupplier = new Supplier(); tempSupplier.setSupplierId(finalSupplierId); product.setSupplier(tempSupplier);
                Category tempCategory = new Category(); tempCategory.setCategoryId(finalCategoryId); product.setCategory(tempCategory);
                Brand tempBrand = new Brand(); tempBrand.setBrandId(finalBrandId); product.setBrand(tempBrand);

                stockMovementDAO.updateProduct(conn, product);
                LOGGER.log(Level.INFO, "Đã cập nhật thông tin sản phẩm hiện có với ID: {0}", productId);

            } else {
                // Người dùng không chọn sản phẩm, là sản phẩm mới
                product = stockMovementDAO.getProductByName(conn, finalProductName); // Kiểm tra tên sản phẩm đã tồn tại chưa
                if (product != null) {
                    throw new IllegalArgumentException("Sản phẩm với tên '" + finalProductName + "' đã tồn tại. Vui lòng chọn từ danh sách hoặc nhập tên khác.");
                }

                if (finalProductDescription == null || finalProductDescription.trim().isEmpty()) finalProductDescription = "Mô tả đang cập nhật";
                if (finalMaterial == null || finalMaterial.trim().isEmpty()) finalMaterial = "Không rõ";
                if (productPrice == null) { // productPrice đã được parse từ finalProductPriceStr
                    throw new IllegalArgumentException("Giá sản phẩm là bắt buộc khi tạo sản phẩm mới.");
                }

                Product newProduct = new Product();
                newProduct.setName(finalProductName);
                newProduct.setDescription(finalProductDescription);
                newProduct.setPrice(productPrice);
                newProduct.setStockQuantity(0);
                newProduct.setMaterial(finalMaterial);
                newProduct.setStatus("Active");
                newProduct.setCreatedAt(LocalDateTime.now());
                newProduct.setUpdatedAt(LocalDateTime.now());
                
                newProduct.setSupplierId(finalSupplierId);
                newProduct.setCategoryId(finalCategoryId);
                newProduct.setBrandId(finalBrandId);

                Supplier tempSupplier = new Supplier(); tempSupplier.setSupplierId(finalSupplierId); newProduct.setSupplier(tempSupplier);
                Category tempCategory = new Category(); tempCategory.setCategoryId(finalCategoryId); newProduct.setCategory(tempCategory);
                Brand tempBrand = new Brand(); tempBrand.setBrandId(finalBrandId); newProduct.setBrand(tempBrand);

                productId = stockMovementDAO.createProduct(conn, newProduct);
                if (productId == null) {
                    throw new SQLException("Không thể tạo sản phẩm mới.");
                }
                product = newProduct;
                product.setProductId(productId);
                LOGGER.log(Level.INFO, "Đã tạo sản phẩm mới với ID: {0}", productId);
            }

            ProductVariant variant = stockMovementDAO.getVariantByProductIdSizeColor(conn, productId, variantSize, variantColor);
            Long variantId;

            if (variant == null) {
                if (sku == null || sku.trim().isEmpty()) {
                    sku = generateSku(finalProductName, variantSize, variantColor); // SKU dùng finalProductName
                }
                variant = new ProductVariant(null, productId, variantSize, variantColor, importQuantity, variantPrice, sku, LocalDateTime.now());
                variantId = stockMovementDAO.createProductVariant(conn, variant);
                if (variantId == null) {
                    throw new SQLException("Không thể tạo biến thể sản phẩm mới.");
                }
                variant.setVariantId(variantId);
                LOGGER.log(Level.INFO, "Đã tạo biến thể mới với ID: {0} cho sản phẩm {1}", new Object[]{variantId, productId});

                Inventory newInventory = new Inventory(null, productId, variantId, importQuantity, 0, LocalDateTime.now());
                stockMovementDAO.createInventory(conn, newInventory);
                LOGGER.log(Level.INFO, "Đã tạo bản ghi tồn kho mới cho biến thể {0}", variantId);

            } else {
                variantId = variant.getVariantId();
                int currentVariantQuantity = variant.getQuantity();
                stockMovementDAO.updateProductVariantQuantity(conn, variantId, currentVariantQuantity + importQuantity);
                LOGGER.log(Level.INFO, "Đã cập nhật số lượng biến thể {0}. Số lượng cũ: {1}, nhập thêm: {2}", new Object[]{variantId, currentVariantQuantity, importQuantity});

                Inventory existingInventory = stockMovementDAO.getInventoryByProductVariant(conn, productId, variantId);
                if (existingInventory != null) {
                    stockMovementDAO.updateInventoryQuantity(conn, existingInventory.getInventoryId(), existingInventory.getQuantity() + importQuantity);
                    LOGGER.log(Level.INFO, "Đã cập nhật số lượng tồn kho cho biến thể {0}. Số lượng cũ: {1}, nhập thêm: {2}", new Object[]{variantId, existingInventory.getQuantity(), importQuantity});
                } else {
                    Inventory newInventory = new Inventory(null, productId, variantId, importQuantity, 0, LocalDateTime.now());
                    stockMovementDAO.createInventory(conn, newInventory);
                    LOGGER.log(Level.WARNING, "Biến thể {0} tồn tại nhưng không có bản ghi tồn kho, đã tạo mới.", variantId);
                }
            }

            int totalProductStock = stockMovementDAO.getTotalStockQuantityForProduct(conn, productId);
            stockMovementDAO.updateProductStock(conn, productId, totalProductStock);
            LOGGER.log(Level.INFO, "Đã cập nhật tổng số lượng tồn kho của sản phẩm {0} thành: {1}", new Object[]{productId, totalProductStock});

            StockMovement stockMovement = new StockMovement(null, productId, variantId, "In", importQuantity, "Adjustment", null, notes, staffId, LocalDateTime.now());
            stockMovementDAO.createStockMovement(conn, stockMovement);
            LOGGER.log(Level.INFO, "Đã ghi lại lịch sử nhập kho cho sản phẩm {0}, biến thể {1}, số lượng {2}", new Object[]{productId, variantId, importQuantity});

            conn.commit();
            request.setAttribute("successMessage", "Nhập kho thành công cho sản phẩm '" + finalProductName + "' (Kích cỡ: " + variantSize + ", Màu: " + variantColor + ", Số lượng: " + importQuantity + ").");
            doGet(request, response);
        } catch (IllegalArgumentException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                    LOGGER.log(Level.WARNING, "Giao dịch đã được rollback do lỗi nghiệp vụ: {0}", e.getMessage());
                } catch (SQLException ex) {
                    LOGGER.log(Level.SEVERE, "Lỗi khi rollback giao dịch: {0}", ex.getMessage());
                }
            }
            request.setAttribute("errorMessage", e.getMessage());
            doGet(request, response);
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                    LOGGER.log(Level.SEVERE, "Giao dịch đã được rollback do lỗi SQL: {0}", e.getMessage());
                } catch (SQLException ex) {
                    LOGGER.log(Level.SEVERE, "Lỗi khi rollback giao dịch: {0}", ex.getMessage());
                }
            }
            LOGGER.log(Level.SEVERE, "Lỗi cơ sở dữ liệu khi nhập kho: {0}", e.getMessage());
            request.setAttribute("errorMessage", "Lỗi cơ sở dữ liệu khi nhập kho: " + e.getMessage());
            doGet(request, response);
        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback();
                    LOGGER.log(Level.SEVERE, "Giao dịch đã được rollback do lỗi không xác định: {0}", e.getMessage());
                } catch (SQLException ex) {
                    LOGGER.log(Level.SEVERE, "Lỗi khi rollback giao dịch: {0}", ex.getMessage());
                }
            }
            LOGGER.log(Level.SEVERE, "Lỗi hệ thống không xác định khi nhập kho: {0}", e.getMessage());
            request.setAttribute("errorMessage", "Lỗi hệ thống không xác định: " + e.getMessage());
            doGet(request, response);
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    LOGGER.log(Level.SEVERE, "Lỗi khi đóng kết nối DB: {0}", e.getMessage());
                }
            }
        }
    }

    private String generateSku(String productName, String size, String color) {
        String productPart = productName.replaceAll("[^a-zA-Z0-9]", "").toUpperCase();
        if (productPart.length() > 5) productPart = productPart.substring(0, 5);
        String sizePart = size.replaceAll("[^a-zA-Z0-9]", "").toUpperCase();
        if (sizePart.length() > 3) sizePart = sizePart.substring(0, 3);
        String colorPart = color.replaceAll("[^a-zA-Z0-9]", "").toUpperCase();
        if (colorPart.length() > 3) colorPart = colorPart.substring(0, 3);

        return (productPart + "-" + sizePart + "-" + colorPart + "-" + System.currentTimeMillis() % 100000).toUpperCase();
    }
}