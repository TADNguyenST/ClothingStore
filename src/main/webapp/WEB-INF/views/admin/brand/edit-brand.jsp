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
    <title>Edit Brand</title>

    <%-- Link to external libraries --%>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

    <%-- Link to common CSS --%>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/admin-dashboard/css/admin-css.css">
</head>
<body>
    <%-- Set necessary requestScope variables for sidebar/header --%>
    <c:set var="currentAction" value="brandForm" scope="request"/>
    <c:set var="currentModule" value="brand" scope="request"/>
    <c:set var="pageTitle" value="Edit Brand" scope="request"/>

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
                            <h3 class="box-title">Edit Brand</h3>
                        </div>
                        <div class="box-body">
                            <%-- Error Message --%>
                            <c:if test="${not empty err}">
                                <p class="text-danger">${err}</p>
                            </c:if>

                            <%-- Edit Form --%>
                            <c:choose>
                                <c:when test="${not empty brand}">
                                    <form action="${pageContext.request.contextPath}/BrandManager" method="post" onsubmit="return validateForm()">
                                        <input type="hidden" name="action" value="update">
                                        <input type="hidden" name="id" value="${brand.brandId}">
                                        <div class="mb-3">
                                            <label for="name" class="form-label">Name <span class="text-danger">*</span></label>
                                            <input type="text" class="form-control" id="name" name="name" value="${brand.name}" required maxlength="100" placeholder="Enter brand name">
                                            <div class="invalid-feedback">Please enter a valid brand name (max 100 characters).</div>
                                        </div>
                                        <div class="mb-3">
                                            <label for="description" class="form-label">Description</label>
                                            <textarea class="form-control" id="description" name="description" rows="4" placeholder="Enter brand description">${brand.description}</textarea>
                                        </div>
                                        <div class="mb-3">
                                            <label for="logoUrl" class="form-label">Logo URL</label>
                                            <input type="url" class="form-control" id="logoUrl" name="logoUrl" value="${brand.logoUrl}" placeholder="Enter logo URL (e.g., https://example.com/logo.png)">
                                            <div class="invalid-feedback">Please enter a valid URL.</div>
                                        </div>
                                        <div class="mb-3">
                                            <label for="isActive" class="form-label">Status</label>
                                            <select class="form-select" id="isActive" name="isActive">
                                                <option value="true" ${brand.active ? 'selected' : ''}>Active</option>
                                                <option value="false" ${brand.active ? '' : 'selected'}>Discontinued</option>
                                            </select>
                                        </div>
                                        <div class="mb-3">
                                            <button type="submit" class="btn btn-primary"><i class="bi bi-save"></i> Update</button>
                                            <a href="${pageContext.request.contextPath}/BrandManager?action=list" class="btn btn-secondary"><i class="bi bi-arrow-left"></i> Back to List</a>
                                        </div>
                                    </form>
                                </c:when>
                                <c:otherwise>
                                    <p class="text-danger">Brand not found!</p>
                                    <div class="mb-3">
                                        <a href="${pageContext.request.contextPath}/BrandManager?action=list" class="btn btn-secondary"><i class="bi bi-arrow-left"></i> Back to List</a>
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

    <%-- JS for active menu and form validation --%>
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

        // Client-side form validation
        function validateForm() {
            let isValid = true;
            const nameInput = document.getElementById('name');
            const logoUrlInput = document.getElementById('logoUrl');

            // Validate name
            if (nameInput.value.trim() === '' || nameInput.value.length > 100) {
                nameInput.classList.add('is-invalid');
                isValid = false;
            } else {
                nameInput.classList.remove('is-invalid');
            }

            // Validate logo URL
            if (logoUrlInput.value.trim() !== '') {
                const urlPattern = /^(https?:\/\/[^\s$.?#].[^\s]*)$/;
                if (!urlPattern.test(logoUrlInput.value)) {
                    logoUrlInput.classList.add('is-invalid');
                    isValid = false;
                } else {
                    logoUrlInput.classList.remove('is-invalid');
                }
            } else {
                logoUrlInput.classList.remove('is-invalid');
            }

            return isValid;
        }
    </script>
</body>
</html>