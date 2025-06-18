package controller.stock;

import dao.StockManagermentDAO; // Đảm bảo đúng tên DAO
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Inventory;
import model.Product;
import model.ProductVariant;
import model.StockMovement;
import util.DBContext;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(name = "EditStockController", urlPatterns = {"/EditStock"})
public class EditStockController extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(EditStockController.class.getName());
    private StockManagermentDAO stockDAO; // Đảm bảo đúng tên DAO

    @Override
    public void init() throws ServletException {
        stockDAO = new StockManagermentDAO(); // Đảm bảo đúng tên DAO
    }

    /**
     * Handles the GET request: Fetches data and displays the edit form.
     * @param request
     * @param response
     * @throws jakarta.servlet.ServletException
     * @throws java.io.IOException
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            long variantId = Long.parseLong(request.getParameter("variantId"));

            ProductVariant variant = stockDAO.getProductVariantById(variantId);
            Inventory inventory = stockDAO.getInventoryByVariantId(variantId);
            Product product = null;
            if (variant != null) {
                product = stockDAO.getProductById(variant.getProductId());
            }

            if (variant == null || inventory == null || product == null) {
                request.setAttribute("errorMessage", "Could not find complete information for the product to be edited.");
                request.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(request, response);
                return;
            }

            request.setAttribute("variant", variant);
            request.setAttribute("inventory", inventory);
            request.setAttribute("product", product);

            request.getRequestDispatcher("/WEB-INF/views/staff/stock/edit-stock.jsp").forward(request, response);

        } catch (NumberFormatException | SQLException e) {
            LOGGER.log(Level.SEVERE, "Error loading data for the edit page", e);
            request.setAttribute("errorMessage", "Error loading data for edit: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(request, response);
        }
    }

    /**
     * Handles the POST request: Updates data in the database and logs the movement within a transaction.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Giả sử staff ID là 4L cho mục đích phát triển
        long staffId = 4L;

        Connection conn = null;
        boolean success = false;
        try {
            // --- Step 1: Get connection and start transaction ---
            conn = new DBContext().getConnection();
            conn.setAutoCommit(false); // Start transaction

            // --- Step 2: Get data from the form ---
            long variantId = Long.parseLong(request.getParameter("variantId"));
            long inventoryId = Long.parseLong(request.getParameter("inventoryId"));
            int quantityValue = Integer.parseInt(request.getParameter("quantityValue"));
            String updateAction = request.getParameter("updateAction");
            int reservedQuantity = Integer.parseInt(request.getParameter("reservedQuantity"));

            // --- Step 3: Process business logic ---
            Inventory oldInventory = stockDAO.getInventoryByVariantId(variantId, conn);
            if (oldInventory == null) {
                throw new SQLException("Could not find inventory to update.");
            }

            int finalQuantity;
            String actionType;
            String notes;
            
            int quantityChanged;

            if ("add".equals(updateAction)) {
                finalQuantity = oldInventory.getQuantity() + quantityValue;
                quantityChanged = quantityValue; // Thêm vào thì lượng thay đổi là số dương
                actionType = "In";
                notes = "Staff ID " + staffId + " added " + quantityValue + " items to stock.";
            } else { // Default is "set"
                finalQuantity = quantityValue;
                quantityChanged = finalQuantity - oldInventory.getQuantity(); // Điều chỉnh thì lượng thay đổi là chênh lệch
                actionType = "Adjustment";
                notes = "Staff ID " + staffId + " adjusted the stock quantity.";
            }

            // --- Step 4: Perform database operations within the transaction ---
            Inventory inventoryToUpdate = new Inventory();
            inventoryToUpdate.setInventoryId(inventoryId);
            inventoryToUpdate.setQuantity(finalQuantity);
            inventoryToUpdate.setReservedQuantity(reservedQuantity);
            stockDAO.updateInventoryQuantities(inventoryToUpdate, conn);

            if (quantityChanged != 0) {
                StockMovement movement = new StockMovement();
                movement.setVariantId(variantId);
                movement.setMovementType(actionType);
                movement.setQuantity(quantityChanged);
                movement.setNotes(notes);
                movement.setCreatedBy(staffId);
                movement.setReferenceType("Adjustment");
                stockDAO.addStockMovement(movement, conn);
            }

            // --- Step 5: Commit the transaction ---
            conn.commit();
            success = true;
            LOGGER.info("Stock update transaction committed successfully.");

        } catch (NumberFormatException | SQLException e) {
            LOGGER.log(Level.SEVERE, "Transaction error, rolling back...", e);
            if (conn != null) {
                try {
                    conn.rollback();
                    LOGGER.info("Transaction has been rolled back.");
                } catch (SQLException ex) {
                    LOGGER.log(Level.SEVERE, "Error while rolling back transaction.", ex);
                }
            }
            request.setAttribute("errorMessage", "Error while updating data: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(request, response);
            return; // Dừng thực thi sau khi chuyển đến trang lỗi

        } finally {
            // --- Step 6: Cleanup ---
            if (conn != null) {
                try {
                    conn.setAutoCommit(true); // Return to default state
                    conn.close();
                } catch (SQLException e) {
                    LOGGER.log(Level.SEVERE, "Error closing connection.", e);
                }
            }
        }
        
        // --- Step 7: Redirect ---
        // === SỬA LỖI TẠI ĐÂY ===
        // Chỉ thực hiện redirect sau khi toàn bộ khối try-catch-finally đã hoàn tất.
        // Điều này tránh được lỗi IllegalStateException.
        String redirectUrl = request.getContextPath() + "/Stock?update=" + (success ? "success" : "failed");
        response.sendRedirect(redirectUrl);
    }
}