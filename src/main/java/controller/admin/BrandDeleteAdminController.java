package controller.admin;

import dao.BrandDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "BrandDeleteAdminController", urlPatterns = {"/BrandDeleteAdmin"})
public class BrandDeleteAdminController extends HttpServlet {

    private final BrandDAO brandDAO = new BrandDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {

            String idParam = request.getParameter("id");
            if (idParam == null || idParam.isEmpty()) {
                out.print("{\"success\": false, \"message\": \"Missing brand ID\"}");
                return;
            }

            try {
                long brandId = Long.parseLong(idParam);

                boolean deleted = brandDAO.deleteBrand(brandId);

                if (deleted) {
                    out.print("{\"success\": true}");
                } else {
                    out.print("{\"success\": false, \"message\": \"Brand not found or could not be deleted\"}");
                }

            } catch (NumberFormatException e) {
                out.print("{\"success\": false, \"message\": \"Invalid brand ID\"}");
            } catch (IllegalStateException e) {
                // trường hợp brand đang được dùng bởi products
                out.print("{\"success\": false, \"message\": \"Brand is used by products\"}");
            } catch (Exception e) {
                out.print("{\"success\": false, \"message\": \"" + e.getMessage() + "\"}");
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
