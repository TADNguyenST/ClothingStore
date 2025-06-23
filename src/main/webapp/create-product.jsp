<%@page import="java.math.BigDecimal"%>
<%@page import="model.Users"%>
<%@page import="model.Category"%>
<%@page import="model.Brand"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="java.text.DecimalFormatSymbols"%>
<%@page import="java.util.List"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String err = (String) request.getAttribute("err");
    List<Category> categories = (List<Category>) request.getAttribute("categories");
    List<Brand> brands = (List<Brand>) request.getAttribute("brands");
%>
<%!
    private String formatPrice(BigDecimal price) {
        if (price == null) {
            return "N/A";
        }
        DecimalFormatSymbols symbols = new DecimalFormatSymbols();
        symbols.setGroupingSeparator('.');
        symbols.setDecimalSeparator(',');
        DecimalFormat df = new DecimalFormat("#,###.##", symbols);
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
    <script>
        function addVariant() {
            const container = document.getElementById('variants-container');
            const variantDiv = document.createElement('div');
            variantDiv.className = 'variant-row mb-3';
            variantDiv.innerHTML = `
                <div class="row">
                    <div class="col-md-4">
                        <input type="text" name="size" class="form-control" placeholder="Size" required>
                    </div>
                    <div class="col-md-4">
                        <input type="text" name="color" class="form-control" placeholder="Color" required>
                    </div>
                    <div class="col-md-3">
                        <input type="text" name="priceModifier" class="form-control" placeholder="Price Modifier (e.g., -5.00, 0.00)" required>
                    </div>
                    <div class="col-md-1">
                        <button type="button" class="btn btn-danger btn-sm" onclick="this.parentElement.parentElement.parentElement.remove()">
                            <i class="bi bi-trash"></i> Remove
                        </button>
                    </div>
                </div>
            `;
            container.appendChild(variantDiv);
        }

        document.addEventListener('DOMContentLoaded', function() {
            document.querySelector('form').addEventListener('submit', function(e) {
                const priceInput = document.querySelector('input[name="price"]').value;
                const sizes = document.querySelectorAll('input[name="size"]');
                const colors = document.querySelectorAll('input[name="color"]');
                const priceModifiers = document.querySelectorAll('input[name="priceModifier"]');
                const numberRegex = /^-?\d+(\.\d{1,2})?$/; // Allows negative, zero, positive decimals

                console.log('Price:', priceInput);
                console.log('Sizes:', Array.from(sizes).map(s => s.value));
                console.log('Colors:', Array.from(colors).map(c => c.value));
                console.log('Price Modifiers:', Array.from(priceModifiers).map(pm => pm.value));

                // Validate price
                if (!numberRegex.test(priceInput) || parseFloat(priceInput) <= 0) {
                    e.preventDefault();
                    alert('Price must be a valid positive number (e.g., 1000000.00)');
                    return;
                }

                const price = parseFloat(priceInput);

                // Validate variants
                if (sizes.length === 0) {
                    e.preventDefault();
                    alert('At least one variant is required');
                    return;
                }
                for (let i = 0; i < sizes.length; i++) {
                    if (!sizes[i].value.trim()) {
                        e.preventDefault();
                        alert('Size cannot be empty');
                        return;
                    }
                    if (!colors[i].value.trim()) {
                        e.preventDefault();
                        alert('Color cannot be empty');
                        return;
                    }
                    if (!priceModifiers[i].value.trim() || !numberRegex.test(priceModifiers[i].value)) {
                        e.preventDefault();
                        alert('Price Modifier must be a valid number (e.g., -5.00, 0.00, 5.50)');
                        return;
                    }
                    const modifier = parseFloat(priceModifiers[i].value);
                    if (price + modifier < 0) {
                        e.preventDefault();
                        alert('Price Modifier for variant ' + (i + 1) + ' makes total price negative (' + (price + modifier) + '). Total price must be non-negative.');
                        return;
                    }
                }
            });
        });
    </script>
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
                <input type="text" name="price" class="form-control" placeholder="e.g., 1000000.00" required>
            </div>
            <div class="mb-3">
                <label class="form-label">Category</label>
                <select name="categoryId" class="form-select" required>
                    <option value="">Select a category</option>
                    <% 
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
            <h4>Variants</h4>
            <div id="variants-container" class="mb-3">
                <div class="variant-row mb-3">
                    <div class="row">
                        <div class="col-md-4">
                            <input type="text" name="size" class="form-control" placeholder="Size" required>
                        </div>
                        <div class="col-md-4">
                            <input type="text" name="color" class="form-control" placeholder="Color" required>
                        </div>
                        <div class="col-md-3">
                            <input type="text" name="priceModifier" class="form-control" placeholder="Price Modifier (e.g., -5.00, 0.00)" required>
                        </div>
                        <div class="col-md-1">
                            <button type="button" class="btn btn-danger btn-sm" onclick="this.parentElement.parentElement.parentElement.remove()">
                                <i class="bi bi-trash"></i> Remove
                            </button>
                        </div>
                    </div>
                </div>
            </div>
            <button type="button" class="btn btn-outline-primary mb-3" onclick="addVariant()">
                <i class="bi bi-plus-circle"></i> Add Variant
            </button>
            <div>
                <button type="submit" class="btn btn-primary"><i class="bi bi-save"></i> Add Product</button>
                <a href="${pageContext.request.contextPath}/ProductManager" class="btn btn-secondary">Cancel</a>
            </div>
        </form>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
</body>
</html>