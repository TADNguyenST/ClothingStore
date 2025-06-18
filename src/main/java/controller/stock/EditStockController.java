package controller.stock;

import dao.InventoryDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Inventory;
import model.Product;
import model.ProductVariant;
import model.Staff;
import model.StockMovement;
import util.DBContext;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

public class EditStockController extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(EditStockController.class.getName());
    private InventoryDAO inventoryDAO;

    @Override
    public void init() throws ServletException {
        inventoryDAO = new InventoryDAO();
    }

    /**
     * Handles the GET request: Fetches data and displays the edit form.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            long variantId = Long.parseLong(request.getParameter("variantId"));

            // Use standalone DAO methods to fetch display data
            ProductVariant variant = inventoryDAO.getProductVariantById(variantId);
            Inventory inventory = inventoryDAO.getInventoryByVariantId(variantId);
            Product product = null;
            if (variant != null) {
                product = inventoryDAO.getProductById(variant.getProductId());
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

        } catch (ServletException | IOException | NumberFormatException | SQLException e) {
            LOGGER.log(Level.SEVERE, "Error loading data for the edit page", e);
            throw new ServletException("Error loading data for edit", e);
        }
    }

    /**
     * Handles the POST request: Updates data in the database and logs the movement within a transaction.
     * @param request
     * @param response
     * @throws jakarta.servlet.ServletException
     * @throws java.io.IOException
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // It is highly recommended to use session management for security and logging.
//        HttpSession session = request.getSession();
//        Staff loggedInStaff = (Staff) session.getAttribute("loggedInStaff");
//
//        if (loggedInStaff == null) {
//            response.sendRedirect(request.getContextPath() + "/login.jsp"); // Require login
//            return;
//        }

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
            Inventory oldInventory = inventoryDAO.getInventoryByVariantId(variantId, conn);
            if (oldInventory == null) {
                throw new SQLException("Could not find inventory to update.");
            }

            int finalQuantity;
            String actionType;
            String notes;

//            if ("add".equals(updateAction)) {
//                finalQuantity = oldInventory.getQuantity() + quantityValue;
//                actionType = "In";
//                notes = "Staff ID " + loggedInStaff.getStaffId() + " added " + quantityValue + " items to stock.";
//            } else { // Default is "set"
//                finalQuantity = quantityValue;
//                actionType = "Adjustment";
//                notes = "Staff ID " + loggedInStaff.getStaffId() + " adjusted the stock quantity.";
//            }

            if ("add".equals(updateAction)) {
                finalQuantity = oldInventory.getQuantity() + quantityValue;
                actionType = "In";
                notes = "Staff ID " + 4 + " added " + quantityValue + " items to stock.";
            } else { // Default is "set"
                finalQuantity = quantityValue;
                actionType = "Adjustment";
                notes = "Staff ID " + 4 + " adjusted the stock quantity.";
            }

            int quantityChanged = finalQuantity - oldInventory.getQuantity();

            // --- Step 4: Perform database operations within the transaction ---
            // 4.1 Update the inventory table
            Inventory inventoryToUpdate = new Inventory();
            inventoryToUpdate.setInventoryId(inventoryId);
            inventoryToUpdate.setQuantity(finalQuantity);
            inventoryToUpdate.setReservedQuantity(reservedQuantity);
            inventoryDAO.updateInventoryQuantities(inventoryToUpdate, conn);

            // 4.2 Log to stock_movements (only if the stock quantity changes)
            if (quantityChanged != 0) {
                StockMovement movement = new StockMovement();
                movement.setVariantId(variantId);
                movement.setMovementType(actionType);
                movement.setQuantityChanged(quantityChanged);
                movement.setNotes(notes);
//              movement.setCreatedBy(loggedInStaff.getStaffId());
                movement.setCreatedBy(4L);
                movement.setReferenceType("Adjustment");
                inventoryDAO.addStockMovement(movement, conn);
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
            // Re-throw the exception to be handled by an error page or filter
            throw new ServletException("Error while updating data and logging movement", e);

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
            
            // --- Step 7: Redirect ---
            // Place the redirect here to ensure it's always called after the connection is closed
            String redirectUrl = request.getContextPath() + "/Stock?update=" + (success ? "success" : "failed");
            response.sendRedirect(redirectUrl);
        }
    }
}