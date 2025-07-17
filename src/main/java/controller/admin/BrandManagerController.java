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
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Date;
import java.util.List;
import java.util.Map;
import model.Brand;

@WebServlet(name = "BrandManagerController", urlPatterns = {"/BrandManager"})
@MultipartConfig(maxFileSize = 10485760) // Limit 10MB per file
public class BrandManagerController extends HttpServlet {

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
            if (cloudinary == null) {
                System.err.println("Failed to initialize Cloudinary!");
            } else {
                System.out.println("Cloudinary initialized successfully.");
            }
        } catch (Exception e) {
            System.err.println("Error initializing Cloudinary: " + e.getMessage());
            e.printStackTrace();
        }
    }

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
                    } 
                } catch (NumberFormatException e) {
                    request.setAttribute("err", "<p class='text-danger'>Invalid brand ID</p>");
                } catch (IllegalStateException e) {
                    request.setAttribute("err", "<p class='text-danger'>" + e.getMessage() + "</p>");
                } catch (RuntimeException e) {
                    request.setAttribute("err", "<p class='text-danger'>Failed to delete brand</p>");
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
                    boolean isActive = request.getParameter("isActive") != null && request.getParameter("isActive").equals("true");
                    String existingLogoUrl = request.getParameter("logoUrl"); // For fallback if no new file is uploaded
                    String logoUrl = null;

                    if (name == null || name.trim().isEmpty()) {
                        throw new IllegalArgumentException("Brand name is required");
                    }

                    // Handle logo file upload
                    Part filePart = request.getPart("logo");
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
                                        "width", 400, // Smaller size for logos
                                        "crop", "limit",
                                        "folder", "brands"
                                ));
                                logoUrl = (String) uploadResult.get("secure_url");
                                System.out.println("Uploaded logo URL: " + logoUrl);
                                tempFile.delete();
                            } else {
                                throw new IllegalStateException("Cloudinary not initialized!");
                            }
                        } catch (IOException | IllegalStateException e) {
                            System.err.println("Error processing logo file: " + e.getMessage());
                            if (tempFile != null) {
                                tempFile.delete();
                            }
                            throw e;
                        }
                    } else if (existingLogoUrl != null && !existingLogoUrl.trim().isEmpty()) {
                        logoUrl = existingLogoUrl; // Use existing URL if no new file is uploaded
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
                    response.sendRedirect("BrandManager?action=list&module=brand");
                } catch (IllegalArgumentException e) {
                    request.setAttribute("err", "<p class='text-danger'>" + e.getMessage() + "</p>");
                    request.getRequestDispatcher("/WEB-INF/views/admin/brand/create-brand.jsp").forward(request, response);
                } catch (Exception e) {
                    System.err.println("Error creating brand: " + e.getMessage());
                    request.setAttribute("err", "<p class='text-danger'>Lỗi tạo thương hiệu: " + e.getMessage() + "</p>");
                    request.getRequestDispatcher("/WEB-INF/views/admin/brand/create-brand.jsp").forward(request, response);
                }
                break;

            case "update":
                request.setAttribute("currentAction", "brandForm");
                try {
                    long id = Long.parseLong(request.getParameter("id"));
                    String name = request.getParameter("name");
                    String description = request.getParameter("description");
                    boolean isActive = request.getParameter("isActive") != null && request.getParameter("isActive").equals("true");
                    String existingLogoUrl = request.getParameter("logoUrl"); // For fallback if no new file is uploaded
                    String logoUrl = null;

                    if (name == null || name.trim().isEmpty()) {
                        throw new IllegalArgumentException("Brand name is required");
                    }

                    // Handle logo file upload
                    Part filePart = request.getPart("logo");
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
                                        "width", 400, // Smaller size for logos
                                        "crop", "limit",
                                        "folder", "brands"
                                ));
                                logoUrl = (String) uploadResult.get("secure_url");
                                System.out.println("Uploaded logo URL: " + logoUrl);
                                tempFile.delete();
                            } else {
                                throw new IllegalStateException("Cloudinary not initialized!");
                            }
                        } catch (IOException | IllegalStateException e) {
                            System.err.println("Error processing logo file: " + e.getMessage());
                            if (tempFile != null) {
                                tempFile.delete();
                            }
                            throw e;
                        }
                    } else if (existingLogoUrl != null && !existingLogoUrl.trim().isEmpty()) {
                        logoUrl = existingLogoUrl; // Use existing URL if no new file is uploaded
                    } else {
                        throw new IllegalArgumentException("A logo image is required");
                    }

                    Brand brand = new Brand();
                    brand.setBrandId(id);
                    brand.setName(name);
                    brand.setDescription(description);
                    brand.setLogoUrl(logoUrl);
                    brand.setActive(isActive);
                    brand.setCreatedAt(new Date()); // Consider fetching from DB to preserve original created_at

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
                    System.err.println("Error updating brand: " + e.getMessage());
                    request.setAttribute("err", "<p class='text-danger'>Lỗi cập nhật thương hiệu: " + e.getMessage() + "</p>");
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