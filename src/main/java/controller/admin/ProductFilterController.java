package controller.admin;

import dao.CategoryDAO;
import dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.Brand;
import model.Product;

import java.io.IOException;
import java.sql.SQLException;
import java.util.*;
import java.util.stream.Collectors;

@WebServlet(name = "ProductFilterController", urlPatterns = {"/ProductFilter"})
public class ProductFilterController extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            //Lấy category 
            String categoryIdStr = request.getParameter("categoryId");
            String parentCategoryIdStr = request.getParameter("parentCategoryId");
            Long categoryId = null;
            List<Long> categoryIds = new ArrayList<>();

            if (categoryIdStr != null && !categoryIdStr.trim().isEmpty()) {
                try {
                    categoryId = Long.parseLong(categoryIdStr.trim());
                    categoryIds.add(categoryId);
                } catch (NumberFormatException ignored) {}
            } else if (parentCategoryIdStr != null && !parentCategoryIdStr.trim().isEmpty()) {
                try {
                    Long parentCategoryId = Long.parseLong(parentCategoryIdStr.trim());
                    CategoryDAO categoryDAO = new CategoryDAO();
                    List<Long> subCategoryIds = categoryDAO.getSubCategoryIds(parentCategoryId);
                    if (subCategoryIds != null && !subCategoryIds.isEmpty()) {
                        categoryIds.addAll(subCategoryIds);
                    } else {
                        categoryIds.add(parentCategoryId);
                    }
                    categoryId = parentCategoryId;
                } catch (NumberFormatException ignored) {}
            }

            //filters
            String[] brandIdsParam = request.getParameterValues("brandId");
            List<Long> brandIds = new ArrayList<>();
            if (brandIdsParam != null) {
                for (String b : brandIdsParam) {
                    if (b != null && !b.trim().isEmpty()) {
                        try {
                            brandIds.add(Long.parseLong(b.trim()));
                        } catch (NumberFormatException ignored) {}
                    }
                }
            }

            String[] sizesParam = request.getParameterValues("size");
            List<String> sizes = new ArrayList<>();
            if (sizesParam != null) {
                for (String s : sizesParam) {
                    if (s != null && !s.trim().isEmpty()) sizes.add(s.trim());
                }
            }

            String[] colorsParam = request.getParameterValues("color");
            List<String> colors = new ArrayList<>();
            if (colorsParam != null) {
                for (String c : colorsParam) {
                    if (c != null && !c.trim().isEmpty()) colors.add(c.trim());
                }
            }

            //sort
            String sort = request.getParameter("sort");
            if (sort == null || !(sort.equals("price_asc") || sort.equals("price_desc"))) {
                sort = null;
            }

            //price range
            String minPriceStr = request.getParameter("minPrice");
            String maxPriceStr = request.getParameter("maxPrice");

            java.math.BigDecimal minPrice = null;
            java.math.BigDecimal maxPrice = null;

            try {
                if (minPriceStr != null && !minPriceStr.trim().isEmpty()) {
                    minPrice = new java.math.BigDecimal(minPriceStr.trim());
                }
                if (maxPriceStr != null && !maxPriceStr.trim().isEmpty()) {
                    maxPrice = new java.math.BigDecimal(maxPriceStr.trim());
                }
            } catch (NumberFormatException ignored) {}

            // Loc ghep
            ProductDAO productDAO = new ProductDAO();
            List<Product> products = productDAO.filterProducts(categoryIds, brandIds, sizes, colors, minPrice, maxPrice, sort);

            List<Brand> brands = productDAO.getBrands();
            List<String> allSizes = productDAO.getSizes();
            List<String> allColors = productDAO.getColors();

            //Set sang JSP
            request.setAttribute("products", products);
            request.setAttribute("categoryId", categoryIdStr);
            request.setAttribute("parentCategoryId", parentCategoryIdStr);
            request.setAttribute("brands", brands);
            request.setAttribute("sizes", allSizes);
            request.setAttribute("colors", allColors);
            request.setAttribute("selectedBrandIds", brandIds.stream().map(String::valueOf).collect(Collectors.toSet()));
            request.setAttribute("selectedSizes", new HashSet<>(sizes));
            request.setAttribute("selectedColors", new HashSet<>(colors));
            request.setAttribute("selectedSort", sort);
            request.setAttribute("minPrice", minPriceStr);
            request.setAttribute("maxPrice", maxPriceStr);

            //Forward sang JSP list
            request.getRequestDispatcher("/WEB-INF/views/public/product/product-list.jsp").forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Database error while filtering products: " + e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Error retrieving products: " + e.getMessage());
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Handles product filtering by color, size, price, brand, and category";
    }
}
