package controller.admin;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import dao.BrandDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Date;
import java.util.Map;
import model.Brand;
import model.Users;

@WebServlet(name = "BrandCreateAdminController", urlPatterns = {"/BrandCreateAdmin"})
@MultipartConfig(maxFileSize = 10485760) // Limit 10MB per file
public class BrandCreateAdminController extends HttpServlet {
    private final BrandDAO brandDAO = new BrandDAO();
    private Cloudinary cloudinary;

    @Override
    public void init() {
        try {
            cloudinary = new Cloudinary(ObjectUtils.asMap(
                    "cloud_name", "da36bkpx5",
                    "api_key", "342541776882536",
                    "api_secret", "F_90gUaX6jfD8yJI8FxCY1Hurbg"
            ));
        } catch (Exception e) {
            e.printStackTrace();
        }
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
        request.setAttribute("currentModule", "brand");
        request.setAttribute("currentAction", "brands");
        request.getRequestDispatcher("/WEB-INF/views/admin/brand/createBrand.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Users currentUser = (Users) session.getAttribute("admin");
        if (currentUser == null) {
            currentUser = (Users) session.getAttribute("staff");
        }
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/AdminLogin");
            return;
        }

        try {
            String name = request.getParameter("name");
            String description = request.getParameter("description");
            boolean isActive = request.getParameter("isActive") != null && request.getParameter("isActive").equals("true");
            if (name == null || name.trim().isEmpty()) {
                throw new IllegalArgumentException("Brand name is required");
            }
            String normalizedName = name.trim().replaceAll("\\s+", " ").toLowerCase();
            if (brandDAO.isBrandExists(normalizedName, null)) {
                throw new IllegalArgumentException("Brand '" + name + "' existed.");
            }
            Part filePart = request.getPart("logo");
            String logoUrl = null;
            if (filePart != null && filePart.getSize() > 0) {
                String fileName = filePart.getSubmittedFileName();
                if (fileName != null && !fileName.toLowerCase().matches(".*\\.(jpg|jpeg|png|gif)$")) {
                    throw new IllegalArgumentException("Invalid image format for logo: " + fileName);
                }
                File tempFile = null;
                try {
                    tempFile = File.createTempFile("upload", fileName);
                    try (InputStream input = filePart.getInputStream(); FileOutputStream output = new FileOutputStream(tempFile)) {
                        byte[] buffer = new byte[1024];
                        int len;
                        while ((len = input.read(buffer)) != -1) {
                            output.write(buffer, 0, len);
                        }
                    }
                    if (cloudinary != null) {
                        Map uploadResult = cloudinary.uploader().upload(tempFile, ObjectUtils.asMap(
                                "quality", "auto",
                                "fetch_format", "auto",
                                "width", 400,
                                "crop", "limit",
                                "folder", "brands"
                        ));
                        logoUrl = (String) uploadResult.get("secure_url");
                        tempFile.delete();
                    } else {
                        throw new IllegalStateException("Cloudinary not initialized!");
                    }
                } catch (IOException | IllegalStateException e) {
                    if (tempFile != null) {
                        tempFile.delete();
                    }
                    throw e;
                }
            } else {
                throw new IllegalArgumentException("A logo image is required");
            }
            Brand brand = new Brand();
            brand.setName(name);
            brand.setDescription(description);
            brand.setLogoUrl(logoUrl);
            brand.setActive(isActive);
            brand.setCreatedAt(new Date());
            brandDAO.insertBrand(brand);
            request.getSession().setAttribute("msg", "Brand created successfully!");
            response.sendRedirect(request.getContextPath() + "/BrandListAdmin");
        } catch (IllegalArgumentException e) {
            request.setAttribute("err", "<p class='text-danger'>" + e.getMessage() + "</p>");
            request.setAttribute("currentModule", "brand");
            request.setAttribute("currentAction", "brands");
            request.getRequestDispatcher("/WEB-INF/views/admin/brand/createBrand.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("err", "<p class='text-danger'>Error creating the mark: " + e.getMessage() + "</p>");
            request.setAttribute("currentModule", "brand");
            request.setAttribute("currentAction", "brands");
            request.getRequestDispatcher("/WEB-INF/views/admin/brand/createBrand.jsp").forward(request, response);
        }
    }

    @Override
    public String getServletInfo() {
        return "Servlet for creating new brands";
    }
}