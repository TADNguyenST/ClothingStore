package controller.admin;

import dao.CategoryDAO;
import dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import model.Category;

@WebServlet(name = "CategoryManagerController", urlPatterns = {"/CategoryManager"})
public class CategoryManagerController extends HttpServlet {

    private final CategoryDAO categoryDAO = new CategoryDAO();
    private final ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action.toLowerCase()) {
            case "list":
                request.setAttribute("categories", categoryDAO.getAllCategories());
                request.getRequestDispatcher("/WEB-INF/views/admin/category/categories.jsp").forward(request, response);
                break;

            case "create":
                request.setAttribute("categories", categoryDAO.getAllCategories());
                request.getRequestDispatcher("/WEB-INF/views/admin/category/create-category.jsp").forward(request, response);
                break;

            case "edit":
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
                    request.getRequestDispatcher("/WEB-INF/views/admin/category/edit-category.jsp").forward(request, response);
                }
            } catch (NumberFormatException e) {
                request.setAttribute("err", "<p class='text-danger'>Invalid category ID</p>");
                request.setAttribute("categories", categoryDAO.getAllCategories());
                request.getRequestDispatcher("/WEB-INF/views/admin/category/categories.jsp").forward(request, response);
            }
            break;

            case "delete":
    try {
                long id = Long.parseLong(request.getParameter("id"));
                boolean result = categoryDAO.deleteCategory(id);
                System.out.println("Delete result for ID " + id + ": " + result);
                if (result) {
                    request.setAttribute("msg", "<p class='text-success'>Category deleted successfully</p>");
                } 
            } catch (NumberFormatException e) {
                request.setAttribute("err", "<p class='text-danger'>Invalid category ID</p>");
            } catch (RuntimeException e) {
                request.setAttribute("err", "<p class='text-danger'>Failed to delete category</p>");
            }
            request.setAttribute("categories", categoryDAO.getAllCategories());
            request.getRequestDispatcher("/WEB-INF/views/admin/category/categories.jsp").forward(request, response);
            break;

            case "detail":
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
                    request.getRequestDispatcher("/WEB-INF/views/admin/category/categoryDetail.jsp").forward(request, response);
                }
            } catch (NumberFormatException e) {
                request.setAttribute("err", "<p class='text-danger'>Invalid category ID</p>");
                request.setAttribute("categories", categoryDAO.getAllCategories());
                request.getRequestDispatcher("/WEB-INF/views/admin/category/categories.jsp").forward(request, response);
            }
            break;

            default:
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Action is required");
            return;
        }

        switch (action.toLowerCase()) {
            case "create":
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
                if (parentCategoryId != null && categoryDAO.getCategoryById(parentCategoryId) == null) {
                    throw new IllegalArgumentException("Invalid Parent Category ID: " + parentCategoryId);
                }

                int result = categoryDAO.insertCategory(name, description, parentCategoryId, isActive);
                if (result == 1) {
                    response.sendRedirect("CategoryManager?action=list");
                } else {
                    request.setAttribute("err", "<p class='text-danger'>Failed to create category</p>");
                    request.setAttribute("categories", categoryDAO.getAllCategories());
                    request.getRequestDispatcher("/WEB-INF/views/admin/category/create-category.jsp").forward(request, response);
                }
            } catch (IllegalArgumentException e) {
                request.setAttribute("err", "<p class='text-danger'>" + e.getMessage() + "</p>");
                request.setAttribute("categories", categoryDAO.getAllCategories());
                request.getRequestDispatcher("/WEB-INF/views/admin/category/create-category.jsp").forward(request, response);
            } catch (Exception e) {
                request.setAttribute("err", "<p class='text-danger'>Error creating category: " + e.getMessage() + "</p>");
                request.setAttribute("categories", categoryDAO.getAllCategories());
                request.getRequestDispatcher("/WEB-INF/views/admin/category/create-category.jsp").forward(request, response);
            }
            break;

            case "update":
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
                if (parentCategoryId != null && categoryDAO.getCategoryById(parentCategoryId) == null) {
                    throw new IllegalArgumentException("Invalid Parent Category ID: " + parentCategoryId);
                }
                if (parentCategoryId != null && parentCategoryId == id) {
                    throw new IllegalArgumentException("Category cannot be its own parent");
                }

                boolean result = categoryDAO.updateCategory(id, name, description, parentCategoryId, isActive);
                if (result) {
                    response.sendRedirect("CategoryManager?action=list");
                } else {
                    request.setAttribute("err", "<p class='text-danger'>Failed to update category</p>");
                    request.setAttribute("category", categoryDAO.getCategoryById(id));
                    request.setAttribute("categories", categoryDAO.getAllCategories());
                    request.getRequestDispatcher("/WEB-INF/views/admin/category/edit-category.jsp").forward(request, response);
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
                request.getRequestDispatcher("/WEB-INF/views/admin/category/edit-category.jsp").forward(request, response);
            } catch (Exception e) {
                request.setAttribute("err", "<p class='text-danger'>Error updating category: " + e.getMessage() + "</p>");
                try {
                    long id = Long.parseLong(request.getParameter("id"));
                    request.setAttribute("category", categoryDAO.getCategoryById(id));
                } catch (NumberFormatException ex) {
                    request.setAttribute("err", "<p class='text-danger'>Invalid category ID</p>");
                }
                request.setAttribute("categories", categoryDAO.getAllCategories());
                request.getRequestDispatcher("/WEB-INF/views/admin/category/edit-category.jsp").forward(request, response);
            }
            break;

            default:
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
        }
    }

    @Override
    public String getServletInfo() {
        return "CategoryManagerController for managing categories in ClothingStore";
    }
}
