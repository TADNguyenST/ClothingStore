/*
 * Click nbfs://nbhost/SystemFileTemplates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileTemplates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.auth;

import dao.UserDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Customer;
import model.Users;

/**
 *
 * @author Khoa
 */
@WebServlet(name = "VerifyOTPController", urlPatterns = {"/VerifyOTP"})
public class VerifyOTPController extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code> methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {

            HttpSession session    = request.getSession();
            Object otpObj          = session.getAttribute("otp");
            String purpose         = (String) session.getAttribute("otpPurpose"); // register | forgot
            Object userObj         = session.getAttribute("registerUser");
            Object customerObj     = session.getAttribute("registerCustomer");
            String enteredOtpStr   = request.getParameter("otp");

            /* ----------- DEBUG console ----------- */
            System.out.println("DEBUG - OTP: " + otpObj);
            System.out.println("DEBUG - Purpose: " + purpose);
            System.out.println("DEBUG - User: " + userObj);
            System.out.println("DEBUG - Customer: " + customerObj);

            /* ----------- Kiểm tra input ----------- */
            if (otpObj == null || enteredOtpStr == null) {
                request.setAttribute("error", "OTP session expired or invalid input.");
                request.getRequestDispatcher("/WEB-INF/views/auth/verify-otp.jsp").forward(request, response);
                return;
            }

            if (!enteredOtpStr.matches("\\d{6}")) {
                request.setAttribute("error", "OTP must be a 6-digit number.");
                request.getRequestDispatcher("/WEB-INF/views/auth/verify-otp.jsp").forward(request, response);
                return;
            }

            String expectedOtp = otpObj.toString();
            String enteredOtp  = enteredOtpStr.trim();

            if (!enteredOtp.equals(expectedOtp)) {
                request.setAttribute("error", "Invalid OTP code.");
                request.getRequestDispatcher("/WEB-INF/views/auth/verify-otp.jsp").forward(request, response);
                return;
            }

            /* ----------- Nếu là ĐĂNG KÝ ----------- */
            if (purpose == null || "register".equals(purpose)) {
                Users u = (Users) userObj;
                Customer c = (Customer) customerObj;

                if (u == null) {
                    request.setAttribute("error", "Missing registration user data.");
                } else {
                    UserDAO dao = new UserDAO();
                    boolean success = false;
                    try {
                        success = dao.registerCustomer(u, c);
                    } catch (Exception ex) {
                        ex.printStackTrace();
                        request.setAttribute("error", "Exception while saving user info.");
                    }

                    if (success) {
                        session.removeAttribute("registerUser");
                        session.removeAttribute("registerCustomer");
                        request.setAttribute("success", "Verification successful! Registration completed.");
                    } else {
                        request.setAttribute("error", "Failed to register user. Check server logs.");
                    }
                }

                // Clean OTP session
                session.removeAttribute("otp");
                session.removeAttribute("otpPurpose");

                request.getRequestDispatcher("/WEB-INF/views/auth/verify-otp.jsp").forward(request, response);
                return;
            }

            /* ----------- Nếu là QUÊN MẬT KHẨU ----------- */
            if ("forgot".equals(purpose)) {
                String email = (String) session.getAttribute("emailForgot");

                session.removeAttribute("otp");
                session.removeAttribute("otpPurpose");
                session.setAttribute("verifiedEmail", email);

                response.sendRedirect("ResetPassword");
                return;
            }

            /* ----------- Purpose không hợp lệ ----------- */
            request.setAttribute("error", "Unknown OTP purpose.");
            request.getRequestDispatcher("/WEB-INF/views/auth/verify-otp.jsp").forward(request, response);
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/auth/verify-otp.jsp").forward(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
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
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "VerifyOTP to mail";
    }// </editor-fold>

}
