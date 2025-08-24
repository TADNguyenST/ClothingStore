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

        // Chuẩn bị biến an toàn
        List<Product> newArrivals = Collections.emptyList();
        Map<Long, Integer> availableMap = new HashMap<>();

        try {
            // 1) Lấy dữ liệu null-safe
            List<Product> tmp = productDAO.getProductIsNew();
            if (tmp != null) {
                newArrivals = tmp;
            }

            System.out.println("[HomepageController] newProducts.size = " + newArrivals.size());

            // 2) Build availableMap (khóa Long để khớp với home.jsp)
            for (Product p : newArrivals) {
                if (p == null) {
                    continue;
                }

                Long productId = null;
                try {
                    productId = p.getProductId();
                } catch (Exception ignore) {
                }
                Integer qtyObj = null;
                try {
                    qtyObj = p.getQuantity();
                } catch (Exception ignore) {
                }

                int available = (qtyObj == null ? 0 : qtyObj);
                if (productId != null) {
                    availableMap.put(productId, available);
                }

                // Log mềm, không để log lỗi làm vỡ trang
                try {
                    System.out.println("[HomepageController] PID=" + String.valueOf(productId)
                            + ", DefaultVariantId=" + String.valueOf(p.getDefaultVariantId())
                            + ", Qty=" + available
                            + ", StockStatus=" + String.valueOf(p.getStockStatus()));
                } catch (Exception ignore) {
                }
            }

        } catch (Exception e) {
            // ❗Không sendError nữa. Ghi log rồi cho trang vẫn render với list rỗng.
            System.err.println("[HomepageController] ERROR: " + e.getMessage());
            e.printStackTrace();
            // Cho view biết có sự cố nhẹ (nếu muốn hiển thị thông báo)
            request.setAttribute("homeError", "Could not load new products at the moment.");
        }

        // 3) Gắn attribute & forward ra trang
        request.setAttribute("newProducts", newArrivals);
        request.setAttribute("availableMap", availableMap);
        request.setAttribute("pageTitle", "Homepage");

        // Không bọc forward trong try/catch nữa để dễ thấy lỗi JSP nếu có
        request.getRequestDispatcher("/WEB-INF/views/public/home.jsp").forward(request, response);
    }
}
