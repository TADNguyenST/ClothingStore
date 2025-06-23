<%@page import="java.math.BigDecimal"%>
<%@page import="model.Product"%>
<%@page import="model.Users"%>
<%@page import="model.Category"%>
<%@page import="model.Brand"%>
<%@page import="model.ProductVariant"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="java.text.DecimalFormatSymbols"%>
<%@page import="java.util.List"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    Product product = (Product) request.getAttribute("data");
    String err = (String) request.getAttribute("err");
    List<Category> categories = (List<Category>) request.getAttribute("categories");
    List<Brand> brands = (List<Brand>) request.getAttribute("brands");
%>
<%!
    private String formatPrice(BigDecimal value) {
        if (value == null) {
            return "0,00";
        }
        DecimalFormatSymbols symbols = new DecimalFormatSymbols();
        symbols.setGroupingSeparator('.');
        symbols.setDecimalSeparator(',');
        DecimalFormat df = new DecimalFormat("#,###.##", symbols);
        return df.format(value);
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Edit Product</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <script>
        function addVariant(size = '', color = '', priceModifier = '') {
            const container = document.getElementById('variants-container');
            const variantDiv = document.createElement('div');
            variantDiv.className = 'variant-row mb-3';
            variantDiv.innerHTML = `
                <div class="row">
                    <input type="hidden" name="variantId" value="">
                    <div class="col-md-4">
                        <input type="text" name="size" class="form-control" placeholder="Size" value="${size}" required>
                    </div>
                    <div class="col-md-4">
                        <input type="text" name="color" class="form-control" placeholder="Color" value="${color}" required>
                    </div>
                    <div class="col-md-3">
                        <input type="text" name="priceModifier" class="form-control" placeholder="Price Modifier (e.g., -5.00, 0, 5.50)" value="${priceModifier}" required>
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
                const variantIds = document.querySelectorAll('input[name="variantId"]');
                const numberRegex = /^-?\d+(\.\d{0,2})?$/; // Allows -5.00, 0, 0.0, 0.00, 5.50

                // Log inputs for debugging
                console.log('Price Input:', priceInput);
                console.log('Sizes:', Array.from(sizes).map(s => s.value));
                console.log('Colors:', Array.from(colors).map(c => c.value));
                console.log('Price Modifiers:', Array.from(priceModifiers).map(pm => pm.value));
                console.log('Variant IDs:', Array.from(variantIds).map(vid => vid.value));

                // Normalize price input (replace comma with dot, remove thousands separators)
                const priceStr = priceInput.replace(/\./g, '').replace(',', '.');
                if (!numberRegex.test(priceStr) || parseFloat(priceStr) <= 0) {
                    e.preventDefault();
                    alert('Price must be a valid positive number (e.g., 1000000,00 or 1000000.00)');
                    console.log('Invalid price format:', priceStr);
                    return;
                }

                const price = parseFloat(priceStr);

                if (sizes.length === 0) {
                    e.preventDefault();
                    alert('At least one variant is required');
                    return;
                }
                if (sizes.length !== colors.length || colors.length !== priceModifiers.length || priceModifiers.length !== variantIds.length) {
                    e.preventDefault();
                    alert('Mismatch in variant data. Please ensure all variant fields are filled correctly.');
                    console.log('Array length mismatch: Sizes=' + sizes.length + ', Colors=' + colors.length + ', PriceModifiers=' + priceModifiers.length + ', VariantIds=' + variantIds.length);
                    return;
                }

                for (let i = 0; i < sizes.length; i++) {
                    if (!sizes[i].value.trim()) {
                        e.preventDefault();
                        alert('Size cannot be empty for variant ' + (i + 1));
                        return;
                    }
                    if (!colors[i].value.trim()) {
                        e.preventDefault();
                        alert('Color cannot be empty for variant ' + (i + 1));
                        return;
                    }
                    const modifierStr = priceModifiers[i].value.replace(/\./g, '').replace(',', '.');
                    if (!modifierStr.trim() || !numberRegex.test(modifierStr)) {
                        e.preventDefault();
                        alert('Price Modifier must be a valid number for variant ' + (i + 1) + ' (e.g., -5.00, 0, 5.50)');
                        console.log('Invalid priceModifier format for variant ' + (i + 1) + ':', modifierStr);
                        return;
                    }
                    const modifier = parseFloat(modifierStr);
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

        <h1 style="margin-top: 45px;">Edit Product</h1>
        <% if (err != null && !err.isEmpty()) { %>
            <p class="text-danger"><%= err %></p>
        <% } %>
        <% if (product != null) { %>
            <form action="${pageContext.request.contextPath}/ProductManager" method="post" class="mt-3">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="id" value="<%= product.getProductId() %>">
                <div class="mb-3">
                    <label class="form-label">Name</label>
                    <input type="text" name="name" class="form-control" value="<%= product.getName() != null ? product.getName() : "" %>" required>
                </div>
                <div class="mb-3">
                    <label class="form-label">Description</label>
                    <textarea name="description" class="form-control"><%= product.getDescription() != null ? product.getDescription() : "" %></textarea>
                </div>
                <div class="mb-3">
                    <label class="form-label">Price</label>
                    <input type="text" name="price" class="form-control" value="<%= formatPrice(product.getPrice()) %>" required>
                </div>
                <div class="mb-3">
                    <label class="form-label">Category</label>
                    <select name="categoryId" class="form-select" required>
                        <option value="">Select a category</option>
                        <% 
                            if (categories != null) {
                                for (Category category : categories) {
                                    String selected = (product.getCategory() != null && category.getCategoryId() == product.getCategory().getCategoryId()) ? "selected" : "";
                        %>
                            <option value="<%= category.getCategoryId() %>" <%= selected %>><%= category.getName() %></option>
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
                                    String selected = (product.getBrand() != null && brand.getBrandId() == product.getBrand().getBrandId()) ? "selected" : "";
                        %>
                            <option value="<%= brand.getBrandId() %>" <%= selected %>><%= brand.getName() %></option>
                        <% 
                                }
                            }
                        %>
                    </select>
                </div>
                <div class="mb-3">
                    <label class="form-label">Material</label>
                    <input type="text" name="material" class="form-control" value="<%= product.getMaterial() != null ? product.getMaterial() : "" %>">
                </div>
                <div class="mb-3">
                    <label class="form-label">Status</label>
                    <select name="status" class="form-select">
                        <option value="Active" <%= product.getStatus().equals("Active") ? "selected" : "" %>>Active</option>
                        <option value="Discontinued" <%= product.getStatus().equals("Discontinued") ? "selected" : "" %>>Discontinued</option>
                    </select>
                </div>
                <h4>Variants</h4>
                <div id="variants-container" class="mb-3">
                    <% 
                        List<ProductVariant> variants = product.getVariants();
                        if (variants != null && !variants.isEmpty()) {
                            for (ProductVariant variant : variants) {
                    %>
                        <div class="variant-row mb-3">
                            <div class="row">
                                <input type="hidden" name="variantId" value="<%= variant.getVariantId() != null ? variant.getVariantId() : "" %>">
                                <div class="col-md-4">
                                    <input type="text" name="size" class="form-control" placeholder="Size" value="<%= variant.getSize() != null ? variant.getSize() : "" %>" required>
                                </div>
                                <div class="col-md-4">
                                    <input type="text" name="color" class="form-control" placeholder="Color" value="<%= variant.getColor() != null ? variant.getColor() : "" %>" required>
                                </div>
                                <div class="col-md-3">
                                    <input type="text" name="priceModifier" class="form-control" placeholder="Price Modifier (e.g., -5.00, 0, 5.50)" value="<%= formatPrice(variant.getPriceModifier()) %>" required>
                                </div>
                                <div class="col-md-1">
                                    <button type="button" class="btn btn-danger btn-sm" onclick="this.parentElement.parentElement.parentElement.remove()">
                                        <i class="bi bi-trash"></i> Remove
                                    </button>
                                </div>
                            </div>
                        </div>
                    <% 
                            }
                        } else {
                    %>
                        <div class="variant-row mb-3">
                            <div class="row">
                                <input type="hidden" name="variantId" value="">
                                <div class="col-md-4">
                                    <input type="text" name="size" class="form-control" placeholder="Size" required>
                                </div>
                                <div class="col-md-4">
                                    <input type="text" name="color" class="form-control" placeholder="Color" required>
                                </div>
                                <div class="col-md-3">
                                    <input type="text" name="priceModifier" class="form-control" placeholder="Price Modifier (e.g., -5.00, 0, 5.50)" value="0,00" required>
                                </div>
                                <div class="col-md-1">
                                    <button type="button" class="btn btn-danger btn-sm" onclick="this.parentElement.parentElement.parentElement.remove()">
                                        <i class="bi bi-trash"></i> Remove
                                    </button>
                                </div>
                            </div>
                        </div>
                    <% 
                        }
                    %>
                </div>
                <button type="button" class="btn btn-outline-primary mb-3" onclick="addVariant()">
                    <i class="bi bi-plus-circle"></i> Add Variant
                </button>
                <div>
                    <button type="submit" class="btn btn-primary"><i class="bi bi-save"></i> Update Product</button>
                    <a href="${pageContext.request.contextPath}/ProductManager" class="btn btn-secondary">Cancel</a>
                </div>
            </form>
        <% } else { %>
            <p>No product found!</p>
        <% } %>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
</body>
</html>