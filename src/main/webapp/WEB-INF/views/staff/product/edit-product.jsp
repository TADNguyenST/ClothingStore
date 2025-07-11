<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@page import="java.math.BigDecimal"%>
<%@page import="model.Product"%>
<%@page import="model.ProductVariant"%>
<%@page import="model.Category"%>
<%@page import="model.Brand"%>
<%@page import="model.ProductImage"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="java.text.DecimalFormatSymbols"%>
<%@page import="java.util.List"%>
<%
    Product product = (Product) request.getAttribute("data");
    String err = (String) request.getAttribute("err");
    List<Category> categories = (List<Category>) request.getAttribute("categories");
    List<Brand> brands = (List<Brand>) request.getAttribute("brands");
    
    // Debug variables
    String debugProduct = product != null ? "Product ID: " + product.getProductId() : "Product is null";
    String debugCategory = product != null && product.getCategory() != null ? 
        "Category ID: " + product.getCategory().getCategoryId() + ", Name: " + product.getCategory().getName() : 
        "Category is null";
    String debugParentCategoryId = product != null && product.getCategory() != null && product.getCategory().getParentCategoryId() != null ? 
        product.getCategory().getParentCategoryId().toString() : "null";
    Long parentCategoryId = null;
    String parentCategoryName = "None";
    
    // Find parent category
    if (product != null && product.getCategory() != null) {
        if (product.getCategory().getParentCategoryId() != null) {
            for (Category category : categories) {
                if (category.getCategoryId().equals(product.getCategory().getParentCategoryId())) {
                    parentCategoryId = category.getCategoryId();
                    parentCategoryName = category.getName();
                    break;
                }
            }
        } else if (product.getCategory().getParentCategoryId() == null) {
            for (Category category : categories) {
                if (category.getCategoryId().equals(product.getCategory().getCategoryId()) && category.getParentCategoryId() == null) {
                    parentCategoryId = category.getCategoryId();
                    parentCategoryName = category.getName();
                    break;
                }
            }
        }
    }
%>
<%!
    private String formatPrice(BigDecimal price) {
        if (price == null) {
            return "N/A";
        }
        DecimalFormatSymbols symbols = new DecimalFormatSymbols();
        symbols.setGroupingSeparator('.');
        symbols.setDecimalSeparator(',');
        DecimalFormat df = new DecimalFormat("#,###", symbols);
        return df.format(price);
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Edit Product</title>

    <%-- Link to external libraries --%>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

    <%-- Link to common CSS --%>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/admin-dashboard/css/admin-css.css">
</head>
<body>
    <%-- Set necessary requestScope variables for sidebar/header --%>
    <c:set var="currentAction" value="products" scope="request"/>
    <c:set var="currentModule" value="admin" scope="request"/>
    <c:set var="pageTitle" value="Edit Product" scope="request"/>

    <%-- Include Sidebar --%>
    <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp" />

    <div class="main-content-wrapper">
        <%-- Include Header --%>
        <jsp:include page="/WEB-INF/includes/admin-header.jsp" />
        
        <%-- Main content area --%>
        <div class="content-area">
            <div class="row">
                <div class="col-xs-12">
                    <div class="box box-primary">
                        <div class="box-header with-border">
                            <h3 class="box-title">Edit Product</h3>
                        </div>
                        <div class="box-body">
                            <%-- Error Message --%>
                            <% if (err != null && !err.isEmpty()) { %>
                                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                    <%= err %>
                                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                                </div>
                            <% } %>

                            <%-- Edit Product Form --%>
                            <form action="${pageContext.request.contextPath}/ProductManager" method="post" enctype="multipart/form-data" class="mt-3">
                                <input type="hidden" name="action" value="update">
                                <input type="hidden" name="id" value="<%= product.getProductId() %>">
                                <div class="mb-3">
                                    <label class="form-label">Name</label>
                                    <input type="text" name="name" class="form-control" value="<%= product.getName() != null ? product.getName() : "" %>" required>
                                    <div class="invalid-feedback">Product name is required.</div>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Description</label>
                                    <textarea name="description" class="form-control"><%= product.getDescription() != null ? product.getDescription() : "" %></textarea>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Price</label>
                                    <input type="text" name="price" class="form-control" value="<%= formatPrice(product.getPrice()) %>" placeholder="e.g., 1000000 or 1000.000" required>
                                    <div class="invalid-feedback">Invalid price format.</div>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Parent Category</label>
                                    <select name="parentCategoryId" id="parentCategoryId" class="form-select" onchange="filterChildCategories()">
                                        <option value="">Select a parent category</option>
                                        <% 
                                            if (categories != null) {
                                                for (Category category : categories) {
                                                    if (category.getParentCategoryId() == null) { // Only parent categories
                                        %>
                                            <option value="<%= category.getCategoryId() %>" <%= parentCategoryId != null && parentCategoryId.equals(category.getCategoryId()) ? "selected" : "" %>>
                                                <%= category.getName() %>
                                            </option>
                                        <% 
                                                    }
                                                }
                                            }
                                        %>
                                    </select>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Category</label>
                                    <select name="categoryId" id="categoryId" class="form-select" required>
                                        <option value="">Select a category</option>
                                        <% 
                                            if (categories != null) {
                                                for (Category category : categories) {
                                                    if (category.getParentCategoryId() != null) { // Only child categories
                                        %>
                                            <option value="<%= category.getCategoryId() %>" 
                                                    data-parent-id="<%= category.getParentCategoryId() %>"
                                                    <%= product.getCategory() != null && product.getCategory().getCategoryId() == category.getCategoryId() ? "selected" : "" %>>
                                                <%= category.getName() %>
                                            </option>
                                        <% 
                                                    }
                                                }
                                            }
                                        %>
                                    </select>
                                    <div class="invalid-feedback">Category is required.</div>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Brand</label>
                                    <select name="brandId" class="form-select" required>
                                        <option value="">Select a brand</option>
                                        <% 
                                            if (brands != null) {
                                                for (Brand brand : brands) {
                                        %>
                                            <option value="<%= brand.getBrandId() %>" <%= product.getBrand() != null && product.getBrand().getBrandId() == brand.getBrandId() ? "selected" : "" %>>
                                                <%= brand.getName() %>
                                            </option>
                                        <% 
                                                }
                                            }
                                        %>
                                    </select>
                                    <div class="invalid-feedback">Brand is required.</div>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Material</label>
                                    <input type="text" name="material" class="form-control" value="<%= product.getMaterial() != null ? product.getMaterial() : "" %>">
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Status</label>
                                    <select name="status" class="form-select">
                                        <option value="Active" <%= "Active".equals(product.getStatus()) ? "selected" : "" %>>Active</option>
                                        <option value="Discontinued" <%= "Discontinued".equals(product.getStatus()) ? "selected" : "" %>>Discontinued</option>
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
                                            <div class="col-md-4">
                                                <input type="hidden" name="variantId" value="<%= variant.getVariantId() != null ? variant.getVariantId() : "" %>">
                                                <select name="size" class="form-control" required onchange="validateField(this)">
                                                    <option value="" disabled>Select Size</option>
                                                    <option value="S" <%= "S".equals(variant.getSize()) ? "selected" : "" %>>S</option>
                                                    <option value="M" <%= "M".equals(variant.getSize()) ? "selected" : "" %>>M</option>
                                                    <option value="L" <%= "L".equals(variant.getSize()) ? "selected" : "" %>>L</option>
                                                    <option value="XL" <%= "XL".equals(variant.getSize()) ? "selected" : "" %>>XL</option>
                                                    <option value="XS" <%= "XS".equals(variant.getSize()) ? "selected" : "" %>>XS</option>
                                                </select>
                                                <div class="invalid-feedback">Invalid size.</div>
                                            </div>
                                            <div class="col-md-4">
                                                <select name="color" class="form-control" required onchange="validateField(this)">
                                                    <option value="" disabled>Select Color</option>
                                                    <option value="Red" <%= "Red".equals(variant.getColor()) ? "selected" : "" %>>Red</option>
                                                    <option value="Blue" <%= "Blue".equals(variant.getColor()) ? "selected" : "" %>>Blue</option>
                                                    <option value="Green" <%= "Green".equals(variant.getColor()) ? "selected" : "" %>>Green</option>
                                                    <option value="Black" <%= "Black".equals(variant.getColor()) ? "selected" : "" %>>Black</option>
                                                    <option value="White" <%= "White".equals(variant.getColor()) ? "selected" : "" %>>White</option>
                                                    <option value="Yellow" <%= "Yellow".equals(variant.getColor()) ? "selected" : "" %>>Yellow</option>
                                                </select>
                                                <div class="invalid-feedback">Invalid color.</div>
                                            </div>
                                            <div class="col-md-3">
                                                <input type="text" name="priceModifier" class="form-control" placeholder="e.g., 0 or 5000" value="<%= formatPrice(variant.getPriceModifier()) %>" required oninput="validateField(this)">
                                                <div class="invalid-feedback">Invalid price modifier.</div>
                                            </div>
                                            <div class="col-md-1">
                                                <button type="button" class="btn btn-danger btn-sm" onclick="this.parentElement.parentElement.parentElement.remove(); updateVariantOptions()">
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
                                            <div class="col-md-4">
                                                <select name="size" class="form-control" required onchange="validateField(this)">
                                                    <option value="" disabled selected>Select Size</option>
                                                    <option value="S">S</option>
                                                    <option value="M">M</option>
                                                    <option value="L">L</option>
                                                    <option value="XL">XL</option>
                                                    <option value="XS">XS</option>
                                                </select>
                                                <div class="invalid-feedback">Invalid size.</div>
                                            </div>
                                            <div class="col-md-4">
                                                <select name="color" class="form-control" required onchange="validateField(this)">
                                                    <option value="" disabled selected>Select Color</option>
                                                    <option value="Red">Red</option>
                                                    <option value="Blue">Blue</option>
                                                    <option value="Green">Green</option>
                                                    <option value="Black">Black</option>
                                                    <option value="White">White</option>
                                                    <option value="Yellow">Yellow</option>
                                                </select>
                                                <div class="invalid-feedback">Invalid color.</div>
                                            </div>
                                            <div class="col-md-3">
                                                <input type="text" name="priceModifier" class="form-control" placeholder="e.g., 0 or 5000" required oninput="validateField(this)">
                                                <div class="invalid-feedback">Invalid price modifier.</div>
                                            </div>
                                            <div class="col-md-1">
                                                <button type="button" class="btn btn-danger btn-sm" onclick="this.parentElement.parentElement.parentElement.remove(); updateVariantOptions()">
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
                                <h4>Images</h4>
                                <div id="images-container" class="mb-3">
                                    <% 
                                        List<ProductImage> images = product.getImages();
                                        if (images != null && !images.isEmpty()) {
                                            for (ProductImage image : images) {
                                    %>
                                    <div class="image-row mb-3" data-image-id="<%= image.getImageId() %>">
                                        <div class="row">
                                            <div class="col-md-7">
                                                <input type="hidden" name="existingImageUrl" value="<%= image.getImageUrl() %>">
                                                <img src="<%= image.getImageUrl() %>" alt="Existing Image" style="max-width: 100px; margin-right: 10px;">
                                                <input type="file" name="images" class="form-control" accept="image/jpeg,image/png,image/gif">
                                            </div>
                                            <div class="col-md-3">
                                                <div class="form-check">
                                                    <input type="checkbox" name="isMainImage" value="true" class="form-check-input" 
                                                           <%= image.isMain() ? "checked" : "" %> onchange="toggleMainImage(this)">
                                                    <label class="form-check-label">Main Image</label>
                                                </div>
                                            </div>
                                            <div class="col-md-2">
                                                <button type="button" class="btn btn-danger btn-sm" onclick="removeImage(this)">
                                                    <i class="bi bi-trash"></i> Remove
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                    <% 
                                            }
                                        } else {
                                    %>
                                    <div class="image-row mb-3">
                                        <div class="row">
                                            <div class="col-md-7">
                                                <input type="file" name="images" class="form-control" accept="image/jpeg,image/png,image/gif" required>
                                            </div>
                                            <div class="col-md-3">
                                                <div class="form-check">
                                                    <input type="checkbox" name="isMainImage" value="true" class="form-check-input" onchange="toggleMainImage(this)">
                                                    <label class="form-check-label">Main Image</label>
                                                </div>
                                            </div>
                                            <div class="col-md-2">
                                                <button type="button" class="btn btn-danger btn-sm" onclick="removeImage(this)">
                                                    <i class="bi bi-trash"></i> Remove
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                    <% 
                                        }
                                    %>
                                </div>
                                <button type="button" class="btn btn-outline-primary mb-3" onclick="addImage()">
                                    <i class="bi bi-plus-circle"></i> Add Image
                                </button>
                                <div>
                                    <button type="submit" class="btn btn-primary"><i class="bi bi-save"></i> Update Product</button>
                                    <a href="${pageContext.request.contextPath}/ProductManager" class="btn btn-secondary">Cancel</a>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>

    <%-- Link to common JS --%>
    <script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
    
    <%-- JS for active menu, form handling, and image management --%>
    <script>
        function addVariant() {
            console.log("Adding new variant...");
            const container = document.getElementById('variants-container');
            const variantDiv = document.createElement('div');
            variantDiv.className = 'variant-row mb-3';
            variantDiv.innerHTML = `
                <div class="row">
                    <div class="col-md-4">
                        <select name="size" class="form-control" required onchange="validateField(this)">
                            <option value="" disabled selected>Select Size</option>
                            <option value="S">S</option>
                            <option value="M">M</option>
                            <option value="L">L</option>
                            <option value="XL">XL</option>
                            <option value="XS">XS</option>
                        </select>
                        <div class="invalid-feedback">Invalid size.</div>
                    </div>
                    <div class="col-md-4">
                        <select name="color" class="form-control" required onchange="validateField(this)">
                            <option value="" disabled selected>Select Color</option>
                            <option value="Red">Red</option>
                            <option value="Blue">Blue</option>
                            <option value="Green">Green</option>
                            <option value="Black">Black</option>
                            <option value="White">White</option>
                            <option value="Yellow">Yellow</option>
                        </select>
                        <div class="invalid-feedback">Invalid color.</div>
                    </div>
                    <div class="col-md-3">
                        <input type="text" name="priceModifier" class="form-control" placeholder="e.g., 0 or 5000" required oninput="validateField(this)">
                        <div class="invalid-feedback">Invalid price modifier.</div>
                    </div>
                    <div class="col-md-1">
                        <button type="button" class="btn btn-danger btn-sm" onclick="this.parentElement.parentElement.parentElement.remove(); updateVariantOptions()">
                            <i class="bi bi-trash"></i> Remove
                        </button>
                    </div>
                </div>
            `;
            container.appendChild(variantDiv);
            updateVariantOptions();
            console.log("Variant added successfully.");
        }

        function addImage() {
            console.log("Adding new image...");
            const container = document.getElementById('images-container');
            const imageDiv = document.createElement('div');
            imageDiv.className = 'image-row mb-3';
            imageDiv.innerHTML = `
                <div class="row">
                    <div class="col-md-7">
                        <input type="file" name="images" class="form-control" accept="image/jpeg,image/png,image/gif">
                    </div>
                    <div class="col-md-3">
                        <div class="form-check">
                            <input type="checkbox" name="isMainImage" value="true" class="form-check-input" onchange="toggleMainImage(this)">
                            <label class="form-check-label">Main Image</label>
                        </div>
                    </div>
                    <div class="col-md-2">
                        <button type="button" class="btn btn-danger btn-sm" onclick="removeImage(this)">
                            <i class="bi bi-trash"></i> Remove
                        </button>
                    </div>
                </div>
            `;
            container.appendChild(imageDiv);
            console.log("Image added successfully.");
        }

        function removeImage(button) {
            const row = button.parentElement.parentElement.parentElement;
            row.parentElement.removeChild(row);
            console.log("Image removed from form.");
        }

        function toggleMainImage(checkbox) {
            console.log("Toggling Main Image...");
            const checkboxes = document.querySelectorAll('input[name="isMainImage"]');
            if (checkbox.checked) {
                checkboxes.forEach(cb => {
                    if (cb !== checkbox) {
                        cb.checked = false;
                        cb.disabled = true;
                    }
                });
            } else {
                checkboxes.forEach(cb => {
                    cb.disabled = false;
                });
            }
        }

        function validateField(field) {
            const variantRow = field.closest('.variant-row');
            const name = field.name;
            const value = field.value;
            const validSizes = ['S', 'M', 'L', 'XL', 'XS'];
            const validColors = ['Red', 'Blue', 'Green', 'Black', 'White', 'Yellow'];
            const numberRegex = /^\d+(\.\d{3})*$|^\d+$/;

            // Clear previous validation state for this field
            field.classList.remove('is-invalid');

            // Validate the specific field
            if (name === 'size' && (!value || !validSizes.includes(value))) {
                field.classList.add('is-invalid');
            } else if (name === 'color' && (!value || !validColors.includes(value))) {
                field.classList.add('is-invalid');
            } else if (name === 'priceModifier') {
                const modifierStr = value.replace(/\./g, '');
                if (!modifierStr || !numberRegex.test(modifierStr) || parseInt(modifierStr) < 0) {
                    field.classList.add('is-invalid');
                }
            }

            // Check for duplicates only for the current variant
            if ((name === 'size' || name === 'color') && value) {
                const size = variantRow.querySelector('select[name="size"]').value;
                const color = variantRow.querySelector('select[name="color"]').value;
                if (size && color) {
                    const variants = document.querySelectorAll('.variant-row');
                    let duplicateCount = 0;
                    variants.forEach(variant => {
                        const vSize = variant.querySelector('select[name="size"]').value;
                        const vColor = variant.querySelector('select[name="color"]').value;
                        if (vSize === size && vColor === color) {
                            duplicateCount++;
                        }
                    });
                    if (duplicateCount > 1) {
                        variantRow.querySelector('select[name="size"]').classList.add('is-invalid');
                        variantRow.querySelector('select[name="color"]').classList.add('is-invalid');
                    } else {
                        variantRow.querySelector('select[name="size"]').classList.remove('is-invalid');
                        variantRow.querySelector('select[name="color"]').classList.remove('is-invalid');
                    }
                }
            }
        }

        function updateVariantOptions() {
            console.log("Updating variant options...");
            const variants = document.querySelectorAll('.variant-row');
            variants.forEach(variant => {
                const size = variant.querySelector('select[name="size"]');
                const color = variant.querySelector('select[name="color"]');
                validateField(size);
                validateField(color);
            });
        }

        function filterChildCategories() {
            const parentCategoryId = document.getElementById('parentCategoryId').value;
            const categorySelect = document.getElementById('categoryId');
            const options = categorySelect.querySelectorAll('option:not([value=""])');

            options.forEach(option => {
                const parentId = option.getAttribute('data-parent-id');
                if (parentCategoryId === '') {
                    option.style.display = 'block';
                } else {
                    option.style.display = parentId === parentCategoryId ? 'block' : 'none';
                }
            });

            const selectedOption = categorySelect.options[categorySelect.selectedIndex];
            if (selectedOption && selectedOption.getAttribute('data-parent-id') !== parentCategoryId) {
                categorySelect.value = '';
            }
        }

        document.addEventListener('DOMContentLoaded', function() {
            // Form validation
            document.querySelector('form').addEventListener('submit', function(e) {
                console.log("Form submit triggered...");
                const nameInput = document.querySelector('input[name="name"]');
                const priceInput = document.querySelector('input[name="price"]');
                const categorySelect = document.querySelector('select[name="categoryId"]');
                const brandSelect = document.querySelector('select[name="brandId"]');
                const sizes = document.querySelectorAll('select[name="size"]');
                const colors = document.querySelectorAll('select[name="color"]');
                const priceModifiers = document.querySelectorAll('input[name="priceModifier"]');
                const images = document.querySelectorAll('input[name="images"]');
                const existingImages = document.querySelectorAll('input[name="existingImageUrl"]');
                const numberRegex = /^\d+(\.\d{3})*$|^\d+$/;
                const errors = [];

                // Clear previous validation states
                nameInput.classList.remove('is-invalid');
                priceInput.classList.remove('is-invalid');
                categorySelect.classList.remove('is-invalid');
                brandSelect.classList.remove('is-invalid');
                sizes.forEach(s => s.classList.remove('is-invalid'));
                colors.forEach(c => c.classList.remove('is-invalid'));
                priceModifiers.forEach(p => p.classList.remove('is-invalid'));

                // Validate name
                if (!nameInput.value.trim()) {
                    errors.push('Product name is required.');
                    nameInput.classList.add('is-invalid');
                }

                // Validate price
                const priceStr = priceInput.value.replace(/\./g, '');
                if (!numberRegex.test(priceStr) || parseInt(priceStr) <= 0) {
                    errors.push('Invalid price format.');
                    priceInput.classList.add('is-invalid');
                }
                const price = parseInt(priceStr);

                // Validate category
                if (!categorySelect.value) {
                    errors.push('Category is required.');
                    categorySelect.classList.add('is-invalid');
                }

                // Validate brand
                if (!brandSelect.value) {
                    errors.push('Brand is required.');
                    brandSelect.classList.add('is-invalid');
                }

                // Validate variants
                if (sizes.length === 0) {
                    errors.push('At least one variant is required.');
                } else {
                    const validSizes = ['S', 'M', 'L', 'XL', 'XS'];
                    const validColors = ['Red', 'Blue', 'Green', 'Black', 'White', 'Yellow'];
                    const variantKeys = new Set();
                    for (let i = 0; i < sizes.length; i++) {
                        const size = sizes[i].value;
                        const color = colors[i].value;
                        const modifierStr = priceModifiers[i].value.replace(/\./g, '');
                        if (!size || !validSizes.includes(size)) {
                            errors.push(`Invalid size in variant ${i + 1}.`);
                            sizes[i].classList.add('is-invalid');
                        }
                        if (!color || !validColors.includes(color)) {
                            errors.push(`Invalid color in variant ${i + 1}.`);
                            colors[i].classList.add('is-invalid');
                        }
                        if (!modifierStr || !numberRegex.test(modifierStr)) {
                            errors.push(`Invalid price modifier in variant ${i + 1}.`);
                            priceModifiers[i].classList.add('is-invalid');
                        } else {
                            const modifier = parseInt(modifierStr);
                            if (modifier < 0) {
                                errors.push(`Price modifier in variant ${i + 1} cannot be negative.`);
                                priceModifiers[i].classList.add('is-invalid');
                            }
                            if (price + modifier < price) {
                                errors.push(`Price modifier in variant ${i + 1} makes total price less than base price.`);
                                priceModifiers[i].classList.add('is-invalid');
                            }
                        }
                        if (size && color) {
                            const variantKey = size + '|' + color;
                            if (variantKeys.has(variantKey)) {
                                errors.push(`Duplicate size and color in variant ${i + 1}.`);
                                sizes[i].classList.add('is-invalid');
                                colors[i].classList.add('is-invalid');
                            }
                            variantKeys.add(variantKey);
                        }
                    }
                }

                // Validate images
                if (images.length === 0 && existingImages.length === 0) {
                    errors.push('At least one image is required.');
                }
                for (let i = 0; i < images.length; i++) {
                    if (images[i].value && !images[i].value.match(/\.(jpg|jpeg|png|gif)$/i)) {
                        errors.push(`Invalid image format for upload ${i + 1}.`);
                    }
                }

                const mainImages = document.querySelectorAll('input[name="isMainImage"]:checked');
                if (mainImages.length > 1) {
                    errors.push('Only one main image is allowed.');
                } else if (mainImages.length === 0 && existingImages.length > 0) {
                    errors.push('A main image is required.');
                }

                // Display all errors in one alert
                if (errors.length > 0) {
                    e.preventDefault();
                    alert('Please correct the following:\n- ' + errors.join('\n- '));
                }
            });

            // Sidebar active menu
            const currentAction = "${requestScope.currentAction}";
            const currentModule = "${requestScope.currentModule}";
            document.querySelectorAll('.sidebar-menu li.active').forEach(li => li.classList.remove('active'));
            document.querySelectorAll('.sidebar-menu .treeview.menu-open').forEach(li => li.classList.remove('menu-open'));
            if (currentAction && currentModule) {
                const activeLink = document.querySelector(`.sidebar-menu a[href*="${currentAction}"][href*="${currentModule}"]`);
                if (activeLink) {
                    activeLink.parentElement.classList.add('active');
                    const parentTreeview = activeLink.closest('.treeview');
                    if (parentTreeview) {
                        parentTreeview.classList.add('active');
                        parentTreeview.classList.add('menu-open');
                    }
                }
            }

            // Initialize child category dropdown
            filterChildCategories();

            // Bind input event for variant updates
            const variantsContainer = document.getElementById('variants-container');
            if (variantsContainer) {
                variantsContainer.addEventListener('input', updateVariantOptions);
                variantsContainer.addEventListener('click', function(e) {
                    if (e.target.closest('.btn-danger')) {
                        updateVariantOptions();
                    }
                });
            } else {
                console.error("Variants container not found!");
            }
        });
    </script>
</body>
</html>