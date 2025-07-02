/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller.auth;

import dao.UserDAO;
import java.io.IOException;
import java.sql.Date;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.Period;
import java.util.Random;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Customer;
import model.Users;
import util.EmailUtil;

/**
 *
 * @author Khoa
 */
@WebServlet(name = "RegisterController", urlPatterns = {"/Register"})
public class RegisterController extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code> methods.
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
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

            if (fullName == null || email == null || password == null || confirmPassword == null || phoneNumber == null
                    || fullName.isEmpty() || email.isEmpty() || password.isEmpty() || confirmPassword.isEmpty() || phoneNumber.isEmpty()) {
                request.setAttribute("error", "All fields must be filled.");
                request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
                return;
            }

            if (!email.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
                request.setAttribute("error", "Invalid email format.");
                request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
                return;
            }

            if (!password.matches("^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z]).{8,}$")) {
                request.setAttribute("error", "Password must be at least 8 characters, contain uppercase, lowercase, and number.");
                request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
                return;
            }

            if (!password.equals(confirmPassword)) {
                request.setAttribute("error", "Passwords do not match.");
                request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
                return;
            }

            if (!phoneNumber.matches("\\d{10}")) {
                request.setAttribute("error", "Phone number must be 10 digits.");
                request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
                return;
            }

            Date sqlBirthDate = null;
            if (birthDateStr == null || birthDateStr.trim().isEmpty()) {
                request.setAttribute("error", "Birth date is required.");
                request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
                return;
            } else {
                try {
                    // Try to parse both formats
                    java.util.Date parsedDate;
                    if (birthDateStr.contains("/")) {
                        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
                        sdf.setLenient(false);
                        parsedDate = sdf.parse(birthDateStr);
                    } else {
                        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                        sdf.setLenient(false);
                        parsedDate = sdf.parse(birthDateStr);
                    }

                    LocalDate birthDate = new java.sql.Date(parsedDate.getTime()).toLocalDate();
                    LocalDate today = LocalDate.now();
                    int age = Period.between(birthDate, today).getYears();

                    if (birthDate.isAfter(today)) {
                        request.setAttribute("error", "Birth date cannot be in the future.");
                        request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
                        return;
                    }

                    if (age < 13) {
                        request.setAttribute("error", "Minimum age is 13.");
                        request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
                        return;
                    }

                    if (age > 120) {
                        request.setAttribute("error", "Maximum age allowed is 120.");
                        request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
                        return;
                    }

                    sqlBirthDate = new java.sql.Date(parsedDate.getTime());
                } catch (ParseException e) {
                    request.setAttribute("error", "Invalid birth date format. Use YYYY-MM-DD or DD/MM/YYYY.");
                    request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
                    return;
                }
            }

            UserDAO dao = new UserDAO();
            if (dao.checkEmailExists(email)) {
                request.setAttribute("error", "Email already exists.");
                request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
                return;
            }

            Random random = new Random();
            int otp = 100000 + random.nextInt(900000);

            boolean emailSent = EmailUtil.sendEmail(email, "Authentication OTP",
                    "Your OTP code is: <strong>" + otp + "</strong>. Please do not share this code with anyone.");

            if (emailSent) {
                HttpSession session = request.getSession();

                Users user = new Users();
                user.setEmail(email);
                user.setPassword(password); // Không mã hóa theo yêu cầu
                user.setFullName(fullName);
                user.setPhoneNumber(phoneNumber);

                Customer customer = new Customer();
                customer.setGender(gender);
                customer.setBirthDate(sqlBirthDate);

                session.setAttribute("otp", otp);
                session.setAttribute("registerUser", user);
                session.setAttribute("registerCustomer", customer);

                request.getRequestDispatcher("/WEB-INF/views/auth/verify-otp.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "Unable to send encrypted OTP. Please try again later.");
                request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
            }
        }
    } 

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        processRequest(request, response);
    } 

    /**
     * Handles the HTTP <code>POST</code> method.
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Returns a short description of the servlet.
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "RegisterController for User";
    }// </editor-fold>

}
