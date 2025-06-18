package controller.stock;

import dao.InventoryDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.*;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List; // Import if not already present
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

public class StockDetailController extends HttpServlet {
    private InventoryDAO inventoryDAO;

    @Override
    public void init() throws ServletException {
        inventoryDAO = new InventoryDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // 1. Get variantId from the URL
            long variantId = Long.parseLong(request.getParameter("variantId"));

            // 2. Call DAO to get the main information
            ProductVariant variant = inventoryDAO.getProductVariantById(variantId);
            if (variant == null) {
                throw new ServletException("Product variant not found with ID: " + variantId);
            }

            Product product = inventoryDAO.getProductById(variant.getProductId());
            if (product == null) {
                throw new ServletException("Main product not found for variant ID: " + variantId);
            }

            Inventory inventory = inventoryDAO.getInventoryByVariantId(variantId);

            Category category = null;
            if (product.getCategoryId() != null) {
                category = inventoryDAO.getCategoryById(product.getCategoryId());
            }

            Brand brand = null;
            if (product.getBrandId() != null) {
                brand = inventoryDAO.getBrandById(product.getBrandId());
            }

            // ================== ADD NEW FEATURE HERE ==================
            // Get the stock movement history for this product
            List<Map<String, Object>> movementHistory = inventoryDAO.getMovementHistoryByVariantId(variantId);
            // =================================================================

            // 3. Set all retrieved objects as request attributes
            request.setAttribute("variant", variant);
            request.setAttribute("product", product);
            request.setAttribute("inventory", inventory);
            request.setAttribute("category", category);
            request.setAttribute("brand", brand);
            request.setAttribute("movementHistory", movementHistory); // <<< Send the history list as well

            // 4. Forward to the details JSP page
            request.getRequestDispatcher("/WEB-INF/views/staff/stock/stock-details.jsp").forward(request, response);

        } catch (ServletException | IOException | NumberFormatException | SQLException e) {
            // Log the error for easy debugging
            Logger.getLogger(StockDetailController.class.getName()).log(Level.SEVERE, "Error loading product details", e);
            request.setAttribute("errorMessage", "Error loading product details: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(request, response);
        }
    }
}