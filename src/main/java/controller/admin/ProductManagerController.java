package controller.admin;

import dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import model.Brand;
import model.Category;
import model.Product;
import model.ProductVariant;

@WebServlet(name = "ProductManagerController", urlPatterns = {"/ProductManager"})
public class ProductManagerController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        ProductDAO dao = new ProductDAO();

        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        if (action.equalsIgnoreCase("list")) {
            List<Product> data = dao.getAll();
            request.setAttribute("list", data);
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

            Long categoryId = null;
            if (categoryIdRaw != null && !categoryIdRaw.isEmpty()) {
                try {
                    categoryId = Long.parseLong(categoryIdRaw);
                    if (!dao.categoryExists(categoryId)) {
                        request.setAttribute("err", "<p class='text-danger'>Invalid Category ID: " + categoryIdRaw + "</p>");
                        categoryId = null;
                    }
                } catch (NumberFormatException e) {
                    System.out.println("Invalid Long format for categoryId: " + categoryIdRaw);
                    request.setAttribute("err", "<p class='text-danger'>Invalid Category ID format</p>");
                }
            }

            Long brandId = null;
            if (brandIdRaw != null && !brandIdRaw.isEmpty()) {
                try {
                    brandId = Long.parseLong(brandIdRaw);
                    if (!dao.brandExists(brandId)) {
                        request.setAttribute("err", "<p class='text-danger'>Invalid Brand ID: " + brandIdRaw + "</p>");
                        brandId = null;
                    }
                } catch (NumberFormatException e) {
                    System.out.println("Invalid Long format for brandId: " + brandIdRaw);
                    request.setAttribute("err", "<p class='text-danger'>Invalid Brand ID format</p>");
                }
            }

            BigDecimal minPrice = null;
            if (minPriceRaw != null && !minPriceRaw.isEmpty()) {
                try {
                    minPrice = new BigDecimal(minPriceRaw.replace(".", "").replace(",", "."));
                } catch (NumberFormatException e) {
                    System.out.println("Invalid BigDecimal format for minPrice: " + minPriceRaw);
                    request.setAttribute("err", "<p class='text-danger'>Invalid Min Price format</p>");
                }
            }

            BigDecimal maxPrice = null;
            if (maxPriceRaw != null && !maxPriceRaw.isEmpty()) {
                try {
                    maxPrice = new BigDecimal(maxPriceRaw.replace(".", "").replace(",", "."));
                } catch (NumberFormatException e) {
                    System.out.println("Invalid BigDecimal format for maxPrice: " + maxPriceRaw);
                    request.setAttribute("err", "<p class='text-danger'>Invalid Max Price format</p>");
                }
            }

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
        ProductDAO dao = new ProductDAO();

        String action = request.getParameter("action");
        if (action.equalsIgnoreCase("create")) {
            String name = request.getParameter("name");
            String description = request.getParameter("description");
            String priceRaw = request.getParameter("price");
            String categoryIdRaw = request.getParameter("categoryId");
            String brandIdRaw = request.getParameter("brandId");
            String material = request.getParameter("material");
            String status = request.getParameter("status");

            String[] sizes = request.getParameterValues("size");
            String[] colors = request.getParameterValues("color");
            String[] priceModifiers = request.getParameterValues("priceModifier");

            try {
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

                priceRaw = priceRaw.replace(".", "").replace(",", ".");
                BigDecimal price = new BigDecimal(priceRaw);
                if (price.compareTo(BigDecimal.ZERO) <= 0) {
                    throw new IllegalArgumentException("Price must be positive");
                }
                long categoryId = Long.parseLong(categoryIdRaw);
                long brandId = Long.parseLong(brandIdRaw);

                if (!dao.categoryExists(categoryId)) {
                    throw new IllegalArgumentException("Invalid Category ID: " + categoryId);
                }
                if (!dao.brandExists(brandId)) {
                    throw new IllegalArgumentException("Invalid Brand ID: " + brandId);
                }

                String brandName = dao.getBrandNameById(brandId);
                if (brandName == null) {
                    throw new IllegalArgumentException("Brand name not found for ID: " + brandId);
                }

                System.out.println("Sizes: " + (sizes != null ? String.join(", ", sizes) : "null"));
                System.out.println("Colors: " + (colors != null ? String.join(", ", colors) : "null"));
                System.out.println("Price Modifiers: " + (priceModifiers != null ? String.join(", ", priceModifiers) : "null"));

                List<ProductVariant> variants = new ArrayList<>();
                if (sizes != null && colors != null && priceModifiers != null &&
                    sizes.length == colors.length && colors.length == priceModifiers.length && sizes.length > 0) {
                    for (int i = 0; i < sizes.length; i++) {
                        if (sizes[i] == null || sizes[i].trim().isEmpty()) {
                            throw new IllegalArgumentException("Size cannot be empty for variant " + (i + 1));
                        }
                        if (colors[i] == null || colors[i].trim().isEmpty()) {
                            throw new IllegalArgumentException("Color cannot be empty for variant " + (i + 1));
                        }
                        if (priceModifiers[i] == null || priceModifiers[i].trim().isEmpty()) {
                            throw new IllegalArgumentException("Price Modifier cannot be empty for variant " + (i + 1));
                        }
                        String priceModifierRaw = priceModifiers[i].replace(".", "").replace(",", ".");
                        BigDecimal priceModifier = new BigDecimal(priceModifierRaw);
                        if (price.add(priceModifier).compareTo(BigDecimal.ZERO) < 0) {
                            throw new IllegalArgumentException("Price Modifier for variant " + (i + 1) + " makes total price negative (" + 
                                price.add(priceModifier) + "). Total price must be non-negative.");
                        }
                        ProductVariant variant = new ProductVariant(
                            null,
                            sizes[i].trim(),
                            colors[i].trim(),
                            priceModifier,
                            brandName,
                            name
                        );
                        variants.add(variant);
                    }
                } else if (sizes != null || colors != null || priceModifiers != null) {
                    throw new IllegalArgumentException("Incomplete or mismatched variant data: " +
                        "Sizes=" + (sizes != null ? sizes.length : "null") + ", " +
                        "Colors=" + (colors != null ? colors.length : "null") + ", " +
                        "PriceModifiers=" + (priceModifiers != null ? priceModifiers.length : "null"));
                }

                int res = dao.insert(name, description, price, categoryId, brandId, material, status, variants);
                if (res == 1) {
                    response.sendRedirect("ProductManager");
                } else {
                    request.setAttribute("err", "<p class='text-danger'>Create failed: Database error or invalid data</p>");
                    List<Category> categories = dao.getAllCategories();
                    List<Brand> brands = dao.getAllBrands();
                    request.setAttribute("categories", categories);
                    request.setAttribute("brands", brands);
                    request.getRequestDispatcher("create-product.jsp").forward(request, response);
                }
            } catch (NumberFormatException e) {
                System.err.println("NumberFormatException in create: " + e.getMessage());
                request.setAttribute("err", "<p class='text-danger'>Invalid input format: Please check Price or Price Modifier (e.g., -5.00, 0, 5.50)</p>");
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

            String[] variantIds = request.getParameterValues("variantId");
            String[] sizes = request.getParameterValues("size");
            String[] colors = request.getParameterValues("color");
            String[] priceModifiers = request.getParameterValues("priceModifier");

            try {
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
                priceRaw = priceRaw.replace(".", "").replace(",", ".");
                BigDecimal price = new BigDecimal(priceRaw);
                if (price.compareTo(BigDecimal.ZERO) <= 0) {
                    throw new IllegalArgumentException("Price must be positive");
                }
                long categoryId = Long.parseLong(categoryIdRaw);
                long brandId = Long.parseLong(brandIdRaw);

                if (!dao.categoryExists(categoryId)) {
                    throw new IllegalArgumentException("Invalid Category ID: " + categoryId);
                }
                if (!dao.brandExists(brandId)) {
                    throw new IllegalArgumentException("Invalid Brand ID: " + brandId);
                }

                String brandName = dao.getBrandNameById(brandId);
                if (brandName == null) {
                    throw new IllegalArgumentException("Brand name not found for ID: " + brandId);
                }

                System.out.println("Sizes: " + (sizes != null ? String.join(", ", sizes) : "null"));
                System.out.println("Colors: " + (colors != null ? String.join(", ", colors) : "null"));
                System.out.println("Price Modifiers: " + (priceModifiers != null ? String.join(", ", priceModifiers) : "null"));
                System.out.println("Variant IDs: " + (variantIds != null ? String.join(", ", variantIds) : "null"));

                List<ProductVariant> variants = new ArrayList<>();
                if (sizes != null && colors != null && priceModifiers != null &&
                    sizes.length == colors.length && colors.length == priceModifiers.length && sizes.length > 0) {
                    // Ensure variantIds is at least as long as other arrays
                    String[] normalizedVariantIds = new String[sizes.length];
                    if (variantIds != null) {
                        for (int i = 0; i < Math.min(variantIds.length, sizes.length); i++) {
                            normalizedVariantIds[i] = variantIds[i];
                        }
                    }
                    for (int i = variantIds != null ? variantIds.length : 0; i < sizes.length; i++) {
                        normalizedVariantIds[i] = "";
                    }

                    for (int i = 0; i < sizes.length; i++) {
                        if (sizes[i] == null || sizes[i].trim().isEmpty()) {
                            throw new IllegalArgumentException("Size cannot be empty for variant " + (i + 1));
                        }
                        if (colors[i] == null || colors[i].trim().isEmpty()) {
                            throw new IllegalArgumentException("Color cannot be empty for variant " + (i + 1));
                        }
                        if (priceModifiers[i] == null || priceModifiers[i].trim().isEmpty()) {
                            throw new IllegalArgumentException("Price Modifier cannot be empty for variant " + (i + 1));
                        }
                        String priceModifierRaw = priceModifiers[i].replace(".", "").replace(",", ".");
                        BigDecimal priceModifier = new BigDecimal(priceModifierRaw);
                        if (price.add(priceModifier).compareTo(BigDecimal.ZERO) < 0) {
                            throw new IllegalArgumentException("Price Modifier for variant " + (i + 1) + " makes total price negative (" + 
                                price.add(priceModifier) + "). Total price must be non-negative.");
                        }
                        ProductVariant variant = new ProductVariant();
                        variant.setProductId(id);
                        variant.setSize(sizes[i].trim());
                        variant.setColor(colors[i].trim());
                        variant.setPriceModifier(priceModifier);
                        variant.setBrand(brandName);
                        variant.setProductName(name);
                        if (normalizedVariantIds[i] != null && !normalizedVariantIds[i].isEmpty()) {
                            variant.setVariantId(Long.parseLong(normalizedVariantIds[i]));
                        }
                        variants.add(variant);
                    }
                } else if (sizes != null || colors != null || priceModifiers != null) {
                    throw new IllegalArgumentException("Incomplete or mismatched variant data: " +
                        "Sizes=" + (sizes != null ? sizes.length : "null") + ", " +
                        "Colors=" + (colors != null ? colors.length : "null") + ", " +
                        "PriceModifiers=" + (priceModifiers != null ? priceModifiers.length : "null") + ", " +
                        "VariantIds=" + (variantIds != null ? variantIds.length : "null"));
                }

                boolean res = dao.update(id, name, description, price, categoryId, brandId, material, status, variants);
                if (res) {
                    response.sendRedirect("ProductManager");
                } else {
                    request.setAttribute("err", "<p class='text-danger'>Update failed: Product not found or database error</p>");
                    Product updatedProduct = dao.getProductById(id);
                    request.setAttribute("data", updatedProduct != null ? updatedProduct : new Product());
                    List<Category> categories = dao.getAllCategories();
                    List<Brand> brands = dao.getAllBrands();
                    request.setAttribute("categories", categories);
                    request.setAttribute("brands", brands);
                    request.getRequestDispatcher("edit-product.jsp").forward(request, response);
                }
            } catch (NumberFormatException e) {
                System.err.println("NumberFormatException in update: " + e.getMessage());
                request.setAttribute("err", "<p class='text-danger'>Invalid input format: Please check Price, Category, Brand, or Price Modifier (e.g., -5.00, 0, 5.50)</p>");
                try {
                    long id = Long.parseLong(idRaw);
                    Product updatedProduct = dao.getProductById(id);
                    request.setAttribute("data", updatedProduct != null ? updatedProduct : new Product());
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
                    Product updatedProduct = dao.getProductById(id);
                    request.setAttribute("data", updatedProduct != null ? updatedProduct : new Product());
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
                    Product updatedProduct = dao.getProductById(id);
                    request.setAttribute("data", updatedProduct != null ? updatedProduct : new Product());
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