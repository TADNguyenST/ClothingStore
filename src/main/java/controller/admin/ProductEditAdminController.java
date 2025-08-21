package controller.admin;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import dao.ProductDAO;
import model.Brand;
import model.Category;
import model.Product;
import model.ProductImage;
import model.ProductVariant;
import model.Users;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

@MultipartConfig(maxFileSize = 10485760) // 10MB
@WebServlet(name = "ProductEditAdminController", urlPatterns = {"/ProductEditAdmin"})
public class ProductEditAdminController extends HttpServlet {
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
            String productIdStr = request.getParameter("productId");
            if (productIdStr == null || productIdStr.trim().isEmpty()) {
                throw new IllegalArgumentException("Missing productId.");
            }
            long productId = Long.parseLong(productIdStr);

            Product product = productDAO.getProductById(productId);
            if (product == null) {
                throw new IllegalArgumentException("No products found with ID: " + productId);
            }

            List<ProductVariant> variants = productDAO.getProductVariantsByProductId(productId);
            List<ProductImage> images = productDAO.getProductImagesByProductId(productId);
            List<Category> categories = productDAO.getCategories();
            List<Brand> brands = productDAO.getBrands();
            List<String> sizes = productDAO.getSizes();
            List<String> colors = productDAO.getColors();

            request.setAttribute("product", product);
            request.setAttribute("variants", variants);
            request.setAttribute("images", images);
            request.setAttribute("categories", categories);
            request.setAttribute("brands", brands);
            request.setAttribute("sizes", sizes);
            request.setAttribute("colors", colors);
            request.getRequestDispatcher("/WEB-INF/views/staff/product/editProduct.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("errorMessage", e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/staff/product/editProduct.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        try {
            // Information products
            long productId = Long.parseLong(request.getParameter("productId"));
            String name = request.getParameter("name");
            long categoryId = Long.parseLong(request.getParameter("categoryId"));
            String brandName = request.getParameter("brandName");
            String material = request.getParameter("material");
            String description = request.getParameter("description");
            String status = request.getParameter("status");

            Product product = new Product();
            product.setProductId(productId);
            product.setName(name);
            product.setStatus(status != null && !status.isEmpty() ? status : "Active");
            product.setMaterial(material);
            product.setDescription(description);

            Category category = new Category();
            category.setCategoryId(categoryId);
            product.setCategory(category);

            Brand brand = new Brand();
            brand.setName(brandName);
            product.setBrand(brand);

            productDAO.updateProduct(product);

            //variant
            String[] variantIds = request.getParameterValues("variantId[]");
            String[] sizes = request.getParameterValues("size[]");
            String[] colors = request.getParameterValues("color[]");
            String[] priceModifiers = request.getParameterValues("priceModifier[]");
            String[] deleteVariants = request.getParameterValues("deleteVariant[]");

            List<Long> variantsToDelete = new ArrayList<>();
            if (deleteVariants != null) {
                for (String deleteVariant : deleteVariants) {
                    if (deleteVariant != null && !deleteVariant.isEmpty()) {
                        variantsToDelete.add(Long.parseLong(deleteVariant));
                    }
                }
            }

            if (sizes != null && colors != null && priceModifiers != null &&
                sizes.length == colors.length && sizes.length == priceModifiers.length) {
                for (int i = 0; i < sizes.length; i++) {
                    if (sizes[i] != null && !sizes[i].isEmpty() &&
                        colors[i] != null && !colors[i].isEmpty()) {

                        BigDecimal modifier = priceModifiers[i] != null && !priceModifiers[i].isEmpty()
                                ? new BigDecimal(priceModifiers[i]) : BigDecimal.ZERO;

                        if (variantIds != null && i < variantIds.length &&
                            variantIds[i] != null && !variantIds[i].isEmpty()) {
                            // Update variant
                            long vId = Long.parseLong(variantIds[i]);

                            // Check duplicate
                            if (productDAO.variantExists(productId, sizes[i], colors[i], vId)) {
                                throw new IllegalArgumentException("Variant Size: " + sizes[i] + ", Color: " + colors[i] + " existed.");
                            }

                            ProductVariant variant = new ProductVariant();
                            variant.setVariantId(vId);
                            variant.setProductId(productId);
                            variant.setSize(sizes[i]);
                            variant.setColor(colors[i]);
                            variant.setPriceModifier(modifier);
                            variant.setProductName(name);
                            variant.setBrand(brandName); 

                            productDAO.updateProductVariant(variant);
                        } else {
                            // Insert variant new 
                            if (productDAO.variantExists(productId, sizes[i], colors[i], null)) {
                                throw new IllegalArgumentException("Variant Size: " + sizes[i] + ", Color: " + colors[i] + " existed.");
                            }

                            ProductVariant variant = new ProductVariant();
                            variant.setProductId(productId);
                            variant.setSize(sizes[i]);
                            variant.setColor(colors[i]);
                            variant.setPriceModifier(modifier);
                            variant.setProductName(name);
                            variant.setBrand(brandName);

                            long variantId = productDAO.addProductVariant(variant);
                            productDAO.addInventory(variantId);
                        }
                    }
                }
            }

            for (Long variantId : variantsToDelete) {
                productDAO.deleteProductVariant(variantId);
            }

            //Image
            String[] imageIds = request.getParameterValues("imageId[]");
            String[] deleteImages = request.getParameterValues("deleteImage[]");
            String mainImageIndex = request.getParameter("mainImage");

            // Delete Image
            if (deleteImages != null) {
                for (String del : deleteImages) {
                    if (del != null && !del.isEmpty()) {
                        long imageId = Long.parseLong(del);
                        productDAO.deleteProductImage(imageId);
                    }
                }
            }

            // Reset image is_main = false
            if (imageIds != null) {
                for (String idStr : imageIds) {
                    if (idStr != null && !idStr.isEmpty()) {
                        productDAO.updateImageMainFlag(Long.parseLong(idStr), false);
                    }
                }
            }

            // update image is main image
            if (mainImageIndex != null && !mainImageIndex.isEmpty()) {
                try {
                    int index = Integer.parseInt(mainImageIndex);
                    if (imageIds != null && index < imageIds.length) {
                        long mainImageId = Long.parseLong(imageIds[index]);
                        productDAO.updateImageMainFlag(mainImageId, true);
                    }
                } catch (Exception ignored) {}
            }

            // Upload new image
            Collection<Part> parts = request.getParts();
            for (Part part : parts) {
                if (part.getName().equals("images[]") && part.getSize() > 0) {
                    String fileName = System.currentTimeMillis() + "_" + part.getSubmittedFileName();
                    String uploadPath = request.getServletContext().getRealPath("/") + "uploads" + File.separator + fileName;

                    File file = new File(uploadPath);
                    file.getParentFile().mkdirs();
                    part.write(uploadPath);

                    boolean isMain = false;
                    if (mainImageIndex != null) {
                        int index = Integer.parseInt(mainImageIndex);
                        if (imageIds == null || index == imageIds.length) {
                            isMain = true;
                        }
                    }

                    productDAO.insertProductImage(productId, "uploads/" + fileName, isMain);
                }
            }

            response.sendRedirect(request.getContextPath() + "/ProductListAdmin?action=list&success=edit");

        } catch (Exception e) {
            String errorMsg = e.getMessage();
            if (errorMsg != null && errorMsg.contains("UNIQUE KEY")) {
                errorMsg = "This variation already exists, please choose another Size or Color.";
            }
            request.setAttribute("errorMessage", "An error occurred: " + errorMsg);
            doGet(request, response);
        }
    }

    @Override
    public String getServletInfo() {
        return "Servlet for editing product information, variants, and images.";
    }
}
