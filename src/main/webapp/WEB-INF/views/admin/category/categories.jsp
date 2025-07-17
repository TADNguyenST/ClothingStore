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
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" crossorigin="anonymous">
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

                <c:if test="${not empty msg}">
                    <div class="alert alert-success alert-dismissible fade show" role="alert" id="successMessage">
                        ${msg}
                    </div>
                </c:if>
                <c:if test="${not empty err}">
                    <div class="alert alert-danger" role="alert">
                        ${err}
                    </div>
                </c:if>

                <div class="mb-3 text-end">
                    <a class="btn btn-success" href="${pageContext.request.contextPath}/CategoryManager?action=create"><i class="bi bi-plus-circle"></i> Create New Category</a>
                </div>

                <table class="table table-hover align-middle">
                    <thead>
                        <tr>
                            <th>Category Name</th>
                            <th style="width: 15%;">Status</th>
                            <th style="width: 15%; text-align: center;">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <%-- Displaying the FULL LIST --%>
                            <c:when test="${not empty categories}">
                                <c:forEach var="parent" items="${categories}">
                                    <c:if test="${empty parent.parentCategoryId}">
                                        <tr>
                                            <td><a href="${pageContext.request.contextPath}/CategoryManager?action=detail&id=${parent.categoryId}" class="category-link"><strong><i class="bi bi-folder-fill text-warning me-2"></i>${parent.name}</strong></a></td>
                                            <td><span class="badge ${parent.active ? 'bg-success' : 'bg-danger'}">${parent.active ? 'Active' : 'Discontinued'}</span></td>
                                            <td class="text-center">
                                                <a href="${pageContext.request.contextPath}/CategoryManager?action=edit&id=${parent.categoryId}" class="btn btn-sm btn-edit me-1 action-btn" title="Edit"><i class="bi bi-pencil-square"></i></a>
                                                <a href="${pageContext.request.contextPath}/CategoryManager?action=delete&id=${parent.categoryId}" class="btn btn-sm btn-delete action-btn" title="Delete" onclick="return confirm('Are you sure you want to delete \'${parent.name}\'?')"><i class="bi bi-trash"></i></a>
                                            </td>
                                        </tr>
                                        <c:forEach var="child" items="${categories}"><c:if test="${child.parentCategoryId == parent.categoryId}">
                                            <tr>
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
                            <%-- No results found --%>
                            <c:otherwise>
                                <tr>
                                    <td colspan="3" class="text-muted text-center mt-4 p-4">No categories found!</td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
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

            // Tự động ẩn thông báo thành công sau 3 giây
            const successMessage = document.getElementById('successMessage');
            if (successMessage) {
                setTimeout(() => {
                    successMessage.classList.remove('show');
                    successMessage.classList.add('fade');
                    setTimeout(() => {
                        successMessage.remove();
                    }, 150); // Đợi hiệu ứng fade hoàn tất
                }, 3000); // Ẩn sau 3 giây
            }
        });
    </script>
</body>
</html>