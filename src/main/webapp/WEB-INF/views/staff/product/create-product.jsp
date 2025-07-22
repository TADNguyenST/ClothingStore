<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@page import="java.math.BigDecimal"%>
<%@page import="model.Category"%>
<%@page import="model.Brand"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="java.text.DecimalFormatSymbols"%>
<%@page import="java.util.List"%>
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
    <title>Add New Product</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/admin-dashboard/css/admin-css.css">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <meta http-equiv="Pragma" content="no-cache">
    <meta http-equiv="Expires" content="0">
    <style>
        body {
            background-color: #f5f7fa;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        .main-content-wrapper {
            padding: 20px;
        }
        .box {
            background-color: #ffffff;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }
        .box-header {
            background-color: #007bff;
            color: #ffffff;
            padding: 15px 20px;
            border-radius: 12px 12px 0 0;
        }
        .box-title {
            margin: 0;
            font-size: 1.5rem;
            font-weight: 600;
        }
        .box-body {
            padding: 20px;
        }
        .form-label {
            font-weight: 500;
            color: #333;
        }
        .form-control, .form-select {
            border-radius: 6px;
            font-size: 0.9rem;
        }
        .btn {
            border-radius: 6px;
            padding: 8px 12px;
            font-size: 0.9rem;
            transition: all 0.3s ease;
        }
        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
        }
        .alert {
            border-radius: 8px;
            margin-bottom: 20px;
        }
        .variant-row, .image-row {
            padding: 10px;
            border: 1px solid #e9ecef;
            border-radius: 8px;
            background-color: #f8f9fa;
            margin-bottom: 15px;
        }
        .image-row.main-image {
            border-color: #007bff;
            background-color: #e7f1ff;
        }
        .form-check-label {
            margin-left: 5px;
        }
        @media (max-width: 768px) {
            .variant-row, .image-row {
                padding: 8px;
            }
            .btn-sm {
                padding: 6px 10px;
                font-size: 0.85rem;
            }
        }
    </style>
</head>
<body>
    <c:set var="currentAction" value="products" scope="request"/>
    <c:set var="currentModule" value="admin" scope="request"/>
    <c:set var="pageTitle" value="Add New Product" scope="request"/>
    <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp" />
    
        
        <div class="content-area">
            <div class="row">
                <div class="col-12">
                    <div class="box box-primary">
                        <div class="box-header with-border">
                            <h3 class="box-title">Add New Product</h3>
                        </div>
                        <div class="box-body">
                            <% if (err != null && !err.isEmpty()) { %>
                                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                    <%= err %>
                                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                                </div>
                            <% } %>
                            <form action="${pageContext.request.contextPath}/ProductManager" method="post" enctype="multipart/form-data" class="mt-3">
                                <input type="hidden" name="action" value="create">
                                <div class="row mb-3">
                                    <div class="col-md-6">
                                        <label class="form-label">Name <span class="text-danger">*</span></label>
                                        <input type="text" name="name" class="form-control" required>
                                        <div class="invalid-feedback">Product name is required.</div>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label">Price <span class="text-danger">*</span></label>
                                        <input type="text" name="price" class="form-control" placeholder="e.g., 450000 or 450.000" required oninput="validatePrice(this)">
                                        <div class="invalid-feedback">Invalid price (e.g., 450000 or 450.000).</div>
                                    </div>
                                </div>
                                <div class="row mb-3">
                                    <div class="col-md-6">
                                        <label class="form-label">Brand <span class="text-danger">*</span></label>
                                        <select name="brandId" class="form-select" required>
                                            <option value="">Select brand</option>
                                            <% if (brands != null) { %>
                                                <% for (Brand brand : brands) { %>
                                                    <option value="<%= brand.getBrandId() %>"><%= brand.getName() %></option>
                                                <% } %>
                                            <% } %>
                                        </select>
                                        <div class="invalid-feedback">Brand is required.</div>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label">Category <span class="text-danger">*</span></label>
                                        <div class="row">
                                            <div class="col-md-6">
                                                <select name="parentCategoryId" id="parentCategoryId" class="form-select" onchange="filterChildCategories()">
                                                    <option value="">Select parent category</option>
                                                    <% if (categories != null) { %>
                                                        <% for (Category category : categories) { %>
                                                            <% if (category.getParentCategoryId() == null) { %>
                                                                <option value="<%= category.getCategoryId() %>"><%= category.getName() %></option>
                                                            <% } %>
                                                        <% } %>
                                                    <% } %>
                                                </select>
                                            </div>
                                            <div class="col-md-6">
                                                <select name="categoryId" id="categoryId" class="form-select" required>
                                                    <option value="">Select category</option>
                                                    <% if (categories != null) { %>
                                                        <% for (Category category : categories) { %>
                                                            <% if (category.getParentCategoryId() != null) { %>
                                                                <option value="<%= category.getCategoryId() %>" data-parent-id="<%= category.getParentCategoryId() %>">
                                                                    <%= category.getName() %>
                                                                </option>
                                                            <% } %>
                                                        <% } %>
                                                    <% } %>
                                                </select>
                                                <div class="invalid-feedback">Category is required.</div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="row mb-3">
                                    <div class="col-md-6">
                                        <label class="form-label">Material <span class="text-danger">*</span></label>
                                        <input type="text" name="material" class="form-control" required>
                                        <div class="invalid-feedback">Material is required.</div>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label">Status</label>
                                        <select name="status" class="form-select">
                                            <option value="Active" selected>Active</option>
                                            <option value="Discontinued">Discontinued</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Description</label>
                                    <textarea name="description" class="form-control"></textarea>
                                </div>
                                <h4>Variants</h4>
                                <div id="variants-container" class="mb-3">
                                    <div class="variant-row mb-3">
                                        <div class="row align-items-center">
                                            <div class="col-md-4">
                                                <select name="size" class="form-control" required onchange="validateField(this)">
                                                    <option value="" disabled selected>Select Size</option>
                                                    <option value="S">S</option>
                                                    <option value="M">M</option>
                                                    <option value="L">L</option>
                                                    <option value="XL">XL</option>
                                                    <option value="XS">XS</option>
                                                </select>
                                                <div class="invalid-feedback">Please select a valid size.</div>
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
                                                <div class="invalid-feedback">Please select a valid color.</div>
                                            </div>
                                            <div class="col-md-3">
                                                <input type="text" name="priceModifier" class="form-control" placeholder="e.g., 450000 or 450.000" required oninput="validateField(this)">
                                                <div class="invalid-feedback">Variant price must be greater than or equal to the base price.</div>
                                            </div>
                                            <div class="col-md-1">
                                                <button type="button" class="btn btn-danger btn-sm" onclick="removeElement(this)">
                                                    <i class="bi bi-trash"></i> Remove
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <button type="button" class="btn btn-outline-primary mb-3" onclick="addVariant()">
                                    <i class="bi bi-plus-circle"></i> Add Variant
                                </button>
                                <h4>Images</h4>
                                <div id="images-container" class="mb-3">
                                    <div class="image-row mb-3">
                                        <div class="row align-items-center">
                                            <div class="col-md-7">
                                                <input type="file" name="images" class="form-control" accept="image/jpeg,image/png,image/gif" required>
                                                <div class="invalid-feedback">Please select a valid image (jpg, png, gif).</div>
                                            </div>
                                            <div class="col-md-3">
                                                <div class="form-check">
                                                    <input type="checkbox" name="isMainImage" value="true" class="form-check-input is-main-checkbox" onchange="toggleMainImage(this)">
                                                    <label class="form-check-label">Main Image</label>
                                                </div>
                                            </div>
                                            <div class="col-md-2">
                                                <button type="button" class="btn btn-danger btn-sm" onclick="removeElement(this)">
                                                    <i class="bi bi-trash"></i> Remove
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <button type="button" class="btn btn-outline-primary mb-3" onclick="addImage()">
                                    <i class="bi bi-plus-circle"></i> Add Image
                                </button>
                                <div class="text-end">
                                    <button type="submit" class="btn btn-primary"><i class="bi bi-save"></i> Add Product</button>
                                    <a href="${pageContext.request.contextPath}/ProductManager" class="btn btn-secondary">Cancel</a>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
        <script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>
        <script>
    function initializeVariants() {
        console.log("Initializing variants...");
        const container = document.getElementById('variants-container');
        if (container) {
            const variantRows = container.querySelectorAll('.variant-row');
            console.log("Found " + variantRows.length + " initial variant rows.");
            variantRows.forEach(row => row.remove());
            console.log("Removed all initial variant rows.");
            addVariant();
        } else {
            console.error("Container 'variants-container' not found!");
        }
    }

    function removeElement(button) {
        const row = button.closest('.variant-row') || button.closest('.image-row');
        if (row) {
            row.remove();
            console.log("Element removed.");
            updateVariantOptions();
            const isMain = row.querySelector('.is-main-checkbox')?.checked;
            if (isMain) {
                const firstCheckbox = document.querySelector('.is-main-checkbox');
                if (firstCheckbox) {
                    firstCheckbox.checked = true;
                    toggleMainImage(firstCheckbox);
                }
            }
        } else {
            console.error("Row to remove not found!");
        }
    }

    function addVariant() {
        console.log("Adding new variant...");
        const container = document.getElementById('variants-container');
        if (!container) {
            console.error("Container 'variants-container' not found!");
            return;
        }
        const variantDiv = document.createElement('div');
        variantDiv.className = 'variant-row mb-3';
        variantDiv.innerHTML = `
            <div class="row align-items-center">
                <div class="col-md-4">
                    <select name="size" class="form-control" required onchange="validateField(this)">
                        <option value="" disabled selected>Select Size</option>
                        <option value="S">S</option>
                        <option value="M">M</option>
                        <option value="L">L</option>
                        <option value="XL">XL</option>
                        <option value="XS">XS</option>
                    </select>
                    <div class="invalid-feedback">Please select a valid size.</div>
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
                    <div class="invalid-feedback">Please select a valid color.</div>
                </div>
                <div class="col-md-3">
                    <input type="text" name="priceModifier" class="form-control" placeholder="e.g., 450000 or 450.000" required oninput="validateField(this)">
                    <div class="invalid-feedback">Invalid variant price (e.g., 450000).</div>
                </div>
                <div class="col-md-1">
                    <button type="button" class="btn btn-danger btn-sm" onclick="removeElement(this)">
                        <i class="bi bi-trash"></i> Remove
                    </button>
                </div>
            </div>
        `;
        container.appendChild(variantDiv);
        console.log("Variant added successfully.");
        // Do not call updateVariantOptions immediately to avoid premature validation
    }

    function addImage() {
        console.log("Adding new image...");
        const container = document.getElementById('images-container');
        if (!container) {
            console.error("Container 'images-container' not found!");
            return;
        }
        const imageDiv = document.createElement('div');
        imageDiv.className = 'image-row mb-3';
        imageDiv.innerHTML = `
            <div class="row align-items-center">
                <div class="col-md-7">
                    <input type="file" name="images" class="form-control" accept="image/jpeg,image/png,image/gif" required>
                    <div class="invalid-feedback">Please select a valid image (jpg, png, gif).</div>
                </div>
                <div class="col-md-3">
                    <div class="form-check">
                        <input type="checkbox" name="isMainImage" value="true" class="form-check-input is-main-checkbox" onchange="toggleMainImage(this)">
                        <label class="form-check-label">Main Image</label>
                    </div>
                </div>
                <div class="col-md-2">
                    <button type="button" class="btn btn-danger btn-sm" onclick="removeElement(this)">
                        <i class="bi bi-trash"></i> Remove
                    </button>
                </div>
            </div>
        `;
        container.appendChild(imageDiv);
        console.log("Image added successfully.");
    }

    function toggleMainImage(checkbox) {
        console.log("Toggling main image...");
        const checkboxes = document.querySelectorAll('.is-main-checkbox');
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

    function updateVariantOptions() {
        console.log("Updating variant options...");
        const variants = document.querySelectorAll('#variants-container .variant-row');
        console.log("Found " + variants.length + " variant rows.");
        variants.forEach((variant, index) => {
            const sizeSelect = variant.querySelector('select[name="size"]');
            const colorSelect = variant.querySelector('select[name="color"]');
            const priceModifier = variant.querySelector('input[name="priceModifier"]');
            if (sizeSelect && colorSelect && priceModifier) {
                console.log(`Checking variant ${index + 1}: Size=${sizeSelect.value}, Color=${colorSelect.value}`);
                validateField(sizeSelect);
                validateField(colorSelect);
                // Only validate priceModifier if it has a value
                if (priceModifier.value) {
                    validateField(priceModifier);
                }
            } else {
                console.error(`Variant ${index + 1} missing size, color, or priceModifier element.`);
            }
        });
    }

    function validatePrice(field) {
        const value = field.value.replace(/\./g, '');
        const numberRegex = /^\d+(\.\d{3})*$|^\d+$/;
        field.classList.remove('is-invalid');
        if (value && (!numberRegex.test(value) || parseInt(value) <= 0)) {
            console.log(`Invalid price: ${value}`);
            field.classList.add('is-invalid');
            field.nextElementSibling.textContent = 'Invalid price (e.g., 450000 or 450.000).';
        }
        const variants = document.querySelectorAll('#variants-container .variant-row');
        variants.forEach(variant => {
            const priceModifierInput = variant.querySelector('input[name="priceModifier"]');
            if (priceModifierInput && priceModifierInput.value) {
                validateField(priceModifierInput);
            }
        });
    }

    function validateField(field) {
        const variantRow = field.closest('.variant-row');
        if (!variantRow) return;
        const name = field.name;
        const value = field.value;
        const validSizes = ['S', 'M', 'L', 'XL', 'XS'];
        const validColors = ['Red', 'Blue', 'Green', 'Black', 'White', 'Yellow'];
        const numberRegex = /^\d+(\.\d{3})*$|^\d+$/;

        console.log(`Validating field: Name=${name}, Value=${value}`);
        field.classList.remove('is-invalid');

        if (name === 'size' && (!value || !validSizes.includes(value))) {
            field.classList.add('is-invalid');
            field.nextElementSibling.textContent = 'Please select a valid size.';
        } else if (name === 'color' && (!value || !validColors.includes(value))) {
            field.classList.add('is-invalid');
            field.nextElementSibling.textContent = 'Please select a valid color.';
        } else if (name === 'priceModifier' && value) { // Only validate if value is not empty
            const priceInput = document.querySelector('input[name="price"]');
            const priceStr = priceInput ? priceInput.value.replace(/\./g, '') : '0';
            const price = priceStr && numberRegex.test(priceStr) ? parseInt(priceStr) : 0;
            const modifierStr = value.replace(/\./g, '');
            if (!modifierStr || !numberRegex.test(modifierStr)) {
                field.classList.add('is-invalid');
                field.nextElementSibling.textContent = 'Invalid variant price (e.g., 450000).';
            } else {
                const modifier = parseInt(modifierStr);
                if (modifier < price) {
                    field.classList.add('is-invalid');
                    field.nextElementSibling.textContent = `Variant price must be greater than or equal to the base price.`;
                }
            }
        }

        const sizeSelect = variantRow.querySelector('select[name="size"]');
        const colorSelect = variantRow.querySelector('select[name="color"]');
        if (sizeSelect && colorSelect) {
            const size = sizeSelect.value;
            const color = colorSelect.value;
            if (validSizes.includes(size) && validColors.includes(color)) {
                const variants = document.querySelectorAll('#variants-container .variant-row');
                let duplicateCount = 0;
                variants.forEach((variant, index) => {
                    if (variant !== variantRow) {
                        const vSize = variant.querySelector('select[name="size"]')?.value || '';
                        const vColor = variant.querySelector('select[name="color"]')?.value || '';
                        if (vSize && vColor && validSizes.includes(vSize) && validColors.includes(vColor) && vSize === size && vColor === color) {
                            duplicateCount++;
                            console.log(`Found duplicate with variant ${index + 1}: Size=${vSize}, Color=${vColor}`);
                        }
                    }
                });
                if (duplicateCount > 0) {
                    sizeSelect.classList.add('is-invalid');
                    colorSelect.classList.add('is-invalid');
                    sizeSelect.nextElementSibling.textContent = `Duplicate size (${size}) and color (${color}) with another variant.`;
                    colorSelect.nextElementSibling.textContent = `Duplicate size (${size}) and color (${color}) with another variant.`;
                } else {
                    sizeSelect.classList.remove('is-invalid');
                    colorSelect.classList.remove('is-invalid');
                }
            } else if (!size || !color) {
                sizeSelect.classList.remove('is-invalid');
                colorSelect.classList.remove('is-invalid');
            }
        }
    }

    function filterChildCategories() {
        console.log("Filtering child categories...");
        const parentCategoryId = document.getElementById('parentCategoryId')?.value || '';
        const categorySelect = document.getElementById('categoryId');
        if (categorySelect) {
            const options = categorySelect.querySelectorAll('option:not([value=""])');
            options.forEach(option => {
                const parentId = option.getAttribute('data-parent-id');
                option.style.display = parentCategoryId === '' || parentId === parentCategoryId ? 'block' : 'none';
            });
            categorySelect.value = '';
            console.log("Child categories filtered.");
        } else {
            console.error("Category select not found!");
        }
    }

    document.addEventListener('DOMContentLoaded', function() {
        console.log("Page loaded, setting up events...");
        initializeVariants();

        const form = document.querySelector('form');
        if (form) {
            form.addEventListener('submit', function(e) {
                console.log("Form submission action...");
                const priceInput = document.querySelector('input[name="price"]');
                const nameInput = document.querySelector('input[name="name"]');
                const categorySelect = document.querySelector('select[name="categoryId"]');
                const brandSelect = document.querySelector('select[name="brandId"]');
                const materialInput = document.querySelector('input[name="material"]');
                const sizes = document.querySelectorAll('#variants-container .variant-row select[name="size"]');
                const colors = document.querySelectorAll('#variants-container .variant-row select[name="color"]');
                const priceModifiers = document.querySelectorAll('#variants-container .variant-row input[name="priceModifier"]');
                const images = document.querySelectorAll('input[name="images"]');
                const numberRegex = /^\d+(\.\d{3})*$|^\d+$/;
                const validSizes = ['S', 'M', 'L', 'XL', 'XS'];
                const validColors = ['Red', 'Blue', 'Green', 'Black', 'White', 'Yellow'];
                const errors = [];

                nameInput.classList.remove('is-invalid');
                priceInput.classList.remove('is-invalid');
                categorySelect.classList.remove('is-invalid');
                brandSelect.classList.remove('is-invalid');
                materialInput.classList.remove('is-invalid');
                sizes.forEach(s => s.classList.remove('is-invalid'));
                colors.forEach(c => c.classList.remove('is-invalid'));
                priceModifiers.forEach(p => p.classList.remove('is-invalid'));

                if (!nameInput.value.trim()) {
                    errors.push('Product name is required.');
                    nameInput.classList.add('is-invalid');
                }
                let price = 0;
                if (priceInput) {
                    const priceStr = priceInput.value.replace(/\./g, '');
                    if (!numberRegex.test(priceStr) || parseInt(priceStr) <= 0) {
                        errors.push('Invalid price (e.g., 450000 or 450.000).');
                        priceInput.classList.add('is-invalid');
                    } else {
                        price = parseInt(priceStr);
                    }
                }
                if (!categorySelect.value) {
                    errors.push('Category is required.');
                    categorySelect.classList.add('is-invalid');
                }
                if (!brandSelect.value) {
                    errors.push('Brand is required.');
                    brandSelect.classList.add('is-invalid');
                }
                if (!materialInput.value.trim()) {
                    errors.push('Material is required.');
                    materialInput.classList.add('is-invalid');
                }

                if (sizes.length === 0) {
                    errors.push('At least one variant is required.');
                } else {
                    sizes.forEach((size, i) => {
                        if (!validSizes.includes(size.value)) {
                            errors.push(`Invalid size in variant ${i + 1}.`);
                            size.classList.add('is-invalid');
                        }
                    });
                    colors.forEach((color, i) => {
                        if (!validColors.includes(color.value)) {
                            errors.push(`Invalid color in variant ${i + 1}.`);
                            color.classList.add('is-invalid');
                        }
                    });
                    priceModifiers.forEach((pm, i) => {
                        const modifierStr = pm.value.replace(/\./g, '');
                        if (!modifierStr || !numberRegex.test(modifierStr)) {
                            errors.push(`Invalid variant price in variant ${i + 1}.`);
                            pm.classList.add('is-invalid');
                        } else {
                            const modifier = parseInt(modifierStr);
                            if (modifier < price) {
                                errors.push(`Variant price (${modifier}) in variant ${i + 1} must be greater than or equal to the base price (${price}).`);
                                pm.classList.add('is-invalid');
                            }
                        }
                    });
                }

                if (images.length === 0) {
                    errors.push('At least one image is required.');
                }
                for (let i = 0; i < images.length; i++) {
                    if (!images[i].value) {
                        errors.push(`Please select an image to upload ${i + 1}.`);
                        images[i].classList.add('is-invalid');
                    }
                }

                const mainImages = document.querySelectorAll('.is-main-checkbox:checked');
                if (mainImages.length > 1) {
                    errors.push('Only one main image can be selected.');
                } else if (mainImages.length === 0 && images.length > 0) {
                    errors.push('Please select one main image.');
                }

                if (errors.length > 0) {
                    e.preventDefault();
                    console.log("Errors found: ", errors);
                    alert('Please fix the following errors:\n- ' + errors.join('\n- '));
                } else {
                    console.log("No errors, submitting form...");
                }
            });
        }

        const variantsContainer = document.getElementById('variants-container');
        if (variantsContainer) {
            variantsContainer.addEventListener('input', function(e) {
                if (e.target.name === 'size' || e.target.name === 'color' || e.target.name === 'priceModifier') {
                    validateField(e.target);
                }
            });
            variantsContainer.addEventListener('click', function(e) {
                if (e.target.closest('.btn-danger')) {
                    updateVariantOptions();
                }
            });
        }

        filterChildCategories();
    });
</script>
    </body>
</html>