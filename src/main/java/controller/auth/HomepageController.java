package controller.auth;

import dao.ProductDAO;
import java.io.IOException;
import java.util.List;
import model.Product;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class HomepageController extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
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