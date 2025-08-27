<%-- File: feedbackForm.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Submit Feedback</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    <style>
        body {
            font-family: 'Inter', sans-serif;
        }
        .order-card {
            transition: transform 0.2s ease-in-out, box-shadow 0.2s ease-in-out;
        }
        .order-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 15px rgba(0, 0, 0, 0.1);
        }
        .star-rating {
            display: flex;
            direction: ltr;
            font-size: 1.5rem;
            cursor: pointer;
        }
        .star-rating input {
            display: none;
        }
        .star-rating label {
            color: #d1d5db;
            transition: color 0.2s ease-in-out;
        }
        .star-rating input:checked ~ label,
        .star-rating label:hover,
        .star-rating label:hover ~ label {
            color: #f59e0b;
        }
        .alert-dismissible {
            transition: opacity 0.5s ease-in-out;
        }
        /* Position the alert at the bottom right corner */
        .alert {
            position: fixed;
            bottom: 20px;
            right: 20px;
            z-index: 1000;
            max-width: 400px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
        }
    </style>
</head>
<body class="bg-light min-vh-100 d-flex flex-column align-items-center py-4">
    <div class="container w-100" style="max-width: 960px;">
        <h1 class="text-center mb-4 fw-bold text-dark">List of Purchased Orders (Not Yet Reviewed)</h1>
        <div class="d-flex justify-content-between align-items-center mb-4">
            <a href="${pageContext.request.contextPath}/home" class="btn btn-secondary">
                Back to Homepage
            </a>
            <a href="${pageContext.request.contextPath}/feedbackHistory" class="btn btn-primary">
                Feedback History
            </a>
        </div>
     
        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger border-start border-4 border-danger rounded" role="alert">
                <p>${errorMessage}</p>
            </div>
        </c:if>
        <c:if test="${not empty sessionScope.message}">
            <div class="alert alert-success border-start border-4 border-success rounded alert-dismissible fade show" role="alert" id="successAlert">
                <p>${sessionScope.message}</p>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
            <c:remove var="message" scope="session"/>
        </c:if>
        <c:choose>
            <c:when test="${empty orders}">
                <div class="card text-center shadow-sm">
                    <div class="card-body">
                        <p class="text-muted">You have no orders to provide feedback for.</p>
                    </div>
                </div>
            </c:when>
            <c:otherwise>
                <c:forEach var="order" items="${orders}">
                    <div class="order-card card shadow-sm mb-4">
                        <div class="card-body">
                            <h3 class="card-title fs-5 fw-semibold text-dark mb-3">Order ID: ${order.orderId}</h3>
                            <div class="row row-cols-1 row-cols-sm-2 g-3 mb-3">
                                <p><span class="fw-medium">Order Date:</span> ${order.orderDate}</p>
                                <p><span class="fw-medium">Total Amount:</span> ${order.totalPrice.intValue()} đ</p>
                                <p><span class="fw-medium">Status:</span> ${order.status}</p>
                            </div>
                            <h4 class="fs-6 fw-medium text-dark mb-2">Products in Order:</h4>
                            <div class="ps-3 border-start border-2 border-secondary">
                                <c:forEach var="item" items="${order.orderItems}">
                                    <p class="text-muted">${item.productName} (Size: ${item.size}, Color: ${item.color}) - Quantity: ${item.quantity}</p>
                                </c:forEach>
                            </div>
                            <form action="${pageContext.request.contextPath}/feedback" method="post" class="mt-4">
                                <input type="hidden" name="orderId" value="${order.orderId}">
                                <div class="mb-3">
                                    <label for="rating-${order.orderId}" class="form-label fw-medium text-dark">Rating (1-5):</label>
                                    <div class="star-rating mt-1">
                                        <input type="radio" name="rating" id="star5-${order.orderId}" value="5" required>
                                        <label for="star5-${order.orderId}" title="5 stars">★</label>
                                        <input type="radio" name="rating" id="star4-${order.orderId}" value="4">
                                        <label for="star4-${order.orderId}" title="4 stars">★</label>
                                        <input type="radio" name="rating" id="star3-${order.orderId}" value="3">
                                        <label for="star3-${order.orderId}" title="3 stars">★</label>
                                        <input type="radio" name="rating" id="star2-${order.orderId}" value="2">
                                        <label for="star2-${order.orderId}" title="2 stars">★</label>
                                        <input type="radio" name="rating" id="star1-${order.orderId}" value="1">
                                        <label for="star1-${order.orderId}" title="1 star">★</label>
                                    </div>
                                </div>
                                <div class="mb-3">
                                    <label for="comments-${order.orderId}" class="form-label fw-medium text-dark">Comments:</label>
                                    <textarea name="comments" id="comments-${order.orderId}" rows="4" class="form-control" required></textarea>
                                </div>
                                <div class="mb-3">
                                    <label for="visibility-${order.orderId}" class="form-label fw-medium text-dark">Visibility:</label>
                                    <select name="visibility" id="visibility-${order.orderId}" class="form-select">
                                        <option value="Public">Public</option>
                                        <option value="Private">Private</option>
                                    </select>
                                </div>
                                <button type="submit" class="btn btn-primary">
                                    Submit Feedback
                                </button>
                            </form>
                        </div>
                    </div>
                </c:forEach>
            </c:otherwise>
        </c:choose>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
    <script>
        // Automatically hide success alert after 5 seconds
        document.addEventListener('DOMContentLoaded', function () {
            const successAlert = document.getElementById('successAlert');
            if (successAlert) {
                setTimeout(function () {
                    successAlert.classList.remove('show');
                    successAlert.style.opacity = '0';
                    setTimeout(function () {
                        successAlert.remove();
                    }, 500); // Wait for fade-out transition to complete
                }, 2000); // Display for 5 seconds
            }
        });
    </script>
</body>
</html>