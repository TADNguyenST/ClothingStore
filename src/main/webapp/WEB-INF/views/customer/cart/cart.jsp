<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<c:set var="pageTitle" value="Shopping Cart" scope="request"/>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<style>
    .toast-container {
        position: fixed;
        bottom: 20px;
        right: 20px;
        z-index: 1050;
    }
    .cart-item-img {
        width: 100px;
        height: 120px;
        object-fit: cover;
    }
    .quantity-input {
        width: 70px;
    }
    .cart-error {
        color: red;
        font-weight: 500;
        margin-bottom: 10px;
    }
    .cart-total-updating {
        opacity: 0.5;
        pointer-events: none;
    }
    .cart-overlay {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0, 0, 0, 0.1);
        z-index: 1000;
        display: none;
    }
    .cart-overlay.active {
        display: block;
    }
</style>

<div class="container my-5">
    <div class="row">
        <div class="col-12">
            <h2 class="mb-4">Your Shopping Cart</h2>
            <c:if test="${not empty errorMessage}">
                <div class="cart-error">${errorMessage}</div>
            </c:if>
        </div>
    </div>

    <div class="toast-container">
        <div class="toast align-items-center text-white bg-success border-0" role="alert" aria-live="assertive" aria-atomic="true" id="successToast" style="display: none;">
            <div class="d-flex"><div class="toast-body" id="successToastBody"></div><button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button></div>
        </div>
        <div class="toast align-items-center text-white bg-danger border-0" role="alert" aria-live="assertive" aria-atomic="true" id="errorToast" style="display: none;">
            <div class="d-flex"><div class="toast-body" id="errorToastBody"></div><button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button></div>
        </div>
    </div>

    <div class="cart-overlay"></div>

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
                <c:forEach var="item" items="${cartItems}" varStatus="loop">
                    <div class="card mb-3" id="cartItem-${item.cartItemId}">
                        <div class="card-body">
                            <div class="d-flex align-items-center">
                                <img src="${not empty item.productImageUrl ? item.productImageUrl : 'https://placehold.co/100x120/eee/333?text=Image'}" class="img-fluid rounded cart-item-img" alt="${item.productName}">
                                <div class="ms-3 flex-grow-1">
                                    <h5 class="mb-1">${item.productName}</h5>
                                    <p class="text-muted small mb-1">Size: ${item.size} / Color: ${item.color}</p>
                                    <p class="fw-bold mb-0" id="unitPrice-${item.cartItemId}"><fmt:formatNumber value="${item.unitPrice}" type="currency" currencyCode="VND"/></p>
                                    <p class="fw-bold mb-0" id="totalPrice-${item.cartItemId}"><fmt:formatNumber value="${item.totalPrice}" type="currency" currencyCode="VND"/></p>
                                </div>
                                <div class="text-end" style="min-width: 150px;">
                                    <form class="d-flex justify-content-end align-items-center mb-2 update-quantity-form" data-cart-item-id="${item.cartItemId}" data-variant-id="${item.variantId}">
                                        <input type="hidden" name="action" value="update">
                                        <input type="hidden" name="cartItemId" value="${item.cartItemId}">
                                        <input type="number" name="quantity" class="form-control form-control-sm quantity-input" value="${item.quantity}" min="1" max="${productDAO.getAvailableQuantityByVariantId(item.variantId) > 0 ? productDAO.getAvailableQuantityByVariantId(item.variantId) : 1}" onchange="validateQuantity(this, ${item.cartItemId}, ${productDAO.getAvailableQuantityByVariantId(item.variantId)})">
                                        <button type="button" class="btn btn-sm btn-light ms-2" onclick="updateQuantity(${item.cartItemId}, ${item.variantId})" title="Update Quantity"><i class="fas fa-sync-alt"></i></button>
                                    </form>
                                    <button class="btn btn-link text-danger p-0 remove-item-btn" data-cart-item-id="${item.cartItemId}" data-bs-toggle="modal" data-bs-target="#removeItemModal">Remove</button>
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
                            <span id="subtotal"><fmt:formatNumber value="${subtotal}" type="currency" currencyCode="VND"/></span>
                        </div>
                        <div class="d-flex justify-content-between mt-2 text-muted">
                            <span>Shipping</span>
                            <span>Calculated at next step</span>
                        </div>
                        <hr>
                        <div class="d-flex justify-content-between fw-bold fs-5">
                            <span>Total</span>
                            <span id="total"><fmt:formatNumber value="${subtotal}" type="currency" currencyCode="VND"/></span>
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

<div class="modal fade" id="removeItemModal" tabindex="-1" aria-labelledby="removeItemModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="removeItemModalLabel">Confirm Removal</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                Are you sure you want to remove this item from your cart?
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-danger" id="confirmRemoveBtn">Remove</button>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-0pUGZvbkm6XF6gxjEnlmuGrJXVbNuzT9qBBavbLwCsOGabYfZo0T0to5eqruptLy" crossorigin="anonymous"></script>
<script>
                                            document.addEventListener('DOMContentLoaded', function () {
                                                var toastSuccess = new bootstrap.Toast(document.getElementById('successToast'), {delay: 3000});
                                                var toastError = new bootstrap.Toast(document.getElementById('errorToast'), {delay: 3000});
                                                var cartOverlay = document.querySelector('.cart-overlay');

                                                function showToast(message, isSuccess) {
                                                    var toast = isSuccess ? toastSuccess : toastError;
                                                    var toastBody = document.getElementById(isSuccess ? 'successToastBody' : 'errorToastBody');
                                                    toastBody.textContent = message;
                                                    toast.show();
                                                }

                                                function showOverlay() {
                                                    if (cartOverlay)
                                                        cartOverlay.classList.add('active');
                                                }

                                                function hideOverlay() {
                                                    if (cartOverlay)
                                                        cartOverlay.classList.remove('active');
                                                }

                                                function validateQuantity(input, cartItemId, maxQuantity) {
                                                    var quantity = parseInt(input.value);
                                                    console.log('Validating quantity:', quantity, 'for cartItemId:', cartItemId, 'max:', maxQuantity); // Debug
                                                    if (isNaN(quantity) || quantity > maxQuantity) {
                                                        showToast('Requested quantity exceeds available stock: ' + maxQuantity, false);
                                                        input.value = maxQuantity > 0 ? maxQuantity : 1;
                                                    } else if (quantity < 1) {
                                                        showToast('Quantity must be at least 1.', false);
                                                        input.value = 1;
                                                    }
                                                }

                                                function updateQuantity(cartItemId, variantId) {
                                                    var form = document.querySelector(`.update-quantity-form[data-cart-item-id="${cartItemId}"]`);
                                                    if (!form) {
                                                        console.error('Form not found for cartItemId:', cartItemId); // Debug
                                                        return;
                                                    }
                                                    var quantityInput = form.querySelector('input[name="quantity"]');
                                                    var quantity = parseInt(quantityInput.value);
                                                    var maxQuantity = parseInt(quantityInput.getAttribute('max'));

                                                    console.log('Updating quantity for cartItemId:', cartItemId, 'with quantity:', quantity, 'max:', maxQuantity); // Debug
                                                    if (isNaN(quantity) || quantity > maxQuantity) {
                                                        showToast('Requested quantity exceeds available stock: ' + maxQuantity, false);
                                                        quantityInput.value = maxQuantity > 0 ? maxQuantity : 1;
                                                        return;
                                                    } else if (quantity < 1) {
                                                        showToast('Quantity must be at least 1.', false);
                                                        quantityInput.value = 1;
                                                        return;
                                                    }

                                                    var formData = new FormData(form);
                                                    showOverlay(); // Hiển thị overlay
                                                    fetch('${pageContext.request.contextPath}/customer/cart', {
                                                        method: 'POST',
                                                        body: new URLSearchParams(formData),
                                                        headers: {
                                                            'Content-Type': 'application/x-www-form-urlencoded',
                                                            'Accept': 'application/json'
                                                        }
                                                    })
                                                            .then(response => {
                                                                if (!response.ok)
                                                                    throw new Error('Network response was not ok: ' + response.statusText);
                                                                return response.json();
                                                            })
                                                            .then(result => {
                                                                console.log('Update response:', result); // Debug
                                                                if (result.success) {
                                                                    var data = result.data;
                                                                    if (!data || !data.unitPrice || !data.subtotal) {
                                                                        console.error('Missing data in response:', data); // Debug
                                                                        showToast('Invalid response data.', false);
                                                                        return;
                                                                    }
                                                                    var unitPrice = parseFloat(data.unitPrice);
                                                                    var totalPrice = unitPrice * quantity;
                                                                    document.getElementById('unitPrice-' + cartItemId).textContent = new Intl.NumberFormat('vi-VN', {style: 'currency', currency: 'VND'}).format(unitPrice);
                                                                    document.getElementById('totalPrice-' + cartItemId).textContent = new Intl.NumberFormat('vi-VN', {style: 'currency', currency: 'VND'}).format(totalPrice);
                                                                    document.getElementById('subtotal').textContent = new Intl.NumberFormat('vi-VN', {style: 'currency', currency: 'VND'}).format(data.subtotal);
                                                                    document.getElementById('total').textContent = new Intl.NumberFormat('vi-VN', {style: 'currency', currency: 'VND'}).format(data.subtotal);
                                                                    showToast(result.message, true);
                                                                    updateCartCount(); // Cập nhật số lượng giỏ hàng
                                                                } else {
                                                                    showToast(result.message || 'Failed to update quantity.', false);
                                                                    quantityInput.value = parseInt('${item.quantity}'); // Reset
                                                                }
                                                                hideOverlay(); // Ẩn overlay
                                                            })
                                                            .catch(error => {
                                                                console.error('Error updating quantity:', error);
                                                                showToast('An error occurred while updating quantity: ' + error.message, false);
                                                                quantityInput.value = parseInt('${item.quantity}'); // Reset
                                                                hideOverlay(); // Ẩn overlay
                                                            });
                                                }

                                                var removeItemId = null;
                                                document.querySelectorAll('.remove-item-btn').forEach(function (btn) {
                                                    btn.addEventListener('click', function () {
                                                        removeItemId = btn.getAttribute('data-cart-item-id');
                                                    });
                                                });

                                                document.getElementById('confirmRemoveBtn').addEventListener('click', function () {
                                                    if (removeItemId) {
                                                        var cartItemElement = document.getElementById('cartItem-' + removeItemId);
                                                        showOverlay(); // Hiển thị overlay
                                                        fetch('${pageContext.request.contextPath}/customer/cart', {
                                                            method: 'POST',
                                                            body: new URLSearchParams({action: 'remove', cartItemId: removeItemId}),
                                                            headers: {
                                                                'Content-Type': 'application/x-www-form-urlencoded',
                                                                'Accept': 'application/json'
                                                            }
                                                        })
                                                                .then(response => {
                                                                    if (!response.ok)
                                                                        throw new Error('Network response was not ok: ' + response.statusText);
                                                                    return response.json();
                                                                })
                                                                .then(result => {
                                                                    if (result.success) {
                                                                        if (cartItemElement)
                                                                            cartItemElement.remove();
                                                                        document.getElementById('subtotal').textContent = new Intl.NumberFormat('vi-VN', {style: 'currency', currency: 'VND'}).format(result.data.subtotal);
                                                                        document.getElementById('total').textContent = new Intl.NumberFormat('vi-VN', {style: 'currency', currency: 'VND'}).format(result.data.subtotal);
                                                                        showToast(result.message, true);
                                                                        if (document.querySelectorAll('.card.mb-3').length === 0) {
                                                                            window.location.href = '${pageContext.request.contextPath}/customer/cart'; // Reload trang nếu giỏ hàng trống
                                                                        }
                                                                    } else {
                                                                        showToast(result.message || 'Failed to remove item.', false);
                                                                    }
                                                                    hideOverlay(); // Ẩn overlay
                                                                })
                                                                .catch(error => {
                                                                    console.error('Error removing item:', error);
                                                                    showToast('An error occurred while removing item: ' + error.message, false);
                                                                    hideOverlay(); // Ẩn overlay
                                                                });
                                                        bootstrap.Modal.getInstance(document.getElementById('removeItemModal')).hide();
                                                    }
                                                });
                                            });
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />