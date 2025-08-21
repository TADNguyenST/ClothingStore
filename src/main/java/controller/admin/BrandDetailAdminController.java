package controller.admin;

import dao.BrandDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.Brand;
import model.Users;

@WebServlet(name = "BrandDetailAdminController", urlPatterns = {"/BrandDetailAdmin"})
public class BrandDetailAdminController extends HttpServlet {
    private final BrandDAO brandDAO = new BrandDAO();

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
            Brand brand = brandDAO.getBrandById(id);
            if (brand == null) {
                request.setAttribute("err", "<p class='text-danger'>Brand not found</p>");
                request.setAttribute("currentModule", "brand");
                request.setAttribute("currentAction", "brands");
                request.getRequestDispatcher("/WEB-INF/views/admin/brand/detailBrand.jsp").forward(request, response);
            } else {
                request.setAttribute("brand", brand);
                request.setAttribute("currentModule", "brand");
                request.setAttribute("currentAction", "brands");
                request.getRequestDispatcher("/WEB-INF/views/admin/brand/detailBrand.jsp").forward(request, response);
            }
        } catch (NumberFormatException e) {
            request.setAttribute("err", "<p class='text-danger'>Invalid brand ID</p>");
            request.setAttribute("currentModule", "brand");
            request.setAttribute("currentAction", "brands");
            request.getRequestDispatcher("/WEB-INF/views/admin/brand/detailBrand.jsp").forward(request, response);
        }
    }

    @Override
    public String getServletInfo() {
        return "Servlet for viewing brand details";
    }
}