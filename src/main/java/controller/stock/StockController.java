package controller.stock; // Đảm bảo package là 'controller.stock'

import model.Inventory; // Import Model cần thiết
import model.Category; // Import Category model
import dao.InventoryDAO;
// <-- IMPORT InventoryDAO TRỰC TIẾP

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

public class StockController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private InventoryDAO inventoryDAO; // <-- Khai báo InventoryDAO

    public void init() {
        // Khởi tạo DAO trong phương thức init()
        inventoryDAO = new InventoryDAO();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String searchTerm = request.getParameter("searchTerm");
        String sortBy = request.getParameter("sortBy");
        String sortOrder = request.getParameter("sortOrder"); // "asc" or "desc"
        String filterCategory = request.getParameter("filterCategory");

        // Logic nghiệp vụ đơn giản: lấy dữ liệu và chuyển tiếp
        try {
            List<Inventory> inventoryList = inventoryDAO.getAllProductVariantsWithStock(searchTerm, sortBy, sortOrder, filterCategory);
            // <-- GỌI DAO TRỰC TIẾP
            request.setAttribute("inventoryList", inventoryList);

            // Pass current search and sort parameters back to the JSP for display
            request.setAttribute("searchTerm", searchTerm);
            request.setAttribute("sortBy", sortBy);
            request.setAttribute("sortOrder", sortOrder);
            request.setAttribute("filterCategory", filterCategory);

            // Get all categories for the filter dropdown
            List<Category> categories = inventoryDAO.getAllCategories();
            request.setAttribute("categories", categories);


            request.getRequestDispatcher("/WEB-INF/views/staff/stock/stock-list.jsp").forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error retrieving stock data: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(request, response);
        }
    }
}