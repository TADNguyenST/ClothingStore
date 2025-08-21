package controller.admin;

import dao.CategoryDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.Category;
import model.Users;

@WebServlet(name = "CategoryDetailAdminController", urlPatterns = {"/CategoryDetailAdmin"})
public class CategoryDetailAdminController extends HttpServlet {
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
            long id = Long.parseLong(request.getParameter("id"));
            Category category = categoryDAO.getCategoryById(id);
            if (category == null) {
                request.setAttribute("err", "<p class='text-danger'>Category not found</p>");
                request.setAttribute("categories", categoryDAO.getAllCategories());
                request.getRequestDispatcher("/WEB-INF/views/admin/category/categories.jsp").forward(request, response);
            } else {
                request.setAttribute("category", category);
                request.setAttribute("categories", categoryDAO.getAllCategories());
                request.getRequestDispatcher("/WEB-INF/views/admin/category/detailCategory.jsp").forward(request, response);
            }
        } catch (NumberFormatException e) {
            request.setAttribute("err", "<p class='text-danger'>Invalid category ID</p>");
            request.setAttribute("categories", categoryDAO.getAllCategories());
            request.getRequestDispatcher("/WEB-INF/views/admin/category/categories.jsp").forward(request, response);
        }
    }

    @Override
    public String getServletInfo() {
        return "Servlet for viewing category details";
    }
}