package controller.admin;

import dao.CategoryDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import model.Category;
import model.Users;

@WebServlet(name = "CategoryListAdminFilterController", urlPatterns = {"/CategoryListAdminFilter"})
public class CategoryListAdminFilterController extends HttpServlet {
    private final CategoryDAO categoryDAO = new CategoryDAO();

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

            List<Category> categories = categoryDAO.searchCategoriesByName(keyword, filter != null ? filter : "All");
            for (Category category : categories) {
            }
            request.setAttribute("categories", categories != null ? categories : new ArrayList<>());
            request.getRequestDispatcher("/WEB-INF/views/admin/category/categories.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("err", "Error loading categories: " + e.getMessage());
            request.setAttribute("categories", new ArrayList<>());
            request.getRequestDispatcher("/WEB-INF/views/admin/category/categories.jsp").forward(request, response);
        }
    }

    @Override
    public String getServletInfo() {
        return "Servlet for filtering categories by name and status";
    }
}