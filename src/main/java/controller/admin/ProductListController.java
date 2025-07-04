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
import java.math.BigDecimal;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

@WebServlet(name = "ProductListController", urlPatterns = {"/ProductList/*"})
public class ProductListController extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);
        try {
            String action = request.getParameter("action");
            String pathInfo = request.getPathInfo();
            String productIdRaw = request.getParameter("productId");
            String parentCategoryIdRaw = request.getParameter("parentCategoryId");
            String categoryIdRaw = request.getParameter("categoryId");
            String sort = request.getParameter("sort");
            String pageStr = request.getParameter("page");

            // Default sort and page
            if (sort == null || sort.trim().isEmpty() || sort.equals("default")) {
                sort = "default"; // Use default to indicate no specific sorting
            }
            int currentPage = 1;
            if (pageStr != null && !pageStr.isEmpty()) {
                try {
                    currentPage = Integer.parseInt(pageStr);
                    if (currentPage < 1) {
                        currentPage = 1;
                    }
                } catch (NumberFormatException e) {
                    System.out.println("Invalid page parameter: " + pageStr);
                }
            }

            // Log input parameters
            System.out.println("doGet - action: " + action + ", pathInfo: " + pathInfo + ", productIdRaw: " + productIdRaw
                    + ", parentCategoryIdRaw: " + parentCategoryIdRaw + ", categoryIdRaw: " + categoryIdRaw
                    + ", sort: " + sort + ", page: " + currentPage);
            if (currentPage == 1 && pageStr != null && pageStr.equals("1")) {
                System.out.println("doGet - Redundant page=1 parameter detected");
            }
            if ("default".equals(sort) && request.getParameter("sort") != null) {
                System.out.println("doGet - Redundant sort=default parameter detected");
            }

            // Handle autocomplete
            if ("autocomplete".equals(action)) {
                String keyword = request.getParameter("keyword");
                List<Product> products = productDAO.searchProducts(keyword);

                response.setContentType("text/html; charset=UTF-8");
                StringBuilder html = new StringBuilder();
                if (products != null && !products.isEmpty()) {
                    for (Product product : products) {
                        String imageUrl = product.getImageUrl() != null ? product.getImageUrl() : "https://placehold.co/50x50";
                        html.append("<div class='p-2 d-flex align-items-center suggestion-item' style='cursor: pointer;' ")
                                .append("onclick='window.location=\"")
                                .append(request.getContextPath()).append("/ProductList/detail?productId=")
                                .append(product.getProductId()).append("\"'>")
                                .append("<img src='").append(imageUrl).append("' style='width: 50px; height: 50px; object-fit: cover; margin-right: 10px;' alt='")
                                .append(product.getName() != null ? product.getName().replace("'", "\\'") : "Product").append("'>")
                                .append("<div>")
                                .append("<div>").append(product.getName() != null ? product.getName() : "N/A").append("</div>")
                                .append("<div>").append(product.getPrice() != null ? product.getPrice() : "N/A").append(" VNĐ</div>")
                                .append("</div>")
                                .append("</div>");
                    }
                } else {
                    html.append("<div class='p-2 text-muted'>Không tìm thấy sản phẩm</div>");
                }
                response.getWriter().write(html.toString());
                return;
            }

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

            // Handle actionPath safely
            String actionPath = "";
            if (pathInfo != null && pathInfo.length() > 1) {
                actionPath = pathInfo.substring(1).toLowerCase().replaceAll("/+$", "");
            }
            System.out.println("doGet - actionPath: " + actionPath);

            // Handle product detail
            if ("detail".equals(actionPath) && productIdRaw != null && !productIdRaw.isEmpty()) {
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
                return;
            }

            // Handle product list
            Long parentCategoryId = null;
            Long categoryId = null;
            String pageTitle = "Products";
            String errorMessage = null;

            // Handle slug-based filtering
            if (!actionPath.isEmpty()) {
                if (actionPath.equals("men") && !parentCategories.isEmpty()) {
                    parentCategoryId = parentCategories.get(0).getCategoryId();
                    pageTitle = parentCategories.get(0).getName() != null ? parentCategories.get(0).getName() + " Collection" : "Men's Collection";
                } else if (actionPath.equals("women") && parentCategories.size() > 1) {
                    parentCategoryId = parentCategories.get(1).getCategoryId();
                    pageTitle = parentCategories.get(1).getName() != null ? parentCategories.get(1).getName() + " Collection" : "Women's Collection";
                } else if (actionPath.equals("sale")) {
                    pageTitle = "Sale";
                    // TODO: Implement sale logic
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
                        if (parentCategoryIdRaw != null && !parentCategoryIdRaw.isEmpty()) {
                            parentCategoryId = Long.parseLong(parentCategoryIdRaw);
                            Category parentCategory = categoryDAO.getCategoryById(parentCategoryId);
                            if (parentCategory != null && parentCategory.getParentCategoryId() == null && parentCategory.isActive()) {
                                if (!category.getParentCategoryId().equals(parentCategoryId)) {
                                    errorMessage = "Subcategory does not belong to the specified parent category.";
                                    categoryId = null;
                                } else {
                                    pageTitle = parentCategory.getName() + " - " + category.getName();
                                }
                            } else {
                                errorMessage = "Invalid or inactive parent category.";
                                parentCategoryId = null;
                            }
                        } else {
                            parentCategoryId = category.getParentCategoryId();
                            if (parentCategoryId != null) {
                                Category parentCategory = categoryDAO.getCategoryById(parentCategoryId);
                                if (parentCategory != null && parentCategory.isActive()) {
                                    pageTitle = parentCategory.getName() + " - " + category.getName();
                                } else {
                                    parentCategoryId = null;
                                }
                            }
                        }
                    } else {
                        errorMessage = "Invalid or inactive subcategory.";
                        categoryId = null;
                    }
                } catch (NumberFormatException e) {
                    errorMessage = "Invalid subcategory ID format.";
                    categoryId = null;
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
                    parentCategoryId = null;
                }
            }

            // Log category parameters
            System.out.println("doGet - parentCategoryId: " + parentCategoryId + ", categoryId: " + categoryId + ", pageTitle: " + pageTitle + ", sort: " + sort);

            // Handle filter from JSP
            String[] colors = request.getParameterValues("colors");
            String[] sizes = request.getParameterValues("sizes");
            String priceRange = request.getParameter("priceRange");
            String[] brandIds = request.getParameterValues("brands");

            List<String> colorList = new ArrayList<>();
            if (colors != null) {
                for (String color : colors) {
                    if (color != null && !color.trim().isEmpty()) {
                        colorList.add(color.trim().toLowerCase());
                    }
                }
            }
            List<String> sizeList = new ArrayList<>();
            if (sizes != null) {
                for (String size : sizes) {
                    if (size != null && !size.trim().isEmpty()) {
                        sizeList.add(size.trim().toLowerCase());
                    }
                }
            }
            BigDecimal maxPrice = null;
            if (priceRange != null && !priceRange.trim().isEmpty() && !priceRange.equals("0")) {
                try {
                    maxPrice = new BigDecimal(priceRange.trim());
                } catch (NumberFormatException e) {
                    System.out.println("Invalid priceRange: " + priceRange);
                }
            }
            List<Long> brandIdList = new ArrayList<>();
            if (brandIds != null) {
                for (String id : brandIds) {
                    if (id != null && !id.trim().isEmpty()) {
                        try {
                            brandIdList.add(Long.parseLong(id.trim()));
                        } catch (NumberFormatException e) {
                            System.out.println("Invalid brandId: " + id);
                        }
                    }
                }
            }

            // Log filter parameters
            System.out.println("doGet - Filter params: colors=" + colorList + ", sizes=" + sizeList
                    + ", priceRange=" + priceRange + ", brandIds=" + brandIdList
                    + ", parentCategoryId=" + parentCategoryId + ", categoryId=" + categoryId + ", sort=" + sort);

            // Fetch products with sorting
            List<Product> products = productDAO.filterProductsForShopWithSort(
                    colorList.isEmpty() ? null : colorList,
                    sizeList.isEmpty() ? null : sizeList,
                    maxPrice,
                    brandIdList.isEmpty() ? null : brandIdList,
                    parentCategoryId,
                    categoryId,
                    currentPage,
                    9,
                    sort
            );

            // Count total products for pagination
            int totalProducts = productDAO.countProductsForShop(
                    colorList.isEmpty() ? null : colorList,
                    sizeList.isEmpty() ? null : sizeList,
                    maxPrice,
                    brandIdList.isEmpty() ? null : brandIdList,
                    parentCategoryId,
                    categoryId
            );
            int totalPages = (int) Math.ceil((double) totalProducts / 9.0);
            if (totalPages < 1) {
                totalPages = 1;
            }
            if (currentPage > totalPages) {
                currentPage = totalPages;
            }

            // Log pagination and products
            System.out.println("doGet - Fetched " + products.size() + " products, page=" + currentPage + ", totalPages=" + totalPages + ", sort=" + sort);
            for (Product product : products) {
                System.out.println("Product ID: " + product.getProductId() + ", Name: " + product.getName()
                        + ", Price: " + product.getPrice()
                        + ", Category ID: " + (product.getCategory() != null ? product.getCategory().getCategoryId() : "N/A")
                        + ", Category Name: " + (product.getCategory() != null ? product.getCategory().getName() : "N/A"));
            }

            // Handle AJAX response
            if (request.getHeader("X-Requested-With") != null && request.getHeader("X-Requested-With").equals("XMLHttpRequest")) {
                NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
                StringBuilder html = new StringBuilder();
                html.append("<div class='row' data-total-pages='").append(totalPages).append("'>");
                if (products != null && !products.isEmpty()) {
                    for (Product product : products) {
                        String imageUrl = product.getImageUrl() != null ? product.getImageUrl() : "https://placehold.co/400x500/f0f0f0/333?text=No+Image";
                        String name = product.getName() != null ? product.getName() : "Unknown Product";
                        String price = product.getPrice() != null ? currencyFormat.format(product.getPrice()) : "N/A";
                        Long variantId = product.getDefaultVariantId();
                        boolean hasVariant = variantId != null && variantId != 0;
                        html.append("<div class='col-lg-4 col-md-6 col-sm-6 col-12'>")
                                .append("<div class='product-card'>")
                                .append("<div class='product-image'>")
                                .append("<a href='").append(request.getContextPath()).append("/ProductList/detail?productId=").append(product.getProductId()).append("'>")
                                .append("<img src='").append(imageUrl).append("' alt='").append(name).append("'>")
                                .append("</a>")
                                .append("</div>")
                                .append("<a href='").append(request.getContextPath()).append("/ProductList/detail?productId=").append(product.getProductId()).append("' class='product-title'>").append(name).append("</a>")
                                .append("<p class='product-price'>").append(price).append("</p>")
                                .append("<div class='btn-container'>")
                                .append("<form action='").append(request.getContextPath()).append("/customer/cart' method='post'>")
                                .append("<input type='hidden' name='action' value='add'>")
                                .append("<input type='hidden' name='variantId' value='").append(hasVariant ? variantId : 0).append("'>")
                                .append("<input type='hidden' name='quantity' value='1'>")
                                .append("<button type='submit' class='btn btn-dark btn-custom-sm' ").append(hasVariant ? "" : "disabled").append(">Add to Cart</button>")
                                .append("</form>")
                                .append("<form action='").append(request.getContextPath()).append("/customer/checkout' method='post'>")
                                .append("<input type='hidden' name='action' value='buy'>")
                                .append("<input type='hidden' name='variantId' value='").append(hasVariant ? variantId : 0).append("'>")
                                .append("<input type='hidden' name='quantity' value='1'>")
                                .append("<button type='submit' class='btn btn-primary btn-custom-sm' ").append(hasVariant ? "" : "disabled").append(">Buy Now</button>")
                                .append("</form>")
                                .append("</div>")
                                .append("</div>")
                                .append("</div>");
                    }
                } else {
                    html.append("<div class='col-12 text-center'><p>No products found.</p></div>");
                }
                html.append("</div>");
                response.setContentType("text/html; charset=UTF-8");
                response.getWriter().write(html.toString());
                System.out.println("doGet - AJAX response sent with length: " + html.length());
                return;
            }

            request.setAttribute("products", products);
            request.setAttribute("pageTitle", pageTitle);
            request.setAttribute("currentPage", currentPage);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("sort", sort);
            if (errorMessage != null) {
                request.setAttribute("error", errorMessage);
            }
            request.setAttribute("brands", productDAO.getAllBrands());
            request.getRequestDispatcher("/WEB-INF/views/public/product/product-list.jsp").forward(request, response);

        } catch (Exception e) {
            System.err.println("Error in ProductListController: " + e.getMessage());
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "An error occurred while processing the request.");
        }
    }

    @Override
    public String getServletInfo() {
        return "Handles public product listing, details, and autocomplete search with enhanced filtering and sorting";
    }
}
