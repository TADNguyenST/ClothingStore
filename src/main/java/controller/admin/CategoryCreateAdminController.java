package controller.admin;

import dao.CategoryDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.Users;

@WebServlet(name = "CategoryCreateAdminController", urlPatterns = {"/CategoryCreateAdmin"})
public class CategoryCreateAdminController extends HttpServlet {
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
        request.setAttribute("categories", categoryDAO.getAllCategories());
        request.getRequestDispatcher("/WEB-INF/views/admin/category/createCategory.jsp").forward(request, response);
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
            String name = request.getParameter("name");
            String description = request.getParameter("description");
            String parentCategoryIdRaw = request.getParameter("parentCategoryId");
            boolean isActive = request.getParameter("isActive") != null && request.getParameter("isActive").equals("true");
            Long parentCategoryId = parentCategoryIdRaw != null && !parentCategoryIdRaw.isEmpty()
                    ? Long.parseLong(parentCategoryIdRaw) : null;
            if (name == null || name.trim().isEmpty()) {
                throw new IllegalArgumentException("Category name is required");
            }
            String normalizedName = name.trim().replaceAll("\\s+", " ").toLowerCase();
            if (categoryDAO.isCategoryExists(normalizedName, parentCategoryId, null)) {
                throw new IllegalArgumentException("Category name already exists under this parent category");
            }
            if (parentCategoryId != null && categoryDAO.getCategoryById(parentCategoryId) == null) {
                throw new IllegalArgumentException("Invalid Parent Category ID: " + parentCategoryId);
            }
            int result = categoryDAO.insertCategory(name, description, parentCategoryId, isActive);
            if (result == 1) {
                request.getSession().setAttribute("msg", "Category created successfully!");
                response.sendRedirect("CategoryListAdmin");
            } else {
                request.setAttribute("err", "<p class='text-danger'>Failed to create category</p>");
                request.setAttribute("categories", categoryDAO.getAllCategories());
                request.getRequestDispatcher("/WEB-INF/views/admin/category/createCategory.jsp").forward(request, response);
            }
        } catch (IllegalArgumentException e) {
            request.setAttribute("err", "<p class='text-danger'>" + e.getMessage() + "</p>");
            request.setAttribute("categories", categoryDAO.getAllCategories());
            request.getRequestDispatcher("/WEB-INF/views/admin/category/createCategory.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("err", "<p class='text-danger'>Error creating category: " + e.getMessage() + "</p>");
            request.setAttribute("categories", categoryDAO.getAllCategories());
            request.getRequestDispatcher("/WEB-INF/views/admin/category/createCategory.jsp").forward(request, response);
        }
    }

    @Override
    public String getServletInfo() {
        return "Servlet for creating categories";
    }
}