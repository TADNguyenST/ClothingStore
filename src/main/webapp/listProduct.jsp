<%@page import="java.text.DecimalFormat"%>
<%@page import="model.Product"%>
<%@page import="java.util.List"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    DecimalFormat df = new DecimalFormat("#,###.##");
    List<Product> listProduct = (List<Product>) request.getAttribute("listProduct");
    String deleteMessage = (String) request.getAttribute("deleteMessage");
%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Product List</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/styleProductManager.css">
</head>
<body>
    <div class="container">
        <div>
            <a href="${pageContext.request.contextPath}/">Home</a> / <span>Product Information</span>
        </div>
        <h1 style="margin-top: 45px;">Product Information</h1>
        
        <!-- Display and remove delete message -->
        <%
            if (deleteMessage != null) {
        %>
            <div class="alert alert-info alert-dismissible fade show" role="alert">
                <%= deleteMessage %>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
            <% request.removeAttribute("deleteMessage"); %> <!-- Remove attribute after display -->
        <%
            }
        %>
        
        <div class="mb-2 text-end">
            <a class="btn btn-success" href="${pageContext.request.contextPath}/ProductManager?action=create">
                <i class="bi bi-file-earmark-plus"></i> Create
            </a>
        </div>
        <%
            if (listProduct == null) {
                out.println("<p>Error: Unable to load product list!</p>");
            } else if (listProduct.isEmpty()) {
                out.println("<p>No data available!</p>");
            } else {
        %>
        <table class="table table-striped table-hover">
            <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Description</th>
                <th>Price</th>
                <th>Quantity</th>
                <th>Supplier</th>
                <th>Category</th>
                <th>Brand</th>
                <th>Material</th>
                <th>Status</th>
                <th>Action</th>
            </tr>
            <%
                for (Product pro : listProduct) {
            %>
            <tr>
                <td><%= pro.getProductId() %></td>
                <td><%= pro.getName() != null ? pro.getName() : "Not available" %></td>
                <td><%= pro.getDescription() != null ? pro.getDescription() : "Not available" %></td>
                <td><%= pro.getPrice() != 0 ? df.format(pro.getPrice()) : "0" %> VND</td>
                <td><%= pro.getStockQuantity() != 0 ? pro.getStockQuantity() : "0" %></td>
                <td><%= pro.getSupplier() != null && pro.getSupplier().getName() != null ? pro.getSupplier().getName() : "Not available" %></td>
                <td><%= pro.getCategory() != null && pro.getCategory().getName() != null ? pro.getCategory().getName() : "Not available" %></td>
                <td><%= pro.getBrand() != null && pro.getBrand().getName() != null ? pro.getBrand().getName() : "Not available" %></td>
                <td><%= pro.getMaterial() != null ? pro.getMaterial() : "Not available" %></td>
                <td><%= pro.getStatus() != null ? pro.getStatus() : "Not available" %></td>
                <td>
                    <a href="${pageContext.request.contextPath}/ProductManager?action=update&id=<%= pro.getProductId() %>" class="btn btn-primary">
                        <i class="bi bi-tools"></i> Edit
                    </a>
                    <a href="${pageContext.request.contextPath}/ProductManager?action=delete&id=<%= pro.getProductId() %>&confirm=ok" 
                       class="btn btn-danger" 
                       onclick="return confirm('Are you sure you want to delete this product?');">
                        <i class="bi bi-trash"></i> Delete
                    </a>
                </td>
            </tr>
            <% } %>
        </table>
        <% } %>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>