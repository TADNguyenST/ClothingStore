/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.auth;

import dao.ProductDAO;
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
import model.Product;

/**
 * Handles logic for the homepage. This version generates mock data to run
 * independently.
 */
public class HomepageController extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ... Toàn bộ nội dung của phương thức doGet giữ nguyên như cũ ...
        try {
            List<Product> newArrivals = productDAO.getNewArrivals(8);
            List<Product> bestSellers = productDAO.getBestSellers(4);

            request.setAttribute("newProducts", newArrivals);
            request.setAttribute("bestSellers", bestSellers);
            request.setAttribute("pageTitle", "Homepage");

            request.getRequestDispatcher("/WEB-INF/views/public/home.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "An error occurred while loading the homepage.");
        }
    }
}
