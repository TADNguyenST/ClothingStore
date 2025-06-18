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
     * Xử lý GET request: Lấy dữ liệu và hiển thị form sửa.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            long variantId = Long.parseLong(request.getParameter("variantId"));

            // Dùng các phương thức DAO độc lập để lấy dữ liệu hiển thị
            ProductVariant variant = inventoryDAO.getProductVariantById(variantId);
            Inventory inventory = inventoryDAO.getInventoryByVariantId(variantId);
            Product product = null;
            if (variant != null) {
                product = inventoryDAO.getProductById(variant.getProductId());
            }

            if (variant == null || inventory == null || product == null) {
                request.setAttribute("errorMessage", "Không tìm thấy thông tin đầy đủ của sản phẩm để sửa.");
                request.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(request, response);
                return;
            }

            request.setAttribute("variant", variant);
            request.setAttribute("inventory", inventory);
            request.setAttribute("product", product);

            request.getRequestDispatcher("/WEB-INF/views/staff/stock/edit-stock.jsp").forward(request, response);

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi khi tải dữ liệu cho trang sửa", e);
            throw new ServletException("Lỗi khi tải dữ liệu để sửa", e);
        }
    }

    /**
     * Xử lý POST request: Cập nhật dữ liệu vào database và ghi log trong một transaction.
     * @param request
     * @param response
     * @throws jakarta.servlet.ServletException
     * @throws java.io.IOException
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

//        HttpSession session = request.getSession();
//        Staff loggedInStaff = (Staff) session.getAttribute("loggedInStaff");

//        if (loggedInStaff == null) {
//            response.sendRedirect(request.getContextPath() + "/login.jsp"); // Yêu cầu đăng nhập
//            return;
//        }

        Connection conn = null;
        boolean success = false;
        try {
            // --- B1: Lấy kết nối và bắt đầu Transaction ---
            conn = new DBContext().getConnection();
            conn.setAutoCommit(false); // Bắt đầu giao dịch

            // --- B2: Lấy dữ liệu từ form ---
            long variantId = Long.parseLong(request.getParameter("variantId"));
            long inventoryId = Long.parseLong(request.getParameter("inventoryId"));
            int quantityValue = Integer.parseInt(request.getParameter("quantityValue"));
            String updateAction = request.getParameter("updateAction");
            int reservedQuantity = Integer.parseInt(request.getParameter("reservedQuantity"));

            // --- B3: Xử lý logic nghiệp vụ ---
            Inventory oldInventory = inventoryDAO.getInventoryByVariantId(variantId, conn);
            if (oldInventory == null) {
                throw new SQLException("Không tìm thấy inventory để cập nhật.");
            }

            int finalQuantity;
            String actionType;
            String notes;

            if ("add".equals(updateAction)) {
                finalQuantity = oldInventory.getQuantity() + quantityValue;
                actionType = "In";
//               notes = "Nhân viên ID " + loggedInStaff.getStaffId() + " đã nhập thêm " + quantityValue + " sản phẩm vào kho.";
                notes = "Nhân viên ID " + 001 + " đã nhập thêm " + quantityValue + " sản phẩm vào kho.";
            } else { // Mặc định là "set"
                finalQuantity = quantityValue;
                actionType = "Adjustment";
//                notes = "Nhân viên ID " + loggedInStaff.getStaffId() + " đã điều chỉnh số lượng tồn kho."; //khi nào có login thì xài
                  notes = "Nhân viên ID " + 001 + " đã điều chỉnh số lượng tồn kho.";
            }

            int quantityChanged = finalQuantity - oldInventory.getQuantity();

            // --- B4: Thực hiện các thao tác CSDL trong transaction ---
            // 4.1 Cập nhật bảng inventory
            Inventory inventoryToUpdate = new Inventory();
            inventoryToUpdate.setInventoryId(inventoryId);
            inventoryToUpdate.setQuantity(finalQuantity);
            inventoryToUpdate.setReservedQuantity(reservedQuantity);
            inventoryDAO.updateInventoryQuantities(inventoryToUpdate, conn);

            // 4.2 Ghi log vào stock_movements (chỉ khi số lượng tồn kho thay đổi)
            if (quantityChanged != 0) {
                StockMovement movement = new StockMovement();
                movement.setVariantId(variantId);
                movement.setMovementType(actionType);
                movement.setQuantityChanged(quantityChanged);
                movement.setNotes(notes);
//                movement.setCreatedBy(loggedInStaff.getStaffId());
            movement.setCreatedBy(4L);
                movement.setReferenceType("Adjustment");
                inventoryDAO.addStockMovement(movement, conn);
            }

            // --- B5: Commit Transaction ---
            conn.commit();
            success = true;
            LOGGER.info("Transaction cập nhật kho thành công.");

        } catch (NumberFormatException | SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi transaction, đang rollback...", e);
            if (conn != null) {
                try {
                    conn.rollback();
                    LOGGER.info("Transaction đã được rollback.");
                } catch (SQLException ex) {
                    LOGGER.log(Level.SEVERE, "Lỗi khi đang rollback transaction.", ex);
                }
            }
            // Chuyển lỗi ra ngoài để có thể xử lý ở trang error.jsp
            throw new ServletException("Lỗi khi cập nhật dữ liệu và ghi log", e);

        } finally {
            // --- B6: Dọn dẹp ---
            if (conn != null) {
                try {
                    conn.setAutoCommit(true); // Trả lại trạng thái mặc định
                    conn.close();
                } catch (SQLException e) {
                    LOGGER.log(Level.SEVERE, "Lỗi khi đóng kết nối.", e);
                }
            }
            // --- B7: Chuyển hướng ---
            // Đặt lệnh chuyển hướng ở đây để đảm bảo nó luôn được gọi sau khi kết nối đã đóng
            if (success) {
                response.sendRedirect(request.getContextPath() + "/Stock?update=success");
            } else {
                // Nếu thất bại, bạn có thể chuyển hướng với param 'failed'
                // Tuy nhiên, vì đã ném Exception ở trên, dòng này thường sẽ không được gọi
                // trừ khi bạn bắt Exception và không ném lại.
                response.sendRedirect(request.getContextPath() + "/Stock?update=failed");
            }
        }
    }
}