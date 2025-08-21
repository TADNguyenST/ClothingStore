package controller.admin;

import dao.ProductDAO;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Product;
import model.Users;

@WebServlet(name="ProductListAdminController", urlPatterns={"/ProductListAdmin"})
public class ProductListAdminController extends HttpServlet {
    private ProductDAO dao;

    @Override
    public void init() throws ServletException {
        dao = new ProductDAO();
    }

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
            String action = request.getParameter("action");
            String sort = request.getParameter("sort"); 
            if (action == null) {
                action = "list";
            }
            List<Product> products;
            if (action.equalsIgnoreCase("list")) {
                products = dao.getAll(sort); 
                System.out.println("ProductListAdminController: Retrieved " + products.size() + " products for list action with sort: " + sort);
                if (products != null) {
                    for (Product p : products) {
                        System.out.println("Servlet: Product ID " + p.getProductId() + ", Image: " + (p.getImageUrl() != null ? p.getImageUrl() : "null"));
                    }
                }
                request.setAttribute("products", products);
                request.setAttribute("currentModule", "admin");
                request.setAttribute("currentAction", "products");
                request.setAttribute("sort", sort); 
                request.getRequestDispatcher("/WEB-INF/views/staff/product/products.jsp").forward(request, response);
            } else if (action.equalsIgnoreCase("detail")) {
                String idRaw = request.getParameter("id");
                try {
                    long id = Long.parseLong(idRaw);
                    Product product = dao.getProductById(id);
                    System.out.println("ProductListAdminController: Retrieved product ID " + id + " for detail");
                    request.setAttribute("data", product);
                    request.setAttribute("currentModule", "admin");
                    request.setAttribute("currentAction", "products");
                    request.getRequestDispatcher("/WEB-INF/views/staff/product/detailProduct.jsp").forward(request, response);
                } catch (NumberFormatException e) {
                    System.out.println("ProductListAdminController: Invalid product ID: " + idRaw);
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid product ID");
                }
            } else if (action.equalsIgnoreCase("create")) {
                request.setAttribute("currentModule", "admin");
                request.setAttribute("currentAction", "products");
                request.getRequestDispatcher("/WEB-INF/views/staff/product/createProduct.jsp").forward(request, response);
            } else if (action.equalsIgnoreCase("delete")) {
                String idRaw = request.getParameter("id");
                try {
                    long id = Long.parseLong(idRaw);
                    int result = dao.deleteProduct(id);
                    if (result == 1) {
                        request.setAttribute("message", "Product deleted successfully!");
                    } else {
                        request.setAttribute("message", "Failed to delete product. Product ID not found.");
                    }
                    products = dao.getAll(sort); 
                    System.out.println("ProductListAdminController: Retrieved " + products.size() + " products after delete");
                    if (products != null) {
                        for (Product p : products) {
                            System.out.println("Servlet: Product ID " + p.getProductId() + ", Image: " + (p.getImageUrl() != null ? p.getImageUrl() : "null"));
                        }
                    }
                    request.setAttribute("products", products);
                    request.setAttribute("currentModule", "admin");
                    request.setAttribute("currentAction", "products");
                    request.setAttribute("sort", sort); 
                    request.getRequestDispatcher("/WEB-INF/views/staff/product/products.jsp").forward(request, response);
                } catch (NumberFormatException e) {
                    System.out.println("ProductListAdminController: Invalid product ID: " + idRaw);
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid product ID");
                } catch (RuntimeException e) {
                    System.out.println("ProductListAdminController: Error deleting product ID " + idRaw + ": " + e.getMessage());
                    request.setAttribute("message", "Failed to delete product: " + e.getMessage());
                    products = dao.getAll(sort); 
                    request.setAttribute("products", products);
                    request.setAttribute("currentModule", "admin");
                    request.setAttribute("currentAction", "products");
                    request.setAttribute("sort", sort); 
                    request.getRequestDispatcher("/WEB-INF/views/staff/product/products.jsp").forward(request, response);
                }
            }
        } catch (Exception e) {
            System.out.println("Error in ProductListAdminController: " + e.getClass().getName() + " - " + e.getMessage());
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error processing request: " + e.getClass().getName() + " - " + e.getMessage());
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        doGet(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Product List Admin Controller";
    }
}