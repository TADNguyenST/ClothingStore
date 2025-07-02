/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
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
@WebServlet(name="VerifyOTPController", urlPatterns={"/VerifyOTP"})
public class VerifyOTPController extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            HttpSession session = request.getSession();
            Object otpObject = session.getAttribute("otp");
            Object userObject = session.getAttribute("registerUser");
            Object customerObject = session.getAttribute("registerCustomer");

            String enteredOtpStr = request.getParameter("otp");

            if (otpObject == null || userObject == null || customerObject == null || enteredOtpStr == null) {
                request.setAttribute("error", "OTP session expired or invalid input.");
                request.getRequestDispatcher("/WEB-INF/views/auth/verify-otp.jsp").forward(request, response);
                return;
            }

            int expectedOtp = (otpObject instanceof Integer) ? (Integer) otpObject : Integer.parseInt(otpObject.toString());

            if (!enteredOtpStr.matches("\\d+")) {
                request.setAttribute("error", "OTP must be a number.");
                request.getRequestDispatcher("/WEB-INF/views/auth/verify-otp.jsp").forward(request, response);
                return;
            }

            int enteredOtp = Integer.parseInt(enteredOtpStr);

            if (enteredOtp == expectedOtp) {
                Users u = (Users) userObject;
                Customer c = (Customer) customerObject;

                UserDAO dao = new UserDAO();
                boolean success = dao.registerCustomer(u, c);

                if (success) {
                    session.removeAttribute("otp");
                    session.removeAttribute("registerUser");
                    session.removeAttribute("registerCustomer");
                    request.setAttribute("success", "Verification successful! Registration completed.");
                } else {
                    request.setAttribute("error", "An error occurred while saving user information.");
                }
            } else {
                request.setAttribute("error", "Invalid OTP code.");
            }

            request.getRequestDispatcher("/WEB-INF/views/auth/verify-otp.jsp").forward(request, response);
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
        return "VerifyOTP to mail";
    }
}

