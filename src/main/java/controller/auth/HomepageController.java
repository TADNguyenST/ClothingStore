package controller.auth;

import dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Product;

import java.io.IOException;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class HomepageController extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

   
        List<Product> newArrivals = Collections.emptyList();
        List<Product> bestSellers = Collections.emptyList(); 
        Map<Long, Integer> availableMap = new HashMap<>();

        try {
           
            List<Product> tmpNew = productDAO.getProductIsNew();
            if (tmpNew != null) {
                newArrivals = tmpNew;
            }

            List<Product> tmpBest = productDAO.getBestSellers(4); 
            if (tmpBest != null) {
                bestSellers = tmpBest;
            }

            System.out.println("[HomepageController] newProducts.size = " + newArrivals.size());
            System.out.println("[HomepageController] bestSellers.size = " + bestSellers.size());

           
            for (Product p : newArrivals) {
                if (p == null) continue;

                Long productId = null;
                try { productId = p.getProductId(); } catch (Exception ignore) {}
                Integer qtyObj = null;
                try { qtyObj = p.getQuantity(); } catch (Exception ignore) {}

                int available = (qtyObj == null ? 0 : qtyObj);
                if (productId != null) {
                    availableMap.put(productId, available);
                }

                try {
                    System.out.println("[HomepageController][New] PID=" + productId
                            + ", DefaultVariantId=" + String.valueOf(p.getDefaultVariantId())
                            + ", Qty=" + available
                            + ", StockStatus=" + String.valueOf(p.getStockStatus()));
                } catch (Exception ignore) {}
            }

          
            for (Product p : bestSellers) {
                if (p == null) continue;
                try {
                    System.out.println("[HomepageController][BestSeller] PID=" + p.getProductId()
                            + ", Qty=" + p.getQuantity());
                } catch (Exception ignore) {}
            }

        } catch (Exception e) {
            System.err.println("[HomepageController] ERROR: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("homeError", "Could not load homepage products at the moment.");
        }

        
        request.setAttribute("newProducts", newArrivals);
        request.setAttribute("bestSellers", bestSellers); 
        request.setAttribute("availableMap", availableMap);
        request.setAttribute("pageTitle", "Homepage");

        request.getRequestDispatcher("/WEB-INF/views/public/home.jsp").forward(request, response);
    }
}
