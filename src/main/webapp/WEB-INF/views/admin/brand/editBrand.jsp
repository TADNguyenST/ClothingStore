<%--
    Document : edit-brand
    Created on : Aug 11, 2025, 9:07 PM
    Author : Thinh
--%>
<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Brand</title>
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
            margin-bottom: 1rem;
            font-size: 0.9rem;
        }
        .img-thumbnail {
            max-width: 60px;
            max-height: 60px;
            object-fit: contain;
            border-radius: 6px;
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
            .img-thumbnail {
                max-width: 50px;
                max-height: 50px;
            }
        }
    </style>
</head>
<body>
    <c:set var="currentAction" value="brands" scope="request"/>
    <c:set var="currentModule" value="admin" scope="request"/>
    <c:set var="pageTitle" value="Edit Brand" scope="request"/>
    <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp" />
    <div class="content-area">
        <h2 style="text-align: center;">Edit Brand</h2>
        <!-- Debug information -->
        
        <c:if test="${not empty msg}">
            <div class="alert alert-success">${msg}</div>
            <c:remove var="msg" scope="session" />
        </c:if>
        <c:if test="${not empty err}">
            <div class="alert alert-danger">${err}</div>
        </c:if>
        <c:choose>
            <c:when test="${not empty brand}">
                <form action="${pageContext.request.contextPath}/BrandEditAdmin" method="post" enctype="multipart/form-data" onsubmit="return validateForm()">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="id" value="${brand.brandId}">
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label for="name" class="form-label">Name <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" id="name" name="name" value="<c:out value="${brand.name}" default="" />" required maxlength="100" placeholder="e.g., Nike" oninput="validateName(this)">
                            <div class="invalid-feedback" id="nameFeedback">Please enter a valid brand name.</div>
                        </div>
                        <div class="col-md-6">
                            <label for="logo" class="form-label">New Logo (optional)</label>
                            <input type="file" class="form-control" id="logo" name="logo" accept="image/jpeg,image/png,image/gif">
                            <div class="invalid-feedback">Please upload a valid image file (jpg, jpeg, png, gif).</div>
                            <c:if test="${not empty brand.logoUrl}">
                                <div class="mt-2">
                                    <label class="form-label">Current Logo</label>
                                    <img src="${fn:escapeXml(brand.logoUrl)}" alt="Brand Logo" class="img-thumbnail">
                                </div>
                                <input type="hidden" name="logoUrl" value="${fn:escapeXml(brand.logoUrl)}">
                            </c:if>
                            <c:if test="${empty brand.logoUrl}">
                                <div class="mt-2 text-muted">No logo uploaded</div>
                            </c:if>
                        </div>
                    </div>
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label for="description" class="form-label">Description</label>
                            <textarea class="form-control" id="description" name="description" rows="3" placeholder="e.g., Premium sportswear brand"><c:out value="${brand.description}" default="" /></textarea>
                        </div>
                        <div class="col-md-6">
                            <label for="isActive" class="form-label">Status</label>
                            <select id="isActive" name="isActive" class="form-select">
                                <option value="true" ${brand.active ? 'selected' : ''}>Active</option>
                                <option value="false" ${!brand.active ? 'selected' : ''}>Inactive</option>
                            </select>
                        </div>
                    </div>
                    <div class="text-end">
                        <button type="submit" id="submitButton" class="btn btn-primary"><i class="bi bi-save me-1"></i>Update Brand</button>
                        <a href="${pageContext.request.contextPath}/BrandListAdmin" class="btn btn-secondary"><i class="bi bi-arrow-left me-1"></i>Cancel</a>
                    </div>
                </form>
            </c:when>
            <c:otherwise>
                <div class="alert alert-danger">Brand not found!</div>
                <div class="text-end">
                    <a href="${pageContext.request.contextPath}/BrandListAdmin" class="btn btn-secondary"><i class="bi bi-arrow-left me-1"></i>Back to List</a>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
    <script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>
    <script>
        // Auto-dismiss alerts after 3 seconds
        document.addEventListener('DOMContentLoaded', function () {
            const alerts = document.querySelectorAll('.alert-dismissible');
            alerts.forEach(alert => {
                setTimeout(() => {
                    alert.classList.remove('show');
                    alert.classList.add('fade');
                    setTimeout(() => alert.remove(), 150);
                }, 3000);
            });
        });

        function validateName(input) {
            const name = input.value.trim();
            const feedback = document.getElementById('nameFeedback');
            const submitButton = document.getElementById('submitButton');
            const brandId = "${brand.brandId}";
            input.classList.remove('is-invalid');
            feedback.textContent = 'Please enter a valid brand name (max 100 characters).';
            submitButton.disabled = false;
            if (name === '' || name.length > 100) {
                input.classList.add('is-invalid');
                submitButton.disabled = true;
                return;
            }
            const url = `${window.location.origin}${pageContext.request.contextPath}/BrandCheckDuplicateAdmin?name=` + encodeURIComponent(name) + `&brandId=` + encodeURIComponent(brandId);
            fetch(url)
                .then(response => response.json())
                .then(data => {
                    if (data.exists) {
                        input.classList.add('is-invalid');
                        feedback.textContent = 'Brand name already exists.';
                        submitButton.disabled = true;
                    } else {
                        input.classList.remove('is-invalid');
                        submitButton.disabled = false;
                    }
                })
                .catch(error => {
                    console.error('Error checking duplicate name:', error);
                    input.classList.add('is-invalid');
                    feedback.textContent = 'Error checking name availability.';
                    submitButton.disabled = true;
                });
        }

        function validateForm() {
            let isValid = true;
            const nameInput = document.getElementById('name');
            const logoInput = document.getElementById('logo');
            const submitButton = document.getElementById('submitButton');

            // Validate name
            if (nameInput.value.trim() === '' || nameInput.value.length > 100) {
                nameInput.classList.add('is-invalid');
                isValid = false;
            } else {
                nameInput.classList.remove('is-invalid');
            }

            // Validate logo file (if provided)
            if (logoInput.files && logoInput.files.length > 0) {
                const file = logoInput.files[0];
                const validTypes = ['image/jpeg', 'image/png', 'image/gif'];
                if (!validTypes.includes(file.type)) {
                    logoInput.classList.add('is-invalid');
                    isValid = false;
                } else {
                    logoInput.classList.remove('is-invalid');
                }
            } else {
                logoInput.classList.remove('is-invalid');
            }

            submitButton.disabled = !isValid;
            return isValid;
        }
    </script>
</body>
</html>