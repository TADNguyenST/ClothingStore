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
                                    <p class="fw-bold mb-0" id="totalPrice-${item.cartItemId}"><fmt:formatNumber value="${item.unitPrice * item.quantity}" type="currency" currencyCode="VND"/></p>
                                </div>
                                <div class="text-end" style="min-width: 150px;">
                                    <form class="d-flex justify-content-end align-items-center mb-2 update-quantity-form" data-cart-item-id="${item.cartItemId}" data-variant-id="${item.variantId}">
                                        <input type="hidden" name="action" value="update">
                                        <input type="hidden" name="cartItemId" value="${item.cartItemId}">
                                        <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                        <input type="number" name="quantity" class="form-control form-control-sm quantity-input" value="${item.quantity}" min="1" max="${availableQuantities[item.variantId]}">
                                        <button type="button" class="btn btn-sm btn-light ms-2 update-quantity-btn" data-cart-item-id="${item.cartItemId}" data-variant-id="${item.variantId}" title="Update Quantity"><i class="fas fa-sync-alt"></i></button>
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
                        <p class="text-muted small">* Shipping fee and vouchers will be applied at checkout.</p>
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
        console.log('Cart page loaded');

        // Initialize Bootstrap toasts
        const toastSuccess = new bootstrap.Toast(document.getElementById('successToast'), {delay: 3000});
        const toastError = new bootstrap.Toast(document.getElementById('errorToast'), {delay: 3000});
        const cartOverlay = document.querySelector('.cart-overlay');

        // Toast helper function
        function showToast(message, isSuccess) {
            const toast = isSuccess ? toastSuccess : toastError;
            const toastBody = document.getElementById(isSuccess ? 'successToastBody' : 'errorToastBody');
            toastBody.textContent = message;
            toast.show();
        }

        // Overlay helper functions
        function showOverlay() {
            if (cartOverlay) {
                cartOverlay.classList.add('active');
            }
        }

        function hideOverlay() {
            if (cartOverlay) {
                cartOverlay.classList.remove('active');
            }
        }

        // Currency formatting helper
        function formatCurrency(amount) {
            return new Intl.NumberFormat('vi-VN', {
                style: 'currency',
                currency: 'VND'
            }).format(amount);
        }

        // Update quantity function
        function updateQuantity(cartItemId, variantId) {
            console.log('Updating quantity for cartItemId:', cartItemId, 'variantId:', variantId);

            const form = document.querySelector(`form[data-cart-item-id="${cartItemId}"]`);
            if (!form) {
                console.error('Form not found for cartItemId:', cartItemId);
                showToast('Form not found', false);
                return;
            }

            const quantityInput = form.querySelector('input[name="quantity"]');
            const quantity = parseInt(quantityInput.value);
            const maxQuantity = parseInt(quantityInput.getAttribute('max'));

            console.log('Quantity:', quantity, 'MaxQuantity:', maxQuantity);

            if (isNaN(quantity) || quantity < 1) {
                showToast('Quantity must be at least 1.', false);
                quantityInput.value = 1;
                return;
            }

            if (quantity > maxQuantity) {
                showToast(`Requested quantity exceeds available stock: ${maxQuantity}`, false);
                quantityInput.value = maxQuantity > 0 ? maxQuantity : 1;
                return;
            }

            const formData = new FormData(form);
            showOverlay();

            // Show loading state on the update button
            const updateBtn = form.querySelector('.update-quantity-btn');
            if (updateBtn) {
                updateBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i>';
                updateBtn.disabled = true;
            }

            fetch('${pageContext.request.contextPath}/customer/cart', {
                method: 'POST',
                body: new URLSearchParams(formData),
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                    'Accept': 'application/json'
                }
            })
                    .then(response => {
                        if (!response.ok) {
                            throw new Error(`HTTP error! status: ${response.status}`);
                        }
                        return response.json();
                    })
                    .then(result => {
                        console.log('Update response:', result);
                        if (result.success) {
                            const data = result.data;
                            // Update UI elements
                            const unitPriceElement = document.getElementById(`unitPrice-${cartItemId}`);
                            const totalPriceElement = document.getElementById(`totalPrice-${cartItemId}`);
                            const subtotalElement = document.getElementById('subtotal');
                            const cartCountElement = document.getElementById('cartCount');

                            if (unitPriceElement && data.unitPrice) {
                                unitPriceElement.textContent = formatCurrency(data.unitPrice);
                            }

                            if (totalPriceElement && data.unitPrice) {
                                totalPriceElement.textContent = formatCurrency(data.unitPrice * quantity);
                            }

                            if (subtotalElement && data.subtotal) {
                                subtotalElement.textContent = formatCurrency(data.subtotal);
                            }

                            if (cartCountElement && data.count !== undefined) {
                                cartCountElement.textContent = data.count;
                            }

                            showToast(result.message, true);
                            // Update cart count in header
                            if (window.updateCartCount) {
                                window.updateCartCount();
                            }
                        } else {
                            showToast(result.message || 'Failed to update quantity.', false);
                        }
                    })
                    .catch(error => {
                        console.error('Error updating quantity:', error);
                        showToast('Error updating quantity: ' + error.message, false);
                    })
                    .finally(() => {
                        hideOverlay();
                        // Restore update button
                        if (updateBtn) {
                            updateBtn.innerHTML = '<i class="fas fa-sync-alt"></i>';
                            updateBtn.disabled = false;
                        }
                    });
        }

        // Remove item functions
        let removeItemId = null;

        // Attach click handlers to remove buttons
        document.querySelectorAll('.remove-item-btn').forEach(function (btn) {
            btn.addEventListener('click', function () {
                removeItemId = btn.getAttribute('data-cart-item-id');
                console.log('Remove button clicked for cartItemId:', removeItemId);
            });
        });

        // Confirm remove button handler
        const confirmRemoveBtn = document.getElementById('confirmRemoveBtn');
        if (confirmRemoveBtn) {
            confirmRemoveBtn.addEventListener('click', function () {
                console.log('Confirm remove clicked, removeItemId:', removeItemId);

                if (!removeItemId) {
                    showToast('No item selected for removal.', false);
                    return;
                }

                const cartItemElement = document.getElementById(`cartItem-${removeItemId}`);
                console.log('Cart item element:', cartItemElement);

                if (!cartItemElement) {
                    showToast('Item element not found.', false);
                    return;
                }

                showOverlay();

                fetch('${pageContext.request.contextPath}/customer/cart', {
                    method: 'POST',
                    body: new URLSearchParams({
                        action: 'remove',
                        cartItemId: removeItemId,
                        csrfToken: '${sessionScope.csrfToken}'
                    }),
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                        'Accept': 'application/json'
                    }
                })
                        .then(response => {
                            if (!response.ok) {
                                throw new Error(`HTTP error! status: ${response.status}`);
                            }
                            return response.json();
                        })
                        .then(result => {
                            console.log('Remove response:', result);
                            if (result.success) {
                                // Remove item from DOM
                                cartItemElement.remove();

                                // Update totals
                                const subtotalElement = document.getElementById('subtotal');
                                const cartCountElement = document.getElementById('cartCount');

                                if (subtotalElement && result.data.subtotal !== undefined) {
                                    subtotalElement.textContent = formatCurrency(result.data.subtotal);
                                }

                                if (cartCountElement && result.data.count !== undefined) {
                                    cartCountElement.textContent = result.data.count;
                                }

                                showToast(result.message, true);

                                // Update cart count in header
                                if (window.updateCartCount) {
                                    window.updateCartCount();
                                }

                                // Check if cart is empty and show empty cart message
                                const remainingItems = document.querySelectorAll('[id^="cartItem-"]');
                                if (remainingItems.length === 0) {
                                    const container = document.querySelector('.container.my-5');
                                    if (container) {
                                        container.innerHTML = `
                                <div class="text-center p-5 border rounded bg-light">
                                    <i class="fas fa-shopping-bag fa-3x text-muted mb-3"></i>
                                    <p class="fs-4">Your cart is empty.</p>
                                    <a href="${pageContext.request.contextPath}/home" class="btn btn-primary mt-3">Continue Shopping</a>
                                </div>`;
                                    }
                                }
                            } else {
                                showToast(result.message || 'Failed to remove product.', false);
                            }
                        })
                        .catch(error => {
                            console.error('Error removing product:', error);
                            showToast('Error removing product: ' + error.message, false);
                        })
                        .finally(() => {
                            hideOverlay();
                            // Close modal
                            const modal = bootstrap.Modal.getInstance(document.getElementById('removeItemModal'));
                            if (modal) {
                                modal.hide();
                            }
                        });
            });
        }

        // Add click handlers for update quantity buttons
        document.querySelectorAll('.update-quantity-btn').forEach(btn => {
            btn.addEventListener('click', function () {
                const cartItemId = this.getAttribute('data-cart-item-id');
                const variantId = this.getAttribute('data-variant-id');
                console.log('Update button clicked for cartItemId:', cartItemId, 'variantId:', variantId);
                updateQuantity(cartItemId, variantId);
            });
        });

        // Add input event listeners for real-time validation
        document.querySelectorAll('.quantity-input').forEach(input => {
            input.addEventListener('blur', function () {
                const form = this.closest('.update-quantity-form');
                const cartItemId = form.getAttribute('data-cart-item-id');
                const variantId = form.getAttribute('data-variant-id');
                console.log('Quantity input blur for cartItemId:', cartItemId, 'variantId:', variantId);
                updateQuantity(cartItemId, variantId);
            });
        });

        console.log('Cart functionality initialized');
    });
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />