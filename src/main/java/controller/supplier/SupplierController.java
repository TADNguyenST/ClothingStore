package controller.supplier;

import com.google.gson.*;
import dao.SupplierDAO;
import model.Supplier;
import model.Users;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.lang.reflect.Type;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;

@WebServlet(name = "SupplierController", urlPatterns = {"/Supplier"})
public class SupplierController extends HttpServlet {

    private SupplierDAO supplierDAO;
    private Gson gson;

    private static final Pattern VIETNAMESE_PHONE_PATTERN = Pattern.compile("^0\\d{9}$");
    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,6}$");

    @Override
    public void init() {
        supplierDAO = new SupplierDAO();
        gson = new GsonBuilder()
                .registerTypeAdapter(LocalDate.class, new LocalDateAdapter())
                .setPrettyPrinting()
                .create();
    }

    private boolean isAdmin(Users user) {
        return user != null && "Admin".equals(user.getRole());
    }

    private void sendJsonResponse(HttpServletResponse response, Object object) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.print(gson.toJson(object));
            out.flush();
        }
    }

    private void sendErrorResponse(HttpServletResponse response, int statusCode, String message) throws IOException {
        response.setStatus(statusCode);
        Map<String, String> error = new HashMap<>();
        error.put("status", "error");
        error.put("message", message);
        sendJsonResponse(response, error);
    }

    private void sendSuccessResponse(HttpServletResponse response, String message, Object data) throws IOException {
        Map<String, Object> success = new HashMap<>();
        success.put("status", "success");
        success.put("message", message);
        if (data != null) {
            success.put("data", data);
        }
        sendJsonResponse(response, success);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        Users currentUser = (session != null)
                ? ((Users) session.getAttribute("admin") != null
                ? (Users) session.getAttribute("admin")
                : (Users) session.getAttribute("staff"))
                : null;

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/AdminLogin");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            request.getRequestDispatcher("/WEB-INF/views/staff/supplier/supplier-list.jsp").forward(request, response);
            return;
        }

        try {
            switch (action) {
                case "list":
                    listSuppliers(response);
                    break;
                case "detail":
                    getSupplierDetails(request, response);
                    break;
                default:
                    request.getRequestDispatcher("/WEB-INF/views/staff/supplier/supplier-list.jsp").forward(request, response);
                    break;
            }
        } catch (SQLException e) {
            sendErrorResponse(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error occurred.");
            e.printStackTrace();
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    private void listSuppliers(HttpServletResponse response) throws SQLException, IOException {
        List<Supplier> supplierList = supplierDAO.getAllSuppliers();
        sendJsonResponse(response, supplierList);
    }

    private void getSupplierDetails(HttpServletRequest request, HttpServletResponse response) throws SQLException, IOException {
        try {
            long id = Long.parseLong(request.getParameter("id"));
            Supplier supplier = supplierDAO.getSupplierById(id);

            if (supplier == null) {
                sendErrorResponse(response, HttpServletResponse.SC_NOT_FOUND, "Supplier not found.");
                return;
            }

            DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy-MM-dd");
            LocalDate today = LocalDate.now();
            String startDateStr = request.getParameter("startDate");
            String endDateStr = request.getParameter("endDate");

            String startDate = (startDateStr != null && !startDateStr.isEmpty()) ? startDateStr : today.withDayOfMonth(1).format(dtf);
            String endDate = (endDateStr != null && !endDateStr.isEmpty()) ? endDateStr : today.format(dtf);

            Map<String, Object> stats = supplierDAO.getSupplierDashboardStats(id, startDate, endDate);
            List<Map<String, Object>> poList = supplierDAO.getPurchaseOrdersBySupplierId(id);
            List<Map<String, Object>> suppliedProducts = supplierDAO.getProductsSuppliedBySupplier(id, startDate, endDate);

            Map<String, Object> responseData = new HashMap<>();
            responseData.put("supplier", supplier);
            responseData.put("stats", stats);
            responseData.put("poList", poList);
            responseData.put("suppliedProducts", suppliedProducts);
            responseData.put("startDate", startDate);
            responseData.put("endDate", endDate);

            sendJsonResponse(response, responseData);

        } catch (NumberFormatException e) {
            sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "Invalid supplier ID format.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        Users currentUser = (session != null) ? (Users) session.getAttribute("admin") : null;

        if (!isAdmin(currentUser)) {
            sendErrorResponse(response, HttpServletResponse.SC_FORBIDDEN, "Access Denied. You do not have permission to perform this action.");
            return;
        }

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        if (action == null) {
            sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "Action parameter is missing.");
            return;
        }

        try {
            switch (action) {
                case "save":
                    saveSupplier(request, response);
                    break;
                case "deactivate":
                    setSupplierStatus(request, response, false);
                    break;
                case "reactivate":
                    setSupplierStatus(request, response, true);
                    break;
                default:
                    sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "Invalid action specified.");
            }
        } catch (SQLException e) {
            sendErrorResponse(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error occurred during the POST request.");
            e.printStackTrace();
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    private void saveSupplier(HttpServletRequest request, HttpServletResponse response) throws SQLException, IOException {
        String idStr = request.getParameter("id");
        String name = request.getParameter("name") != null ? request.getParameter("name").trim() : "";
        String email = request.getParameter("email") != null ? request.getParameter("email").trim() : "";
        String phone = request.getParameter("phone") != null ? request.getParameter("phone").trim() : "";
        String address = request.getParameter("address") != null ? request.getParameter("address").trim() : "";
        boolean isActive = "true".equals(request.getParameter("isActive"));

        long currentId = (idStr != null && !idStr.isEmpty() && !"null".equals(idStr)) ? Long.parseLong(idStr) : 0L;

        List<String> errors = new ArrayList<>();
        if (name.isEmpty()) {
            errors.add("Supplier name is required.");
        }
        if (!EMAIL_PATTERN.matcher(email).matches()) {
            errors.add("A valid email address is required.");
        }
        if (!VIETNAMESE_PHONE_PATTERN.matcher(phone).matches()) {
            errors.add("A valid 10-digit phone number starting with 0 is required.");
        }
        if (address.isEmpty()) {
            errors.add("Address is required.");
        }

        // ✅ KIỂM TRA SĐT TRÙNG LẶP
        if (errors.isEmpty()) {
            if (supplierDAO.isPhoneNumberExists(phone, currentId)) {
                errors.add("Phone number already exists for another supplier.");
            }
        }

        if (!errors.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("status", "error");
            errorResponse.put("errors", errors);
            sendJsonResponse(response, errorResponse);
            return;
        }

        Supplier supplierToSave = new Supplier();
        supplierToSave.setName(name);
        supplierToSave.setContactEmail(email);
        supplierToSave.setPhoneNumber(phone);
        supplierToSave.setAddress(address);
        supplierToSave.setIsActive(isActive);

        boolean isNew = (currentId == 0L);

        if (isNew) {
            supplierDAO.addSupplier(supplierToSave);
        } else {
            supplierToSave.setSupplierId(currentId);
            supplierDAO.updateSupplier(supplierToSave);
        }

        String message = isNew ? "Supplier added successfully!" : "Supplier updated successfully!";
        sendSuccessResponse(response, message, supplierToSave);
    }

    private void setSupplierStatus(HttpServletRequest request, HttpServletResponse response, boolean isActive) throws SQLException, IOException {
        try {
            long id = Long.parseLong(request.getParameter("id"));
            supplierDAO.setSupplierStatus(id, isActive);
            String message = isActive ? "Supplier has been reactivated." : "Supplier has been deactivated.";
            sendSuccessResponse(response, message, null);
        } catch (NumberFormatException e) {
            sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, "Invalid ID format.");
        }
    }

    private static class LocalDateAdapter implements JsonSerializer<LocalDate>, JsonDeserializer<LocalDate> {
        private static final DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");

        @Override
        public JsonElement serialize(LocalDate date, Type typeOfSrc, JsonSerializationContext context) {
            return new JsonPrimitive(formatter.format(date));
        }

        @Override
        public LocalDate deserialize(JsonElement json, Type typeOfT, JsonDeserializationContext context) throws JsonParseException {
            return LocalDate.parse(json.getAsString(), formatter);
        }
    }
}