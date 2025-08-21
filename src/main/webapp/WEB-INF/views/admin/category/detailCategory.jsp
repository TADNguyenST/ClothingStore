<%--
    Document : categoryDetail
    Created on : Aug 11, 2025, 8:26 PM
    Author : Thinh
--%>
<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Category Details</title>
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
        <h2 style="text-align: center;">Category Details</h2>
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
                <div class="detail-section">
                    <div class="row">
                        <div class="col-md-6">
                            <div class="detail-label">ID</div>
                            <div class="detail-value"><c:out value="${category.categoryId}" default="N/A" /></div>
                        </div>
                        <div class="col-md-6">
                            <div class="detail-label">Name</div>
                            <div class="detail-value"><c:out value="${category.name}" default="N/A" /></div>
                        </div>
                    </div>
                </div>
                <div class="detail-section">
                    <div class="row">
                        <div class="col-md-6">
                            <div class="detail-label">Description</div>
                            <div class="detail-value"><c:out value="${category.description}" default="N/A" /></div>
                        </div>
                        <div class="col-md-6">
                            <div class="detail-label">Parent Category</div>
                            <div class="detail-value">
                                <c:choose>
                                    <c:when test="${not empty category.parentCategoryId}">
                                        <c:forEach var="cat" items="${categories}">
                                            <c:if test="${cat.categoryId == category.parentCategoryId}">
                                                <c:out value="${cat.name}" default="N/A" />
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
                                <span class="badge ${category.isActive ? 'bg-success' : 'bg-danger'} text-white">
                                    <c:out value="${category.isActive ? 'Active' : 'Discontinued'}" />
                                </span>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="detail-label">Created At</div>
                            <div class="detail-value">
                                <c:choose>
                                    <c:when test="${not empty category.createdAt}">
                                        <fmt:formatDate value="${category.createdAt}" pattern="dd/MM/yyyy HH:mm:ss"/>
                                    </c:when>
                                    <c:otherwise>N/A</c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="text-end">
                    <a href="${pageContext.request.contextPath}/CategoryListAdmin" class="btn btn-secondary">
                        <i class="bi bi-arrow-left me-1"></i>Back to Categories
                    </a>
                </div>
            </c:when>
            <c:otherwise>
                <div class="alert alert-danger">No category found!</div>
                <div class="text-end">
                    <a href="${pageContext.request.contextPath}/CategoryListAdmin" class="btn btn-secondary">
                        <i class="bi bi-arrow-left me-1"></i>Back to Categories
                    </a>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
    <script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>
    <script>
        // Auto-dismiss alerts after 3 seconds
        document.addEventListener('DOMContentLoaded', function() {
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