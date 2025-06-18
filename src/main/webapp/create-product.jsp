<%@page import="java.math.BigDecimal"%>
<%@page import="model.Users"%>
<%@page import="model.Category"%>
<%@page import="model.Brand"%>
<%@page import="java.util.List"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="java.text.DecimalFormatSymbols"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
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
    <title>Add New Product</title>
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

        <h1 style="margin-top: 45px;">Add New Product</h1>
        <% if (err != null && !err.isEmpty()) { %>
            <p class="text-danger"><%= err %></p>
        <% } %>
        <form action="${pageContext.request.contextPath}/ProductManager" method="post" class="mt-3">
            <input type="hidden" name="action" value="create">
            <div class="mb-3">
                <label class="form-label">Name</label>
                <input type="text" name="name" class="form-control" required>
            </div>
            <div class="mb-3">
                <label class="form-label">Description</label>
                <textarea name="description" class="form-control"></textarea>
            </div>
            <div class="mb-3">
                <label class="form-label">Price</label>
                <input type="text" name="price" class="form-control" required>
            </div>
            <div class="mb-3">
                <label class="form-label">Category</label>
                <select name="categoryId" class="form-select" required>
                    <option value="">Select a category</option>
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
            <div class="mb-3">
                <label class="form-label">Brand</label>
                <select name="brandId" class="form-select" required>
                    <option value="">Select a brand</option>
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
            <div class="mb-3">
                <label class="form-label">Material</label>
                <input type="text" name="material" class="form-control">
            </div>
            <div class="mb-3">
                <label class="form-label">Status</label>
                <select name="status" class="form-select">
                    <option value="Active">Active</option>
                    <option value="Discontinued">Discontinued</option>
                </select>
            </div>
            <button type="submit" class="btn btn-primary"><i class="bi bi-save"></i> Add Product</button>
            <a href="${pageContext.request.contextPath}/ProductManager" class="btn btn-secondary">Cancel</a>
        </form>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
</body>
</html>