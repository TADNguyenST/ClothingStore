<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Category Details</title>

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
    <c:set var="pageTitle" value="Category Details" scope="request"/>

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
                            <h3 class="box-title">Category Details</h3>
                        </div>
                        <div class="box-body">
                            <%-- Error Message --%>
                            <c:if test="${not empty err}">
                                <p class="text-danger">${err}</p>
                            </c:if>

                            <%-- Category Details --%>
                            <c:choose>
                                <c:when test="${not empty category}">
                                    <table class="table table-bordered">
                                        <tbody>
                                            <tr>
                                                <th>ID</th>
                                                <td>${category.categoryId}</td>
                                            </tr>
                                            <tr>
                                                <th>Name</th>
                                                <td>${category.name}</td>
                                            </tr>
                                            <tr>
                                                <th>Description</th>
                                                <td>${not empty category.description ? category.description : 'N/A'}</td>
                                            </tr>
                                            <tr>
                                                <th>Parent Category</th>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${not empty category.parentCategoryId}">
                                                            <c:forEach var="cat" items="${categories}">
                                                                <c:if test="${cat.categoryId == category.parentCategoryId}">
                                                                    ${cat.name}
                                                                </c:if>
                                                            </c:forEach>
                                                        </c:when>
                                                        <c:otherwise>None</c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                            <tr>
                                                <th>Status</th>
                                                <td>
                                                    <span class="badge ${category.active ? 'bg-success' : 'bg-danger'}">
                                                        ${category.active ? 'Active' : 'Inactive'}
                                                    </span>
                                                </td>
                                            </tr>
                                            <tr>
                                                <th>Created At</th>
                                                <td>${category.createdAt}</td>
                                            </tr>
                                        </tbody>
                                    </table>
                                    <div class="mt-3">
                                        <a href="${pageContext.request.contextPath}/CategoryManager?action=list" 
                                           class="btn btn-secondary">
                                            <i class="bi bi-arrow-left"></i> Back to Categories
                                        </a>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <p class="text-muted">No category found!</p>
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