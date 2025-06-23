<%@page import="java.math.BigDecimal"%>
<%@page import="model.Product"%>
<%@page import="model.Users"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="java.text.DecimalFormatSymbols"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    Product product = (Product) request.getAttribute("data");
    String err = (String) request.getAttribute("err");
%>
<%!
    // Method to format price with thousand separators and two decimal places in Vietnamese format
    private String formatPrice(BigDecimal price) {
    if (price == null) {
        return "N/A";
    }
    DecimalFormatSymbols symbols = new DecimalFormatSymbols();
    symbols.setGroupingSeparator('.');
    symbols.setDecimalSeparator(','); 

   DecimalFormat df = new DecimalFormat("#,##0.##", symbols);// ✅ thêm .00 để luôn có 2 số lẻ
    return df.format(price);
}
%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Product Details</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
</head>
<body>
    <div class="container">
        <nav class="navbar navbar-light bg-light px-3">
            <a class="navbar-brand" href="#">ClothingStore</a>
            <div class="ms-auto">
                <a class="text-dark me-3 text-decoration-none" href="${pageContext.request.contextPath}/ProductManager">Products</a>
                <span class="text-dark">Hi, Admin, <a class="text-dark text-decoration-none" href="Logout">logout</a></span>
            </div>
        </nav>

        <h1 style="margin-top: 45px;">Product Details</h1>
        <% if (err != null && !err.isEmpty()) { %>
            <p class="text-danger"><%= err %></p>
        <% } %>
        <% if (product != null) { %>
            <table class="table table-bordered">
                <tr>
                    <th>ID</th>
                    <td><%= product.getProductId() %></td>
                </tr>
                <tr>
                    <th>Name</th>
                    <td><%= product.getName() %></td>
                </tr>
                <tr>
                    <th>Description</th>
                    <td><%= product.getDescription() != null ? product.getDescription() : "N/A" %></td>
                </tr>
                <tr>
                    <th>Price</th>
                    <td><%= formatPrice(product.getPrice()) %>đ</td>
                </tr>
                <tr>
                    <th>Category</th>
                    <td><%= product.getCategory() != null ? product.getCategory().getName() : "N/A" %></td>
                </tr>
                <tr>
                    <th>Brand</th>
                    <td><%= product.getBrand() != null ? product.getBrand().getName() : "N/A" %></td>
                </tr>
                <tr>
                    <th>Material</th>
                    <td><%= product.getMaterial() != null ? product.getMaterial() : "N/A" %></td>
                </tr>
                <tr>
                    <th>Status</th>
                    <td><%= product.getStatus() %></td>
                </tr>
                <tr>
                    <th>Variants</th>
                    <td>
                        <% 
                            java.util.List variants = (java.util.List) product.getClass().getMethod("getVariants").invoke(product);
                            if (variants != null && !variants.isEmpty()) {
                                for (Object variant : variants) {
                                    
                                   
                                    String sku = (String) variant.getClass().getMethod("getSku").invoke(variant);
                        %>
                            SKU: <%= sku %><br>
                        <% 
                                }
                            } else {
                        %>
                            No variants available.
                        <% 
                            }
                        %>
                    </td>
                </tr>
                <tr>
                    <th>Images</th>
                    <td>
                        <% 
                            java.util.List images = (java.util.List) product.getClass().getMethod("getImages").invoke(product);
                            if (images != null && !images.isEmpty()) {
                                for (Object image : images) {
                                    String imageUrl = (String) image.getClass().getMethod("getImageUrl").invoke(image);
                        %>
                            <img src="<%= imageUrl %>" alt="Product Image" width="100"><br>
                        <% 
                                }
                            } else {
                        %>
                            No images available.
                        <% 
                            }
                        %>
                    </td>
                </tr>
            </table>
            <a href="${pageContext.request.contextPath}/ProductManager" class="btn btn-secondary">Back to Products</a>
        <% } else { %>
            <p>No product found!</p>
        <% } %>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
</body>
</html>