package controller.staff;

import dao.BlogDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Blog;

import java.io.IOException;
import java.sql.Timestamp;

public class StaffBlogController extends HttpServlet {

    private BlogDAO blogDAO;

    @Override
    public void init() throws ServletException {
        blogDAO = new BlogDAO(); // DAO tự mở kết nối bên trong
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/staff/blog/blog-form.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

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

            Timestamp now = new Timestamp(System.currentTimeMillis());

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
            blog.setCreatedAt(now);
            blog.setUpdatedAt(now);
            blog.setPublishedAt(now);

            blogDAO.insert(blog);

            // Sau khi thêm xong, chuyển hướng về danh sách
            response.sendRedirect("StaffBlogListController");

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi khi tạo blog: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/staff/blog/blog-form.jsp").forward(request, response);
        }
    }
}
