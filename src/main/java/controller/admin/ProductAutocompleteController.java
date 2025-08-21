package controller.admin;

import dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Product;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "ProductAutocompleteController", urlPatterns = {"/ProductAutocomplete"})
public class ProductAutocompleteController extends HttpServlet {
    private final ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        try {
            String keyword = request.getParameter("keyword");

            List<Product> products = productDAO.searchProductsForHomePage(keyword);
            response.setContentType("text/html; charset=UTF-8");
            StringBuilder html = new StringBuilder();
            if (products != null && !products.isEmpty()) {
                for (Product product : products) {
                    String imageUrl = product.getImageUrl() != null ? product.getImageUrl() : "https://placehold.co/50x50";
                    html.append("<div class='p-2 d-flex align-items-center suggestion-item' style='cursor: pointer;' ")
                            .append("onclick='window.location=\"")
                            .append(request.getContextPath()).append("/ProductDetail?productId=")
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
                html.append("<div class='p-2 text-muted'>No products found</div>");
            }
            response.getWriter().write(html.toString());
        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().write("<div class='p-2 text-muted'>Error fetching suggestions</div>");
        }
    }

    @Override
    public String getServletInfo() {
        return "Handles product autocomplete search";
    }
}