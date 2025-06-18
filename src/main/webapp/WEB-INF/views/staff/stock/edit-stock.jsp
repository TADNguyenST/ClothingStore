<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%-- 1. Set variables for this page --%>
<c:set var="pageTitle" value="Edit Stock Information" scope="request"/>
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
                        <h3 class="box-title">Edit stock information for SKU: <c:out value="${variant.sku}"/></h3>
                    </div>
                    <div class="box-body">

                        <%-- Display error if any (e.g., non-numeric input) --%>
                        <c:if test="${not empty errorMessage}">
                            <div class="alert alert-warning"><c:out value="${errorMessage}"/></div>
                        </c:if>

                        <form action="${pageContext.request.contextPath}/EditStock" method="POST">

                            <%-- Send IDs as hidden fields so the Controller knows which object to update --%>
                            <input type="hidden" name="variantId" value="${variant.variantId}">
                            <input type="hidden" name="inventoryId" value="${inventory.inventoryId}">

                            <div class="mb-3">
                                <label class="form-label">Product Name</label>
                                <input type="text" class="form-control" value="<c:out value='${product.name}'/>" disabled>
                                <small class="form-text text-muted d-block mb-1">Current quantity in stock: <strong><c:out value="${inventory.quantity}"/></strong></small>
                            </div>
                            <hr>

                            <div class="mb-3">
                                <label class="form-label fw-bold">Select Action for Stock Quantity:</label>
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="updateAction" id="actionSet" value="set" checked>
                                    <label class="form-check-label" for="actionSet">
                                        Set Quantity (Overwrite old quantity with new value)
                                    </label>
                                </div>
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="updateAction" id="actionAdd" value="add">
                                    <label class="form-check-label" for="actionAdd">
                                        Add to Stock (Add to the current quantity)
                                    </label>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label for="quantityValue" class="form-label">Value to Change Stock:</label>                             
                                    <input type="number" class="form-control" id="quantityValue" name="quantityValue" min="0" value="0" required>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label for="reservedQuantity" class="form-label">Set Reserved Quantity:</label>
                                    <input type="number" class="form-control" id="reservedQuantity" name="reservedQuantity"
                                           value="${inventory.reservedQuantity}" required>
                                </div>
                            </div>

                            <hr>
                            <button type="submit" class="btn btn-primary">Save Changes</button>
                            <a href="${pageContext.request.contextPath}/Stock" class="btn btn-secondary">Cancel</a>
                        </form>

                    </div>
                </div>
            </main>
        </div>

        <script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>
    </body>
</html>