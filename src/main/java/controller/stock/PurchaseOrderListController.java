package controller.stock;

import dao.PurchaseOrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession; // Thêm import
import model.Users; // Thêm import

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(name = "PurchaseOrderListController", urlPatterns = {"/PurchaseOrderList"})
public class PurchaseOrderListController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(PurchaseOrderListController.class.getName());
    private PurchaseOrderDAO purchaseDAO;

    @Override
    public void init() {
        purchaseDAO = new PurchaseOrderDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // --- KIỂM TRA SESSION ---
        HttpSession session = request.getSession();
        Users currentUser = (Users) session.getAttribute("admin");
        if (currentUser == null) {
            currentUser = (Users) session.getAttribute("staff");
        }

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/AdminLogin");
            return;
        }
        // --- KẾT THÚC KIỂM TRA ---

        try {
            String searchTerm = request.getParameter("searchTerm");
            String startDate = request.getParameter("startDate");
            String endDate = request.getParameter("endDate");
            String pageStr = request.getParameter("page");
            String status = request.getParameter("status");

            int page = (pageStr == null || pageStr.isEmpty()) ? 1 : Integer.parseInt(pageStr);
            int limit = 10;
            int offset = (page - 1) * limit;

            List<Map<String, Object>> poList = purchaseDAO.getFilteredAndPaginatedPurchaseOrders(searchTerm, startDate, endDate, status, offset, limit);
            int totalRecords = purchaseDAO.getTotalFilteredPurchaseOrders(searchTerm, startDate, endDate, status);
            int totalPages = (int) Math.ceil((double) totalRecords / limit);

            request.setAttribute("poList", poList);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("currentPage", page);
            request.setAttribute("searchTerm", searchTerm);
            request.setAttribute("startDate", startDate);
            request.setAttribute("endDate", endDate);
            request.setAttribute("status", status);
            
            request.setAttribute("currentModule", "stock");
            request.setAttribute("currentAction", "purchaseorder"); // Cập nhật lại action cho sidebar
            request.getRequestDispatcher("/WEB-INF/views/staff/stock/po-list.jsp").forward(request, response);

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting purchase order list", e);
            throw new ServletException("Database error while fetching PO list.", e);
        }
    }
}