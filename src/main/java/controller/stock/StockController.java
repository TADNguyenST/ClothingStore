package controller.stock;

import com.google.gson.Gson;
import dao.PurchaseOrderDAO;
import dao.StockManagermentDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
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
    private PurchaseOrderDAO purchaseDAO;
    private final Gson gson = new Gson(); // Khởi tạo Gson

    @Override
    public void init() throws ServletException {
        stockDAO = new StockManagermentDAO();
        purchaseDAO = new PurchaseOrderDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Users currentUser = (Users) session.getAttribute("admin");
        if (currentUser == null) {
            currentUser = (Users) session.getAttribute("staff");
        }

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/AdminLogin");
            return;
        }
        try {

            // Lấy tham số từ request
            String searchTerm = request.getParameter("searchTerm");
            String filterCategory = request.getParameter("filterCategory");
            String sortBy = request.getParameter("sortBy");
            String sortOrder = request.getParameter("sortOrder");
            String pageStr = request.getParameter("page");
            String clear = request.getParameter("clear");
            String isAjaxRequest = request.getParameter("ajax");

            // Xử lý xóa bộ lọc
            if ("true".equals(clear)) {
                session.removeAttribute("stock_searchTerm");
                session.removeAttribute("stock_filterCategory");
                session.removeAttribute("stock_sortBy");
                session.removeAttribute("stock_sortOrder");
                if ("true".equals(isAjaxRequest)) { // Nếu yêu cầu xóa filter là ajax
                    response.setContentType("application/json");
                    response.setCharacterEncoding("UTF-8");
                    response.getWriter().write("{\"status\":\"cleared\"}");
                    return;
                } else {
                    response.sendRedirect(request.getContextPath() + "/Stock");
                    return;
                }
            }

            // Xử lý session cho các tham số
            boolean newFilterSubmitted = searchTerm != null || filterCategory != null || sortBy != null;
            if (newFilterSubmitted) {
                session.setAttribute("stock_searchTerm", searchTerm);
                session.setAttribute("stock_filterCategory", filterCategory);
                session.setAttribute("stock_sortBy", sortBy);
                session.setAttribute("stock_sortOrder", sortOrder);
            } else {
                searchTerm = (String) session.getAttribute("stock_searchTerm");
                filterCategory = (String) session.getAttribute("stock_filterCategory");
                sortBy = (String) session.getAttribute("stock_sortBy");
                sortOrder = (String) session.getAttribute("stock_sortOrder");
            }

            // Tải tất cả dữ liệu từ DAO
            List<Inventory> allInventories = stockDAO.getAllInventories();
            List<Product> allProducts = stockDAO.getAllProducts();
            List<ProductVariant> allVariants = stockDAO.getAllProductVariants();
            List<Category> allCategories = stockDAO.getAllCategories();
            List<Brand> allBrands = stockDAO.getAllBrands();

            // Tạo các Map để tra cứu
            Map<Long, Product> productMap = new HashMap<>();
            for (Product p : allProducts) {
                productMap.put(p.getProductId(), p);
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

            // === Lọc và xây dựng danh sách kết quả (Phiên bản an toàn) ===
            List<Map<String, Object>> fullFilteredList = new ArrayList<>();
            for (ProductVariant variant : allVariants) {
                Product product = productMap.get(variant.getProductId());
                if (product == null || variant == null || product.getName() == null) {
                    continue;
                }

                Category category = (product.getCategory() != null) ? categoryMap.get(product.getCategory().getCategoryId()) : null;
                Brand brand = (product.getBrand() != null) ? brandMap.get(product.getBrand().getBrandId()) : null;

                if (filterCategory != null && !filterCategory.isEmpty() && !filterCategory.equals("all")) {
                    if (category == null || !filterCategory.equals(String.valueOf(category.getCategoryId()))) {
                        continue;
                    }
                }

                if (searchTerm != null && !searchTerm.trim().isEmpty()) {
                    String lowerSearchTerm = searchTerm.toLowerCase().trim();
                    boolean nameMatch = product.getName().toLowerCase().contains(lowerSearchTerm);
                    boolean skuMatch = (variant.getSku() != null) && variant.getSku().toLowerCase().contains(lowerSearchTerm);
                    boolean categoryMatch = (category != null && category.getName() != null) && category.getName().toLowerCase().contains(lowerSearchTerm);
                    boolean brandMatch = (brand != null && brand.getName() != null) && brand.getName().toLowerCase().contains(lowerSearchTerm);
                    if (!(nameMatch || skuMatch || categoryMatch || brandMatch)) {
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
                itemData.put("quantity", inventoryQuantityMap.getOrDefault(variant.getVariantId(), 0));
                fullFilteredList.add(itemData);
            }

            // Sắp xếp
            final String effectiveSortBy = sortBy;
            if (effectiveSortBy != null && !effectiveSortBy.trim().isEmpty()) {
                final String finalSortOrder = "desc".equalsIgnoreCase(sortOrder) ? "desc" : "asc";
                Collections.sort(fullFilteredList, new Comparator<Map<String, Object>>() {
                    @Override
                    public int compare(Map<String, Object> o1, Map<String, Object> o2) {
                        Comparable val1 = (Comparable) o1.get(effectiveSortBy);
                        Comparable val2 = (Comparable) o2.get(effectiveSortBy);
                        int comparison;
                        if (val1 == null && val2 == null) {
                            comparison = 0;
                        } else if (val1 == null) {
                            comparison = -1;
                        } else if (val2 == null) {
                            comparison = 1;
                        } else {
                            comparison = val1.compareTo(val2);
                        }
                        return "asc".equals(finalSortOrder) ? comparison : -comparison;
                    }
                });
            }
            // Phân trang
            int currentPage = (pageStr == null || pageStr.isEmpty()) ? 1 : Integer.parseInt(pageStr);
            int itemsPerPage = 10;
            int totalItems = fullFilteredList.size();
            int totalPages = (int) Math.ceil((double) totalItems / itemsPerPage);
            int fromIndex = (currentPage - 1) * itemsPerPage;
            int toIndex = Math.min(fromIndex + itemsPerPage, totalItems);
            List<Map<String, Object>> displayListForPage = (List<Map<String, Object>>) ((fromIndex < toIndex) ? new ArrayList<>(fullFilteredList.subList(fromIndex, toIndex)) : new ArrayList<>());

            // === PHÂN LOẠI YÊU CẦU ĐỂ TRẢ VỀ KẾT QUẢ ===
            if ("true".equals(isAjaxRequest)) {
                // Yêu cầu AJAX: Trả về JSON
                Map<String, Object> jsonData = new HashMap<>();
                jsonData.put("products", displayListForPage);
                jsonData.put("totalPages", totalPages);
                jsonData.put("currentPage", currentPage);
                jsonData.put("totalItems", totalItems);

                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write(gson.toJson(jsonData));
            } else {
                // Yêu cầu tải trang bình thường: Forward đến JSP
                request.setAttribute("displayList", displayListForPage);
                request.setAttribute("categories", allCategories);
                request.setAttribute("totalPages", totalPages);
                request.setAttribute("currentPage", currentPage);
                request.setAttribute("totalItems", totalItems); // Gửi thêm tổng số kết quả
                request.setAttribute("searchTerm", searchTerm);
                request.setAttribute("filterCategory", filterCategory);
                request.setAttribute("sortBy", sortBy);
                request.setAttribute("sortOrder", sortOrder);

                List<Supplier> suppliers = purchaseDAO.getAllActiveSuppliers();
                request.setAttribute("suppliersForModal", suppliers);

                request.getRequestDispatcher("/WEB-INF/views/staff/stock/stock-statistics.jsp").forward(request, response);
            }

        } catch (ServletException | IOException | NumberFormatException | SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in StockController", e);
            // Nếu là yêu cầu ajax thì trả về lỗi JSON, nếu không thì ném exception
            if ("true".equals(request.getParameter("ajax"))) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"error\":\"An internal server error occurred.\"}");
            } else {
                throw new ServletException("An unexpected error occurred in StockController", e);
            }
        }
    }

}
