package controller;

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

@WebServlet(name = "CategoryHeaderController", urlPatterns = {"/CategoryHeader"})
public class CategoryHeaderController extends HttpServlet {
    private CategoryDAO categoryDAO;

    @Override
    public void init() throws ServletException {
        categoryDAO = new CategoryDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            List<Category> allCategories = categoryDAO.getAllCategories();
            List<Category> parentCategories = new ArrayList<>();
            if (allCategories != null) {
                for (Category cat : allCategories) {
                    if (cat.getParentCategoryId() == null) {
                        parentCategories.add(cat);
                    }
                }
            }
            request.setAttribute("parentCategories", parentCategories);
            request.setAttribute("allCategories", allCategories);
            request.getRequestDispatcher("/WEB-INF/views/public/common/header.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error retrieving categories");
        }
    }
}