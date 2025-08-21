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

@WebServlet(name = "CategoryCheckDuplicateAdminController", urlPatterns = {"/CategoryCheckDuplicateAdmin"})
public class CategoryCheckDuplicateAdminController extends HttpServlet {
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

        String name = request.getParameter("name");
        String parentCategoryIdRaw = request.getParameter("parentCategoryId");
        String categoryIdRaw = request.getParameter("categoryId");
        try {
            Long parentCategoryId = parentCategoryIdRaw != null && !parentCategoryIdRaw.isEmpty() ? Long.parseLong(parentCategoryIdRaw) : null;
            Long categoryId = categoryIdRaw != null && !categoryIdRaw.isEmpty() ? Long.parseLong(categoryIdRaw) : null;
            String normalizedName = name != null ? name.trim().replaceAll("\\s+", " ").toLowerCase() : "";
            boolean exists = categoryDAO.isCategoryExists(normalizedName, parentCategoryId, categoryId);
            response.setContentType("application/json");
            response.getWriter().write("{\"exists\": " + exists + "}");
        } catch (NumberFormatException e) {
            response.setContentType("application/json");
            response.getWriter().write("{\"error\": \"Invalid category ID\"}");
        } catch (Exception e) {
            response.setContentType("application/json");
            response.getWriter().write("{\"error\": \"Error checking duplicate name\"}");
        }
    }

    @Override
    public String getServletInfo() {
        return "Servlet for checking duplicate category names";
    }
}