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
import java.util.List; // Thêm import nếu chưa có
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
            // 1. Lấy variantId từ URL
            long variantId = Long.parseLong(request.getParameter("variantId"));

            // 2. Gọi DAO để lấy các thông tin chính
            ProductVariant variant = inventoryDAO.getProductVariantById(variantId);
            if (variant == null) {
                throw new ServletException("Không tìm thấy biến thể sản phẩm với ID: " + variantId);
            }

            Product product = inventoryDAO.getProductById(variant.getProductId());
            if (product == null) {
                throw new ServletException("Không tìm thấy sản phẩm chính cho biến thể ID: " + variantId);
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

            // ================== THÊM TÍNH NĂNG MỚI TẠI ĐÂY ==================
            // Lấy lịch sử thay đổi kho cho sản phẩm này
              List<Map<String, Object>> movementHistory = inventoryDAO.getMovementHistoryByVariantId(variantId);
            // =================================================================

            // 3. Đặt tất cả các đối tượng đã lấy được vào request
            request.setAttribute("variant", variant);
            request.setAttribute("product", product);
            request.setAttribute("inventory", inventory);
            request.setAttribute("category", category);
            request.setAttribute("brand", brand);
            request.setAttribute("movementHistory", movementHistory); // <<< Gửi thêm danh sách lịch sử

            // 4. Chuyển tiếp đến trang JSP chi tiết
            request.getRequestDispatcher("/WEB-INF/views/staff/stock/stock-details.jsp").forward(request, response);

        } catch (ServletException | IOException | NumberFormatException | SQLException e) {
            // Ghi log lỗi để dễ debug
            Logger.getLogger(StockDetailController.class.getName()).log(Level.SEVERE, "Lỗi khi tải chi tiết sản phẩm", e);
            request.setAttribute("errorMessage", "Lỗi khi tải chi tiết sản phẩm: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(request, response);
        }
    }
}