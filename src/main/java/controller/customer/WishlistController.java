package controller.customer;

import dao.ProductDAO;
import dao.ProductFavoriteDAO;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import model.Product;
import model.ProductFavorite;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class WishlistController extends HttpServlet {

    private ProductFavoriteDAO favoriteDAO;
    private ProductDAO productDAO;

    @Override
    public void init() throws ServletException {
        favoriteDAO = new ProductFavoriteDAO();
        productDAO = new ProductDAO(); // dùng để lấy Product nếu cần kiểm tra tồn tại
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Long customerId = getUserIdFromSession(session);

        if (customerId == null) {
            response.sendRedirect(request.getContextPath() + "/Login");
            return;
        }

        String action = request.getParameter("action");
        String productIdStr = request.getParameter("productId");

        if (action == null || productIdStr == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing parameters");
            return;
        }

        try {
            int productId = Integer.parseInt(productIdStr);

            switch (action.toLowerCase()) {
                case "add":
                    Product product = productDAO.getProductById(productId);
                    if (product != null) {
                        ProductFavorite pf = new ProductFavorite();
                        pf.setCustomerId(customerId.intValue());
                        pf.setProductId(productId);
                        favoriteDAO.addToWishlist(pf);
                    }
                    break;

                case "remove":
                    favoriteDAO.deleteFromWishlist(customerId.intValue(), productId);
                    break;

                default:
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unsupported action: " + action);
                    return;
            }

            // Quay về trang trước
            String referer = request.getHeader("Referer");
            response.sendRedirect(referer != null ? referer : request.getContextPath() + "/home");

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid product ID");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error processing wishlist action");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Long customerId = getUserIdFromSession(session);

        if (customerId == null) {
            response.sendRedirect(request.getContextPath() + "/Login");
            return;
        }

        String action = request.getParameter("action");
        if (action == null || action.isEmpty()) {
            action = "view";
        }

        try {
            switch (action.toLowerCase()) {
                case "view":
                    List<ProductFavorite> wishlist = favoriteDAO.getWishlistByUserId(customerId);
                    List<Product> wishlistProducts = new ArrayList<>();

                    for (ProductFavorite item : wishlist) {
                        Product product = productDAO.getProductById(item.getProductId());
                        if (product != null) {
                            wishlistProducts.add(product);
                        }
                    }

                    request.setAttribute("wishlistProducts", wishlistProducts);
                    request.getRequestDispatcher("/WEB-INF/views/customer/wishlist/wishlist.jsp").forward(request, response);
                    break;

                case "remove":
                    int productId = Integer.parseInt(request.getParameter("productId"));
                    favoriteDAO.deleteFromWishlist(customerId.intValue(), productId);
                    response.sendRedirect("wishlist?action=view");
                    break;

                default:
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action: " + action);
            }
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid product ID");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error retrieving wishlist");
        }
    }

    private Long getUserIdFromSession(HttpSession session) {
        if (session == null) {
            return null;
        }

        Object userIdObj = session.getAttribute("userId");

        if (userIdObj instanceof Long) {
            return (Long) userIdObj;
        } else if (userIdObj instanceof Integer) {
            return ((Integer) userIdObj).longValue();
        }

        return null;
    }
}
