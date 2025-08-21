<%--
    Document : products
    Created on : Aug 10, 2025, 1:00:00 AM
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
        <title>Product List</title>
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
    .table img {
        width: 80px;
        height: 80px;
        max-width: 80px;
        max-height: 80px;
        object-fit: cover;
        border-radius: 4px;
        border: 1px solid #ddd;
        display: block;
        margin: 0 auto;
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
        max-width: 100% !important; /* Đảm bảo container không giới hạn */
    }
    .search-bar {
        max-width: 500px !important; /* Thanh tìm kiếm dài 900px */
        width: 100%;
    }
    .search-bar .input-group {
        max-width: 900px !important; /* Input bên trong dài 900px */
        width: 100%;
    }
    .filter-select, .sort-select {
        max-width: 200px;
    }
    @media (max-width: 768px) {
        .content-area {
            margin-left: 0;
            width: 100%;
        }
        .sidebar.hidden ~ .content-area {
            margin-left: 0;
        }
        .table img {
            width: 50px;
            height: 50px;
            max-width: 50px;
            max-height: 50px;
            object-fit: cover;
        }
        .search-filter-container {
            flex-direction: column;
            align-items: stretch;
        }
        .search-bar, .filter-select, .sort-select {
            max-width: 100% !important; /* Chiếm toàn bộ chiều rộng trên mobile */
        }
    }
</style>
    </head>
    <body>
        <c:set var="currentAction" value="products" scope="request"/>
        <c:set var="currentModule" value="admin" scope="request"/>
        <c:set var="pageTitle" value="Product List" scope="request"/>
        <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp" />
        <div class="content-area">
            <h2 style="text-align: center;">Product List</h2>
            <div class="search-filter-container">
                <a href="${pageContext.request.contextPath}/ProductCreateAdmin" class="btn btn-success">
                    <i class="bi bi-plus-circle"></i> Create New Product
                </a>
                <form action="${pageContext.request.contextPath}/ProductListAdminFilter" method="get" class="search-bar">
                    <div class="input-group">
                        <input type="text" class="form-control" name="keyword" placeholder="Search products by name..."
                               value="${fn:escapeXml(param.keyword)}">
                        <button class="btn btn-primary" type="submit"><i class="bi bi-search"></i></button>
                    </div>
                </form>
                <a href="${pageContext.request.contextPath}/ProductListAdmin?action=list" class="btn btn-secondary">
                    <i class="bi bi-x-circle"></i> Clear
                </a>
                <form action="${pageContext.request.contextPath}/ProductListAdminFilter" method="get" class="filter-select">
                    <input type="hidden" name="keyword" value="${fn:escapeXml(param.keyword)}">
                    <input type="hidden" name="sort" value="${fn:escapeXml(param.sort)}">
                    <select class="form-select" name="filter" onchange="this.form.submit()">
                        <option value="All" ${param.filter == null || param.filter == 'All' ? 'selected' : ''}>All Products</option>
                        <option value="Active" ${param.filter == 'Active' ? 'selected' : ''}>Active</option>
                        <option value="Inactive" ${param.filter == 'Inactive' ? 'selected' : ''}>Inactive</option>
                        <option value="New" ${param.filter == 'New' ? 'selected' : ''}>New</option>
                    </select>
                </form>
                <form action="${pageContext.request.contextPath}/ProductListAdmin" method="get" class="sort-select">
                    <input type="hidden" name="action" value="list">
                    <input type="hidden" name="keyword" value="${fn:escapeXml(param.keyword)}">
                    <input type="hidden" name="filter" value="${fn:escapeXml(param.filter)}">
                    <select class="form-select" name="sort" onchange="this.form.submit()">
                        <option value="" ${param.sort == null || param.sort == '' ? 'selected' : ''}>Default Sort</option>
                        <option value="name_asc" ${param.sort == 'name_asc' ? 'selected' : ''}>Name A-Z</option>
                        <option value="name_desc" ${param.sort == 'name_desc' ? 'selected' : ''}>Name Z-A</option>
                        <option value="price_asc" ${param.sort == 'price_asc' ? 'selected' : ''}>Price Low to High</option>
                        <option value="price_desc" ${param.sort == 'price_desc' ? 'selected' : ''}>Price High to Low</option>
                    </select>
                </form>

            </div>
            <c:if test="${not empty message}">
                <div class="alert alert-warning"><c:out value="${message}"/></div>
            </c:if>
            <c:choose>
                <c:when test="${not empty products || not empty productList}">
                    <div>
                        <table class="table table-striped table-hover" id="productTable">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Product Name</th>
                                    <th>Price</th>
                                    <th>Status</th>
                                    <th>Category</th>
                                    <th>Brand</th>
                                    <th>Images</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="product" items="${not empty productList ? productList : products}">
                                    <tr>
                                        <td><c:out value="${product.productId}"/></td>
                                        <td><c:out value="${product.name}"/></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty product.price}">
                                                    <fmt:setLocale value="vi_VN"/>
                                                    <fmt:formatNumber value="${product.price}" type="currency"/>
                                                </c:when>
                                                <c:otherwise>N/A</c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <span class="${product.status == 'Active' ? 'status-active' : 'status-inactive'}">
                                                <c:out value="${product.status}"/>
                                            </span>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${product.category != null}">
                                                    <c:out value="${product.parentCategoryName != null ? product.parentCategoryName : ''}"/>
                                                    <c:if test="${product.parentCategoryName != null && product.category.name != null}"> / </c:if>
                                                    <c:out value="${product.category.name != null ? product.category.name : 'N/A'}"/>
                                                </c:when>
                                                <c:otherwise>
                                                    N/A
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td><c:out value="${product.brand != null ? product.brand.name : 'N/A'}"/></td>
                                        <td>
                                            <img src="${fn:escapeXml(product.imageUrl != null ? product.imageUrl : 'https://placehold.co/80x80?text=No+Image')}"
                                                 alt="${fn:escapeXml(product.name)}" class="product-image">
                                        </td>
                                        <td>
                                            <div class="d-flex gap-1 justify-content-center">
                                                <a href="${pageContext.request.contextPath}/ProductDetailsAdmin?productId=${product.productId}"
                                                   class="btn btn-warning"><i class="bi bi-tools"></i> Detail</a>
                                                <a href="${pageContext.request.contextPath}/ProductEditAdmin?productId=${product.productId}"
                                                   class="btn btn-primary"><i class="bi bi-tools"></i> Edit</a>
                                                <button class="btn btn-danger" onclick="confirmDelete(${product.productId})">Delete</button>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="alert alert-warning">No matching products found!</div>
                </c:otherwise>
            </c:choose>
        </div>
        <!-- Bootstrap JS -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
        <script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
        <script>
                                                    function confirmDelete(productId) {
                                                        Swal.fire({
                                                            title: 'Are you sure?',
                                                            text: "You won't be able to revert this!",
                                                            icon: 'warning',
                                                            showCancelButton: true,
                                                            confirmButtonColor: '#3085d6',
                                                            cancelButtonColor: '#d33',
                                                            confirmButtonText: 'Yes, delete it!'
                                                        }).then((result) => {
                                                            if (result.isConfirmed) {
                                                                fetch('${pageContext.request.contextPath}/ProductListAdmin?action=delete&id=' + productId, {
                                                                    method: 'GET'
                                                                }).then(response => {
                                                                    if (response.ok) {
                                                                        Swal.fire(
                                                                                'Deleted!',
                                                                                'Product has been deleted.',
                                                                                'success'
                                                                                ).then(() => {
                                                                            window.location.href = '${pageContext.request.contextPath}/ProductListAdmin?action=list';
                                                                        });
                                                                    } else {
                                                                        return response.text().then(text => {
                                                                            throw new Error('Failed to delete product: ' + text);
                                                                        });
                                                                    }
                                                                }).catch(error => {
                                                                    console.error('Error deleting product:', error);
                                                                    Swal.fire(
                                                                            'Error!',
                                                                            error.message,
                                                                            'error'
                                                                            );
                                                                });
                                                            }
                                                        });
                                                    }
        </script>
    </body>
</html>