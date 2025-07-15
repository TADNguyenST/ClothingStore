package controller.stock;

import dao.PurchaseOrderDAO;
import dao.StockManagermentDAO;
import model.PurchaseOrder;
import model.PurchaseOrderDetail;
import model.StockMovement;
import util.DBContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(name = "PurchaseOrderController", urlPatterns = {"/PurchaseOrder"})
public class PurchaseOrderController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(PurchaseOrderController.class.getName());
    private PurchaseOrderDAO purchaseDAO;
    private StockManagermentDAO stockDAO;

    @Override
    public void init() {
        purchaseDAO = new PurchaseOrderDAO();
        stockDAO = new StockManagermentDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            if (request.getParameter("poId") != null) {
                action = "edit";
            } else {
                response.sendRedirect("Stock");
                return;
            }
        }

        try {
            switch (action) {
                case "startNewPO":
                    handleStartNewPO(request, response);
                    break;
                case "edit":
                    handleEditPO(request, response);
                    break;
                case "showProductSelector":
                    handleShowProductSelector(request, response);
                    break;
                case "deleteItem":
                    handleDeleteItem(request, response);
                    break;
                case "cancel":
                    handleCancelPO(request, response);
                    break;
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in PurchaseOrderController GET", e);
            throw new ServletException("GET action failed in PurchaseOrderController", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        if (action == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Action parameter is missing.");
            return;
        }

        try {
            switch (action) {
                case "addProducts":
                    handleAddProducts(request, response);
                    break;
                case "saveDraft":
                    handleSaveDraft(request, response);
                    break;
                case "finalize":
                    handleFinalizePO(request, response);
                    break;
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in PurchaseOrderController POST", e);
            throw new ServletException("POST action failed in PurchaseOrderController", e);
        }
    }

    private void handleStartNewPO(HttpServletRequest request, HttpServletResponse response) throws SQLException, IOException {
        long staffId = 1;
        String poName = "Purchase Order " + new SimpleDateFormat("dd/MM/yyyy HH:mm").format(new Date());
        long newPoId = purchaseDAO.createDraftPO(poName, staffId);
        response.sendRedirect("PurchaseOrder?action=edit&poId=" + newPoId);
    }

    private void handleEditPO(HttpServletRequest request, HttpServletResponse response) throws SQLException, ServletException, IOException {
        long poId = Long.parseLong(request.getParameter("poId"));
        Map<String, Object> poData = purchaseDAO.getPurchaseOrderHeader(poId);
        List<Map<String, Object>> itemsInPO = purchaseDAO.getItemsInPurchaseOrder(poId);
        List<model.Supplier> suppliers = purchaseDAO.getAllActiveSuppliers();

        request.setAttribute("poData", poData);
        request.setAttribute("itemsInPO", itemsInPO);
        request.setAttribute("suppliers", suppliers);
        request.getRequestDispatcher("/WEB-INF/views/staff/stock/po-detail.jsp").forward(request, response);
    }

    private void handleShowProductSelector(HttpServletRequest request, HttpServletResponse response) throws SQLException, ServletException, IOException {
        long poId = Long.parseLong(request.getParameter("poId"));
        List<Map<String, Object>> productDataList = purchaseDAO.getAllVariantsForSelection();

        request.setAttribute("poId", poId);
        request.setAttribute("productDataList", productDataList);
        request.getRequestDispatcher("/WEB-INF/views/staff/stock/po-product-selector.jsp").forward(request, response);
    }

    private void handleDeleteItem(HttpServletRequest request, HttpServletResponse response) throws SQLException, IOException {
        long poId = Long.parseLong(request.getParameter("poId"));
        long podId = Long.parseLong(request.getParameter("podId"));
        purchaseDAO.deleteItemFromPO(podId);
        response.sendRedirect("PurchaseOrder?action=edit&poId=" + poId);
    }

    private void handleCancelPO(HttpServletRequest request, HttpServletResponse response) throws SQLException, IOException {
        long poId = Long.parseLong(request.getParameter("poId"));
        purchaseDAO.deleteDraftPO(poId);
        response.sendRedirect("admindashboard?action=purchaseorder&module=stock");
    }

    private void handleAddProducts(HttpServletRequest request, HttpServletResponse response) throws SQLException, IOException {
        long poId = Long.parseLong(request.getParameter("poId"));
        String[] selectedVariants = request.getParameterValues("selectedVariants");

        if (selectedVariants != null && selectedVariants.length > 0) {
            List<Long> variantIds = new ArrayList<>();
            for (String idStr : selectedVariants) {
                variantIds.add(Long.parseLong(idStr));
            }
            purchaseDAO.addVariantsToPODetails(poId, variantIds);
        }
        response.sendRedirect("PurchaseOrder?action=edit&poId=" + poId);
    }

    private void handleSaveDraft(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        long poId = Long.parseLong(request.getParameter("poId"));
        try {
            // === START: CẬP NHẬT GHI CHÚ (NOTES) ===
            String notes = request.getParameter("notes");
            if (notes != null) {
                // Bạn cần tự tạo phương thức này trong PurchaseOrderDAO
                purchaseDAO.updatePONotes(poId, notes);
            }
            // === END: CẬP NHẬT GHI CHÚ (NOTES) ===
            
            String supplierIdStr = request.getParameter("supplierId");
            if (supplierIdStr != null && !supplierIdStr.isEmpty()) {
                long supplierId = Long.parseLong(supplierIdStr);
                purchaseDAO.updateDraftPOSupplier(poId, supplierId);
            }

            Enumeration<String> paramNames = request.getParameterNames();
            while (paramNames.hasMoreElements()) {
                String paramName = paramNames.nextElement();
                if (paramName.startsWith("quantity_")) {
                    long podId = Long.parseLong(paramName.substring("quantity_".length()));
                    int quantity = Integer.parseInt(request.getParameter(paramName));
                    BigDecimal unitPrice = new BigDecimal(request.getParameter("price_" + podId));
                    purchaseDAO.updatePODetail(podId, quantity, unitPrice);
                }
            }
            response.sendRedirect("PurchaseOrder?action=edit&poId=" + poId + "&save=success");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error saving draft PO", e);
            throw new ServletException("Error saving draft", e);
        }
    }

    private void handleFinalizePO(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        long poId = Long.parseLong(request.getParameter("poId"));
        Connection conn = null;

        try {
            List<Map<String, Object>> itemsInPO = purchaseDAO.getItemsInPurchaseOrder(poId);
            if (itemsInPO == null || itemsInPO.isEmpty()) {
                request.setAttribute("errorMessage", "Cannot finalize an empty purchase order. Please add products.");
                handleEditPO(request, response);
                return;
            }
            String supplierIdStr = request.getParameter("supplierId");
            if (supplierIdStr == null || supplierIdStr.isEmpty()) {
                request.setAttribute("errorMessage", "Please select a supplier before finalizing the purchase order.");
                handleEditPO(request, response);
                return;
            }
            long supplierId = Long.parseLong(request.getParameter("supplierId"));
            long staffId = 1;

            conn = new DBContext().getConnection();
            conn.setAutoCommit(false);

            // === START: CẬP NHẬT GHI CHÚ (NOTES) TRONG GIAO DỊCH ===
            String notes = request.getParameter("notes");
            if (notes != null) {
                // Bạn cần tự tạo phương thức này trong PurchaseOrderDAO, nhận vào Connection
                purchaseDAO.updatePONotes(poId, notes, conn);
            }
            // === END: CẬP NHẬT GHI CHÚ (NOTES) TRONG GIAO DỊCH ===

            Enumeration<String> paramNames = request.getParameterNames();
            while (paramNames.hasMoreElements()) {
                String paramName = paramNames.nextElement();
                if (paramName.startsWith("quantity_")) {
                    long podId = Long.parseLong(paramName.substring("quantity_".length()));
                    int quantity = Integer.parseInt(request.getParameter(paramName));
                    BigDecimal unitPrice = new BigDecimal(request.getParameter("price_" + podId));
                    purchaseDAO.updatePODetail(podId, quantity, unitPrice, conn);
                }
            }

            List<PurchaseOrderDetail> items = purchaseDAO.getItemsForConfirmation(poId, conn);
            for (PurchaseOrderDetail item : items) {
                purchaseDAO.increaseInventoryForVariant(item.getVariantId(), item.getQuantity(), conn);
                StockMovement sm = new StockMovement();
                sm.setVariantId(item.getVariantId());
                sm.setMovementType("In");
                sm.setQuantity(item.getQuantity());
                sm.setReferenceType("Purchase Order");
                sm.setReferenceId(poId);
                sm.setCreatedBy(staffId);
                sm.setNotes("Stock import from PO#" + poId);
                purchaseDAO.addStockMovement(sm, conn);
            }

            purchaseDAO.finalizePO(poId, supplierId, "Delivered", conn);
            conn.commit();
            response.sendRedirect("PurchaseOrder?action=edit&poId=" + poId + "&confirm=success");

        } catch (Exception e) {
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) { LOGGER.log(Level.SEVERE, "Failed to rollback", ex); }
            throw new ServletException("Transaction failed for PO finalization", e);
        } finally {
            if (conn != null) try { conn.close(); } catch (SQLException ex) { LOGGER.log(Level.SEVERE, "Failed to close connection", ex); }
        }
    }
}