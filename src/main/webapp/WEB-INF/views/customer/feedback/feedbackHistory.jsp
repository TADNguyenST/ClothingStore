<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<html>
<head>
    <title>Feedback History</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    <style>
        /* Existing styles remain unchanged */
    </style>
</head>
<body class="bg-light">
    <div class="container my-5">
        <h1 class="text-center mb-4 text-dark fw-bold">List of Orders with Feedback</h1>
        <c:if test="${empty orders}">
            <p class="text-center text-muted fs-5">You have not provided feedback for any orders.</p>
        </c:if>
        <c:if test="${not empty orders}">
            <div class="

table-responsive shadow-sm rounded">
                <table class="table table-hover bg-white mb-0">
                    <thead class="bg-light">
                        <tr>
                            <th scope="col" class="py-3 px-4 text-start small fw-bold text-dark">Order ID</th>
                            <th scope="col" class="py-3 px-4 text-start small fw-bold text-dark">Order Date</th>
                            <th scope="col" class="py-3 px-4 text-start small fw-bold text-dark">Total Price</th>
                            <th scope="col" class="py-3 px-4 text-start small fw-bold text-dark">Status</th>
                            <th scope="col" class="py-3 px-4 text-start small fw-bold text-dark">Products</th>
                            <th scope="col" class="py-3 px-4 text-start small fw-bold text-dark">Feedback</th>
                            <th scope="col" class="py-3 px-4 text-start small fw-bold text-dark">Reply</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="order" items="${orders}">
                            <tr class="table-row">
                                <td class="py-4 px-4 text-secondary">${order.orderId}</td>
                                <td class="py-4 px-4 text-secondary">${order.orderDate}</td>
                                <td class="py-4 px-4 text-secondary"><fmt:formatNumber value="${order.totalPrice}" pattern="#,### đ" minFractionDigits="0" maxFractionDigits="0"/></td>
                                <td class="py-4 px-4 text-secondary">${order.status}</td>
                                <td class="py-4 px-4 text-secondary">
                                    <ul class="list-unstyled">
                                        <c:forEach var="item" items="${order.orderItems}">
                                            <li>${item.productName} - Size: ${item.size}, Color: ${item.color}, Quantity: ${item.quantity}</li>
                                        </c:forEach>
                                    </ul>
                                </td>
                                <td class="py-4 px-4 text-secondary">
                                    <c:forEach var="item" items="${order.orderItems}">
                                        <c:if test="${not empty item.feedbacks}">
                                            <ul class="list-unstyled mb-2">
                                                <c:forEach var="feedback" items="${item.feedbacks}">
                                                    <li class="feedback-item mb-2">
                                                        <span class="fw-bold">Rating:</span> ${feedback.rating}/5<br>
                                                        <span class="fw-bold">Comments:</span> ${feedback.comments}
                                                    </li>
                                                </c:forEach>
                                            </ul>
                                        </c:if>
                                        <c:if test="${empty item.feedbacks}">
                                            <p class="text-muted">No feedback available for this item.</p>
                                        </c:if>
                                    </c:forEach>
                                </td>
                                <td class="py-4 px-4 text-secondary">
                                    <c:forEach var="item" items="${order.orderItems}">
                                        <c:if test="${not empty item.feedbacks}">
                                            <ul class="list-unstyled mb-2">
                                                <c:forEach var="feedback" items="${item.feedbacks}">
                                                    <li class="reply-item mb-2">
                                                        <c:choose>
                                                            <c:when test="${not empty feedback.replyContent}">
                                                                <span class="fw-bold reply-text"></span> <span class="reply-text">${feedback.replyContent}</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="text-muted">No reply available</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </li>
                                                </c:forEach>
                                            </ul>
                                        </c:if>
                                        <c:if test="${empty item.feedbacks}">
                                            <p class="text-muted">No reply available</p>
                                        </c:if>
                                    </c:forEach>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </c:if>
        <div class="text-center mt-5">
            <a href="${pageContext.request.contextPath}/feedback" class="btn btn-primary back-link fw-bold">Back to Feedback Page</a>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
</body>
</html>