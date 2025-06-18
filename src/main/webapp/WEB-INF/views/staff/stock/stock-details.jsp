<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<c:set var="pageTitle" value="Product Details" scope="request"/>
<c:set var="pageSubtitle" value="SKU: ${variant.sku}" scope="request"/>
<c:set var="currentModule" value="stock" scope="request"/>
<c:set var="currentAction" value="stock-list" scope="request"/>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>${pageTitle} - Admin Panel</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css"/>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/admin-dashboard/css/admin-css.css">
    </head>
    <body>
        <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp"/>
        <div class="main-content-wrapper">
            <jsp:include page="/WEB-INF/includes/admin-header.jsp"/>
            <main class="content-area">
                <div class="box">
                    <div class="box-header with-border">
                        <h3 class="box-title">Product Details Information</h3>
                    </div>
                    <div class="box-body">
                        <div class="row">
                            <div class="col-md-6">
                                <h4>Basic Information</h4>
                                <ul class="list-group list-group-flush">
                                    <li class="list-group-item"><strong>Product ID:</strong> <c:out value="${product.productId}"/></li>
                                    <li class="list-group-item"><strong>Product Name:</strong> <c:out value="${product.name}"/></li>
                                    <li class="list-group-item"><strong>Material:</strong> <c:out value="${product.material}"/></li>
                                    <li class="list-group-item"><strong>Original Price:</strong> <c:out value="${product.price}"/></li>
                                    <li class="list-group-item"><strong>Status:</strong> <c:out value="${product.status}"/></li>
                                </ul>
                            </div>
                            <div class="col-md-6">
                                <h4>Variant Information</h4>
                                <ul class="list-group list-group-flush">
                                    <li class="list-group-item"><strong>Variant ID:</strong> <c:out value="${variant.variantId}"/></li>
                                    <li class="list-group-item"><strong>SKU:</strong> <c:out value="${variant.sku}"/></li>
                                    <li class="list-group-item"><strong>Size:</strong> <c:out value="${variant.size}"/></li>
                                    <li class="list-group-item"><strong>Color:</strong> <c:out value="${variant.color}"/></li>
                                    <li class="list-group-item"><strong>Price Modifier:</strong> <c:out value="${variant.priceModifier}"/></li>
                                </ul>
                            </div>
                        </div>
                        <hr>
                        <div class="row mt-3">
                            <div class="col-md-6">
                                <h4>Classification Information</h4>
                                <ul class="list-group list-group-flush">
                                    <li class="list-group-item"><strong>Category ID:</strong> <c:out value="${category.categoryId}"/></li>
                                    <li class="list-group-item"><strong>Category Name:</strong> <c:out value="${category.name}"/></li>
                                    <li class="list-group-item"><strong>Brand ID:</strong> <c:out value="${brand.brandId}"/></li>
                                    <li class="list-group-item"><strong>Brand Name:</strong> <c:out value="${brand.name}"/></li>
                                </ul>
                            </div>
                            <div class="col-md-6">
                                <h4>Inventory Information</h4>
                                <ul class="list-group list-group-flush">
                                    <li class="list-group-item"><strong>Inventory ID:</strong> <c:out value="${inventory.inventoryId}"/></li>
                                    <li class="list-group-item"><strong>Quantity in Stock:</strong> <c:out value="${inventory.quantity}"/>
                                        <a href="${pageContext.request.contextPath}/EditStock?variantId=${variant.variantId}" class="btn btn-warning btn-xs"><i class="fa fa-pencil"></i> Edit
                                        </a></li>
                                    <li class="list-group-item"><strong>Reserved Quantity:</strong> <c:out value="${inventory.reservedQuantity}"/></li>
                                    <li class="list-group-item"><strong>Last Updated:</strong> <c:out value="${inventory.lastUpdated}"/></li>
                                </ul>
                            </div>
                        </div>
                        <%-- Add this box to the end of the product-details.jsp page --%>
                        <div class="box mt-4">
                            <div class="box-header with-border">
                                <h3 class="box-title">Inventory Change History</h3>
                            </div>
                            <div class="box-body">
                                <div class="table-responsive">
                                    <table class="table table-striped table-sm">
                                        <thead>
                                            <tr>
                                                <th>Timestamp</th>
                                                <th>Change Type</th>
                                                <th>Quantity Changed</th>
                                                <th>Notes</th>
                                                <th>Performed By</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:choose>
                                                <c:when test="${not empty movementHistory}">
                                                    <c:forEach var="movement" items="${movementHistory}">
                                                        <tr>
                                                            <%-- Now just display the pre-formatted string --%>
                                                            <td><c:out value="${movement.createdAtFormatted}"/></td>

                                                            <td>
                                                                <c:choose>
                                                                    <c:when test="${movement.movementType == 'In'}"><span class="badge bg-success">Stock In</span></c:when>
                                                                    <c:when test="${movement.movementType == 'Out'}"><span class="badge bg-danger">Stock Out</span></c:when>
                                                                    <c:when test="${movement.movementType == 'Adjustment'}"><span class="badge bg-warning text-dark">Adjustment</span></c:when>
                                                                    <c:otherwise><c:out value="${movement.movementType}"/></c:otherwise>
                                                                </c:choose>
                                                            </td>
                                                            <td>
                                                                <strong class="${movement.quantityChanged > 0 ? 'text-success' : 'text-danger'}">
                                                                    ${movement.quantityChanged > 0 ? '+' : ''}<c:out value="${movement.quantityChanged}"/>
                                                                </strong>
                                                            </td>
                                                            <td><c:out value="${movement.notes}"/></td>

                                                            <%-- Display Staff Name instead of ID --%>
                                                            <td><c:out value="${movement.staffName}"/></td>
                                                        </tr>
                                                    </c:forEach>
                                                </c:when>
                                                <c:otherwise>
                                                    <tr>
                                                        <td colspan="5" class="text-center text-muted p-3">
                                                            No change history available for this product.
                                                        </td>
                                                    </tr>
                                                </c:otherwise>
                                            </c:choose>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                        <hr>
                        <a href="${pageContext.request.contextPath}/Stock" class="btn btn-secondary">
                            <i class="fa fa-arrow-left"></i> Back to list
                        </a>
                        <a href="${pageContext.request.contextPath}/StockMovement" class="btn btn-secondary">
                            View Stock Movement <i class="fa fa-arrow-right"></i> 
                        </a>
                    </div>
                </div>
            </main>
        </div>
        <script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>
    </body>
</html>