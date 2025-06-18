package controller.stock;

import dao.StockManagermentDAO; // Đảm bảo đúng tên DAO
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

// KHÔNG CẦN THAY ĐỔI - CODE ĐÃ RẤT TỐT VÀ KHÔNG BỊ ẢNH HƯỞNG BỞI MODEL
@WebServlet(name = "StockMovementController", urlPatterns = {"/StockMovement"})
public class StockMovementController extends HttpServlet {
    private StockManagermentDAO stockDAO; // Đảm bảo đúng tên DAO

    @Override
    public void init() throws ServletException {
        stockDAO = new StockManagermentDAO(); // Đảm bảo đúng tên DAO
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String pageStr = request.getParameter("page");
            int page = (pageStr == null || pageStr.isEmpty()) ? 1 : Integer.parseInt(pageStr);
            int limit = 10; // Number of records per page
            int offset = (page - 1) * limit;

            // Call the DAO method; the return type is List<Map<String, Object>>
            List<Map<String, Object>> movementList = stockDAO.getPaginatedStockMovements(offset, limit);

            int totalRecords = stockDAO.getTotalStockMovements();
            int totalPages = (int) Math.ceil((double) totalRecords / limit);

            request.setAttribute("movementList", movementList);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("currentPage", page);

            request.getRequestDispatcher("/WEB-INF/views/staff/stock/stock-movements.jsp").forward(request, response);

        } catch (NumberFormatException | SQLException e) {
            Logger.getLogger(StockMovementController.class.getName()).log(Level.SEVERE, "Error loading stock history", e);
            request.setAttribute("errorMessage", "Error loading stock history: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(request, response);
        }
    }
}