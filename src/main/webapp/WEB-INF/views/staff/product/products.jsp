<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@page import="java.math.BigDecimal"%>
<%@page import="model.Product"%>
<%@page import="dao.ProductDAO"%>
<%@page import="dao.CategoryDAO"%>
<%@page import="model.Users"%>
<%@page import="model.Category"%>
<%@page import="model.Brand"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="java.text.DecimalFormatSymbols"%>
<%
    List<Product> list = (List<Product>) request.getAttribute("list");
    String msg = (String) request.getAttribute("msg");
    String err = (String) request.getAttribute("err");
    CategoryDAO cateDAO = new CategoryDAO();
    // Get all categories
    List<Category> allCategories = cateDAO.getAllCategories();
    List<Category> parentCategories = new ArrayList<>();
    if (allCategories != null) {
        for (Category cat : allCategories) {
            if (cat.getParentCategoryId() == null) {
                parentCategories.add(cat);
            }
        }
    }
    // Get selected filter values from request parameters
    String selectedParentCategoryId = request.getParameter("parentCategoryId");
    String selectedCategoryId = request.getParameter("categoryId");
    String selectedStatus = request.getParameter("status"); // Thêm tham số trạng thái
%>
<%!
    // Method to format price with thousand separators and two decimal places in Vietnamese format
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
        <c:set var="pageTitle" value="Products List" scope="request"/>

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
                                <h3 class="box-title">Products List</h3>
                            </div>
                            <div class="box-body">
                                <%-- Filter Form --%>
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
                                                <option value="">All Child Categories</option>
                                                <%-- Child categories will be populated dynamically by JavaScript --%>
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
                                            <input type="text" name="minPrice" class="form-control" placeholder="Min Price" value="<%= request.getParameter("minPrice") != null ? request.getParameter("minPrice") : ""%>">
                                        </div>
                                        <div class="col-md-2">
                                            <input type="text" name="maxPrice" class="form-control" placeholder="Max Price" value="<%= request.getParameter("maxPrice") != null ? request.getParameter("maxPrice") : ""%>">
                                        </div>
                                        <div class="col-md-2">
                                            <select name="status" class="form-select">
                                                <option value="">All Status</option>
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

                                <%-- Create Button --%>
                                <div class="mb-2 text-end">
                                    <a class="btn btn-success" href="${pageContext.request.contextPath}/ProductManager?action=create"><i class="bi bi-file-earmark-plus"></i> Create</a>
                                </div>

                                <%-- Messages --%>
                                <% if (msg != null && !msg.isEmpty()) {%>
                                <p class="text-success"><%= msg%></p>
                                <% } %>
                                <% if (err != null && !err.isEmpty()) {%>
                                <p class="text-danger"><%= err%></p>
                                <% } %>

                                <%-- Product Table --%>
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
                                            <th>Action</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% for (Product product : list) {
                                                Category parentCategory = null;
                                                if (product.getCategory() != null && product.getCategory().getParentCategoryId() != null) {
                                                    parentCategory = cateDAO.getCategoryById(product.getCategory().getParentCategoryId());
                                                }
                                                // Determine status class
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
                                                <a href="${pageContext.request.contextPath}/ProductManager?action=delete&id=<%= product.getProductId()%>" class="btn btn-danger btn-sm"
                                                   onclick="return confirm('Are you sure you want to delete <%= product.getName()%>?')"><i class="bi bi-trash"></i> Delete</a>
                                            </td>
                                        </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                                <% } else { %>
                                <p>No Data!</p>
                                <% }%>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <%-- Link to common JS --%>
        <script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>

        <%-- JavaScript for filtering child categories --%>
        <script>
            // Store all categories in a JavaScript array
            const allCategories = [
                <%
                    if (allCategories != null) {
                        for (Category cat : allCategories) {
                            if (cat.getParentCategoryId() != null) { // Only include child categories
                %>
                {
                    id: <%= cat.getCategoryId()%>,
                    name: "<%= cat.getName()%>",
                    parentId: <%= cat.getParentCategoryId()%>
                },
                <%
                            }
                        }
                    }
                %>
            ];

            // Function to populate child category dropdown
            function populateChildCategories(parentId, selectedCategoryId) {
                const categorySelect = document.getElementById('categoryId');
                // Clear existing options
                categorySelect.innerHTML = '<option value="">All Child Categories</option>';

                // Filter child categories based on parentId
                const childCategories = allCategories.filter(cat => cat.parentId == parentId);

                // Add new options
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

            // Event listener for parent category change
            document.getElementById('parentCategoryId').addEventListener('change', function () {
                const parentId = this.value;
                const selectedCategoryId = "<%= selectedCategoryId != null ? selectedCategoryId : ""%>";
                populateChildCategories(parentId, selectedCategoryId);
            });

            // Initialize child categories on page load
            document.addEventListener('DOMContentLoaded', function () {
                const parentId = "<%= selectedParentCategoryId != null ? selectedParentCategoryId : ""%>";
                const selectedCategoryId = "<%= selectedCategoryId != null ? selectedCategoryId : ""%>";
                populateChildCategories(parentId, selectedCategoryId);

                // Active menu logic
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