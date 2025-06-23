<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Brand" %>
<%
    List<Brand> brands = (List<Brand>) request.getAttribute("brands");
    String msg = (String) request.getAttribute("msg");
    String err = (String) request.getAttribute("err");
    System.out.println("brands.jsp: Brands = " + (brands != null ? brands.size() : "null"));
    System.out.println("brands.jsp: Msg = " + msg + ", Err = " + err);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Brand List</title>
    
    <%-- Link to external libraries --%>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    
    <%-- Link to common CSS --%>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/admin-dashboard/css/admin-css.css">
</head>
<body>
    <%-- Set necessary requestScope variables for sidebar/header --%>
    <c:set var="currentAction" value="brandList" scope="request"/>
    <c:set var="currentModule" value="brand" scope="request"/>
    <c:set var="pageTitle" value="Brand List" scope="request"/>

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
                            <h3 class="box-title">Brand List</h3>
                        </div>
                        <div class="box-body">
                            <%-- Create Button --%>
                            <div class="mb-2 text-end">
                                <a class="btn btn-success" href="${pageContext.request.contextPath}/BrandManager?action=create"><i class="bi bi-plus-circle"></i> Create</a>
                            </div>

                            <%-- Search Form --%>
                            <form action="${pageContext.request.contextPath}/BrandManager" method="get" class="mb-3">
                                <input type="hidden" name="action" value="search">
                                <div class="input-group">
                                    <input type="text" name="search" class="form-control" placeholder="Search by name" value="<%= request.getParameter("search") != null ? request.getParameter("search") : "" %>">
                                    <button type="submit" class="btn btn-primary"><i class="bi bi-search"></i> Search</button>
                                </div>
                            </form>

                            <%-- Filter Form --%>
                            <form action="${pageContext.request.contextPath}/BrandManager" method="get" class="mb-3">
                                <input type="hidden" name="action" value="filter">
                                <div class="input-group">
                                    <select name="status" class="form-select">
                                        <option value="">All</option>
                                        <option value="active" <%= "active".equals(request.getParameter("status")) ? "selected" : "" %>>Active</option>
                                        <option value="inactive" <%= "inactive".equals(request.getParameter("status")) ? "selected" : "" %>>Inactive</option>
                                    </select>
                                    <button type="submit" class="btn btn-primary"><i class="bi bi-funnel"></i> Filter</button>
                                    <a href="${pageContext.request.contextPath}/BrandManager?action=list" class="btn btn-secondary ms-2"><i class="bi bi-arrow-repeat"></i> Clear Filters</a>
                                </div>
                            </form>

                            <%-- Messages --%>
                            <c:if test="${not empty msg}">
                                <p class="text-success">${msg}</p>
                            </c:if>
                            <c:if test="${not empty err}">
                                <p class='text-danger'>${err}</p>
                            </c:if>

                            <%-- Brand Table --%>
                            <c:choose>
                                <c:when test="${not empty brands}">
                                    <table class="table table-striped table-hover">
                                        <thead>
                                            <tr>
                                                <th>ID</th>
                                                <th>Name</th>
                                                <th>Description</th>
                                                <th>Logo</th>
                                                <th>Status</th>
                                                <th>Actions</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="brand" items="${brands}">
                                                <tr>
                                                    <td>${brand.brandId}</td>
                                                    <td>
                                                        <a href="${pageContext.request.contextPath}/BrandManager?action=detail&id=${brand.brandId}">
                                                            ${brand.name}
                                                        </a>
                                                    </td>
                                                    <td>${not empty brand.description ? brand.description : 'N/A'}</td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${not empty brand.logoUrl}">
                                                                <img src="${brand.logoUrl}" alt="${brand.name} Logo" class="img-thumbnail" style="max-width: 100px; max-height: 100px;">
                                                            </c:when>
                                                            <c:otherwise>N/A</c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <span class="badge ${brand.active ? 'bg-success' : 'bg-danger'} text-white">
                                                            ${brand.active ? 'Active' : 'Discontinued'}
                                                        </span>
                                                    </td>
                                                    <td>
                                                        <a href="${pageContext.request.contextPath}/BrandManager?action=edit&id=${brand.brandId}" class="btn btn-primary btn-sm"><i class="bi bi-pencil"></i> Edit</a>
                                                        <a href="${pageContext.request.contextPath}/BrandManager?action=delete&id=${brand.brandId}" class="btn btn-danger btn-sm" 
                                                           onclick="return confirm('Are you sure you want to delete ${brand.name}?')"><i class='bi bi-trash'></i> Delete</a>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </c:when>
                                <c:otherwise>
                                    <p>No brands found!</p>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%-- Link to common JS --%>
    <script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>

    <%-- JS for active menu --%>
    <script>
        document.addEventListener('DOMContentLoaded', function () {
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