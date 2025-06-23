<%@page import="dao.CategoryDAO"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@page import="java.math.BigDecimal"%>
<%@page import="model.Product"%>
<%@page import="model.Category"%>
<%@page import="dao.ProductDAO"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="java.text.DecimalFormatSymbols"%>
<%
    Product product = (Product) request.getAttribute("data");
    String err = (String) request.getAttribute("err");
    ProductDAO dao = new ProductDAO();
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
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/admin-dashboard/css/admin-css.css">
</head>
<body>
    <c:set var="currentAction" value="products" scope="request"/>
    <c:set var="currentModule" value="admin" scope="request"/>
    <c:set var="pageTitle" value="Product Details" scope="request"/>

    <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp" />

    <div class="main-content-wrapper">
        <jsp:include page="/WEB-INF/includes/admin-header.jsp" />
        
        <div class="content-area">
            <div class="row">
                <div class="col-xs-12">
                    <div class="box box-primary">
                        <div class="box-header with-border">
                            <h3 class="box-title">Product Details</h3>
                        </div>
                        <div class="box-body">
                            <% if (err != null && !err.isEmpty()) { %>
                                <p class="text-danger"><%= err %></p>
                            <% } %>

                            <% if (product != null) { %>
                                <table class="table table-bordered">
                                    <tbody>
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
                                            <th>Parent Category</th>
                                            <td><%= parentCategory != null ? parentCategory.getName() : "None" %></td>
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
                                                    java.util.List variants = product.getVariants();
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
                                                    java.util.List images = product.getImages();
                                                    if (images != null && !images.isEmpty()) {
                                                        for (Object image : images) {
                                                            String imageUrl = (String) image.getClass().getMethod("getImageUrl").invoke(image);
                                                %>
                                                            <img src="<%= imageUrl %>" alt="Product Image" width="100" class="img-thumbnail m-1"><br>
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
                                    </tbody>
                                </table>
                                <a href="${pageContext.request.contextPath}/ProductManager" class="btn btn-secondary">Back to Products</a>
                            <% } else { %>
                                <p>No product found!</p>
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