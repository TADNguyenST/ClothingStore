/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.auth;

import dao.UserDAO;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Date;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Customer;
import model.Users;

@WebServlet(name = "RegisterController", urlPatterns = {"/Register"})
public class RegisterController extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");

        String method = request.getMethod();
        if (method.equalsIgnoreCase("GET")) {
            request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
        } else if (method.equalsIgnoreCase("POST")) {
            String fullName = request.getParameter("fullName");
            String email = request.getParameter("email");
            String password = request.getParameter("password");
            String confirmPassword = request.getParameter("confirmPassword");
            String phoneNumber = request.getParameter("phoneNumber");
            String gender = request.getParameter("gender");
            String birthDateStr = request.getParameter("birthDate");

            // Kiểm tra rỗng
            if (fullName == null || email == null || password == null || confirmPassword == null || phoneNumber == null
                    || fullName.isEmpty() || email.isEmpty() || password.isEmpty() || confirmPassword.isEmpty() || phoneNumber.isEmpty()) {
                request.setAttribute("error", "All fields must be filled.");
                request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
                return;
            }

            // Kiểm tra định dạng email
            if (!email.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
                request.setAttribute("error", "Invalid email format.");
                request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
                return;
            }

            // Kiểm tra mật khẩu
            if (!password.matches("^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z]).{8,}$")) {
                request.setAttribute("error", "Password must be at least 8 characters, contain uppercase, lowercase, and number.");
                request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
                return;
            }

            // Kiểm tra confirmPassword
            if (!password.equals(confirmPassword)) {
                request.setAttribute("error", "Passwords do not match.");
                request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
                return;
            }

            // Kiểm tra số điện thoại là số và đúng 10 số
            if (!phoneNumber.matches("\\d{10}")) {
                request.setAttribute("error", "Phone number must be 10 digits.");
                request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
                return;
            }

            // Kiểm tra email tồn tại
            UserDAO dao = new UserDAO();
            if (dao.checkEmailExists(email)) {
                request.setAttribute("error", "Email already exists.");
                request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
                return;
            }

            // Nếu không lỗi -> tạo user & customer
            Users user = new Users();
            user.setEmail(email);
            user.setPassword(password); // KHÔNG mã hóa
            user.setFullName(fullName);
            user.setPhoneNumber(phoneNumber);

            Customer customer = new Customer();
            customer.setGender(gender);
            customer.setBirthDate(birthDateStr == null || birthDateStr.isEmpty() ? null : Date.valueOf(birthDateStr));

            boolean registered = dao.registerCustomer(user, customer);

            if (registered) {
                request.setAttribute("success", "Registration successful! Please login.");
            } else {
                request.setAttribute("error", "Registration failed. Try again.");
            }

            request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
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
        return "Short description";
    }
}
