<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Category Details</title>
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
        .detail-section {
            margin-bottom: 1rem;
        }
        .detail-label {
            font-weight: 600;
            font-size: 0.9rem;
            color: #4a5568;
            margin-bottom: 0.25rem;
        }
        .detail-value {
            font-size: 0.85rem;
            color: #2d3748;
        }
        .badge {
            padding: 0.3rem 0.6rem;
            font-size: 0.75rem;
            border-radius: 10px;
        }
        .btn {
            border-radius: 6px;
            padding: 0.4rem 0.8rem;
            font-size: 0.85rem;
            transition: all 0.2s ease;
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
            .detail-label {
                font-size: 0.85rem;
            }
            .detail-value {
                font-size: 0.8rem;
            }
            .btn {
                padding: 0.3rem 0.6rem;
                font-size: 0.8rem;
            }
            .badge {
                font-size: 0.7rem;
            }
        }
    </style>
</head>
<body>
    <c:set var="currentAction" value="categories" scope="request"/>
    <c:set var="currentModule" value="admin" scope="request"/>
    <c:set var="pageTitle" value="Category Details" scope="request"/>
    <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp" />
    
        <div class="content-area">
            <div class="row">
                <div class="col-12">
                    <div class="box box-primary">
                        <div class="box-header with-border">
                            <h3 class="box-title">Category Details</h3>
                        </div>
                        <div class="box-body">
                            <c:if test="${not empty err}">
                                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                    ${err}
                                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                                </div>
                            </c:if>
                            <c:choose>
                                <c:when test="${not empty category}">
                                    <div class="detail-section">
                                        <div class="row">
                                            <div class="col-md-6">
                                                <div class="detail-label">ID</div>
                                                <div class="detail-value">${category.categoryId}</div>
                                            </div>
                                            <div class="col-md-6">
                                                <div class="detail-label">Name</div>
                                                <div class="detail-value">${category.name}</div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="detail-section">
                                        <div class="row">
                                            <div class="col-md-6">
                                                <div class="detail-label">Description</div>
                                                <div class="detail-value">${not empty category.description ? category.description : 'N/A'}</div>
                                            </div>
                                            <div class="col-md-6">
                                                <div class="detail-label">Parent Category</div>
                                                <div class="detail-value">
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
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="detail-section">
                                        <div class="row">
                                            <div class="col-md-6">
                                                <div class="detail-label">Status</div>
                                                <div class="detail-value">
                                                    <span class="badge ${category.active ? 'bg-success' : 'bg-danger'} text-white">
                                                        ${category.active ? 'Active' : 'Discontinued'}
                                                    </span>
                                                </div>
                                            </div>
                                            <div class="col-md-6">
                                                <div class="detail-label">Created At</div>
                                                <div class="detail-value">${category.createdAt}</div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="text-end">
                                        <a href="${pageContext.request.contextPath}/CategoryManager?action=list" class="btn btn-secondary">
                                            <i class="bi bi-arrow-left me-1"></i>Back to Categories
                                        </a>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                        No category found!
                                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                                    </div>
                                    <div class="text-end">
                                        <a href="${pageContext.request.contextPath}/CategoryManager?action=list" class="btn btn-secondary">
                                            <i class="bi bi-arrow-left me-1"></i>Back to Categories
                                        </a>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
    <script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
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
    </script>
</body>
</html>