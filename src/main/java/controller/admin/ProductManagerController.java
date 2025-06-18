/*
 * Click nbproject://SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbproject://SystemFileSystem/Templates/J2EE/Servlet.java to edit this template
 */
package controller.admin;

import dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;
import model.Brand;
import model.Category;
import model.Product;
import model.Users;

@WebServlet(name = "ProductManagerController", urlPatterns = {"/ProductManager"})
public class ProductManagerController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // HttpSession session = request.getSession();
        // Users acc = (Users) session.getAttribute("user");
        ProductDAO dao = new ProductDAO();

        // Require authentication
        // if (acc == null) {
        //     response.sendRedirect("Login");
        //     return;
        // }

        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        if (action.equalsIgnoreCase("list")) {
            List<Product> data = dao.getAll();
            request.setAttribute("list", data);
            // Provide categories and brands for filter dropdowns
            List<Category> categories = dao.getAllCategories();
            List<Brand> brands = dao.getAllBrands();
            request.setAttribute("categories", categories);
            request.setAttribute("brands", brands);
            request.getRequestDispatcher("products.jsp").forward(request, response);
        } else if (action.equalsIgnoreCase("create")) {
            List<Category> categories = dao.getAllCategories();
            List<Brand> brands = dao.getAllBrands();
            request.setAttribute("categories", categories);
            request.setAttribute("brands", brands);
            request.getRequestDispatcher("create-product.jsp").forward(request, response);
        } else if (action.equalsIgnoreCase("delete")) {
            String idRaw = request.getParameter("id");
            try {
                long id = Long.parseLong(idRaw);
                int result = dao.delete(id);
                if (result == 1) {
                    request.setAttribute("msg", "<p class='text-success'>Product deleted successfully!</p>");
                } else {
                    request.setAttribute("err", "<p class='text-danger'>Failed to delete product with ID: " + id + "</p>");
                }
            } catch (NumberFormatException e) {
                request.setAttribute("err", "<p class='text-danger'>Invalid product ID</p>");
            } catch (Exception e) {
                request.setAttribute("err", "<p class='text-danger'>Error deleting product: " + e.getMessage() + "</p>");
            }
            List<Product> data = dao.getAll();
            request.setAttribute("list", data);
            request.getRequestDispatcher("products.jsp").forward(request, response);
        } else if (action.equalsIgnoreCase("update")) {
            String idRaw = request.getParameter("id");
            try {
                long id = Long.parseLong(idRaw);
                Product product = dao.getProductById(id);
                if (product == null) {
                    request.setAttribute("err", "<p class='text-danger'>Product not found with ID: " + id + "</p>");
                    List<Product> data = dao.getAll();
                    request.setAttribute("list", data);
                    request.getRequestDispatcher("products.jsp").forward(request, response);
                } else {
                    request.setAttribute("data", product);
                    // Provide categories and brands for dropdowns
                    List<Category> categories = dao.getAllCategories();
                    List<Brand> brands = dao.getAllBrands();
                    request.setAttribute("categories", categories);
                    request.setAttribute("brands", brands);
                    request.getRequestDispatcher("edit-product.jsp").forward(request, response);
                }
            } catch (NumberFormatException e) {
                request.setAttribute("err", "<p class='text-danger'>Invalid product ID</p>");
                List<Product> data = dao.getAll();
                request.setAttribute("list", data);
                request.getRequestDispatcher("products.jsp").forward(request, response);
            } catch (Exception e) {
                request.setAttribute("err", "<p class='text-danger'>Error retrieving product: " + e.getMessage() + "</p>");
                List<Product> data = dao.getAll();
                request.setAttribute("list", data);
                request.getRequestDispatcher("products.jsp").forward(request, response);
            }
        } else if (action.equalsIgnoreCase("detail")) {
            String idRaw = request.getParameter("id");
            try {
                long id = Long.parseLong(idRaw);
                Product product = dao.getProductById(id);
                if (product == null) {
                    request.setAttribute("err", "<p class='text-danger'>Product not found with ID: " + id + "</p>");
                } else {
                    request.setAttribute("data", product);
                }
                request.getRequestDispatcher("productDetail.jsp").forward(request, response);
            } catch (NumberFormatException e) {
                request.setAttribute("err", "<p class='text-danger'>Invalid product ID</p>");
                request.getRequestDispatcher("productDetail.jsp").forward(request, response);
            } catch (Exception e) {
                request.setAttribute("err", "<p class='text-danger'>Error retrieving product: " + e.getMessage() + "</p>");
                request.getRequestDispatcher("productDetail.jsp").forward(request, response);
            }
        } else if (action.equalsIgnoreCase("filter")) {
            String categoryIdRaw = request.getParameter("categoryId");
            String brandIdRaw = request.getParameter("brandId");
            String size = request.getParameter("size");
            String color = request.getParameter("color");
            String minPriceRaw = request.getParameter("minPrice");
            String maxPriceRaw = request.getParameter("maxPrice");

            // Parse categoryId
            Long categoryId = null;
            if (categoryIdRaw != null && !categoryIdRaw.isEmpty()) {
                try {
                    categoryId = Long.parseLong(categoryIdRaw);
                    if (!dao.categoryExists(categoryId)) {
                        request.setAttribute("err", "<p class='text-danger'>Invalid Category ID: " + categoryIdRaw + "</p>");
                        categoryId = null; // Ignore invalid category
                    }
                } catch (NumberFormatException e) {
                    System.out.println("Invalid Long format for categoryId: " + categoryIdRaw);
                    request.setAttribute("err", "<p class='text-danger'>Invalid Category ID format</p>");
                }
            }

            // Parse brandId
            Long brandId = null;
            if (brandIdRaw != null && !brandIdRaw.isEmpty()) {
                try {
                    brandId = Long.parseLong(brandIdRaw);
                    if (!dao.brandExists(brandId)) {
                        request.setAttribute("err", "<p class='text-danger'>Invalid Brand ID: " + brandIdRaw + "</p>");
                        brandId = null; // Ignore invalid brand
                    }
                } catch (NumberFormatException e) {
                    System.out.println("Invalid Long format for brandId: " + brandIdRaw);
                    request.setAttribute("err", "<p class='text-danger'>Invalid Brand ID format</p>");
                }
            }

            // Parse minPrice
            BigDecimal minPrice = null;
            if (minPriceRaw != null && !minPriceRaw.isEmpty()) {
                try {
                    // Remove thousand separators (dots) and convert comma to decimal point
                    minPrice = new BigDecimal(minPriceRaw.replace(".", "").replace(",", "."));
                } catch (NumberFormatException e) {
                    System.out.println("Invalid BigDecimal format for minPrice: " + minPriceRaw);
                    request.setAttribute("err", "<p class='text-danger'>Invalid Min Price format</p>");
                }
            }

            // Parse maxPrice
            BigDecimal maxPrice = null;
            if (maxPriceRaw != null && !maxPriceRaw.isEmpty()) {
                try {
                    // Remove thousand separators (dots) and convert comma to decimal point
                    maxPrice = new BigDecimal(maxPriceRaw.replace(".", "").replace(",", "."));
                } catch (NumberFormatException e) {
                    System.out.println("Invalid BigDecimal format for maxPrice: " + maxPriceRaw);
                    request.setAttribute("err", "<p class='text-danger'>Invalid Max Price format</p>");
                }
            }

            // Validate price range
            if (minPrice != null && maxPrice != null && minPrice.compareTo(maxPrice) > 0) {
                request.setAttribute("err", "<p class='text-danger'>Min Price cannot be greater than Max Price</p>");
                minPrice = null;
                maxPrice = null;
            }

            List<Product> data = dao.filterProducts(categoryId, brandId, size, color, minPrice, maxPrice);
            request.setAttribute("list", data);
            if (data.isEmpty()) {
                request.setAttribute("err", "<p class='text-danger'>No products found matching the filter criteria</p>");
            }
            // Provide categories and brands for filter dropdowns
            List<Category> categories = dao.getAllCategories();
            List<Brand> brands = dao.getAllBrands();
            request.setAttribute("categories", categories);
            request.setAttribute("brands", brands);
            request.getRequestDispatcher("products.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // HttpSession session = request.getSession();
        // Users acc = (Users) session.getAttribute("user");
        ProductDAO dao = new ProductDAO();

        // Require authentication
        // if (acc == null) {
        //     response.sendRedirect("Login");
        //     return;
        // }

        String action = request.getParameter("action");
        if (action.equalsIgnoreCase("create")) {
            String name = request.getParameter("name");
            String description = request.getParameter("description");
            String priceRaw = request.getParameter("price");
            String categoryIdRaw = request.getParameter("categoryId");
            String brandIdRaw = request.getParameter("brandId");
            String material = request.getParameter("material");
            String status = request.getParameter("status");

            try {
                // Validate required fields
                if (name == null || name.trim().isEmpty()) {
                    throw new IllegalArgumentException("Name is required");
                }
                if (priceRaw == null || priceRaw.trim().isEmpty()) {
                    throw new IllegalArgumentException("Price is required");
                }
                if (categoryIdRaw == null || categoryIdRaw.trim().isEmpty()) {
                    throw new IllegalArgumentException("Category is required");
                }
                if (brandIdRaw == null || brandIdRaw.trim().isEmpty()) {
                    throw new IllegalArgumentException("Brand is required");
                }

                // Remove thousand separators (dots) and convert comma to decimal point
                priceRaw = priceRaw.replace(".", "").replace(",", ".");
                BigDecimal price = new BigDecimal(priceRaw);
                long categoryId = Long.parseLong(categoryIdRaw);
                long brandId = Long.parseLong(brandIdRaw);

                // Validate category and brand existence
                if (!dao.categoryExists(categoryId)) {
                    throw new IllegalArgumentException("Invalid Category ID: " + categoryId);
                }
                if (!dao.brandExists(brandId)) {
                    throw new IllegalArgumentException("Invalid Brand ID: " + brandId);
                }

                int res = dao.insert(name, description, price, categoryId, brandId, material, status);
                if (res == 1) {
                    response.sendRedirect("ProductManager");
                } else {
                    request.setAttribute("err", "<p class='text-danger'>Create failed: Database error</p>");
                    List<Category> categories = dao.getAllCategories();
                    List<Brand> brands = dao.getAllBrands();
                    request.setAttribute("categories", categories);
                    request.setAttribute("brands", brands);
                    request.getRequestDispatcher("create-product.jsp").forward(request, response);
                }
            } catch (NumberFormatException e) {
                System.err.println("NumberFormatException in create: " + e.getMessage());
                request.setAttribute("err", "<p class='text-danger'>Invalid input format: Please check Price, Category, or Brand</p>");
                List<Category> categories = dao.getAllCategories();
                List<Brand> brands = dao.getAllBrands();
                request.setAttribute("categories", categories);
                request.setAttribute("brands", brands);
                request.getRequestDispatcher("create-product.jsp").forward(request, response);
            } catch (IllegalArgumentException e) {
                System.err.println("IllegalArgumentException in create: " + e.getMessage());
                request.setAttribute("err", "<p class='text-danger'>" + e.getMessage() + "</p>");
                List<Category> categories = dao.getAllCategories();
                List<Brand> brands = dao.getAllBrands();
                request.setAttribute("categories", categories);
                request.setAttribute("brands", brands);
                request.getRequestDispatcher("create-product.jsp").forward(request, response);
            } catch (Exception e) {
                System.err.println("Unexpected error in create: " + e.getMessage());
                e.printStackTrace();
                request.setAttribute("err", "<p class='text-danger'>Error creating product: " + e.getMessage() + "</p>");
                List<Category> categories = dao.getAllCategories();
                List<Brand> brands = dao.getAllBrands();
                request.setAttribute("categories", categories);
                request.setAttribute("brands", brands);
                request.getRequestDispatcher("create-product.jsp").forward(request, response);
            }
        } else if (action.equalsIgnoreCase("update")) {
            String idRaw = request.getParameter("id");
            String name = request.getParameter("name");
            String description = request.getParameter("description");
            String priceRaw = request.getParameter("price");
            String categoryIdRaw = request.getParameter("categoryId");
            String brandIdRaw = request.getParameter("brandId");
            String material = request.getParameter("material");
            String status = request.getParameter("status");

            try {
                // Validate required fields
                if (name == null || name.trim().isEmpty()) {
                    throw new IllegalArgumentException("Name is required");
                }
                if (priceRaw == null || priceRaw.trim().isEmpty()) {
                    throw new IllegalArgumentException("Price is required");
                }
                if (categoryIdRaw == null || categoryIdRaw.trim().isEmpty()) {
                    throw new IllegalArgumentException("Category is required");
                }
                if (brandIdRaw == null || brandIdRaw.trim().isEmpty()) {
                    throw new IllegalArgumentException("Brand is required");
                }

                long id = Long.parseLong(idRaw);
                // Remove thousand separators (dots) and convert comma to decimal point
                priceRaw = priceRaw.replace(".", "").replace(",", ".");
                BigDecimal price = new BigDecimal(priceRaw);
                long categoryId = Long.parseLong(categoryIdRaw);
                long brandId = Long.parseLong(brandIdRaw);

                // Validate category and brand existence
                if (!dao.categoryExists(categoryId)) {
                    throw new IllegalArgumentException("Invalid Category ID: " + categoryId);
                }
                if (!dao.brandExists(brandId)) {
                    throw new IllegalArgumentException("Invalid Brand ID: " + brandId);
                }

                boolean res = dao.update(id, name, description, price, categoryId, brandId, material, status);
                if (res) {
                    response.sendRedirect("ProductManager");
                } else {
                    request.setAttribute("err", "<p class='text-danger'>Update failed: Product not found or database error</p>");
                    Product product = dao.getProductById(id);
                    request.setAttribute("data", product != null ? product : new Product());
                    List<Category> categories = dao.getAllCategories();
                    List<Brand> brands = dao.getAllBrands();
                    request.setAttribute("categories", categories);
                    request.setAttribute("brands", brands);
                    request.getRequestDispatcher("edit-product.jsp").forward(request, response);
                }
            } catch (NumberFormatException e) {
                System.err.println("NumberFormatException in update: " + e.getMessage());
                request.setAttribute("err", "<p class='text-danger'>Invalid input format: Please check Price, Category, or Brand</p>");
                try {
                    long id = Long.parseLong(idRaw);
                    Product product = dao.getProductById(id);
                    request.setAttribute("data", product != null ? product : new Product());
                } catch (NumberFormatException ex) {
                    request.setAttribute("err", "<p class='text-danger'>Invalid product ID</p>");
                }
                List<Category> categories = dao.getAllCategories();
                List<Brand> brands = dao.getAllBrands();
                request.setAttribute("categories", categories);
                request.setAttribute("brands", brands);
                request.getRequestDispatcher("edit-product.jsp").forward(request, response);
            } catch (IllegalArgumentException e) {
                System.err.println("IllegalArgumentException in update: " + e.getMessage());
                request.setAttribute("err", "<p class='text-danger'>" + e.getMessage() + "</p>");
                try {
                    long id = Long.parseLong(idRaw);
                    Product product = dao.getProductById(id);
                    request.setAttribute("data", product != null ? product : new Product());
                } catch (NumberFormatException ex) {
                    request.setAttribute("err", "<p class='text-danger'>Invalid product ID</p>");
                }
                List<Category> categories = dao.getAllCategories();
                List<Brand> brands = dao.getAllBrands();
                request.setAttribute("categories", categories);
                request.setAttribute("brands", brands);
                request.getRequestDispatcher("edit-product.jsp").forward(request, response);
            } catch (Exception e) {
                System.err.println("Unexpected error in update: " + e.getMessage());
                e.printStackTrace();
                request.setAttribute("err", "<p class='text-danger'>Error updating product: " + e.getMessage() + "</p>");
                try {
                    long id = Long.parseLong(idRaw);
                    Product product = dao.getProductById(id);
                    request.setAttribute("data", product != null ? product : new Product());
                } catch (NumberFormatException ex) {
                    request.setAttribute("err", "<p class='text-danger'>Invalid product ID</p>");
                }
                List<Category> categories = dao.getAllCategories();
                List<Brand> brands = dao.getAllBrands();
                request.setAttribute("categories", categories);
                request.setAttribute("brands", brands);
                request.getRequestDispatcher("edit-product.jsp").forward(request, response);
            }
        }
    }

    @Override
    public String getServletInfo() {
        return "ProductManagerController for ClothingStore";
    }
}