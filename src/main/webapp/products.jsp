<%@page import="java.math.BigDecimal"%>
<%@page import="model.Product"%>
<%@page import="dao.ProductDAO"%>
<%@page import="model.Users"%>
<%@page import="model.Category"%>
<%@page import="model.Brand"%>
<%@page import="java.util.List"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="java.text.DecimalFormatSymbols"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    List<Product> list = (List<Product>) request.getAttribute("list");
    String msg = (String) request.getAttribute("msg");
    String err = (String) request.getAttribute("err");
%>
<%!
    // Method to format price with thousand separators and two decimal places in Vietnamese format
    private String formatPrice(BigDecimal price) {
        if (price == null) {
            return "N/A";
        }
        DecimalFormatSymbols symbols = new DecimalFormatSymbols();
        symbols.setDecimalSeparator(',');
        symbols.setGroupingSeparator('.');
        DecimalFormat df = new DecimalFormat("#,###.##", symbols);
        return df.format(price);
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Products List</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
</head>
<body>
    <div class="container">
        <!-- Thanh điều hướng -->
        <nav class="navbar navbar-light bg-light px-3">
            <a class="navbar-brand" href="#">ClothingStore</a>
            <div class="ms-auto">
                <a class="text-dark me-3 text-decoration-none" href="#">Products</a>
                <span class="text-dark">Hi, Admin, <a class="text-dark text-decoration-none" href="Logout">logout</a></span>
            </div>
        </nav>

        <h1 style="margin-top: 45px;">Products List</h1>
        <!-- Form lọc -->
        <form action="${pageContext.request.contextPath}/ProductManager" method="get" class="mb-3">
            <input type="hidden" name="action" value="filter">
            <div class="row g-3">
                <div class="col-md-2">
                    <select name="categoryId" class="form-select">
                        <option value="">All Categories</option>
                        <% 
                            List<Category> categories = (List<Category>) request.getAttribute("categories");
                            if (categories != null) {
                                for (Category category : categories) {
                        %>
                            <option value="<%= category.getCategoryId() %>"><%= category.getName() %></option>
                        <% 
                                }
                            }
                        %>
                    </select>
                </div>
                <div class="col-md-2">
                    <select name="brandId" class="form-select">
                        <option value="">All Brands</option>
                        <% 
                            List<Brand> brands = (List<Brand>) request.getAttribute("brands");
                            if (brands != null) {
                                for (Brand brand : brands) {
                        %>
                            <option value="<%= brand.getBrandId() %>"><%= brand.getName() %></option>
                        <% 
                                }
                            }
                        %>
                    </select>
                </div>
                <div class="col-md-2">
                    <input type="text" name="size" class="form-control" placeholder="Size">
                </div>
                <div class="col-md-2">
                    <input type="text" name="color" class="form-control" placeholder="Color">
                </div>
                <div class="col-md-2">
                    <input type="text" name="minPrice" class="form-control" placeholder="Min Price">
                </div>
                <div class="col-md-2">
                    <input type="text" name="maxPrice" class="form-control" placeholder="Max Price">
                </div>
                <div class="col-md-2">
                    <button type="submit" class="btn btn-primary"><i class="bi bi-funnel"></i> Filter</button>
                </div>
            </div>
        </form>
        <!-- Nút tạo mới -->
        <div class="mb-2 text-end">
            <a class="btn btn-success" href="${pageContext.request.contextPath}/ProductManager?action=create"><i class="bi bi-file-earmark-plus"></i> Create</a>
        </div>
        <% if (msg != null && !msg.isEmpty()) { %>
            <p class="text-success"><%= msg %></p>
        <% } %>
        <% if (err != null && !err.isEmpty()) { %>
            <p class="text-danger"><%= err %></p>
        <% } %>
        <% if (list != null && !list.isEmpty()) { %>
        <table class="table table-striped table-hover">
            <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Price</th>
                <th>Category</th>
                <th>Brand</th>
                <th>Material</th>
                <th>Status</th>
                <th>Action</th>
            </tr>
            <% for (Product product : list) { %>
            <tr>
                <td><%= product.getProductId() %></td>
                <td><a href="${pageContext.request.contextPath}/ProductManager?action=detail&id=<%= product.getProductId() %>"><%= product.getName() %></a></td>
                <td><%= formatPrice(product.getPrice()) %>đ</td>
                <td><%= product.getCategory() != null ? product.getCategory().getName() : "N/A" %></td>
                <td><%= product.getBrand() != null ? product.getBrand().getName() : "N/A" %></td>
                <td><%= product.getMaterial() != null ? product.getMaterial() : "N/A" %></td>
                <td><%= product.getStatus() %></td>
                <td>
                    <a href="${pageContext.request.contextPath}/ProductManager?action=update&id=<%= product.getProductId() %>" class="btn btn-primary"><i class="bi bi-tools"></i> Edit</a>
                    <a href="${pageContext.request.contextPath}/ProductManager?action=delete&id=<%= product.getProductId() %>" class="btn btn-danger" 
                       onclick="return confirm('Are you sure you want to delete <%= product.getName() %>?')"><i class="bi bi-trash"></i> Delete</a>
                </td>
            </tr>
            <% } %>
        </table>
        <% } else { %>
            <p>No Data!</p>
        <% } %>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
</body>
</html>