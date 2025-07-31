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
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.stream.Collectors;

@WebServlet(name = "CartController", urlPatterns = {"/customer/cart", "/customer/cart/count"})
public class CartController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(CartController.class.getName());
    private final CartItemDAO cartItemDAO = new CartItemDAO();
    private final CustomerDAO customerDAO = new CustomerDAO();
    private final ProductDAO productDAO = new ProductDAO();
    private final Gson gson = new Gson();

    private long getCustomerId(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("user") == null) {
            String sessionCartId = (String) session.getAttribute("sessionCartId");
            if (sessionCartId == null) {
                sessionCartId = UUID.randomUUID().toString();
                session.setAttribute("sessionCartId", sessionCartId);
            }
            return -1; // Indicate session-based cart
        }
        Users user = (Users) session.getAttribute("user");
        Customer customer = customerDAO.getCustomerByUserId(user.getUserId());
        if (customer == null) {
            LOGGER.log(Level.SEVERE, "Customer not found for userId: " + user.getUserId());
            response.sendRedirect(request.getContextPath() + "/Login");
            return -1;
        }
        return customer.getCustomerId();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String requestURI = request.getRequestURI();

        // Handle cart count endpoint
        if (requestURI.endsWith("/customer/cart/count")) {
            handleCartCount(request, response);
            return;
        }

        HttpSession session = request.getSession();
        if (session.getAttribute("csrfToken") == null) {
            session.setAttribute("csrfToken", UUID.randomUUID().toString());
            LOGGER.info("Generated new CSRF token: " + session.getAttribute("csrfToken"));
        }

        long customerId = getCustomerId(request, response);
        List<CartItem> cartItems = new ArrayList<>();
        BigDecimal subtotal = BigDecimal.ZERO;
        Map<Long, Integer> availableQuantities = new HashMap<>();
        int count = 0;

        if (customerId > 0) {
            cartItems = cartItemDAO.getCartItemsByCustomerId(customerId);
            subtotal = calculateSubtotal(cartItems);
            availableQuantities = cartItems.stream()
                    .collect(Collectors.toMap(CartItem::getVariantId,
                            item -> productDAO.getAvailableQuantityByVariantId(item.getVariantId())));
            count = cartItems.stream().mapToInt(CartItem::getQuantity).sum();
        } else {
            // FIXED: Handle guest cart from session
            Map<Long, CartItem> sessionCart = getSessionCart(session);
            cartItems = new ArrayList<>(sessionCart.values());
            subtotal = calculateSubtotal(cartItems);
            availableQuantities = cartItems.stream()
                    .collect(Collectors.toMap(CartItem::getVariantId,
                            item -> productDAO.getAvailableQuantityByVariantId(item.getVariantId())));
            count = cartItems.stream().mapToInt(CartItem::getQuantity).sum();
        }

        request.setAttribute("cartItems", cartItems);
        request.setAttribute("subtotal", subtotal);
        request.setAttribute("availableQuantities", availableQuantities);
        request.setAttribute("count", count);
        request.setAttribute("pageTitle", "Shopping Cart");
        request.getRequestDispatcher("/WEB-INF/views/customer/cart/cart.jsp").forward(request, response);
    }

    private void handleCartCount(HttpServletRequest request, HttpServletResponse response) throws IOException {
        long customerId = getCustomerId(request, response);
        int count = 0;

        if (customerId > 0) {
            List<CartItem> cartItems = cartItemDAO.getCartItemsByCustomerId(customerId);
            count = cartItems.stream().mapToInt(CartItem::getQuantity).sum();
        } else {
            // FIXED: Count from session cart for guest
            Map<Long, CartItem> sessionCart = getSessionCart(request.getSession());
            count = sessionCart.values().stream().mapToInt(CartItem::getQuantity).sum();
        }

        Map<String, Object> result = new HashMap<>();
        result.put("count", count);

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write(gson.toJson(result));
    }

    private BigDecimal calculateSubtotal(List<CartItem> cartItems) {
        BigDecimal subtotal = BigDecimal.ZERO;
        for (CartItem item : cartItems) {
            if (item.getUnitPrice() != null && item.getQuantity() > 0) {
                subtotal = subtotal.add(item.getUnitPrice().multiply(BigDecimal.valueOf(item.getQuantity())));
            }
        }
        return subtotal;
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("csrfToken") == null) {
            session.setAttribute("csrfToken", UUID.randomUUID().toString());
            LOGGER.info("Generated new CSRF token in POST: " + session.getAttribute("csrfToken"));
        }

        long customerId = getCustomerId(request, response);
        String csrfToken = (String) session.getAttribute("csrfToken");
        String requestToken = request.getParameter("csrfToken");
        LOGGER.info("Server CSRF Token: " + csrfToken + ", Received Token: " + requestToken);

        if (csrfToken == null || !csrfToken.equals(requestToken)) {
            sendJsonResponse(response, HttpServletResponse.SC_FORBIDDEN, false, "Invalid CSRF token.", null);
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            sendJsonResponse(response, HttpServletResponse.SC_BAD_REQUEST, false, "Missing action parameter.", null);
            return;
        }

        try {
            switch (action) {
                case "add":
                    handleAddToCart(request, response, customerId, session);
                    break;
                case "update":
                    handleUpdateQuantity(request, response, customerId, session);
                    break;
                case "remove":
                    handleRemoveFromCart(request, response, customerId, session);
                    break;
                default:
                    sendJsonResponse(response, HttpServletResponse.SC_BAD_REQUEST, false, "Invalid action.", null);
                    break;
            }
        } catch (NumberFormatException e) {
            LOGGER.log(Level.SEVERE, "Invalid input for action " + action + ": " + e.getMessage());
            sendJsonResponse(response, HttpServletResponse.SC_BAD_REQUEST, false, "Invalid input data: " + e.getMessage(), null);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error processing cart action: " + action, e);
            sendJsonResponse(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, false, "System error: " + e.getMessage(), null);
        }
    }

    private void handleAddToCart(HttpServletRequest request, HttpServletResponse response, long customerId, HttpSession session) throws IOException {
        long variantId = Long.parseLong(request.getParameter("variantId"));
        int addQuantity = Integer.parseInt(request.getParameter("quantity"));

        int availableQuantity = productDAO.getAvailableQuantityByVariantId(variantId);
        if (addQuantity <= 0 || availableQuantity < addQuantity) {
            String errorMsg = "Invalid quantity or out of stock. Available: " + availableQuantity;
            sendJsonResponse(response, HttpServletResponse.SC_BAD_REQUEST, false, errorMsg, null);
            return;
        }

        CartItem addedItem;
        if (customerId > 0) {
            cartItemDAO.addToCart(customerId, variantId, addQuantity);
            addedItem = cartItemDAO.findCartItemByVariantId(customerId, variantId);
        } else {
            // FIXED: Handle add for guest session cart
            Map<Long, CartItem> sessionCart = getSessionCart(session);
            CartItem existing = sessionCart.getOrDefault(variantId, new CartItem());
            int newQuantity = existing.getQuantity() + addQuantity;
            existing.setVariantId(variantId);
            existing.setQuantity(newQuantity);
            // FIXED: Fetch unitPrice for session cart (since no DB trigger)
            BigDecimal unitPrice = productDAO.getUnitPriceByVariantId(variantId); // Assume you add this method in ProductDAO
            existing.setUnitPrice(unitPrice != null ? unitPrice : BigDecimal.ZERO);
            sessionCart.put(variantId, existing);
            session.setAttribute("sessionCart", sessionCart);
            addedItem = existing;
        }

        // Calculate updated totals
        List<CartItem> cartItems = (customerId > 0) ? cartItemDAO.getCartItemsByCustomerId(customerId) : new ArrayList<>(getSessionCart(session).values());
        BigDecimal subtotal = calculateSubtotal(cartItems);
        int count = cartItems.stream().mapToInt(CartItem::getQuantity).sum();

        Map<String, Object> data = new HashMap<>();
        data.put("subtotal", subtotal.doubleValue());
        data.put("count", count);
        if (addedItem != null && addedItem.getUnitPrice() != null) {
            data.put("unitPrice", addedItem.getUnitPrice().doubleValue());
        }

        sendJsonResponse(response, HttpServletResponse.SC_OK, true, "Product added to cart.", data);
    }

    private void handleUpdateQuantity(HttpServletRequest request, HttpServletResponse response, long customerId, HttpSession session) throws IOException {
        long cartItemId = Long.parseLong(request.getParameter("cartItemId"));
        int newQuantity = Integer.parseInt(request.getParameter("quantity"));

        if (customerId > 0) {
            CartItem item = cartItemDAO.findCartItem(customerId, cartItemId);
            if (item == null) {
                sendJsonResponse(response, HttpServletResponse.SC_BAD_REQUEST, false, "Product not found in cart.", null);
                return;
            }

            if (newQuantity <= 0) {
                cartItemDAO.removeFromCart(cartItemId);
                // Calculate updated totals
                List<CartItem> cartItems = cartItemDAO.getCartItemsByCustomerId(customerId);
                BigDecimal subtotal = calculateSubtotal(cartItems);
                int count = cartItems.stream().mapToInt(CartItem::getQuantity).sum();

                Map<String, Object> data = new HashMap<>();
                data.put("cartItemId", cartItemId);
                data.put("subtotal", subtotal.doubleValue());
                data.put("count", count);
                sendJsonResponse(response, HttpServletResponse.SC_OK, true, "Product removed from cart.", data);
                return;
            }

            int available = productDAO.getAvailableQuantityByVariantId(item.getVariantId());
            if (newQuantity > available + item.getQuantity()) { // + current to allow reduce
                sendJsonResponse(response, HttpServletResponse.SC_BAD_REQUEST, false, "Quantity exceeds available stock: " + available, null);
                return;
            }

            cartItemDAO.updateQuantity(cartItemId, newQuantity, customerId);

            // Calculate updated totals
            List<CartItem> cartItems = cartItemDAO.getCartItemsByCustomerId(customerId);
            BigDecimal subtotal = calculateSubtotal(cartItems);
            int count = cartItems.stream().mapToInt(CartItem::getQuantity).sum();

            Map<String, Object> data = new HashMap<>();
            data.put("cartItemId", cartItemId);
            data.put("newQuantity", newQuantity);
            data.put("unitPrice", item.getUnitPrice().doubleValue());
            data.put("subtotal", subtotal.doubleValue());
            data.put("count", count);
            sendJsonResponse(response, HttpServletResponse.SC_OK, true, "Quantity updated successfully.", data);
        } else {
            // FIXED: Handle update for guest session cart
            Map<Long, CartItem> sessionCart = getSessionCart(session);
            // Assume cartItemId is variantId for guest (since no DB id)
            long variantId = cartItemId; // For guest, use variantId as key
            CartItem item = sessionCart.get(variantId);
            if (item == null) {
                sendJsonResponse(response, HttpServletResponse.SC_BAD_REQUEST, false, "Product not found in cart.", null);
                return;
            }

            int available = productDAO.getAvailableQuantityByVariantId(variantId);
            if (newQuantity <= 0) {
                sessionCart.remove(variantId);
            } else if (newQuantity > available + item.getQuantity()) {
                sendJsonResponse(response, HttpServletResponse.SC_BAD_REQUEST, false, "Quantity exceeds available stock: " + available, null);
                return;
            } else {
                item.setQuantity(newQuantity);
            }
            session.setAttribute("sessionCart", sessionCart);

            // Calculate updated totals
            List<CartItem> cartItems = new ArrayList<>(sessionCart.values());
            BigDecimal subtotal = calculateSubtotal(cartItems);
            int count = cartItems.stream().mapToInt(CartItem::getQuantity).sum();

            Map<String, Object> data = new HashMap<>();
            data.put("cartItemId", variantId);
            data.put("newQuantity", newQuantity);
            data.put("unitPrice", item.getUnitPrice().doubleValue());
            data.put("subtotal", subtotal.doubleValue());
            data.put("count", count);
            sendJsonResponse(response, HttpServletResponse.SC_OK, true, "Quantity updated successfully.", data);
        }
    }

    private void handleRemoveFromCart(HttpServletRequest request, HttpServletResponse response, long customerId, HttpSession session) throws IOException {
        long removeCartItemId = Long.parseLong(request.getParameter("cartItemId"));

        if (customerId > 0) {
            cartItemDAO.removeFromCart(removeCartItemId);
            // Calculate updated totals
            List<CartItem> cartItems = cartItemDAO.getCartItemsByCustomerId(customerId);
            BigDecimal subtotal = calculateSubtotal(cartItems);
            int count = cartItems.stream().mapToInt(CartItem::getQuantity).sum();

            Map<String, Object> data = new HashMap<>();
            data.put("cartItemId", removeCartItemId);
            data.put("subtotal", subtotal.doubleValue());
            data.put("count", count);
            sendJsonResponse(response, HttpServletResponse.SC_OK, true, "Product removed from cart.", data);
        } else {
            // FIXED: Handle remove for guest session cart
            Map<Long, CartItem> sessionCart = getSessionCart(session);
            // For guest, cartItemId is variantId
            sessionCart.remove(removeCartItemId);
            session.setAttribute("sessionCart", sessionCart);

            // Calculate updated totals
            List<CartItem> cartItems = new ArrayList<>(sessionCart.values());
            BigDecimal subtotal = calculateSubtotal(cartItems);
            int count = cartItems.stream().mapToInt(CartItem::getQuantity).sum();

            Map<String, Object> data = new HashMap<>();
            data.put("cartItemId", removeCartItemId);
            data.put("subtotal", subtotal.doubleValue());
            data.put("count", count);
            sendJsonResponse(response, HttpServletResponse.SC_OK, true, "Product removed from cart.", data);
        }
    }

    private void sendJsonResponse(HttpServletResponse response, int statusCode, boolean success, String message, Object data) throws IOException {
        response.setStatus(statusCode);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        Map<String, Object> result = new HashMap<>();
        result.put("success", success);
        result.put("message", message);
        result.put("data", data);
        response.getWriter().write(gson.toJson(result));
    }

    // FIXED: Helper for guest session cart (Map<VariantId, CartItem>)
    private Map<Long, CartItem> getSessionCart(HttpSession session) {
        Map<Long, CartItem> sessionCart = (Map<Long, CartItem>) session.getAttribute("sessionCart");
        if (sessionCart == null) {
            sessionCart = new HashMap<>();
            session.setAttribute("sessionCart", sessionCart);
        }
        return sessionCart;
    }
}
