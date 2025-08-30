package controller.admin;

import dao.ProductDAO;
import dao.CategoryDAO;
import dao.ProductFavoriteDAO;                          // ✅ NEW
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;               // ✅ NEW
import model.Product;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collections;                          // ✅ NEW
import java.util.List;
import java.util.Set;                                  // ✅ NEW
import java.util.stream.Collectors;                    // ✅ NEW

@WebServlet(name = "ProductListController", urlPatterns = {"/ProductList"})
public class ProductListController extends HttpServlet {

    private ProductDAO productDAO;
    private CategoryDAO categoryDAO;
    private ProductFavoriteDAO favoriteDAO;            // ✅ NEW

    @Override
    public void init() throws ServletException {
        productDAO = new ProductDAO();
        categoryDAO = new CategoryDAO();
        favoriteDAO = new ProductFavoriteDAO();        // ✅ NEW
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // ==== input ====
            String categoryIdStr = request.getParameter("categoryId");
            String parentCategoryIdStr = request.getParameter("parentCategoryId");
            String offsetStr = request.getParameter("offset");

            Long categoryId = null;
            List<Long> categoryIds = new ArrayList<>();

            // ==== phân loại theo category / parentCategory ====
            if ((categoryIdStr == null || categoryIdStr.trim().isEmpty())
                    && (parentCategoryIdStr == null || parentCategoryIdStr.trim().isEmpty())) {
                // không lọc -> dùng getAll
            } else if (categoryIdStr != null && !categoryIdStr.trim().isEmpty()) {
                try {
                    categoryId = Long.parseLong(categoryIdStr);
                    categoryIds.add(categoryId);
                } catch (NumberFormatException e) {
                    System.err.println("Invalid categoryId: " + categoryIdStr);
                }
            } else {
                try {
                    Long parentCategoryId = Long.parseLong(parentCategoryIdStr);
                    List<Long> subCategoryIds = categoryDAO.getSubCategoryIds(parentCategoryId);
                    if (subCategoryIds != null && !subCategoryIds.isEmpty()) {
                        categoryIds.addAll(subCategoryIds);
                    } else {
                        // không có sub -> dùng parent
                        categoryIds.add(parentCategoryId);
                    }
                    categoryId = parentCategoryId;
                } catch (NumberFormatException e) {
                    System.err.println("Invalid parentCategoryId: " + parentCategoryIdStr);
                }
            }

            int offset;
            try {
                offset = (offsetStr != null && !offsetStr.trim().isEmpty())
                        ? Integer.parseInt(offsetStr) : 0;
            } catch (NumberFormatException e) {
                System.err.println("Invalid offset: " + offsetStr);
                offset = 0;
            }

            // ==== lấy sản phẩm ====
            List<Product> products;
            if (categoryIds.isEmpty() && categoryId == null) {
                products = productDAO.getAll(null); // không lọc
            } else {
                products = productDAO.getProductsByCategories(categoryIds, offset);
            }

            // ==== wishlist ids cho user đang đăng nhập ====
            HttpSession session = request.getSession(false);
            Long customerId = null;
            if (session != null) {
                Object uid = session.getAttribute("userId");
                if (uid instanceof Long) customerId = (Long) uid;
                else if (uid instanceof Integer) customerId = ((Integer) uid).longValue();
            }

            Set<Long> wishlistProductIds = Collections.emptySet();
            if (customerId != null) {
                Set<Integer> rawIds = favoriteDAO.getWishlistProductIds(customerId);
                wishlistProductIds = rawIds.stream()
                        .map(Integer::longValue)
                        .collect(Collectors.toSet());
            }

            // ==== set attribute & forward ====
            request.setAttribute("products", products);
            request.setAttribute("categoryId", categoryId);
            request.setAttribute("offset", offset);
            request.setAttribute("wishlistProductIds", wishlistProductIds);   // ✅ NEW

            request.getRequestDispatcher("/WEB-INF/views/public/product/product-list.jsp")
                   .forward(request, response);

        } catch (SQLException e) {
            System.err.println("Database error in ProductListController: " + e.getMessage());
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Database error while retrieving products: " + e.getMessage());
        } catch (Exception e) {
            System.err.println("Unexpected error in ProductListController: " + e.getMessage());
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Error retrieving products: " + e.getMessage());
        }
    }
}
