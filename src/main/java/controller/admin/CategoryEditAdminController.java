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

@WebServlet(name = "CategoryEditAdminController", urlPatterns = {"/CategoryEditAdmin"})
public class CategoryEditAdminController extends HttpServlet {
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
                request.getRequestDispatcher("/WEB-INF/views/admin/category/editCategory.jsp").forward(request, response);
            }
        } catch (NumberFormatException e) {
            request.setAttribute("err", "<p class='text-danger'>Invalid category ID</p>");
            request.setAttribute("categories", categoryDAO.getAllCategories());
            request.getRequestDispatcher("/WEB-INF/views/admin/category/categories.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Users currentUser = (Users) session.getAttribute("admin");
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/AdminLogin");
            return;
        }

        try {
            long id = Long.parseLong(request.getParameter("id"));
            String name = request.getParameter("name");
            String description = request.getParameter("description");
            String parentCategoryIdRaw = request.getParameter("parentCategoryId");
            Long parentCategoryId = parentCategoryIdRaw != null && !parentCategoryIdRaw.isEmpty()
                    ? Long.parseLong(parentCategoryIdRaw) : null;
            boolean isActive = request.getParameter("isActive") != null && request.getParameter("isActive").equals("true");
            if (name == null || name.trim().isEmpty()) {
                throw new IllegalArgumentException("Category name is required");
            }
            String normalizedName = name.trim().replaceAll("\\s+", " ").toLowerCase();
            if (categoryDAO.isCategoryExists(normalizedName, parentCategoryId, id)) {
                throw new IllegalArgumentException("Category name already exists under this parent category");
            }
            if (parentCategoryId != null && categoryDAO.getCategoryById(parentCategoryId) == null) {
                throw new IllegalArgumentException("Invalid Parent Category ID: " + parentCategoryId);
            }
            if (parentCategoryId != null && parentCategoryId == id) {
                throw new IllegalArgumentException("Category cannot be its own parent");
            }
            boolean result = categoryDAO.updateCategory(id, name, description, parentCategoryId, isActive);
            if (result) {
                request.getSession().setAttribute("msg", "Category updated successfully!");
                response.sendRedirect("CategoryListAdmin");
            } else {
                request.setAttribute("err", "<p class='text-danger'>Failed to update category</p>");
                request.setAttribute("category", categoryDAO.getCategoryById(id));
                request.setAttribute("categories", categoryDAO.getAllCategories());
                request.getRequestDispatcher("/WEB-INF/views/admin/category/editCategory.jsp").forward(request, response);
            }
        } catch (IllegalArgumentException e) {
            request.setAttribute("err", "<p class='text-danger'>" + e.getMessage() + "</p>");
            try {
                long id = Long.parseLong(request.getParameter("id"));
                request.setAttribute("category", categoryDAO.getCategoryById(id));
            } catch (NumberFormatException ex) {
                request.setAttribute("err", "<p class='text-danger'>Invalid category ID</p>");
            }
            request.setAttribute("categories", categoryDAO.getAllCategories());
            request.getRequestDispatcher("/WEB-INF/views/admin/category/editCategory.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("err", "<p class='text-danger'>Error updating category: " + e.getMessage() + "</p>");
            try {
                long id = Long.parseLong(request.getParameter("id"));
                request.setAttribute("category", categoryDAO.getCategoryById(id));
            } catch (NumberFormatException ex) {
                request.setAttribute("err", "<p class='text-danger'>Invalid category ID</p>");
            }
            request.setAttribute("categories", categoryDAO.getAllCategories());
            request.getRequestDispatcher("/WEB-INF/views/admin/category/editCategory.jsp").forward(request, response);
        }
    }

    @Override
    public String getServletInfo() {
        return "Servlet for editing categories";
    }
}