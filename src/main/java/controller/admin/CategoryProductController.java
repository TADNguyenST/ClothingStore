// FILE: src/main/java/controller/admin/CategoryProductController.java
package controller.admin;

import dao.CategoryDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Category;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/admin/categories")
public class CategoryProductController extends HttpServlet {
    private final CategoryDAO categoryDAO = new CategoryDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            List<Category> parentCategories = categoryDAO.getParentCategories();
            List<Category> allCategories = categoryDAO.getAllCategories();
            if (parentCategories == null) {
                parentCategories = new ArrayList<>();
            }
            if (allCategories == null) {
                allCategories = new ArrayList<>();
            }
            request.setAttribute("parentCategories", parentCategories);
            request.setAttribute("allCategories", allCategories);
        } catch (Exception e) {
            System.err.println("Error in CategoryProductController: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Failed to load categories.");
        }
        // No forward needed since this is included
    }
}