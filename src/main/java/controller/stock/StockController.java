package controller.stock;

import dao.PurchaseOrderDAO; // <<< THÊM VÀO
import dao.StockManagermentDAO;
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

@WebServlet(name = "StockController", urlPatterns = {"/Stock"})
public class StockController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(StockController.class.getName());

    private StockManagermentDAO stockDAO;
    private PurchaseOrderDAO purchaseDAO; // <<< THÊM VÀO

    @Override
    public void init() throws ServletException {
        stockDAO = new StockManagermentDAO();
        purchaseDAO = new PurchaseOrderDAO(); // <<< THÊM VÀO
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            // === STEP 1: GET ALL PARAMETERS FROM THE REQUEST ===
            String viewMode = request.getParameter("viewMode"); // <<< THÊM VÀO
            String searchTerm = request.getParameter("searchTerm");
            String filterCategory = request.getParameter("filterCategory");
            final String sortBy = request.getParameter("sortBy");
            String sortOrder = request.getParameter("sortOrder");
            String pageStr = request.getParameter("page");

            // === STEP 2: LOAD ALL DATA FROM THE DAO ===
            List<Inventory> allInventories = stockDAO.getAllInventories();
            List<Product> allProducts = stockDAO.getAllProducts();
            List<ProductVariant> allVariants = stockDAO.getAllProductVariants();
            List<Category> allCategories = stockDAO.getAllCategories();
            List<Brand> allBrands = stockDAO.getAllBrands();

            // === STEP 2.1: CREATE LOOKUP MAPS ===
            Map<Long, Product> productMap = new HashMap<>();
            for (Product p : allProducts) {
                productMap.put(p.getProductId(), p);
            }

            Map<Long, ProductVariant> variantMap = new HashMap<>();
            for (ProductVariant pv : allVariants) {
                variantMap.put(pv.getVariantId(), pv);
            }

            Map<Long, Integer> inventoryQuantityMap = new HashMap<>();
            for (Inventory i : allInventories) {
                inventoryQuantityMap.put(i.getVariantId(), i.getQuantity());
            }

            Map<Long, Category> categoryMap = new HashMap<>();
            for (Category c : allCategories) {
                categoryMap.put(c.getCategoryId(), c);
            }

            Map<Long, Brand> brandMap = new HashMap<>();
            for (Brand b : allBrands) {
                brandMap.put(b.getBrandId(), b);
            }

            // === STEP 3: BUILD, JOIN AND FILTER DATA IN MEMORY ===
            List<Map<String, Object>> fullFilteredList = new ArrayList<>();
            // <<< SỬA NHỎ: Lặp qua tất cả variant thay vì chỉ inventory >>>
            for (ProductVariant variant : allVariants) {
                Product product = productMap.get(variant.getProductId());
                if (product == null) {
                    continue;
                }

                Category category = (product.getCategory() != null) ? categoryMap.get(product.getCategory().getCategoryId()) : null;
                Brand brand = (product.getBrand() != null) ? brandMap.get(product.getBrand().getBrandId()) : null;

                // --- LOGIC FILTER GỐC CỦA BẠN (GIỮ NGUYÊN) ---
                if (filterCategory != null && !filterCategory.isEmpty() && !filterCategory.equals("all")) {
                    if (category == null || !filterCategory.equals(String.valueOf(category.getCategoryId()))) {
                        continue;
                    }
                }

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
                // --- KẾT THÚC LOGIC FILTER ---

                Map<String, Object> itemData = new HashMap<>();
                itemData.put("variantId", variant.getVariantId());
                itemData.put("productName", product.getName());
                itemData.put("sku", variant.getSku());
                itemData.put("size", variant.getSize());
                itemData.put("color", variant.getColor());
                itemData.put("categoryName", category != null ? category.getName() : "N/A");
                itemData.put("brandName", brand != null ? brand.getName() : "N/A");
                itemData.put("quantity", inventoryQuantityMap.getOrDefault(variant.getVariantId(), 0));

                fullFilteredList.add(itemData);
            }

            // === SORTING LOGIC (GIỮ NGUYÊN) ===
            if (sortBy != null && !sortBy.trim().isEmpty()) {
                final String finalSortOrder = "desc".equalsIgnoreCase(sortOrder) ? "desc" : "asc";

                Collections.sort(fullFilteredList, new Comparator<Map<String, Object>>() {
                    @Override
                    public int compare(Map<String, Object> o1, Map<String, Object> o2) {
                        // Logic so sánh bên trong không thay đổi
                        Comparable val1 = (Comparable) o1.get(sortBy);
                        Comparable val2 = (Comparable) o2.get(sortBy);

                        int comparison;
                        if (val1 == null && val2 == null) {
                            comparison = 0;
                        } else if (val1 == null) {
                            comparison = -1; // nulls first
                        } else if (val2 == null) {
                            comparison = 1;
                        } else {
                            comparison = val1.compareTo(val2);
                        }

                        // Đảo ngược kết quả nếu sắp xếp giảm dần
                        return "asc".equals(finalSortOrder) ? comparison : -comparison;
                    }
                });
            }

            // === STEP 4: PERFORM PAGINATION (GIỮ NGUYÊN) ===
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

            // <<< THÊM VÀO: Logic quyết định trang JSP sẽ hiển thị >>>
            if ("selector".equals(viewMode)) {
                long poId = Long.parseLong(request.getParameter("poId"));
                request.setAttribute("poId", poId);
                request.getRequestDispatcher("/WEB-INF/views/staff/stock/product-selector.jsp").forward(request, response);
            } else {
                List<Supplier> suppliers = purchaseDAO.getAllActiveSuppliers();
                request.setAttribute("suppliersForModal", suppliers);
                request.getRequestDispatcher("/WEB-INF/views/staff/stock/stock-statistics.jsp").forward(request, response);
            }

        } catch (ServletException | IOException | NumberFormatException | SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in StockController", e);
            throw new ServletException("An unexpected error occurred in StockController", e);
        }
    }
}
