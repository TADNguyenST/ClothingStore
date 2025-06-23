/*
 * Click nbproject://SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbproject://SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.admin;

import dao.BrandDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Date;
import java.util.List;
import model.Brand;

/**
 *
 * @author DANGVUONGTHINH
 */
@WebServlet(name = "BrandManagerController", urlPatterns = {"/BrandManager"})
public class BrandManagerController extends HttpServlet {

    private final BrandDAO brandDAO = new BrandDAO();

    @Override
protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
    String action = request.getParameter("action");
    if (action == null) {
        action = "list";
    }

    // Set currentModule for sidebar
    request.setAttribute("currentModule", "brand");

    switch (action.toLowerCase()) {
        case "list":
            request.setAttribute("currentAction", "brandList");
            List<Brand> brands = brandDAO.getAll();
            request.setAttribute("brands", brands);
            if (brands.isEmpty()) {
                request.setAttribute("err", "<p class='text-danger'>No brands found</p>");
            }
            request.getRequestDispatcher("/WEB-INF/views/admin/brand/brands.jsp").forward(request, response);
            break;

        case "search":
            request.setAttribute("currentAction", "brandList");
            String search = request.getParameter("search");
            try {
                brands = brandDAO.searchBrandsByName(search != null ? search.trim() : "");
                request.setAttribute("brands", brands);
                request.setAttribute("search", search); // Persist search parameter
                if (brands.isEmpty()) {
                    request.setAttribute("err", "<p class='text-danger'>No brands found matching the search criteria</p>");
                }
            } catch (Exception e) {
                request.setAttribute("err", "<p class='text-danger'>Error searching brands: " + e.getMessage() + "</p>");
                System.out.println("Error in search action: " + e.getMessage());
            }
            request.getRequestDispatcher("/WEB-INF/views/admin/brand/brands.jsp").forward(request, response);
            break;

        case "filter":
            request.setAttribute("currentAction", "brandList");
            String status = request.getParameter("status");
            try {
                if (status != null && !status.isEmpty()) {
                    boolean isActive = status.equals("active");
                    brands = brandDAO.getBrandsByStatus(isActive);
                } else {
                    brands = brandDAO.getAll();
                }
                request.setAttribute("brands", brands);
                request.setAttribute("status", status); // Persist status parameter
                if (brands.isEmpty()) {
                    request.setAttribute("err", "<p class='text-danger'>No brands found matching the filter criteria</p>");
                }
            } catch (Exception e) {
                request.setAttribute("err", "<p class='text-danger'>Error filtering brands: " + e.getMessage() + "</p>");
                System.out.println("Error in filter action: " + e.getMessage());
            }
            request.getRequestDispatcher("/WEB-INF/views/admin/brand/brands.jsp").forward(request, response);
            break;

        case "create":
            request.setAttribute("currentAction", "brandForm");
            request.getRequestDispatcher("/WEB-INF/views/admin/brand/create-brand.jsp").forward(request, response);
            break;

        case "edit":
            request.setAttribute("currentAction", "brandForm");
            try {
                long id = Long.parseLong(request.getParameter("id"));
                Brand brand = brandDAO.getBrandById(id);
                if (brand == null) {
                    request.setAttribute("err", "<p class='text-danger'>Brand not found</p>");
                    request.setAttribute("brands", brandDAO.getAll());
                    request.getRequestDispatcher("/WEB-INF/views/admin/brand/brands.jsp").forward(request, response);
                } else {
                    request.setAttribute("brand", brand);
                    request.getRequestDispatcher("/WEB-INF/views/admin/brand/edit-brand.jsp").forward(request, response);
                }
            } catch (NumberFormatException e) {
                request.setAttribute("err", "<p class='text-danger'>Invalid brand ID</p>");
                request.setAttribute("brands", brandDAO.getAll());
                request.getRequestDispatcher("/WEB-INF/views/admin/brand/brands.jsp").forward(request, response);
            }
            break;

        case "delete":
            request.setAttribute("currentAction", "brandList");
            try {
                long id = Long.parseLong(request.getParameter("id"));
                boolean result = brandDAO.deleteBrand(id);
                if (result) {
                    request.setAttribute("msg", "<p class='text-success'>Brand deleted successfully</p>");
                } else {
                    request.setAttribute("err", "<p class='text-danger'>Failed to delete brand</p>");
                }
            } catch (NumberFormatException e) {
                request.setAttribute("err", "<p class='text-danger'>Invalid brand ID</p>");
            } catch (RuntimeException e) {
                request.setAttribute("err", "<p class='text-danger'>" + e.getMessage() + "</p>");
            }
            request.setAttribute("brands", brandDAO.getAll());
            request.getRequestDispatcher("/WEB-INF/views/admin/brand/brands.jsp").forward(request, response);
            break;

        case "detail":
            request.setAttribute("currentAction", "brandDetails");
            try {
                long id = Long.parseLong(request.getParameter("id"));
                Brand brand = brandDAO.getBrandById(id);
                if (brand == null) {
                    request.setAttribute("err", "<p class='text-danger'>Brand not found</p>");
                    request.setAttribute("brands", brandDAO.getAll());
                    request.getRequestDispatcher("/WEB-INF/views/admin/brand/brands.jsp").forward(request, response);
                } else {
                    request.setAttribute("brand", brand);
                    request.getRequestDispatcher("/WEB-INF/views/admin/brand/brandDetail.jsp").forward(request, response);
                }
            } catch (NumberFormatException e) {
                request.setAttribute("err", "<p class='text-danger'>Invalid brand ID</p>");
                request.setAttribute("brands", brandDAO.getAll());
                request.getRequestDispatcher("/WEB-INF/views/admin/brand/brands.jsp").forward(request, response);
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

        // Set currentModule for sidebar
        request.setAttribute("currentModule", "brand");

        switch (action.toLowerCase()) {
            case "create":
                request.setAttribute("currentAction", "brandForm");
                try {
                    String name = request.getParameter("name");
                    String description = request.getParameter("description");
                    String logoUrl = request.getParameter("logoUrl");
                    boolean isActive = request.getParameter("isActive") != null && request.getParameter("isActive").equals("true");

                    if (name == null || name.trim().isEmpty()) {
                        throw new IllegalArgumentException("Brand name is required");
                    }

                    Brand brand = new Brand();
                    brand.setName(name);
                    brand.setDescription(description);
                    brand.setLogoUrl(logoUrl);
                    brand.setActive(isActive);
                    brand.setCreatedAt(new Date());

                    brandDAO.insertBrand(brand);
                    response.sendRedirect("BrandManager?action=list&module=brand");
                } catch (IllegalArgumentException e) {
                    request.setAttribute("err", "<p class='text-danger'>" + e.getMessage() + "</p>");
                    request.getRequestDispatcher("/WEB-INF/views/admin/brand/create-brand.jsp").forward(request, response);
                } catch (Exception e) {
                    request.setAttribute("err", "<p class='text-danger'>Error creating brand: " + e.getMessage() + "</p>");
                    request.getRequestDispatcher("/WEB-INF/views/admin/brand/create-brand.jsp").forward(request, response);
                }
                break;

            case "update":
                request.setAttribute("currentAction", "brandForm");
                try {
                    long id = Long.parseLong(request.getParameter("id"));
                    String name = request.getParameter("name");
                    String description = request.getParameter("description");
                    String logoUrl = request.getParameter("logoUrl");
                    boolean isActive = request.getParameter("isActive") != null && request.getParameter("isActive").equals("true");

                    if (name == null || name.trim().isEmpty()) {
                        throw new IllegalArgumentException("Brand name is required");
                    }

                    Brand brand = new Brand();
                    brand.setBrandId(id);
                    brand.setName(name);
                    brand.setDescription(description);
                    brand.setLogoUrl(logoUrl);
                    brand.setActive(isActive);
                    brand.setCreatedAt(new Date()); // Giữ nguyên created_at hoặc lấy từ DB nếu cần

                    boolean result = brandDAO.updateBrand(brand);
                    if (result) {
                        response.sendRedirect("BrandManager?action=list&module=brand");
                    } else {
                        request.setAttribute("err", "<p class='text-danger'>Failed to update brand</p>");
                        request.setAttribute("brand", brandDAO.getBrandById(id));
                        request.getRequestDispatcher("/WEB-INF/views/admin/brand/edit-brand.jsp").forward(request, response);
                    }
                } catch (IllegalArgumentException e) {
                    request.setAttribute("err", "<p class='text-danger'>" + e.getMessage() + "</p>");
                    try {
                        long id = Long.parseLong(request.getParameter("id"));
                        request.setAttribute("brand", brandDAO.getBrandById(id));
                    } catch (NumberFormatException ex) {
                        request.setAttribute("err", "<p class='text-danger'>Invalid brand ID</p>");
                    }
                    request.getRequestDispatcher("/WEB-INF/views/admin/brand/edit-brand.jsp").forward(request, response);
                } catch (Exception e) {
                    request.setAttribute("err", "<p class='text-danger'>Error updating brand: " + e.getMessage() + "</p>");
                    try {
                        long id = Long.parseLong(request.getParameter("id"));
                        request.setAttribute("brand", brandDAO.getBrandById(id));
                    } catch (NumberFormatException ex) {
                        request.setAttribute("err", "<p class='text-danger'>Invalid brand ID</p>");
                    }
                    request.getRequestDispatcher("/WEB-INF/views/admin/brand/edit-brand.jsp").forward(request, response);
                }
                break;

            default:
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
        }
    }

    @Override
    public String getServletInfo() {
        return "BrandManagerController for managing brands in ClothingStore";
    }
}