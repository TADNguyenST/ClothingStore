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
    String msg = (String) session.getAttribute("msg");
    String err = (String) request.getAttribute("err");
    List<Category> allCategories = (List<Category>) request.getAttribute("categories");
    List<Category> parentCategories = new ArrayList<>();
    Integer totalProducts = (Integer) request.getAttribute("totalProducts");
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
    String selectedBrandId = request.getParameter("brandId");
    String sort = request.getParameter("sort") != null ? request.getParameter("sort").toLowerCase() : "created_at_desc";
    String pageParam = request.getParameter("page");
    int currentPage = (pageParam != null && !pageParam.isEmpty()) ? Integer.parseInt(pageParam) : 1;
    int pageSize = 5;
    int totalPages = (totalProducts != null && totalProducts > 0) ? (int) Math.ceil((double) totalProducts / pageSize) : 1;
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
.table {
    border-collapse: separate;
    border-spacing: 0;
    width: 100%;
    font-size: 0.9rem;
}
.table th, .table td {
    padding: 0.75rem;
    vertical-align: middle;
}
.table th {
    background-color: #f9fafb;
    font-weight: 600;
    color: #4a5568;
    text-transform: uppercase;
    font-size: 0.85rem;
}
.table th.sortable {
    cursor: pointer;
    position: relative;
    padding-right: 1.5rem;
}
.table th.sortable:hover {
    background-color: #e5e7eb;
}
.table th.sortable::after {
    content: '\f0dc';
    font-family: 'FontAwesome';
    position: absolute;
    right: 0.5rem;
    top: 50%;
    transform: translateY(-50%);
    color: #6b7280;
}
.table th.sort-asc::after {
    content: '\f0de';
}
.table th.sort-desc::after {
    content: '\f0dd';
}
.table tr:hover {
    background-color: #f1f5f9;
    transition: background-color 0.2s ease;
}
.table tbody tr td:nth-child(2),
.table tbody tr td:nth-child(3),
.table tbody tr td:nth-child(4),
.table tbody tr td:nth-child(5) {
    font-size: 1rem; /* [THAY ĐỔI] Tăng từ 0.9rem lên 1rem cho Name, Price, Brand, Category */
    padding: 0.85rem; /* [THAY ĐỔI] Tăng nhẹ padding từ 0.75rem để phù hợp phông chữ lớn hơn */
}
.product-image {
    width: 50px;
    height: 50px;
    object-fit: cover;
    border-radius: 6px;
    border: 1px solid #e5e7eb;
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
.btn-success {
    background-color: #10b981;
    border-color: #10b981;
}
.btn-success:hover {
    background-color: #059669;
    border-color: #059669;
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
.form-select, .form-control {
    border-radius: 6px;
    font-size: 0.85rem;
    border: 1px solid #d1d5db;
    padding: 0.4rem 0.75rem;
}
.form-control:focus, .form-select:focus {
    border-color: #3b82f6;
    box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}
.badge {
    padding: 0.4rem 0.8rem;
    font-size: 0.8rem;
    border-radius: 12px;
}
.filter-row {
    display: flex;
    flex-wrap: wrap;
    gap: 0.5rem;
    align-items: center;
}
.pagination {
    margin-top: 1rem;
    justify-content: center;
}
.page-item.active .page-link {
    background-color: #3b82f6;
    border-color: #3b82f6;
    color: #ffffff;
}
.page-link {
    border-radius: 6px;
    font-size: 0.85rem;
    margin: 0 0.25rem;
    color: #3b82f6;
    cursor: pointer;
}
.page-link:hover {
    background-color: #eff6ff;
    color: #2563eb;
}
@media (max-width: 768px) {
    .main-content-wrapper {
        padding: 1rem;
    }
    .box-body {
        padding: 1rem;
    }
    .table th, .table td {
        padding: 0.5rem;
    }
    .table tbody tr td:nth-child(2),
    .table tbody tr td:nth-child(3),
    .table tbody tr td:nth-child(4),
    .table tbody tr td:nth-child(5) {
        font-size: 0.95rem; /* [THAY ĐỔI] Tăng nhẹ trong chế độ responsive từ ngầm định (~0.9rem) lên 0.95rem */
        padding: 0.6rem; /* [THAY ĐỔI] Tăng nhẹ padding trong chế độ responsive */
    }
    .filter-row .col {
        flex: 1 1 100%;
    }
    .btn {
        padding: 0.3rem 0.6rem;
        font-size: 0.8rem;
    }
    .pagination {
        flex-wrap: wrap;
    }
    .page-link {
        margin: 0.2rem;
    }
}
    </style>
</head>
<body>
    <c:set var="currentAction" value="products" scope="request"/>
    <c:set var="currentModule" value="admin" scope="request"/>
    <c:set var="pageTitle" value="Products List" scope="request"/>
    <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp" />
    
    <div class="content-area">
        <div class="row">
            <div class="col-12">
                <div class="box box-primary">
                    <div class="box-header with-border">
                        <h3 class="box-title">Products List</h3>
                        <a href="${pageContext.request.contextPath}/ProductManager?action=create" class="btn btn-success btn-sm">
                            <i class="bi bi-plus-circle me-1"></i>Add Product
                        </a>
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
                        <form id="filterForm" action="${pageContext.request.contextPath}/ProductManager" method="post" class="mb-3">
                            <input type="hidden" name="action" value="filter">
                            <input type="hidden" name="page" id="pageInput" value="<%= currentPage %>">
                            <input type="hidden" name="sort" id="sortInput" value="<%= sort != null ? sort : "" %>">
                            <div class="filter-row">
                                <div class="col">
                                    <select name="parentCategoryId" id="parentCategoryId" class="form-select">
                                        <option value="">All Parent Categories</option>
                                        <% for (Category parentCategory : parentCategories) { %>
                                            <option value="<%= parentCategory.getCategoryId() %>" <%= selectedParentCategoryId != null && selectedParentCategoryId.equals(String.valueOf(parentCategory.getCategoryId())) ? "selected" : "" %>>
                                                <%= parentCategory.getName() %>
                                            </option>
                                        <% } %>
                                    </select>
                                </div>
                                <div class="col">
                                    <select name="categoryId" id="categoryId" class="form-select">
                                        <option value="">All Subcategories</option>
                                    </select>
                                </div>
                                <div class="col">
                                    <select name="brandId" class="form-select">
                                        <option value="">All Brands</option>
                                        <% 
                                            List<Brand> brands = (List<Brand>) request.getAttribute("brands");
                                            if (brands != null) {
                                                for (Brand brand : brands) {
                                                    String selected = selectedBrandId != null && selectedBrandId.equals(String.valueOf(brand.getBrandId())) ? "selected" : "";
                                        %>
                                        <option value="<%= brand.getBrandId() %>" <%= selected %>><%= brand.getName() %></option>
                                        <% } %>
                                    <% } %>
                                    </select>
                                </div>
                                <div class="col">
                                    <select name="status" class="form-select">
                                        <option value="">All Statuses</option>
                                        <option value="Active" <%= "Active".equals(selectedStatus) ? "selected" : "" %>>Active</option>
                                        <option value="Discontinued" <%= "Discontinued".equals(selectedStatus) ? "selected" : "" %>>Discontinued</option>
                                    </select>
                                </div>
                                <div class="col">
                                    <button type="submit" class="btn btn-primary w-100"><i class="bi bi-funnel me-1"></i>Filter</button>
                                </div>
                                <div class="col">
                                    <button type="button" class="btn btn-secondary w-100" onclick="clearFilter()"><i class="bi bi-arrow-repeat me-1"></i>Clear</button>
                                </div>
                            </div>
                        </form>
                        <% if (list != null && !list.isEmpty()) { %>
                            <div class="table-responsive">
                                <table class="table table-striped table-hover">
                                    <thead>
                                        <tr>
                                            <th style="width: 80px;">Image</th>
                                            <th class="sortable <%= "name_asc".equals(sort) ? "sort-asc" : "name_desc".equals(sort) ? "sort-desc" : "" %>">
                                                <a href="javascript:void(0)" onclick="sortTable('<%= sort %>', '<%= "name_asc".equals(sort) ? "name_desc" : "name_asc" %>', '<%= selectedParentCategoryId != null ? selectedParentCategoryId : "" %>', '<%= selectedCategoryId != null ? selectedCategoryId : "" %>', '<%= selectedBrandId != null ? selectedBrandId : "" %>', '<%= selectedStatus != null ? selectedStatus : "" %>')">Name</a>
                                            </th>
                                            <th style="width: 120px;" class="sortable <%= "price_asc".equals(sort) ? "sort-asc" : "price_desc".equals(sort) ? "sort-desc" : "" %>">
                                                <a href="javascript:void(0)" onclick="sortTable('<%= sort %>', '<%= "price_asc".equals(sort) ? "price_desc" : "price_asc" %>', '<%= selectedParentCategoryId != null ? selectedParentCategoryId : "" %>', '<%= selectedCategoryId != null ? selectedCategoryId : "" %>', '<%= selectedBrandId != null ? selectedBrandId : "" %>', '<%= selectedStatus != null ? selectedStatus : "" %>')">Price</a>
                                            </th>
                                            <th>Brand</th>
                                            <th>Category</th>
                                            <th style="width: 100px;">Status</th>
                                            <th style="width: 150px;">Actions</th>
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
                                            String imageUrl = (product.getImageUrl() != null) ? product.getImageUrl() : "https://placehold.co/50x50?text=No+Image";
                                            String brandName = (product.getBrand() != null && product.getBrand().getName() != null) ? product.getBrand().getName() : "N/A";
                                        %>
                                        <tr>
                                            <td><img src="<%= imageUrl %>" alt="<%= product.getName() %>" class="product-image"></td>
                                            <td><a href="${pageContext.request.contextPath}/ProductManager?action=detail&id=<%= product.getProductId() %>"><%= product.getName() %></a></td>
                                            <td><%= formatPrice(product.getPrice()) %>đ</td>
                                            <td><%= brandName %></td>
                                            <td><%= parentCategory != null ? parentCategory.getName() + " / " : "" %><%= product.getCategory() != null ? product.getCategory().getName() : "N/A" %></td>
                                            <td><span class="badge <%= statusClass %> text-white"><%= product.getStatus() %></span></td>
                                            <td>
                                                <a href="${pageContext.request.contextPath}/ProductManager?action=update&id=<%= product.getProductId() %>&page=<%= currentPage %>&sort=<%= sort != null ? sort : "" %>&parentCategoryId=<%= selectedParentCategoryId != null ? selectedParentCategoryId : "" %>&categoryId=<%= selectedCategoryId != null ? selectedCategoryId : "" %>&brandId=<%= selectedBrandId != null ? selectedBrandId : "" %>&status=<%= selectedStatus != null ? selectedStatus : "" %>" class="btn btn-primary btn-sm me-1" title="Edit Product">
                                                    <i class="bi bi-tools"></i>
                                                </a>
                                                <a href="${pageContext.request.contextPath}/ProductManager?action=delete&id=<%= product.getProductId() %>&page=<%= currentPage %>&sort=<%= sort != null ? sort : "" %>&parentCategoryId=<%= selectedParentCategoryId != null ? selectedParentCategoryId : "" %>&categoryId=<%= selectedCategoryId != null ? selectedCategoryId : "" %>&brandId=<%= selectedBrandId != null ? selectedBrandId : "" %>&status=<%= selectedStatus != null ? selectedStatus : "" %>" class="btn btn-danger btn-sm" title="Delete Product" onclick="return confirmDelete(<%= product.getProductId() %>, '<%= product.getName().replace("'", "\\'") %>')">
                                                    <i class="bi bi-trash"></i>
                                                </a>
                                            </td>
                                        </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>
                            <% if (totalPages > 1) { %>
                                <nav aria-label="Page navigation">
                                    <ul class="pagination">
                                        <li class="page-item <%= currentPage == 1 ? "disabled" : "" %>">
                                            <a class="page-link" href="javascript:void(0)" onclick="changePage(<%= currentPage - 1 %>)" aria-label="Previous">
                                                <span aria-hidden="true">«</span>
                                            </a>
                                        </li>
                                        <% for (int i = 1; i <= totalPages; i++) { %>
                                            <li class="page-item <%= currentPage == i ? "active" : "" %>">
                                                <a class="page-link" href="javascript:void(0)" onclick="changePage(<%= i %>)"><%= i %></a>
                                            </li>
                                        <% } %>
                                        <li class="page-item <%= currentPage == totalPages ? "disabled" : "" %>">
                                            <a class="page-link" href="javascript:void(0)" onclick="changePage(<%= currentPage + 1 %>)" aria-label="Next">
                                                <span aria-hidden="true">»</span>
                                            </a>
                                        </li>
                                    </ul>
                                </nav>
                            <% } %>
                        <% } else { %>
                            <p class="text-muted text-center">No products found.</p>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
    <script>
        console.log("Sort parameter: <%= sort != null ? sort : "none" %>");
        const allCategories = [
            <% if (allCategories != null) { %>
                <% for (Category cat : allCategories) { %>
                    <% if (cat.getParentCategoryId() != null) { %>
                        {
                            id: <%= cat.getCategoryId() %>,
                            name: "<%= cat.getName().replace("\"", "\\\"") %>",
                            parentId: <%= cat.getParentCategoryId() %>
                        },
                    <% } %>
                <% } %>
            <% } %>
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

        document.getElementById('parentCategoryId').addEventListener('change', function() {
            const parentId = this.value;
            const selectedCategoryId = "<%= selectedCategoryId != null ? selectedCategoryId : "" %>";
            populateChildCategories(parentId, selectedCategoryId);
        });

        document.addEventListener('DOMContentLoaded', function() {
            const parentId = "<%= selectedParentCategoryId != null ? selectedParentCategoryId : "" %>";
            const selectedCategoryId = "<%= selectedCategoryId != null ? selectedCategoryId : "" %>";
            populateChildCategories(parentId, selectedCategoryId);

            const successMessage = document.getElementById('successMessage');
            if (successMessage) {
                setTimeout(() => {
                    successMessage.classList.remove('show');
                    successMessage.classList.add('fade');
                    setTimeout(() => successMessage.remove(), 150);
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

        function changePage(page) {
            if (page < 1 || page > <%= totalPages %>) return;
            document.getElementById('pageInput').value = page;
            document.getElementById('filterForm').submit();
        }

        function sortTable(currentSort, newSort, parentCategoryId, categoryId, brandId, status) {
            document.getElementById('sortInput').value = newSort;
            document.getElementById('parentCategoryId').value = parentCategoryId;
            document.getElementById('categoryId').value = categoryId;
            document.querySelector('select[name="brandId"]').value = brandId;
            document.querySelector('select[name="status"]').value = status;
            document.getElementById('filterForm').submit();
        }

        function clearFilter() {
            const form = document.getElementById('filterForm');
            form.action = "${pageContext.request.contextPath}/ProductManager";
            form.querySelector('input[name="action"]').value = "list";
            form.querySelector('input[name="page"]').value = "1";
            form.querySelector('input[name="sort"]').value = "";
            form.querySelector('select[name="parentCategoryId"]').value = "";
            form.querySelector('select[name="categoryId"]').value = "";
            form.querySelector('select[name="brandId"]').value = "";
            form.querySelector('select[name="status"]').value = "";
            form.submit();
        }

        function confirmDelete(productId, productName) {
            if (isNaN(productId) || productId <= 0) {
                alert('Invalid product ID!');
                return false;
            }
            return confirm('Are you sure you want to delete the product "' + productName + '"?');
        }
    </script>
</body>
</html>
