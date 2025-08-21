package controller.customer;

import com.google.gson.Gson;
import dao.AddressDAO;
import dao.DistrictDAO;
import dao.ProvinceDAO;
import dao.WardDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Address;
import model.District;
import model.Province;
import model.Users;
import model.Ward;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections; 
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "AddressController", urlPatterns = {"/customer/address"})
public class AddressController extends HttpServlet {

    private final AddressDAO addressDAO = new AddressDAO();
    private final ProvinceDAO provinceDAO = new ProvinceDAO();
    private final DistrictDAO districtDAO = new DistrictDAO();
    private final WardDAO wardDAO = new WardDAO();
    private final Gson gson = new Gson();

    /* =========================
       GET
       ========================= */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        String action = request.getParameter("action");

        // Nếu là AJAX lấy địa giới / danh sách địa chỉ mà chưa đăng nhập -> trả JSON 401 (tránh redirect HTML)
        if (session == null || session.getAttribute("user") == null) {
            if ("getProvinces".equals(action) || "getDistricts".equals(action) || "getWards".equals(action) || "getAddresses".equals(action)) {
                response.setStatus(401);
                writeJson(response, simpleError("Unauthorized")); // JDK8: không dùng Map.of
                return;
            }
            response.sendRedirect(request.getContextPath() + "/Login");
            return;
        }

        try {
            if ("getProvinces".equals(action)) {
                serveProvinces(response);
            } else if ("getDistricts".equals(action)) {
                // Client gửi "id" nhưng thực chất là CODE
                String provinceCode = request.getParameter("id");
                serveDistricts(provinceCode, response);
            } else if ("getWards".equals(action)) {
                // Client gửi "id" nhưng thực chất là CODE
                String districtCode = request.getParameter("id");
                serveWards(districtCode, response);
            } else if ("getAddresses".equals(action)) {
                handleGetSavedAddresses(request, response);
            } else {
                request.getRequestDispatcher("/WEB-INF/views/customer/address/address.jsp").forward(request, response);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            response.setStatus(500);
            writeJson(response, simpleError("Internal server error"));
        }
    }

    /* =========================
       POST (giữ nguyên logic add/update/delete/setDefault)
       ========================= */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            sendJsonResponse(response, 401, false, "Authentication required.", null);
            return;
        }
        Users user = (Users) session.getAttribute("user");
        String action = request.getParameter("action");
        if (action == null) {
            sendJsonResponse(response, 400, false, "Action parameter is missing.", null);
            return;
        }

        boolean success;
        String message = "";
        try {
            if ("add".equals(action)) {
                Address newAddress = mapRequestToAddress(request);
                newAddress.setUserId(user.getUserId());

                System.out.println("--- ADD ADDRESS ---");
                System.out.println("Recipient: " + newAddress.getRecipientName());
                System.out.println("isDefault checkbox: " + newAddress.isDefault());

                success = addressDAO.addAddress(newAddress);

                if (success && newAddress.isDefault()) {
                    // tìm lại địa chỉ vừa thêm để set default (có thể tối ưu bằng trả id từ DAO)
                    List<Address> addresses = addressDAO.getAddressesByUserId(user.getUserId());
                    Address addedAddress = null;
                    for (Address a : addresses) {
                        if (eq(a.getRecipientName(), newAddress.getRecipientName())
                                && eq(a.getPhoneNumber(), newAddress.getPhoneNumber())
                                && eq(a.getStreetAddress(), newAddress.getStreetAddress())) {
                            addedAddress = a;
                            break;
                        }
                    }
                    if (addedAddress != null) {
                        success = addressDAO.setDefaultAddress(addedAddress.getAddressId(), user.getUserId());
                        if (!success) {
                            message = "Address added but failed to set as default.";
                        }
                    } else {
                        message = "Address added but could not find it to set as default.";
                        success = false;
                    }
                }
                message = success ? "Address added successfully." : (message.isEmpty() ? "Failed to add address." : message);

            } else if ("update".equals(action)) {
                Address updatedAddress = mapRequestToAddress(request);
                updatedAddress.setAddressId(Long.parseLong(request.getParameter("addressId")));
                updatedAddress.setUserId(user.getUserId());

                success = addressDAO.updateAddress(updatedAddress);
                if (success && updatedAddress.isDefault()) {
                    addressDAO.setDefaultAddress(updatedAddress.getAddressId(), user.getUserId());
                }
                message = success ? "Address updated successfully." : "Failed to update address.";

            } else if ("delete".equals(action)) {
                long deleteId = Long.parseLong(request.getParameter("addressId"));
                success = addressDAO.deleteAddress(deleteId, user.getUserId());
                message = success ? "Address deleted successfully." : "Failed to delete address.";

            } else if ("setDefault".equals(action)) {
                long defaultId = Long.parseLong(request.getParameter("addressId"));
                success = addressDAO.setDefaultAddress(defaultId, user.getUserId());
                message = success ? "Default address set successfully." : "Failed to set default address.";

            } else {
                success = false;
                message = "Invalid action.";
            }
        } catch (Exception e) {
            e.printStackTrace();
            success = false;
            message = "An unexpected error occurred: " + e.getMessage();
        }
        sendJsonResponse(response, 200, success, message, null);
    }

    /* =========================
       Handlers/Helpers
       ========================= */
    private void handleGetSavedAddresses(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Users user = (Users) request.getSession().getAttribute("user");
        List<Address> addresses = addressDAO.getAddressesByUserId(user.getUserId());
        System.out.println("Addresses returned for user " + user.getUserId() + ":");
        for (Address addr : addresses) {
            System.out.println("Address ID: " + addr.getAddressId() + ", isDefault: " + addr.isDefault());
        }
        sendJsonResponse(response, 200, true, null, addresses);
    }

    /**
     * Trả danh sách tỉnh từ DB: [{name, code}]
     */
    private void serveProvinces(HttpServletResponse response) throws IOException {
        List<Province> list = provinceDAO.getAllProvinces();
        List<Map<String, Object>> out = new ArrayList<Map<String, Object>>();
        for (Province p : list) {
            Map<String, Object> m = new HashMap<String, Object>();
            m.put("name", p.getName());
            m.put("code", p.getCode());
            out.add(m);
        }
        writeJson(response, out);
    }

    /**
     * Nhận provinceCode (string) -> trả districts của tỉnh đó: [{name, code}]
     */
    private void serveDistricts(String provinceCode, HttpServletResponse response) throws IOException {
        if (isBlank(provinceCode)) {
            writeJson(response, Collections.emptyList()); // JDK8
            return;
        }
        Province p = provinceDAO.findByCode(provinceCode);
        if (p == null) {
            writeJson(response, Collections.emptyList());
            return;
        }
        List<District> districts = districtDAO.getDistrictsByProvinceId(p.getProvinceId());
        List<Map<String, Object>> out = new ArrayList<Map<String, Object>>();
        for (District d : districts) {
            Map<String, Object> m = new HashMap<String, Object>();
            m.put("name", d.getName());
            m.put("code", d.getCode());
            out.add(m);
        }
        writeJson(response, out);
    }

    /**
     * Nhận districtCode (string) -> trả wards của quận/huyện đó: [{name, code}]
     */
    private void serveWards(String districtCode, HttpServletResponse response) throws IOException {
        if (isBlank(districtCode)) {
            writeJson(response, Collections.emptyList());
            return;
        }
        District d = districtDAO.findByCode(districtCode);
        if (d == null) {
            writeJson(response, Collections.emptyList());
            return;
        }
        List<Ward> wards = wardDAO.getWardsByDistrictId(d.getDistrictId());
        List<Map<String, Object>> out = new ArrayList<Map<String, Object>>();
        for (Ward w : wards) {
            Map<String, Object> m = new HashMap<String, Object>();
            m.put("name", w.getName());
            m.put("code", w.getCode());
            out.add(m);
        }
        writeJson(response, out);
    }

    private Address mapRequestToAddress(HttpServletRequest request) {
        Address address = new Address();
        address.setRecipientName(request.getParameter("recipientName"));
        address.setPhoneNumber(request.getParameter("phoneNumber"));
        address.setStreetAddress(request.getParameter("streetAddress"));

        // 3 field phía client đặt tên ...Id nhưng thực chất là CODE
        String provinceCode = request.getParameter("provinceId");
        String districtCode = request.getParameter("districtId");
        String wardCode = request.getParameter("wardId");

        Province p = provinceDAO.findByCode(provinceCode);
        if (p == null) {
            throw new IllegalArgumentException("Invalid Province Code: " + provinceCode);
        }
        address.setProvinceId(p.getProvinceId());

        District d = districtDAO.findByCode(districtCode);
        if (d == null) {
            throw new IllegalArgumentException("Invalid District Code: " + districtCode);
        }
        address.setDistrictId(d.getDistrictId());

        Ward w = wardDAO.findByCode(wardCode);
        if (w == null) {
            throw new IllegalArgumentException("Invalid Ward Code: " + wardCode);
        }
        address.setWardId(w.getWardId());

        String isDefaultParam = request.getParameter("isDefault");
        address.setDefault(isDefaultParam != null && "true".equals(isDefaultParam));
        return address;
    }

    private void sendJsonResponse(HttpServletResponse response, int statusCode, boolean success, String message, Object data) throws IOException {
        response.setStatus(statusCode);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setHeader("Expires", "0");
        Map<String, Object> result = new HashMap<String, Object>();
        result.put("success", success);
        result.put("message", message);
        result.put("data", data);
        String json = gson.toJson(result);
        System.out.println("JSON response: " + json);
        response.getWriter().write(json);
    }

    private void writeJson(HttpServletResponse response, Object data) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
        response.getWriter().write(gson.toJson(data));
    }

    /* ===== Utils cho JDK 8 ===== */
    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    private boolean eq(String a, String b) {
        if (a == null) {
            return b == null;
        }
        return a.equals(b);
    }

    private Map<String, String> simpleError(String msg) {
        Map<String, String> m = new HashMap<String, String>();
        m.put("error", msg);
        return m;
    }
}
