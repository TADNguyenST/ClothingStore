package controller.stock;

import dao.StockMovementDAO; // Đảm bảo đúng tên DAO
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(name = "StockMovementController", urlPatterns = {"/StockMovement"})
public class StockMovementController extends HttpServlet {
    private StockMovementDAO stockMovementDAO; 

    @Override
    public void init() throws ServletException {
        stockMovementDAO = new StockMovementDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // === STEP 1: LẤY TẤT CẢ CÁC THAM SỐ TỪ REQUEST ===
            String startDate = request.getParameter("startDate");
            String endDate = request.getParameter("endDate");
            String filterType = request.getParameter("filterType"); // <<< THÊM DÒNG NÀY
            String pageStr = request.getParameter("page");
            
            int page = (pageStr == null || pageStr.isEmpty()) ? 1 : Integer.parseInt(pageStr);
            int limit = 10; // Số bản ghi trên mỗi trang
            int offset = (page - 1) * limit;

            // === STEP 2: GỌI CÁC PHƯƠNG THỨC DAO ĐÃ CẬP NHẬT ===
            
            // Gọi phương thức DAO có khả năng lọc với đầy đủ các tham số
            List<Map<String, Object>> movementList = stockMovementDAO.getFilteredAndPaginatedStockMovements(startDate, endDate, filterType, offset, limit);

            // Gọi phương thức DAO để đếm tổng số bản ghi đã lọc
            int totalRecords = stockMovementDAO.getTotalFilteredStockMovements(startDate, endDate, filterType);
            
            int totalPages = (int) Math.ceil((double) totalRecords / limit);

            // === STEP 3: GỬI DỮ LIỆU VÀ CÁC THAM SỐ LỌC RA LẠI JSP ===
            request.setAttribute("movementList", movementList);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("currentPage", page);
            
            // Gửi lại các tham số lọc để giữ trạng thái trên JSP
            request.setAttribute("startDate", startDate);
            request.setAttribute("endDate", endDate);
            request.setAttribute("filterType", filterType); // <<< THÊM DÒNG NÀY

            // Forward đến trang JSP
            request.getRequestDispatcher("/WEB-INF/views/staff/stock/stock-movements.jsp").forward(request, response);

        } catch (NumberFormatException | SQLException e) {
            Logger.getLogger(StockMovementController.class.getName()).log(Level.SEVERE, "Error loading stock history", e);
            request.setAttribute("errorMessage", "Error loading stock history: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(request, response);
        }
    }
}