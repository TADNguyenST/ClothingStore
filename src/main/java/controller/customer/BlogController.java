package controller.customer;

import dao.BlogDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import model.Blog;

import java.io.IOException;
import java.util.List;

public class BlogController extends HttpServlet {

    private BlogDAO blogDAO;

    @Override
    public void init() throws ServletException {
        blogDAO = new BlogDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");

        try {
            if (idParam != null && !idParam.isEmpty()) {
                // === Display blog detail ===
                try {
                    long blogId = Long.parseLong(idParam);
                    Blog blog = blogDAO.getBlogById(blogId);

                    if (blog == null || !"Published".equalsIgnoreCase(blog.getStatus())) {
                        request.setAttribute("error", "The requested blog post does not exist or is not published.");
                        request.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(request, response);
                        return;
                    }

                    request.setAttribute("blog", blog);
                    request.getRequestDispatcher("/WEB-INF/views/public/blog/blog-details.jsp").forward(request, response);
                } catch (NumberFormatException ex) {
                    request.setAttribute("error", "Invalid blog ID format.");
                    request.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(request, response);
                }

            } else {
                // === Display paginated blog list ===
                int page = 1;
                int limit = 6; // number of blogs per page
                String pageParam = request.getParameter("page");

                if (pageParam != null) {
                    try {
                        page = Integer.parseInt(pageParam);
                        if (page < 1) {
                            page = 1;
                        }
                    } catch (NumberFormatException e) {
                        page = 1;
                    }
                }

                int totalBlogs = blogDAO.countPublishedBlogs();
                int totalPages = (int) Math.ceil((double) totalBlogs / limit);
                int offset = (page - 1) * limit;

                List<Blog> blogs = blogDAO.getPublishedBlogsByPage(offset, limit);

                request.setAttribute("blogs", blogs);
                request.setAttribute("page", page);
                request.setAttribute("totalPages", totalPages);

                request.getRequestDispatcher("/WEB-INF/views/public/blog/blog-list.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "An error occurred while processing the blog request.");
            request.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(request, response);
        }
    }
}
