<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<c:set var="pageTitle" value="Stock History" scope="request"/>
<c:set var="currentModule" value="stock" scope="request"/>
<c:set var="currentAction" value="stock-history" scope="request"/>

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
                        <h3 class="box-title">Inventory Change History</h3>
                    </div>
                    <div class="box-body">
                        <div class="table-responsive">
                            <table class="table table-bordered table-striped table-sm">
                                <thead>
                                    <tr>
                                        <th>Timestamp</th>
                                        <th>Product</th>
                                        <th>SKU</th>
                                        <th>Change Type</th>
                                        <th>Quantity</th>
                                        <th>Notes</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="move" items="${movementList}">
                                        <tr>
                                            <td>
                                                <%-- createdAt is LocalDateTime, still needs formatting --%>
                                                <c:if test="${not empty move.createdAt}">
                                                    <fmt:parseDate value="${move.createdAt}" pattern="yyyy-MM-dd'T'HH:mm:ss" var="parsedDateTime" type="both"/>
                                                    <fmt:formatDate value="${parsedDateTime}" pattern="HH:mm:ss dd/MM/yyyy"/>
                                                </c:if>
                                            </td>
                                            <%-- Access values in the Map by key --%>
                                            <td><c:out value="${move.productName}"/> (<c:out value="${move.size}"/>, <c:out value="${move.color}"/>)</td>
                                            <td><c:out value="${move.sku}"/></td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${move.movementType == 'In'}"><span class="badge bg-success">Stock In</span></c:when>
                                                    <c:when test="${move.movementType == 'Out'}"><span class="badge bg-danger">Stock Out</span></c:when>
                                                    <c:when test="${move.movementType == 'Adjustment'}"><span class="badge bg-warning text-dark">Adjustment</span></c:when>
                                                    <c:otherwise><c:out value="${move.movementType}"/></c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <strong class="${move.quantityChanged > 0 ? 'text-success' : 'text-danger'}">
                                                    ${move.quantityChanged > 0 ? '+' : ''}<c:out value="${move.quantityChanged}"/>
                                                </strong>
                                            </td>
                                            <td><c:out value="${move.notes}"/></td>
                                            <td>
                                                <a href="${pageContext.request.contextPath}/StockDetail?variantId=${move.variantId}" class="btn btn-info btn-xs ms-1">
                                                    <i class="fa-solid fa-eye"></i> Details
                                                </a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>

                        <%-- Pagination Section (Keep as is) --%>
                        <nav aria-label="Page navigation">
                            <ul class="pagination justify-content-center">
                                <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                                    <a class="page-link" href="StockMovement?page=${currentPage - 1}">Previous</a>
                                </li>
                                <c:forEach begin="1" end="${totalPages}" var="i">
                                    <li class="page-item ${currentPage == i ? 'active' : ''}">
                                        <a class="page-link" href="StockMovement?page=${i}">${i}</a>
                                    </li>
                                </c:forEach>
                                <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                    <a class="page-link" href="StockMovement?page=${currentPage + 1}">Next</a>
                                </li>
                            </ul>
                        </nav>
                    </div>
                </div>
            </main>
        </div>
        <script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>
    </body>
</html>