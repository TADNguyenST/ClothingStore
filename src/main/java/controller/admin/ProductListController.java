package controller.admin;

import dao.ProductDAO;
import dao.CategoryDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Product;
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "ProductListController", urlPatterns = {"/ProductList"})
public class ProductListController extends HttpServlet {
    private ProductDAO productDAO;
    private CategoryDAO categoryDAO;

    @Override
    public void init() throws ServletException {
        productDAO = new ProductDAO();
        categoryDAO = new CategoryDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            // Lấy tham số từ request
            String categoryIdStr = request.getParameter("categoryId");
            String parentCategoryIdStr = request.getParameter("parentCategoryId");
            String offsetStr = request.getParameter("offset");

            Long categoryId = null;
            List<Long> categoryIds = new ArrayList<>();
            if (categoryIdStr != null && !categoryIdStr.trim().isEmpty()) {
                try {
                    categoryId = Long.parseLong(categoryIdStr);
                    categoryIds.add(categoryId);
                } catch (NumberFormatException e) {
                    System.err.println("Invalid categoryId: " + categoryIdStr);
                    categoryId = 3L;
                    categoryIds.add(categoryId);
                }
            } else if (parentCategoryIdStr != null && !parentCategoryIdStr.trim().isEmpty()) {
                try {
                    Long parentCategoryId = Long.parseLong(parentCategoryIdStr);
                    List<Long> subCategoryIds = categoryDAO.getSubCategoryIds(parentCategoryId);
                    if (subCategoryIds != null && !subCategoryIds.isEmpty()) {
                        categoryIds.addAll(subCategoryIds);
                    } else {
                        System.out.println("No subcategories found for parentCategoryId: " + parentCategoryId);
                        categoryIds.add(parentCategoryId); 
                    }
                    categoryId = parentCategoryId; 
                } catch (NumberFormatException e) {
                    System.err.println("Invalid parentCategoryId: " + parentCategoryIdStr);
                    categoryId = 3L;
                    categoryIds.add(categoryId);
                }
            } else {
                categoryId = 3L;
                categoryIds.add(categoryId);
            }

            int offset;
            try {
                offset = offsetStr != null && !offsetStr.trim().isEmpty() ? 
                         Integer.parseInt(offsetStr) : 0;
            } catch (NumberFormatException e) {
                System.err.println("Invalid offset: " + offsetStr);
                offset = 0;
            }

            List<Product> products = productDAO.getProductsByCategories(categoryIds, offset);

            request.setAttribute("products", products);
            request.setAttribute("categoryId", categoryId);
            request.setAttribute("offset", offset);

            // Forward JSP
            request.getRequestDispatcher("/WEB-INF/views/public/product/product-list.jsp").forward(request, response);
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