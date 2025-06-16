/*
 * Click nbproject://SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbproject://SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.admin;

import dao.ProductDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.List;
import model.Product;

/**
 *
 * @author DANGVUONGTHINH
 */
@WebServlet(name = "ProductManagerController", urlPatterns = {"/ProductManager"})
public class ProductManagerController extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet ProductManagerController</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ProductManagerController at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        ProductDAO dao = new ProductDAO();
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }
        try {
            if (action.equalsIgnoreCase("list")) {
                List<Product> listProduct = dao.getAll();
                request.setAttribute("listProduct", listProduct);

                // ✅ Retrieve message from session if available
                String deleteMessage = (String) request.getSession().getAttribute("deleteMessage");
                if (deleteMessage != null) {
                    request.setAttribute("deleteMessage", deleteMessage);
                    request.getSession().removeAttribute("deleteMessage"); // Remove after display
                }

                request.getRequestDispatcher("listProduct.jsp").forward(request, response);
            } else if (action.equalsIgnoreCase("create")) {
                request.getRequestDispatcher("createProduct.jsp").forward(request, response);
            } else if (action.equalsIgnoreCase("update")) {
                String id = request.getParameter("id");
                long productId = (id != null && id.matches("\\d+")) ? Long.parseLong(id) : -1;
                if (productId != -1) {
                    Product product = dao.getProductById(productId);
                    if (product != null) {
                        request.setAttribute("product", product);
                        request.getRequestDispatcher("editProduct.jsp").forward(request, response);
                    } else {
                        response.sendError(HttpServletResponse.SC_NOT_FOUND, "Product does not exist!");
                    }
                } else {
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid ID!");
                }
            } else if (action.equalsIgnoreCase("delete")) {
                String id = request.getParameter("id");
                String confirm = request.getParameter("confirm");
                long productId = (id != null && id.matches("\\d+")) ? Long.parseLong(id) : -1;

                if (productId != -1) {
                    if ("ok".equals(confirm)) {
                        int result = dao.delete(productId);
                        if (result == 1) {
                            // ✅ Set successful delete message to session for redirect to list
                            request.getSession().setAttribute("deleteMessage", "Product deleted successfully!");
                        } else {
                            request.getSession().setAttribute("deleteMessage", "Product deletion failed!");
                        }
                    }
                    // ✅ Redirect to action=list to avoid keeping delete URL
                    response.sendRedirect(request.getContextPath() + "/ProductManager?action=list");
                } else {
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid ID!");
                }
            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action!");
            }
        } catch (Exception e) {
            System.out.println("Get error: " + e.getMessage());
            response.setContentType("text/html; charset=UTF-8");
            try (PrintWriter out = response.getWriter()) {
                out.println("<html><body>");
                out.println("<h1>Error</h1>");
                out.println("<p>" + e.getMessage() + "</p>");
                out.println("<a href='" + request.getContextPath() + "/ProductManager?action=list'>Back</a>");
                out.println("</body></html>");
            }
        }
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        ProductDAO dao = new ProductDAO();
        if (action != null && action.equalsIgnoreCase("create")) {
            try {
                String name = request.getParameter("name");
                String description = request.getParameter("description");
                String priceStr = request.getParameter("price");
                String stockQuantityStr = request.getParameter("stockQuantity");
                String supplierIdStr = request.getParameter("supplierId");
                String categoryIdStr = request.getParameter("categoryId");
                String brandIdStr = request.getParameter("brandId");
                String material = request.getParameter("material");
                String status = request.getParameter("status");

                System.out.println("Creating product - Name: " + name + ", Price: " + priceStr + ", Status: " + status);

                // Validation
                if (name == null || name.trim().isEmpty()) {
                    throw new IllegalArgumentException("Product name cannot be empty.");
                }
                if (priceStr == null || priceStr.trim().isEmpty()) {
                    throw new IllegalArgumentException("Price cannot be empty.");
                }
                if (stockQuantityStr == null || stockQuantityStr.trim().isEmpty()) {
                    throw new IllegalArgumentException("Stock quantity cannot be empty.");
                }
                if (material == null || material.trim().isEmpty()) {
                    throw new IllegalArgumentException("Material cannot be empty.");
                }
                if (status == null || (!status.equals("Active") && !status.equals("Discontinued"))) {
                    throw new IllegalArgumentException("Status must be 'Active' or 'Discontinued'.");
                }

                double price = Double.parseDouble(priceStr);
                int stockQuantity = Integer.parseInt(stockQuantityStr);
                Long supplierId = supplierIdStr != null && !supplierIdStr.trim().isEmpty() ? Long.parseLong(supplierIdStr) : null;
                Long categoryId = categoryIdStr != null && !categoryIdStr.trim().isEmpty() ? Long.parseLong(categoryIdStr) : null;
                Long brandId = brandIdStr != null && !brandIdStr.trim().isEmpty() ? Long.parseLong(brandIdStr) : null;

                int res = dao.insert(name, description, price, stockQuantity, supplierId, categoryId, brandId, material, status);
                System.out.println("Insert result: " + res);
                if (res == 1) {
                    response.sendRedirect(request.getContextPath() + "/ProductManager?action=list");
                } else {
                    request.setAttribute("err", "<p>Product creation failed. Please check logs or contact admin.</p>");
                    request.getRequestDispatcher("createProduct.jsp").forward(request, response);
                }
            } catch (NumberFormatException e) {
                System.out.println("NumberFormatException: " + e.getMessage());
                request.setAttribute("err", "<p>Invalid numeric data (price or quantity).</p>");
                request.getRequestDispatcher("createProduct.jsp").forward(request, response);
            } catch (IllegalArgumentException e) {
                System.out.println("Validation error: " + e.getMessage());
                request.setAttribute("err", "<p>" + e.getMessage() + "</p>");
                request.getRequestDispatcher("createProduct.jsp").forward(request, response);
            } catch (Exception e) {
                System.out.println("Post error: " + e.getMessage());
                request.setAttribute("err", "<p>System error: " + e.getMessage() + "</p>");
                request.getRequestDispatcher("createProduct.jsp").forward(request, response);
            }
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action!");
        }
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Manages product operations including listing, creating, updating, and deleting products.";
    }
    // </editor-fold>
}