package controller.customer;

import com.google.gson.Gson;
import dao.CartItemDAO;
import dao.CustomerDAO;
import dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.CartItem;
import model.Customer;
import model.Users;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(name = "CartController", urlPatterns = {"/customer/cart", "/customer/cart/count"})
public class CartController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(CartController.class.getName());
    private final CartItemDAO cartItemDAO = new CartItemDAO();
    private final CustomerDAO customerDAO = new CustomerDAO();
    private final ProductDAO productDAO = new ProductDAO();
    private final Gson gson = new Gson();

    private long getCustomerId(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/Login"); // Đảm bảo "/Login" với chữ "L" viết hoa
            return -1;
        }

        Users user = (Users) session.getAttribute("user");
        Customer customer = customerDAO.getCustomerByUserId(user.getUserId());
        if (customer == null) {
            response.sendRedirect(request.getContextPath() + "/Login"); // Đảm bảo "/Login" với chữ "L" viết hoa
            return -1;
        }
        return customer.getCustomerId();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        long customerId = getCustomerId(request, response);
        if (customerId == -1) {
            return;
        }

        String path = request.getServletPath();
        if ("/customer/cart/count".equals(path)) {
            int count = cartItemDAO.getCartItemsByCustomerId(customerId).size();
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            Map<String, Integer> result = new HashMap<>();
            result.put("count", count);
            String json = gson.toJson(result);
            response.getWriter().write(json);
            return;
        }

        List<CartItem> cartItems = cartItemDAO.getCartItemsByCustomerId(customerId);
        BigDecimal subtotal = BigDecimal.ZERO;
        for (CartItem item : cartItems) {
            BigDecimal totalPrice = item.getTotalPrice();
            if (totalPrice != null) {
                subtotal = subtotal.add(totalPrice);
            }
        }

        request.setAttribute("cartItems", cartItems);
        request.setAttribute("subtotal", subtotal);
        request.setAttribute("pageTitle", "Shopping Cart");
        request.getRequestDispatcher("/WEB-INF/views/customer/cart/cart.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        long customerId = getCustomerId(request, response);
        if (customerId == -1) {
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            sendJsonResponse(response, HttpServletResponse.SC_BAD_REQUEST, false, "Action parameter is missing.", null);
            return;
        }

        boolean success = false;
        String message = "";
        Map<String, Object> data = new HashMap<>();
        try {
            switch (action) {
                case "add": {
                    long variantId = Long.parseLong(getValidatedParameter(request, "variantId", "Variant ID"));
                    int addQuantity = Integer.parseInt(getValidatedParameter(request, "quantity", "Quantity"));
                    if (addQuantity <= 0) {
                        message = "Quantity must be greater than 0.";
                        break;
                    }
                    int availableQuantity = getAvailableQuantity(variantId, request, response);
                    if (availableQuantity < 0) {
                        message = "Error fetching available quantity.";
                        break;
                    }
                    if (addQuantity > availableQuantity) {
                        message = "Requested quantity exceeds available stock: " + availableQuantity;
                        break;
                    }
                    cartItemDAO.addToCart(customerId, variantId, addQuantity);
                    success = true;
                    message = "Product added to cart!";
                    data.put("subtotal", calculateSubtotal(customerId));
                    break;
                }
                case "update": {
                    String cartItemIdStr = getValidatedParameter(request, "cartItemId", "Cart Item ID");
                    LOGGER.info("Received cartItemId: " + cartItemIdStr); // Debug
                    long cartItemId = Long.parseLong(cartItemIdStr);
                    int newQuantity = Integer.parseInt(getValidatedParameter(request, "quantity", "Quantity"));
                    if (newQuantity <= 0) {
                        cartItemDAO.removeFromCart(cartItemId);
                        success = true;
                        message = "Item removed from cart.";
                        break;
                    }
                    CartItem item = cartItemDAO.findCartItem(customerId, cartItemId);
                    if (item == null) {
                        message = "Cart item not found.";
                        break;
                    }
                    Long variantIdObj = item.getVariantId();
                    if (variantIdObj == null) {
                        LOGGER.warning("variantId is null for cartItemId: " + cartItemId);
                        message = "Invalid variant ID (null) for cart item.";
                        break;
                    }
                    long variantId = variantIdObj;
                    if (variantId <= 0) {
                        LOGGER.warning("Invalid variantId: " + variantId + " for cartItemId: " + cartItemId);
                        message = "Invalid variant ID for cart item.";
                        break;
                    }
                    int availableQuantity = getAvailableQuantity(variantId, request, response);
                    if (availableQuantity < 0) {
                        message = "Error fetching available quantity.";
                        break;
                    }
                    if (newQuantity > availableQuantity) {
                        message = "Requested quantity exceeds available stock: " + availableQuantity;
                        break;
                    }
                    cartItemDAO.updateQuantity(cartItemId, newQuantity);
                    success = true;
                    message = "Quantity updated successfully.";
                    data.put("cartItemId", cartItemId);
                    data.put("newQuantity", newQuantity);
                    data.put("unitPrice", item.getUnitPrice() != null ? item.getUnitPrice().doubleValue() : 0.0); // Đảm bảo trả về số
                    data.put("subtotal", calculateSubtotal(customerId).doubleValue()); // Đảm bảo trả về số
                    break;
                }
                case "remove": {
                    String cartItemIdStr = getValidatedParameter(request, "cartItemId", "Cart Item ID");
                    LOGGER.info("Received cartItemId for remove: " + cartItemIdStr); // Debug
                    long cartItemId = Long.parseLong(cartItemIdStr);
                    cartItemDAO.removeFromCart(cartItemId);
                    success = true;
                    message = "Item removed from cart.";
                    data.put("cartItemId", cartItemId);
                    data.put("subtotal", calculateSubtotal(customerId).doubleValue()); // Đảm bảo trả về số
                    break;
                }
                default:
                    message = "Invalid action.";
                    break;
            }
        } catch (NumberFormatException e) {
            message = "Invalid input data for " + e.getMessage().split(":")[0] + ". Received value: " + request.getParameter(e.getMessage().split(":")[0]);
            LOGGER.log(Level.WARNING, "NumberFormatException in CartController: {0}", e.getMessage());
        } catch (IllegalArgumentException e) {
            message = e.getMessage() + ". Received value: " + request.getParameter(e.getMessage().split(":")[0]);
            LOGGER.log(Level.WARNING, "IllegalArgumentException in CartController: {0}", e.getMessage());
        } catch (Exception e) {
            message = "An unexpected error occurred: " + e.getMessage();
            LOGGER.log(Level.SEVERE, "Unexpected error in CartController: {0}", e.getMessage());
        }

        sendJsonResponse(response, success ? HttpServletResponse.SC_OK : HttpServletResponse.SC_BAD_REQUEST, success, message, data);
    }

    private BigDecimal calculateSubtotal(long customerId) {
        List<CartItem> cartItems = cartItemDAO.getCartItemsByCustomerId(customerId);
        BigDecimal subtotal = BigDecimal.ZERO;
        for (CartItem item : cartItems) {
            BigDecimal totalPrice = item.getTotalPrice();
            if (totalPrice != null) {
                subtotal = subtotal.add(totalPrice);
            }
        }
        return subtotal;
    }

    private String getValidatedParameter(HttpServletRequest request, String paramName, String paramDescription) {
        String value = request.getParameter(paramName);
        if (value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException(paramDescription + " is required.");
        }
        return value;
    }

    private int getAvailableQuantity(long variantId, HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            int available = productDAO.getAvailableQuantityByVariantId(variantId);
            if (available < 0) {
                sendJsonResponse(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, false, "Invalid available quantity for variant ID: " + variantId, null);
                return -1;
            }
            return available;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error fetching available quantity for variantId: " + variantId, e);
            sendJsonResponse(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, false, "Error fetching available quantity: " + e.getMessage(), null);
            return -1;
        }
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
        LOGGER.log(Level.INFO, "JSON response: {0}", json);
        response.getWriter().write(json);
    }
}
