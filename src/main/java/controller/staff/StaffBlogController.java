/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.staff;

import dao.BlogDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Date;
import model.Blog;
import util.DBContext;

/**
 *
 * @author ADMIN
 */
public class StaffBlogController extends HttpServlet {

    private BlogDAO blogDAO;
    private DBContext dbContext;

    @Override
    public void init() throws ServletException {
        try {
            dbContext = new DBContext();
            Connection conn = dbContext.getConnection();
            blogDAO = new BlogDAO(conn);
        } catch (SQLException e) {
            throw new ServletException("Failed to initialize BlogDAO: " + e.getMessage(), e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/staff/blog/blog-form.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (blogDAO == null) {
            throw new ServletException("BlogDAO not initialized.");
        }

        try {

            String title = request.getParameter("title");
            String slug = request.getParameter("slug");
            String excerpt = request.getParameter("excerpt");
            String content = request.getParameter("content");
            String thumbnailUrl = request.getParameter("thumbnailUrl");
            String category = request.getParameter("category");
            String tags = request.getParameter("tags");
            String status = request.getParameter("status");
            int staffId = Integer.parseInt(request.getParameter("staffId"));

            Blog blog = new Blog();
            blog.setTitle(title);
            blog.setSlug(slug);
            blog.setExcerpt(excerpt);
            blog.setContent(content);
            blog.setThumbnailUrl(thumbnailUrl);
            blog.setCategory(category);
            blog.setTags(tags);
            blog.setStatus(status);
            blog.setStaffId(staffId);
            blog.setViewCount(0);
            Date now = new Date();
            blog.setCreatedAt(now);
            blog.setUpdatedAt(now);
            blog.setPublishedAt(now);
            blogDAO.insert(blog);

            response.sendRedirect("WEB-INF/views/staff/blog/blog-from.jsp");

        } catch (Exception e) {
            throw new ServletException("Error creating blog post: " + e.getMessage(), e);
        }
    }

    @Override
    public void destroy() {
        if (dbContext != null) {
            dbContext.closeConnection();
        }
    }
}
