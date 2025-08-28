/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller.admin;

import dao.StaffDAO;
import dao.StaffDAO.StaffInfo;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

/**
 *
 * @author Khoa
 */
@WebServlet(name="EditStaffController", urlPatterns={"/EditStaff"})
public class EditStaffController extends HttpServlet {
   
    /** 
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code> methods.
     * @param request servletRequest
     * @param response servletResponse
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");

        
        jakarta.servlet.http.HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("admin") == null) {
            response.sendRedirect(request.getContextPath() + "/AdminLogin");
            return;
        }

        String method = request.getMethod();
        StaffDAO dao = new StaffDAO();

        if (method.equalsIgnoreCase("GET")) {
            try {
                long userId = Long.parseLong(request.getParameter("userId"));
                StaffInfo info = dao.getStaffInfoByUserId(userId);
                request.setAttribute("staffInfo", info);
                request.getRequestDispatcher("/WEB-INF/views/admin/mangestaff/staff-edit.jsp").forward(request, response);
            } catch (Exception e) {
                response.sendRedirect("StaffManagement?errorMessage=Invalid+staff+ID");
            }
        } else if (method.equalsIgnoreCase("POST")) {
            long userId = Long.parseLong(request.getParameter("userId"));
            String fullName = request.getParameter("fullName");
            String phoneNumber = request.getParameter("phoneNumber");
            String status = request.getParameter("status");
            String position = request.getParameter("position");
            String notes = request.getParameter("notes");

            // Validation
            if (fullName == null || fullName.trim().isEmpty()
                    || phoneNumber == null || !phoneNumber.matches("\\d{10}")
                    || status == null || status.trim().isEmpty()
                    || position == null || position.trim().isEmpty()) {
                response.sendRedirect("EditStaff?userId=" + userId + "&errorMessage=Please+fill+all+fields+correctly");
                return;
            }

            boolean updated = dao.updateStaff(userId, fullName, phoneNumber, status, position, notes);
            if (updated) {
                response.sendRedirect("StaffManagement?successMessage=Staff+updated+successfully");
            } else {
                response.sendRedirect("EditStaff?userId=" + userId + "&errorMessage=Failed+to+update+staff");
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
        return "Short description";
    }// </editor-fold>

}
