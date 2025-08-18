package controller.auth;

import dao.UserDAO;
import dao.CustomerDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.Users;
import model.Customer;

@WebServlet(name = "LoginController", urlPatterns = {"/Login"})
public class LoginController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(LoginController.class.getName());

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        String method = request.getMethod();
        if ("GET".equalsIgnoreCase(method)) {
            String redirectTo = request.getParameter("redirectTo");
            if (redirectTo != null && !redirectTo.isEmpty()) {
                HttpSession session = request.getSession();
                session.setAttribute("redirectAfterLogin", redirectTo);
            }
            request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
            return;
        }

        String email = request.getParameter("email");
        String password = request.getParameter("password");
        if (email == null || email.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "Email and password cannot be empty.");
            request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
            return;
        }

        UserDAO dao = new UserDAO();
        Users user = dao.checkLogin(email, password);
        if (user != null && "Customer".equalsIgnoreCase(user.getRole()) && "Active".equalsIgnoreCase(user.getStatus())) {
            HttpSession session = request.getSession();
            session.setAttribute("user", user);
            session.setAttribute("userId", user.getUserId());
            // Create and store CSRF token
            String csrfToken = UUID.randomUUID().toString();
            session.setAttribute("csrfToken", csrfToken);
            LOGGER.log(Level.INFO, "CSRF Token set for userId " + user.getUserId() + ": " + csrfToken);

            CustomerDAO customerDAO = new CustomerDAO();
            Customer customer = customerDAO.getCustomerByUserId(user.getUserId());
            if (customer != null) {
                // Skip guest cart merging
            }

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
