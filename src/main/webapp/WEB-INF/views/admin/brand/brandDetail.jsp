<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="model.Brand" %>
<%
    Brand brand = (Brand) request.getAttribute("brand");
    String err = (String) request.getAttribute("err");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Brand Detail</title>

    <%-- Link to external libraries --%>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

    <%-- Link to common CSS --%>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/admin-dashboard/css/admin-css.css">
</head>
<body>
    <%-- Set necessary requestScope variables for sidebar/header --%>
    <c:set var="currentAction" value="brandDetails" scope="request"/>
    <c:set var="currentModule" value="brand" scope="request"/>
    <c:set var="pageTitle" value="Brand Detail" scope="request"/>

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
                            <h3 class="box-title">Brand Detail</h3>
                        </div>
                        <div class="box-body">
                            <%-- Error Message --%>
                            <c:if test="${not empty err}">
                                <p class="text-danger">${err}</p>
                            </c:if>

                            <%-- Brand Details --%>
                            <c:choose>
                                <c:when test="${not empty brand}">
                                    <div class="mb-3">
                                        <strong>ID:</strong> ${brand.brandId}
                                    </div>
                                    <div class="mb-3">
                                        <strong>Name:</strong> ${brand.name}
                                    </div>
                                    <div class="mb-3">
                                        <strong>Description:</strong> ${not empty brand.description ? brand.description : 'N/A'}
                                    </div>
                                    <div class="mb-3">
                                        <strong>Logo URL:</strong>
                                        <c:choose>
                                            <c:when test="${not empty brand.logoUrl}">
                                                <a href="${brand.logoUrl}" target="_blank">${brand.logoUrl}</a>
                                            </c:when>
                                            <c:otherwise>N/A</c:otherwise>
                                        </c:choose>
                                    </div>
                                    <div class="mb-3">
                                        <strong>Status:</strong> ${brand.active ? 'Active' : 'Inactive'}
                                    </div>
                                    <div class="mb-3">
                                        <strong>Created At:</strong> ${not empty brand.createdAt ? brand.createdAt : 'N/A'}
                                    </div>
                                    <div class="mb-3 text-end">
                                        <a href="${pageContext.request.contextPath}/BrandManager?action=edit&id=${brand.brandId}" class="btn btn-primary btn-sm"><i class="bi bi-pencil"></i> Edit</a>
                                        <a href="${pageContext.request.contextPath}/BrandManager?action=list" class="btn btn-secondary btn-sm"><i class="bi bi-arrow-left"></i> Back to List</a>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <p class="text-danger">Brand not found!</p>
                                    <div class="mb-3">
                                        <a href="${pageContext.request.contextPath}/BrandManager?action=list" class="btn btn-secondary btn-sm"><i class="bi bi-arrow-left"></i> Back to List</a>
                                    </div>
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