package controller.auth;

import dao.UserDAO;
import dao.CustomerDAO;
import dao.CartItemDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.Users;
import model.CartItem;
import model.Customer;

@WebServlet(name = "LoginController", urlPatterns = {"/Login"})
public class LoginController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(LoginController.class.getName());

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");

        String method = request.getMethod();
        if ("GET".equalsIgnoreCase(method)) {
            // Nếu người dùng đến từ trang yêu cầu đăng nhập (ví dụ: wishlist)
            String redirectTo = request.getParameter("redirectTo");
            if (redirectTo != null && !redirectTo.isEmpty()) {
                HttpSession session = request.getSession();
                session.setAttribute("redirectAfterLogin", redirectTo);
            }

            request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
            return;
        }

        // POST - xử lý đăng nhập
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if (email == null || email.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "Email and password cannot be empty.");
            request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
            return;
        }

        UserDAO dao = new UserDAO();
        Users user = dao.checkLogin(email, password); // Giả định password đã mã hoá ở DAO

        if (user != null && "Customer".equalsIgnoreCase(user.getRole()) && "Active".equalsIgnoreCase(user.getStatus())) {
            HttpSession session = request.getSession();
            session.setAttribute("user", user);
            session.setAttribute("userId", user.getUserId()); // dùng để check login ở các controller khác

            // FIXED: Merge guest cart if exists
            CustomerDAO customerDAO = new CustomerDAO();
            Customer customer = customerDAO.getCustomerByUserId(user.getUserId());
            if (customer != null) {
                long customerId = customer.getCustomerId();
                Map<Long, CartItem> sessionCart = (Map<Long, CartItem>) session.getAttribute("sessionCart");
                if (sessionCart != null && !sessionCart.isEmpty()) {
                    CartItemDAO cartItemDAO = new CartItemDAO();
                    for (CartItem item : sessionCart.values()) {
                        try {
                            cartItemDAO.addToCart(customerId, item.getVariantId(), item.getQuantity());
                        } catch (Exception e) {
                            LOGGER.log(Level.WARNING, "Failed to merge cart item for variantId: " + item.getVariantId(), e);
                        }
                    }
                    session.removeAttribute("sessionCart");
                }
            }

            // Quay lại trang ban đầu nếu có
            String redirectTo = (String) session.getAttribute("redirectAfterLogin");
            if (redirectTo != null && !redirectTo.isEmpty()) {
                session.removeAttribute("redirectAfterLogin");
                response.sendRedirect(redirectTo);
            } else {
                response.sendRedirect(request.getContextPath() + "/home");
            }
        } else {
            request.setAttribute("error", "Invalid credentials or not a Customer account.");
            request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    public String getServletInfo() {
        return "LoginController handles authentication and redirect logic.";
    }
}
