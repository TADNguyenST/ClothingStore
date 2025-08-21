<%--
    Document : editCategory
    Created on : Aug 11, 2025, 8:26 PM
    Author : Thinh
--%>
<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Category</title>
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
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <meta http-equiv="Pragma" content="no-cache">
    <meta http-equiv="Expires" content="0">
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
        .form-label {
            font-weight: 500;
            font-size: 0.9rem;
            color: #4a5568;
            margin-bottom: 0.5rem;
        }
        .form-control, .form-select {
            border-radius: 6px;
            font-size: 0.85rem;
            border: 1px solid #d1d5db;
            padding: 0.4rem 0.75rem;
        }
        .form-control:focus, .form-select:focus {
            border-color: #3b82f6;
            box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
        }
        .btn {
            border-radius: 6px;
            padding: 0.4rem 0.8rem;
            font-size: 0.85rem;
            transition: all 0.2s ease;
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
        .btn-secondary {
            background-color: #6b7280;
            border-color: #6b7280;
        }
        .btn-secondary:hover {
            background-color: #4b5563;
            border-color: #4b5563;
            transform: translateY(-1px);
        }
        .alert {
            border-radius: 6px;
            margin-bottom: 1rem;
            font-size: 0.9rem;
        }
        @media (max-width: 768px) {
            .content-area {
                margin-left: 0;
                width: 100%;
                padding: 0.75rem;
            }
            .sidebar.hidden ~ .content-area {
                margin-left: 0;
            }
            .form-control, .form-select {
                font-size: 0.8rem;
                padding: 0.3rem 0.6rem;
            }
            .btn {
                padding: 0.3rem 0.6rem;
                font-size: 0.8rem;
            }
        }
    </style>
</head>
<body>
    <c:set var="currentAction" value="categories" scope="request"/>
    <c:set var="currentModule" value="admin" scope="request"/>
    <c:set var="pageTitle" value="Edit Category" scope="request"/>
   <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp" />
    <div class="content-area">
        <h2 style="text-align: center;">Edit Category</h2>
        <!-- Debug information -->
        
        <c:if test="${not empty msg}">
            <div class="alert alert-success">${msg}</div>
            <c:remove var="msg" scope="session" />
        </c:if>
        <c:if test="${not empty err}">
            <div class="alert alert-danger">${err}</div>
        </c:if>
        <c:choose>
            <c:when test="${not empty category}">
                <form action="${pageContext.request.contextPath}/CategoryEditAdmin" method="post" onsubmit="return validateForm()">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="id" value="${category.categoryId}">
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label for="name" class="form-label">Name <span class="text-danger">*</span></label>
                            <input type="text" id="name" name="name" class="form-control" value="<c:out value="${category.name}" default="" />" required maxlength="100" placeholder="e.g., Men's Shirts" oninput="validateName(this)">
                            <div class="invalid-feedback" id="nameFeedback">Please enter a valid category name.</div>
                        </div>
                        <div class="col-md-6">
                            <label for="parentCategoryId" class="form-label">Parent Category</label>
                            <select id="parentCategoryId" name="parentCategoryId" class="form-select" onchange="validateName(document.getElementById('name'))">
                                <option value="">None (Top-level category)</option>
                                <c:forEach var="parent" items="${categories}">
                                    <c:if test="${empty parent.parentCategoryId && parent.categoryId != category.categoryId}">
                                        <option value="${parent.categoryId}" ${parent.categoryId == category.parentCategoryId ? 'selected' : ''}>
                                            <c:out value="${parent.name}" default="N/A" />
                                        </option>
                                    </c:if>
                                </c:forEach>
                            </select>
                        </div>
                    </div>
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label for="description" class="form-label">Description</label>
                            <textarea id="description" name="description" class="form-control" rows="3" placeholder="e.g., Shirts for men in various styles"><c:out value="${category.description}" default="" /></textarea>
                        </div>
                        <div class="col-md-6">
                            <label for="isActive" class="form-label">Status</label>
                            <select id="isActive" name="isActive" class="form-select">
                                <option value="true" ${category.isActive ? 'selected' : ''}>Active</option>
                                <option value="false" ${!category.isActive ? 'selected' : ''}>Inactive</option>
                            </select>
                        </div>
                    </div>
                    <div class="text-end">
                        <button type="submit" class="btn btn-primary"><i class="bi bi-save me-1"></i>Update Category</button>
                        <a href="${pageContext.request.contextPath}/CategoryListAdmin" class="btn btn-secondary"><i class="bi bi-arrow-left me-1"></i>Cancel</a>
                    </div>
                </form>
            </c:when>
            <c:otherwise>
                <div class="alert alert-danger">No category found!</div>
                <div class="text-end">
                    <a href="${pageContext.request.contextPath}/CategoryListAdmin" class="btn btn-secondary"><i class="bi bi-arrow-left me-1"></i>Back to List</a>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
    <script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>
    <script>
        function validateName(input) {
            const name = input.value.trim();
            const parentCategoryId = document.getElementById('parentCategoryId').value;
            const feedback = document.getElementById('nameFeedback');
            const categoryId = "${category.categoryId}";
            input.classList.remove('is-invalid');
            feedback.textContent = 'Please enter a valid category name (max 100 characters).';
            if (name === '' || name.length > 100) {
                input.classList.add('is-invalid');
                return;
            }
            let url = `${window.location.origin}${pageContext.request.contextPath}/CategoryCheckDuplicateAdmin?name=` + encodeURIComponent(name);
            if (parentCategoryId) {
                url += `&parentCategoryId=` + encodeURIComponent(parentCategoryId);
            }
            url += `&categoryId=` + encodeURIComponent(categoryId);
            fetch(url)
                .then(response => response.json())
                .then(data => {
                    if (data.exists) {
                        input.classList.add('is-invalid');
                        feedback.textContent = 'Category name already exists under this parent category.';
                    } else {
                        input.classList.remove('is-invalid');
                    }
                })
                .catch(error => {
                    console.error('Error checking duplicate name:', error);
                });
        }

        function validateForm() {
            const nameInput = document.getElementById('name');
            const name = nameInput.value.trim();
            if (name === '' || name.length > 100) {
                nameInput.classList.add('is-invalid');
                return false;
            }
            return true;
        }
    </script>
</body>
</html>