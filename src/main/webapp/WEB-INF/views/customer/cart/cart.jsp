<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp" />

<style>
    :root{
        --primary:#1e3a8a;
        --primary-2:#3b82f6;
        --bg:#f0f6ff;
        --card:#ffffff;
        --border:#d8e4ff;
        --shadow:0 10px 30px rgba(30,58,138,.08);
    }
    body{
        font-family:'Poppins',sans-serif;
        background:var(--bg)
    }
    .cart-section{
        padding:32px 0
    }
    .cart-title{
        font-size:2rem;
        font-weight:800;
        color:var(--primary);
        margin-bottom:14px
    }
    .cart-wrap{
        display:grid;
        grid-template-columns:1fr 360px;
        gap:20px
    }
    @media (max-width: 992px){
        .cart-wrap{
            grid-template-columns:1fr
        }
    }
    .card-like{
        background:#fff;
        border:1px solid var(--border);
        border-radius:16px;
        box-shadow:var(--shadow)
    }
    .cart-toolbar{
        display:flex;
        align-items:center;
        gap:12px;
        padding:14px 16px;
        border-bottom:1px solid #eef2ff
    }
    table.cart-table{
        width:100%;
        border-collapse:separate;
        border-spacing:0
    }
    table.cart-table thead th{
        background:#1e3a8a;
        color:#fff;
        font-weight:700;
        text-transform:uppercase;
        padding:12px;
        font-size:.9rem
    }
    table.cart-table tbody td{
        background:#fff;
        border-bottom:1px solid #e5e7eb;
        padding:12px;
        vertical-align:middle
    }
    tr.is-selected td{
        background:#f0f5ff
    }

    .product-img{
        width:80px;
        height:80px;
        object-fit:cover;
        border-radius:8px;
        display:block
    }
    .product-name{
        font-weight:700;
        color:#1e3a8a;
        text-decoration:none
    }
    .product-name:hover{
        color:#3b82f6
    }

    .quantity-input{
        width:80px;
        border-radius:8px
    }
    .quantity-input:focus{
        border-color:#3b82f6;
        box-shadow:0 0 5px rgba(59,130,246,.4)
    }
    .stock-info{
        color:#1e3a8a;
        font-size:.9rem
    }
    .stock-info.low{
        color:#dc2626;
        font-weight:700
    }

    .btn-pill{
        padding:.45rem 1rem;
        border-radius:999px;
        font-size:.9rem
    }
    .empty-box{
        text-align:center;
        border:2px dashed #e5e7eb;
        background:#fff;
        border-radius:12px;
        padding:2.25rem 1rem;
        color:#6b7280
    }

    .summary-card{
        padding:16px
    }
    .summary-title{
        font-weight:800;
        color:#1e3a8a;
        font-size:1.1rem;
        margin:.25rem 0 12px
    }
    .summary-row{
        display:flex;
        justify-content:space-between;
        align-items:center;
        margin:.35rem 0
    }
    .summary-row .label{
        color:#334155;
        font-size:.95rem
    }
    .summary-row .value{
        font-weight:800;
        color:#0f172a
    }
    .selected-list{
        max-height:220px;
        overflow:auto;
        border:1px solid #e5e7eb;
        border-radius:10px;
        padding:.5rem .75rem;
        background:#fff
    }
    .selected-item{
        display:flex;
        align-items:flex-start;
        gap:.5rem;
        padding:.35rem 0;
        border-bottom:1px dashed #eef2f7
    }
    .selected-item:last-child{
        border-bottom:none
    }
    .selected-item .badge{
        background:#e2e8f0;
        color:#0f172a
    }

    /* Voucher UI */
    .voucher-box .form-control{
        border-radius:10px
    }
    .voucher-box .btn{
        border-radius:10px
    }
    .voucher-applied{
        background:#f1f5ff;
        border:1px dashed var(--border);
        padding:.5rem .75rem;
        border-radius:10px
    }
    .voucher-error{
        color:#dc2626;
        font-size:.9rem
    }
</style>

<div class="container cart-section">
    <h1 class="cart-title">Your Cart</h1>

    <!-- Empty -->
    <c:if test="${empty cartItems}">
        <div class="empty-box card-like" id="emptyStateCard">
            <i class="fas fa-shopping-bag fa-2x mb-3"></i>
            <p>Your cart is empty.</p>
            <a href="${pageContext.request.contextPath}/home" class="btn btn-outline-primary btn-pill">Continue Shopping</a>
        </div>
    </c:if>

    <!-- Have items -->
    <c:if test="${not empty cartItems}">
        <div class="cart-wrap" id="cartGrid">
            <div class="card-like">
                <div class="cart-toolbar">
                    <div class="form-check">
                        <input class="form-check-input" type="checkbox" id="selectAll">
                        <label class="form-check-label" for="selectAll">
                            Select all (<span id="selectedCount">0</span>/<span id="totalCount">${cartItems.size()}</span>)
                        </label>
                    </div>
                    <div class="ms-auto">
                        <a href="${pageContext.request.contextPath}/ProductList" class="btn btn-outline-secondary btn-pill">← Continue Shopping</a>
                        <button id="clearCartBtn" type="button" class="btn btn-outline-danger btn-pill">Clear Cart</button>
                    </div>
                </div>

                <table class="cart-table">
                    <thead>
                        <tr>
                            <th style="width:54px;"></th>
                            <th>Image</th>
                            <th>Product</th>
                            <th>Size</th>
                            <th>Color</th>
                            <th>Qty</th>
                            <th>Stock</th>
                            <th>Unit Price</th>
                            <th>Total</th>
                            <th style="width:120px;">Action</th>
                        </tr>
                    </thead>
                    <tbody id="cartTbody">
                        <c:forEach var="item" items="${cartItems}">
                            <tr data-row="cart-item"
                                data-cart-item-id="${item.cartItemId}"
                                data-unit-price="${item.unitPrice}"
                                data-quantity="${item.quantity}">
                                <td>
                                    <input type="checkbox"
                                           class="form-check-input row-check"
                                           data-id="${item.cartItemId}"
                                           data-name="${item.productName}"
                                           data-size="${item.size}"
                                           data-color="${item.color}"
                                           data-qty="${item.quantity}">
                                </td>
                                <td>
                                    <img class="product-img"
                                         src="${item.imageUrl}"
                                         alt="${item.productName}"
                                         onerror="this.src='https://placehold.co/100x100/eee/333?text=No+Image';">
                                </td>
                                <td>
                                    <a class="product-name"
                                       href="${pageContext.request.contextPath}/ProductDetail?productId=${item.productId}">
                                        ${item.productName}
                                    </a>
                                </td>
                                <td>${item.size}</td>
                                <td>${item.color}</td>
                                <td>
                                    <input type="number"
                                           class="form-control quantity-input"
                                           value="${item.quantity}"
                                           min="1"
                                           max="${item.availableStock}"
                                           data-cart-item-id="${item.cartItemId}"
                                           data-csrf-token="${sessionScope.csrfToken}"
                                           data-max-stock="${item.availableStock}">
                                </td>
                                <td>
                                    <span class="stock-info ${item.availableStock <= 5 ? 'low' : ''}">
                                        ${item.availableStock} in stock
                                    </span>
                                </td>
                                <td class="unit-price-cell">
                                    <span class="money" data-raw="${item.unitPrice}">₫</span>
                                </td>
                                <td class="line-total-cell">
                                    <span class="money line-total" data-line-total="${item.totalPrice}">₫</span>
                                </td>
                                <td>
                                    <form class="remove-form"
                                          action="${pageContext.request.contextPath}/customer/cart"
                                          method="post"
                                          data-csrf-token="${sessionScope.csrfToken}">
                                        <input type="hidden" name="action" value="remove">
                                        <input type="hidden" name="cartItemId" value="${item.cartItemId}">
                                        <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                        <button type="submit" class="btn btn-outline-danger btn-pill">Remove</button>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>

            <!-- Summary -->
            <div class="card-like summary-card" id="summaryCard">
                <div class="d-flex align-items-center">
                    <i class="fas fa-receipt me-2 text-primary"></i>
                    <div class="summary-title mb-0">Order Summary</div>
                </div>

                <div class="summary-row mt-2">
                    <div class="label">Items selected</div>
                    <div class="value" id="sumItems">0</div>
                </div>
                <div class="summary-row">
                    <div class="label">Selected subtotal</div>
                    <div class="value" id="sumSelected">0đ</div>
                </div>

                <!-- Voucher -->
                <div class="voucher-box mt-3">
                    <label class="form-label mb-1">Voucher</label>
                    <div class="input-group">
                        <input id="voucherCodeInput" type="text" class="form-control" placeholder="Enter code (e.g. SALE50)">
                        <button id="applyVoucherBtn" class="btn btn-primary">Apply</button>
                        <button id="clearVoucherBtn" class="btn btn-outline-secondary d-none">Remove</button>
                    </div>

                    <!-- BỎ hẳn link public voucher -->
                    <small id="voucherStatus" class="text-muted mt-2 d-inline-block" aria-live="polite"></small>

                    <div id="voucherApplied" class="voucher-applied mt-2 d-none">
                        <div><strong id="vName"></strong> — <span class="text-muted">code:</span> <span id="vCode" class="font-monospace"></span></div>
                        <div class="text-muted">Type: <span id="vType"></span>, Value: <span id="vValue"></span></div>
                    </div>
                    <div id="voucherError" class="voucher-error mt-2 d-none"></div>

                    <!-- Ví voucher: saved vouchers -->
                    <div class="mt-3">
                        <button id="toggleWalletBtn" type="button" class="btn btn-outline-primary btn-sm">
                            <i class="fas fa-wallet me-1"></i> My saved vouchers
                        </button>
                        <div id="voucherWallet" class="mt-2 d-none">
                            <div id="voucherWalletLoading" class="text-muted small">Loading...</div>
                            <div id="voucherWalletError" class="text-danger small d-none"></div>
                            <div id="voucherWalletList" class="row g-2"></div>
                        </div>
                    </div>
                </div>

                <div class="summary-row">
                    <div class="label">Voucher discount</div>
                    <div class="value text-danger" id="sumVoucherDiscount">-0đ</div>
                </div>

                <hr/>
                <div class="summary-row">
                    <div class="label fw-bold">Payable</div>
                    <div class="value fw-bold" id="sumPayable">0đ</div>
                </div>

                <div class="mb-2 fw-semibold" style="color:#1e293b;">Selected items</div>
                <div class="selected-list" id="selectedList">
                    <div class="text-muted small">No items selected.</div>
                </div>

                <!-- Checkout -->
                <form id="checkoutForm" class="d-grid gap-2 mt-3"
                      action="${pageContext.request.contextPath}/customer/checkout"
                      method="post">
                    <input type="hidden" name="action" value="checkoutSelected">
                    <input type="hidden" name="cartItemIds" id="checkoutIds" value="">
                    <input type="hidden" name="voucherCode" id="voucherCodeHidden" value="">
                    <input type="hidden" name="selectedSubtotal" id="selectedSubtotalHidden" value="">
                    <input type="hidden" name="voucherDiscount"  id="voucherDiscountHidden"  value="">
                    <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                    <button id="checkoutBtn" type="submit" class="btn btn-primary btn-pill" disabled>
                        Proceed to Checkout
                    </button>
                    <a href="${pageContext.request.contextPath}/home" class="btn btn-outline-primary btn-pill">
                        Continue Shopping
                    </a>
                </form>
            </div>
        </div>
    </c:if>
</div>

<!-- Toast -->
<div class="toast-container position-fixed bottom-0 end-0 p-3"></div>

<script>
    (function () {
        /* ===== Helpers ===== */
        function showToast(msg, ok) {
            if (typeof ok === 'undefined')
                ok = true;
            var c = document.querySelector('.toast-container');
            var html = '<div class="toast align-items-center text-white ' + (ok ? 'bg-success' : 'bg-danger') + ' border-0" role="alert" aria-live="assertive" aria-atomic="true">'
                    + ' <div class="d-flex"><div class="toast-body">' + (msg || '') + '</div>'
                    + ' <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>'
                    + ' </div></div>';
            c.insertAdjacentHTML('beforeend', html);
            new bootstrap.Toast(c.lastElementChild, {delay: 3000}).show();
        }
        function formatVNDdot(v) {
            var n = Math.round(Number(v) || 0).toString();
            return n.replace(/\B(?=(\d{3})+(?!\d))/g, '.') + 'đ';
        }
        function displayVoucherValue(type, value) {
            if (!type)
                return '';
            var t = String(type).trim();
            if (/percentage/i.test(t)) {
                var num = Number(value) || 0;
                if (num > 0 && num <= 1)
                    num = num * 100; // 0.12 -> 12
                // làm gọn đến 2 chữ số thập phân nếu cần
                return (Math.round(num * 100) / 100) + '%';
            }
            return formatVNDdot(value);
        }

        function showEmptyState() {
            var grid = document.getElementById('cartGrid');
            if (grid)
                grid.style.display = 'none';
            var sum = document.getElementById('summaryCard');
            if (sum)
                sum.style.display = 'none';
            var empty = document.getElementById('emptyStateCard');
            if (!empty) {
                var container = document.querySelector('.cart-section .container') || document.querySelector('.cart-section');
                var div = document.createElement('div');
                div.id = 'emptyStateCard';
                div.className = 'empty-box card-like mt-3';
                div.innerHTML = '<i class="fas fa-shopping-bag fa-2x mb-3"></i><p>Your cart is empty.</p>'
                        + '<a href="${pageContext.request.contextPath}/ProductList" class="btn btn-outline-primary btn-pill">Continue Shopping</a>';
                container.appendChild(div);
            }
            // reset
            ['selectedCount', 'totalCount', 'sumItems'].forEach(function (id) {
                var el = document.getElementById(id);
                if (el)
                    el.textContent = '0';
            });
            var ss = document.getElementById('sumSelected');
            if (ss)
                ss.textContent = '0đ';
            clearVoucher(true);
            var list = document.getElementById('selectedList');
            if (list)
                list.innerHTML = '<div class="text-muted small">No items selected.</div>';
            var cb = document.getElementById('checkoutBtn');
            if (cb)
                cb.disabled = true;
            var ci = document.getElementById('checkoutIds');
            if (ci)
                ci.value = '';
            document.getElementById('sumVoucherDiscount').textContent = '-0đ';
            document.getElementById('sumPayable').textContent = '0đ';
        }

        /* ===== Row total & selection ===== */
        function recalcRowTotal(row) {
            var unit = Number(row.getAttribute('data-unit-price')) || 0;
            var qtyEl = row.querySelector('.quantity-input');
            var qty = qtyEl ? Number(qtyEl.value) || 0 : Number(row.getAttribute('data-quantity')) || 0;
            var line = unit * qty;
            var lt = row.querySelector('.line-total');
            if (lt) {
                lt.setAttribute('data-line-total', String(line));
                lt.textContent = formatVNDdot(line);
            }
            row.setAttribute('data-quantity', String(qty));
            return line;
        }
        function refreshRowHighlight() {
            var checks = document.querySelectorAll('.row-check');
            for (var i = 0; i < checks.length; i++) {
                var id = checks[i].getAttribute('data-id');
                var row = document.querySelector('tr[data-cart-item-id="' + id + '"]');
                if (row)
                    row.classList.toggle('is-selected', checks[i].checked);
            }
        }
        function refreshSelectAllState() {
            var all = document.getElementById('selectAll');
            if (!all)
                return;
            var checks = document.querySelectorAll('.row-check');
            var total = checks.length, checked = 0;
            for (var i = 0; i < checks.length; i++)
                if (checks[i].checked)
                    checked++;
            all.checked = (checked === total && total > 0);
            all.indeterminate = (checked > 0 && checked < total);
        }
        function getSelectedSubtotal() {
            var checks = document.querySelectorAll('.row-check:checked');
            var sum = 0;
            for (var i = 0; i < checks.length; i++) {
                var id = checks[i].getAttribute('data-id');
                var row = document.querySelector('tr[data-cart-item-id="' + id + '"]');
                if (!row)
                    continue;
                var lt = row.querySelector('.line-total');
                var line = lt ? Number(lt.getAttribute('data-line-total') || 0) : recalcRowTotal(row);
                sum += line;
            }
            return sum;
        }
        function refreshSelectionSummary() {
            var checks = document.querySelectorAll('.row-check');
            var sel = [], i;
            for (i = 0; i < checks.length; i++)
                if (checks[i].checked)
                    sel.push(checks[i]);

            var selCount = sel.length;
            var el;
            (el = document.getElementById('selectedCount')) && (el.textContent = String(selCount));
            (el = document.getElementById('sumItems')) && (el.textContent = String(selCount));

            var subtotal = 0, ids = [];
            for (i = 0; i < sel.length; i++) {
                var id = sel[i].getAttribute('data-id');
                ids.push(id);
                var row = document.querySelector('tr[data-cart-item-id="' + id + '"]');
                if (!row)
                    continue;
                var lt = row.querySelector('.line-total');
                var line = lt ? Number(lt.getAttribute('data-line-total') || 0) : recalcRowTotal(row);
                subtotal += line;
            }
            (el = document.getElementById('sumSelected')) && (el.textContent = formatVNDdot(subtotal));

            // selected list
            var list = document.getElementById('selectedList');
            if (list) {
                list.innerHTML = '';
                if (selCount === 0) {
                    list.innerHTML = '<div class="text-muted small">No items selected.</div>';
                } else {
                    for (i = 0; i < sel.length; i++) {
                        var s = sel[i], name = s.getAttribute('data-name') || 'Product',
                                size = s.getAttribute('data-size') || '', color = s.getAttribute('data-color') || '',
                                qty = s.getAttribute('data-qty') || '1', meta = [];
                        if (size)
                            meta.push('Size: ' + size);
                        if (color)
                            meta.push('Color: ' + color);
                        var line = document.createElement('div');
                        line.className = 'selected-item';
                        line.innerHTML = '<span class="badge me-2">x' + qty + '</span>'
                                + '<div><div class="fw-semibold">' + name + '</div>'
                                + '<div class="text-muted small">' + meta.join(' • ') + '</div></div>';
                        list.appendChild(line);
                    }
                }
            }

            // checkout ids + enable/disable
            var hid = document.getElementById('checkoutIds');
            if (hid)
                hid.value = ids.join(',');
            var btn = document.getElementById('checkoutBtn');
            if (btn)
                btn.disabled = (selCount === 0);

            updatePayableUI(subtotal);
            debounceRevalidate();
        }
        function formatAllMoney() {
            var cells = document.querySelectorAll('.money');
            for (var i = 0; i < cells.length; i++) {
                var raw = cells[i].getAttribute('data-raw');
                var lt = cells[i].getAttribute('data-line-total');
                if (raw != null)
                    cells[i].textContent = formatVNDdot(raw);
                else if (lt != null)
                    cells[i].textContent = formatVNDdot(lt);
            }
        }

        /* ===== Voucher State & UI ===== */
        var voucherState = {code: null, name: null, type: null, value: null, discount: 0, valid: false};
        var revalTimer = null;

        function setVoucherAppliedUI(resp) {
            voucherState.code = (resp.voucher && resp.voucher.code) || voucherState.code;
            voucherState.name = (resp.voucher && resp.voucher.name) || voucherState.name;
            voucherState.type = (resp.voucher && resp.voucher.type) || voucherState.type;
            voucherState.value = (resp.voucher && resp.voucher.value) || voucherState.value;
            voucherState.discount = Number(resp.discount || 0);
            voucherState.valid = !!resp.success;

            document.getElementById('voucherError').classList.add('d-none');
            document.getElementById('voucherApplied').classList.remove('d-none');
            document.getElementById('vName').textContent = voucherState.name || 'Voucher';
            document.getElementById('vCode').textContent = voucherState.code || '';
            document.getElementById('vType').textContent = voucherState.type || '';
            document.getElementById('vValue').textContent = displayVoucherValue(voucherState.type, voucherState.value);
            document.getElementById('voucherStatus').textContent = resp.message || 'Applied.';
            document.getElementById('applyVoucherBtn').textContent = 'Re-apply';
            document.getElementById('clearVoucherBtn').classList.remove('d-none');
            document.getElementById('voucherCodeInput').value = voucherState.code || '';
            document.getElementById('voucherCodeHidden').value = voucherState.code || '';
        }
        function setVoucherErrorUI(msg) {
            voucherState.discount = 0;
            voucherState.valid = false;
            document.getElementById('voucherApplied').classList.add('d-none');
            document.getElementById('voucherError').classList.remove('d-none');
            document.getElementById('voucherError').textContent = msg || 'Cannot apply voucher.';
            document.getElementById('voucherStatus').textContent = '';
            document.getElementById('voucherCodeHidden').value = '';
        }
        function clearVoucher(silent) {
            voucherState = {code: null, name: null, type: null, value: null, discount: 0, valid: false};
            document.getElementById('voucherCodeInput').value = '';
            document.getElementById('voucherCodeHidden').value = '';
            document.getElementById('voucherApplied').classList.add('d-none');
            document.getElementById('voucherError').classList.add('d-none');
            document.getElementById('voucherStatus').textContent = '';
            document.getElementById('applyVoucherBtn').textContent = 'Apply';
            document.getElementById('clearVoucherBtn').classList.add('d-none');
            if (!silent)
                updatePayableUI(getSelectedSubtotal());
        }
        function updatePayableUI(subtotal) {
            var discount = voucherState.valid ? voucherState.discount : 0;
            document.getElementById('sumVoucherDiscount').textContent = '-' + formatVNDdot(discount);
            var payable = Math.max(0, subtotal - discount);
            document.getElementById('sumPayable').textContent = formatVNDdot(payable);
        }

        function applyVoucherNow() {
            var code = (document.getElementById('voucherCodeInput').value || '').trim();
            var subtotal = getSelectedSubtotal();
            if (!code) {
                setVoucherErrorUI('Please enter voucher code.');
                updatePayableUI(subtotal);
                return;
            }
            if (subtotal <= 0) {
                setVoucherErrorUI('Please select product before applying voucher.');
                updatePayableUI(subtotal);
                return;
            }

            document.getElementById('voucherStatus').textContent = 'Validating...';
            console.log('[Voucher DEBUG] subtotalSent =', subtotal, 'code =', code);
            fetch('${pageContext.request.contextPath}/customer/voucher/validate', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8', 'Accept': 'application/json'},
                body: new URLSearchParams({code: code, subtotal: String(subtotal)})
            })
                    .then(function (res) {
                        if (!res.ok)
                            throw new Error('HTTP ' + res.status);
                        return res.json();
                    })
                    .then(function (resp) {
                        if (resp.success) {
                            setVoucherAppliedUI(resp);
                            document.getElementById('sumVoucherDiscount').textContent = '-' + formatVNDdot(resp.discount);
                            document.getElementById('sumPayable').textContent = formatVNDdot(resp.newTotal);
                            showToast(resp.message || 'Voucher applied.', true);
                        } else {
                            setVoucherErrorUI(resp.message || 'Cannot apply voucher.');
                            updatePayableUI(subtotal);
                            showToast(resp.message || 'Apply failed.', false);
                        }
                    })
                    .catch(function () {
                        setVoucherErrorUI('Network error. Please try again.');
                        updatePayableUI(subtotal);
                    });
        }

        function debounceRevalidate() {
            if (!voucherState.code)
                return;
            if (revalTimer)
                clearTimeout(revalTimer);
            revalTimer = setTimeout(function () {
                var subtotal = getSelectedSubtotal();
                if (subtotal <= 0) {
                    clearVoucher(true);
                    updatePayableUI(0);
                    return;
                }
                fetch('${pageContext.request.contextPath}/customer/voucher/validate', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8', 'Accept': 'application/json'},
                    body: new URLSearchParams({code: voucherState.code, subtotal: String(subtotal)})
                })
                        .then(function (res) {
                            if (!res.ok)
                                throw new Error('HTTP ' + res.status);
                            return res.json();
                        })
                        .then(function (resp) {
                            if (resp.success) {
                                setVoucherAppliedUI(resp);
                                document.getElementById('sumVoucherDiscount').textContent = '-' + formatVNDdot(resp.discount);
                                document.getElementById('sumPayable').textContent = formatVNDdot(resp.newTotal);
                            } else {
                                setVoucherErrorUI(resp.message || 'Voucher not valid for current selection.');
                                updatePayableUI(subtotal);
                            }
                        })
                        .catch(function () {/* giữ trạng thái cũ */
                        });
            }, 300);
        }

        /* ===== Saved Vouchers (Wallet) ===== */
        var voucherWalletLoaded = false;

        function renderWallet(vouchers) {
            var list = document.getElementById('voucherWalletList');
            list.innerHTML = '';
            if (!vouchers || vouchers.length === 0) {
                list.innerHTML = '<div class="text-muted small">No saved vouchers.</div>';
                return;
            }
            vouchers.forEach(function (v) {
                var col = document.createElement('div');
                col.className = 'col-12';

                var disabled = (v.isUsed === true) || (v.isExpired === true);
                var btn = document.createElement('button');
                btn.type = 'button';
                btn.className = 'btn w-100 d-flex justify-content-between align-items-center '
                        + (disabled ? 'btn-outline-secondary' : 'btn-outline-success');
                btn.disabled = disabled;

                var left = document.createElement('div');
                left.className = 'text-start';
                left.innerHTML =
                        '<div class="fw-semibold">' + (v.name || 'Voucher') + '</div>' +
                        '<div class="small text-muted">Code: <span class="font-monospace">' + (v.code || '') + '</span></div>';

                var right = document.createElement('div');
                right.className = 'text-end';
                var valueLabel = displayVoucherValue(v.type, v.value);
                right.innerHTML = '<span class="badge bg-light text-dark">' + valueLabel + '</span>';

                btn.appendChild(left);
                btn.appendChild(right);

                if (!disabled) {
                    btn.addEventListener('click', function () {
                        document.getElementById('voucherCodeInput').value = v.code || '';
                        applyVoucherNow();
                        document.getElementById('voucherCodeInput').focus({preventScroll: false});
                    });
                } else {
                    btn.title = v.isUsed ? 'Already used' : 'Expired';
                }

                col.appendChild(btn);
                list.appendChild(col);
            });
        }

        function loadSavedVouchers() {
            var loading = document.getElementById('voucherWalletLoading');
            var err = document.getElementById('voucherWalletError');
            var list = document.getElementById('voucherWalletList');

            loading.classList.remove('d-none');
            err.classList.add('d-none');
            err.textContent = '';
            list.innerHTML = '';


            fetch('${pageContext.request.contextPath}/customer/voucher/saved', {
                method: 'GET',
                headers: {'Accept': 'application/json'}
            })
                    .then(function (res) {
                        if (!res.ok) {
                            if (res.status === 401 || res.status === 403) {
                                throw new Error('Please log in to view your saved vouchers.');
                            }
                            throw new Error('Failed to load vouchers. HTTP ' + res.status);
                        }
                        return res.json();
                    })
                    .then(function (json) {
                        loading.classList.add('d-none');
                        var vouchers = (json && (json.vouchers || json.data || [])) || [];
                        renderWallet(vouchers);
                        voucherWalletLoaded = true;
                    })
                    .catch(function (e) {
                        loading.classList.add('d-none');
                        err.classList.remove('d-none');
                        err.textContent = e.message || 'Cannot load saved vouchers.';
                    });
        }

        function bindVoucherWalletToggle() {
            var btn = document.getElementById('toggleWalletBtn');
            var wrap = document.getElementById('voucherWallet');
            if (!btn || !wrap)
                return;

            btn.addEventListener('click', function () {
                var isHidden = wrap.classList.contains('d-none');
                if (isHidden) {
                    wrap.classList.remove('d-none');
                    if (!voucherWalletLoaded)
                        loadSavedVouchers();
                } else {
                    wrap.classList.add('d-none');
                }
            });
        }

        /* ===== Binds ===== */
        function bindChecks() {
            var selectAll = document.getElementById('selectAll');
            var checks = document.querySelectorAll('.row-check');

            for (var i = 0; i < checks.length; i++) {
                checks[i].addEventListener('change', function () {
                    refreshRowHighlight();
                    refreshSelectionSummary();
                    refreshSelectAllState();
                });
            }
            if (selectAll) {
                selectAll.addEventListener('change', function () {
                    var checked = this.checked;
                    for (var i = 0; i < checks.length; i++)
                        checks[i].checked = checked;
                    refreshRowHighlight();
                    refreshSelectionSummary();
                    refreshSelectAllState();
                });
                // mặc định: chọn hết
                selectAll.checked = true;
                selectAll.dispatchEvent(new Event('change'));
            }
        }

        function bindQtyHandlers() {
            var inputs = document.querySelectorAll('.quantity-input');
            for (var i = 0; i < inputs.length; i++) {
                (function (input) {
                    input.addEventListener('change', function () {
                        var cartItemId = input.getAttribute('data-cart-item-id');
                        var quantity = parseInt(input.value, 10);
                        var maxStock = parseInt(input.getAttribute('data-max-stock'), 10);
                        var csrfToken = input.getAttribute('data-csrf-token');

                        if (!csrfToken) {
                            showToast('CSRF token is missing.', false);
                            return;
                        }
                        if (isNaN(quantity) || quantity < 1) {
                            quantity = 1;
                            input.value = 1;
                        }
                        if (!isNaN(maxStock) && quantity > maxStock) {
                            quantity = maxStock;
                            input.value = maxStock;
                            showToast('Quantity exceeds available stock.', false);
                        }

                        var body = new URLSearchParams();
                        body.append('action', 'update');
                        body.append('cartItemId', cartItemId);
                        body.append('quantity', String(quantity));
                        body.append('csrfToken', csrfToken);

                        fetch('${pageContext.request.contextPath}/customer/cart', {
                            method: 'POST',
                            body: body,
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
                                        var row = input.closest('tr[data-row="cart-item"]');
                                        if (row) {
                                            var chk = row.querySelector('.row-check');
                                            if (chk)
                                                chk.setAttribute('data-qty', String(quantity));
                                            recalcRowTotal(row);
                                        }
                                        refreshSelectionSummary();
                                        refreshSelectAllState();
                                        if (typeof window.updateCartCount === 'function') {
                                            if (typeof result.cartCount !== 'undefined')
                                                window.updateCartCount(result.cartCount);
                                            else
                                                window.updateCartCount();
                                        }
                                    } else {
                                        input.value = input.defaultValue || '1';
                                    }
                                })
                                .catch(function () {
                                    showToast('Network error. Please try again.', false);
                                    input.value = input.defaultValue || '1';
                                });
                    });
                })(inputs[i]);
            }
        }

        function bindRemoveSingle() {
            var forms = document.querySelectorAll('form.remove-form');
            for (var i = 0; i < forms.length; i++) {
                (function (form) {
                    form.addEventListener('submit', function (e) {
                        e.preventDefault();
                        var fd = new FormData(form);
                        var csrf = fd.get('csrfToken');
                        if (!csrf) {
                            showToast('CSRF token is missing.', false);
                            return;
                        }
                        if (!confirm('Are you sure you want to remove this item from your cart?'))
                            return;

                        fetch('${pageContext.request.contextPath}/customer/cart', {
                            method: 'POST',
                            body: new URLSearchParams(fd),
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
                                        var row = form.closest('tr[data-row="cart-item"]');
                                        if (row && row.parentNode)
                                            row.parentNode.removeChild(row);

                                        var remain = document.querySelectorAll('tr[data-row="cart-item"]').length;
                                        var tc = document.getElementById('totalCount');
                                        if (tc)
                                            tc.textContent = String(remain);

                                        if (remain === 0) {
                                            showEmptyState();
                                        } else {
                                            refreshSelectionSummary();
                                            refreshSelectAllState();
                                            refreshRowHighlight();
                                        }

                                        if (typeof window.updateCartCount === 'function') {
                                            if (typeof result.cartCount !== 'undefined')
                                                window.updateCartCount(result.cartCount);
                                            else
                                                window.updateCartCount();
                                        }
                                    }
                                })
                                .catch(function () {
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
                var rows = document.querySelectorAll('tr[data-row="cart-item"]');
                if (rows.length === 0)
                    return;
                if (!confirm('Clear all items from your cart?'))
                    return;

                var anyForm = document.querySelector('form.remove-form');
                var csrf = anyForm ? (new FormData(anyForm)).get('csrfToken') : '';
                if (!csrf) {
                    showToast('CSRF token is missing.', false);
                    return;
                }

                btn.disabled = true;
                var old = btn.textContent;
                btn.textContent = 'Clearing...';

                var ids = [];
                for (var i = 0; i < rows.length; i++)
                    ids.push(rows[i].getAttribute('data-cart-item-id'));
                var idx = 0;
                function next() {
                    if (idx >= ids.length) {
                        btn.disabled = false;
                        btn.textContent = old;
                        showToast('Cart has been cleared.', true);
                        if (typeof window.updateCartCount === 'function')
                            window.updateCartCount();
                        showEmptyState();
                        return;
                    }
                    var body = new URLSearchParams();
                    body.append('action', 'remove');
                    body.append('cartItemId', ids[idx]);
                    body.append('csrfToken', csrf);
                    fetch('${pageContext.request.contextPath}/customer/cart', {
                        method: 'POST', body: body,
                        headers: {'Content-Type': 'application/x-www-form-urlencoded', 'Accept': 'application/json', 'Cache-Control': 'no-cache'}
                    }).then(function () {
                        idx++;
                        next();
                    }).catch(function () {
                        idx++;
                        next();
                    });
                }
                next();
            });
        }

        // Guard checkout
        function bindCheckoutGuard() {
            var form = document.getElementById('checkoutForm');
            if (!form)
                return;

            form.addEventListener('submit', function (e) {
                var idsEl = document.getElementById('checkoutIds');
                var ids = idsEl ? idsEl.value : '';
                if (!ids) {
                    e.preventDefault();
                    showToast('Please select at least one item to checkout.', false);
                    return;
                }

                // Đẩy subtotal & discount (raw number, không định dạng) sang server
                var subtotal = getSelectedSubtotal();
                var discount = (typeof voucherState !== 'undefined' && voucherState.valid)
                        ? Number(voucherState.discount || 0)
                        : 0;

                document.getElementById('selectedSubtotalHidden').value = String(Math.max(0, Math.round(subtotal)));
                document.getElementById('voucherDiscountHidden').value = String(Math.max(0, Math.round(discount)));
                // voucherCodeHidden đã được set khi Apply/Clear voucher nên không cần đụng ở đây
            });
        }


        function bindVoucherUI() {
            document.getElementById('applyVoucherBtn').addEventListener('click', function (e) {
                e.preventDefault();
                applyVoucherNow();
            });
            document.getElementById('voucherCodeInput').addEventListener('keydown', function (e) {
                if (e.key === 'Enter') {
                    e.preventDefault();
                    applyVoucherNow();
                }
            });
            document.getElementById('clearVoucherBtn').addEventListener('click', function (e) {
                e.preventDefault();
                clearVoucher();
            });
        }

        function bindVoucherWalletToggle() {
            var btn = document.getElementById('toggleWalletBtn');
            var wrap = document.getElementById('voucherWallet');
            if (!btn || !wrap)
                return;

            btn.addEventListener('click', function () {
                var isHidden = wrap.classList.contains('d-none');
                if (isHidden) {
                    wrap.classList.remove('d-none');
                    if (!voucherWalletLoaded)
                        loadSavedVouchers();
                } else {
                    wrap.classList.add('d-none');
                }
            });
        }

        /* ===== Init ===== */
        document.addEventListener('DOMContentLoaded', function () {
            formatAllMoney();
            var rows = document.querySelectorAll('tr[data-row="cart-item"]');
            for (var i = 0; i < rows.length; i++)
                recalcRowTotal(rows[i]);

            bindChecks();
            bindQtyHandlers();
            bindRemoveSingle();
            bindClearCart();
            bindCheckoutGuard();
            bindVoucherUI();
            bindVoucherWalletToggle();

            if (typeof window.updateCartCount === 'function')
                window.updateCartCount();

            updatePayableUI(getSelectedSubtotal()); // initial
        });
    })();
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
