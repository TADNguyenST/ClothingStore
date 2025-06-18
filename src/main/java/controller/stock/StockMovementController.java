package controller.stock;

import dao.InventoryDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

@WebServlet("/StockMovements") // Assuming this is the correct URL pattern
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
            int page = (pageStr == null || pageStr.isEmpty()) ? 1 : Integer.parseInt(pageStr);
            int limit = 10; // Number of records per page
            int offset = (page - 1) * limit;

            // Call the DAO method; the return type is List<Map<String, Object>>
            List<Map<String, Object>> movementList = inventoryDAO.getPaginatedStockMovements(offset, limit);

            int totalRecords = inventoryDAO.getTotalStockMovements();
            int totalPages = (int) Math.ceil((double) totalRecords / limit);

            request.setAttribute("movementList", movementList);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("currentPage", page);

            request.getRequestDispatcher("/WEB-INF/views/staff/stock/stock-movements.jsp").forward(request, response);

        } catch (ServletException | IOException | NumberFormatException | SQLException e) {
            throw new ServletException("Error loading stock history", e);
        }
    }
}