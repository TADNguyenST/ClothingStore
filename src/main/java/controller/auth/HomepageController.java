package controller.auth;

import dao.ProductDAO;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import model.Product;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class HomepageController extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            List<Product> newArrivals = productDAO.getNewArrivals(8);
            List<Product> bestSellers = productDAO.getBestSellers(4);

            // Calculate available quantity for each product and store in a map
            Map<Long, Integer> availableMap = new HashMap<>();
            for (Product product : newArrivals) {
                Long variantId = product.getDefaultVariantId();
                int available = productDAO.getAvailableQuantityByVariantId(variantId);
                availableMap.put(product.getProductId(), available);
                System.out.println("Homepage - New Arrival Product ID: " + product.getProductId() + ", Variant ID: " + variantId + ", Available: " + available);
            }
            for (Product product : bestSellers) {
                Long variantId = product.getDefaultVariantId();
                int available = productDAO.getAvailableQuantityByVariantId(variantId);
                availableMap.put(product.getProductId(), available);
                System.out.println("Homepage - Best Seller Product ID: " + product.getProductId() + ", Variant ID: " + variantId + ", Available: " + available);
            }

            request.setAttribute("newProducts", newArrivals);
            request.setAttribute("bestSellers", bestSellers);
            request.setAttribute("availableMap", availableMap);
            request.setAttribute("pageTitle", "Homepage");

            request.getRequestDispatcher("/WEB-INF/views/public/home.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "An error occurred while loading the homepage.");
        }
    }
}