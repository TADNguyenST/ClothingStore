package controller.admin;

import dao.BrandDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.Users;

@WebServlet(name = "BrandCheckDuplicateAdminController", urlPatterns = {"/BrandCheckDuplicateAdmin"})
public class BrandCheckDuplicateAdminController extends HttpServlet {
    private final BrandDAO brandDAO = new BrandDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Users currentUser = (Users) session.getAttribute("admin");
        if (currentUser == null) {
            response.setContentType("application/json");
            response.getWriter().write("{\"error\": \"Unauthorized access. Please log in.\"}");
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        String name = request.getParameter("name");
        String brandIdRaw = request.getParameter("brandId");
        try {
            Long brandId = brandIdRaw != null && !brandIdRaw.isEmpty() ? Long.parseLong(brandIdRaw) : null;
            String normalizedName = name != null ? name.trim().replaceAll("\\s+", " ").toLowerCase() : "";
            boolean exists = brandDAO.isBrandExists(normalizedName, brandId);
            response.setContentType("application/json");
            response.getWriter().write("{\"exists\": " + exists + "}");
        } catch (NumberFormatException e) {
            response.setContentType("application/json");
            response.getWriter().write("{\"error\": \"Invalid brand ID\"}");
        } catch (Exception e) {
            response.setContentType("application/json");
            response.getWriter().write("{\"error\": \"Error checking duplicate name\"}");
        }
    }

    @Override
    public String getServletInfo() {
        return "Servlet for checking duplicate brand names";
    }
}