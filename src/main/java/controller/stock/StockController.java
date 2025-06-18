package controller.stock;

import dao.InventoryDAO;
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

public class StockController extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(StockController.class.getName());
    private InventoryDAO inventoryDAO;

    @Override
    public void init() throws ServletException {
        inventoryDAO = new InventoryDAO();
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
            List<Inventory> allInventories = inventoryDAO.getAllInventories();
            List<Product> allProducts = inventoryDAO.getAllProducts();
            List<ProductVariant> allVariants = inventoryDAO.getAllProductVariants();
            List<Category> allCategories = inventoryDAO.getAllCategories();
            List<Brand> allBrands = inventoryDAO.getAllBrands();

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

                Category category = categoryMap.get(product.getCategoryId());
                Brand brand = brandMap.get(product.getBrandId());

                // Filter by Category logic
                if (filterCategory != null && !filterCategory.isEmpty() && !filterCategory.equals("all")) {
                    if (category == null || !filterCategory.equals(String.valueOf(category.getCategoryId()))) {
                        continue;
                    }
                }

                // Filter by search term logic
                if (searchTerm != null && !searchTerm.trim().isEmpty()) {
                    String lowerSearchTerm = searchTerm.toLowerCase().trim();

                    // Add null checks before calling .toLowerCase()
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

            // === SORTING FIX: USE JAVA 7 COMPATIBLE SYNTAX ===
            if (sortBy != null && !sortBy.trim().isEmpty()) {
                final String finalSortOrder = "desc".equalsIgnoreCase(sortOrder) ? "desc" : "asc";

                Collections.sort(fullFilteredList, new Comparator<Map<String, Object>>() {
                    @Override
                    public int compare(Map<String, Object> o1, Map<String, Object> o2) {
                        // Cast to Comparable to be able to compare both Strings and Integers
                        Comparable val1 = (Comparable) o1.get(sortBy);
                        Comparable val2 = (Comparable) o2.get(sortBy);

                        int comparison;
                        if (val1 == null && val2 == null) comparison = 0;
                        else if (val1 == null) comparison = -1; // Puts nulls first
                        else if (val2 == null) comparison = 1;
                        else comparison = val1.compareTo(val2);

                        return "asc".equals(finalSortOrder) ? comparison : -comparison;
                    }
                });
            }
            // ================================================================

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

            request.getRequestDispatcher("/WEB-INF/views/staff/stock/stock-statistics.jsp").forward(request, response);

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in StockController", e);
            request.setAttribute("errorMessage", "An error occurred: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(request, response);
        }
    }
}