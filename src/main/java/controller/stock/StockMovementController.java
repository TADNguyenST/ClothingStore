package controller.stock;

import dao.InventoryDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;
import java.util.Map; // Thêm import này


public class StockMovementController extends HttpServlet {
    private InventoryDAO inventoryDAO;

    @Override
    public void init() throws ServletException {
        inventoryDAO = new InventoryDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String pageStr = request.getParameter("page");
            int page = (pageStr == null) ? 1 : Integer.parseInt(pageStr);
            int limit = 10;
            int offset = (page - 1) * limit;

            // Gọi phương thức DAO mới, kiểu trả về là List<Map<String, Object>>
            List<Map<String, Object>> movementList = inventoryDAO.getPaginatedStockMovements(offset, limit);

            int totalRecords = inventoryDAO.getTotalStockMovements();
            int totalPages = (int) Math.ceil((double) totalRecords / limit);

            request.setAttribute("movementList", movementList);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("currentPage", page);

            request.getRequestDispatcher("/WEB-INF/views/staff/stock/stock-movements.jsp").forward(request, response);

        } catch (Exception e) {
            throw new ServletException("Lỗi tải lịch sử kho", e);
        }
    }
}