/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller.admin;

import dao.StaffDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Staff;
import model.Users;

/**
 *
 * @author Khoa
 */
@WebServlet(name="CreateAccountController", urlPatterns={"/CreateAccount"})
public class CreateAccountController extends HttpServlet {

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

        // 🔒 Kiểm tra session admin
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("admin") == null) {
            response.sendRedirect(request.getContextPath() + "/AdminLogin");
            return;
        }

        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet CreateAccountController</title>");  
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet CreateAccountController at " + request.getContextPath () + "</h1>");
            out.println("</body>");
            out.println("</html>");
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
        // 🔒 Kiểm tra session admin
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("admin") == null) {
            response.sendRedirect(request.getContextPath() + "/AdminLogin");
            return;
        }

        // Gọi form để nhập tài khoản nhân viên
        request.getRequestDispatcher("/WEB-INF/views/admin/mangestaff/staff-form.jsp").forward(request, response);
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
        // 🔒 Kiểm tra session admin
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("admin") == null) {
            response.sendRedirect(request.getContextPath() + "/AdminLogin");
            return;
        }

        // Xử lý tạo tài khoản nhân viên
        request.setCharacterEncoding("UTF-8");

        String email = request.getParameter("email");
        String fullName = request.getParameter("fullName");
        String phoneNumber = request.getParameter("phoneNumber");
        String position = request.getParameter("position");
        String notes = request.getParameter("notes");

        String errorMessage = null;

        if (email == null || email.isEmpty() ||
            fullName == null || fullName.isEmpty() ||
            phoneNumber == null || phoneNumber.isEmpty() ||
            position == null || position.isEmpty()) {
            errorMessage = "All fields are required.";
        } else if (!email.matches("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}$")) {
            errorMessage = "Invalid email format.";
        } else if (!phoneNumber.matches("\\d{10}")) {
            errorMessage = "Phone number must be 10 digits and contain only numbers.";
        } else {
            StaffDAO dao = new StaffDAO();
            if (dao.isEmailExists(email)) {
                errorMessage = "Email already exists.";
            }
        }

        if (errorMessage != null) {
            request.setAttribute("errorMessage", errorMessage);
            request.setAttribute("email", email);
            request.setAttribute("fullName", fullName);
            request.setAttribute("phoneNumber", phoneNumber);
            request.setAttribute("position", position);
            request.setAttribute("notes", notes);
            request.getRequestDispatcher("/WEB-INF/views/admin/mangestaff/staff-form.jsp").forward(request, response);
            return;
        }

        Users user = new Users();
        user.setEmail(email);
        user.setPassword(null); // <-- luôn để null
        user.setFullName(fullName);
        user.setPhoneNumber(phoneNumber);

        Staff staff = new Staff();
        staff.setPosition(position);
        staff.setNotes(notes);

        StaffDAO dao = new StaffDAO();
        boolean success = dao.createStaffAccount(user, staff);

        if (success) {
            response.sendRedirect("StaffManagement?successMessage=Account created successfully");
        } else {
            request.setAttribute("errorMessage", "Failed to create account");
            request.getRequestDispatcher("/WEB-INF/views/admin/mangestaff/staff-form.jsp").forward(request, response);
        }
    }

    /** 
     * Returns a short description of the servlet.
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
