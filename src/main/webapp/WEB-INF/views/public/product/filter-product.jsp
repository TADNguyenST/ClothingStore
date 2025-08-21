<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="dao.ProductDAO" %>
<%@ page import="model.Brand" %>
<%@ page import="java.util.*" %>
<%
    String categoryId = request.getParameter("categoryId");
    String parentCategoryId = request.getParameter("parentCategoryId");
    List<Brand> brands = (List<Brand>) request.getAttribute("brands");
    List<String> sizes = (List<String>) request.getAttribute("sizes");
    List<String> colors = (List<String>) request.getAttribute("colors");
    if (brands == null || sizes == null || colors == null) {
        try {
            ProductDAO pdao = new ProductDAO();
            if (brands == null) brands = pdao.getBrands();
            if (sizes == null) sizes = pdao.getSizes();
            if (colors == null) colors = pdao.getColors();
        } catch (Exception e) {
            brands = new ArrayList<>();
            sizes = new ArrayList<>();
            colors = new ArrayList<>();
        }
    }
    Set<String> selectedBrandIds = (Set<String>) request.getAttribute("selectedBrandIds");
    if (selectedBrandIds == null) {
        String[] brandArr = request.getParameterValues("brandId");
        selectedBrandIds = new HashSet<>();
        if (brandArr != null) selectedBrandIds.addAll(Arrays.asList(brandArr));
    }
    Set<String> selectedSizes = (Set<String>) request.getAttribute("selectedSizes");
    if (selectedSizes == null) {
        String[] sizeArr = request.getParameterValues("size");
        selectedSizes = new HashSet<>();
        if (sizeArr != null) selectedSizes.addAll(Arrays.asList(sizeArr));
    }
    Set<String> selectedColors = (Set<String>) request.getAttribute("selectedColors");
    if (selectedColors == null) {
        String[] colorArr = request.getParameterValues("color");
        selectedColors = new HashSet<>();
        if (colorArr != null) selectedColors.addAll(Arrays.asList(colorArr));
    }
    String selectedSort = (String) request.getAttribute("selectedSort");
    if (selectedSort == null) selectedSort = request.getParameter("sort");
    String clearUrl = request.getContextPath() + "/ProductFilter";
    if (categoryId != null && !categoryId.trim().isEmpty()) {
        clearUrl += "?categoryId=" + categoryId.trim();
    } else if (parentCategoryId != null && !parentCategoryId.trim().isEmpty()) {
        clearUrl += "?parentCategoryId=" + parentCategoryId.trim();
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <style>
            .filter-card {
                transition: all 0.3s ease;
                box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            }
            .filter-card:hover {
                box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            }
            .filter-section {
                background: #f8f9fa;
                border-radius: 8px;
                padding: 15px;
            }
            .filter-label {
                font-size: 1.1rem;
                font-weight: 600;
                margin-bottom: 10px;
            }
            .scrollable-filter {
                max-height: 200px;
                overflow-y: auto;
                padding-right: 10px;
            }
            .form-check {
                margin-bottom: 8px;
            }
            .btn-apply {
                background-color: #1a1a1a;
                border-color: #1a1a1a;
            }
            .btn-apply:hover {
                background-color: #333;
                border-color: #333;
            }
            @media (max-width: 768px) {
                .filter-section {
                    margin-bottom: 20px;
                }
            }
        </style>
    </head>
    <body>
        <div class="container my-5">
            <div class="filter-card p-4 bg-white rounded-3">
                <h3 class="mb-4 fw-bold">Product Filters</h3>
                <form action="<%= request.getContextPath() %>/ProductFilter" method="get">
                    <% if (categoryId != null && !categoryId.trim().isEmpty()) { %>
                    <input type="hidden" name="categoryId" value="<%= categoryId %>">
                    <% } %>
                    <% if (parentCategoryId != null && !parentCategoryId.trim().isEmpty()) { %>
                    <input type="hidden" name="parentCategoryId" value="<%= parentCategoryId %>">
                    <% } %>
                    <div class="row g-4">
                        <!-- Brand -->
                        <div class="col-12 col-md-4">
                            <div class="filter-section">
                                <label class="filter-label">Brand</label>
                                <div class="scrollable-filter">
                                    <% 
                                        if (brands != null) {
                                            for (Brand b : brands) {
                                                String bid = String.valueOf(b.getBrandId());
                                                boolean checked = selectedBrandIds.contains(bid);
                                    %>
                                    <div class="form-check">
                                        <input class="form-check-input" type="checkbox" name="brandId" id="brand_<%= bid %>" value="<%= bid %>" <%= checked ? "checked" : "" %>>
                                        <label class="form-check-label" for="brand_<%= bid %>"><%= b.getName() %></label>
                                    </div>
                                    <% }
                                        }
                                    %>
                                </div>
                            </div>
                        </div>
                        <!-- Size -->
                        <div class="col-12 col-md-4">
                            <div class="filter-section">
                                <label class="filter-label">Size</label>
                                <div class="scrollable-filter">
                                    <% 
                                        if (sizes != null) {
                                            for (String s : sizes) {
                                                if (s == null) continue;
                                                String sval = s.trim();
                                                if (sval.isEmpty()) continue;
                                                boolean checked = selectedSizes.contains(sval);
                                    %>
                                    <div class="form-check form-check-inline">
                                        <input class="form-check-input" type="checkbox" name="size" id="size_<%= sval %>" value="<%= sval %>" <%= checked ? "checked" : "" %>>
                                        <label class="form-check-label" for="size_<%= sval %>"><%= sval %></label>
                                    </div>
                                    <% }
                                        }
                                    %>
                                </div>
                            </div>
                        </div>
                        <!-- Color -->
                        <div class="col-12 col-md-4">
                            <div class="filter-section">
                                <label class="filter-label">Color</label>
                                <div class="scrollable-filter">
                                    <% 
                                        if (colors != null) {
                                            for (String c : colors) {
                                                if (c == null) continue;
                                                String cval = c.trim();
                                                if (cval.isEmpty()) continue;
                                                boolean checked = selectedColors.contains(cval);
                                    %>
                                    <div class="form-check form-check-inline">
                                        <input class="form-check-input" type="checkbox" name="color" id="color_<%= cval %>" value="<%= cval %>" <%= checked ? "checked" : "" %>>
                                        <label class="form-check-label" for="color_<%= cval %>"><%= cval %></label>
                                    </div>
                                    <% }
                                        }
                                    %>
                                </div>
                            </div>
                        </div>
                                
                                <div class="col-12"><hr></div>
                        <!-- Sort -->
                        <div class="col-12 col-md-4">
                            <div class="filter-section">
                                <label class="filter-label">Sort by Price</label>
                                <select name="sort" class="form-select">
                                    <option value="">Default</option>
                                    <option value="price_asc" <%= "price_asc".equals(selectedSort) ? "selected" : "" %> >Low → High</option>
                                    <option value="price_desc" <%= "price_desc".equals(selectedSort) ? "selected" : "" %> >High → Low</option>
                                </select>
                            </div>
                        </div>
                        <!-- Price Range -->
                        <div class="col-12 col-md-4">
                            <div class="filter-section">
                                <label class="filter-label">Price Range (VNĐ)</label>
                                <div class="input-group mb-2">
                                    <span class="input-group-text">Min</span>
                                    <input type="number" class="form-control" name="minPrice" 
                                           value="<%= request.getParameter("minPrice") != null ? request.getParameter("minPrice") : "" %>" 
                                           placeholder="e.g. 100000">
                                </div>
                                <div class="input-group">
                                    <span class="input-group-text">Max</span>
                                    <input type="number" class="form-control" name="maxPrice" 
                                           value="<%= request.getParameter("maxPrice") != null ? request.getParameter("maxPrice") : "" %>" 
                                           placeholder="e.g. 2000000">
                                </div>
                            </div>
                        </div>

                        <!-- Actions -->
                        <div class="col-12 d-flex gap-3 justify-content-end">
                            <a class="btn btn-outline-secondary" href="<%= clearUrl %>">Clear Filters</a>
                            <button type="submit" class="btn btn-apply text-white">Apply Filters</button>
                        </div>
                    </div> 
                </form>
            </div>
        </div>
    </body>
</html>