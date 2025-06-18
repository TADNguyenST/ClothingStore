<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%-- 1. Set variables for this page, used by sidebar and header --%>
<c:set var="pageTitle" value="Inventory Management" scope="request"/>
<c:set var="currentModule" value="stock" scope="request"/>
<c:set var="currentAction" value="stock-list" scope="request"/>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>${pageTitle} - Admin Panel</title>

        <%-- 2. Link to common libraries and CSS files --%>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css"/>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/admin-dashboard/css/admin-css.css">
    </head>
    <body>

        <%-- 3. Include Sidebar --%>
        <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp"/>

        <%-- 4. Wrap all content in .main-content-wrapper --%>
        <div class="main-content-wrapper">

            <%-- Include Header --%>
            <jsp:include page="/WEB-INF/includes/admin-header.jsp"/>

            <%-- 5. Page-specific content is placed in .content-area --%>
            <main class="content-area">
                <div class="box">
                    <div class="box-header with-border">
                        <h3 class="box-title">Product List in Stock</h3>
                    </div>
                    <div class="box-body">

                        <%-- Display notification (if any) --%>
                        <c:if test="${param.update == 'success'}">
                            <div class="alert alert-success alert-dismissible fade show" role="alert">
                                <strong>Success!</strong> Inventory information has been updated.
                                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                            </div>
                        </c:if>

                        <form action="${pageContext.request.contextPath}/Stock" method="GET" class="row g-3 align-items-center mb-4">
                            <div class="col-md-5">
                                <input type="text" class="form-control" name="searchTerm" placeholder="Search by product name, SKU..." value="<c:out value='${searchTerm}'/>">
                            </div>
                            <div class="col-md-4">
                                <select class="form-select" name="filterCategory">
                                    <option value="${cat.categoryId}" ${filterCategory != 'all' && cat.categoryId == filterCategory ? 'selected' : ''}><c:out value="${cat.name}"/>--All Category--</option>
                                    <c:forEach var="cat" items="${categories}">
                                        <option value="${cat.categoryId}" ${cat.categoryId == filterCategory ? 'selected' : ''}><c:out value="${cat.name}"/></option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="col-md-3 d-flex">
                                <button type="submit" class="btn btn-primary w-100 me-2"><i class="fa-solid fa-search"></i> Filter / Search</button>
                                <a href="${pageContext.request.contextPath}/Stock" class="btn btn-secondary"><i class="fa-solid fa-eraser"></i></a>
                            </div>
                        </form>

                        <p><strong>Showing ${displayList.size()} results.</strong></p>

                        <div class="table-responsive">
                            <table class="table table-hover table-bordered table-sm">
                                <thead>
                                    <tr>
                                        <%-- Correct the URL paths --%>
                                        <th><a href="${pageContext.request.contextPath}/Stock?sortBy=sku&sortOrder=${sortBy == 'sku' && sortOrder == 'asc' ? 'desc' : 'asc'}&searchTerm=${searchTerm}&filterCategory=${filterCategory}">SKU <c:if test="${sortBy == 'sku'}"><i class="fa-solid ${sortOrder == 'asc' ? 'fa-sort-up' : 'fa-sort-down'} sort-icon"></i></c:if></a></th>
                                        <th><a href="${pageContext.request.contextPath}/Stock?sortBy=productName&sortOrder=${sortBy == 'productName' && sortOrder == 'asc' ? 'desc' : 'asc'}&searchTerm=${searchTerm}&filterCategory=${filterCategory}">Product Name <c:if test="${sortBy == 'productName'}"><i class="fa-solid ${sortOrder == 'asc' ? 'fa-sort-up' : 'fa-sort-down'} sort-icon"></i></c:if></a></th>
                                        <th><a href="${pageContext.request.contextPath}/Stock?sortBy=categoryName&sortOrder=${sortBy == 'categoryName' && sortOrder == 'asc' ? 'desc' : 'asc'}&searchTerm=${searchTerm}&filterCategory=${filterCategory}">Category <c:if test="${sortBy == 'categoryName'}"><i class="fa-solid ${sortOrder == 'asc' ? 'fa-sort-up' : 'fa-sort-down'} sort-icon"></i></c:if></a></th>
                                        <th>Size</th>
                                        <th>Color</th>
                                        <th><a href="${pageContext.request.contextPath}/Stock?sortBy=quantity&sortOrder=${sortBy == 'quantity' && sortOrder == 'asc' ? 'desc' : 'asc'}&searchTerm=${searchTerm}&filterCategory=${filterCategory}">In Stock <c:if test="${sortBy == 'quantity'}"><i class="fa-solid ${sortOrder == 'asc' ? 'fa-sort-up' : 'fa-sort-down'} sort-icon"></i></c:if></a></th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                <c:choose>
                                    <c:when test="${not empty displayList}">
                                        <c:forEach var="item" items="${displayList}">
                                            <tr>
                                                <td><c:out value="${item.sku}"/></td>
                                                <td><c:out value="${item.productName}"/></td>
                                                <td><c:out value="${item.categoryName}"/></td>
                                                <td><c:out value="${item.size}"/></td>
                                                <td><c:out value="${item.color}"/></td>
                                                <td><c:out value="${item.quantity}"/></td>
                                                <td>
                                                    <a href="${pageContext.request.contextPath}/EditStock?variantId=${item.variantId}" class="btn btn-warning btn-xs">
                                                        <i class="fa fa-pencil"></i> Edit
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/StockDetail?variantId=${item.variantId}" class="btn btn-info btn-xs ms-1">
                                                        <i class="fa-solid fa-eye"></i> Details
                                                    </a>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr><td colspan="8" class="text-center p-4">No products found.</td></tr>
                                    </c:otherwise>
                                </c:choose>
                                </tbody>
                            </table>
                            <c:if test="${totalPages > 1}">
                                <nav aria-label="Page navigation" class="mt-4">
                                    <ul class="pagination justify-content-center">
                                        <%-- Previous page button --%>
                                        <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                                            <a class="page-link" href="${pageContext.request.contextPath}/Stock?page=${currentPage - 1}&searchTerm=${searchTerm}&filterCategory=${filterCategory}&sortBy=${sortBy}&sortOrder=${sortOrder}">Previous</a>
                                        </li>

                                        <%-- Page number buttons --%>
                                        <c:forEach begin="1" end="${totalPages}" var="i">
                                            <li class="page-item ${currentPage == i ? 'active' : ''}">
                                                <a class="page-link" href="${pageContext.request.contextPath}/Stock?page=${i}&searchTerm=${searchTerm}&filterCategory=${filterCategory}&sortBy=${sortBy}&sortOrder=${sortOrder}">${i}</a>
                                            </li>
                                        </c:forEach>

                                        <%-- Next page button --%>
                                        <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                            <a class="page-link" href="${pageContext.request.contextPath}/Stock?page=${currentPage + 1}&searchTerm=${searchTerm}&filterCategory=${filterCategory}&sortBy=${sortBy}&sortOrder=${sortOrder}">Next</a>
                                        </li>
                                    </ul>
                                </nav>
                            </c:if>
                        </div>
                    </div>
                </div>
            </main>
        </div>
        
        <%-- Paste this code at the end of the box-body in stock-statistics.jsp --%>
        <%-- 6. Link to common JS file --%>
        <script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>

        <%-- JS part to activate the menu, needs JSP variables so it will be here --%>
        <script>
            document.addEventListener('DOMContentLoaded', function () {
                const currentAction = "${requestScope.currentAction}";
                const currentModule = "${requestScope.currentModule}";

                document.querySelectorAll('.sidebar-menu li.active').forEach(li => li.classList.remove('active'));
                document.querySelectorAll('.sidebar-menu .treeview.menu-open').forEach(li => li.classList.remove('menu-open'));

                if (currentAction && currentModule) {
                    // Find the link with both action and module
                    const activeLink = document.querySelector(`.sidebar-menu a[href*="${currentAction}"][href*="${currentModule}"]`);
                    if (activeLink) {
                        activeLink.parentElement.classList.add('active');
                        const parentTreeview = activeLink.closest('.treeview');
                        if (parentTreeview) {
                            parentTreeview.classList.add('active');
                            parentTreeview.classList.add('menu-open');
                        }
                    }
                } else if (!currentAction || currentAction === 'home' || currentAction === 'dashboard') {
                    // Default active dashboard link
                    const dashboardLink = document.querySelector('.sidebar-menu a[href*="dashboard"]'); // Modify to find the dashboard link more simply
                    if (dashboardLink && !dashboardLink.closest('.treeview')) { // Only activate if it's not inside a treeview
                        dashboardLink.parentElement.classList.add('active');
                    }
                }
            });
        </script>
    </body>
</html>