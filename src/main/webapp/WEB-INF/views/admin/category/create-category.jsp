<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Create Category</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
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
    <c:set var="pageTitle" value="Create Category" scope="request"/>
    <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp" />
    
        <div class="content-area">
            <div class="row">
                <div class="col-12">
                    <div class="box box-primary">
                        <div class="box-header with-border">
                            <h3 class="box-title">Create Category</h3>
                        </div>
                        <div class="box-body">
                            <c:if test="${not empty err}">
                                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                    ${err}
                                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                                </div>
                            </c:if>
                            <form action="${pageContext.request.contextPath}/CategoryManager" method="post" onsubmit="return validateForm()">
                                <input type="hidden" name="action" value="create">
                                <div class="row mb-3">
                                    <div class="col-md-6">
                                        <label for="name" class="form-label">Name <span class="text-danger">*</span></label>
                                        <input type="text" id="name" name="name" class="form-control" required maxlength="100" placeholder="e.g., Men's Shirts" oninput="validateName(this)">
                                        <div class="invalid-feedback" id="nameFeedback">Please enter a valid category name (max 100 characters).</div>
                                    </div>
                                    <div class="col-md-6">
                                        <label for="parentCategoryId" class="form-label">Parent Category</label>
                                        <select id="parentCategoryId" name="parentCategoryId" class="form-select" onchange="validateName(document.getElementById('name'))">
                                            <option value="">None (Top-level category)</option>
                                            <c:forEach var="category" items="${categories}">
                                                <c:if test="${empty category.parentCategoryId}">
                                                    <option value="${category.categoryId}">${category.name}</option>
                                                </c:if>
                                            </c:forEach>
                                        </select>
                                    </div>
                                </div>
                                <div class="row mb-3">
                                    <div class="col-md-6">
                                        <label for="description" class="form-label">Description</label>
                                        <textarea id="description" name="description" class="form-control" rows="3" placeholder="e.g., Shirts for men in various styles"></textarea>
                                    </div>
                                    <div class="col-md-6">
                                        <label for="isActive" class="form-label">Status</label>
                                        <select id="isActive" name="isActive" class="form-select">
                                            <option value="true" selected>Active</option>
                                            <option value="false">Inactive</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="text-end">
                                    <button type="submit" class="btn btn-primary"><i class="bi bi-save me-1"></i>Create Category</button>
                                    <a href="${pageContext.request.contextPath}/CategoryManager?action=list" class="btn btn-secondary"><i class="bi bi-arrow-left me-1"></i>Cancel</a>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    
    <script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
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
                        parentTreeview.classList.add('active', 'menu-open');
                    }
                }
            }
        });

        function validateName(input) {
            const name = input.value.trim();
            const parentCategoryId = document.getElementById('parentCategoryId').value;
            const feedback = document.getElementById('nameFeedback');
            input.classList.remove('is-invalid');
            feedback.textContent = 'Please enter a valid category name (max 100 characters).';
            if (name === '' || name.length > 100) {
                input.classList.add('is-invalid');
                return;
            }
            // AJAX check for duplicate name under the same parent category
            let url = `${window.location.origin}${pageContext.request.contextPath}/CategoryManager?action=checkDuplicate&name=` + encodeURIComponent(name);
            if (parentCategoryId) {
                url += `&parentCategoryId=` + encodeURIComponent(parentCategoryId);
            }
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
            // Note: Duplicate check is async, so rely on oninput validation
            return true;
        }
    </script>
</body>
</html>