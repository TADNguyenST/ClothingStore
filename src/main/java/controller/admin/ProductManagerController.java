package controller.admin;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import dao.CategoryDAO;
import dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import model.Brand;
import model.Category;
import model.Product;
import model.ProductImage;
import model.ProductVariant;

@WebServlet(name = "ProductManagerController", urlPatterns = {"/ProductManager"})
@MultipartConfig(maxFileSize = 10485760) // Giới hạn 10MB cho mỗi file
public class ProductManagerController extends HttpServlet {

    private Cloudinary cloudinary;

    @Override
    public void init() {
        try {
            cloudinary = new Cloudinary(ObjectUtils.asMap(
                "cloud_name", "da36bkpx5",
                "api_key", "342541776882536",
                "api_secret", "F_90gUaX6jfD8yJI8FxCY1Hurbg"
            ));
            if (cloudinary == null) {
                System.err.println("Failed to initialize Cloudinary!");
            } else {
                System.out.println("Cloudinary initialized successfully.");
            }
        } catch (Exception e) {
            System.err.println("Error initializing Cloudinary: " + e.getMessage());
            e.printStackTrace();
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        ProductDAO dao = new ProductDAO();
        CategoryDAO categoryDAO = new CategoryDAO();
        
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
            request.getRequestDispatcher("/WEB-INF/views/staff/product/products.jsp").forward(request, response);
        } else if (action.equalsIgnoreCase("create")) {
            List<Category> categories = dao.getAllCategories();
            List<Brand> brands = dao.getAllBrands();
            request.setAttribute("categories", categories);
            request.setAttribute("brands", brands);
            request.getRequestDispatcher("/WEB-INF/views/staff/product/create-product.jsp").forward(request, response);
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
            request.getRequestDispatcher("/WEB-INF/views/staff/product/products.jsp").forward(request, response);
        } else if (action.equalsIgnoreCase("update")) {
            String idRaw = request.getParameter("id");
            try {
                long id = Long.parseLong(idRaw);
                Product product = dao.getProductById(id);
                if (product == null) {
                    request.setAttribute("err", "<p class='text-danger'>Product not found with ID: " + id + "</p>");
                    List<Product> data = dao.getAll();
                    request.setAttribute("list", data);
                    request.getRequestDispatcher("/WEB-INF/views/staff/product/products.jsp").forward(request, response);
                } else {
                    request.setAttribute("data", product);
                    List<Category> categories = dao.getAllCategories();
                    List<Brand> brands = dao.getAllBrands();
                    request.setAttribute("categories", categories);
                    request.setAttribute("brands", brands);
                    request.getRequestDispatcher("/WEB-INF/views/staff/product/edit-product.jsp").forward(request, response);
                }
            } catch (NumberFormatException e) {
                request.setAttribute("err", "<p class='text-danger'>Invalid product ID</p>");
                List<Product> data = dao.getAll();
                request.setAttribute("list", data);
                request.getRequestDispatcher("/WEB-INF/views/staff/product/products.jsp").forward(request, response);
            } catch (Exception e) {
                request.setAttribute("err", "<p class='text-danger'>Error retrieving product: " + e.getMessage() + "</p>");
                List<Product> data = dao.getAll();
                request.setAttribute("list", data);
                request.getRequestDispatcher("/WEB-INF/views/staff/product/products.jsp").forward(request, response);
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
                request.getRequestDispatcher("/WEB-INF/views/staff/product/productDetail.jsp").forward(request, response);
            } catch (NumberFormatException e) {
                request.setAttribute("err", "<p class='text-danger'>Invalid product ID</p>");
                request.getRequestDispatcher("/WEB-INF/views/staff/product/productDetail.jsp").forward(request, response);
            } catch (Exception e) {
                request.setAttribute("err", "<p class='text-danger'>Error retrieving product: " + e.getMessage() + "</p>");
                request.getRequestDispatcher("/WEB-INF/views/staff/product/productDetail.jsp").forward(request, response);
            }
        } else if (action.equalsIgnoreCase("filter")) {
    String parentCategoryIdRaw = request.getParameter("parentCategoryId");
    String categoryIdRaw = request.getParameter("categoryId");
    String brandIdRaw = request.getParameter("brandId");
    String size = request.getParameter("size");
    String color = request.getParameter("color");
    String minPriceRaw = request.getParameter("minPrice");
    String maxPriceRaw = request.getParameter("maxPrice");
    String status = request.getParameter("status"); // Thêm tham số trạng thái

    Long parentCategoryId = null;
    if (parentCategoryIdRaw != null && !parentCategoryIdRaw.isEmpty()) {
        try {
            parentCategoryId = Long.parseLong(parentCategoryIdRaw);
            if (!dao.categoryExists(parentCategoryId)) {
                request.setAttribute("err", "<p class='text-danger'>Invalid Parent Category ID: " + parentCategoryIdRaw + "</p>");
                parentCategoryId = null;
            }
        } catch (NumberFormatException e) {
            System.out.println("Invalid Long format for parentCategoryId: " + parentCategoryIdRaw);
            request.setAttribute("err", "<p class='text-danger'>Invalid Parent Category ID format</p>");
        }
    }

    Long categoryId = null;
    if (categoryIdRaw != null && !categoryIdRaw.isEmpty()) {
        try {
            categoryId = Long.parseLong(categoryIdRaw);
            // Chỉ báo lỗi nếu categoryId không tồn tại và parentCategoryId hợp lệ
            if (parentCategoryId != null && !dao.categoryExists(categoryId)) {
                System.out.println("Warning: Invalid Category ID: " + categoryIdRaw + " under parent " + parentCategoryId);
                // Không set err ngay, để filter tiếp tục với dữ liệu hợp lệ
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

    try {
        List<Product> data = dao.filterProducts(parentCategoryId, categoryId, brandId, size, color, minPrice, maxPrice, status);
        request.setAttribute("list", data);
        if (data.isEmpty()) {
            request.setAttribute("err", "<p class='text-danger'>No products found matching the filter criteria</p>");
        }
    } catch (Exception e) {
        request.setAttribute("err", "<p class='text-danger'>Error filtering products: " + e.getMessage() + "</p>");
        System.out.println("Error in filter action: " + e.getMessage());
    }

    List<Category> categories = dao.getAllCategories();
    List<Brand> brands = dao.getAllBrands();
    request.setAttribute("categories", categories);
    request.setAttribute("brands", brands);
    request.getRequestDispatcher("/WEB-INF/views/staff/product/products.jsp").forward(request, response);
}
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        System.out.println("doPost called with action: " + request.getParameter("action")); // Debug log
        ProductDAO dao = new ProductDAO();

        String action = request.getParameter("action");
        if (action == null) {
            action = "create"; // Default to create for POST
        }

        if (action.equalsIgnoreCase("create")) {
            try {
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
                String[] isMainImages = request.getParameterValues("isMainImage");

                // Validate inputs
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
                System.out.println("Is Main Images: " + (isMainImages != null ? String.join(", ", isMainImages) : "null"));

                // Handle variants
                List<ProductVariant> variants = new ArrayList<>();
                if (sizes != null && colors != null && priceModifiers != null
                        && sizes.length == colors.length && colors.length == priceModifiers.length && sizes.length > 0) {
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
                            throw new IllegalArgumentException("Price Modifier for variant " + (i + 1) + " makes total price negative ("
                                    + price.add(priceModifier) + "). Total price must be non-negative.");
                        }
                        ProductVariant variant = new ProductVariant(null, sizes[i].trim(), colors[i].trim(),
                                priceModifier, brandName, name);
                        variants.add(variant);
                    }
                } else if (sizes != null || colors != null || priceModifiers != null) {
                    throw new IllegalArgumentException("Incomplete or mismatched variant data: "
                            + "Sizes=" + (sizes != null ? sizes.length : "null") + ", "
                            + "Colors=" + (colors != null ? colors.length : "null") + ", "
                            + "PriceModifiers=" + (priceModifiers != null ? priceModifiers.length : "null"));
                }

                // Handle images
                List<ProductImage> images = new ArrayList<>();
                Collection<Part> fileParts = request.getParts();
                System.out.println("Number of file parts: " + (fileParts != null ? fileParts.size() : "null"));
                if (fileParts != null && !fileParts.isEmpty()) {
                    int imageIndex = 0;
                    for (Part filePart : fileParts) {
                        System.out.println("Processing part: " + filePart.getName() + ", Size: " + filePart.getSize());
                        if ("images".equals(filePart.getName()) && filePart.getSize() > 0) {
                            String fileName = filePart.getSubmittedFileName();
                            if (fileName != null && !fileName.toLowerCase().matches(".*\\.(jpg|jpeg|png|gif)$")) {
                                throw new IllegalArgumentException("Invalid image format for file: " + fileName);
                            }

                            File tempFile = null;
                            try {
                                tempFile = File.createTempFile("upload", fileName);
                                try (InputStream input = filePart.getInputStream();
                                     FileOutputStream output = new FileOutputStream(tempFile)) {
                                    byte[] buffer = new byte[1024];
                                    int len;
                                    while ((len = input.read(buffer)) != -1) {
                                        output.write(buffer, 0, len);
                                    }
                                }

                                if (cloudinary != null) {
                                    Map uploadResult = cloudinary.uploader().upload(tempFile, ObjectUtils.asMap(
                                        "quality", "auto",
                                        "fetch_format", "auto",
                                        "width", 800,
                                        "crop", "limit",
                                        "folder", "products"
                                    ));
                                    String imageUrl = (String) uploadResult.get("secure_url");
                                    System.out.println("Optimized image URL: " + imageUrl);
                                    tempFile.delete();

                                    ProductImage image = new ProductImage();
                                    image.setImageUrl(imageUrl);
                                    image.setDisplayOrder(imageIndex + 1);
                                    image.setMain(isMainImages != null && imageIndex < isMainImages.length && "true".equals(isMainImages[imageIndex]));
                                    images.add(image);
                                    imageIndex++;
                                } else {
                                    throw new IllegalStateException("Cloudinary not initialized!");
                                }
                            } catch (IOException e) {
                                System.err.println("IO Error processing file: " + e.getMessage());
                                if (tempFile != null) tempFile.delete();
                                throw e;
                            } catch (Exception e) {
                                System.err.println("Upload error: " + e.getMessage());
                                if (tempFile != null) tempFile.delete();
                                throw e;
                            }
                        }
                    }
                }

                if (images.isEmpty()) {
                    throw new IllegalArgumentException("At least one image is required");
                }

                long productId = dao.insert(name, description, price, categoryId, brandId, material, status, variants, images);
                if (productId > 0) {
                    response.sendRedirect("ProductManager");
                } else {
                    throw new Exception("Database error or invalid data");
                }
            } catch (IllegalArgumentException e) {
                System.err.println("IllegalArgumentException in create: " + e.getMessage());
                request.setAttribute("err", "<p class='text-danger'>" + e.getMessage() + "</p>");
                List<Category> categories = dao.getAllCategories();
                List<Brand> brands = dao.getAllBrands();
                request.setAttribute("categories", categories);
                request.setAttribute("brands", brands);
                request.getRequestDispatcher("/WEB-INF/views/staff/product/create-product.jsp").forward(request, response);
            } catch (Exception e) {
                e.printStackTrace();
                System.err.println("Unexpected error in create: " + e.getMessage());
                request.setAttribute("err", "<p class='text-danger'>Error creating product: " + e.getMessage() + "</p>");
                List<Category> categories = dao.getAllCategories();
                List<Brand> brands = dao.getAllBrands();
                request.setAttribute("categories", categories);
                request.setAttribute("brands", brands);
                request.getRequestDispatcher("/WEB-INF/views/staff/product/create-product.jsp").forward(request, response);
            }
        } else if (action.equalsIgnoreCase("update")) {
            try {
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
                String[] existingImageUrls = request.getParameterValues("existingImageUrl");
                String[] isMainImages = request.getParameterValues("isMainImage");

                System.out.println("Update action started for ID: " + idRaw); // Debug
                System.out.println("Existing Image URLs: " + (existingImageUrls != null ? String.join(", ", existingImageUrls) : "null"));
                System.out.println("Is Main Images: " + (isMainImages != null ? String.join(", ", isMainImages) : "null"));

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
                if (sizes != null && colors != null && priceModifiers != null
                        && sizes.length == colors.length && colors.length == priceModifiers.length && sizes.length > 0) {
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
                            throw new IllegalArgumentException("Price Modifier for variant " + (i + 1) + " makes total price negative ("
                                    + price.add(priceModifier) + "). Total price must be non-negative.");
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
                    throw new IllegalArgumentException("Incomplete or mismatched variant data: "
                            + "Sizes=" + (sizes != null ? sizes.length : "null") + ", "
                            + "Colors=" + (colors != null ? colors.length : "null") + ", "
                            + "PriceModifiers=" + (priceModifiers != null ? priceModifiers.length : "null") + ", "
                            + "VariantIds=" + (variantIds != null ? variantIds.length : "null"));
                }

                // Handle existing and new images
                List<ProductImage> images = new ArrayList<>();
                // Keep existing images based on what is still in the form
                if (existingImageUrls != null) {
                    for (int i = 0; i < existingImageUrls.length; i++) {
                        ProductImage image = new ProductImage();
                        image.setImageUrl(existingImageUrls[i]);
                        image.setDisplayOrder(i + 1);
                        image.setMain(isMainImages != null && i < isMainImages.length && "true".equals(isMainImages[i]));
                        images.add(image);
                    }
                }
                // Handle new uploaded images
                Collection<Part> fileParts = request.getParts();
                System.out.println("Number of file parts: " + (fileParts != null ? fileParts.size() : "null"));
                if (fileParts != null && !fileParts.isEmpty()) {
                    int imageIndex = existingImageUrls != null ? existingImageUrls.length : 0;
                    for (Part filePart : fileParts) {
                        System.out.println("Processing part: " + filePart.getName() + ", Size: " + filePart.getSize());
                        if ("images".equals(filePart.getName()) && filePart.getSize() > 0) {
                            String fileName = filePart.getSubmittedFileName();
                            if (fileName != null && !fileName.toLowerCase().matches(".*\\.(jpg|jpeg|png|gif)$")) {
                                throw new IllegalArgumentException("Invalid image format for file: " + fileName);
                            }

                            File tempFile = null;
                            try {
                                tempFile = File.createTempFile("upload", fileName);
                                try (InputStream input = filePart.getInputStream();
                                     FileOutputStream output = new FileOutputStream(tempFile)) {
                                    byte[] buffer = new byte[1024];
                                    int len;
                                    while ((len = input.read(buffer)) != -1) {
                                        output.write(buffer, 0, len);
                                    }
                                }

                                if (cloudinary != null) {
                                    Map uploadResult = cloudinary.uploader().upload(tempFile, ObjectUtils.asMap(
                                        "quality", "auto",
                                        "fetch_format", "auto",
                                        "width", 800,
                                        "crop", "limit",
                                        "folder", "products"
                                    ));
                                    String imageUrl = (String) uploadResult.get("secure_url");
                                    System.out.println("Optimized image URL: " + imageUrl);
                                    tempFile.delete();

                                    ProductImage image = new ProductImage();
                                    image.setImageUrl(imageUrl);
                                    image.setDisplayOrder(imageIndex + 1);
                                    image.setMain(isMainImages != null && imageIndex < isMainImages.length && "true".equals(isMainImages[imageIndex]));
                                    images.add(image);
                                    imageIndex++;
                                } else {
                                    throw new IllegalStateException("Cloudinary not initialized!");
                                }
                            } catch (IOException e) {
                                System.err.println("IO Error processing file: " + e.getMessage());
                                if (tempFile != null) tempFile.delete();
                                throw e;
                            } catch (Exception e) {
                                System.err.println("Upload error: " + e.getMessage());
                                if (tempFile != null) tempFile.delete();
                                throw e;
                            }
                        }
                    }
                }

                if (images.isEmpty()) {
                    throw new IllegalArgumentException("At least one image is required");
                }

                boolean res = dao.update(id, name, description, price, categoryId, brandId, material, status, variants, images);
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
                    request.getRequestDispatcher("/WEB-INF/views/staff/product/edit-product.jsp").forward(request, response);
                }
            } catch (NumberFormatException e) {
                System.err.println("NumberFormatException in update: " + e.getMessage());
                request.setAttribute("err", "<p class='text-danger'>Invalid input format: Please check Price, Category, Brand, or Price Modifier (e.g., -5.00, 0, 5.50)</p>");
                try {
                    long id = Long.parseLong(request.getParameter("id"));
                    Product updatedProduct = dao.getProductById(id);
                    request.setAttribute("data", updatedProduct != null ? updatedProduct : new Product());
                } catch (NumberFormatException ex) {
                    request.setAttribute("err", "<p class='text-danger'>Invalid product ID</p>");
                }
                List<Category> categories = dao.getAllCategories();
                List<Brand> brands = dao.getAllBrands();
                request.setAttribute("categories", categories);
                request.setAttribute("brands", brands);
                request.getRequestDispatcher("/WEB-INF/views/staff/product/edit-product.jsp").forward(request, response);
            } catch (IllegalArgumentException e) {
                System.err.println("IllegalArgumentException in update: " + e.getMessage());
                request.setAttribute("err", "<p class='text-danger'>" + e.getMessage() + "</p>");
                try {
                    long id = Long.parseLong(request.getParameter("id"));
                    Product updatedProduct = dao.getProductById(id);
                    request.setAttribute("data", updatedProduct != null ? updatedProduct : new Product());
                } catch (NumberFormatException ex) {
                    request.setAttribute("err", "<p class='text-danger'>Invalid product ID</p>");
                }
                List<Category> categories = dao.getAllCategories();
                List<Brand> brands = dao.getAllBrands();
                request.setAttribute("categories", categories);
                request.setAttribute("brands", brands);
                request.getRequestDispatcher("/WEB-INF/views/staff/product/edit-product.jsp").forward(request, response);
            } catch (Exception e) {
                e.printStackTrace();
                System.err.println("Unexpected error in update: " + e.getMessage());
                request.setAttribute("err", "<p class='text-danger'>Error updating product: " + e.getMessage() + "</p>");
                try {
                    long id = Long.parseLong(request.getParameter("id"));
                    Product updatedProduct = dao.getProductById(id);
                    request.setAttribute("data", updatedProduct != null ? updatedProduct : new Product());
                } catch (NumberFormatException ex) {
                    request.setAttribute("err", "<p class='text-danger'>Invalid product ID</p>");
                }
                List<Category> categories = dao.getAllCategories();
                List<Brand> brands = dao.getAllBrands();
                request.setAttribute("categories", categories);
                request.setAttribute("brands", brands);
                request.getRequestDispatcher("/WEB-INF/views/staff/product/edit-product.jsp").forward(request, response);
            }
        }
    }

    @Override
    public String getServletInfo() {
        return "ProductManagerController for ClothingStore";
    }
}