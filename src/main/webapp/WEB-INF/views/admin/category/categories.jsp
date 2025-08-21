<%--
    Document : categories
    Created on : Aug 11, 2025, 9:07 PM
    Author : Thinh
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Category List</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <!-- BoxIcons -->
    <link href='https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css' rel='stylesheet'>
    <!-- Custom CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/admin-dashboard/css/admin-css.css">
    <style>
        body {
            background-color: #f8f9fa;
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            color: #2d3748;
            margin: 0;
            overflow-x: hidden;
        }
        .content-area {
            position: relative;
            margin-left: 260px;
            padding: 1.5rem;
            width: calc(100% - 260px);
            transition: all 0.5s ease;
            min-height: 100vh;
        }
        .sidebar.close ~ .content-area {
            margin-left: 88px;
            width: calc(100% - 88px);
        }
        .sidebar.hidden ~ .content-area {
            margin-left: 0;
            width: 100%;
        }
        .table {
            width: 100%;
            border-collapse: collapse;
        }
        .table th, .table td {
            text-align: center;
            vertical-align: middle;
            padding: 0.75rem;
            border: 1px solid #dee2e6;
        }
        .table th {
            background-color: #f9fafb;
            font-weight: 600;
            text-transform: uppercase;
            font-size: 0.8rem;
        }
        .alert {
            border-radius: 6px;
            margin-bottom: 1rem;
            font-size: 0.9rem;
        }
        .btn {
            border-radius: 6px;
            padding: 0.4rem 0.8rem;
            font-size: 0.85rem;
        }
        .status-active {
            background-color: #28a745;
            color: white;
            padding: 0.2rem 0.5rem;
            border-radius: 4px;
        }
        .status-inactive {
            background-color: #dc3545;
            color: white;
            padding: 0.2rem 0.5rem;
            border-radius: 4px;
        }
        .search-filter-container {
            display: flex;
            gap: 1rem;
            margin-bottom: 1.5rem;
            align-items: center;
            flex-wrap: wrap;
        }
        .search-bar, .filter-select {
            max-width: 200px;
        }
        .child-category {
            padding-left: 2rem;
            font-style: italic;
        }
        @media (max-width: 768px) {
            .content-area {
                margin-left: 0;
                width: 100%;
            }
            .sidebar.hidden ~ .content-area {
                margin-left: 0;
            }
            .search-filter-container {
                flex-direction: column;
                align-items: stretch;
            }
            .search-bar, .filter-select {
                max-width: 100%;
            }
        }
    </style>
</head>
<body>
    <c:set var="currentAction" value="categories" scope="request"/>
    <c:set var="currentModule" value="admin" scope="request"/>
    <c:set var="pageTitle" value="Category List" scope="request"/>
    <jsp:include page="/WEB-INF/includes/sidebar.jsp" />
    <div class="content-area">
        <h2 style="text-align: center;">Category List</h2>
        <div class="search-filter-container">
            <a href="${pageContext.request.contextPath}/CategoryCreateAdmin" class="btn btn-success">
                <i class="bi bi-plus-circle"></i> Create New Category
            </a>
            <form action="${pageContext.request.contextPath}/CategoryListAdminFilter" method="get" class="search-bar">
                <div class="input-group">
                    <input type="text" class="form-control" name="keyword" placeholder="Search categories by name..."
                           value="${fn:escapeXml(param.keyword)}">
                    <button class="btn btn-primary" type="submit"><i class="bi bi-search"></i></button>
                </div>
            </form>
            <form action="${pageContext.request.contextPath}/CategoryListAdminFilter" method="get" class="filter-select">
                <input type="hidden" name="keyword" value="${fn:escapeXml(param.keyword)}">
                <select class="form-select" name="filter" onchange="this.form.submit()">
                    <option value="All" ${param.filter == null || param.filter == 'All' ? 'selected' : ''}>All Status</option>
                    <option value="Active" ${param.filter == 'Active' ? 'selected' : ''}>Active</option>
                    <option value="Inactive" ${param.filter == 'Inactive' ? 'selected' : ''}>Inactive</option>
                </select>
            </form>
            <a href="${pageContext.request.contextPath}/CategoryListAdmin?action=list" class="btn btn-secondary">
                <i class="bi bi-x-circle"></i> Clear
            </a>
        </div>
        <!-- Debug information -->
        
        <c:if test="${not empty msg}">
            <div class="alert alert-success">${msg}</div>
            <c:remove var="msg" scope="session" />
        </c:if>
        <c:if test="${not empty err}">
            <div class="alert alert-danger">${err}</div>
        </c:if>
        <c:choose>
            <c:when test="${not empty categories}">
                <table class="table table-striped table-hover" id="categoryTable">
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
                        <c:forEach var="category" items="${categories}" varStatus="loop">
                            <tr class="${category.parentCategoryId != null ? 'child-category' : ''}">
                                <td><c:out value="${category.categoryId}" default="N/A" /></td>
                                <td class="category-name"><c:out value="${category.name}" default="N/A" /></td>
                                <td><c:out value="${category.parentCategoryName != null ? category.parentCategoryName : 'None'}" /></td>
                                <td class="status-cell">
                                    <span class="${category.isActive ? 'status-active' : 'status-inactive'}">
                                        <c:out value="${category.isActive ? 'Active' : 'Inactive'}" />
                                    </span>
                                </td>
                                <td>
                                    <div class="d-flex gap-1 justify-content-center">
                                        <a href="${pageContext.request.contextPath}/CategoryEditAdmin?id=${category.categoryId}" class="btn btn-primary">
                                            <i class="bi bi-pencil"></i> Edit
                                        </a>
                                        <a href="${pageContext.request.contextPath}/CategoryDetailAdmin?id=${category.categoryId}" class="btn btn-info">
                                            <i class="bi bi-eye"></i> Detail
                                        </a>
                                        <button class="btn btn-danger" data-category-id="${category.categoryId}" onclick="confirmDelete(this)">
                                            <i class="bi bi-trash"></i> Delete
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:when>
            <c:otherwise>
                <div class="alert alert-warning">No categories found! Please add some categories.</div>
            </c:otherwise>
        </c:choose>
    </div>
    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
    <script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script>
function confirmDelete(button) {
    const categoryId = button.getAttribute('data-category-id');
    const row = button.closest('tr');
    const nameCell = row.querySelector('.category-name');
    let categoryName = nameCell ? nameCell.textContent.trim() : 'N/A';
    categoryName = categoryName && categoryName !== 'N/A' && categoryName.trim() !== '' ? categoryName : 'this category';
    
    Swal.fire({
        title: 'Are you sure?',
        text: `You are about to delete "${categoryName}". This action cannot be undone!`,
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Yes, delete it!'
    }).then((result) => {
        if (result.isConfirmed) {
            fetch('${pageContext.request.contextPath}/CategoryDeleteAdmin?id=' + categoryId, {
                method: 'GET'
            })
            .then(response => {
                if (!response.ok) {
                    return response.json().then(data => { throw new Error(data.message || 'Failed to delete category'); });
                }
                return response.json();
            })
            .then(data => {
                if (data.success) {
                    Swal.fire(
                        'Deleted!',
                        `Category "${categoryName}" has been deleted.`,
                        'success'
                    ).then(() => {
                        window.location.href = '${pageContext.request.contextPath}/CategoryListAdmin';
                    });
                } else {
                    throw new Error(data.message || 'Failed to delete category');
                }
            })
            .catch(error => {
                console.error('Error deleting category:', error);
                Swal.fire(
                    'Error!',
                    error.message.includes('non-zero inventory') ? 
                        'Cannot delete category: It is used by products with non-zero inventory.' :
                        error.message.includes('has subcategories') ?
                        'Cannot delete category: It has subcategories.' :
                        'Failed to delete category: ' + error.message,
                    'error'
                );
            });
        }
    });
}
</script>
</body>
</html>