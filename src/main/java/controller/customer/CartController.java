/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.customer;

import dao.CartItemDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.math.BigDecimal;
import java.util.List;
import model.CartItem;
import model.Users;

/**
 *
 * @author Lenovo
 */
@WebServlet(name = "CartController", urlPatterns = {"/customer/cart"})
public class CartController extends HttpServlet {

    private final CartItemDAO cartItemDAO = new CartItemDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Users user = (session != null) ? (Users) session.getAttribute("user") : null;

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Mặc định action là 'view' để hiển thị giỏ hàng
        viewCart(request, response, user);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Users user = (session != null) ? (Users) session.getAttribute("user") : null;

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/customer/cart");
            return;
        }

        switch (action) {
            case "add":
                addToCart(request, response, user);
                break;
            case "update":
                updateCart(request, response, user);
                break;
            case "remove":
                removeFromCart(request, response, user);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/customer/cart");
                break;
        }
    }

    private void viewCart(HttpServletRequest request, HttpServletResponse response, Users user)
            throws ServletException, IOException {

        // Giả sử Khoa đã có CustomerDAO
        // long customerId = customerDAO.getCustomerByUserId(user.getUserId()).getCustomerId();
        long customerId = user.getUserId(); // Tạm thời dùng userId làm customerId để test

        List<CartItem> cartItems = cartItemDAO.getCartItemsByCustomerId(customerId);

        // Tính tổng tiền
        BigDecimal subtotal = BigDecimal.ZERO;
        for (CartItem item : cartItems) {
            subtotal = subtotal.add(item.getTotalPrice());
        }

        request.setAttribute("cartItems", cartItems);
        request.setAttribute("subtotal", subtotal);

        request.getRequestDispatcher("/WEB-INF/views/customer/cart/cart.jsp").forward(request, response);
    }

    private void addToCart(HttpServletRequest request, HttpServletResponse response, Users user)
            throws IOException {
        try {
            long variantId = Long.parseLong(request.getParameter("variantId"));
            int quantity = Integer.parseInt(request.getParameter("quantity"));
            long customerId = user.getUserId(); // Tạm thời dùng userId làm customerId

            if (quantity > 0) {
                cartItemDAO.addToCart(customerId, variantId, quantity);
            }
            // Chuyển hướng về trang giỏ hàng để xem kết quả
            response.sendRedirect(request.getContextPath() + "/customer/cart");

        } catch (NumberFormatException e) {
            e.printStackTrace();
            // Quay lại trang trước đó nếu có lỗi
            response.sendRedirect(request.getHeader("Referer") + "?error=invalidInput");
        }
    }

    private void updateCart(HttpServletRequest request, HttpServletResponse response, Users user)
            throws IOException {
        try {
            long cartItemId = Long.parseLong(request.getParameter("cartItemId"));
            int quantity = Integer.parseInt(request.getParameter("quantity"));

            if (quantity > 0) {
                cartItemDAO.updateQuantity(cartItemId, quantity);
            } else {
                // Nếu số lượng <= 0 thì xóa luôn
                cartItemDAO.removeFromCart(cartItemId);
            }
            response.sendRedirect(request.getContextPath() + "/customer/cart");

        } catch (NumberFormatException e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/customer/cart?error=updateFailed");
        }
    }

    private void removeFromCart(HttpServletRequest request, HttpServletResponse response, Users user)
            throws IOException {
        try {
            long cartItemId = Long.parseLong(request.getParameter("cartItemId"));
            cartItemDAO.removeFromCart(cartItemId);
            response.sendRedirect(request.getContextPath() + "/customer/cart?status=removed");
        } catch (NumberFormatException e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/customer/cart?error=removeFailed");
        }
    }
}
