/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.customer;

import dao.CustomerDAO;
import java.io.IOException;
import java.sql.Date;
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
@WebServlet(name = "EditProfileController", urlPatterns = {"/customer/edit-profile"})
public class EditProfileController extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");

        HttpSession session = request.getSession(false);
        Users user = (Users) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect("Login");
            return;
        }

        CustomerDAO dao = new CustomerDAO();

        if (request.getMethod().equalsIgnoreCase("GET")) {
            Users userInfo = dao.getUserById(user.getUserId());
            Customer customerInfo = dao.getCustomerByUserId(user.getUserId());
            request.setAttribute("user", userInfo);
            request.setAttribute("customer", customerInfo);
            request.getRequestDispatcher("/WEB-INF/views/customer/profile/edit-profile.jsp").forward(request, response);
        } else if (request.getMethod().equalsIgnoreCase("POST")) {
            String fullName = request.getParameter("fullName");
            String phoneNumber = request.getParameter("phoneNumber");
            String gender = request.getParameter("gender");
            String birthDateStr = request.getParameter("birthDate");

            // Kiểm tra số điện thoại
            if (phoneNumber == null || !phoneNumber.matches("\\d{10}")) {
                request.setAttribute("error", "Phone number must be exactly 10 digits and contain only numbers.");
                request.setAttribute("user", dao.getUserById(user.getUserId()));
                request.setAttribute("customer", dao.getCustomerByUserId(user.getUserId()));
                request.getRequestDispatcher("/WEB-INF/views/customer/profile/edit-profile.jsp").forward(request, response);
                return;
            }

            // Cập nhật model
            user.setFullName(fullName);
            user.setPhoneNumber(phoneNumber);

            Customer customer = new Customer();
            customer.setUserId(user.getUserId());
            customer.setGender(gender);
            customer.setBirthDate(
                    birthDateStr == null || birthDateStr.isEmpty() ? null : Date.valueOf(birthDateStr)
            );

            boolean updated = dao.updateCustomerProfile(user, customer);

            if (updated) {
                request.setAttribute("success", "Profile updated successfully.");
            } else {
                request.setAttribute("error", "Failed to update profile.");
            }

            request.setAttribute("user", dao.getUserById(user.getUserId()));
            request.setAttribute("customer", dao.getCustomerByUserId(user.getUserId()));
            request.getRequestDispatcher("/WEB-INF/views/customer/profile/edit-profile.jsp").forward(request, response);
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
        processRequest(request, response);
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
        return "Edit Profile";
    }// </editor-fold>

}
