/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.auth;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Handles logic for the homepage. This version generates mock data to run
 * independently.
 */
public class HomepageController extends HttpServlet {

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
        try ( PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet HomepageController</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet HomepageController at " + request.getContextPath() + "</h1>");
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
        try {
            // Generate mock data for different sections
            List<Map<String, Object>> newArrivals = createMockProductList(8, "New Arrival");
            List<Map<String, Object>> bestSellers = createMockProductList(4, "Best Seller");

            // Send data to the JSP
            request.setAttribute("newArrivals", newArrivals);
            request.setAttribute("bestSellers", bestSellers);

            request.getRequestDispatcher("/WEB-INF/views/public/home.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "An error occurred, please try again.");
        }
    }

    /**
     * Creates a mock list of products for UI testing.
     */
    private List<Map<String, Object>> createMockProductList(int count, String namePrefix) {
        List<Map<String, Object>> mockList = new ArrayList<>();
        String[] names = {"Classic T-Shirt", "Slim-fit Jeans", "Bomber Jacket", "Summer Dress"};
        String[] prices = {"250000", "750000", "990000", "650000"};

        for (int i = 0; i < count; i++) {
            Map<String, Object> p = new HashMap<>();
            p.put("productId", (i + 1) * 10);
            p.put("name", namePrefix + " - " + names[i % names.length]);
            p.put("price", new BigDecimal(prices[i % prices.length]));
            if (i % 2 == 0) {
                p.put("oldPrice", new BigDecimal(prices[i % prices.length]).add(new BigDecimal("100000")));
            }
            p.put("thumbnailUrl", "https://placehold.co/400x500/EFEFEF/AAAAAA?text=Product");
            mockList.add(p);
        }
        return mockList;
    }
}
