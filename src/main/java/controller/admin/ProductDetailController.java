package controller.admin;

import dao.FeedbackDAO;
import dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Feedback;
import model.Product;
import model.ProductVariant;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(name = "ProductDetailController", urlPatterns = {"/ProductDetail"})
public class ProductDetailController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(ProductDetailController.class.getName());



    private ProductDAO productDAO;
    private FeedbackDAO feedbackDAO;

    @Override
    public void init() {
        try {
            productDAO = new ProductDAO();
            feedbackDAO = new FeedbackDAO(); // Thêm FeedbackDAO
        } catch (Exception e) {
            throw new RuntimeException("Initialization failed", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");

        try {
            String productIdStr = request.getParameter("productId");
            if (productIdStr == null || productIdStr.trim().isEmpty()) {
                throw new IllegalArgumentException("Product ID cannot be blank.");
            }

            long productId;
            try {
                productId = Long.parseLong(productIdStr);
            } catch (NumberFormatException e) {
                throw new IllegalArgumentException("Invalid product ID.");
            }

            Product product = productDAO.getProductById(productId);
            if (product == null) {
                throw new IllegalArgumentException("No products found with ID: " + productId);
            }

            List<ProductVariant> variants = productDAO.getProductVariantsByProductId(productId);
            product.setVariants(variants);
            product.setImages(productDAO.getProductImagesByProductId(productId));


            // Lấy danh sách phản hồi
            List<Feedback> feedbackList = feedbackDAO.getFeedbackByProductId(productId);
            LOGGER.log(Level.INFO, "Retrieved {0} feedbacks for product {1}", new Object[]{feedbackList.size(), productId});

            // TODO: Thay bằng logic thực tế từ bảng product_favorites

            // ---- Giá variant là giá cuối, KHÔNG cộng base ----
            BigDecimal lowestPrice = null;
            ProductVariant defaultVariant = null;

            if (variants != null && !variants.isEmpty()) {
                for (ProductVariant v : variants) {
                    BigDecimal vPrice = (v.getPriceModifier() != null) ? v.getPriceModifier()
                            : (product.getPrice() != null ? product.getPrice() : BigDecimal.ZERO);

                    if (lowestPrice == null || vPrice.compareTo(lowestPrice) < 0) {
                        lowestPrice = vPrice;
                    }
                    // chọn variant default ưu tiên còn hàng
                    if (defaultVariant == null || (defaultVariant.getQuantity() <= 0 && v.getQuantity() > 0)) {
                        defaultVariant = v;
                    }
                }
            }
            if (lowestPrice == null) {
                lowestPrice = (product.getPrice() != null) ? product.getPrice() : BigDecimal.ZERO;
            }

            // TODO: thay bằng dữ liệu wishlist thực tế

            Set<Long> wishlistProductIds = new HashSet<>();

            request.setAttribute("wishlistProductIds", wishlistProductIds);
            request.setAttribute("product", product);

            request.setAttribute("feedbackList", feedbackList); // Truyền feedbackList vào JSP

            request.setAttribute("defaultVariant", defaultVariant);
            request.setAttribute("lowestPrice", lowestPrice.doubleValue()); // chỉ dùng dự phòng

            request.setAttribute("pageTitle", product.getName());

            request.getRequestDispatcher("/WEB-INF/views/public/product/product-details.jsp")
                    .forward(request, response);

        } catch (IllegalArgumentException e) {
            System.err.println("IllegalArgumentException: " + e.getMessage());
            request.setAttribute("errorMessage", e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/public/product/product-details.jsp")
                    .forward(request, response);

        } catch (SQLException e) {
            System.err.println("SQLException: " + e.getMessage());
            request.setAttribute("errorMessage", "Lỗi cơ sở dữ liệu: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/public/product/product-details.jsp")
                    .forward(request, response);

        } catch (Exception e) {
            System.err.println("Exception: " + e.getMessage());
            request.setAttribute("errorMessage", "Đã xảy ra lỗi: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/public/product/product-details.jsp")
                    .forward(request, response);
        }
    }

    @Override
    public String getServletInfo() {
        return "Servlet for displaying product details, including variants and images.";
    }
}
