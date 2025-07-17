<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@page import="java.math.BigDecimal"%>
<%@page import="model.Product"%>
<%@page import="model.Category"%>
<%@page import="model.Brand"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="java.text.DecimalFormatSymbols"%>
<%
    List<Product> list = (List<Product>) request.getAttribute("list");
    String msg = (String) session.getAttribute("msg"); // Retrieve success message from session
    String err = (String) request.getAttribute("err");
    List<Category> allCategories = (List<Category>) request.getAttribute("categories");
    List<Category> parentCategories = new ArrayList<>();
    if (allCategories != null) {
        for (Category cat : allCategories) {
            if (cat.getParentCategoryId() == null) {
                parentCategories.add(cat);
            }
        }
    }
    String selectedParentCategoryId = request.getParameter("parentCategoryId");
    String selectedCategoryId = request.getParameter("categoryId");
    String selectedStatus = request.getParameter("status");
    // Remove msg from session after retrieval
    if (msg != null && !msg.isEmpty()) {
        session.removeAttribute("msg");
    }
%>
<%!
    private String formatPrice(BigDecimal price) {
        if (price == null) {
            return "N/A";
        }
        DecimalFormatSymbols symbols = new DecimalFormatSymbols();
        symbols.setDecimalSeparator(',');
        symbols.setGroupingSeparator('.');
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
        <title>Products List</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/admin-dashboard/css/admin-css.css">
        <!-- Disable browser caching -->
        <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
        <meta http-equiv="Pragma" content="no-cache">
        <meta http-equiv="Expires" content="0">
    </head>
    <body>
        <c:set var="currentAction" value="products" scope="request"/>
        <c:set var="currentModule" value="admin" scope="request"/>
        <c:set var="pageTitle" value="Products List" scope="request"/>
        <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp" />
        <div class="main-content-wrapper">
            <jsp:include page="/WEB-INF/includes/admin-header.jsp" />
            <div class="content-area">
                <div class="row">
                    <div class="col-xs-12">
                        <div class="box box-primary">
                            <div class="box-header with-border">
                                <h3 class="box-title">Products List</h3>
                            </div>
                            <div class="box-body">
                                <% if (msg != null && !msg.isEmpty()) { %>
                                <div class="alert alert-success alert-dismissible fade show" role="alert" id="successMessage">
                                    <%= msg %>
                                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                                </div>
                                <% } %>
                                <% if (err != null && !err.isEmpty()) { %>
                                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                    <%= err %>
                                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                                </div>
                                <% } %>
                                <form action="${pageContext.request.contextPath}/ProductManager" method="get" class="mb-3">
                                    <input type="hidden" name="action" value="filter">
                                    <div class="row g-3">
                                        <div class="col-md-2">
                                            <select name="parentCategoryId" id="parentCategoryId" class="form-select">
                                                <option value="">All Parent Categories</option>
                                                <%
                                                    if (parentCategories != null) {
                                                        for (Category parentCategory : parentCategories) {
                                                            String selected = selectedParentCategoryId != null && selectedParentCategoryId.equals(String.valueOf(parentCategory.getCategoryId())) ? "selected" : "";
                                                %>
                                                <option value="<%= parentCategory.getCategoryId()%>" <%= selected%>><%= parentCategory.getName()%></option>
                                                <%
                                                        }
                                                    }
                                                %>
                                            </select>
                                        </div>
                                        <div class="col-md-2">
                                            <select name="categoryId" id="categoryId" class="form-select">
                                                <option value="">All Subcategories</option>
                                            </select>
                                        </div>
                                        <div class="col-md-2">
                                            <select name="brandId" class="form-select">
                                                <option value="">All Brands</option>
                                                <%
                                                    List<Brand> brands = (List<Brand>) request.getAttribute("brands");
                                                    String selectedBrandId = request.getParameter("brandId");
                                                    if (brands != null) {
                                                        for (Brand brand : brands) {
                                                            String selected = selectedBrandId != null && selectedBrandId.equals(String.valueOf(brand.getBrandId())) ? "selected" : "";
                                                %>
                                                <option value="<%= brand.getBrandId()%>" <%= selected%>><%= brand.getName()%></option>
                                                <%
                                                        }
                                                    }
                                                %>
                                            </select>
                                        </div>
                                        <div class="col-md-2">
                                            <input type="text" name="minPrice" class="form-control" placeholder="Minimum Price" value="<%= request.getParameter("minPrice") != null ? request.getParameter("minPrice") : ""%>">
                                        </div>
                                        <div class="col-md-2">
                                            <input type="text" name="maxPrice" class="form-control" placeholder="Maximum Price" value="<%= request.getParameter("maxPrice") != null ? request.getParameter("maxPrice") : ""%>">
                                        </div>
                                        <div class="col-md-2">
                                            <select name="status" class="form-select">
                                                <option value="">All Statuses</option>
                                                <option value="Active" <%= "Active".equals(selectedStatus) ? "selected" : ""%>>Active</option>
                                                <option value="Discontinued" <%= "Discontinued".equals(selectedStatus) ? "selected" : ""%>>Discontinued</option>
                                            </select>
                                        </div>
                                        <div class="col-md-1">
                                            <button type="submit" class="btn btn-primary"><i class="bi bi-funnel"></i> Filter</button>
                                        </div>
                                        <div class="col-md-1">
                                            <a href="${pageContext.request.contextPath}/ProductManager?action=list" class="btn btn-secondary"><i class="bi bi-arrow-repeat"></i> Clear</a>
                                        </div>
                                    </div>
                                </form>
                                <div class="mb-2 text-end">
                                    <a class="btn btn-success" href="${pageContext.request.contextPath}/ProductManager?action=create"><i class="bi bi-file-earmark-plus"></i> Create New</a>
                                </div>
                                <% if (list != null && !list.isEmpty()) { %>
                                <table class="table table-striped table-hover">
                                    <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>Name</th>
                                            <th>Price</th>
                                            <th>Parent Category</th>
                                            <th>Category</th>
                                            <th>Brand</th>
                                            <th>Material</th>
                                            <th>Status</th>
                                            <th>Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% for (Product product : list) {
                                                Category parentCategory = null;
                                                if (product.getCategory() != null && product.getCategory().getParentCategoryId() != null) {
                                                    for (Category cat : allCategories) {
                                                        if (cat.getCategoryId() == product.getCategory().getParentCategoryId()) {
                                                            parentCategory = cat;
                                                            break;
                                                        }
                                                    }
                                                }
                                                String statusClass = product.getStatus() != null && product.getStatus().equalsIgnoreCase("Active") ? "bg-success" : "bg-danger";
                                        %>
                                        <tr>
                                            <td><%= product.getProductId()%></td>
                                            <td><a href="${pageContext.request.contextPath}/ProductManager?action=detail&id=<%= product.getProductId()%>"><%= product.getName()%></a></td>
                                            <td><%= formatPrice(product.getPrice())%>đ</td>
                                            <td><%= parentCategory != null ? parentCategory.getName() : "None"%></td>
                                            <td><%= product.getCategory() != null ? product.getCategory().getName() : "N/A"%></td>
                                            <td><%= product.getBrand() != null ? product.getBrand().getName() : "N/A"%></td>
                                            <td><%= product.getMaterial() != null ? product.getMaterial() : "N/A"%></td>
                                            <td><span class="badge <%= statusClass%> text-white"><%= product.getStatus()%></span></td>
                                            <td>
                                                <a href="${pageContext.request.contextPath}/ProductManager?action=update&id=<%= product.getProductId()%>" class="btn btn-primary btn-sm"><i class="bi bi-tools"></i> Edit</a>
                                                <a href="${pageContext.request.contextPath}/ProductManager?action=delete&id=<%= product.getProductId()%>" class="btn btn-danger btn-sm" onclick="return confirmDelete(<%= product.getProductId()%>, '<%= product.getName().replace("'", "\\'")%>')"><i class="bi bi-trash"></i> Delete</a>
                                            </td>
                                        </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                                <% } else { %>
                                <p>No Data Available!</p>
                                <% }%>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
        <script>
            const allCategories = [
                <%
                    if (allCategories != null) {
                        for (Category cat : allCategories) {
                            if (cat.getParentCategoryId() != null) {
                %>
                {
                    id: <%= cat.getCategoryId()%>,
                    name: "<%= cat.getName().replace("\"", "\\\"")%>",
                    parentId: <%= cat.getParentCategoryId()%>
                },
                <%
                            }
                        }
                    }
                %>
            ];

            function populateChildCategories(parentId, selectedCategoryId) {
                const categorySelect = document.getElementById('categoryId');
                categorySelect.innerHTML = '<option value="">All Subcategories</option>';
                const childCategories = allCategories.filter(cat => cat.parentId == parentId);
                childCategories.forEach(cat => {
                    const option = document.createElement('option');
                    option.value = cat.id;
                    option.textContent = cat.name;
                    if (cat.id == selectedCategoryId) {
                        option.selected = true;
                    }
                    categorySelect.appendChild(option);
                });
            }

            document.getElementById('parentCategoryId').addEventListener('change', function () {
                const parentId = this.value;
                const selectedCategoryId = "<%= selectedCategoryId != null ? selectedCategoryId : ""%>";
                populateChildCategories(parentId, selectedCategoryId);
            });

            document.addEventListener('DOMContentLoaded', function () {
                const parentId = "<%= selectedParentCategoryId != null ? selectedParentCategoryId : ""%>";
                const selectedCategoryId = "<%= selectedCategoryId != null ? selectedCategoryId : ""%>";
                populateChildCategories(parentId, selectedCategoryId);
                const successMessage = document.getElementById('successMessage');
                if (successMessage) {
                    setTimeout(() => {
                        successMessage.classList.remove('show');
                        successMessage.classList.add('fade');
                        setTimeout(() => {
                            successMessage.remove();
                        }, 150);
                    }, 3000);
                }
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

            function confirmDelete(productId, productName) {
                if (isNaN(productId) || productId <= 0) {
                    alert('Invalid product ID!');
                    return false;
                }
                return confirm('Are you sure you want to delete the product ' + productName + '?');
            }
        </script>
    </body>
</html>