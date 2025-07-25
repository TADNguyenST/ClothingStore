package controller.stock;

import DTO.ApiResponse;
import DTO.PurchaseOrderContextDTO;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import dao.PurchaseOrderDAO;
import model.*;
import DTO.*;
import util.DBContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import util.PdfGenerator;

@WebServlet(name = "PurchaseOrderController", urlPatterns = {"/PurchaseOrder"})
public class PurchaseOrderController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(PurchaseOrderController.class.getName());
    private PurchaseOrderDAO purchaseDAO;
    private Gson gson;

    @Override
    public void init() {
        purchaseDAO = new PurchaseOrderDAO();
        gson = new GsonBuilder().setDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").create();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null && request.getParameter("poId") != null) {
            action = "edit";
        } else if (action == null) {
            action = "list";
        }

        try {
            switch (action) {
                case "edit":
                    handleEditPOPage(request, response);
                    break;
                case "startNewPO":
                    handleStartNewPO(request, response);
                    break;
                case "printReceipt":
                    handlePrintReceipt(request, response);
                    break;
                default:
                    response.sendRedirect(request.getContextPath() + "/Admindashboard?action=purchaseorder&module=stock");
                    break;
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in doGet", e);
            request.setAttribute("errorMessage", "Error loading page: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        ApiResponse<?> apiResponse = null;

        // Giả lập lấy user từ session để kiểm tra quyền
        // Lưu ý: Đổi tên lớp thành Users cho khớp với code của bạn
        Users currentUser = new Users();
        currentUser.setUserId(1L);
        currentUser.setRole("Admin");

        try {
            switch (action) {
                case "autoSave":
                    apiResponse = handleAutoSave(request);
                    break;
                case "deleteItem":
                    apiResponse = handleAjaxDeleteItem(request);
                    break;
                case "sendOrder":
                    apiResponse = handleAjaxSendOrder(request);
                    break;
                case "confirmOrder":
                    apiResponse = handleAjaxConfirmOrder(request, currentUser);
                    break;
                case "receiveDelivery":
                    apiResponse = handleAjaxReceiveDelivery(request, currentUser);
                    break;
                case "cancelOrder":
                    apiResponse = handleAjaxCancelOrder(request);
                    break;
                case "deleteDraft":
                    apiResponse = handleAjaxDeleteDraft(request);
                    break;

                case "getProductsForSelection":
                    apiResponse = handleAjaxGetProductsForSelection();
                    break;
                case "addProducts":
                    apiResponse = handleAjaxAddProducts(request);
                    break;
                // --- KẾT THÚC PHẦN THÊM VÀO ---

                default:
                    apiResponse = ApiResponse.error("Invalid action.");
                    break;
            }
            sendJsonResponse(response, HttpServletResponse.SC_OK, apiResponse);

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error processing AJAX request for action: " + action, e);
            apiResponse = ApiResponse.error(e.getMessage());
            sendJsonResponse(response, HttpServletResponse.SC_BAD_REQUEST, apiResponse);
        }
    }

    // --- CÁC HÀM XỬ LÝ LOGIC ---
    // ... (Các hàm handleAutoSave, handleAjaxDeleteItem, handleAjaxSendOrder giữ nguyên) ...
    private ApiResponse<Object> handleAutoSave(HttpServletRequest request) throws SQLException {
        long poId = Long.parseLong(request.getParameter("poId"));
        String updateType = request.getParameter("updateType");
        PurchaseOrderHeaderDTO po = purchaseDAO.getPurchaseOrderHeader(poId);
        if (!"Draft".equals(po.getStatus()) && !"Sent".equals(po.getStatus())) {
            throw new IllegalStateException("Cannot edit a PO that is not in Draft or Sent status.");
        }
        switch (updateType) {
            case "quantity":
                long podIdQty = Long.parseLong(request.getParameter("podId"));
                int quantity = Integer.parseInt(request.getParameter("value"));

                // --- SERVER-SIDE VALIDATION CHO SỐ LƯỢNG ---
                if (quantity <= 0) {
                    // Ném ra lỗi, Controller sẽ bắt và gửi về cho client
                    throw new IllegalArgumentException("Quantity must be a positive number.");
                }
                purchaseDAO.updateItemQuantity(podIdQty, quantity);
                break;
            case "price":
                long podIdPrice = Long.parseLong(request.getParameter("podId"));
                BigDecimal price = new BigDecimal(request.getParameter("value"));

                // --- SERVER-SIDE VALIDATION CHO GIÁ TIỀN ---
                if (price.compareTo(BigDecimal.ZERO) < 0) {
                    // Ném ra lỗi
                    throw new IllegalArgumentException("Unit price cannot be negative.");
                }
                purchaseDAO.updateItemPrice(podIdPrice, price);
                break;
            case "notes":
                String userNotes = request.getParameter("value");
                PurchaseOrderHeaderDTO currentPO = purchaseDAO.getPurchaseOrderHeader(poId);
                String currentFullNotes = currentPO.getNotes();
                String prefix = "";
                int prefixLength = 31; // Độ dài chính xác

                if (currentFullNotes != null && currentFullNotes.startsWith("Purchase Order") && currentFullNotes.length() >= prefixLength) {
                    prefix = currentFullNotes.substring(0, prefixLength);
                } else {
                    prefix = currentFullNotes != null ? currentFullNotes : "";
                }

                String newFullNotes = (prefix + " " + userNotes).trim();
                purchaseDAO.updatePONotes(poId, newFullNotes);
                break;
            case "supplier":
                String supplierIdStr = request.getParameter("value");
                if (supplierIdStr != null && !supplierIdStr.isEmpty()) {
                    // Nếu có giá trị, cập nhật bình thường
                    long supplierId = Long.parseLong(supplierIdStr);
                    purchaseDAO.updateDraftPOSupplier(poId, supplierId);
                } else {
                    // Nếu giá trị rỗng, gọi hàm xóa supplier
                    purchaseDAO.clearPOSupplier(poId);
                }
                break;
            default:
                throw new IllegalArgumentException("Invalid update type.");
        }
        return ApiResponse.success(null, "Saved");
    }

    private ApiResponse<Object> handleAjaxDeleteItem(HttpServletRequest request) throws SQLException {
        long podId = Long.parseLong(request.getParameter("podId"));
        purchaseDAO.deleteItemFromPO(podId);
        return ApiResponse.success(null, "Item deleted successfully.");
    }

    private ApiResponse<Object> handleAjaxSendOrder(HttpServletRequest request) throws SQLException {
        long poId = Long.parseLong(request.getParameter("poId"));
        PurchaseOrderHeaderDTO poHeader = purchaseDAO.getPurchaseOrderHeader(poId);
        List<PurchaseOrderItemDTO> poItems = purchaseDAO.getItemsInPurchaseOrder(poId);
        if (poHeader.getSupplierId() == null || poHeader.getSupplierId() <= 0) {
            throw new IllegalArgumentException("A supplier must be selected before sending.");
        }
        if (poItems == null || poItems.isEmpty()) {
            throw new IllegalArgumentException("Cannot send an empty purchase order.");
        }
        for (PurchaseOrderItemDTO item : poItems) {
            if (item.getQuantity() <= 0) {
                throw new IllegalArgumentException("Quantity for product '" + item.getProductName() + "' must be greater than 0.");
            }
        }
        try ( Connection conn = new DBContext().getConnection()) {
            conn.setAutoCommit(false);
            try {
                if (!"Draft".equals(poHeader.getStatus())) {
                    throw new IllegalStateException("Only Draft orders can be sent.");
                }
                purchaseDAO.updatePOStatus(poId, "Sent", conn);
                conn.commit();
            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
        }
        return ApiResponse.success(null, "Order has been sent.");
    }

    // Lưu ý: Đã đổi tên lớp thành Users cho khớp với code của bạn
    private ApiResponse<Object> handleAjaxConfirmOrder(HttpServletRequest request, Users currentUser) throws SQLException {
        if (!"Admin".equals(currentUser.getRole())) {
            throw new SecurityException("Access Denied: Only Admins can confirm orders.");
        }
        long poId = Long.parseLong(request.getParameter("poId"));
        try ( Connection conn = new DBContext().getConnection()) {
            conn.setAutoCommit(false);
            try {
                PurchaseOrderHeaderDTO po = purchaseDAO.getPurchaseOrderHeader(poId);
                if (!"Sent".equals(po.getStatus())) {
                    throw new IllegalStateException("Only Sent orders can be confirmed.");
                }
                purchaseDAO.updatePOStatus(poId, "Confirmed", conn);
                conn.commit();
            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
        }
        return ApiResponse.success(null, "Order has been confirmed.");
    }

    private ApiResponse<Object> handleAjaxReceiveDelivery(HttpServletRequest request, Users currentUser) throws SQLException {
        long poId = Long.parseLong(request.getParameter("poId"));
        long staffId = currentUser.getUserId();
        Connection conn = null;
        try {
            conn = new DBContext().getConnection();
            conn.setAutoCommit(false);
            PurchaseOrderHeaderDTO po = purchaseDAO.getPurchaseOrderHeader(poId);
            if (!"Confirmed".equals(po.getStatus())) {
                throw new IllegalStateException("Only Confirmed orders can be delivered.");
            }
            PurchaseOrderContextDTO context = purchaseDAO.getContextForNotes(poId, conn);
            if (context == null) {
                throw new SQLException("Could not find context for PO ID: " + poId);
            }
            String currentDate = new SimpleDateFormat("dd/MM/yyyy").format(new Date());
            String noteMessage = String.format("Purchase Order %s by %s, supplier %s", currentDate, context.getStaffName(), context.getSupplierName());
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
                sm.setNotes(noteMessage);
                purchaseDAO.addStockMovement(sm, conn);
            }
            purchaseDAO.updatePOStatus(poId, "Delivered", conn);
            conn.commit();
        } catch (Exception e) {
            if (conn != null) {
                conn.rollback();
            }
            throw new SQLException("Failed to receive delivery for PO#" + poId, e);
        } finally {
            if (conn != null) {
                conn.close();
            }
        }
        return ApiResponse.success(null, "Delivery received and stock updated.");
    }

    private ApiResponse<Object> handleAjaxCancelOrder(HttpServletRequest request) throws SQLException {
        long poId = Long.parseLong(request.getParameter("poId"));
        try ( Connection conn = new DBContext().getConnection()) {
            conn.setAutoCommit(false);
            try {
                PurchaseOrderHeaderDTO po = purchaseDAO.getPurchaseOrderHeader(poId);
                if (!"Draft".equals(po.getStatus()) && !"Sent".equals(po.getStatus())) {
                    throw new IllegalStateException("This order can no longer be cancelled.");
                }
                purchaseDAO.updatePOStatus(poId, "Cancelled", conn);
                conn.commit();
            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
        }
        return ApiResponse.success(null, "Order has been cancelled.");
    }

    private ApiResponse<Object> handleAjaxDeleteDraft(HttpServletRequest request) throws SQLException {
        long poId = Long.parseLong(request.getParameter("poId"));
        int deletedRows = purchaseDAO.deleteDraftPO(poId);
        if (deletedRows > 0) {
            return ApiResponse.success(null, "Draft order has been deleted successfully.");
        } else {
            throw new IllegalStateException("Could not delete the order. It might not be a draft anymore.");
        }
    }

    // --- CÁC HÀM XỬ LÝ CHO VIỆC CHỌN SẢN PHẨM (ĐÃ THÊM) ---
    private ApiResponse<List<ProductVariantSelectionDTO>> handleAjaxGetProductsForSelection() throws SQLException {
        List<ProductVariantSelectionDTO> variants = purchaseDAO.getAllVariantsForSelection();
        return ApiResponse.success(variants);
    }

    private ApiResponse<List<PurchaseOrderItemDTO>> handleAjaxAddProducts(HttpServletRequest request) throws SQLException {
        long poId = Long.parseLong(request.getParameter("poId"));
        String[] selectedVariants = request.getParameterValues("variantIds[]");
        if (selectedVariants != null && selectedVariants.length > 0) {
            List<Long> variantIds = new ArrayList<>();
            for (String idStr : selectedVariants) {
                variantIds.add(Long.parseLong(idStr));
            }
            purchaseDAO.addVariantsToPODetails(poId, variantIds);
            List<PurchaseOrderItemDTO> updatedItems = purchaseDAO.getItemsInPurchaseOrder(poId);
            return ApiResponse.success(updatedItems, "Products added successfully.");
        }
        throw new IllegalArgumentException("No products selected.");
    }

    // --- CÁC HÀM HELPER VÀ TẢI TRANG ---
    private void handleEditPOPage(HttpServletRequest request, HttpServletResponse response) throws SQLException, ServletException, IOException {
        long poId = Long.parseLong(request.getParameter("poId"));
        PurchaseOrderHeaderDTO poData = purchaseDAO.getPurchaseOrderHeader(poId);
        List<PurchaseOrderItemDTO> itemsInPO = purchaseDAO.getItemsInPurchaseOrder(poId);
        List<Supplier> suppliers = purchaseDAO.getAllActiveSuppliers();

        if (poData != null && poData.getNotes() != null) {
            String fullNotes = poData.getNotes();
            // Độ dài chính xác của tiền tố: "Purchase Order " (15) + "dd/MM/yyyy HH:mm" (16) = 31
            int prefixLength = 31;

            if (fullNotes.startsWith("Purchase Order") && fullNotes.length() >= prefixLength) {
                String prefix = fullNotes.substring(0, prefixLength);
                poData.setNotePrefix(prefix);
                if (fullNotes.length() > prefixLength) {
                    poData.setUserNotes(fullNotes.substring(prefixLength).trim());
                } else {
                    poData.setUserNotes("");
                }
            } else {
                poData.setNotePrefix(fullNotes);
                poData.setUserNotes("");
            }

        }
        // --- KẾT THÚC ---

        request.setAttribute("poData", gson.toJson(poData));
        request.setAttribute("itemsInPO", gson.toJson(itemsInPO));
        request.setAttribute("suppliers", suppliers);
        request.getRequestDispatcher("/WEB-INF/views/staff/stock/po-detail.jsp").forward(request, response);
    }

    private void handleStartNewPO(HttpServletRequest request, HttpServletResponse response) throws SQLException, IOException {
        long staffId = 1; // Giả lập lấy từ session
        String poName = "Purchase Order " + new SimpleDateFormat("dd/MM/yyyy HH:mm").format(new Date());
        long newPoId = purchaseDAO.createDraftPO(poName, staffId);
        response.sendRedirect("PurchaseOrder?action=edit&poId=" + newPoId);
    }

    private void sendJsonResponse(HttpServletResponse response, int statusCode, Object data) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setStatus(statusCode);
        PrintWriter out = response.getWriter();
        out.print(gson.toJson(data));
        out.flush();
    }

    // Trong PurchaseOrderController.java
    private void handlePrintReceipt(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        long poId = Long.parseLong(request.getParameter("poId"));

        // 1. Lấy dữ liệu từ DAO
        PurchaseOrderHeaderDTO poHeader = purchaseDAO.getPurchaseOrderHeader(poId);
        List<PurchaseOrderItemDTO> poItems = purchaseDAO.getItemsInPurchaseOrder(poId);

        // --- THÊM BƯỚC KIỂM TRA NULL VÀO ĐÂY ---
        if (poHeader == null || poItems == null) {
            LOGGER.log(Level.SEVERE, "Data not found for Purchase Order ID: " + poId);
            // Trả về một lỗi rõ ràng cho trình duyệt thay vì file PDF trắng
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Purchase Order data not found for ID: " + poId);
            return; // Dừng thực thi
        }

        if (poItems.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Cannot print a receipt for an empty Purchase Order.");
            return; // Dừng thực thi
        }
        // --- KẾT THÚC BƯỚC KIỂM TRA ---

        // 2. Thiết lập response header để trả về file PDF
        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "inline; filename=\"PhieuNhapKho_" + poId + ".pdf\"");

        // 3. Gọi hàm tạo PDF và ghi vào OutputStream của response
        OutputStream out = response.getOutputStream();
        PdfGenerator.generateReceiptPdf(out, poHeader, poItems);
    }
}
