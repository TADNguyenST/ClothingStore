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
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" xintegrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

    <%-- Link to common CSS --%>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/admin-dashboard/css/admin-css.css">

    <%-- Custom styles --%>
    <style>
        body { background-color: #f4f6f9; }
        .content-area { padding: 20px; }
        .card-view {
            background-color: #fff;
            border: none;
            border-radius: 0.5rem;
            box-shadow: 0 0 1px rgba(0,0,0,.125), 0 1px 3px rgba(0,0,0,.2);
            padding: 1.5rem;
        }
        .card-view .box-title { font-size: 1.25rem; font-weight: 500; margin-bottom: 1.5rem; }
        .table { border-collapse: separate; border-spacing: 0; border: 1px solid #dee2e6; border-radius: 0.375rem; overflow: hidden; }
        .table thead th { background-color: #f8f9fa; border-bottom: 2px solid #dee2e6; font-weight: 600; color: #495057; }
        .table td, .table th { vertical-align: middle; }
        .table-hover tbody tr:hover { background-color: rgba(0,0,0,0.05); }
        .action-btn { width: 36px; height: 36px; display: inline-flex; align-items: center; justify-content: center; border-radius: 0.375rem; }
        .btn-edit { background-color: #17a2b8; border-color: #17a2b8; color: #fff; }
        .btn-edit:hover { background-color: #138496; border-color: #117a8b; }
        .btn-delete { background-color: #dc3545; border-color: #dc3545; color: #fff; }
        .btn-delete:hover { background-color: #c82333; border-color: #bd2130; }
        .category-link { text-decoration: none; color: inherit; font-weight: 500; }
        .category-link:hover { color: #007bff; }
        .parent-category strong { font-weight: 600; }
        .child-category, .orphan-category { padding-left: 2.5rem !important; }
    </style>
</head>
<body>
    <c:set var="currentAction" value="categories" scope="request"/>
    <c:set var="currentModule" value="admin" scope="request"/>
    <c:set var="pageTitle" value="Category List" scope="request"/>

    <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp" />

    <div class="main-content-wrapper">
        <jsp:include page="/WEB-INF/includes/admin-header.jsp" />

        <div class="content-area">
            <div class="card-view">
                <h3 class="box-title">Category List</h3>

                <c:if test="${not empty msg}"><div class="alert alert-success">${msg}</div></c:if>
                <c:if test="${not empty err}"><div class="alert alert-danger">${err}</div></c:if>

                <form action="${pageContext.request.contextPath}/CategoryManager" method="get" class="mb-4">
                    <input type="hidden" name="action" value="search">
                    <div class="row">
                        <div class="col-md-4 mb-3">
                            <label for="name" class="form-label">Category Name</label>
                            <input type="text" id="name" name="name" class="form-control" placeholder="Enter category name" value="${param.name}">
                        </div>
                        <div class="col-md-4 mb-3">
                            <label for="parentCategoryId" class="form-label">Parent Category</label>
                            <select id="parentCategoryId" name="parentCategoryId" class="form-select">
                                <option value="">All</option>
                                <c:forEach var="category" items="${categories}">
                                    <c:if test="${empty category.parentCategoryId}">
                                        <option value="${category.categoryId}" ${param.parentCategoryId == category.categoryId ? 'selected' : ''}>${category.name}</option>
                                    </c:if>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-md-4 mb-3">
                            <label for="isActive" class="form-label">Status</label>
                            <select id="isActive" name="isActive" class="form-select">
                                <option value="">All</option>
                                <option value="true" ${param.isActive == 'true' ? 'selected' : ''}>Active</option>
                                <option value="false" ${param.isActive == 'false' ? 'selected' : ''}>Discontinued</option>
                            </select>
                        </div>
                    </div>
                    <div class="mt-3">
                        <button type="submit" class="btn btn-primary"><i class="bi bi-search"></i> Search</button>
                        <a href="${pageContext.request.contextPath}/CategoryManager?action=list" class="btn btn-secondary"><i class="bi bi-arrow-refresh"></i> Reset</a>
                    </div>
                </form>

                <div class="mb-3 text-end">
                    <a class="btn btn-success" href="${pageContext.request.contextPath}/CategoryManager?action=create"><i class="bi bi-plus-circle"></i> Create New Category</a>
                </div>

                <%-- LOGIC FIX: Determine which display mode to use --%>
                <c:set var="isSearch" value="${not empty param.action and param.action eq 'search'}" />
                <c:set var="isAllFilterSearch" value="${isSearch and empty param.name and empty param.parentCategoryId and empty param.isActive}" />
                <c:set var="isFilteredSearch" value="${isSearch and not isAllFilterSearch}" />

                <table class="table table-hover align-middle">
                    <thead>
                        <tr>
                            <th style="width: 10%;">ID</th>
                            <th>Category Name</th>
                            <th style="width: 15%;">Status</th>
                            <th style="width: 15%; text-align: center;">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <%-- CASE 1: Displaying a specific, FILTERED search result --%>
                            <c:when test="${isFilteredSearch and not empty searchResults}">
                                <c:set var="listToDisplay" value="${searchResults}" />
                                <%-- Render parents and their children from the filtered list --%>
                                <c:forEach var="parent" items="${listToDisplay}">
                                    <c:if test="${empty parent.parentCategoryId}">
                                        <tr>
                                            <td>${parent.categoryId}</td>
                                            <td><a href="${pageContext.request.contextPath}/CategoryManager?action=detail&id=${parent.categoryId}" class="category-link"><strong><i class="bi bi-folder-fill text-warning me-2"></i>${parent.name}</strong></a></td>
                                            <td><span class="badge ${parent.active ? 'bg-success' : 'bg-danger'}">${parent.active ? 'Active' : 'Discontinued'}</span></td>
                                            <td class="text-center">
                                                <a href="${pageContext.request.contextPath}/CategoryManager?action=edit&id=${parent.categoryId}" class="btn btn-sm btn-edit me-1 action-btn" title="Edit"><i class="bi bi-pencil-square"></i></a>
                                                <a href="${pageContext.request.contextPath}/CategoryManager?action=delete&id=${parent.categoryId}" class="btn btn-sm btn-delete action-btn" title="Delete" onclick="return confirm('Are you sure you want to delete \'${parent.name}\'?')"><i class="bi bi-trash"></i></a>
                                            </td>
                                        </tr>
                                        <c:forEach var="child" items="${listToDisplay}"><c:if test="${child.parentCategoryId == parent.categoryId}">
                                            <tr>
                                                <td>${child.categoryId}</td>
                                                <td class="child-category"><a href="${pageContext.request.contextPath}/CategoryManager?action=detail&id=${child.categoryId}" class="category-link"><i class="bi bi-tag-fill text-secondary me-2"></i>${child.name}</a></td>
                                                <td><span class="badge ${child.active ? 'bg-success' : 'bg-danger'}">${child.active ? 'Active' : 'Discontinued'}</span></td>
                                                <td class="text-center">
                                                    <a href="${pageContext.request.contextPath}/CategoryManager?action=edit&id=${child.categoryId}" class="btn btn-sm btn-edit me-1 action-btn" title="Edit"><i class="bi bi-pencil-square"></i></a>
                                                    <a href="${pageContext.request.contextPath}/CategoryManager?action=delete&id=${child.categoryId}" class="btn btn-sm btn-delete action-btn" title="Delete" onclick="return confirm('Are you sure you want to delete \'${child.name}\'?')"><i class="bi bi-trash"></i></a>
                                                </td>
                                            </tr>
                                        </c:if></c:forEach>
                                    </c:if>
                                </c:forEach>
                                <%-- Render "orphan" children (whose parents are not in the filtered list) --%>
                                <c:forEach var="orphan" items="${listToDisplay}"><c:if test="${not empty orphan.parentCategoryId}">
                                    <c:set var="parentInList" value="${false}" /><c:forEach var="p" items="${listToDisplay}"><c:if test="${p.categoryId == orphan.parentCategoryId}"><c:set var="parentInList" value="${true}" /></c:if></c:forEach>
                                    <c:if test="${not parentInList}">
                                        <tr>
                                            <td>${orphan.categoryId}</td>
                                            <td class="orphan-category"><a href="${pageContext.request.contextPath}/CategoryManager?action=detail&id=${orphan.categoryId}" class="category-link"><i class="bi bi-tag-fill text-secondary me-2"></i>${orphan.name}</a></td>
                                            <td><span class="badge ${orphan.active ? 'bg-success' : 'bg-danger'}">${orphan.active ? 'Active' : 'Discontinued'}</span></td>
                                            <td class="text-center">
                                                <a href="${pageContext.request.contextPath}/CategoryManager?action=edit&id=${orphan.categoryId}" class="btn btn-sm btn-edit me-1 action-btn" title="Edit"><i class="bi bi-pencil-square"></i></a>
                                                <a href="${pageContext.request.contextPath}/CategoryManager?action=delete&id=${orphan.categoryId}" class="btn btn-sm btn-delete action-btn" title="Delete" onclick="return confirm('Are you sure you want to delete \'${orphan.name}\'?')"><i class="bi bi-trash"></i></a>
                                            </td>
                                        </tr>
                                    </c:if>
                                </c:if></c:forEach>
                            </c:when>

                            <%-- CASE 2: Displaying the FULL LIST (default view or "All/All" search) --%>
                            <c:when test="${not empty categories}">
                                <c:forEach var="parent" items="${categories}">
                                    <c:if test="${empty parent.parentCategoryId}">
                                        <tr>
                                            <td>${parent.categoryId}</td>
                                            <td><a href="${pageContext.request.contextPath}/CategoryManager?action=detail&id=${parent.categoryId}" class="category-link"><strong><i class="bi bi-folder-fill text-warning me-2"></i>${parent.name}</strong></a></td>
                                            <td><span class="badge ${parent.active ? 'bg-success' : 'bg-danger'}">${parent.active ? 'Active' : 'Discontinued'}</span></td>
                                            <td class="text-center">
                                                <a href="${pageContext.request.contextPath}/CategoryManager?action=edit&id=${parent.categoryId}" class="btn btn-sm btn-edit me-1 action-btn" title="Edit"><i class="bi bi-pencil-square"></i></a>
                                                <a href="${pageContext.request.contextPath}/CategoryManager?action=delete&id=${parent.categoryId}" class="btn btn-sm btn-delete action-btn" title="Delete" onclick="return confirm('Are you sure you want to delete \'${parent.name}\'?')"><i class="bi bi-trash"></i></a>
                                            </td>
                                        </tr>
                                        <c:forEach var="child" items="${categories}"><c:if test="${child.parentCategoryId == parent.categoryId}">
                                            <tr>
                                                <td>${child.categoryId}</td>
                                                <td class="child-category"><a href="${pageContext.request.contextPath}/CategoryManager?action=detail&id=${child.categoryId}" class="category-link"><i class="bi bi-tag-fill text-secondary me-2"></i>${child.name}</a></td>
                                                <td><span class="badge ${child.active ? 'bg-success' : 'bg-danger'}">${child.active ? 'Active' : 'Discontinued'}</span></td>
                                                <td class="text-center">
                                                    <a href="${pageContext.request.contextPath}/CategoryManager?action=edit&id=${child.categoryId}" class="btn btn-sm btn-edit me-1 action-btn" title="Edit"><i class="bi bi-pencil-square"></i></a>
                                                    <a href="${pageContext.request.contextPath}/CategoryManager?action=delete&id=${child.categoryId}" class="btn btn-sm btn-delete action-btn" title="Delete" onclick="return confirm('Are you sure you want to delete \'${child.name}\'?')"><i class="bi bi-trash"></i></a>
                                                </td>
                                            </tr>
                                        </c:if></c:forEach>
                                    </c:if>
                                </c:forEach>
                            </c:when>
                            
                            <%-- CASE 3: No results found --%>
                            <c:otherwise>
                                <tr>
                                    <td colspan="4" class="text-muted text-center mt-4 p-4">
                                        <c:choose>
                                            <c:when test="${isFilteredSearch}">No matching categories found!</c:when>
                                            <c:otherwise>No categories found!</c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" xintegrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
    <script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>
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
                        parentTreeview.classList.add('active', 'menu-open');
                    }
                }
            }
        });
    </script>
</body>
</html>
