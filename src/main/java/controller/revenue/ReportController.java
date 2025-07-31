package controller.revenue;

import com.google.gson.Gson;
import dao.ReportDAO;
import DTO.CombinedReportDTO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import model.Users;

@WebServlet(name = "ReportController", urlPatterns = {"/Reports"})
public class ReportController extends HttpServlet {

    private ReportDAO reportDAO;
    private Gson gson;

    @Override
    public void init() {
        reportDAO = new ReportDAO();
        gson = new Gson();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        Users currentUser = (session != null) ? (Users) session.getAttribute("admin") : null;
        if (currentUser == null) currentUser = (session != null) ? (Users) session.getAttribute("staff") : null;
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/AdminLogin");
            return;
        }

        try {
            String reportType = request.getParameter("type");
            String startDate = request.getParameter("startDate");
            String endDate = request.getParameter("endDate");
            String isAjaxRequest = request.getParameter("ajax");
            String productSortBy = request.getParameter("productSortBy");
            String productSortOrder = request.getParameter("productSortOrder");
            String orderSortBy = request.getParameter("orderSortBy");
            String orderSortOrder = request.getParameter("orderSortOrder");

            if (reportType == null || reportType.isEmpty()) reportType = "revenue";
            if (startDate == null || startDate.isEmpty()) {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                Calendar cal = Calendar.getInstance();
                cal.set(Calendar.DAY_OF_WEEK, cal.getFirstDayOfWeek());
                startDate = sdf.format(cal.getTime());
                endDate = sdf.format(new Date());
            }
            if (productSortBy == null || productSortBy.isEmpty()) productSortBy = "revenue";
            if (productSortOrder == null || productSortOrder.isEmpty()) productSortOrder = "DESC";
            if (orderSortBy == null || orderSortBy.isEmpty()) orderSortBy = "date";
            if (orderSortOrder == null || orderSortOrder.isEmpty()) orderSortOrder = "DESC";

            CombinedReportDTO combinedReport = reportDAO.getCombinedReportData(startDate, endDate, reportType, productSortBy, productSortOrder, orderSortBy, orderSortOrder);

            if ("true".equals(isAjaxRequest)) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write(gson.toJson(combinedReport));
            } else {
                request.setAttribute("report", combinedReport);
                request.setAttribute("currentType", reportType);
                request.setAttribute("startDate", startDate);
                request.setAttribute("endDate", endDate);
                request.setAttribute("productSortBy", productSortBy);
                request.setAttribute("productSortOrder", productSortOrder);
                request.setAttribute("orderSortBy", orderSortBy);
                request.setAttribute("orderSortOrder", orderSortOrder);
                request.setAttribute("pageTitle", "Overall Dashboard Report");
                request.getRequestDispatcher("/WEB-INF/views/staff/revenue/product-report.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            throw new ServletException("Database error in ReportController", e);
        }
    }
}