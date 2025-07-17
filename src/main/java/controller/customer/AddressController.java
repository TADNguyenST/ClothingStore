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
import model.*;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
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

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/Login");
            return;
        }

        String action = request.getParameter("action");

        // --- SỬA LẠI LOGIC PROXY TẠI ĐÂY ---
        if ("getProvinces".equals(action)) {
            proxyApiRequest("https://provinces.open-api.vn/api/p", response);
        } else if ("getDistricts".equals(action)) {
            // Lấy code trực tiếp từ request và truyền đi, không cần tra cứu ID
            String provinceCode = request.getParameter("id");
            proxyApiRequest("https://provinces.open-api.vn/api/p/" + provinceCode + "?depth=2", response);
        } else if ("getWards".equals(action)) {
            // Lấy code trực tiếp từ request và truyền đi
            String districtCode = request.getParameter("id");
            proxyApiRequest("https://provinces.open-api.vn/api/d/" + districtCode + "?depth=2", response);
        } else if ("getAddresses".equals(action)) {
            handleGetSavedAddresses(request, response);
        } else {
            request.getRequestDispatcher("/WEB-INF/views/customer/address/address.jsp").forward(request, response);
        }
    }

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
            switch (action) {
                case "add": {
                    Address newAddress = mapRequestToAddress(request);
                    newAddress.setUserId(user.getUserId());

                    // --- LOGGING ĐỂ KIỂM TRA ---
                    System.out.println("--- BẮT ĐẦU THÊM ĐỊA CHỈ MỚI ---");
                    System.out.println("Tên người nhận: " + newAddress.getRecipientName());
                    System.out.println("Checkbox 'isDefault' được chọn: " + newAddress.isDefault());
                    // -----------------------------

                    success = addressDAO.addAddress(newAddress);
                    if (success && newAddress.isDefault()) {
                        // Tìm địa chỉ vừa thêm bằng vòng lặp
                        List<Address> addresses = addressDAO.getAddressesByUserId(user.getUserId());
                        Address addedAddress = null;
                        for (Address a : addresses) {
                            if (a.getRecipientName().equals(newAddress.getRecipientName())
                                    && a.getPhoneNumber().equals(newAddress.getPhoneNumber())
                                    && a.getStreetAddress().equals(newAddress.getStreetAddress())) {
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
                    break;
                }
                case "update": {
                    Address updatedAddress = mapRequestToAddress(request);
                    updatedAddress.setAddressId(Long.parseLong(request.getParameter("addressId")));
                    updatedAddress.setUserId(user.getUserId());

                    success = addressDAO.updateAddress(updatedAddress);
                    if (success && updatedAddress.isDefault()) {
                        // Nếu update thành công và người dùng muốn đặt làm mặc định
                        addressDAO.setDefaultAddress(updatedAddress.getAddressId(), user.getUserId());
                    }
                    message = success ? "Address updated successfully." : "Failed to update address.";
                    break;
                }
                case "delete": {
                    long deleteId = Long.parseLong(request.getParameter("addressId"));
                    success = addressDAO.deleteAddress(deleteId, user.getUserId());
                    message = success ? "Address deleted successfully." : "Failed to delete address.";
                    break;
                }
                case "setDefault": {
                    long defaultId = Long.parseLong(request.getParameter("addressId"));
                    success = addressDAO.setDefaultAddress(defaultId, user.getUserId());
                    message = success ? "Default address set successfully." : "Failed to set default address.";
                    break;
                }
                default:
                    success = false;
                    message = "Invalid action.";
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            success = false;
            message = "An unexpected error occurred: " + e.getMessage();
        }
        sendJsonResponse(response, 200, success, message, null);
    }

    private void handleGetSavedAddresses(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Users user = (Users) request.getSession().getAttribute("user");
        List<Address> addresses = addressDAO.getAddressesByUserId(user.getUserId());
        System.out.println("Addresses returned for user " + user.getUserId() + ":");
        for (Address addr : addresses) {
            System.out.println("Address ID: " + addr.getAddressId() + ", isDefault: " + addr.isDefault());
        }
        sendJsonResponse(response, 200, true, null, addresses);
    }

    private void proxyApiRequest(String apiUrl, HttpServletResponse response) throws IOException {
        HttpURLConnection connection = null;
        try {
            URL url = new URL(apiUrl);
            connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod("GET");
            connection.setConnectTimeout(5000);
            connection.setReadTimeout(5000);

            if (connection.getResponseCode() == HttpURLConnection.HTTP_OK) {
                StringBuilder content = new StringBuilder();
                try ( BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream(), "UTF-8"))) {
                    String inputLine;
                    while ((inputLine = in.readLine()) != null) {
                        content.append(inputLine);
                    }
                }
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write(content.toString());
            } else {
                response.sendError(connection.getResponseCode());
            }
        } finally {
            if (connection != null) {
                connection.disconnect();
            }
        }
    }

    private Address mapRequestToAddress(HttpServletRequest request) {
        // Phương thức này đã chính xác
        Address address = new Address();
        address.setRecipientName(request.getParameter("recipientName"));
        address.setPhoneNumber(request.getParameter("phoneNumber"));
        address.setStreetAddress(request.getParameter("streetAddress"));

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
        address.setDefault(isDefaultParam != null && isDefaultParam.equals("true"));
        return address;
    }

    private void sendJsonResponse(HttpServletResponse response, int statusCode, boolean success, String message, Object data) throws IOException {
        response.setStatus(statusCode);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setHeader("Expires", "0");
        Map<String, Object> result = new HashMap<>();
        result.put("success", success);
        result.put("message", message);
        result.put("data", data);
        String json = gson.toJson(result);
        System.out.println("JSON response: " + json);
        response.getWriter().write(json);
    }
}
