package controller.admin;

import dao.BrandDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import model.Brand;
import model.Users;

@WebServlet(name = "BrandListAdminFilterController", urlPatterns = {"/BrandListAdminFilter"})
public class BrandListAdminFilterController extends HttpServlet {
    private final BrandDAO brandDAO = new BrandDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Users currentUser = (Users) session.getAttribute("admin");
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/AdminLogin");
            return;
        }

        try {
            String keyword = request.getParameter("keyword");
            String filter = request.getParameter("filter");

            List<Brand> brands = brandDAO.searchBrandsByName(keyword, filter != null ? filter : "All");
            for (Brand brand : brands) {
            }
            request.setAttribute("brands", brands != null ? brands : new ArrayList<>());
            request.setAttribute("currentModule", "brand");
            request.setAttribute("currentAction", "brands");
            request.getRequestDispatcher("/WEB-INF/views/admin/brand/brands.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("err", "<p class='text-danger'>Error loading brands: " + e.getMessage() + "</p>");
            request.setAttribute("brands", new ArrayList<>());
            request.setAttribute("currentModule", "brand");
            request.setAttribute("currentAction", "brands");
            request.getRequestDispatcher("/WEB-INF/views/admin/brand/brands.jsp").forward(request, response);
        }
    }

    @Override
    public String getServletInfo() {
        return "Servlet for filtering brands by name and status";
    }
}