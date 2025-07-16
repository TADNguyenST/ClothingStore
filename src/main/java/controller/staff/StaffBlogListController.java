package controller.staff;

import dao.BlogDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Blog;

import java.io.IOException;
import java.util.List;

/**
 * Servlet hiển thị danh sách blog cho staff.
 */
public class StaffBlogListController extends HttpServlet {

    private BlogDAO blogDAO;

    @Override
    public void init() throws ServletException {
        blogDAO = new BlogDAO(); // Không cần truyền Connection nếu BlogDAO tự mở kết nối
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            List<Blog> blogs = blogDAO.getAllBlogs(); // Sử dụng đúng tên phương thức đã định nghĩa
            request.setAttribute("blogs", blogs);
            request.getRequestDispatcher("/WEB-INF/views/staff/blog/blog-list.jsp")
                    .forward(request, response);
        } catch (Exception e) {
            e.printStackTrace(); // Log lỗi chi tiết
            request.setAttribute("error", "Lỗi khi lấy danh sách bài viết.");
            request.getRequestDispatcher("/WEB-INF/views/error.jsp")
                    .forward(request, response);
        }
    }
}
