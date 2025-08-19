package controller.customer;

import dao.CartItemDAO;
import model.CartItem;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.json.JSONObject;

@WebServlet({"/customer/cart", "/customer/cart/count"})
public class CartController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(CartController.class.getName());
    private CartItemDAO cartItemDAO;

    @Override
    public void init() throws ServletException {
        cartItemDAO = new CartItemDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Long userId = (Long) session.getAttribute("userId");
        String path = request.getServletPath();

        // API đếm số lượng badge
        if ("/customer/cart/count".equals(path)) {
            handleCartCount(request, response, userId);
            return;
        }

        // Cho phép GUEST truy cập trang giỏ hàng
        try {
            List<CartItem> cartItems = null;
            BigDecimal totalAmount = BigDecimal.ZERO;

            if (userId != null) {
                long customerId = cartItemDAO.getCustomerIdByUserId(userId);
                cartItems = cartItemDAO.getCartItems(customerId);
                LOGGER.log(Level.INFO, "Fetched {0} cart items for customerId={1}",
                        new Object[]{(cartItems == null ? 0 : cartItems.size()), customerId});

                if (cartItems != null) {
                    for (CartItem item : cartItems) {
                        if (item.getTotalPrice() != null) {
                            totalAmount = totalAmount.add(item.getTotalPrice());
                        }
                    }
                }
            } else {
                // Guest: để cartItems = null để JSP hiện "Your cart is empty"
                LOGGER.log(Level.INFO, "Guest visits cart page.");
            }

            request.setAttribute("cartItems", cartItems);
            request.setAttribute("totalAmount", totalAmount);
            request.getRequestDispatcher("/WEB-INF/views/customer/cart/cart.jsp").forward(request, response);

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching cart items for userId=" + userId, e);
            throw new ServletException("Database error", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Long userId = (Long) session.getAttribute("userId");

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setHeader("Expires", "0");

        PrintWriter out = response.getWriter();
        JSONObject json = new JSONObject();

        // Các thao tác POST vẫn yêu cầu đăng nhập
        if (userId == null) {
            json.put("success", false);
            json.put("message", "Please log in to perform this action.");
            out.print(json);
            out.flush();
            return;
        }

        String action = request.getParameter("action");
        String csrfToken = request.getParameter("csrfToken");
        String sessionCsrfToken = (String) session.getAttribute("csrfToken");
        if (csrfToken == null || !csrfToken.equals(sessionCsrfToken)) {
            LOGGER.log(Level.WARNING, "Invalid CSRF token for userId {0}. Received={1}, Expected={2}",
                    new Object[]{userId, csrfToken, sessionCsrfToken});
            json.put("success", false);
            json.put("message", "Invalid CSRF token.");
            out.print(json);
            out.flush();
            return;
        }

        try {
            long customerId = cartItemDAO.getCustomerIdByUserId(userId);

            if ("add".equals(action)) {
                long variantId = Long.parseLong(request.getParameter("variantId"));
                int quantity = Integer.parseInt(request.getParameter("quantity"));
                if (quantity < 1) {
                    json.put("success", false);
                    json.put("message", "Invalid quantity.");
                } else {
                    boolean success = cartItemDAO.addToCart(customerId, variantId, quantity);
                    if (success) {
                        int newCount = cartItemDAO.getCartItemCount(customerId);
                        json.put("success", true);
                        json.put("message", "Product added to cart successfully.");
                        json.put("cartCount", newCount);
                    } else {
                        json.put("success", false);
                        json.put("message", "Failed to add to cart: Out of stock or invalid request.");
                    }
                }

            } else if ("update".equals(action)) {
                long cartItemId = Long.parseLong(request.getParameter("cartItemId"));
                int quantity = Integer.parseInt(request.getParameter("quantity"));
                if (quantity < 1) {
                    json.put("success", false);
                    json.put("message", "Invalid quantity.");
                } else {
                    // Truyền customerId theo DAO đã update (cartItemId, customerId, quantity)
                    boolean success = cartItemDAO.updateCartItem(cartItemId, customerId, quantity);
                    if (success) {
                        int newCount = cartItemDAO.getCartItemCount(customerId);
                        json.put("success", true);
                        json.put("message", "Cart updated successfully.");
                        json.put("cartCount", newCount);
                    } else {
                        json.put("success", false);
                        json.put("message", "Failed to update cart: Out of stock or invalid request.");
                    }
                }

            } else if ("remove".equals(action)) {
                long cartItemId = Long.parseLong(request.getParameter("cartItemId"));
                // Truyền customerId theo DAO đã update (cartItemId, customerId)
                boolean success = cartItemDAO.removeCartItem(cartItemId, customerId);
                if (success) {
                    int newCount = cartItemDAO.getCartItemCount(customerId);
                    json.put("success", true);
                    json.put("message", "Item removed from cart successfully.");
                    json.put("cartCount", newCount);
                } else {
                    json.put("success", false);
                    json.put("message", "Failed to remove item.");
                }

            } else {
                json.put("success", false);
                json.put("message", "Invalid action.");
            }

            out.print(json);
            out.flush();

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error processing cart action for userId=" + userId, e);
            json.put("success", false);
            json.put("message", "Database error: " + e.getMessage());
            out.print(json);
            out.flush();
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Invalid input data for userId=" + userId, e);
            json.put("success", false);
            json.put("message", "Invalid input data.");
            out.print(json);
            out.flush();
        }
    }

    private void handleCartCount(HttpServletRequest request, HttpServletResponse response, Long userId)
            throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        JSONObject json = new JSONObject();
        try ( PrintWriter out = response.getWriter()) {
            if (userId == null) {
                // Guest -> 0
                json.put("count", 0);
            } else {
                long customerId = cartItemDAO.getCustomerIdByUserId(userId);
                int count = cartItemDAO.getCartItemCount(customerId);
                json.put("count", count);
            }
            out.print(json);
            out.flush();
        } catch (SQLException e) {
            Logger.getLogger(CartController.class.getName()).log(Level.SEVERE, "Error counting cart items", e);
            try ( PrintWriter out = response.getWriter()) {
                json.put("count", 0);
                out.print(json);
                out.flush();
            }
        }
    }
}
