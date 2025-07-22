<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Create Brand</title>
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
        .btn-primary:disabled {
            background-color: #6b7280;
            border-color: #6b7280;
            cursor: not-allowed;
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
    <c:set var="currentAction" value="brands" scope="request"/>
    <c:set var="currentModule" value="admin" scope="request"/>
    <c:set var="pageTitle" value="Create Brand" scope="request"/>
    <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp" />
    <div class="main-content-wrapper">
        <div class="content-area">
            <div class="row">
                <div class="col-12">
                    <div class="box box-primary">
                        <div class="box-header with-border">
                            <h3 class="box-title">Create New Brand</h3>
                        </div>
                        <div class="box-body">
                            <c:if test="${not empty err}">
                                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                    ${err}
                                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                                </div>
                            </c:if>
                            <form action="${pageContext.request.contextPath}/BrandManager" method="post" enctype="multipart/form-data" onsubmit="return validateForm()">
                                <input type="hidden" name="action" value="create">
                                <div class="row mb-3">
                                    <div class="col-md-6">
                                        <label for="name" class="form-label">Name <span class="text-danger">*</span></label>
                                        <input type="text" class="form-control" id="name" name="name" required maxlength="100" placeholder="e.g., Nike">
                                        <div class="invalid-feedback">Please enter a valid brand name (max 100 characters).</div>
                                    </div>
                                    <div class="col-md-6">
                                        <label for="logo" class="form-label">Logo <span class="text-danger">*</span></label>
                                        <input type="file" class="form-control" id="logo" name="logo" accept="image/jpeg,image/png,image/gif" required>
                                        <div class="invalid-feedback">Please upload a valid image file (jpg, jpeg, png, gif).</div>
                                    </div>
                                </div>
                                <div class="row mb-3">
                                    <div class="col-md-6">
                                        <label for="description" class="form-label">Description</label>
                                        <textarea class="form-control" id="description" name="description" rows="3" placeholder="e.g., Premium sportswear brand"></textarea>
                                    </div>
                                    <div class="col-md-6">
                                        <label for="isActive" class="form-label">Status</label>
                                        <select id="isActive" name="isActive" class="form-select">
                                            <option value="true" selected>Active</option>
                                            <option value="false">Discontinued</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="text-end">
                                    <button type="submit" id="submitButton" class="btn btn-primary"><i class="bi bi-save me-1"></i>Create Brand</button>
                                    <a href="${pageContext.request.contextPath}/BrandManager?action=list" class="btn btn-secondary"><i class="bi bi-arrow-left me-1"></i>Cancel</a>
                                </div>
                            </form>
                        </div>
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

            // Auto-dismiss alerts after 3 seconds
            const alerts = document.querySelectorAll('.alert-dismissible');
            alerts.forEach(alert => {
                setTimeout(() => {
                    alert.classList.remove('show');
                    alert.classList.add('fade');
                    setTimeout(() => alert.remove(), 150);
                }, 3000);
            });
        });

        function validateForm() {
            let isValid = true;
            const nameInput = document.getElementById('name');
            const logoInput = document.getElementById('logo');

            // Validate name length
            if (nameInput.value.length > 100) {
                nameInput.classList.add('is-invalid');
                isValid = false;
            } else {
                nameInput.classList.remove('is-invalid');
            }

            // Validate logo file
            if (!logoInput.files || logoInput.files.length === 0) {
                logoInput.classList.add('is-invalid');
                isValid = false;
            } else {
                const file = logoInput.files[0];
                const validTypes = ['image/jpeg', 'image/png', 'image/gif'];
                if (!validTypes.includes(file.type)) {
                    logoInput.classList.add('is-invalid');
                    isValid = false;
                } else {
                    logoInput.classList.remove('is-invalid');
                }
            }

            return isValid;
        }
    </script>
</body>
</html>