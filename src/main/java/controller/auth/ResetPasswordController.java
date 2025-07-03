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
import model.Users;
import util.PasswordUtil;

/**
 *
 * @author Khoa
 */
@WebServlet(name="ResetPasswordController", urlPatterns={"/ResetPassword"})
public class ResetPasswordController extends HttpServlet {
   
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
        HttpSession session = request.getSession();
        String verifiedEmail = (String) session.getAttribute("verifiedEmail");   // set in VerifyOTPController
        String method = request.getMethod();
        
        if (verifiedEmail == null) {      // no email verified → redirect to login
            response.sendRedirect(request.getContextPath() + "/Login");
            return;
        }
        
        // If POST: handle password change
        if ("POST".equalsIgnoreCase(method)) {
            String pass1 = request.getParameter("password");
            String pass2 = request.getParameter("confirm");
            
            if (pass1 == null || pass2 == null || !pass1.equals(pass2)) {
                request.setAttribute("error", "Password confirmation does not match.");
                request.getRequestDispatcher("/WEB-INF/views/auth/reset-password.jsp").forward(request, response);
                return;
            }

            // Kiểm tra điều kiện mật khẩu: ít nhất 8 ký tự, 1 chữ hoa, 1 chữ thường, 1 số
            String passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{8,}$";
            if (!pass1.matches(passwordRegex)) {
                request.setAttribute("error", "Password must be at least 8 characters and include at least 1 uppercase letter, 1 lowercase letter, and 1 digit.");
                request.getRequestDispatcher("/WEB-INF/views/auth/reset-password.jsp").forward(request, response);
                return;
            }

            UserDAO dao = new UserDAO();
            Users u = dao.getUserByEmail(verifiedEmail);
            if (u == null) {
                // Edge‑case: account removed after OTP
                response.sendRedirect(request.getContextPath() + "/Login");
                return;
            }
            
            String hashedNew = PasswordUtil.hashPassword(pass1);
            if (hashedNew.equals(u.getPassword())) {
                request.setAttribute("error", "New password must differ from the current password.");
                request.getRequestDispatcher("/WEB-INF/views/auth/reset-password.jsp").forward(request, response);
                return;
            }
            
            boolean ok = dao.updatePassword(u.getUserId(), pass1);
            if (ok) request.setAttribute("success", "Password changed successfully.");
            else    request.setAttribute("error",   "Password change failed. Please try again.");
        }
        
        /* ------------------------------------------------------------------
           Render reset-password.jsp for both GET and POST
        ------------------------------------------------------------------ */
        request.getRequestDispatcher("/WEB-INF/views/auth/reset-password.jsp").forward(request, response);
        
        /* ------------------ NetBeans sample HTML (kept for template) ------------------ */
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet ResetPasswordController</title>");  
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ResetPasswordController at " + request.getContextPath () + "</h1>");
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
        return "Short description";
    }// </editor-fold>

}
