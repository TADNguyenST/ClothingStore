package controller.stock;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import dao.StockMovementDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.Users;

@WebServlet(name = "StockMovementController", urlPatterns = {"/StockMovement"})
public class StockMovementController extends HttpServlet {

    private StockMovementDAO dao;
    private Gson gson;

    // yyyy-MM-dd để khớp input type="date"
    private static final DateTimeFormatter ISO = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    @Override
    public void init() throws ServletException {
        dao = new StockMovementDAO();
        gson = new GsonBuilder().create();
    }

    private int safeInt(String s, int def) {
        try { return Integer.parseInt(s); } catch (Exception e) { return def; }
    }

    private void respondJson(HttpServletResponse resp, Map<String, Object> body) throws IOException {
        resp.setStatus(HttpServletResponse.SC_OK);
        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json");
        try (PrintWriter out = resp.getWriter()) {
            out.write(gson.toJson(body));
        }
    }

    /* -------------------- DATE HELPERS -------------------- */

    private static boolean isBlankCompat(String s) {
        return s == null || s.trim().isEmpty(); // thay cho String.isBlank() (Java 8 compatible)
    }

    /** Quick range -> [start, end] (yyyy-MM-dd)
     *  Hỗ trợ: "7", "30", "365", "ytd", "year"/"thisyear".
     *  Nếu là số n bất kỳ -> hiểu là n ngày gần đây.
     */
    private String[] resolveQuickRange(String quick) {
        if (isBlankCompat(quick)) return null;

        String q = quick.trim().toLowerCase();
        LocalDate today = LocalDate.now();
        LocalDate start;
        LocalDate end = today;

        switch (q) {
            case "7":
            case "7d":
                start = today.minusDays(6);
                break;
            case "30":
            case "30d":
                start = today.minusDays(29);
                break;
            case "365":
            case "365d":
                start = today.minusDays(364);
                break;
            case "ytd":
            case "year":
            case "thisyear":
                start = LocalDate.of(today.getYear(), 1, 1);
                break;
            default:
                // nếu là số -> N ngày gần đây
                try {
                    int n = Integer.parseInt(q);
                    if (n <= 1) start = today;
                    else start = today.minusDays(n - 1L);
                } catch (NumberFormatException ex) {
                    return null; // không hiểu quick
                }
        }
        return new String[]{ start.format(ISO), end.format(ISO) };
    }

    /** Mặc định 30 ngày: nếu không có quick
     *  - Thiếu cả hai: end = hôm nay, start = end-29
     *  - Thiếu một đầu: suy ra đầu còn lại sao cho đủ 30 ngày (không vượt quá hôm nay)
     *  - start > end: hoán đổi
     */
    private String[] resolveDateRange30(String startDate, String endDate) {
        LocalDate today = LocalDate.now();
        LocalDate start = null, end = null;

        try { if (!isBlankCompat(startDate)) start = LocalDate.parse(startDate.trim(), ISO); } catch (Exception ignore) {}
        try { if (!isBlankCompat(endDate))   end   = LocalDate.parse(endDate.trim(), ISO);   } catch (Exception ignore) {}

        if (start == null && end == null) {
            end = today;
            start = end.minusDays(29);
        } else if (start == null) {
            start = end.minusDays(29);
        } else if (end == null) {
            end = start.plusDays(29);
            if (end.isAfter(today)) end = today;
        }

        if (start.isAfter(end)) { LocalDate t = start; start = end; end = t; }
        return new String[]{ start.format(ISO), end.format(ISO) };
    }

    /** Ưu tiên QUICK nếu có; nếu không, dùng dải 30 ngày */
    private String[] resolveDateRange(String startDate, String endDate, String quick) {
        String[] byQuick = resolveQuickRange(quick);
        if (byQuick != null) return byQuick;
        return resolveDateRange30(startDate, endDate);
    }

    /* -------------------- /DATE HELPERS -------------------- */

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ---- Auth (admin/staff) ----
        HttpSession session = request.getSession();
        Users currentUser = (Users) session.getAttribute("admin");
        if (currentUser == null) currentUser = (Users) session.getAttribute("staff");
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/AdminLogin");
            return;
        }

        try {
            // ---- Params ----
            String startDate  = request.getParameter("startDate");
            String endDate    = request.getParameter("endDate");
            String searchTerm = request.getParameter("searchTerm");
            String groupBy    = request.getParameter("groupBy");      // purchase_order | sale_order | adjustment | none
            String viewMode   = request.getParameter("viewMode");      // list | grouped | product
            String isAjax     = request.getParameter("ajax");

            // QUICK: chấp nhận "quick" hoặc "range"
            String quick      = request.getParameter("quick");
            if (isBlankCompat(quick)) quick = request.getParameter("range");

            int page          = safeInt(request.getParameter("page"), 1);
            int limit         = 15;
            int offset        = (page - 1) * limit;

            // ---- Dải ngày (ưu tiên QUICK) ----
            String[] range = resolveDateRange(startDate, endDate, quick);
            startDate = range[0];
            endDate   = range[1];

            if (isBlankCompat(viewMode)) viewMode = "grouped";
            if ("grouped".equals(viewMode) && (isBlankCompat(groupBy) || "none".equals(groupBy))) {
                groupBy = "purchase_order";
            }

            switch (viewMode) {
                case "product": {
                    Map<String, Object> sum = dao.getProductMovementSummary(startDate, endDate, searchTerm);
                    @SuppressWarnings("unchecked")
                    List<Map<String, Object>> fullRows = (List<Map<String, Object>>) sum.get("rows");
                    if (fullRows == null) fullRows = Collections.emptyList();

                    int totalRecords = fullRows.size();
                    int totalPages   = (int) Math.ceil(totalRecords / (double) limit);
                    if (page > totalPages && totalPages > 0) {
                        page = totalPages;
                        offset = (page - 1) * limit;
                    }
                    int to = Math.min(offset + limit, totalRecords);
                    List<Map<String, Object>> pageData =
                        (totalRecords == 0) ? Collections.emptyList() : fullRows.subList(offset, to);

                    if ("true".equalsIgnoreCase(isAjax)) {
                        Map<String, Object> json = new HashMap<>();
                        json.put("viewMode", "product");
                        json.put("data", pageData);
                        Map<String, Object> totals = new HashMap<>();
                        totals.put("totalIn", sum.get("totalIn"));
                        totals.put("totalOut", sum.get("totalOut"));
                        totals.put("net", sum.get("net"));
                        json.put("totals", totals);
                        json.put("totalRecords", totalRecords);
                        json.put("totalPages", totalPages);
                        json.put("currentPage", page);
                        json.put("limit", limit);
                        json.put("startDate", startDate);
                        json.put("endDate", endDate);
                        if (!isBlankCompat(quick)) json.put("quick", quick);
                        respondJson(response, json);
                        return;
                    }

                    request.setAttribute("viewMode", "product");
                    request.setAttribute("productSummary", pageData);
                    request.setAttribute("totalRecords", totalRecords);
                    request.setAttribute("totalPages", totalPages);
                    request.setAttribute("currentPage", page);
                    request.setAttribute("startDate", startDate);
                    request.setAttribute("endDate", endDate);
                    request.setAttribute("searchTerm", searchTerm);
                    request.setAttribute("quick", quick);
                    request.getRequestDispatcher("/WEB-INF/views/staff/stock/stock-movements.jsp").forward(request, response);
                    return;
                }

                case "grouped": {
                    Map<String, List<Map<String, Object>>> grouped =
                            dao.getGroupedMovements(startDate, endDate, null, searchTerm, groupBy);

                    int totalRecords = (grouped == null) ? 0 : grouped.values().stream().mapToInt(List::size).sum();

                    if ("true".equalsIgnoreCase(isAjax)) {
                        Map<String, Object> json = new HashMap<>();
                        json.put("viewMode", "grouped");
                        json.put("data", grouped);
                        json.put("totalRecords", totalRecords);
                        json.put("totalPages", 1);
                        json.put("currentPage", 1);
                        json.put("startDate", startDate);
                        json.put("endDate", endDate);
                        if (!isBlankCompat(quick)) json.put("quick", quick);
                        respondJson(response, json);
                        return;
                    }

                    request.setAttribute("viewMode", "grouped");
                    request.setAttribute("groupedData", grouped);
                    request.setAttribute("totalRecords", totalRecords);
                    request.setAttribute("totalPages", 1);
                    request.setAttribute("currentPage", 1);
                    request.setAttribute("startDate", startDate);
                    request.setAttribute("endDate", endDate);
                    request.setAttribute("searchTerm", searchTerm);
                    request.setAttribute("groupBy", groupBy);
                    request.setAttribute("quick", quick);
                    request.getRequestDispatcher("/WEB-INF/views/staff/stock/stock-movements.jsp").forward(request, response);
                    return;
                }

                case "list":
                default: {
                    List<Map<String, Object>> rows =
                            dao.getFilteredAndPaginatedStockMovements(startDate, endDate, null, searchTerm, offset, limit);
                    int totalRecords = dao.getTotalFilteredStockMovements(startDate, endDate, null, searchTerm);
                    int totalPages   = (int) Math.ceil(totalRecords / (double) limit);

                    if ("true".equalsIgnoreCase(isAjax)) {
                        Map<String, Object> json = new HashMap<>();
                        json.put("viewMode", "list");
                        json.put("data", rows);
                        json.put("totalRecords", totalRecords);
                        json.put("totalPages", totalPages);
                        json.put("currentPage", page);
                        json.put("startDate", startDate);
                        json.put("endDate", endDate);
                        if (!isBlankCompat(quick)) json.put("quick", quick);
                        respondJson(response, json);
                        return;
                    }

                    request.setAttribute("viewMode", "list");
                    request.setAttribute("movementList", rows);
                    request.setAttribute("totalRecords", totalRecords);
                    request.setAttribute("totalPages", totalPages);
                    request.setAttribute("currentPage", page);
                    request.setAttribute("startDate", startDate);
                    request.setAttribute("endDate", endDate);
                    request.setAttribute("searchTerm", searchTerm);
                    request.setAttribute("quick", quick);
                    request.getRequestDispatcher("/WEB-INF/views/staff/stock/stock-movements.jsp").forward(request, response);
                }
            }

        } catch (Exception ex) {
            Logger.getLogger(StockMovementController.class.getName())
                  .log(Level.SEVERE, "Error in StockMovementController", ex);

            if ("true".equalsIgnoreCase(request.getParameter("ajax"))) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.setCharacterEncoding("UTF-8");
                response.setContentType("application/json");
                try (PrintWriter out = response.getWriter()) {
                    Map<String, Object> err = new HashMap<>();
                    err.put("error", "Internal server error");
                    out.write(gson.toJson(err));
                }
            } else {
                response.sendError(500);
            }
        }
    }
}
