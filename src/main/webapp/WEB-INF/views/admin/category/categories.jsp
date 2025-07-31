<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Category List</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" crossorigin="anonymous">
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
    padding: 1rem;
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
    padding: 0.75rem 1rem;
    border-radius: 8px 8px 0 0;
    display: flex;
    justify-content: space-between;
    align-items: center;
}
.box-title {
    margin: 0;
    font-size: 1.1rem;
    font-weight: 600;
}
.box-body {
    padding: 1rem;
}
.table {
    border-collapse: separate;
    border-spacing: 0;
    font-size: 0.85rem;
}
.table th, .table td {
    padding: 0.5rem;
    vertical-align: middle;
}
.table th {
    background-color: #f9fafb;
    font-weight: 600;
    color: #4a5568;
    text-transform: uppercase;
    font-size: 0.8rem;
}
.table tr:hover {
    background-color: #f1f5f9;
    transition: background-color 0.2s ease;
}
.table tbody tr td:nth-child(1),
.table tbody tr td:nth-child(2) {
    font-size: 0.95rem; /* [THAY ĐỔI] Tăng từ 0.85rem lên 0.95rem cho Name và Parent Category */
    padding: 0.6rem; /* [THAY ĐỔI] Tăng nhẹ padding từ 0.5rem để phù hợp phông chữ lớn hơn */
}
.category-link {
    text-decoration: none;
    color: #2d3748;
    font-weight: 500;
}
.category-link:hover {
    color: #3b82f6;
}
.parent-category {
    font-weight: 600;
}
.child-category {
    padding-left: 1.5rem !important;
}
.badge {
    padding: 0.3rem 0.6rem;
    font-size: 0.75rem;
    border-radius: 10px;
}
.btn {
    border-radius: 6px;
    padding: 0.3rem 0.6rem;
    font-size: 0.8rem;
    transition: all 0.2s ease;
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
.btn-primary {
    background-color: #3b82f6;
    border-color: #3b82f6;
}
.btn-primary:hover {
    background-color: #2563eb;
    border-color: #2563eb;
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
.alert {
    border-radius: 6px;
    margin-bottom: 0.75rem;
    font-size: 0.85rem;
}
@media (max-width: 768px) {
    .main-content-wrapper {
        padding: 0.75rem;
    }
    .box-body {
        padding: 0.75rem;
    }
    .table th, .table td {
        padding: 0.4rem;
        font-size: 0.75rem;
    }
    .table tbody tr td:nth-child(1),
    .table tbody tr td:nth-child(2) {
        font-size: 0.85rem; /* [THAY ĐỔI] Tăng nhẹ trong chế độ responsive từ 0.75rem lên 0.85rem */
        padding: 0.5rem; /* [THAY ĐỔI] Tăng nhẹ padding trong chế độ responsive */
    }
    .child-category {
        padding-left: 1rem !important;
    }
    .btn {
        padding: 0.25rem 0.5rem;
        font-size: 0.75rem;
    }
    .badge {
        font-size: 0.7rem;
    }
}
    </style>
</head>
<body>
    <c:set var="currentAction" value="categories" scope="request"/>
    <c:set var="currentModule" value="admin" scope="request"/>
    <c:set var="pageTitle" value="Category List" scope="request"/>
    <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp" />
    
        <div class="content-area">
            <div class="row">
                <div class="col-12">
                    <div class="box box-primary">
                        <div class="box-header with-border">
                            <h3 class="box-title">Category List</h3>
                            <a class="btn btn-success btn-sm" href="${pageContext.request.contextPath}/CategoryManager?action=create">
                                <i class="bi bi-plus-circle me-1"></i>Create New Category
                            </a>
                        </div>
                        <div class="box-body">
                            <c:if test="${not empty msg}">
                                <div class="alert alert-success alert-dismissible fade show" role="alert" id="successMessage">
                                    ${msg}
                                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                                    <%-- Remove msg from session after displaying --%>
                                    <% session.removeAttribute("msg"); %>
                                </div>
                            </c:if>
                            <c:if test="${not empty err}">
                                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                    ${err}
                                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                                </div>
                            </c:if>
                            <table class="table table-hover align-middle">
                                <thead>
                                    <tr>
                                        <th>Name</th>
                                        <th style="width: 20%;">Parent Category</th>
                                        <th style="width: 15%;">Status</th>
                                        <th style="width: 15%; text-align: center;">Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${not empty categories}">
                                            <c:forEach var="parent" items="${categories}">
                                                <c:if test="${empty parent.parentCategoryId}">
                                                    <tr class="parent-category">
                                                        <td>
                                                            <a href="${pageContext.request.contextPath}/CategoryManager?action=detail&id=${parent.categoryId}" class="category-link">
                                                                <i class="bi bi-folder-fill text-warning me-2"></i>${parent.name}
                                                            </a>
                                                        </td>
                                                        <td>None</td>
                                                        <td>
                                                            <span class="badge ${parent.active ? 'bg-success' : 'bg-danger'} text-white">
                                                                ${parent.active ? 'Active' : 'Discontinued'}
                                                            </span>
                                                        </td>
                                                        <td class="text-center">
                                                            <a href="${pageContext.request.contextPath}/CategoryManager?action=edit&id=${parent.categoryId}" class="btn btn-primary btn-sm me-1" title="Edit">
                                                                <i class="bi bi-pencil-square"></i>
                                                            </a>
                                                            <a href="${pageContext.request.contextPath}/CategoryManager?action=delete&id=${parent.categoryId}" class="btn btn-danger btn-sm" title="Delete" onclick="return confirm('Are you sure you want to delete \'${parent.name}\'?')">
                                                                <i class="bi bi-trash"></i>
                                                            </a>
                                                        </td>
                                                    </tr>
                                                    <c:forEach var="child" items="${categories}">
                                                        <c:if test="${child.parentCategoryId == parent.categoryId}">
                                                            <tr class="child-category">
                                                                <td>
                                                                    <a href="${pageContext.request.contextPath}/CategoryManager?action=detail&id=${child.categoryId}" class="category-link">
                                                                        <i class="bi bi-tag-fill text-secondary me-2"></i>${child.name}
                                                                    </a>
                                                                </td>
                                                                <td>${parent.name}</td>
                                                                <td>
                                                                    <span class="badge ${child.active ? 'bg-success' : 'bg-danger'} text-white">
                                                                        ${child.active ? 'Active' : 'Discontinued'}
                                                                    </span>
                                                                </td>
                                                                <td class="text-center">
                                                                    <a href="${pageContext.request.contextPath}/CategoryManager?action=edit&id=${child.categoryId}" class="btn btn-primary btn-sm me-1" title="Edit">
                                                                        <i class="bi bi-pencil-square"></i>
                                                                    </a>
                                                                    <a href="${pageContext.request.contextPath}/CategoryManager?action=delete&id=${child.categoryId}" class="btn btn-danger btn-sm" title="Delete" onclick="return confirm('Are you sure you want to delete \'${child.name}\'?')">
                                                                        <i class="bi bi-trash"></i>
                                                                    </a>
                                                                </td>
                                                            </tr>
                                                        </c:if>
                                                    </c:forEach>
                                                </c:if>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <tr>
                                                <td colspan="4" class="text-muted text-center py-4">No categories found!</td>
                                            </tr>
                                        </c:otherwise>
                                    </c:choose>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" crossorigin="anonymous"></script>
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

            const successMessage = document.getElementById('successMessage');
            if (successMessage) {
                setTimeout(() => {
                    successMessage.classList.remove('show');
                    successMessage.classList.add('fade');
                    setTimeout(() => successMessage.remove(), 150);
                }, 3000);
            }
        });
    </script>
</body>
</html>