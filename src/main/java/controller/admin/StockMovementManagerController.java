/*
 * Click nbproject://SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbproject://SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.admin;

import dao.StockMovementDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.List;
import model.StockMovement;

/**
 *
 * @author DANGVUONGTHINH
 */
@WebServlet(name = "StockMovementManagerController", urlPatterns = {"/StockMovementManager"})
public class StockMovementManagerController extends HttpServlet {

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
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet StockMovementManagerServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet StockMovementManagerServlet at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
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
        StockMovementDAO dao = new StockMovementDAO();

        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        if (action.equalsIgnoreCase("list")) {
            List<StockMovement> listStockMovement = dao.getAll();
            request.setAttribute("listStockMovement", listStockMovement);
            request.getRequestDispatcher("/StockMovementManager/listStockMovement.jsp").forward(request, response);
        } else if (action.equalsIgnoreCase("update")) {
            String id = request.getParameter("id");
            int movementId = (id != null && id.matches("\\d+")) ? Integer.parseInt(id) : -1;

            if (movementId != -1) {
                StockMovement movement = dao.getStockMovementById(movementId); // Changed from long to int
                if (movement != null) {
                    request.setAttribute("movement", movement);
                    request.getRequestDispatcher("/StockMovementManager/editStockMovement.jsp").forward(request, response);
                } else {
                    request.setAttribute("errorMessage", "Stock movement does not exist!");
                    request.getRequestDispatcher("/StockMovementManager/error.jsp").forward(request, response);
                }
            } else {
                response.sendRedirect("errorPage.jsp?message=Invalid ID");
            }
        }
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
        return "Short description";
    }
    // </editor-fold>
}