<%-- 
    Document   : cart
    Created on : Jun 14, 2025, 4:37:16 AM
    Author     : Lenovo
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="container my-5">
    <h2 class="mb-4">Your Shopping Cart</h2>

    <c:if test="${empty cartItems}">
        <div class="text-center p-5 border rounded bg-light">
            <p class="fs-4">Your shopping cart is empty.</p>
            <a href="${pageContext.request.contextPath}/home" class="btn btn-primary mt-3">Continue Shopping</a>
        </div>
    </c:if>

    <c:if test="${not empty cartItems}">
        <div class="row">
            <!-- Product List Column -->
            <div class="col-lg-8">
                <c:forEach var="item" items="${cartItems}">
                    <div class="card mb-3">
                        <div class="card-body">
                            <div class="d-flex">
                                <img src="${item.productImageUrl != null ? item.productImageUrl : 'https://placehold.co/100x100/EFEFEF/AAAAAA?text=Image'}" class="img-fluid rounded" style="width: 100px; height: 100px; object-fit: cover;" alt="${item.productName}">
                                <div class="ms-3 flex-grow-1">
                                    <h5>${item.productName}</h5>
                                    <p class="text-muted small">
                                        Size: ${item.size} / Color: ${item.color}
                                    </p>
                                    <p class="fw-bold">
                                        <fmt:formatNumber value="${item.unitPrice}" type="number" maxFractionDigits="0"/>đ
                                    </p>
                                </div>
                                <div class="d-flex flex-column align-items-end justify-content-between" style="min-width: 150px;">
                                    <form action="${pageContext.request.contextPath}/customer/cart" method="post" class="d-flex align-items-center">
                                        <input type="hidden" name="action" value="update">
                                        <input type="hidden" name="cartItemId" value="${item.cartItemId}">
                                        <input type="number" name="quantity" class="form-control form-control-sm" style="width: 70px;" value="${item.quantity}" min="1" onchange="this.form.submit()">
                                    </form>
                                    <form action="${pageContext.request.contextPath}/customer/cart" method="post">
                                        <input type="hidden" name="action" value="remove">
                                        <input type="hidden" name="cartItemId" value="${item.cartItemId}">
                                        <button type="submit" class="btn btn-link text-danger p-0">Remove</button>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>

            <!-- Order Summary Column -->
            <div class="col-lg-4">
                <div class="card">
                    <div class="card-body">
                        <h4 class="card-title">Order Summary</h4>
                        <hr>
                        <div class="d-flex justify-content-between">
                            <span>Subtotal</span>
                            <span>
                                <fmt:formatNumber value="${subtotal}" type="number" maxFractionDigits="0"/>đ
                            </span>
                        </div>
                        <div class="d-flex justify-content-between mt-2">
                            <span>Shipping</span>
                            <span>Calculated at next step</span>
                        </div>
                        <hr>
                        <div class="d-flex justify-content-between fw-bold fs-5">
                            <span>Total</span>
                            <span>
                                <fmt:formatNumber value="${subtotal}" type="number" maxFractionDigits="0"/>đ
                            </span>
                        </div>
                        <div class="d-grid mt-4">
                            <a href="${pageContext.request.contextPath}/customer/checkout" class="btn btn-primary btn-lg">Proceed to Checkout</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </c:if>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
