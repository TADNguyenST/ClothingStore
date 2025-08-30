package controller.auth;

import dao.ProductDAO;
import dao.ProductFavoriteDAO;      // ✅ thêm
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import model.Product;

import java.io.IOException;
import java.util.*;
import java.util.Set;               // ✅ thêm

public class HomepageController extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAO();
    private final ProductFavoriteDAO favoriteDAO = new ProductFavoriteDAO(); // ✅ thêm

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Product> newArrivals = Collections.emptyList();
        List<Product> bestSellers = Collections.emptyList();
        Map<Long, Integer> availableMap = new HashMap<>();

        try {
            List<Product> tmpNew  = productDAO.getProductIsNew();
            if (tmpNew  != null) newArrivals = tmpNew;

            List<Product> tmpBest = productDAO.getBestSellers(8);
            if (tmpBest != null) bestSellers = tmpBest;

            for (Product p : newArrivals) {
                if (p == null) continue;
                Long pid = p.getProductId();
                Integer q = p.getQuantity();
                availableMap.put(pid, q == null ? 0 : q);
            }
        } catch (Exception e) {
            System.err.println("[HomepageController] ERROR: " + e.getMessage());
            request.setAttribute("homeError", "Could not load homepage products at the moment.");
        }

        // ✅ LẤY USER ID TỪ SESSION & NẠP WISHLIST IDS
        Set<Integer> wishlistIds = Collections.emptySet();
        try {
            HttpSession session = request.getSession(false);
            Long customerId = null;
            if (session != null) {
                Object uid = session.getAttribute("userId"); // đúng với WishlistController của bạn
                if (uid instanceof Long)    customerId = (Long) uid;
                else if (uid instanceof Integer) customerId = ((Integer) uid).longValue();
            }
            if (customerId != null) {
                wishlistIds = favoriteDAO.getWishlistProductIds(customerId);
            }
        } catch (Exception ex) {
            System.err.println("[HomepageController] wishlistIds error: " + ex.getMessage());
        }

        request.setAttribute("newProducts", newArrivals);
        request.setAttribute("bestSellers", bestSellers);
        request.setAttribute("availableMap", availableMap);
        request.setAttribute("wishlistProductIds", wishlistIds);   // ✅ QUAN TRỌNG
        request.setAttribute("pageTitle", "Homepage");

        request.getRequestDispatcher("/WEB-INF/views/public/home.jsp").forward(request, response);
    }
}
