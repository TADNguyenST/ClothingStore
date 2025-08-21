package controller.admin;

import dao.ProductDAO;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Product;

@WebServlet(name="ProductListAdminFilterController", urlPatterns={"/ProductListAdminFilter"})
public class ProductListAdminFilterController extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        ProductDAO proDAO = new ProductDAO();
        String filter = request.getParameter("filter");
        String keyword = request.getParameter("keyword");
        String sort = request.getParameter("sort"); 
        List<Product> productList = new ArrayList<>();

       
        if (keyword != null && !keyword.trim().isEmpty()) {
            productList = proDAO.searchProductByNameAndFilter(keyword, filter);
        } else {
            // Lọc filter
            if (filter == null || filter.equals("All")) {
                productList = proDAO.getAll(sort);
            } else if (filter.equals("New")) {
                productList = proDAO.getProductIsNew();
            } else if (filter.equals("Active")) {
                productList = proDAO.getProductsByStatus("Active");
            } else if (filter.equals("Inactive")) {
                productList = proDAO.getProductsByStatus("Inactive");
            }
            System.out.println("ProductListAdminFilterController: Retrieved " + productList.size() +
                              " products for filter: " + filter + ", sort: " + sort);
        }
        request.setAttribute("productList", productList);
        request.setAttribute("currentModule", "admin");
        request.setAttribute("currentAction", "products");
        request.setAttribute("sort", sort); 
        request.getRequestDispatcher("/WEB-INF/views/staff/product/products.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        doGet(request, response); 
    }

    @Override
    public String getServletInfo() {
        return "Product List Admin Filter Controller";
    }
}