<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<c:set var="pageTitle" value="Shopping Cart" scope="request"/>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="container my-5">
    <div class="row">
        <div class="col-12">
            <h2 class="mb-4">Your Shopping Cart</h2>
        </div>
    </div>

    <c:if test="${empty cartItems}">
        <div class="text-center p-5 border rounded bg-light">
            <i class="fas fa-shopping-bag fa-3x text-muted mb-3"></i>
            <p class="fs-4">Your shopping cart is empty.</p>
            <a href="${pageContext.request.contextPath}/home" class="btn btn-primary mt-3">Continue Shopping</a>
        </div>
    </c:if>

    <c:if test="${not empty cartItems}">
        <div class="row">
            <div class="col-lg-8">
                <c:forEach var="item" items="${cartItems}">
                    <div class="card mb-3">
                        <div class="card-body">
                            <div class="d-flex align-items-center">
                                <img src="${not empty item.productImageUrl ? item.productImageUrl : 'https://placehold.co/100x120/eee/333?text=Image'}"
                                     class="img-fluid rounded" style="width: 100px; height: 120px; object-fit: cover;"
                                     alt="${item.productName}">

                                <div class="ms-3 flex-grow-1">
                                    <h5 class="mb-1">${item.productName}</h5>
                                    <p class="text-muted small mb-1">
                                        Size: ${item.size} / Color: ${item.color}
                                    </p>
                                    <p class="fw-bold mb-0">
                                        <fmt:formatNumber value="${item.unitPrice}" type="currency" currencyCode="VND"/>
                                    </p>
                                </div>

                                <div class="text-end" style="min-width: 150px;">
                                    <form action="${pageContext.request.contextPath}/customer/cart" method="post" class="d-flex justify-content-end align-items-center mb-2">
                                        <input type="hidden" name="action" value="update">
                                        <input type="hidden" name="cartItemId" value="${item.cartItemId}">
                                        <label for="quantity_${item.cartItemId}" class="visually-hidden">Quantity</label>
                                        <input type="number" id="quantity_${item.cartItemId}" name="quantity" class="form-control form-control-sm" style="width: 70px;" value="${item.quantity}" min="1">
                                        <button type="submit" class="btn btn-sm btn-light ms-2" title="Update Quantity"><i class="fas fa-sync-alt"></i></button>
                                    </form>
                                    <form action="${pageContext.request.contextPath}/customer/cart" method="post" onsubmit="return confirm('Remove this item from cart?');">
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

            <div class="col-lg-4">
                <div class="card">
                    <div class="card-body">
                        <h4 class="card-title">Order Summary</h4>
                        <hr>
                        <div class="d-flex justify-content-between">
                            <span>Subtotal</span>
                            <span><fmt:formatNumber value="${subtotal}" type="currency" currencyCode="VND"/></span>
                        </div>
                        <div class="d-flex justify-content-between mt-2 text-muted">
                            <span>Shipping</span>
                            <span>Calculated at next step</span>
                        </div>
                        <hr>
                        <div class="d-flex justify-content-between fw-bold fs-5">
                            <span>Total</span>
                            <span><fmt:formatNumber value="${subtotal}" type="currency" currencyCode="VND"/></span>
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