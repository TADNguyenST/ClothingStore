package controller.stock;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import dao.StockMovementDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(name = "StockMovementController", urlPatterns = {"/StockMovement"})
public class StockMovementController extends HttpServlet {

    private StockMovementDAO stockMovementDAO;
    private Gson gson;

    @Override
    public void init() throws ServletException {
        stockMovementDAO = new StockMovementDAO();
        GsonBuilder gsonBuilder = new GsonBuilder();
        gson = gsonBuilder.create();
    }

    private void formatTimestampInGroupedMap(Map<String, List<Map<String, Object>>> groupedMap) {
        for (List<Map<String, Object>> list : groupedMap.values()) {
            formatTimestampInList(list);
        }
    }

    private void formatTimestampInList(List<Map<String, Object>> list) {
        SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss dd/MM/yyyy");
        for (Map<String, Object> map : list) {
            if (map.get("createdAt") instanceof Timestamp) {
                Timestamp ts = (Timestamp) map.get("createdAt");
                map.put("createdAtFormatted", sdf.format(ts));
                map.remove("createdAt"); // Xóa object timestamp gốc
            }
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Lấy tất cả các tham số
            String startDate = request.getParameter("startDate");
            String endDate = request.getParameter("endDate");
            String filterType = request.getParameter("filterType");
            String searchTerm = request.getParameter("searchTerm");
            String groupBy = request.getParameter("groupBy");
            if (groupBy == null || groupBy.isEmpty()) {
                groupBy = "all_references"; // Đặt giá trị mặc định
            }
            String isAjaxRequest = request.getParameter("ajax");
            String pageStr = request.getParameter("page");
            if ((startDate == null || startDate.isEmpty()) && (endDate == null || endDate.isEmpty())) {
                DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy-MM-dd");
                LocalDate today = LocalDate.now();
                startDate = today.format(dtf);
                endDate = today.format(dtf);
            }
            int page = (pageStr == null || pageStr.isEmpty()) ? 1 : Integer.parseInt(pageStr);
            int limit = 15;
            int offset = (page - 1) * limit;

            Object resultData;
            boolean isGroupedView = groupBy != null && !groupBy.equals("none");

            if (isGroupedView) {
                Map<String, List<Map<String, Object>>> groupedData = stockMovementDAO.getGroupedMovements(startDate, endDate, filterType, searchTerm, groupBy);
                formatTimestampInGroupedMap(groupedData); // Format thời gian
                resultData = groupedData;
            } else {
                List<Map<String, Object>> movementList = stockMovementDAO.getFilteredAndPaginatedStockMovements(startDate, endDate, filterType, searchTerm, offset, limit);
                formatTimestampInList(movementList); // Format thời gian
                resultData = movementList;
            }

            int totalRecords = stockMovementDAO.getTotalFilteredStockMovements(startDate, endDate, filterType, searchTerm);
            int totalPages = (int) Math.ceil((double) totalRecords / limit);

            if ("true".equals(isAjaxRequest)) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                Map<String, Object> jsonResponse = new HashMap<>();
                jsonResponse.put("data", resultData);
                jsonResponse.put("totalPages", totalPages);
                jsonResponse.put("currentPage", page);
                jsonResponse.put("totalRecords", totalRecords);
                jsonResponse.put("viewMode", isGroupedView ? "grouped" : "list");
                response.getWriter().write(gson.toJson(jsonResponse));
            } else {
                if (isGroupedView) {
                    request.setAttribute("groupedData", resultData);
                } else {
                    request.setAttribute("movementList", resultData);
                }
                request.setAttribute("totalPages", totalPages);
                request.setAttribute("currentPage", page);
                request.setAttribute("totalRecords", totalRecords);
                request.setAttribute("startDate", startDate);
                request.setAttribute("endDate", endDate);
                request.setAttribute("filterType", filterType);
                request.setAttribute("searchTerm", searchTerm);
                request.setAttribute("groupBy", groupBy);
                request.getRequestDispatcher("/WEB-INF/views/staff/stock/stock-movements.jsp").forward(request, response);
            }

        } catch (Exception e) {
            Logger.getLogger(StockMovementController.class.getName()).log(Level.SEVERE, "Error in StockMovementController", e);
            // Xử lý lỗi
        }
    }
}
