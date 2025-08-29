<%--
    Document   : detailProduct
    Created on : Aug 11, 2025
    Author     : Thinh
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Product Details</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
        <link href='https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css' rel='stylesheet'>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/admin-dashboard/css/admin-css.css">
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
            .card {
                border-radius: 6px;
                box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            }
            .card-header {
                background-color: #f9fafb;
                font-weight: 600;
                font-size: 1.1rem;
            }
            .table {
                width: 100%;
                border-collapse: collapse;
            }
            .table th, .table td {
                text-align: left;
                vertical-align: middle;
                padding: 0.75rem;
                border: 1px solid #dee2e6;
            }
            .table th {
                background-color: #f9fafb;
                font-weight: 600;
                text-transform: uppercase;
                font-size: 0.8rem;
            }
            .table img {
                width: 80px;
                height: 80px;
                max-width: 80px;
                max-height: 80px;
                object-fit: cover;
                border-radius: 4px;
                border: 1px solid #ddd;
                display: block;
                margin: 0 auto;
            }
            /* New class for product detail image */
            .product-detail-image {
                width: 150px;
                height: 150px;
                object-fit: cover;
                border-radius: 6px;
                border: 1px solid #e2e8f0;
                box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            }
            .status-active {
                background-color: #28a745;
                color: white;
                padding: 0.2rem 0.5rem;
                border-radius: 4px;
            }
            .status-inactive {
                background-color: #dc3545;
                color: white;
                padding: 0.2rem 0.5rem;
                border-radius: 4px;
            }
            .alert {
                border-radius: 6px;
                margin-bottom: 1rem;
                font-size: 0.9rem;
            }
            .btn {
                border-radius: 6px;
                padding: 0.4rem 0.8rem;
                font-size: 0.85rem;
            }
            @media (max-width: 768px) {
                .content-area {
                    margin-left: 0;
                    width: 100%;
                }
                .sidebar.hidden ~ .content-area {
                    margin-left: 0;
                }
                .table img {
                    width: 50px;
                    height: 50px;
                    max-width: 50px;
                    max-height: 50px;
                }
            }
        </style>
    </head>
    <body>
        <c:set var="currentAction" value="products" scope="request"/>
        <c:set var="currentModule" value="admin" scope="request"/>
        <c:set var="pageTitle" value="Product Details" scope="request"/>
        <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp" />
        <div class="content-area">
            <h2 style="text-align: center;">Product Details</h2>
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-warning"><c:out value="${errorMessage}"/></div>
            </c:if>
            <c:choose>
                <c:when test="${not empty product}">
                    <div class="card mb-4">
                        <div class="card-header">
                            Product Information
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-6">
                                    <p><strong>ID:</strong> <c:out value="${product.productId}"/></p>
                                    <p><strong>Product Name:</strong> <c:out value="${product.name}"/></p>
                                    <p><strong>Price:</strong>
                                        <c:choose>
                                            <c:when test="${not empty product.price}">
                                                <fmt:setLocale value="vi_VN"/>
                                                <fmt:formatNumber value="${product.price}" type="currency"/>
                                            </c:when>
                                            <c:otherwise>N/A</c:otherwise>
                                        </c:choose>
                                    </p>
                                    <p><strong>Status:</strong>
                                        <span class="${product.status == 'Active' ? 'status-active' : 'status-inactive'}">
                                            <c:out value="${product.status == 'Active' ? 'Active' : 'Inactive'}"/>
                                        </span>
                                    </p>
                                    <p><strong>Category:</strong>
                                        <c:choose>
                                            <c:when test="${product.category != null}">
                                                <c:out value="${product.parentCategoryName != null ? product.parentCategoryName : ''}"/>
                                                <c:if test="${product.parentCategoryName != null && product.category.name != null}"> / </c:if>
                                                <c:out value="${product.category.name != null ? product.category.name : 'N/A'}"/>
                                            </c:when>
                                            <c:otherwise>N/A</c:otherwise>
                                        </c:choose>
                                    </p>
                                    <p><strong>Brand:</strong> <c:out value="${product.brand != null ? product.brand.name : 'N/A'}"/></p>
                                    <p><strong>Material:</strong> <c:out value="${product.material != null ? product.material : 'N/A'}"/></p>
                                    <p><strong>Description:</strong> <c:out value="${product.description != null ? product.description : 'N/A'}"/></p>
                                    <p><strong>Created At:</strong>
                                        <c:choose>
                                            <c:when test="${not empty product.createdAt}">
                                                <fmt:formatDate value="${product.createdAt}" pattern="dd/MM/yyyy HH:mm:ss"/>

                                            </c:when>
                                            <c:otherwise>N/A</c:otherwise>
                                        </c:choose>
                                    </p>
                                    <p><strong>Updated At:</strong>
                                        <c:choose>
                                            <c:when test="${not empty product.updatedAt}">
                                                <fmt:formatDate value="${product.updatedAt}" pattern="dd/MM/yyyy HH:mm:ss"/>
                                            </c:when>
                                            <c:otherwise>N/A</c:otherwise>
                                        </c:choose>
                                    </p>
                                </div>
                                <div class="col-md-6">
                                    <h5>Product Images</h5>
                                    <c:choose>
                                        <c:when test="${not empty product.images}">
                                            <div class="d-flex flex-wrap gap-3 justify-content-center">
                                                <c:forEach var="image" items="${product.images}">
                                                    <div class="text-center">
                                                        <img src="${fn:escapeXml(image.imageUrl != null ? image.imageUrl : 'https://placehold.co/150x150?text=No+Image')}"
                                                             alt="Product Image" class="product-detail-image">
                                                        <c:if test="${image.main}">
                                                            <p class="text-success mt-1 mb-0"><small><strong>Main Image</strong></small></p>
                                                                    </c:if>
                                                    </div>
                                                </c:forEach>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <p>No images available.</p>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="card mb-4">
                        <div class="card-header">
                            Product Variants
                        </div>
                        <div class="card-body">
                            <c:choose>
                                <c:when test="${not empty product.variants}">
                                    <table class="table table-striped table-hover">
                                        <thead>
                                            <tr>
                                                <th>Variant ID</th>
                                                <th>Size</th>
                                                <th>Color</th>
                                                <th>Price Modifier</th>
                                                <th>SKU</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="variant" items="${product.variants}">
                                                <tr>
                                                    <td><c:out value="${variant.variantId}"/></td>
                                                    <td><c:out value="${variant.size != null ? variant.size : 'N/A'}"/></td>
                                                    <td><c:out value="${variant.color != null ? variant.color : 'N/A'}"/></td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${not empty variant.priceModifier}">
                                                                <fmt:setLocale value="vi_VN"/>
                                                                <fmt:formatNumber value="${variant.priceModifier}" type="currency"/>
                                                            </c:when>
                                                            <c:otherwise>N/A</c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td><c:out value="${variant.sku != null ? variant.sku : 'N/A'}"/></td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </c:when>
                                <c:otherwise>
                                    <p>No variants available.</p>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    <div class="d-flex gap-2">
                        <a href="${pageContext.request.contextPath}/ProductEditAdmin?productId=${product.productId}" class="btn btn-primary">
                            <i class="bi bi-tools"></i> Edit Product
                        </a>
                        <a href="${pageContext.request.contextPath}/ProductListAdmin?action=list" class="btn btn-secondary">
                            <i class="bi bi-arrow-left"></i> Back to List
                        </a>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="alert alert-warning">Product not found!</div>
                    <a href="${pageContext.request.contextPath}/ProductListAdmin?action=list" class="btn btn-secondary">
                        <i class="bi bi-arrow-left"></i> Back to List
                    </a>
                </c:otherwise>
            </c:choose>
        </div>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
        <script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>
    </body>
</html>