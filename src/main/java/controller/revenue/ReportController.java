package controller.revenue;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import dao.ReportDAO;
import DTO.CombinedReportDTO;
import DTO.CustomerOrderDTO;
import DTO.CustomerOrderItemDTO;
import DTO.CustomerSummaryDTO;
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
import java.util.List;
import model.Users;

@WebServlet(name = "ReportController", urlPatterns = {"/Reports"})
public class ReportController extends HttpServlet {

    private ReportDAO reportDAO;
    private Gson gson;

    @Override
    public void init() {
        reportDAO = new ReportDAO();
        // ISO-8601 để client parse chắc chắn
        gson = new GsonBuilder()
                .setDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSX")
                .create();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ==== Auth ====
        HttpSession session = request.getSession(false);
        Users currentUser = (session != null) ? (Users) session.getAttribute("admin") : null;
        if (currentUser == null) {
            currentUser = (session != null) ? (Users) session.getAttribute("staff") : null;
        }
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/AdminLogin");
            return;
        }

        try {
            // ===== Params =====
            String reportType = trimOrNull(request.getParameter("type"));          // revenue | bestselling
            String startDate = trimOrNull(request.getParameter("startDate"));
            String endDate = trimOrNull(request.getParameter("endDate"));
            String isAjaxRequest = request.getParameter("ajax");

            String productSortBy = trimOrNull(request.getParameter("productSortBy")); // quantity | revenue
            String productSortOrder = trimOrNull(request.getParameter("productSortOrder")); // ASC | DESC

            String orderSortBy = trimOrNull(request.getParameter("orderSortBy"));   // date | total
            String orderSortOrder = trimOrNull(request.getParameter("orderSortOrder")); // ASC | DESC

            // API phụ cho Customer/Items
            String customerIdStr = trimOrNull(request.getParameter("customerId"));
            String orderIdStr = trimOrNull(request.getParameter("orderId"));

            if (reportType == null || reportType.isEmpty()) {
                reportType = "revenue";
            }

            // Default date range: đầu tuần → hôm nay
            if (startDate == null || startDate.isEmpty() || endDate == null || endDate.isEmpty()) {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

                Calendar endCal = Calendar.getInstance();
                endCal.set(Calendar.HOUR_OF_DAY, 0);
                endCal.set(Calendar.MINUTE, 0);
                endCal.set(Calendar.SECOND, 0);
                endCal.set(Calendar.MILLISECOND, 0);

                Calendar startCal = (Calendar) endCal.clone();
                startCal.add(Calendar.DAY_OF_YEAR, -29);

                startDate = sdf.format(startCal.getTime());
                endDate = sdf.format(endCal.getTime());
            }

            // Product sort guard
            if (productSortBy == null || productSortBy.isEmpty()) {
                productSortBy = "revenue";
            } else {
                productSortBy = productSortBy.equalsIgnoreCase("quantity") ? "quantity" : "revenue";
            }
            if (!"ASC".equalsIgnoreCase(productSortOrder) && !"DESC".equalsIgnoreCase(productSortOrder)) {
                productSortOrder = "DESC";
            } else {
                productSortOrder = productSortOrder.toUpperCase();
            }

            // Orders sort guard → DAO hiểu 'date' hoặc 'total'
            if (orderSortBy == null || orderSortBy.isEmpty()) {
                orderSortBy = "date";
            } else {
                if ("totalPrice".equalsIgnoreCase(orderSortBy)) {
                    orderSortBy = "total";
                } else if (!"total".equalsIgnoreCase(orderSortBy)) {
                    orderSortBy = "date";
                }
            }
            if (!"ASC".equalsIgnoreCase(orderSortOrder) && !"DESC".equalsIgnoreCase(orderSortOrder)) {
                orderSortOrder = "DESC";
            } else {
                orderSortOrder = orderSortOrder.toUpperCase();
            }

            // ===== API phụ: Orders theo Customer =====
            if ("true".equals(isAjaxRequest) && customerIdStr != null) {
                long cid = Long.parseLong(customerIdStr);
                List<CustomerOrderDTO> list = reportDAO.getOrdersByCustomer(startDate, endDate, cid);
                writeJson(response, list);
                return;
            }

            // ===== API phụ: Items theo Order =====
            if ("true".equals(isAjaxRequest) && orderIdStr != null) {
                long oid = Long.parseLong(orderIdStr);
                List<CustomerOrderItemDTO> items = reportDAO.getOrderItems(oid);
                writeJson(response, items);
                return;
            }

            // ===== AJAX chính (tab động): trả đúng 'type' hiện tại + customerSummary =====
            if ("true".equals(isAjaxRequest)) {
                CombinedReportDTO single = reportDAO.getCombinedReportData(
                        startDate, endDate, reportType,
                        productSortBy, productSortOrder,
                        orderSortBy, orderSortOrder
                );
                // bổ sung customerSummary
                single.setCustomerSummary(reportDAO.getCustomerSummary(startDate, endDate));

                writeJson(response, single);
                return;
            }

            // ===== PAGE LOAD: PRELOAD CẢ 2 BỘ PRODUCT =====
            CombinedReportDTO revenueBlock = reportDAO.getCombinedReportData(
                    startDate, endDate, "revenue",
                    "revenue", "DESC",
                    orderSortBy, orderSortOrder
            );
            CombinedReportDTO bestBlock = reportDAO.getCombinedReportData(
                    startDate, endDate, "bestselling",
                    "quantity", "DESC",
                    orderSortBy, orderSortOrder
            );
            // customerSummary dùng cùng range (lấy 1 lần)
            List<CustomerSummaryDTO> customerSummary = reportDAO.getCustomerSummary(startDate, endDate);

            // Gói preload
            PreloadedPayload preload = new PreloadedPayload();
            preload.currentType = reportType;
            preload.startDate = startDate;
            preload.endDate = endDate;

            // System + orders dùng từ revenueBlock (cùng range)
            preload.systemKpis = revenueBlock.getSystemKpis();
            preload.systemRevenueChartData = revenueBlock.getSystemRevenueChartData();
            preload.ordersReportData = revenueBlock.getOrdersReportData();

            // NEW: customer summary
            preload.customerSummary = customerSummary;

            // Hai block product riêng
            preload.product = new PreloadedPayload.ProductDual();
            preload.product.revenue = new PreloadedPayload.ProductOnly(
                    revenueBlock.getProductKpis(), revenueBlock.getProductReportData());
            preload.product.bestselling = new PreloadedPayload.ProductOnly(
                    bestBlock.getProductKpis(), bestBlock.getProductReportData());

            // Render
            request.setAttribute("report", preload);
            request.setAttribute("currentType", reportType);
            request.setAttribute("startDate", startDate);
            request.setAttribute("endDate", endDate);
            request.setAttribute("productSortBy", productSortBy);
            request.setAttribute("productSortOrder", productSortOrder);
            request.setAttribute("orderSortBy", orderSortBy);
            request.setAttribute("orderSortOrder", orderSortOrder);
            request.setAttribute("pageTitle", "Overall Dashboard Report");

            request.getRequestDispatcher("/WEB-INF/views/staff/revenue/combined-report.jsp")
                    .forward(request, response);

        } catch (SQLException e) {
            throw new ServletException("Database error in ReportController", e);
        }
    }

    private static String trimOrNull(String s) {
        return (s == null) ? null : s.trim();
    }

    private void writeJson(HttpServletResponse resp, Object obj) throws IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        resp.getWriter().write(gson.toJson(obj));
    }

    // ===== DTO preload để đẩy ra JSP =====
    public static class PreloadedPayload {

        public String currentType;
        public String startDate;
        public String endDate;

        public Object systemKpis;
        public Object systemRevenueChartData;
        public Object ordersReportData;

        // NEW: Customer summary
        public List<CustomerSummaryDTO> customerSummary;

        public ProductDual product;

        public static class ProductDual {

            public ProductOnly revenue;
            public ProductOnly bestselling;
        }

        public static class ProductOnly {

            public Object productKpis;
            public Object productReportData;

            public ProductOnly(Object kpis, Object data) {
                this.productKpis = kpis;
                this.productReportData = data;
            }
        }
    }
}
