package controller.admin;

import dao.CategoryDAO;
import dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Category;
import model.Product;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "ProductListController", urlPatterns = {"/ProductList/*"})
public class ProductListController extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String action = request.getParameter("action");
            String pathInfo = request.getPathInfo();
            String productIdRaw = request.getParameter("productId");
            String parentCategoryIdRaw = request.getParameter("parentCategoryId");
            String categoryIdRaw = request.getParameter("categoryId");

            if ("autocomplete".equals(action)) {
                // Xử lý tìm kiếm autocomplete
                String keyword = request.getParameter("keyword");
                List<Product> products = productDAO.searchProducts(keyword);
                
                response.setContentType("text/html; charset=UTF-8");
                StringBuilder html = new StringBuilder();
                if (products != null && !products.isEmpty()) {
                    for (Product product : products) {
                        String imageUrl = product.getImageUrl() != null ? product.getImageUrl() : "https://placehold.co/50x50";
                        html.append("<div class='p-2 d-flex align-items-center suggestion-item' style='cursor: pointer;' ")
                            .append("onclick='window.location=\"${pageContext.request.contextPath}/ProductList/detail?productId=")
                            .append(product.getProductId()).append("\"'>")
                            .append("<img src='").append(imageUrl).append("' style='width: 50px; height: 50px; object-fit: cover; margin-right: 10px;' alt='")
                            .append(product.getName()).append("'>")
                            .append("<div>")
                            .append("<div>").append(product.getName()).append("</div>")
                            .append("<div>").append(product.getPrice() != null ? product.getPrice() : "N/A").append(" VNĐ</div>")
                            .append("</div>")
                            .append("</div>");
                    }
                } else {
                    html.append("<div class='p-2 text-muted'>Không tìm thấy sản phẩm</div>");
                }
                response.getWriter().write(html.toString());
                return; // Kết thúc xử lý để không tiếp tục logic khác
            }

            // Logic hiện tại của ProductListController
            String actionPath = (pathInfo != null && pathInfo.length() > 1) ? pathInfo.substring(1).toLowerCase() : "";

            // Load category data for menu
            List<Category> parentCategories = categoryDAO.getParentCategories();
            List<Category> allCategories = categoryDAO.getAllCategories();
            if (parentCategories == null) {
                parentCategories = new ArrayList<>();
            }
            if (allCategories == null) {
                allCategories = new ArrayList<>();
            }
            request.setAttribute("parentCategories", parentCategories);
            request.setAttribute("allCategories", allCategories);

            if ("detail".equals(actionPath) && productIdRaw != null && !productIdRaw.isEmpty()) {
                // Handle product detail request
                try {
                    long productId = Long.parseLong(productIdRaw);
                    Product product = productDAO.getProductById(productId);
                    if (product == null || !"Active".equalsIgnoreCase(product.getStatus())) {
                        request.setAttribute("error", "Product not found or not active.");
                        request.setAttribute("pageTitle", "Product Not Found");
                        request.getRequestDispatcher("/WEB-INF/views/public/product/product-details.jsp").forward(request, response);
                        return;
                    }
                    request.setAttribute("product", product);
                    request.setAttribute("pageTitle", product.getName() != null ? product.getName() : "Product Details");
                    request.getRequestDispatcher("/WEB-INF/views/public/product/product-details.jsp").forward(request, response);
                } catch (NumberFormatException e) {
                    request.setAttribute("error", "Invalid product ID format.");
                    request.setAttribute("pageTitle", "Product Not Found");
                    request.getRequestDispatcher("/WEB-INF/views/public/product/product-details.jsp").forward(request, response);
                }
            } else {
                // Handle product listing
                Long parentCategoryId = null;
                Long categoryId = null;
                String pageTitle = "Products";
                String errorMessage = null;

                // Handle slug-based filtering (e.g., /ProductList/men, /ProductList/women)
                if (pathInfo != null && pathInfo.length() > 1) {
                    String slug = pathInfo.substring(1).toLowerCase();
                    if (slug.equals("men") && !parentCategories.isEmpty()) {
                        parentCategoryId = parentCategories.get(0).getCategoryId();
                        pageTitle = parentCategories.get(0).getName() != null ? parentCategories.get(0).getName() + " Collection" : "Men's Collection";
                    } else if (slug.equals("women") && parentCategories.size() > 1) {
                        parentCategoryId = parentCategories.get(1).getCategoryId();
                        pageTitle = parentCategories.get(1).getName() != null ? parentCategories.get(1).getName() + " Collection" : "Women's Collection";
                    } else if (slug.equals("sale")) {
                        pageTitle = "Sale";
                        // TODO: Implement sale logic (e.g., filter products with discount)
                    } else {
                        errorMessage = "Invalid category.";
                    }
                }

                // Handle parameter-based filtering
                if (categoryIdRaw != null && !categoryIdRaw.isEmpty()) {
                    try {
                        categoryId = Long.parseLong(categoryIdRaw);
                        Category category = categoryDAO.getCategoryById(categoryId);
                        if (category != null && category.isActive()) {
                            pageTitle = category.getName() != null ? category.getName() : "Products";
                            // Validate parentCategoryId if provided
                            if (parentCategoryIdRaw != null && !parentCategoryIdRaw.isEmpty()) {
                                parentCategoryId = Long.parseLong(parentCategoryIdRaw);
                                Category parentCategory = categoryDAO.getCategoryById(parentCategoryId);
                                if (parentCategory != null && parentCategory.getParentCategoryId() == null && parentCategory.isActive()) {
                                    // Ensure subcategory belongs to parent category
                                    if (!category.getParentCategoryId().equals(parentCategoryId)) {
                                        errorMessage = "Subcategory does not belong to the specified parent category.";
                                        categoryId = null;
                                        parentCategoryId = null;
                                    } else {
                                        pageTitle = parentCategory.getName() + " - " + category.getName();
                                    }
                                } else {
                                    errorMessage = "Invalid or inactive parent category.";
                                    parentCategoryId = null;
                                }
                            } else {
                                // If no parentCategoryId provided, use the subcategory's parent
                                parentCategoryId = category.getParentCategoryId();
                                if (parentCategoryId != null) {
                                    Category parentCategory = categoryDAO.getCategoryById(parentCategoryId);
                                    if (parentCategory != null && parentCategory.isActive()) {
                                        pageTitle = parentCategory.getName() + " - " + category.getName();
                                    }
                                }
                            }
                        } else {
                            errorMessage = "Invalid or inactive subcategory.";
                            categoryId = null;
                        }
                    } catch (NumberFormatException e) {
                        errorMessage = "Invalid subcategory ID format.";
                    }
                } else if (parentCategoryIdRaw != null && !parentCategoryIdRaw.isEmpty()) {
                    try {
                        parentCategoryId = Long.parseLong(parentCategoryIdRaw);
                        Category category = categoryDAO.getCategoryById(parentCategoryId);
                        if (category != null && category.getParentCategoryId() == null && category.isActive()) {
                            pageTitle = category.getName() != null ? category.getName() + " Collection" : "Products";
                        } else {
                            errorMessage = "Invalid or inactive parent category.";
                            parentCategoryId = null;
                        }
                    } catch (NumberFormatException e) {
                        errorMessage = "Invalid parent category ID format.";
                    }
                }

                // Fetch products using ProductDAO.filterProducts
                List<Product> products = productDAO.filterProducts(
                        parentCategoryId,
                        categoryId,
                        null, // brandId
                        null, // size
                        null, // color
                        null, // minPrice
                        null, // maxPrice
                        "Active" // status
                );

                // Log for debugging
                System.out.println("ProductListController - Fetched " + products.size() + " products for parentCategoryId=" + parentCategoryId + ", categoryId=" + categoryId);

                request.setAttribute("products", products);
                request.setAttribute("pageTitle", pageTitle);
                if (errorMessage != null) {
                    request.setAttribute("error", errorMessage);
                }
                request.getRequestDispatcher("/WEB-INF/views/public/product/product-list.jsp").forward(request, response);
            }
        } catch (Exception e) {
            System.err.println("Error in ProductListController: " + e.getMessage());
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "An error occurred while processing the request.");
        }
    }

    @Override
    public String getServletInfo() {
        return "Handles public product listing, details, and autocomplete search";
    }
}