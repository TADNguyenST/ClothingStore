package controller.admin;

import dao.ProductDAO;
import model.Product;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import model.Users;

@WebServlet(name = "ProductDetailsAdminController", urlPatterns = {"/ProductDetailsAdmin"})
public class ProductDetailsAdminController extends HttpServlet {
    private ProductDAO productDAO;

    @Override
    public void init() {
        try {
            productDAO = new ProductDAO();
        } catch (Exception e) {
            throw new RuntimeException("Initialization failed", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        HttpSession session = request.getSession();
        Users currentUser = (Users) session.getAttribute("admin");
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/AdminLogin");
            return;
        }
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

            // Fetch variants and images
            product.setVariants(productDAO.getProductVariantsByProductId(productId));
            product.setImages(productDAO.getProductImagesByProductId(productId));

            request.setAttribute("product", product);
            request.getRequestDispatcher("/WEB-INF/views/staff/product/detailProduct.jsp").forward(request, response);

        } catch (IllegalArgumentException e) {
            System.err.println("IllegalArgumentException: " + e.getMessage());
            request.setAttribute("errorMessage", e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/staff/product/detailProduct.jsp").forward(request, response);
        } catch (SQLException e) {
            System.err.println("SQLException: " + e.getMessage());
            request.setAttribute("errorMessage", "Lỗi cơ sở dữ liệu: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/staff/product/detailProduct.jsp").forward(request, response);
        } catch (Exception e) {
            System.err.println("Exception: " + e.getMessage());
            request.setAttribute("errorMessage", "Đã xảy ra lỗi: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/staff/product/detailProduct.jsp").forward(request, response);
        }
    }

    @Override
    public String getServletInfo() {
        return "Servlet for displaying product details, including variants and images.";
    }
}