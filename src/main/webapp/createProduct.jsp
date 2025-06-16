<%@page import="dao.SupplierDAO"%>
<%@page import="dao.CategoryDAO"%>
<%@page import="dao.BrandDAO"%>
<%@page import="java.util.List"%>
<%@page import="model.Supplier"%>
<%@page import="model.Category"%>
<%@page import="model.Brand"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Create Product</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styleProductManager.css">
</head>
<body>
    <!-- Try-catch block for header -->
    <%
        try {
    %>
    <!-- Header content (assumed) -->
    <%
        } catch (Exception headerException) {
            out.println("<p style='color: red;'>Error including header: " + headerException.getMessage() + "</p>");
        }
    %>

    <div class="container">
        <div>
            <a href="${pageContext.request.contextPath}/">Home</a> / <span>Create Product</span>
        </div>
        <h1 style="margin-top: 45px;">Create Product</h1>
        <form method="post" action="${pageContext.request.contextPath}/ProductManager?action=create">
            <div class="mb-3">
                <label class="form-label">Product Name</label>
                <input type="text" class="form-control" name="name" id="name" required />
            </div>
            <div class="mb-3">
                <label class="form-label">Description</label>
                <textarea class="form-control" name="description" id="description" rows="4"></textarea>
            </div>
            <div class="mb-3">
                <label class="form-label">Price</label>
                <input type="number" min="0" step="0.01" class="form-control" name="price" id="price" required />
            </div>
            <div class="mb-3">
                <label class="form-label">Stock Quantity</label>
                <input type="number" min="0" class="form-control" name="stockQuantity" id="stockQuantity" required />
            </div>
            <div class="mb-3">
                <label class="form-label">Supplier</label>
                <select class="form-control" name="supplierId" id="supplierId">
                    <option value="">Select Supplier</option>
                    <%
                        SupplierDAO supplierDAO = new SupplierDAO();
                        List<Supplier> suppliers = supplierDAO.getAll();
                        if (suppliers != null) {
                            for (Supplier s : suppliers) {
                                out.println("<option value='" + s.getSupplierId() + "'>" + (s.getName() != null ? s.getName() : "") + "</option>");
                            }
                        }
                    %>
                </select>
            </div>
            <div class="mb-3">
                <label class="form-label">Category</label>
                <select class="form-control" name="categoryId" id="categoryId">
                    <option value="">Select Category</option>
                    <%
                        CategoryDAO categoryDAO = new CategoryDAO();
                        List<Category> categories = categoryDAO.getAll();
                        if (categories != null) {
                            for (Category c : categories) {
                                out.println("<option value='" + c.getCategoryId() + "'>" + (c.getName() != null ? c.getName() : "") + "</option>");
                            }
                        }
                    %>
                </select>
            </div>
            <div class="mb-3">
                <label class="form-label">Brand</label>
                <select class="form-control" name="brandId" id="brandId">
                    <option value="">Select Brand</option>
                    <%
                        BrandDAO brandDAO = new BrandDAO();
                        List<Brand> brands = brandDAO.getAll();
                        if (brands != null) {
                            for (Brand b : brands) {
                                out.println("<option value='" + b.getBrandId() + "'>" + (b.getName() != null ? b.getName() : "") + "</option>");
                            }
                        }
                    %>
                </select>
            </div>
            <div class="mb-3">
                <label class="form-label">Material</label>
                <input type="text" class="form-control" name="material" id="material" required />
            </div>
            <div class="mb-3">
                <label class="form-label">Status</label>
                <select class="form-control" name="status" id="status" required>
                    <option value="Active">Active</option>
                    <option value="Discontinued">Discontinued</option>
                </select>
            </div>
            <a href="${pageContext.request.contextPath}/ProductManager?action=list" class="btn btn-secondary">
                <i class="bi bi-arrow-return-left"></i> Back
            </a>
            <button type="submit" class="btn btn-primary">
                <i class="bi bi-file-earmark-plus"></i> Create
            </button>
        </form>
        <%
            String err = (String) request.getAttribute("err");
            if (err != null) {
                out.println("<div class='alert alert-danger' role='alert'>" + err + "</div>");
                // Debug: Display submitted data
                out.println("<div style='color: gray;'>");
                out.println("Debug - Submitted Data:<br>");
                out.println("Name: " + request.getParameter("name") + "<br>");
                out.println("Price: " + request.getParameter("price") + "<br>");
                out.println("StockQuantity: " + request.getParameter("stockQuantity") + "<br>");
                out.println("SupplierId: " + request.getParameter("supplierId") + "<br>");
                out.println("CategoryId: " + request.getParameter("categoryId") + "<br>");
                out.println("BrandId: " + request.getParameter("brandId") + "<br>");
                out.println("Material: " + request.getParameter("material") + "<br>");
                out.println("Status: " + request.getParameter("status") + "<br>");
                out.println("</div>");
            }
        %>
    </div>

    <!-- Try-catch block for footer -->
    <%
        try {
    %>
    <!-- Footer content (assumed) -->
    <%
        } catch (Exception footerException) {
            out.println("<p style='color: red;'>Error including footer: " + footerException.getMessage() + "</p>");
        }
    %>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
</body>
</html>