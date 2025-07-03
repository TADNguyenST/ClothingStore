/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller.customer;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import dao.CustomerDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.sql.Date;
import java.time.LocalDate;
import java.time.Period;
import java.util.Map;
import model.Customer;
import model.Users;

/**
 *
 * @author Khoa
 */
@WebServlet(name="EditProfileContronller", urlPatterns={"/EditProfile"})
@MultipartConfig
public class EditProfileController extends HttpServlet {
    
    private final CustomerDAO customerDAO = new CustomerDAO();
    private final Cloudinary cloudinary = new Cloudinary(ObjectUtils.asMap(
        "cloud_name", "da36bkpx5",
        "api_key", "342541776882536",
        "api_secret", "F_90gUaX6jfD8yJI8FxCY1Hurbg"
    ));
   
    /** 
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code> methods.
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login");
            return;
        }

        Users user = (Users) session.getAttribute("user");
        Customer customer = customerDAO.getCustomerByUserId(user.getUserId());

        if (request.getMethod().equalsIgnoreCase("GET")) {
            request.setAttribute("user", user);
            request.setAttribute("customer", customer);
            request.getRequestDispatcher("/WEB-INF/views/customer/profile/edit-profile.jsp").forward(request, response);
            return;
        }

        // POST logic
        String fullName = request.getParameter("full_name");
        String phone = request.getParameter("phone_number");
        String gender = request.getParameter("gender");
        String birthDateStr = request.getParameter("birth_date");

        String error = null;
        if (fullName == null || fullName.trim().isEmpty() ||
            phone == null || phone.trim().isEmpty() ||
            gender == null || gender.trim().isEmpty() ||
            birthDateStr == null || birthDateStr.trim().isEmpty()) {
            error = "All fields (except avatar) are required.";
        } else if (!phone.matches("^\\d{10}$")) {
            error = "Phone number must be exactly 10 digits and contain only numbers.";
        } else {
            try {
                LocalDate birthDate = Date.valueOf(birthDateStr).toLocalDate();
                LocalDate today = LocalDate.now();

                if (birthDate.isAfter(today)) {
                    error = "Birth date must not be in the future.";
                } else {
                    int age = Period.between(birthDate, today).getYears();
                    if (age < 13) {
                        error = "Minimum age is 13.";
                    } else if (age > 120) {
                        error = "Maximum age is 120.";
                    } else {
                        customer.setBirthDate(Date.valueOf(birthDate));
                    }
                }
            } catch (IllegalArgumentException e) {
                error = "Invalid birth date format. Please use YYYY-MM-DD.";
            }
        }

        if (error != null) {
            request.setAttribute("err", error);
            request.setAttribute("user", user);
            request.setAttribute("customer", customer);
            request.getRequestDispatcher("/WEB-INF/views/customer/profile/edit-profile.jsp").forward(request, response);
            return;
        }

        user.setFullName(fullName);
        user.setPhoneNumber(phone);
        customer.setGender(gender);

        Part avatarPart = request.getPart("avatar");
        if (avatarPart != null && avatarPart.getSize() > 0) {
            File tempFile = File.createTempFile("avatar", avatarPart.getSubmittedFileName());
            try (InputStream input = avatarPart.getInputStream();
                 FileOutputStream output = new FileOutputStream(tempFile)) {
                byte[] buffer = new byte[1024];
                int len;
                while ((len = input.read(buffer)) != -1) {
                    output.write(buffer, 0, len);
                }
            }

            try {
                Map uploadResult = cloudinary.uploader().upload(tempFile, ObjectUtils.asMap(
                    "quality", "auto",
                    "fetch_format", "auto",
                    "folder", "avatars"
                ));
                String avatarUrl = (String) uploadResult.get("secure_url");
                customer.setAvatarUrl(avatarUrl);
            } catch (Exception e) {
                request.setAttribute("err", "Image upload failed: " + e.getMessage());
                request.setAttribute("user", user);
                request.setAttribute("customer", customer);
                tempFile.delete();
                request.getRequestDispatcher("/WEB-INF/views/customer/profile/edit-profile.jsp").forward(request, response);
                return;
            } finally {
                tempFile.delete();
            }
        }

        if (customerDAO.updateCustomerProfile(user, customer)) {
            session.setAttribute("user", user);
            request.setAttribute("success", "Profile updated successfully!");
        } else {
            request.setAttribute("err", "Failed to update profile.");
        }

        request.setAttribute("user", user);
        request.setAttribute("customer", customer);
        request.getRequestDispatcher("/WEB-INF/views/customer/profile/edit-profile.jsp").forward(request, response);
    } 

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /** 
     * Handles the HTTP <code>GET</code> method.
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        processRequest(request, response);
    } 

    /** 
     * Handles the HTTP <code>POST</code> method.
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        processRequest(request, response);
    }

    /** 
     * Returns a short description of the servlet.
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Edit Profile for Profie Page";
    }// </editor-fold>

}
