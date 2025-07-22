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
    String success = (String) request.getAttribute("success"); // New attribute for success message
    List<Category> categories = (List<Category>) request.getAttribute("categories");
    List<Brand> brands = (List<Brand>) request.getAttribute("brands");
    
    String debugProduct = product != null ? "Product ID: " + product.getProductId() : "Product is null";
    String debugCategory = product != null && product.getCategory() != null ? 
        "Category ID: " + product.getCategory().getCategoryId() + ", Name: " + product.getCategory().getName() : 
        "Category is null";
    String debugParentCategoryId = product != null && product.getCategory() != null && product.getCategory().getParentCategoryId() != null ? 
        product.getCategory().getParentCategoryId().toString() : "null";
    Long parentCategoryId = null;
    String parentCategoryName = "None";
    
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
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/admin-dashboard/css/admin-css.css">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <meta http-equiv="Pragma" content="no-cache">
    <meta http-equiv="Expires" content="0">
    <style>
        body {
            background-color: #f8f9fa;
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            color: #2d3748;
        }
        .main-content-wrapper {
            padding: 1.5rem;
        }
        .box {
            background-color: #ffffff;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }
        .box-header {
            background-color: #3b82f6;
            color: #ffffff;
            padding: 1rem 1.5rem;
            border-radius: 8px 8px 0 0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .box-title {
            margin: 0;
            font-size: 1.25rem;
            font-weight: 600;
        }
        .box-body {
            padding: 1.5rem;
        }
        .form-label {
            font-weight: 500;
            font-size: 0.9rem;
            color: #4a5568;
            margin-bottom: 0.5rem;
        }
        .form-control, .form-select {
            border-radius: 6px;
            font-size: 0.85rem;
            border: 1px solid #d1d5db;
            padding: 0.4rem 0.75rem;
        }
        .form-control:focus, .form-select:focus {
            border-color: #3b82f6;
            box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
        }
        .btn {
            border-radius: 6px;
            padding: 0.4rem 0.8rem;
            font-size: 0.85rem;
            transition: all 0.2s ease;
        }
        .btn-primary {
            background-color: #3b82f6;
            border-color: #3b82f6;
        }
        .btn-primary:hover {
            background-color: #2563eb;
            border-color: #2563eb;
            transform: translateY(-1px);
        }
        .btn-outline-primary {
            border-color: #3b82f6;
            color: #3b82f6;
        }
        .btn-outline-primary:hover {
            background-color: #eff6ff;
            color: #3b82f6; /* Prevent text color change on hover */
            transform: translateY(-1px);
        }
        .btn-danger {
            background-color: #ef4444;
            border-color: #ef4444;
        }
        .btn-danger:hover {
            background-color: #dc2626;
            border-color: #dc2626;
            transform: translateY(-1px);
        }
        .btn-secondary {
            background-color: #6b7280;
            border-color: #6b7280;
        }
        .btn-secondary:hover {
            background-color: #4b5563;
            border-color: #4b5563;
            transform: translateY(-1px);
        }
        .alert {
            border-radius: 6px;
            margin-bottom: 1rem;
            font-size: 0.9rem;
        }
        .alert-success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        .variant-row, .image-row {
            padding: 0.75rem;
            border: 1px solid #e5e7eb;
            border-radius: 6px;
            background-color: #f9fafb;
            margin-bottom: 0.75rem;
            transition: all 0.2s ease;
        }
        .image-row.main-image {
            border-color: #3b82f6;
            background-color: #eff6ff;
        }
        .product-image {
            width: 60px;
            height: 60px;
            object-fit: cover;
            border-radius: 6px;
            border: 1px solid #e5e7eb;
            margin-bottom: 0.5rem;
        }
        .form-check-label {
            font-size: 0.85rem;
            color: #4a5568;
        }
        .form-check-input {
            margin-top: 0.25rem;
        }
        @media (max-width: 768px) {
            .main-content-wrapper {
                padding: 1rem;
            }
            .box-body {
                padding: 1rem;
            }
            .variant-row, .image-row {
                padding: 0.5rem;
            }
            .btn {
                padding: 0.3rem 0.6rem;
                font-size: 0.8rem;
            }
            .form-control, .form-select {
                font-size: 0.8rem;
                padding: 0.3rem 0.6rem;
            }
            .product-image {
                width: 50px;
                height: 50px;
            }
        }
    </style>
</head>
<body>
    <c:set var="currentAction" value="products" scope="request"/>
    <c:set var="currentModule" value="admin" scope="request"/>
    <c:set var="pageTitle" value="Edit Product" scope="request"/>
    <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp" />
    
    <div class="content-area">
        <div class="row">
            <div class="col-12">
                <div class="box box-primary">
                    <div class="box-header with-border">
                        <h3 class="box-title">Edit Product</h3>
                    </div>
                    <div class="box-body">
                        <% if (success != null && !success.isEmpty()) { %>
                            <div class="alert alert-success alert-dismissible fade show" role="alert">
                                <%= success %>
                                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                            </div>
                        <% } %>
                        <% if (err != null && !err.isEmpty()) { %>
                            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                <%= err %>
                                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                            </div>
                        <% } %>
                        <form action="${pageContext.request.contextPath}/ProductManager" method="post" enctype="multipart/form-data" class="mt-3">
                            <input type="hidden" name="action" value="update">
                            <input type="hidden" name="id" value="<%= product.getProductId() %>">
                            <div class="row mb-3">
                                <div class="col-md-6">
                                    <label class="form-label">Name <span class="text-danger">*</span></label>
                                    <input type="text" name="name" class="form-control" value="<%= product.getName() != null ? product.getName() : "" %>" required>
                                    <div class="invalid-feedback">Product name is required.</div>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Price <span class="text-danger">*</span></label>
                                    <input type="text" name="price" class="form-control" value="<%= formatPrice(product.getPrice()) %>" placeholder="e.g., 450000 or 450.000" required oninput="validatePrice(this)">
                                    <div class="invalid-feedback">Invalid price (e.g., 450000 or 450.000).</div>
                                </div>
                            </div>
                            <div class="row mb-3">
                                <div class="col-md-6">
                                    <label class="form-label">Brand <span class="text-danger">*</span></label>
                                    <select name="brandId" class="form-select" required>
                                        <option value="">Select brand</option>
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
                                <div class="col-md-6">
                                    <label class="form-label">Category <span class="text-danger">*</span></label>
                                    <div class="row">
                                        <div class="col-md-6">
                                            <select name="parentCategoryId" id="parentCategoryId" class="form-select" onchange="filterChildCategories()">
                                                <option value="">Select parent category</option>
                                                <% 
                                                    if (categories != null) {
                                                        for (Category category : categories) {
                                                            if (category.getParentCategoryId() == null) {
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
                                        <div class="col-md-6">
                                            <select name="categoryId" id="categoryId" class="form-select" required>
                                                <option value="">Select category</option>
                                                <% 
                                                    if (categories != null) {
                                                        for (Category category : categories) {
                                                            if (category.getParentCategoryId() != null) {
                                                %>
                                                <option value="<%= category.getCategoryId() %>" data-parent-id="<%= category.getParentCategoryId() %>"
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
                                    </div>
                                </div>
                            </div>
                            <div class="row mb-3">
                                <div class="col-md-6">
                                    <label class="form-label">Material <span class="text-danger">*</span></label>
                                    <input type="text" name="material" class="form-control" value="<%= product.getMaterial() != null ? product.getMaterial() : "" %>" required>
                                    <div class="invalid-feedback">Material is required.</div>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Status</label>
                                    <select name="status" class="form-select">
                                        <option value="Active" <%= "Active".equals(product.getStatus()) ? "selected" : "" %>>Active</option>
                                        <option value="Discontinued" <%= "Discontinued".equals(product.getStatus()) ? "selected" : "" %>>Discontinued</option>
                                    </select>
                                </div>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Description</label>
                                <textarea name="description" class="form-control" rows="4"><%= product.getDescription() != null ? product.getDescription() : "" %></textarea>
                            </div>
                            <div class="mb-3">
                                <h5 class="fw-semibold">Variants</h5>
                                <div id="variants-container">
                                    <% 
                                        List<ProductVariant> variants = product.getVariants();
                                        if (variants != null && !variants.isEmpty()) {
                                            for (ProductVariant variant : variants) {
                                    %>
                                    <div class="variant-row">
                                        <div class="row align-items-center">
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
                                                <div class="invalid-feedback">Please select a valid size.</div>
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
                                                <div class="invalid-feedback">Please select a valid color.</div>
                                            </div>
                                            <div class="col-md-3">
                                                <input type="text" name="priceModifier" class="form-control" placeholder="e.g., 450000" value="<%= formatPrice(variant.getPriceModifier()) %>" required oninput="validateField(this)">
                                                <div class="invalid-feedback">Variant price must be greater than or equal to the base price.</div>
                                            </div>
                                            <div class="col-md-1">
                                                <button type="button" class="btn btn-danger btn-sm" onclick="removeElement(this)">
                                                    <i class="bi bi-trash"></i>
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                    <% 
                                            }
                                        } else {
                                    %>
                                    <div class="variant-row">
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
                                                <input type="text" name="priceModifier" class="form-control" placeholder="e.g., 450000" required oninput="validateField(this)">
                                                <div class="invalid-feedback">Variant price must be greater than or equal to the base price.</div>
                                            </div>
                                            <div class="col-md-1">
                                                <button type="button" class="btn btn-danger btn-sm" onclick="removeElement(this)">
                                                    <i class="bi bi-trash"></i>
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                    <% 
                                        }
                                    %>
                                </div>
                                <button type="button" class="btn btn-outline-primary btn-sm mt-2" onclick="addVariant()">
                                    <i class="bi bi-plus-circle me-1"></i>Add Variant
                                </button>
                            </div>
                            <div class="mb-3">
                                <h5 class="fw-semibold">Images</h5>
                                <div id="images-container">
                                    <% 
                                        List<ProductImage> images = product.getImages();
                                        int imageIndex = images != null ? images.size() : 0;
                                        if (images != null && !images.isEmpty()) {
                                            for (ProductImage image : images) {
                                    %>
                                    <div class="image-row <%= image.isMain() ? "main-image" : "" %>" data-image-id="<%= image.getImageId() %>">
                                        <div class="row align-items-center">
                                            <div class="col-md-7">
                                                <input type="hidden" name="existingImageId" value="<%= image.getImageId() %>">
                                                <input type="hidden" name="existingImageUrl" value="<%= image.getImageUrl() %>">
                                                <img src="<%= image.getImageUrl() %>" alt="Product Image" class="product-image">
                                                <input type="hidden" name="isMainImages" value="<%= image.isMain() ? "true" : "false" %>" class="is-main-hidden">
                                            </div>
                                            <div class="col-md-3">
                                                <div class="form-check">
                                                    <input type="checkbox" class="form-check-input is-main-checkbox" <%= image.isMain() ? "checked" : "" %> onchange="toggleMainImage(this)">
                                                    <label class="form-check-label">Main Image</label>
                                                </div>
                                            </div>
                                            <div class="col-md-2">
                                                <button type="button" class="btn btn-danger btn-sm" onclick="removeElement(this)">
                                                    <i class="bi bi-trash"></i>
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                    <% 
                                            }
                                        }
                                    %>
                                    <div class="image-row new-image" data-image-index="<%= imageIndex %>">
                                        <div class="row align-items-center">
                                            <div class="col-md-7">
                                                <input type="file" name="images" class="form-control" accept="image/jpeg,image/png,image/gif">
                                                <input type="hidden" name="isMainImages" value="false" class="is-main-hidden">
                                            </div>
                                            <div class="col-md-3">
                                                <div class="form-check">
                                                    <input type="checkbox" class="form-check-input is-main-checkbox" onchange="toggleMainImage(this)">
                                                    <label class="form-check-label">Main Image</label>
                                                </div>
                                            </div>
                                            <div class="col-md-2">
                                                <button type="button" class="btn btn-danger btn-sm" onclick="removeElement(this)">
                                                    <i class="bi bi-trash"></i>
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <button type="button" class="btn btn-outline-primary btn-sm mt-2" onclick="addImage()">
                                    <i class="bi bi-plus-circle me-1"></i>Add Image
                                </button>
                            </div>
                            <div class="text-end">
                                <button type="submit" class="btn btn-primary"><i class="bi bi-save me-1"></i>Update Product</button>
                                <a href="${pageContext.request.contextPath}/ProductManager" class="btn btn-secondary">Cancel</a>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
        <script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
        <script>
            function addVariant() {
                const container = document.getElementById('variants-container');
                const variantDiv = document.createElement('div');
                variantDiv.className = 'variant-row';
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
                            <input type="text" name="priceModifier" class="form-control" placeholder="e.g., 450000" required oninput="validateField(this)">
                            <div class="invalid-feedback">Variant price must be greater than or equal to the base price.</div>
                        </div>
                        <div class="col-md-1">
                            <button type="button" class="btn btn-danger btn-sm" onclick="removeElement(this)">
                                <i class="bi bi-trash"></i>
                            </button>
                        </div>
                    </div>
                `;
                container.appendChild(variantDiv);
                updateVariantOptions();
            }

            function addImage() {
                const container = document.getElementById('images-container');
                const imageRows = document.querySelectorAll('.image-row');
                const imageIndex = imageRows.length;
                const imageDiv = document.createElement('div');
                imageDiv.className = 'image-row new-image';
                imageDiv.setAttribute('data-image-index', imageIndex);
                imageDiv.innerHTML = `
                    <div class="row align-items-center">
                        <div class="col-md-7">
                            <input type="file" name="images" class="form-control" accept="image/jpeg,image/png,image/gif">
                            <input type="hidden" name="isMainImages" value="false" class="is-main-hidden">
                        </div>
                        <div class="col-md-3">
                            <div class="form-check">
                                <input type="checkbox" class="form-check-input is-main-checkbox" onchange="toggleMainImage(this)">
                                <label class="form-check-label">Main Image</label>
                            </div>
                        </div>
                        <div class="col-md-2">
                            <button type="button" class="btn btn-danger btn-sm" onclick="removeElement(this)">
                                <i class="bi bi-trash"></i>
                            </button>
                        </div>
                    </div>
                `;
                container.appendChild(imageDiv);
            }

            function removeElement(button) {
                const row = button.closest('.variant-row') || button.closest('.image-row');
                if (row) {
                    row.remove();
                    updateVariantOptions();
                    const isMain = row.querySelector('.is-main-checkbox')?.checked;
                    if (isMain) {
                        const firstCheckbox = document.querySelector('.is-main-checkbox');
                        if (firstCheckbox) {
                            firstCheckbox.checked = true;
                            toggleMainImage(firstCheckbox);
                        }
                    }
                }
            }

            function toggleMainImage(checkbox) {
                const imageRows = document.querySelectorAll('.image-row');
                imageRows.forEach(row => {
                    const rowCheckbox = row.querySelector('.is-main-checkbox');
                    const hiddenInput = row.querySelector('.is-main-hidden');
                    row.classList.remove('main-image');
                    hiddenInput.value = 'false';
                    if (rowCheckbox === checkbox && checkbox.checked) {
                        row.classList.add('main-image');
                        hiddenInput.value = 'true';
                        rowCheckbox.checked = true;
                    } else {
                        rowCheckbox.checked = false;
                    }
                });
            }

            function validatePrice(field) {
                const value = field.value.replace(/\./g, '');
                const numberRegex = /^\d+(\.\d{3})*$|^\d+$/;
                field.classList.remove('is-invalid');
                if (!value || !numberRegex.test(value) || parseInt(value) <= 0) {
                    field.classList.add('is-invalid');
                    field.nextElementSibling.textContent = 'Invalid price (e.g., 450000 or 450.000).';
                }
                const variants = document.querySelectorAll('#variants-container .variant-row');
                variants.forEach(variant => {
                    const priceModifierInput = variant.querySelector('input[name="priceModifier"]');
                    if (priceModifierInput) {
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

                field.classList.remove('is-invalid');

                if (name === 'size' && (!value || !validSizes.includes(value))) {
                    field.classList.add('is-invalid');
                    field.nextElementSibling.textContent = 'Please select a valid size.';
                } else if (name === 'color' && (!value || !validColors.includes(value))) {
                    field.classList.add('is-invalid');
                    field.nextElementSibling.textContent = 'Please select a valid color.';
                } else if (name === 'priceModifier') {
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
                                if (vSize && vColor && vSize === size && vColor === color) {
                                    duplicateCount++;
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
                    }
                }
            }

            function updateVariantOptions() {
                const variants = document.querySelectorAll('#variants-container .variant-row');
                variants.forEach((variant, index) => {
                    const sizeSelect = variant.querySelector('select[name="size"]');
                    const colorSelect = variant.querySelector('select[name="color"]');
                    const priceModifier = variant.querySelector('input[name="priceModifier"]');
                    if (sizeSelect && colorSelect && priceModifier) {
                        validateField(sizeSelect);
                        validateField(colorSelect);
                        validateField(priceModifier);
                    }
                });
            }

            function filterChildCategories() {
                const parentCategoryId = document.getElementById('parentCategoryId')?.value || '';
                const categorySelect = document.getElementById('categoryId');
                if (categorySelect) {
                    const options = categorySelect.querySelectorAll('option:not([value=""])');
                    options.forEach(option => {
                        const parentId = option.getAttribute('data-parent-id');
                        option.style.display = parentCategoryId === '' || parentId === parentCategoryId ? 'block' : 'none';
                    });
                    const selectedOption = categorySelect.options[categorySelect.selectedIndex];
                    if (selectedOption && selectedOption.getAttribute('data-parent-id') !== parentCategoryId) {
                        categorySelect.value = '';
                    }
                }
            }

            document.addEventListener('DOMContentLoaded', function() {
                filterChildCategories();
                updateVariantOptions();

                const form = document.querySelector('form');
                if (form) {
                    form.addEventListener('submit', function(e) {
                        const nameInput = document.querySelector('input[name="name"]');
                        const priceInput = document.querySelector('input[name="price"]');
                        const categorySelect = document.querySelector('select[name="categoryId"]');
                        const brandSelect = document.querySelector('select[name="brandId"]');
                        const materialInput = document.querySelector('input[name="material"]');
                        const sizes = document.querySelectorAll('#variants-container .variant-row select[name="size"]');
                        const colors = document.querySelectorAll('#variants-container .variant-row select[name="color"]');
                        const priceModifiers = document.querySelectorAll('#variants-container .variant-row input[name="priceModifier"]');
                        const images = document.querySelectorAll('input[name="images"]');
                        const existingImages = document.querySelectorAll('input[name="existingImageUrl"]');
                        const mainImages = document.querySelectorAll('.is-main-checkbox:checked');
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

                        if (images.length === 0 && existingImages.length === 0) {
                            errors.push('At least one image is required.');
                        }
                        for (let i = 0; i < images.length; i++) {
                            if (images[i].value && !images[i].value.match(/\.(jpg|jpeg|png|gif)$/i)) {
                                errors.push(`Invalid image format for upload ${i + 1}.`);
                                images[i].classList.add('is-invalid');
                            }
                        }

                        if (mainImages.length > 1) {
                            errors.push('Only one main image can be selected.');
                        } else if (mainImages.length === 0 && (images.length > 0 || existingImages.length > 0)) {
                            errors.push('Please select one main image.');
                        }

                        if (errors.length > 0) {
                            e.preventDefault();
                            alert('Please fix the following errors:\n- ' + errors.join('\n- '));
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
            });
        </script>
    </body>
</html>