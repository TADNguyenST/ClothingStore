package controller.customer;

import com.google.gson.Gson;
import dao.AddressDAO;
import dao.ProvinceDAO;
import dao.WardDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Address;
import model.Province;
import model.Users;
import model.Ward;

import java.io.IOException;
import java.util.*;

@WebServlet(name = "AddressController", urlPatterns = {"/customer/address"})
public class AddressController extends HttpServlet {

    private final AddressDAO addressDAO = new AddressDAO();
    private final ProvinceDAO provinceDAO = new ProvinceDAO();
    private final WardDAO wardDAO = new WardDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String action = request.getParameter("action");

        // Cho AJAX lấy địa giới/sổ địa chỉ nếu chưa login -> trả JSON 401
        if (session == null || session.getAttribute("user") == null) {
            if ("getProvinces".equals(action) || "getWards".equals(action) || "getAddresses".equals(action)) {
                response.setStatus(401);
                writeJson(response, simpleError("Unauthorized"));
                return;
            }
            response.sendRedirect(request.getContextPath() + "/Login");
            return;
        }

        try {
            if ("getProvinces".equals(action)) {
                serveProvinces(response);
            } else if ("getWards".equals(action)) {
                String provinceCode = request.getParameter("id"); // id == provinceCode
                serveWardsByProvince(provinceCode, response);
            } else if ("getAddresses".equals(action)) {
                handleGetSavedAddresses(request, response);
            } else {
                request.getRequestDispatcher("/WEB-INF/views/customer/address/address.jsp")
                        .forward(request, response);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            response.setStatus(500);
            writeJson(response, simpleError("Internal server error"));
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

        boolean success = false;
        String message = "";
        try {
            if ("add".equals(action)) {
                Address newAddress = mapRequestToAddress(request);
                newAddress.setUserId(user.getUserId());

                success = addressDAO.addAddress(newAddress);

                // Đảm bảo luôn có 1 default sau khi thêm
                ensureOneDefault(user.getUserId(), null);

                message = success ? "Address added successfully." : "Failed to add address.";

            } else if ("update".equals(action)) {
                Address updated = mapRequestToAddress(request);
                updated.setAddressId(Long.parseLong(request.getParameter("addressId")));
                updated.setUserId(user.getUserId());

                success = addressDAO.updateAddress(updated);

                // Nếu sau khi update không còn default -> set default cho bản ghi vừa update
                ensureOneDefault(user.getUserId(), updated.getAddressId());

                message = success ? "Address updated successfully." : "Failed to update address.";

            } else if ("delete".equals(action)) {
                long deleteId = Long.parseLong(request.getParameter("addressId"));

                // Không cho xoá hết: phải còn ≥ 1 địa chỉ
                List<Address> current = addressDAO.getAddressesByUserId(user.getUserId());
                if (current == null) {
                    current = new ArrayList<>();
                }
                if (current.size() <= 1) {
                    success = false;
                    message = "You must keep at least one address.";
                } else {
                    // Xác định bản ghi cần xoá & có phải default không
                    Address target = null;
                    for (Address a : current) {
                        if (a.getAddressId() == deleteId) {
                            target = a;
                            break;
                        }
                    }
                    if (target == null) {
                        success = false;
                        message = "Address not found.";
                    } else {
                        boolean wasDefault = target.isDefault();
                        success = addressDAO.deleteAddress(deleteId, user.getUserId());
                        if (success) {
                            // Nếu xoá default -> gán default cho 1 bản ghi còn lại (ưu tiên mới nhất)
                            if (wasDefault) {
                                ensureOneDefault(user.getUserId(), null);
                            }
                            message = "Address deleted successfully.";
                        } else {
                            message = "Failed to delete address.";
                        }
                    }
                }

            } else if ("setDefault".equals(action)) {
                long defaultId = Long.parseLong(request.getParameter("addressId"));
                success = addressDAO.setDefaultAddress(defaultId, user.getUserId());
                // bảo đảm sau gọi vẫn còn default
                ensureOneDefault(user.getUserId(), defaultId);
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

    /* ========================= Helpers ========================= */
    /**
     * Luôn bảo đảm có đúng 1 địa chỉ default cho user. - Nếu đã có default:
     * không làm gì - Nếu chưa có: chọn preferredId (nếu != null), ngược lại
     * chọn bản ghi mới nhất
     */
    private void ensureOneDefault(long userId, Long preferredId) {
        List<Address> list = addressDAO.getAddressesByUserId(userId);
        if (list == null || list.isEmpty()) {
            return;
        }

        Address currentDefault = null;
        for (Address a : list) {
            if (a.isDefault()) {
                currentDefault = a;
                break;
            }
        }

        if (currentDefault == null) {
            long idToSet;
            if (preferredId != null) {
                idToSet = preferredId;
            } else {
                // danh sách đã sắp xếp: default DESC, created_at DESC trong DAO -> chọn phần tử đầu
                idToSet = list.get(0).getAddressId();
            }
            addressDAO.setDefaultAddress(idToSet, userId);
        }
    }

    private void handleGetSavedAddresses(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Users user = (Users) request.getSession().getAttribute("user");
        List<Address> addresses = addressDAO.getAddressesByUserId(user.getUserId());
        sendJsonResponse(response, 200, true, null, addresses);
    }

    private void serveProvinces(HttpServletResponse response) throws IOException {
        List<Province> list = provinceDAO.getAllProvinces();
        List<Map<String, Object>> out = new ArrayList<>();
        for (Province p : list) {
            Map<String, Object> m = new HashMap<>();
            m.put("name", p.getName());
            m.put("code", p.getCode());
            out.add(m);
        }
        writeJson(response, out);
    }

    // nhận provinceCode -> trả wards của tỉnh đó
    private void serveWardsByProvince(String provinceCode, HttpServletResponse response) throws IOException {
        if (isBlank(provinceCode)) {
            writeJson(response, Collections.emptyList());
            return;
        }
        Province p = provinceDAO.findByCode(provinceCode);
        if (p == null) {
            writeJson(response, Collections.emptyList());
            return;
        }
        List<Ward> wards = wardDAO.getWardsByProvinceId(p.getProvinceId());
        List<Map<String, Object>> out = new ArrayList<>();
        for (Ward w : wards) {
            Map<String, Object> m = new HashMap<>();
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

        String provinceCode = request.getParameter("provinceId"); // client vẫn dùng name này
        String wardCode = request.getParameter("wardId");

        Province p = provinceDAO.findByCode(provinceCode);
        if (p == null) {
            throw new IllegalArgumentException("Invalid Province Code: " + provinceCode);
        }
        address.setProvinceId(p.getProvinceId());

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
        Map<String, Object> result = new HashMap<>();
        result.put("success", success);
        result.put("message", message);
        result.put("data", data);
        response.getWriter().write(gson.toJson(result));
    }

    private void writeJson(HttpServletResponse response, Object data) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
        response.getWriter().write(gson.toJson(data));
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    private boolean eq(String a, String b) {
        return a == null ? b == null : a.equals(b);
    }

    private Map<String, String> simpleError(String msg) {
        Map<String, String> m = new HashMap<>();
        m.put("error", msg);
        return m;
    }
}
