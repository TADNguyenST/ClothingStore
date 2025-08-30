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
import java.util.Locale;
import model.ProductImage;

public class WishlistController extends HttpServlet {

    private ProductFavoriteDAO favoriteDAO;
    private ProductDAO productDAO;

    @Override
    public void init() throws ServletException {
        favoriteDAO = new ProductFavoriteDAO();
        productDAO = new ProductDAO(); // kiểm tra tồn tại Product
    }

    // ========================= AJAX/JSON helper =========================
    private boolean wantsJson(HttpServletRequest req) {
        String accept = req.getHeader("Accept");
        String xrw = req.getHeader("X-Requested-With");
        return (accept != null && accept.toLowerCase(Locale.ROOT).contains("application/json"))
                || "XMLHttpRequest".equalsIgnoreCase(xrw);
    }

    private void writeJson(HttpServletResponse resp, int status, String json) throws IOException {
        resp.setStatus(status);
        resp.setContentType("application/json; charset=UTF-8");
        resp.setHeader("Cache-Control", "no-store");
        resp.getWriter().write(json);
    }
    // ===================================================================

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Long customerIdL = getUserIdFromSession(session);
        boolean json = wantsJson(request);

        if (customerIdL == null) {
            if (json) {
                writeJson(response, HttpServletResponse.SC_UNAUTHORIZED, "{\"ok\":false,\"message\":\"LOGIN_REQUIRED\"}");
            } else {
                response.sendRedirect(request.getContextPath() + "/Login");
            }
            return;
        }
        int customerId = customerIdL.intValue();

        String action = request.getParameter("action");
        String productIdStr = request.getParameter("productId");

        if (action == null || productIdStr == null) {
            if (json) {
                writeJson(response, HttpServletResponse.SC_BAD_REQUEST, "{\"ok\":false,\"message\":\"MISSING_PARAMS\"}");
            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing parameters");
            }
            return;
        }

        try {
            int productId = Integer.parseInt(productIdStr);
            boolean wished = false;

            switch (action.toLowerCase(Locale.ROOT)) {
                case "toggle": {
                    // nếu đã tồn tại -> xóa, ngược lại -> thêm
                    boolean exists = favoriteDAO.exists(customerId, productId);
                    if (exists) {
                        favoriteDAO.deleteFromWishlist(customerId, productId);
                        wished = false;
                    } else {
                        Product product = productDAO.getProductById(productId);
                        if (product == null) {
                            if (json) {
                                writeJson(response, HttpServletResponse.SC_NOT_FOUND, "{\"ok\":false,\"message\":\"PRODUCT_NOT_FOUND\"}");
                            } else {
                                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Product not found");
                            }
                            return;
                        }
                        ProductFavorite pf = new ProductFavorite();
                        pf.setCustomerId(customerId);
                        pf.setProductId(productId);
                        favoriteDAO.addToWishlist(pf);
                        wished = true;
                    }
                    break;
                }

                case "add": {
                    Product product = productDAO.getProductById(productId);
                    if (product != null && !favoriteDAO.exists(customerId, productId)) {
                        ProductFavorite pf = new ProductFavorite();
                        pf.setCustomerId(customerId);
                        pf.setProductId(productId);
                        favoriteDAO.addToWishlist(pf);
                    }
                    wished = true;
                    break;
                }

                case "remove": {
                    favoriteDAO.deleteFromWishlist(customerId, productId);
                    wished = false;
                    break;
                }

                default:
                    if (json) {
                        writeJson(response, HttpServletResponse.SC_BAD_REQUEST, "{\"ok\":false,\"message\":\"INVALID_ACTION\"}");
                    } else {
                        response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unsupported action: " + action);
                    }
                    return;
            }

            int count = favoriteDAO.countByUser(customerId);

            if (json) {
                String resJson = String.format(Locale.US,
                        "{\"ok\":true,\"wished\":%s,\"count\":%d}",
                        wished ? "true" : "false", count);
                writeJson(response, HttpServletResponse.SC_OK, resJson);
            } else {
                // hành vi cũ: quay lại trang trước
                String referer = request.getHeader("Referer");
                response.sendRedirect(referer != null ? referer : request.getContextPath() + "/home");
            }

        } catch (NumberFormatException e) {
            if (json) {
                writeJson(response, HttpServletResponse.SC_BAD_REQUEST, "{\"ok\":false,\"message\":\"INVALID_PRODUCT_ID\"}");
            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid product ID");
            }
        } catch (Exception e) {
            e.printStackTrace();
            if (json) {
                writeJson(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "{\"ok\":false,\"message\":\"SERVER_ERROR\"}");
            } else {
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error processing wishlist action");
            }
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Long customerIdL = getUserIdFromSession(session);

        if (customerIdL == null) {
            if (wantsJson(request)) {
                writeJson(response, HttpServletResponse.SC_UNAUTHORIZED, "{\"ok\":false,\"message\":\"LOGIN_REQUIRED\"}");
            } else {
                response.sendRedirect(request.getContextPath() + "/Login");
            }
            return;
        }
        int customerId = customerIdL.intValue();

        String action = request.getParameter("action");
        if (action == null || action.isEmpty()) {
            action = "view";
        }

        try {
            switch (action.toLowerCase(Locale.ROOT)) {
                case "view": {
                    List<ProductFavorite> wishlist = favoriteDAO.getWishlistByUserId(customerIdL);
                    List<Product> wishlistProducts = new ArrayList<>();
                    for (ProductFavorite item : wishlist) {
                        Product product = productDAO.getProductById(item.getProductId());
                        if (product != null) {
                            // nạp list ảnh
                            List<ProductImage> imgs = productDAO.getProductImagesByProductId(product.getProductId());
                            product.setImages(imgs);

                            // nếu imageUrl trống thì lấy ảnh chính trong list (ưu tiên is_main)
                            if (product.getImageUrl() == null || product.getImageUrl().isEmpty()) {
                                if (imgs != null && !imgs.isEmpty()) {
                                    ProductImage main = imgs.stream()
                                            .filter(ProductImage::isMain)
                                            .findFirst()
                                            .orElse(imgs.get(0));
                                    product.setImageUrl(main.getImageUrl());
                                }
                            }
                            wishlistProducts.add(product);
                        }
                    }
                    request.setAttribute("wishlistProducts", wishlistProducts);
                    request.getRequestDispatcher("/WEB-INF/views/customer/wishlist/wishlist.jsp")
                            .forward(request, response);
                    break;
                }

                case "remove": {
                    int productId = Integer.parseInt(request.getParameter("productId"));
                    favoriteDAO.deleteFromWishlist(customerId, productId);
                    response.sendRedirect("wishlist?action=view");
                    break;
                }

                // tiện ích: trả về count dạng JSON (dùng cho header badge nếu cần)
                case "count": {
                    int count = favoriteDAO.countByUser(customerId);
                    writeJson(response, HttpServletResponse.SC_OK,
                            String.format(Locale.US, "{\"ok\":true,\"count\":%d}", count));
                    break;
                }

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
        }
        if (userIdObj instanceof Integer) {
            return ((Integer) userIdObj).longValue();
        }
        return null;
    }
}
