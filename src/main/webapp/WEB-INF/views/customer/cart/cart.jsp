<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp" />

<style>
    /* ===== BLUE THEME ===== */
    :root{
        --primary:#1e3a8a;      /* navy blue */
        --primary-2:#3b82f6;    /* blue accent */
        --bg:#f0f6ff;           /* very light blue background */
        --card:#ffffff;
        --border:#d8e4ff;
        --shadow:0 10px 30px rgba(30,58,138,.08);
        --danger:#dc2626;
    }
    body{
        font-family:'Poppins',sans-serif;
        background:var(--bg)
    }
    .cart-wrap{
        padding:32px 0
    }
    .title-bar{
        font-weight:800;
        font-size:28px;
        color:#fff;
        background:var(--primary);
        border-radius:12px;
        padding:14px 18px;
        margin-bottom:18px;
        box-shadow:var(--shadow)
    }
    .card{
        background:var(--card);
        border:1px solid var(--border);
        border-radius:16px;
        box-shadow:var(--shadow)
    }
    .select-all{
        display:flex;
        align-items:center;
        gap:12px;
        background:#f3f8ff;
        border:1px solid var(--border);
        padding:14px 16px;
        border-radius:12px
    }
    .cart-item{
        border:1px solid var(--border);
        border-radius:16px;
        padding:16px;
        margin-top:14px;
        display:flex;
        gap:16px;
        align-items:center;
        background:var(--card);
        position:relative;
        transition:box-shadow .2s ease
    }
    .cart-item.selected{
        box-shadow:0 0 0 3px rgba(59,130,246,.2)
    }
    .thumb{
        width:110px;
        height:110px;
        border-radius:12px;
        object-fit:cover;
        flex:0 0 110px
    }
    .item-main{
        flex:1
    }
    .name{
        font-weight:700;
        color:var(--primary);
        margin:3px 0;
        text-decoration:none
    }
    .name:hover{
        color:var(--primary-2)
    }
    .meta{
        color:#64748b;
        font-size:13px
    }
    .price{
        font-weight:800;
        color:var(--primary)
    }
    .remove-btn{
        background:#eef4ff;
        border:1px solid var(--border);
        border-radius:12px;
        padding:10px 16px;
        color:var(--primary);
        font-weight:700
    }
    .remove-btn:hover{
        background:#e2edff
    }
    .qty{
        width:90px
    }

    /* Summary */
    .summary{
        position:sticky;
        top:18px
    }
    .summary .card{
        padding:18px
    }
    .summary h5{
        font-weight:800;
        color:var(--primary)
    }
    .row-line{
        display:flex;
        justify-content:space-between;
        margin:8px 0;
        color:#334155
    }
    .total{
        font-size:20px;
        font-weight:900;
        color:var(--primary)
    }
    .checkout-btn{
        width:100%;
        background:linear-gradient(90deg,var(--primary),var(--primary-2));
        border:0;
        color:#fff;
        font-weight:800;
        padding:12px 18px;
        border-radius:12px
    }
    .toolbar{
        display:flex;
        gap:10px;
        margin-top:16px
    }

    /* Remove/Clear animation */
    .removing{
        opacity:.2;
        transform:translateY(-6px);
        transition:opacity .25s ease, transform .25s ease
    }

    @media (max-width: 991px){
        .summary{
            position:static;
            margin-top:18px
        }
    }
</style>

<div class="container cart-wrap">
    <div class="title-bar">
        Cart Items (<span id="titleCount">0</span>)
    </div>

    <c:if test="${empty cartItems}">
        <div class="text-center p-5 border rounded bg-light" style="border-style: dashed!important; color:#1e3a8a;">
            <i class="fas fa-shopping-bag fa-2x mb-3"></i>
            <p class="mb-3">Your cart is empty.</p>
            <a href="${pageContext.request.contextPath}/home" class="btn btn-outline-primary">Continue Shopping</a>
        </div>
    </c:if>

    <c:if test="${not empty cartItems}">
        <div class="row g-4">
            <!-- LEFT: Items -->
            <div class="col-lg-8">
                <div class="card p-3">
                    <div class="select-all">
                        <input type="checkbox" id="checkAll">
                        <label for="checkAll" class="m-0">Select All</label>
                    </div>

                    <div id="itemsBox">
                        <c:forEach var="item" items="${cartItems}">
                            <div class="cart-item" data-row="cart-item"
                                 data-cart-item-id="${item.cartItemId}"
                                 data-unit-price="${item.unitPrice}"
                                 data-quantity="${item.quantity}">
                                <div>
                                    <input type="checkbox" class="item-check">
                                </div>

                                <img class="thumb"
                                     src="${item.imageUrl}"
                                     alt="${item.productName}"
                                     onerror="this.src='https://placehold.co/110x110/eee/333?text=No+Image'">

                                <div class="item-main">
                                    <a class="name" href="${pageContext.request.contextPath}/ProductList/detail?productId=${item.productId}">
                                        ${item.productName}
                                    </a>
                                    <div class="meta">
                                        Size: <strong>${item.size}</strong> &nbsp;|&nbsp; Color: <strong>${item.color}</strong>
                                    </div>
                                    <div class="meta">
                                        Stock: <span class="${item.availableStock <= 5 ? 'text-danger' : ''}">
                                            ${item.availableStock}
                                        </span>
                                    </div>

                                    <div class="d-flex align-items-center gap-3 mt-2">
                                        <div class="price">
                                            <span class="unit-price" data-raw="${item.unitPrice}">${item.unitPrice}</span>
                                        </div>

                                        <div>
                                            <input type="number"
                                                   min="1" max="${item.availableStock}" value="${item.quantity}"
                                                   class="form-control qty quantity-input"
                                                   data-cart-item-id="${item.cartItemId}"
                                                   data-max-stock="${item.availableStock}"
                                                   data-csrf-token="${sessionScope.csrfToken}">
                                        </div>

                                        <div class="ms-auto fw-bold">
                                            <span class="line-total" data-line-total="0">0</span>
                                        </div>

                                        <form class="remove-form ms-2"
                                              action="${pageContext.request.contextPath}/customer/cart"
                                              method="post"
                                              data-csrf-token="${sessionScope.csrfToken}">
                                            <input type="hidden" name="action" value="remove">
                                            <input type="hidden" name="cartItemId" value="${item.cartItemId}">
                                            <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                            <button type="submit" class="remove-btn">REMOVE</button>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>

                    <div class="toolbar">
                        <a href="${pageContext.request.contextPath}/home" class="btn btn-outline-secondary">
                            ← Continue Shopping
                        </a>
                        <button id="clearCartBtn" type="button" class="btn btn-outline-danger">
                            Clear Cart
                        </button>
                    </div>
                </div>
            </div>

            <!-- RIGHT: Summary -->
            <div class="col-lg-4">
                <div class="summary">
                    <div class="card">
                        <h5 class="mb-3">Order Summary</h5>

                        <div class="row-line"><span>Total Items</span><span id="sumTotalItems">0</span></div>
                        <div class="row-line"><span>Selected Items</span><span id="sumSelectedItems">0</span></div>
                        <div class="row-line"><span>Subtotal</span><span id="sumSubtotal">0đ</span></div>

                        <hr>
                        <div class="row-line total">
                            <span>Selected Total</span>
                            <span id="sumSelectedTotal">0đ</span>
                        </div>

                        <button class="checkout-btn mt-3" onclick="location.href = '${pageContext.request.contextPath}/customer/checkout'">
                            PROCEED TO CHECKOUT
                        </button>

                    </div>
                </div>
            </div>
        </div>
    </c:if>
</div>

<!-- Toast -->
<div class="toast-container position-fixed bottom-0 end-0 p-3"></div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
                            (function () {
                                /* ===== Helpers ===== */
                                function showToast(message, isSuccess) {
                                    if (typeof isSuccess === 'undefined')
                                        isSuccess = true;
                                    var c = document.querySelector('.toast-container');
                                    var html = '<div class="toast align-items-center text-white ' + (isSuccess ? 'bg-success' : 'bg-danger') + ' border-0" role="alert" aria-live="assertive" aria-atomic="true">'
                                            + '<div class="d-flex"><div class="toast-body">' + (message || '') + '</div>'
                                            + '<button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button></div></div>';
                                    c.insertAdjacentHTML('beforeend', html);
                                    new bootstrap.Toast(c.lastElementChild, {delay: 3000}).show();
                                }
                                function formatVND(n) {
                                    var x = Math.round(Number(n) || 0).toString();
                                    return x.replace(/\B(?=(\d{3})+(?!\d))/g, '.') + 'đ';
                                }
                                function closestRow(el) {
                                    while (el && el.nodeType === 1) {
                                        if (el.getAttribute('data-row') === 'cart-item')
                                            return el;
                                        el = el.parentNode;
                                    }
                                    return null;
                                }
                                function updateCartBadgeIfPresent(n) {
                                    if (typeof window.updateCartCount === 'function' && typeof n !== 'undefined') {
                                        window.updateCartCount(n);
                                    }
                                }
                                function fetchCartCountAndUpdateBadge() {
                                    return fetch('${pageContext.request.contextPath}/customer/cart/count', {headers: {'Cache-Control': 'no-cache'}})
                                            .then(function (r) {
                                                return r.json();
                                            })
                                            .then(function (d) {
                                                updateCartBadgeIfPresent(d.count);
                                                return d.count;
                                            })
                                            .catch(function () {
                                                updateCartBadgeIfPresent(0);
                                                return 0;
                                            });
                                }

                                /* ===== Totals ===== */
                                function recalcRow(row) {
                                    var unit = Number(row.getAttribute('data-unit-price')) || 0;
                                    var qtyInput = row.querySelector('.quantity-input');
                                    var qty = qtyInput ? Number(qtyInput.value) || 0 : Number(row.getAttribute('data-quantity')) || 0;
                                    var total = unit * qty;
                                    row.setAttribute('data-quantity', String(qty));
                                    var span = row.querySelector('.line-total');
                                    if (span) {
                                        span.setAttribute('data-line-total', String(total));
                                        span.textContent = formatVND(total);
                                    }
                                    return total;
                                }
                                function recalcSummary() {
                                    var rows = document.querySelectorAll('div[data-row="cart-item"]');
                                    var subtotal = 0, selectedTotal = 0, selectedCount = 0;
                                    for (var i = 0; i < rows.length; i++) {
                                        var row = rows[i];
                                        var lt = row.querySelector('.line-total');
                                        var line = lt ? Number(lt.getAttribute('data-line-total')) || 0 : recalcRow(row);
                                        subtotal += line;
                                        var chk = row.querySelector('.item-check');
                                        if (chk && chk.checked) {
                                            selectedTotal += line;
                                            selectedCount++;
                                        }
                                    }
                                    var totalItems = rows.length;
                                    document.getElementById('titleCount').textContent = totalItems;
                                    document.getElementById('sumTotalItems').textContent = totalItems;
                                    document.getElementById('sumSelectedItems').textContent = selectedCount;
                                    document.getElementById('sumSubtotal').textContent = formatVND(subtotal);
                                    document.getElementById('sumSelectedTotal').textContent = formatVND(selectedTotal);

                                    var checkAll = document.getElementById('checkAll');
                                    if (totalItems === 0) {
                                        checkAll.checked = false;
                                        checkAll.indeterminate = false;
                                    } else {
                                        if (selectedCount === 0) {
                                            checkAll.checked = false;
                                            checkAll.indeterminate = false;
                                        } else if (selectedCount === totalItems) {
                                            checkAll.checked = true;
                                            checkAll.indeterminate = false;
                                        } else {
                                            checkAll.indeterminate = true;
                                        }
                                    }
                                }

                                /* ===== Bindings ===== */
                                function bindFormatting() {
                                    var ups = document.querySelectorAll('.unit-price');
                                    for (var i = 0; i < ups.length; i++) {
                                        var raw = ups[i].getAttribute('data-raw');
                                        ups[i].textContent = formatVND(raw);
                                        var row = closestRow(ups[i]);
                                        if (row)
                                            row.setAttribute('data-unit-price', String(Number(raw) || 0));
                                    }
                                    var rows = document.querySelectorAll('div[data-row="cart-item"]');
                                    for (var j = 0; j < rows.length; j++) {
                                        recalcRow(rows[j]);
                                    }
                                    recalcSummary();
                                }

                                function bindQtyChange() {
                                    var inputs = document.querySelectorAll('.quantity-input');
                                    for (var i = 0; i < inputs.length; i++) {
                                        (function (input) {
                                            input.addEventListener('change', function () {
                                                var qty = parseInt(input.value, 10);
                                                var max = parseInt(input.getAttribute('data-max-stock'), 10);
                                                var token = input.getAttribute('data-csrf-token');
                                                var id = input.getAttribute('data-cart-item-id');

                                                if (!token) {
                                                    showToast('CSRF token is missing.', false);
                                                    return;
                                                }
                                                if (isNaN(qty) || qty < 1) {
                                                    qty = 1;
                                                    input.value = 1;
                                                }
                                                if (!isNaN(max) && qty > max) {
                                                    qty = max;
                                                    input.value = max;
                                                    showToast('Quantity exceeds available stock.', false);
                                                }

                                                var body = new URLSearchParams();
                                                body.append('action', 'update');
                                                body.append('cartItemId', id);
                                                body.append('quantity', String(qty));
                                                body.append('csrfToken', token);

                                                fetch('${pageContext.request.contextPath}/customer/cart', {
                                                    method: 'POST', body: body,
                                                    headers: {'Content-Type': 'application/x-www-form-urlencoded', 'Accept': 'application/json', 'Cache-Control': 'no-cache'}
                                                })
                                                        .then(function (res) {
                                                            if (!res.ok)
                                                                throw new Error('HTTP ' + res.status);
                                                            return res.json();
                                                        })
                                                        .then(function (result) {
                                                            if (result.message)
                                                                showToast(result.message, !!result.success);
                                                            if (result.success) {
                                                                input.defaultValue = String(qty);
                                                                var row = closestRow(input);
                                                                if (row)
                                                                    recalcRow(row);
                                                                recalcSummary();
                                                                updateCartBadgeIfPresent(result.cartCount);
                                                            } else {
                                                                input.value = input.defaultValue || '1';
                                                            }
                                                        })
                                                        .catch(function (err) {
                                                            console.error(err);
                                                            showToast('Network error. Please try again.', false);
                                                            input.value = input.defaultValue || '1';
                                                        });
                                            });
                                        })(inputs[i]);
                                    }
                                }

                                function bindChecks() {
                                    var checkAll = document.getElementById('checkAll');
                                    var itemsBox = document.getElementById('itemsBox');

                                    checkAll.addEventListener('change', function () {
                                        var checks = itemsBox.querySelectorAll('.item-check');
                                        for (var i = 0; i < checks.length; i++) {
                                            checks[i].checked = checkAll.checked;
                                            var row = closestRow(checks[i]);
                                            if (row) {
                                                checks[i].checked ? row.classList.add('selected') : row.classList.remove('selected');
                                            }
                                        }
                                        recalcSummary();
                                    });

                                    itemsBox.addEventListener('change', function (e) {
                                        if (e.target && e.target.classList.contains('item-check')) {
                                            var row = closestRow(e.target);
                                            if (row) {
                                                row.classList.toggle('selected', e.target.checked);
                                            }
                                            recalcSummary();
                                        }
                                    });
                                }

                                function bindRemove() {
                                    var forms = document.querySelectorAll('form.remove-form');
                                    for (var i = 0; i < forms.length; i++) {
                                        (function (form) {
                                            form.addEventListener('submit', function (e) {
                                                e.preventDefault();
                                                var fd = new FormData(form);
                                                if (!fd.get('csrfToken')) {
                                                    showToast('CSRF token is missing.', false);
                                                    return;
                                                }
                                                if (!confirm('Are you sure you want to remove this item from your cart?'))
                                                    return;

                                                var row = closestRow(form);
                                                if (row)
                                                    row.classList.add('removing');

                                                fetch('${pageContext.request.contextPath}/customer/cart', {
                                                    method: 'POST', body: new URLSearchParams(fd),
                                                    headers: {'Content-Type': 'application/x-www-form-urlencoded', 'Accept': 'application/json', 'Cache-Control': 'no-cache'}
                                                })
                                                        .then(function (res) {
                                                            if (!res.ok)
                                                                throw new Error('HTTP ' + res.status);
                                                            return res.json();
                                                        })
                                                        .then(function (result) {
                                                            if (result.message)
                                                                showToast(result.message, !!result.success);
                                                            if (result.success) {
                                                                if (row && row.parentNode)
                                                                    row.parentNode.removeChild(row);
                                                                recalcSummary();
                                                                return fetchCartCountAndUpdateBadge();
                                                            }
                                                        })
                                                        .catch(function (err) {
                                                            console.error(err);
                                                            showToast('Network error. Please try again.', false);
                                                        });
                                            });
                                        })(forms[i]);
                                    }
                                }

                                function bindClearCart() {
                                    var btn = document.getElementById('clearCartBtn');
                                    if (!btn)
                                        return;

                                    btn.addEventListener('click', function () {
                                        var rows = document.querySelectorAll('div[data-row="cart-item"]');
                                        if (rows.length === 0)
                                            return;
                                        if (!confirm('Clear all items from your cart?'))
                                            return;

                                        var tokenEl = document.querySelector('form.remove-form input[name="csrfToken"]');
                                        var token = tokenEl ? tokenEl.value : null;
                                        if (!token) {
                                            showToast('CSRF token is missing.', false);
                                            return;
                                        }

                                        // UI state
                                        btn.disabled = true;
                                        var oldText = btn.textContent;
                                        btn.textContent = 'Clearing...';

                                        var ids = [];
                                        for (var i = 0; i < rows.length; i++) {
                                            ids.push(rows[i].getAttribute('data-cart-item-id'));
                                            rows[i].classList.add('removing');
                                        }

                                        // Remove all (parallel), then update UI once
                                        var promises = ids.map(function (id) {
                                            var body = new URLSearchParams();
                                            body.append('action', 'remove');
                                            body.append('cartItemId', id);
                                            body.append('csrfToken', token);
                                            return fetch('${pageContext.request.contextPath}/customer/cart', {
                                                method: 'POST', body: body,
                                                headers: {'Content-Type': 'application/x-www-form-urlencoded', 'Accept': 'application/json', 'Cache-Control': 'no-cache'}
                                            }).then(function (r) {
                                                return r.json();
                                            }).catch(function () {
                                                return {success: false};
                                            });
                                        });

                                        Promise.all(promises).then(function () {
                                            // Remove DOM rows
                                            for (var i = 0; i < ids.length; i++) {
                                                var row = document.querySelector('div[data-row="cart-item"][data-cart-item-id="' + ids[i] + '"]');
                                                if (row && row.parentNode)
                                                    row.parentNode.removeChild(row);
                                            }
                                            recalcSummary();

                                            // Empty placeholder
                                            if (document.querySelectorAll('div[data-row="cart-item"]').length === 0) {
                                                var listCard = document.querySelector('.col-lg-8 .card');
                                                var empty = document.createElement('div');
                                                empty.className = 'card p-4 text-center mt-3';
                                                empty.innerHTML = '<p class="mb-0">Your cart is empty.</p>';
                                                listCard.appendChild(empty);
                                            }

                                            // Update badge accurately
                                            return fetchCartCountAndUpdateBadge();
                                        }).finally(function () {
                                            btn.disabled = false;
                                            btn.textContent = oldText;
                                            showToast('Cart has been cleared.', true);
                                        });
                                    });
                                }

                                /* ===== Init ===== */
                                document.addEventListener('DOMContentLoaded', function () {
                                    bindFormatting();
                                    bindQtyChange();
                                    bindChecks();
                                    bindRemove();
                                    bindClearCart();
                                });
                            })();
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
