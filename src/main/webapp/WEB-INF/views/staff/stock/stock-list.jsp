<%--
    File: stock-list.jsp
    Path: src/main/webapp/WEB-INF/views/staff/stock/stock-list.jsp
    Description: Stock list page for staff.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${requestScope.pageTitle != null ? requestScope.pageTitle : "Stock List"}</title>

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">

    <style>
        /*
         * ALL CSS CODE IS PASTED FROM admin-styles.css HERE
         * NOTE: body { display: flex; } will arrange direct child elements of <body>
         * (i.e., .sidebar and .main-content-wrapper) side by side.
         */
        body { margin: 0; font-family: Arial, sans-serif; display: flex; min-height: 100vh; }
        .sidebar { width: 250px; background-color: #222d32; color: #b8c7ce; padding-top: 20px; flex-shrink: 0; box-shadow: 2px 0 5px rgba(0,0,0,0.2); }
        .sidebar-header { color: white; padding: 10px 15px; text-align: center; font-size: 20px; font-weight: bold; border-bottom: 1px solid #4b646f; margin-bottom: 15px; }
        .sidebar-menu { list-style: none; padding: 0; margin: 0; }
        .sidebar-menu li a { display: block; padding: 12px 15px; color: #b8c7ce; text-decoration: none; }
        .sidebar-menu li a:hover, .sidebar-menu li.active > a { background-color: #1e282c; color: white; }
        .sidebar-menu .header { color: #4b646f; background-color: #1a2226; padding: 10px 15px; font-size: 12px; text-transform: uppercase; }
        .sidebar-menu .treeview-menu { list-style: none; padding-left: 20px; display: none; }
        .sidebar-menu .treeview.active.menu-open > .treeview-menu { display: block; }
        .sidebar-menu .pull-right-container { float: right; }

        .main-content-wrapper { flex-grow: 1; display: flex; flex-direction: column; }
        .content-header { background-color: #f8f8f8; padding: 15px 20px; border-bottom: 1px solid #eee; display: flex; justify-content: space-between; align-items: center; }
        .content-header h1 { margin: 0; font-size: 24px; color: #333; }
        .content-header ol.breadcrumb { padding: 0; margin: 0; background: none; list-style: none; }
        .content-header ol.breadcrumb li { display: inline-block; }
        .content-header ol.breadcrumb li + li::before { content: "/\00a0"; padding: 0 5px; color: #ccc; }
        .content-area { padding: 20px; background-color: #ecf0f5; flex-grow: 1; }
        .box { background: #fff; border-radius: 3px; border-top: 3px solid #d2d6de; margin-bottom: 20px; width: 100%; box-shadow: 0 1px 1px rgba(0,0,0,0.1); }
        .box-header { color: #444; display: block; padding: 10px; position: relative; border-bottom: 1px solid #f4f4f4; }
        .box-title { display: inline-block; font-size: 18px; margin: 0; line-height: 1; }
        .box-body { padding: 10px; }
        .box-tools { float: right; }
        .btn { display: inline-block; padding: 6px 12px; margin-bottom: 0; font-size: 14px; font-weight: 400; line-height: 1.42857143; text-align: center; white-space: nowrap; vertical-align: middle; cursor: pointer; border: 1px solid transparent; border-radius: 4px; }
        .btn-primary { color: #fff; background-color: #3c8dbc; border-color: #367fa9; }
        .btn-warning { color: #fff; background-color: #f39c12; border-color: #e08e0b; }
        .btn-danger { color: #fff; background-color: #dd4b39; border-color: #d73925; }
        .btn-xs { padding: 1px 5px; font-size: 12px; line-height: 1.5; border-radius: 3px; }
        .table { width: 100%; max-width: 100%; margin-bottom: 20px; border-collapse: collapse; border-spacing: 0; }
        .table th, .table td { padding: 8px; line-height: 1.42857143; vertical-align: top; border-top: 1px solid #ddd; text-align: left; }
        .table thead th { vertical-align: bottom; border-bottom: 2px solid #ddd; }
        .small-box {
            position: relative;
            display: block;
            border-radius: 2px;
            box-shadow: 0 1px 1px rgba(0,0,0,0.1);
            margin-bottom: 20px;
            color: white;
            padding: 15px;
        }
        .small-box .inner {
            padding: 10px;
        }
        .small-box h3 {
            font-size: 38px;
            font-weight: bold;
            margin: 0 0 10px 0;
            white-space: nowrap;
            padding: 0;
        }
        .small-box p {
            font-size: 15px;
        }
        .small-box .icon {
            position: absolute;
            top: auto;
            bottom: 5px;
            right: 5px;
            z-index: 0;
            font-size: 90px;
            color: rgba(0,0,0,0.15);
        }
        .small-box .small-box-footer {
            position: relative;
            text-align: center;
            padding: 3px 0;
            color: #fff;
            color: rgba(255,255,255,0.8);
            display: block;
            z-index: 10;
            background: rgba(0,0,0,0.1);
            text-decoration: none;
        }
        .small-box .small-box-footer:hover {
            color: #fff;
            background: rgba(0, 0, 0, 0.15);
        }
        /* Custom styles for stock levels */
        .no-stock {
            background-color: #fce4e4; /* Light red */
        }
        .low-stock {
            background-color: #fffacd; /* Lemon Chiffon */
        }
        .search-sort-form {
            margin-bottom: 20px;
            padding: 15px;
            background-color: #f9f9f9;
            border: 1px solid #ddd;
            border-radius: 4px;
            display: flex;
            gap: 10px;
            align-items: center;
            flex-wrap: wrap; /* Allow wrapping on smaller screens */
        }
        .search-sort-form label {
            margin-right: 5px;
        }
        .search-sort-form input[type="text"],
        .search-sort-form select {
            padding: 8px;
            border: 1px solid #ccc;
            border-radius: 4px;
            flex-grow: 1; /* Allow inputs/selects to grow */
            min-width: 150px; /* Minimum width for inputs/selects */
        }
        .search-sort-form button {
            padding: 8px 15px;
            background-color: #3c8dbc;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        .search-sort-form button:hover {
            background-color: #367fa9;
        }
    </style>
</head>
<body>

    <%-- Set necessary requestScope variables for sidebar/header --%>
    <c:set var="currentAction" value="stock-list" scope="request"/>
    <c:set var="currentModule" value="stock" scope="request"/>
    <c:set var="pageTitle" value="Stock List" scope="request"/>

    <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp" />

    <div class="main-content-wrapper">
        <jsp:include page="/WEB-INF/includes/admin-header.jsp" />

        <div class="content-area">
            <div class="row">
                <div class="col-xs-12">
<div class="box box-primary">
    <div class="box-header with-border">
        <h3 class="box-title">Inventory Details List</h3>
        <div class="box-tools">
            <a href="${pageContext.request.contextPath}/StockImport" class="btn btn-primary btn-sm">
                <i class="fa fa-plus"></i> New Stock Import
            </a>
        </div>
    </div>
    <div class="box-body">
        <c:if test="${not empty errorMessage}">
            <p style="color: red;">${errorMessage}</p>
        </c:if>

        <div class="search-sort-form">
            <form action="${pageContext.request.contextPath}/stock/list" method="get" style="display: flex; flex-wrap: wrap; gap: 10px; width: 100%;">
                <label for="searchTerm">Search:</label>
                <input type="text" id="searchTerm" name="searchTerm" placeholder="Product name, SKU, color, size" value="${requestScope.searchTerm != null ? requestScope.searchTerm : ''}">

                <label for="filterCategory">Category:</label>
                <select id="filterCategory" name="filterCategory">
                    <option value="">All Categories</option>
                    <c:forEach var="category" items="${requestScope.categories}">
                        <option value="${category.name}" ${requestScope.filterCategory == category.name ? 'selected' : ''}>${category.name}</option>
                    </c:forEach>
                </select>

                <label for="sortBy">Sort By:</label>
                <select id="sortBy" name="sortBy">
                    <option value="productName" ${requestScope.sortBy == 'productName' ? 'selected' : ''}>Product Name</option>
                    <option value="sku" ${requestScope.sortBy == 'sku' ? 'selected' : ''}>SKU</option>
                    <option value="quantity" ${requestScope.sortBy == 'quantity' ? 'selected' : ''}>Stock Quantity</option>
                    <option value="category" ${requestScope.sortBy == 'category' ? 'selected' : ''}>Category</option>
                    <option value="brand" ${requestScope.sortBy == 'brand' ? 'selected' : ''}>Brand</option>
                </select>

                <label for="sortOrder">Order:</label>
                <select id="sortOrder" name="sortOrder">
                    <option value="asc" ${requestScope.sortOrder == 'asc' || requestScope.sortOrder == null ? 'selected' : ''}>Ascending</option>
                    <option value="desc" ${requestScope.sortOrder == 'desc' ? 'selected' : ''}>Descending</option>
                </select>

                <button type="submit" class="btn btn-primary">Apply</button>
                <a href="${pageContext.request.contextPath}/stock/list" class="btn btn-warning">Reset</a>
            </form>
        </div>


        <c:if test="${empty inventoryList}">
            <p>No products in stock to display based on current filters.</p>
        </c:if>

        <c:if test="${not empty inventoryList}">
            <div class="table-container">
                <table class="table table-bordered table-striped">
                    <thead>
                        <tr>
                            <th>Product ID</th>
                            <th>Variant ID</th> <%-- Changed from Inventory ID for better clarity based on data --%>
                            <th>Product Name</th>
                            <th>SKU</th>
                            <th>Size</th>
                            <th>Color</th>
                            <th>Stock</th>
                            <th>Reserved</th>
                            <th>Available</th>
                            <th>Category</th>
                            <th>Brand</th>
                            <th>Last Updated</th> <%-- Add Last Updated column --%>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="item" items="${inventoryList}">
                            <tr <c:if test="${item.quantity <= 0}">class="no-stock"</c:if>
                                <c:if test="${item.quantity > 0 && item.quantity < 10}">class="low-stock"</c:if>>
                                <td>${item.product.productId}</td>
                                <td>${item.productVariant.variantId}</td>
                                <td>${item.product.name}</td>
                                <td>${item.productVariant.sku}</td>
                                <td>${item.productVariant.size}</td>
                                <td>${item.productVariant.color}</td>
                                <td>${item.quantity}</td>
                                <td>${item.reservedQuantity}</td>
                                <td>${item.availableQuantity}</td> <%-- Display available quantity --%>
                                <td>${item.product.category.name}</td>
                                <td>${item.product.brand.name}</td>
                                <td>${item.lastUpdated}</td> <%-- Display last updated time --%>
                                <td>
                                    <a href="${pageContext.request.contextPath}/stock/details?variantId=${item.productVariant.variantId}" class="btn btn-info btn-xs">
                                        <i class="fa fa-info-circle"></i> Details
                                    </a>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </c:if>
    </div>
</div>
                </div>
            </div>
        </div>
    </div>


    <script>
        /* ALL JAVASCRIPT CODE IS PASTED FROM admin-scripts.js HERE */
        document.addEventListener('DOMContentLoaded', function() {
            const treeviews = document.querySelectorAll('.sidebar-menu .treeview > a');
            treeviews.forEach(function(treeviewLink) {
                treeviewLink.addEventListener('click', function(e) {
                    const parentLi = this.parentElement;
                    if (parentLi.classList.contains('treeview')) {
                        e.preventDefault();
                        document.querySelectorAll('.sidebar-menu .treeview.menu-open').forEach(li => {
                            if (li !== parentLi) {
                                li.classList.remove('menu-open');
                                li.classList.remove('active');
                            }
                        });
                        parentLi.classList.toggle('menu-open');
                        parentLi.classList.toggle('active');
                    }
                });
            });
            const currentAction = "${requestScope.currentAction}";
            const currentModule = "${requestScope.currentModule}";

            document.querySelectorAll('.sidebar-menu li.active').forEach(li => li.classList.remove('active'));
            document.querySelectorAll('.sidebar-menu .treeview.menu-open').forEach(li => li.classList.remove('menu-open'));
            if (currentAction && currentModule) {
                const activeLink = document.querySelector(`.sidebar-menu a[href*="action=${currentAction}"][href*="module=${currentModule}"]`);
                if (activeLink) {
                    activeLink.parentElement.classList.add('active');
                    const parentTreeview = activeLink.closest('.treeview');
                    if (parentTreeview) {
                        parentTreeview.classList.add('active');
                        parentTreeview.classList.add('menu-open');
                    }
                }
            } else if (!currentAction || currentAction === 'home' || currentAction === 'dashboard') {
                const dashboardLink = document.querySelector('.sidebar-menu a[href*="action=dashboard"]');
                if (dashboardLink) {
                    dashboardLink.parentElement.classList.add('active');
                }
            }
        });
    </script>
</body>
</html>