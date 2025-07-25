package controller.stock;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import dao.StockManagermentDAO; // Đảm bảo đúng tên DAO
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(name = "StockDetailController", urlPatterns = {"/StockDetail"})
public class StockDetailController extends HttpServlet {

    private StockManagermentDAO stockDAO;
    private Gson gson;

    @Override
    public void init() throws ServletException {
        stockDAO = new StockManagermentDAO();

        // Cấu hình Gson
        GsonBuilder gsonBuilder = new GsonBuilder();

        gson = gsonBuilder.create();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Lấy tham số 'ajax' để xác định loại yêu cầu
        String ajaxRequest = request.getParameter("ajax");

        try {
            String variantStr = request.getParameter("variantId");
            if (variantStr == null || !variantStr.matches("\\d+")) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid variant ID");
                return;
            }
            long variantId = Long.parseLong(variantStr);

            // --- LOGIC LẤY DỮ LIỆU GỐC CỦA BẠN (GIỮ NGUYÊN) ---
            ProductVariant variant = stockDAO.getProductVariantById(variantId);
            if (variant == null) {
                throw new ServletException("Product variant not found with ID: " + variantId);
            }
            Product product = stockDAO.getProductById(variant.getProductId());
            Inventory inventory = stockDAO.getInventoryByVariantId(variantId);
            if (inventory == null) {
                inventory = new Inventory();
                inventory.setQuantity(0);
            }
            List<Map<String, Object>> movementHistory = stockDAO.getMovementHistoryByVariantId(variantId);
            // --- KẾT THÚC LOGIC LẤY DỮ LIỆU GỐC ---

            // --- LOGIC MỚI ĐỂ QUYẾT ĐỊNH TRẢ VỀ JSON HAY JSP ---
            if ("true".equals(ajaxRequest)) {
                // Nếu là yêu cầu AJAX, đóng gói và trả về JSON
                Map<String, Object> dataMap = new HashMap<>();
                dataMap.put("product", product);
                dataMap.put("variant", variant);
                dataMap.put("inventory", inventory);
                dataMap.put("movementHistory", movementHistory);
                // Bạn có thể thêm category, brand nếu cần

                String jsonData = this.gson.toJson(dataMap);

                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                PrintWriter out = response.getWriter();
                out.print(jsonData);
                out.flush();

            } else {
                // Nếu là yêu cầu thông thường, trả về trang JSP như cũ
                request.setAttribute("variant", variant);
                request.setAttribute("product", product);
                request.setAttribute("inventory", inventory);
                request.setAttribute("movementHistory", movementHistory);
                // Set thêm category, brand nếu cần
                // request.setAttribute("category", category);
                // request.setAttribute("brand", brand);

                request.getRequestDispatcher("/WEB-INF/views/staff/stock/stock-details.jsp").forward(request, response);
            }

        } catch (NumberFormatException | SQLException e) {
            Logger.getLogger(StockDetailController.class.getName()).log(Level.SEVERE, "Error loading product details", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading product details.");
        }
    }
}
