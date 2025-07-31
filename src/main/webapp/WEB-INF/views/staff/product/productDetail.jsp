<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@page import="java.math.BigDecimal"%>
<%@page import="model.Product"%>
<%@page import="model.ProductVariant"%>
<%@page import="model.ProductImage"%>
<%@page import="model.Category"%>
<%@page import="dao.CategoryDAO"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="java.text.DecimalFormatSymbols"%>
<%@page import="java.util.List"%>
<%
    Product product = (Product) request.getAttribute("data");
    String err = (String) request.getAttribute("err");
    CategoryDAO cateDAO = new CategoryDAO();
    Category parentCategory = null;
    if (product != null && product.getCategory() != null && product.getCategory().getParentCategoryId() != null) {
        parentCategory = cateDAO.getCategoryById(product.getCategory().getParentCategoryId());
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
        DecimalFormat df = new DecimalFormat("#,###.##", symbols);
        return df.format(price);
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Product Details</title>
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
        .detail-section {
            margin-bottom: 1.5rem;
        }
        .detail-label {
            font-weight: 600;
            font-size: 0.9rem;
            color: #4a5568;
            margin-bottom: 0.25rem;
        }
        .detail-value {
            font-size: 0.9rem;
            color: #2d3748;
        }
        .variant-table, .image-grid {
            margin-bottom: 1rem;
        }
        .variant-table .table {
            font-size: 0.85rem;
            border-collapse: separate;
            border-spacing: 0;
        }
        .variant-table th, .variant-table td {
            padding: 0.5rem;
            vertical-align: middle;
        }
        .variant-table th {
            background-color: #f9fafb;
            font-weight: 600;
            text-transform: uppercase;
            font-size: 0.8rem;
        }
        .image-grid {
            display: flex;
            flex-wrap: wrap;
            gap: 0.5rem;
        }
        .image-item {
            position: relative;
            width: 60px;
            height: 60px;
        }
        .product-image {
            width: 100%;
            height: 100%;
            object-fit: cover;
            border-radius: 6px;
            border: 1px solid #e5e7eb;
        }
        .main-image-badge {
            position: absolute;
            top: 0;
            right: 0;
            background-color: #3b82f6;
            color: #ffffff;
            font-size: 0.7rem;
            padding: 0.2rem 0.4rem;
            border-radius: 0 0 0 4px;
        }
        .btn {
            border-radius: 6px;
            padding: 0.4rem 0.8rem;
            font-size: 0.85rem;
            transition: all 0.2s ease;
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
        @media (max-width: 768px) {
            .main-content-wrapper {
                padding: 1rem;
            }
            .box-body {
                padding: 1rem;
            }
            .variant-table th, .variant-table td {
                padding: 0.4rem;
                font-size: 0.8rem;
            }
            .image-item {
                width: 50px;
                height: 50px;
            }
            .btn {
                padding: 0.3rem 0.6rem;
                font-size: 0.8rem;
            }
        }
    </style>
</head>
<body>
    <c:set var="currentAction" value="products" scope="request"/>
    <c:set var="currentModule" value="admin" scope="request"/>
    <c:set var="pageTitle" value="Product Details" scope="request"/>
    <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp" />
    
        <div class="content-area">
            <div class="row">
                <div class="col-12">
                    <div class="box box-primary">
                        <div class="box-header with-border">
                            <h3 class="box-title">Product Details</h3>
                        </div>
                        <div class="box-body">
                            <% if (err != null && !err.isEmpty()) { %>
                                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                    <%= err %>
                                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                                </div>
                            <% } %>
                            <% if (product != null) { %>
                                <div class="detail-section">
                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="detail-label">ID</div>
                                            <div class="detail-value"><%= product.getProductId() %></div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="detail-label">Name</div>
                                            <div class="detail-value"><%= product.getName() != null ? product.getName() : "N/A" %></div>
                                        </div>
                                    </div>
                                </div>
                                <div class="detail-section">
                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="detail-label">Price</div>
                                            <div class="detail-value"><%= formatPrice(product.getPrice()) %>đ</div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="detail-label">Status</div>
                                            <div class="detail-value">
                                                <span class="badge <%= product.getStatus() != null && product.getStatus().equalsIgnoreCase("Active") ? "bg-success" : "bg-danger" %> text-white">
                                                    <%= product.getStatus() != null ? product.getStatus() : "N/A" %>
                                                </span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="detail-section">
                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="detail-label">Parent Category</div>
                                            <div class="detail-value"><%= parentCategory != null ? parentCategory.getName() : "None" %></div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="detail-label">Category</div>
                                            <div class="detail-value"><%= product.getCategory() != null ? product.getCategory().getName() : "N/A" %></div>
                                        </div>
                                    </div>
                                </div>
                                <div class="detail-section">
                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="detail-label">Brand</div>
                                            <div class="detail-value"><%= product.getBrand() != null ? product.getBrand().getName() : "N/A" %></div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="detail-label">Material</div>
                                            <div class="detail-value"><%= product.getMaterial() != null ? product.getMaterial() : "N/A" %></div>
                                        </div>
                                    </div>
                                </div>
                                <div class="detail-section">
                                    <div class="detail-label">Description</div>
                                    <div class="detail-value"><%= product.getDescription() != null ? product.getDescription() : "N/A" %></div>
                                </div>
                                <div class="detail-section variant-table">
                                    <div class="detail-label">Variants</div>
                                    <% 
                                        List<ProductVariant> variants = product.getVariants();
                                        if (variants != null && !variants.isEmpty()) {
                                    %>
                                        <table class="table table-bordered">
                                            <thead>
                                                <tr>
                                                    <th>Size</th>
                                                    <th>Color</th>
                                                    <th>Price Variant</th>
                                                    <th>SKU</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <% for (ProductVariant variant : variants) { %>
                                                    <tr>
                                                        <td><%= variant.getSize() != null ? variant.getSize() : "N/A" %></td>
                                                        <td><%= variant.getColor() != null ? variant.getColor() : "N/A" %></td>
                                                        <td><%= formatPrice(variant.getPriceModifier()) %>đ</td>
                                                        <td><%= variant.getSku() != null ? variant.getSku() : "N/A" %></td>
                                                    </tr>
                                                <% } %>
                                            </tbody>
                                        </table>
                                    <% } else { %>
                                        <div class="detail-value text-muted">No variants available.</div>
                                    <% } %>
                                </div>
                                <div class="detail-section image-grid">
                                    <div class="detail-label">Images</div>
                                    <% 
                                        List<ProductImage> images = product.getImages();
                                        if (images != null && !images.isEmpty()) {
                                    %>
                                        <div class="image-grid">
                                            <% for (ProductImage image : images) { %>
                                                <div class="image-item">
                                                    <img src="<%= image.getImageUrl() != null ? image.getImageUrl() : "https://placehold.co/60x60?text=No+Image" %>" alt="Product Image" class="product-image">
                                                    <% if (image.isMain()) { %>
                                                        <span class="main-image-badge">Main</span>
                                                    <% } %>
                                                </div>
                                            <% } %>
                                        </div>
                                    <% } else { %>
                                        <div class="detail-value text-muted">No images available.</div>
                                    <% } %>
                                </div>
                                <div class="text-end">
                                    <a href="${pageContext.request.contextPath}/ProductManager" class="btn btn-secondary"><i class="bi bi-arrow-left me-1"></i>Back to Products</a>
                                </div>
                            <% } else { %>
                                <div class="alert alert-warning">No product found!</div>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
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
        });
    </script>
</body>
</html>