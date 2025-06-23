package controller.stock;

import dao.StockManagermentDAO; // Đảm bảo đúng tên DAO
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.*;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(name = "StockDetailController", urlPatterns = {"/StockDetail"})
public class StockDetailController extends HttpServlet {
    private StockManagermentDAO stockDAO; // Đảm bảo đúng tên DAO

    @Override
    public void init() throws ServletException {
        stockDAO = new StockManagermentDAO(); // Đảm bảo đúng tên DAO
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // 1. Get variantId from the URL
            long variantId = Long.parseLong(request.getParameter("variantId"));

            // 2. Call DAO to get the main information
            ProductVariant variant = stockDAO.getProductVariantById(variantId);
            if (variant == null) {
                throw new ServletException("Product variant not found with ID: " + variantId);
            }

            Product product = stockDAO.getProductById(variant.getProductId());
            if (product == null) {
                throw new ServletException("Main product not found for variant ID: " + variantId);
            }

            // === SỬA LỖI #2: XỬ LÝ TRƯỜNG HỢP INVENTORY CÓ THỂ NULL ===
            Inventory inventory = stockDAO.getInventoryByVariantId(variantId);
            if (inventory == null) {
                // If no inventory record exists, create a default one with 0 quantity
                // to prevent NullPointerException on the JSP page.
                inventory = new Inventory();
                inventory.setVariantId(variantId);
                inventory.setQuantity(0);
                inventory.setReservedQuantity(0);
            }
            // ==========================================================

            // === SỬA LỖI #1: LẤY CATEGORY/BRAND TỪ MODEL MỚI ===
            Category category = null;
            // Lấy object Category từ Product, kiểm tra nó không null, rồi mới lấy ID
            if (product.getCategory() != null && product.getCategory().getCategoryId() != null) {
                category = stockDAO.getCategoryById(product.getCategory().getCategoryId());
            }

            Brand brand = null;
            // Tương tự với Brand
            if (product.getBrand() != null && product.getBrand().getBrandId() != null) {
                brand = stockDAO.getBrandById(product.getBrand().getBrandId());
            }
            // ========================================================

            // Get the stock movement history for this product
            List<Map<String, Object>> movementHistory = stockDAO.getMovementHistoryByVariantId(variantId);

            // 3. Set all retrieved objects as request attributes
            request.setAttribute("variant", variant);
            request.setAttribute("product", product);
            request.setAttribute("inventory", inventory);
            request.setAttribute("category", category);
            request.setAttribute("brand", brand);
            request.setAttribute("movementHistory", movementHistory);

            // 4. Forward to the details JSP page
            request.getRequestDispatcher("/WEB-INF/views/staff/stock/stock-details.jsp").forward(request, response);

        } catch (NumberFormatException | SQLException e) {
            // Log the error for easy debugging
            Logger.getLogger(StockDetailController.class.getName()).log(Level.SEVERE, "Error loading product details", e);
            request.setAttribute("errorMessage", "Error loading product details: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(request, response);
        }
    }
}