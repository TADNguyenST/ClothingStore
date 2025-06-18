package controller.stock;

import dao.StockManagermentDAO; // Đổi lại tên DAO của bạn nếu khác
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.*;

import java.io.IOException;
import java.sql.SQLException;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

// Bạn có thể cần đổi lại tên DAO cho đúng với file của bạn
// Ví dụ: import dao.StockManagermentDAO;

@WebServlet(name = "StockController", urlPatterns = {"/Stock"})
public class StockController extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(StockController.class.getName());
    
    // Đảm bảo tên DAO này khớp với tên file DAO của bạn
    private StockManagermentDAO stockDAO; 

    @Override
    public void init() throws ServletException {
        // Khởi tạo đúng DAO
        stockDAO = new StockManagermentDAO(); 
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            // === STEP 1: GET ALL PARAMETERS FROM THE REQUEST ===
            String searchTerm = request.getParameter("searchTerm");
            String filterCategory = request.getParameter("filterCategory");
            final String sortBy = request.getParameter("sortBy");
            String sortOrder = request.getParameter("sortOrder");
            String pageStr = request.getParameter("page");

            // === STEP 2: LOAD ALL DATA FROM THE DAO ===
            // Đảm bảo bạn đang gọi đúng phương thức từ DAO của mình
            List<Inventory> allInventories = stockDAO.getAllInventories();
            List<Product> allProducts = stockDAO.getAllProducts();
            List<ProductVariant> allVariants = stockDAO.getAllProductVariants();
            List<Category> allCategories = stockDAO.getAllCategories();
            List<Brand> allBrands = stockDAO.getAllBrands();

            // Create lookup Maps for quick access
            Map<Long, Product> productMap = new HashMap<>();
            for (Product p : allProducts) productMap.put(p.getProductId(), p);

            Map<Long, ProductVariant> variantMap = new HashMap<>();
            for (ProductVariant pv : allVariants) variantMap.put(pv.getVariantId(), pv);

            Map<Long, Category> categoryMap = new HashMap<>();
            for (Category c : allCategories) categoryMap.put(c.getCategoryId(), c);

            Map<Long, Brand> brandMap = new HashMap<>();
            for (Brand b : allBrands) brandMap.put(b.getBrandId(), b);

            // === STEP 3: FILTER DATA INTO A TEMPORARY LIST ===
            List<Map<String, Object>> fullFilteredList = new ArrayList<>();
            for (Inventory inventory : allInventories) {
                ProductVariant variant = variantMap.get(inventory.getVariantId());
                if (variant == null) continue;

                Product product = productMap.get(variant.getProductId());
                if (product == null) continue;

                // === SỬA LỖI DO CẬP NHẬT MODEL TẠI ĐÂY ===
                // Lấy Category object từ Product, sau đó dùng ID của nó để tra cứu trong Map.
                // Thêm kiểm tra null để tránh lỗi khi sản phẩm không có category/brand.
                Category category = null;
                if (product.getCategory() != null) {
                    category = categoryMap.get(product.getCategory().getCategoryId());
                }

                Brand brand = null;
                if (product.getBrand() != null) {
                    brand = brandMap.get(product.getBrand().getBrandId());
                }
                // ===========================================

                // Filter by Category logic
                if (filterCategory != null && !filterCategory.isEmpty() && !filterCategory.equals("all")) {
                    if (category == null || !filterCategory.equals(String.valueOf(category.getCategoryId()))) {
                        continue;
                    }
                }

                // Filter by search term logic
                if (searchTerm != null && !searchTerm.trim().isEmpty()) {
                    String lowerSearchTerm = searchTerm.toLowerCase().trim();
                    boolean found = (product.getName() != null && product.getName().toLowerCase().contains(lowerSearchTerm))
                            || (variant.getSku() != null && variant.getSku().toLowerCase().contains(lowerSearchTerm))
                            || (category != null && category.getName() != null && category.getName().toLowerCase().contains(lowerSearchTerm))
                            || (brand != null && brand.getName() != null && brand.getName().toLowerCase().contains(lowerSearchTerm));

                    if (!found) {
                        continue;
                    }
                }

                Map<String, Object> itemData = new HashMap<>();
                itemData.put("variantId", variant.getVariantId());
                itemData.put("productName", product.getName());
                itemData.put("sku", variant.getSku());
                itemData.put("size", variant.getSize());
                itemData.put("color", variant.getColor());
                itemData.put("categoryName", category != null ? category.getName() : "N/A");
                itemData.put("brandName", brand != null ? brand.getName() : "N/A");
                itemData.put("quantity", inventory.getQuantity());
                itemData.put("reservedQuantity", inventory.getReservedQuantity());
                itemData.put("availableQuantity", inventory.getQuantity() - inventory.getReservedQuantity());
                itemData.put("lastUpdated", inventory.getLastUpdated());
                fullFilteredList.add(itemData);
            }

            // === SORTING LOGIC (Phần này đã ổn) ===
            if (sortBy != null && !sortBy.trim().isEmpty()) {
                final String finalSortOrder = "desc".equalsIgnoreCase(sortOrder) ? "desc" : "asc";

                Collections.sort(fullFilteredList, new Comparator<Map<String, Object>>() {
                    @Override
                    public int compare(Map<String, Object> o1, Map<String, Object> o2) {
                        Comparable val1 = (Comparable) o1.get(sortBy);
                        Comparable val2 = (Comparable) o2.get(sortBy);

                        int comparison;
                        if (val1 == null && val2 == null) comparison = 0;
                        else if (val1 == null) comparison = -1;
                        else if (val2 == null) comparison = 1;
                        else comparison = val1.compareTo(val2);

                        return "asc".equals(finalSortOrder) ? comparison : -comparison;
                    }
                });
            }

            // === STEP 4: PERFORM PAGINATION ON THE RESULT LIST ===
            int currentPage = (pageStr == null || pageStr.isEmpty()) ? 1 : Integer.parseInt(pageStr);
            int itemsPerPage = 10;
            int totalItems = fullFilteredList.size();
            int totalPages = (int) Math.ceil((double) totalItems / itemsPerPage);
            int fromIndex = (currentPage - 1) * itemsPerPage;
            int toIndex = Math.min(fromIndex + itemsPerPage, totalItems);

            List<Map<String, Object>> displayListForPage = new ArrayList<>();
            if (fromIndex < toIndex) {
                displayListForPage = fullFilteredList.subList(fromIndex, toIndex);
            }

            // === STEP 5: SEND DATA TO THE JSP ===
            request.setAttribute("displayList", displayListForPage);
            request.setAttribute("categories", allCategories);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("currentPage", currentPage);
            request.setAttribute("searchTerm", searchTerm);
            request.setAttribute("filterCategory", filterCategory);
            request.setAttribute("sortBy", sortBy);
            request.setAttribute("sortOrder", sortOrder);

            // Sửa lại đường dẫn JSP của bạn nếu cần
            request.getRequestDispatcher("/WEB-INF/views/staff/stock/stock-statistics.jsp").forward(request, response);

        } catch (ServletException | IOException | NumberFormatException e) {
            LOGGER.log(Level.SEVERE, "Error in StockController", e);
            request.setAttribute("errorMessage", "An error occurred: " + e.getMessage());
            // Sửa lại đường dẫn JSP lỗi của bạn nếu cần
            request.getRequestDispatcher("/WEB-INF/views/staff/stock/error.jsp").forward(request, response);
        } catch (SQLException ex) {
            Logger.getLogger(StockController.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
}