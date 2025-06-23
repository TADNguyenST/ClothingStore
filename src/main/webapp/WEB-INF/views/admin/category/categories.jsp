<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Category List</title>

    <%-- Link to external libraries --%>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

    <%-- Link to common CSS --%>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/admin-dashboard/css/admin-css.css">
</head>
<body>
    <%-- Set necessary requestScope variables for sidebar/header --%>
    <c:set var="currentAction" value="categories" scope="request"/>
    <c:set var="currentModule" value="admin" scope="request"/>
    <c:set var="pageTitle" value="Category List" scope="request"/>

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
                            <h3 class="box-title">Category List</h3>
                        </div>
                        <div class="box-body">
                            <%-- Messages --%>
                            <c:if test="${not empty msg}">
                                <p class="text-success">${msg}</p>
                            </c:if>
                            <c:if test="${not empty err}">
                                <p class="text-danger">${err}</p>
                            </c:if>

                            <%-- Search Form --%>
                            <form action="${pageContext.request.contextPath}/CategoryManager" method="get" class="mb-4">
                                <input type="hidden" name="action" value="search">
                                <div class="row">
                                    <div class="col-md-4 mb-3">
                                        <label for="name" class="form-label">Category Name</label>
                                        <input type="text" id="name" name="name" class="form-control" 
                                               placeholder="Enter category name" value="${param.name}">
                                    </div>
                                    <div class="col-md-4 mb-3">
                                        <label for="parentCategoryId" class="form-label">Parent Category</label>
                                        <select id="parentCategoryId" name="parentCategoryId" class="form-select">
                                            <option value="">All</option>
                                            <c:forEach var="category" items="${categories}">
                                                <c:if test="${empty category.parentCategoryId}">
                                                    <option value="${category.categoryId}" 
                                                            ${param.parentCategoryId == category.categoryId ? 'selected' : ''}>
                                                        ${category.name}
                                                    </option>
                                                </c:if>
                                            </c:forEach>
                                        </select>
                                    </div>
                                    <div class="col-md-4 mb-3">
                                        <label for="isActive" class="form-label">Status</label>
                                        <select id="isActive" name="isActive" class="form-select">
                                            <option value="">All</option>
                                            <option value="true" ${param.isActive == 'true' ? 'selected' : ''}>Active</option>
                                            <option value="false" ${param.isActive == 'false' ? 'selected' : ''}>Inactive</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="mt-3">
                                    <button type="submit" class="btn btn-primary">
                                        <i class="bi bi-search"></i> Search
                                    </button>
                                    <a href="${pageContext.request.contextPath}/CategoryManager?action=list" 
                                       class="btn btn-secondary">
                                        <i class="bi bi-arrow-refresh"></i> Reset
                                    </a>
                                </div>
                            </form>

                            <%-- Create Button --%>
                            <div class="mb-3 text-end">
                                <a class="btn btn-success" href="${pageContext.request.contextPath}/CategoryManager?action=create">
                                    <i class="bi bi-plus-circle"></i> Create New Category
                                </a>
                            </div>

                            <%-- Category Table --%>
                            <c:choose>
                                <c:when test="${not empty searchResults || not empty categories}">
                                    <table class="table table-striped table-hover">
                                        <thead>
                                            <tr>
                                                <th>ID</th>
                                                <th>Name</th>
                                                <th>Parent Category</th>
                                                <th>Status</th>
                                                <th>Actions</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="category" items="${not empty searchResults ? searchResults : categories}">
                                                <tr>
                                                    <td>${category.categoryId}</td>
                                                    <td>
                                                        <a href="${pageContext.request.contextPath}/CategoryManager?action=detail&id=${category.categoryId}">
                                                            ${category.name}
                                                        </a>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${not empty category.parentCategoryId}">
                                                                <c:forEach var="parent" items="${categories}">
                                                                    <c:if test="${parent.categoryId == category.parentCategoryId}">
                                                                        ${parent.name}
                                                                    </c:if>
                                                                </c:forEach>
                                                            </c:when>
                                                            <c:otherwise>None</c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <span class="badge ${category.active ? 'bg-success' : 'bg-danger'}">
                                                            ${category.active ? 'Active' : 'Discontinued'}
                                                        </span>
                                                    </td>
                                                    <td>
                                                        <a href="${pageContext.request.contextPath}/CategoryManager?action=edit&id=${category.categoryId}" 
                                                           class="btn btn-primary btn-sm me-1">
                                                            <i class="bi bi-pencil"></i> Edit
                                                        </a>
                                                        <a href="${pageContext.request.contextPath}/CategoryManager?action=delete&id=${category.categoryId}" 
                                                           class="btn btn-danger btn-sm" 
                                                           onclick="return confirm('Are you sure you want to delete ${category.name}?')">
                                                            <i class="bi bi-trash"></i> Delete
                                                        </a>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </c:when>
                                <c:otherwise>
                                    <p class="text-muted">No categories found!</p>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%-- Link to common JS --%>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
    <script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>

    <%-- JS for active menu --%>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const currentAction = "${requestScope.currentAction}";
            const currentModule = "${requestScope.currentModule}";

            // Remove existing active classes
            document.querySelectorAll('.sidebar-menu li.active').forEach(li => li.classList.remove('active'));
            document.querySelectorAll('.sidebar-menu .treeview.menu-open').forEach(li => li.classList.remove('menu-open'));

            // Add active class to current menu item
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