package controller.admin;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import dao.ProductDAO;
import model.Brand;
import model.Category;
import model.Product;
import model.ProductImage;
import model.ProductVariant;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.*;
import java.util.stream.Collectors;
import model.Users;

@MultipartConfig(maxFileSize = 10485760) // 10MB
@WebServlet(name = "ProductCreateAdminController", urlPatterns = {"/ProductCreateAdmin"})
public class ProductCreateAdminController extends HttpServlet {
    private ProductDAO productDAO;
    private Cloudinary cloudinary;

    @Override
    public void init() {
        try {
            cloudinary = new Cloudinary(ObjectUtils.asMap(
                    "cloud_name", "da36bkpx5",
                    "api_key", "342541776882536",
                    "api_secret", "F_90gUaX6jfD8yJI8FxCY1Hurbg"
            ));
            productDAO = new ProductDAO();
        } catch (Exception e) {
            throw new RuntimeException("Initialization failed", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Users currentUser = (Users) session.getAttribute("admin");
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/AdminLogin");
            return;
        }
        try {
            request.setAttribute("brands", productDAO.getBrands());
            request.setAttribute("categories", productDAO.getCategories());
            request.getRequestDispatcher("/WEB-INF/views/staff/product/createProduct.jsp").forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error loading data: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/staff/product/createProduct.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        try {
            // Retrieve product information
            String name = request.getParameter("name");
            String categoryIdStr = request.getParameter("categoryId");
            String brandName = request.getParameter("brandName");
            String material = request.getParameter("material");
            String description = request.getParameter("description");
            String[] sizes = request.getParameterValues("size[]");
            String[] colors = request.getParameterValues("color[]");
            String[] priceModifiers = request.getParameterValues("priceModifier[]");
            String mainImageIndexStr = request.getParameter("mainImage");

            List<Part> fileParts = request.getParts().stream()
                    .filter(part -> "images".equals(part.getName()) && part.getSize() > 0)
                    .collect(Collectors.toList());

            // List of errors
            List<String> errorMessages = new ArrayList<>();

            // Validate product
            if (name == null || name.trim().isEmpty()) {
                errorMessages.add("Product name is required.");
            } else if (productDAO.isProductNameExists(name)) {
                errorMessages.add("Product name already exists.");
            }

            if (categoryIdStr == null || categoryIdStr.trim().isEmpty()) {
                errorMessages.add("Category is required.");
            } else {
                try {
                    Long.parseLong(categoryIdStr);
                } catch (NumberFormatException e) {
                    errorMessages.add("Invalid category ID.");
                }
            }

            if (brandName == null || brandName.trim().isEmpty()) {
                errorMessages.add("Brand is required.");
            }

            if (fileParts.isEmpty()) {
                errorMessages.add("At least one image is required.");
            }

            // Validate variants
            boolean hasValidVariant = false;
            Set<String> variantSet = new HashSet<>();
            if (sizes != null && colors != null && priceModifiers != null &&
                    sizes.length == colors.length && sizes.length == priceModifiers.length) {
                for (int i = 0; i < sizes.length; i++) {
                    if (sizes[i] == null || sizes[i].isEmpty() || colors[i] == null || colors[i].isEmpty()) {
                        errorMessages.add("Variant #" + (i + 1) + ": Missing Size or Color.");
                        continue;
                    }
                    String variantKey = sizes[i] + ":" + colors[i];
                    if (!variantSet.add(variantKey)) {
                        errorMessages.add("Variant #" + (i + 1) + " is duplicated (Size " + sizes[i] + ", Color " + colors[i] + ").");
                    }
                    try {
                        String priceModifier = priceModifiers[i] != null && !priceModifiers[i].isEmpty() ? priceModifiers[i] : "0";
                        new BigDecimal(priceModifier); // check parse
                    } catch (NumberFormatException e) {
                        errorMessages.add("Variant #" + (i + 1) + ": Invalid price modifier.");
                    }
                    hasValidVariant = true;
                }
            } else {
                errorMessages.add("Invalid or unsynchronized variant data.");
            }

            if (!hasValidVariant) {
                errorMessages.add("At least one valid variant (Size and Color) is required.");
            }

            // If there are errors -> return to form
            if (!errorMessages.isEmpty()) {
                request.setAttribute("errorMessage", String.join("<br>", errorMessages));
                request.setAttribute("oldName", name);
                request.setAttribute("oldMaterial", material);
                request.setAttribute("oldDescription", description);
                request.setAttribute("oldBrand", brandName);
                request.setAttribute("oldCategoryId", categoryIdStr);
                request.setAttribute("oldSizes", sizes);
                request.setAttribute("oldColors", colors);
                request.setAttribute("oldPriceModifiers", priceModifiers);
                request.setAttribute("brands", productDAO.getBrands());
                request.setAttribute("categories", productDAO.getCategories());
                request.getRequestDispatcher("/WEB-INF/views/staff/product/createProduct.jsp").forward(request, response);
                return;
            }

            // Add product
            long categoryId = Long.parseLong(categoryIdStr);
            Product product = new Product();
            product.setName(name);
            product.setStatus("Active");
            product.setMaterial(material);
            product.setDescription(description);

            Category category = new Category();
            category.setCategoryId(categoryId);
            product.setCategory(category);

            Brand brand = new Brand();
            brand.setName(brandName);
            product.setBrand(brand);

            long productId = productDAO.addProduct(product);
            if (productId == 0) throw new SQLException("Cannot add product.");

            for (int i = 0; i < sizes.length; i++) {
                if (sizes[i] == null || sizes[i].isEmpty() || colors[i] == null || colors[i].isEmpty()) continue;

                ProductVariant variant = new ProductVariant();
                variant.setProductId(productId);
                variant.setSize(sizes[i]);
                variant.setColor(colors[i]);
                variant.setProductName(name);       
                variant.setBrand(brandName);        

                String priceModifier = priceModifiers[i] != null && !priceModifiers[i].isEmpty() ? priceModifiers[i] : "0";
                variant.setPriceModifier(new BigDecimal(priceModifier));

                long variantId = productDAO.addProductVariant(variant);
                productDAO.addInventory(variantId);
            }

            // Add images
            int displayOrder = 0;
            int mainImageIndex = Integer.parseInt(mainImageIndexStr);
            for (Part filePart : fileParts) {
                ByteArrayOutputStream baos = new ByteArrayOutputStream();
                try (InputStream inputStream = filePart.getInputStream()) {
                    byte[] buffer = new byte[1024];
                    int bytesRead;
                    while ((bytesRead = inputStream.read(buffer)) != -1) {
                        baos.write(buffer, 0, bytesRead);
                    }
                }
                byte[] fileBytes = baos.toByteArray();
                Map uploadResult = cloudinary.uploader().upload(fileBytes, ObjectUtils.emptyMap());
                String imageUrl = (String) uploadResult.get("secure_url");

                ProductImage image = new ProductImage();
                image.setProductId(productId);
                image.setImageUrl(imageUrl);
                image.setDisplayOrder(displayOrder);
                image.setMain(displayOrder == mainImageIndex);

                productDAO.addProductImage(image);
                displayOrder++;
            }

            response.sendRedirect(request.getContextPath() + "/ProductListAdmin?success=create");

        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error: " + e.getMessage());
            doGet(request, response);
        } catch (Exception e) {
            request.setAttribute("errorMessage", "An error occurred: " + e.getMessage());
            doGet(request, response);
        }
    }

    @Override
    public String getServletInfo() {
        return "Servlet for creating product information, variants, and images with server-side validation.";
    }
}