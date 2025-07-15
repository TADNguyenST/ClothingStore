package controller.supplier;

import dao.SupplierDAO;
import model.Supplier;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;

@WebServlet(name = "SupplierController", urlPatterns = {"/Supplier"})
public class SupplierController extends HttpServlet {
    private SupplierDAO supplierDAO;

    private static final Pattern VIETNAMESE_PHONE_PATTERN = Pattern.compile("^0\\d{9}$");
    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,6}$");

    @Override
    public void init() {
        supplierDAO = new SupplierDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        try {
            List<Supplier> supplierList = supplierDAO.getAllSuppliers();
            request.setAttribute("supplierList", supplierList);

            switch (action) {
                case "add":
                    request.setAttribute("viewMode", "form");
                    request.setAttribute("supplier", new Supplier());
                    break;
                case "edit":
                    request.setAttribute("viewMode", "form");
                    long idEdit = Long.parseLong(request.getParameter("id"));
                    Supplier existingSupplier = supplierDAO.getSupplierById(idEdit);
                    request.setAttribute("supplier", existingSupplier);
                    break;
                case "detail":
                    request.setAttribute("viewMode", "detail");
                    long idDetail = Long.parseLong(request.getParameter("id"));
                    Supplier supplier = supplierDAO.getSupplierById(idDetail);
                    List<Map<String, Object>> poList = supplierDAO.getPurchaseOrdersBySupplierId(idDetail);
                    request.setAttribute("supplier", supplier);
                    request.setAttribute("poList", poList);
                    break;
                default:
                    break;
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }

        request.getRequestDispatcher("/WEB-INF/views/staff/supplier/supplier-list.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
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
                    response.sendRedirect("Supplier?action=list");
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    private boolean isValidEmail(String email) {
        if (email == null || email.isEmpty()) {
            return false;
        }
        return EMAIL_PATTERN.matcher(email).matches();
    }

    private boolean isValidVietnamesePhone(String phone) {
        if (phone == null || phone.isEmpty()) {
            return false;
        }
        return VIETNAMESE_PHONE_PATTERN.matcher(phone).matches();
    }
    
    /**
     * SỬA LỖI TRIỆT ĐỂ: Tái cấu trúc lại hoàn toàn để chống NullPointerException.
     */
    private void saveSupplier(HttpServletRequest request, HttpServletResponse response) throws SQLException, IOException, ServletException {
        // Bước 1: Lấy tất cả tham số từ request và xử lý trim() ngay lập tức.
        // Nếu tham số là null, nó sẽ trở thành một chuỗi rỗng an toàn.
        String idStr = request.getParameter("id");
        String name = request.getParameter("name") != null ? request.getParameter("name").trim() : "";
        String email = request.getParameter("email") != null ? request.getParameter("email").trim() : "";
        String phone = request.getParameter("phone") != null ? request.getParameter("phone").trim() : "";
        String address = request.getParameter("address") != null ? request.getParameter("address").trim() : "";
        boolean isActive = "true".equals(request.getParameter("isActive"));

        // Bước 2: Kiểm tra dữ liệu hợp lệ trên các biến cục bộ an toàn.
        List<String> errors = new ArrayList<>();
        if (name.isEmpty()) {
            errors.add("Supplier name is required.");
        }
        if (!isValidEmail(email)) {
            errors.add("A valid email is required.");
        }
        if (!isValidVietnamesePhone(phone)) {
            errors.add("A valid 10-digit phone number starting with 0 is required.");
        }
        if (address.isEmpty()) {
            errors.add("Address is required.");
        }

        // Bước 3: Xử lý kết quả kiểm tra
        if (!errors.isEmpty()) {
            // Nếu có lỗi, tạo một đối tượng Supplier chỉ để gửi dữ liệu người dùng đã nhập trở lại form.
            Supplier supplierWithOldData = new Supplier();
            if (idStr != null && !idStr.isEmpty()) {
                supplierWithOldData.setSupplierId(Long.parseLong(idStr));
            }
            supplierWithOldData.setName(name);
            supplierWithOldData.setContactEmail(email);
            supplierWithOldData.setPhoneNumber(phone);
            supplierWithOldData.setAddress(address);
            supplierWithOldData.setIsActive(isActive);

            // Gửi lại form với thông tin đã nhập và danh sách lỗi
            request.setAttribute("errorMessages", errors);
            request.setAttribute("supplier", supplierWithOldData);
            request.setAttribute("viewMode", "form");
            List<Supplier> supplierList = supplierDAO.getAllSuppliers();
            request.setAttribute("supplierList", supplierList);
            request.getRequestDispatcher("/WEB-INF/views/staff/supplier/supplier-list.jsp").forward(request, response);
        } else {
            // Nếu không có lỗi, tạo đối tượng Supplier cuối cùng để lưu vào DB
            Supplier supplierToSave = new Supplier();
            supplierToSave.setName(name);
            supplierToSave.setContactEmail(email);
            supplierToSave.setPhoneNumber(phone);
            supplierToSave.setAddress(address);
            supplierToSave.setIsActive(isActive);

            if (idStr == null || idStr.isEmpty()) {
                supplierDAO.addSupplier(supplierToSave);
            } else {
                supplierToSave.setSupplierId(Long.parseLong(idStr));
                supplierDAO.updateSupplier(supplierToSave);
            }
            response.sendRedirect("Supplier?action=list&save=success");
        }
    }

    private void setSupplierStatus(HttpServletRequest request, HttpServletResponse response, boolean isActive) throws SQLException, IOException {
        try {
            long id = Long.parseLong(request.getParameter("id"));
            supplierDAO.setSupplierStatus(id, isActive);
            response.sendRedirect("Supplier?action=list");
        } catch (NumberFormatException e) {
             response.sendRedirect("Supplier?action=list&error=invalidId");
        }
    }
}