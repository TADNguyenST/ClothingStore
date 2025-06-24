package controller.customer;

import dao.CartItemDAO;
import dao.CustomerDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.CartItem;
import model.Customer;
import model.Users;

@WebServlet(name = "CartController", urlPatterns = {"/customer/cart"})
public class CartController extends HttpServlet {

    private final CartItemDAO cartItemDAO = new CartItemDAO();
    private final CustomerDAO customerDAO = new CustomerDAO();

    // Helper để lấy customerId, xử lý lỗi tập trung
    private long getCustomerId(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/Login");
            return -1;
        }

        Users user = (Users) session.getAttribute("user");
        Customer customer = customerDAO.getCustomerByUserId(user.getUserId());
        if (customer == null) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Customer data not found for the logged-in user.");
            return -1;
        }
        return customer.getCustomerId();
    }

    // GET request chỉ dùng để hiển thị giỏ hàng
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        long customerId = getCustomerId(request, response);
        if (customerId == -1) {
            return;
        }

        List<CartItem> cartItems = cartItemDAO.getCartItemsByCustomerId(customerId);
        BigDecimal subtotal = BigDecimal.ZERO;
        for (CartItem item : cartItems) {
            subtotal = subtotal.add(item.getTotalPrice());
        }

        request.setAttribute("cartItems", cartItems);
        request.setAttribute("subtotal", subtotal);
        request.setAttribute("pageTitle", "Shopping Cart");

        request.getRequestDispatcher("/WEB-INF/views/customer/cart/cart.jsp").forward(request, response);
    }

    // POST request xử lý các hành động: add, update, remove
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        long customerId = getCustomerId(request, response);
        if (customerId == -1) {
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/customer/cart");
            return;
        }

        String redirectURL = request.getContextPath() + "/customer/cart"; // Mặc định là về trang giỏ hàng

        try {
            switch (action) {
                case "add":
                    long variantId = Long.parseLong(request.getParameter("variantId"));
                    int addQuantity = Integer.parseInt(request.getParameter("quantity"));
                    if (addQuantity > 0) {
                        cartItemDAO.addToCart(customerId, variantId, addQuantity);
                        request.getSession().setAttribute("successMessage", "Product added to cart!");
                    }
                    // Khi thêm mới, quay lại trang trước đó
                    String referer = request.getHeader("Referer");
                    response.sendRedirect(referer != null ? referer : request.getContextPath() + "/home");
                    return; // Kết thúc sớm

                case "update":
                    long updateCartItemId = Long.parseLong(request.getParameter("cartItemId"));
                    int newQuantity = Integer.parseInt(request.getParameter("quantity"));
                    if (newQuantity > 0) {
                        cartItemDAO.updateQuantity(updateCartItemId, newQuantity);
                    } else {
                        // Nếu người dùng nhập số lượng <= 0, ta coi như họ muốn xóa
                        cartItemDAO.removeFromCart(updateCartItemId);
                    }
                    break;

                case "remove":
                    long removeCartItemId = Long.parseLong(request.getParameter("cartItemId"));
                    cartItemDAO.removeFromCart(removeCartItemId);
                    request.getSession().setAttribute("successMessage", "Item removed from cart.");
                    break;

                default:
                    // Hành động không xác định, không làm gì cả
                    break;
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("errorMessage", "Invalid input data.");
            Logger.getLogger(CartController.class.getName()).log(Level.WARNING, "Lỗi NumberFormatException trong CartController", e);
        } catch (Exception e) {
            request.getSession().setAttribute("errorMessage", "An unexpected error occurred.");
            Logger.getLogger(CartController.class.getName()).log(Level.SEVERE, "Lỗi không xác định trong CartController", e);
        }

        // Sau khi thực hiện update hoặc remove, redirect về trang giỏ hàng
        response.sendRedirect(redirectURL);
    }
}
