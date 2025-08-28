<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<c:set var="pageTitle" value="Purchase Order Detail" scope="request"/>
<c:set var="currentModule" value="stock" scope="request"/>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Purchase Order Detail</title>

        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css"/>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/admin-dashboard/css/admin-css.css">

        <style>
            .info-label{
                font-weight:600;
                color:#555
            }
            .box{
                background:#fff;
                border:1px solid #e5e7eb;
                border-radius:12px;
                margin-bottom:20px;
                box-shadow:0 8px 24px rgba(16,24,40,.04)
            }
            .box-header{
                padding:16px 20px;
                border-bottom:1px solid #eef2f7
            }
            .box-title{
                margin:0;
                font-size:1.25rem;
                font-weight:600
            }
            .box-body{
                padding:20px
            }
            .action-buttons-container{
                display:flex;
                justify-content:space-between;
                gap:12px;
                align-items:center;
                flex-wrap:wrap
            }
            .action-buttons .btn,#save-status{
                margin-left:8px
            }
            .table-footer td{
                background:#fafafa
            }
            .content-area{
                position:relative;
                margin-left:260px;
                padding:1.5rem;
                width:calc(100% - 260px);
                transition:all .5s ease;
                min-height:100vh
            }
            .sidebar.close ~ .content-area{
                margin-left:88px;
                width:calc(100% - 88px)
            }
            .sidebar.hidden ~ .content-area{
                margin-left:0;
                width:100%
            }

            /* === UX nâng cấp cho Product Selector === */
            #product-selector-list input[type="checkbox"]{
                transform:scale(1.3);
                cursor:pointer
            }
            #product-selector-list tr{
                cursor:pointer
            }
            #product-selector-list tr:hover{
                background:#fafafa
            }
            #product-selector-list tr.is-selected{
                background:#eef2ff
            }
            #productSelectorModal thead th{
                position:sticky;
                top:0;
                background:#fff;
                z-index:2
            }
            
        </style>
    </head>

    <body>
        <c:choose>
    <c:when test="${not empty sessionScope.admin}">
        <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp"/>
    </c:when>
    <c:when test="${not empty sessionScope.staff}">
         <jsp:include page="/WEB-INF/views/staff/staff-sidebar.jsp" />
    </c:when>
</c:choose>
        <div class="main-content-wrapper">
            <main class="content-area">
                <div class="box">
                    <div class="box-header">
                        <h3 class="box-title">Purchase Order Detail</h3>
                    </div>

                    <div class="box-body">
                        <div class="toast-container position-fixed top-0 end-0 p-3" style="z-index:1100"></div>

                        <div id="po-header-info" class="mb-4"><!-- render bằng JS --></div>
                        <hr>

                        <div id="add-product-container" class="mb-3"><!-- render button Add bằng JS --></div>

                        <form id="poForm">
                            <!-- JSON từ Controller -->
                            <div id="po-data-json" style="display:none;">${poData}</div>
                            <div id="po-items-json" style="display:none;">${itemsInPO}</div>

                            <div class="mb-4 row">
                                <label for="supplierId" class="col-sm-2 col-form-label"><b>Supplier (*)</b></label>
                                <div class="col-sm-10">
                                    <select name="supplierId" id="supplierId" class="form-select" required>
                                        <option value="">-- Select Supplier --</option>
                                        <c:forEach var="supplier" items="${suppliers}">
                                            <option value="${supplier.supplierId}">${supplier.name}</option>
                                        </c:forEach>
                                    </select>
                                </div>
                            </div>

                            <div class="mb-4 row">
                                <label for="userNotes" class="col-sm-2 col-form-label"><b>Notes</b></label>
                                <div class="col-sm-10">
                                    <div class="input-group">
                                        <span class="input-group-text" id="notePrefix"></span>
                                        <textarea class="form-control" id="userNotes" name="userNotes" rows="3" placeholder="Add additional notes..."></textarea>
                                    </div>
                                </div>
                            </div>

                            <h4 class="mt-4 mb-3">Products in Purchase Order</h4>
                            <div class="table-responsive">
                                <table class="table table-bordered table-hover align-middle">
                                    <thead class="table-light">
                                        <tr>
                                            <th>Product</th>
                                            <th>SKU</th>
                                            <th style="width:140px">Quantity</th>
                                            <th style="width:180px">Unit Price (VND)</th>
                                            <th style="width:160px">Subtotal (VND)</th>
                                            <th style="width:100px">Action</th>
                                        </tr>
                                    </thead>
                                    <tbody id="po-item-list"><!-- render bằng JS --></tbody>
                                    <tfoot>
                                        <tr class="table-footer">
                                            <td colspan="2" class="text-end"><strong>Total:</strong></td>
                                            <td id="total-quantity"><strong>0</strong></td>
                                            <td></td>
                                            <td id="total-amount"><strong>0</strong></td>
                                            <td></td>
                                        </tr>
                                    </tfoot>
                                </table>
                            </div>

                            <div class="action-buttons-container">
                                <div id="save-status"></div>
                                <div class="action-buttons" style="border-top:none;padding-top:0;margin-top:0;">
                                    <a href="${pageContext.request.contextPath}/Admindashboard?action=purchaseorder&module=stock" class="btn btn-secondary">
                                        <i class="fa fa-arrow-left me-1"></i> Back to List
                                    </a>

                                    <button type="button" class="btn btn-info action-btn" data-action="sendOrder">
                                        <i class="fas fa-paper-plane me-1"></i> Send Order
                                    </button>
                                    <button type="button" class="btn btn-success action-btn" data-action="confirmOrder">
                                        <i class="fas fa-check-double me-1"></i> Confirm Order
                                    </button>
                                    <button type="button" class="btn btn-success action-btn" data-action="receiveDelivery">
                                        <i class="fas fa-truck-loading me-1"></i> Mark as Delivered
                                    </button>
                                    <button type="button" class="btn btn-danger action-btn" data-action="cancelOrder">
                                        <i class="fas fa-times me-1"></i> Cancel Order
                                    </button>

                                    <button type="button" id="printReceiptBtn" class="btn btn-warning" data-bs-toggle="modal" data-bs-target="#printReceiptModal" style="display:none;">
                                        <i class="fas fa-print me-1"></i> Print 
                                    </button>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>
            </main>
        </div>

        <!-- MODAL: Select Products -->
        <div class="modal fade" id="productSelectorModal" tabindex="-1" style="z-index:1060;">
            <div class="modal-dialog modal-xl modal-dialog-scrollable">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">Select Products to Add</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="mb-3">
                            <input type="text" id="productSearchInput" class="form-control" placeholder="Search by product name or SKU...">
                        </div>
                        <div class="table-responsive">
                            <table class="table table-sm table-hover">
                                <thead class="table-light">
                                    <tr>
                                        <th style="width:48px;"><input type="checkbox" id="selectAllProducts"></th>
                                        <th>Product</th>
                                        <th>SKU</th>
                                        <th>Size/Color</th>
                                        <th style="width:110px;">Stock</th>
                                    </tr>
                                </thead>
                                <tbody id="product-selector-list"><!-- render bằng JS --></tbody>
                            </table>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                        <button type="button" class="btn btn-primary" id="addSelectedProductsBtn" disabled>Add Selected Products</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- MODAL: Confirm chung -->
        <div class="modal fade" id="customModal" tabindex="-1">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content">
                    <div class="modal-header"><h5 class="modal-title" id="modalLabel">Confirmation</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
                    <div class="modal-body" id="modalBody"></div>
                    <div class="modal-footer"><button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button><button type="button" class="btn btn-primary" id="modalConfirmButton">Confirm</button></div>
                </div>
            </div>
        </div>

        <!-- MODAL: Print Receipt -->
        <div class="modal fade" id="printReceiptModal" tabindex="-1" aria-labelledby="printModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-xl modal-fullscreen-lg-down">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="printModalLabel">Phiếu Nhập Kho</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body p-0" style="height:80vh;">
                        <iframe id="pdf-iframe" src="" width="100%" height="100%" frameborder="0"></iframe>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                    </div>
                </div>
            </div>
        </div>

        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>

        <script>
            document.addEventListener('DOMContentLoaded', function () {
                // ===== STATE =====
                var poData = JSON.parse(document.getElementById('po-data-json').textContent);
                var itemsInPO = JSON.parse(document.getElementById('po-items-json').textContent);
                var poId = poData.poId;
                var poForm = document.getElementById('poForm');
                var customModal = new bootstrap.Modal(document.getElementById('customModal'));
                var saveStatusEl = document.getElementById('save-status');
                var currentUserRole = 'Admin';
                var allProducts = [];
                var printModalEl = document.getElementById('printReceiptModal');
                var pdfIframe = document.getElementById('pdf-iframe');
                var contextPath = '${pageContext.request.contextPath}';
                var inputTimers = {};

                // ===== HELPERS =====
                var formatCurrency = function (num) {
                    return new Intl.NumberFormat('vi-VN').format(num);
                };

                function showToast(message, isError) {
                    isError = isError || false;
                    var toastContainer = document.querySelector('.toast-container');
                    var toastId = 'toast-' + Date.now();
                    var toastHTML =
                            '<div id="' + toastId + '" class="toast align-items-center text-white ' + (isError ? 'bg-danger' : 'bg-success') + '" role="alert" aria-live="assertive" aria-atomic="true">' +
                            '<div class="d-flex">' +
                            '<div class="toast-body">' + message + '</div>' +
                            '<button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>' +
                            '</div>' +
                            '</div>';
                    toastContainer.insertAdjacentHTML('beforeend', toastHTML);
                    var toastEl = document.getElementById(toastId);
                    var toast = new bootstrap.Toast(toastEl, {delay: 3000});
                    toast.show();
                    toastEl.addEventListener('hidden.bs.toast', function () {
                        toastEl.remove();
                    });
                }

                function showModal(title, body, onConfirm) {
                    document.getElementById('modalLabel').textContent = title;
                    document.getElementById('modalBody').innerHTML = body;
                    var confirmBtn = document.getElementById('modalConfirmButton');
                    var newConfirmBtn = confirmBtn.cloneNode(true);
                    confirmBtn.parentNode.replaceChild(newConfirmBtn, confirmBtn);
                    newConfirmBtn.addEventListener('click', function () {
                        onConfirm();
                        customModal.hide();
                    }, {once: true});
                    customModal.show();
                }

                function sendAjaxRequest(action, data) {
                    if (!data)
                        data = {};
                    var formData = new URLSearchParams();
                    formData.append('action', action);
                    formData.append('poId', poId);
                    for (var k in data) {
                        if (Array.isArray(data[k]))
                            data[k].forEach(v => formData.append(k, v));
                        else
                            formData.append(k, data[k]);
                    }
                    return fetch('PurchaseOrder', {method: 'POST', body: formData})
                            .then(async (res) => {
                                const json = await res.json();
                                if (!res.ok)
                                    throw new Error(json.message || 'An unknown error occurred.');
                                return json;
                            })
                            .catch(err => {
                                showToast(err.message, true);
                                throw err;
                            });
                }

                var updateSaveStatus = function (status) {
                    var iconMap = {
                        saving: '<i class="fas fa-spinner fa-spin"></i> Saving...',
                        saved: '<i class="fas fa-check-circle text-success"></i> All changes saved.',
                        error: '<i class="fas fa-exclamation-circle text-danger"></i> Failed to save.'
                    };
                    saveStatusEl.innerHTML = iconMap[status] || '';
                };

                var updateTotals = function () {
                    var totalQty = 0, totalAmt = 0;
                    itemsInPO.forEach(function (item) {
                        var row = document.querySelector('#po-item-list tr[data-pod-id="' + item.podId + '"]');
                                var qty = row ? parseInt(row.querySelector('.quantity-input')?.value || '0', 10) : item.quantity;
                                var price = row ? parseFloat(row.querySelector('.price-input')?.value || '0') : item.unitPrice;
                        var subtotal = qty * price;
                        if (row)
                            row.querySelector('.subtotal').textContent = formatCurrency(subtotal);
                        totalQty += qty;
                        totalAmt += subtotal;
                    });
                    document.querySelector('#total-quantity strong').textContent = totalQty;
                    document.querySelector('#total-amount strong').textContent = formatCurrency(totalAmt);
                };

                var autoSave = function (updateType, value, podId) {
                    updateSaveStatus('saving');
                    sendAjaxRequest('autoSave', {updateType, value, podId})
                            .then(function () {
                                updateSaveStatus('saved');
                                updateTotals();
                            })
                            .catch(function () {
                                updateSaveStatus('error');
                            });
                };
                var debouncedAutoSave = (fn => {
                    let t;
                    return function () {
                        clearTimeout(t);
                        t = setTimeout(() => fn.apply(this, arguments), 800);
                    };
                })(autoSave);

                var renderUI = function () {
                    document.getElementById('po-header-info').innerHTML =
                            '<p><span class="info-label">PO ID:</span> #' + poData.poId + '</p>' +
                            '<p><span class="info-label">Status:</span> <span id="poStatusBadge" class="badge"></span></p>' +
                            '<p><span class="info-label">Created Date:</span> ' + new Date(poData.orderDate).toLocaleString('vi-VN') + '</p>';

                    document.getElementById('supplierId').value = poData.supplierId || '';
                    document.getElementById('notePrefix').textContent = poData.notePrefix || '';
                    document.getElementById('userNotes').value = poData.userNotes || '';

                    var body = document.getElementById('po-item-list');
                    body.innerHTML = itemsInPO.length > 0 ? itemsInPO.map(function (it) {
                        return '<tr data-pod-id="' + it.podId + '">' +
                                '<td>' + it.productName + ' (' + it.size + '/' + it.color + ')</td>' +
                                '<td>' + it.sku + '</td>' +
                                '<td><input type="number" class="form-control quantity-input" value="' + it.quantity + '" min="1"></td>' +
                                '<td><input type="number" class="form-control price-input" value="' + it.unitPrice + '" min="0" step="1000"></td>' +
                                '<td class="subtotal">' + formatCurrency(it.totalPrice) + '</td>' +
                                '<td class="item-actions"></td>' +
                                '</tr>';
                    }).join('') : '<tr id="no-items-row"><td colspan="6" class="text-center">No products in this order.</td></tr>';

                    updateUIForStatus(poData.status);
                    updateTotals();
                };

                var updateUIForStatus = function (status) {
                    poData.status = status;
                    var badge = document.getElementById('poStatusBadge');
                    badge.textContent = status;
                    var colors = {Draft: 'bg-secondary', Sent: 'bg-info', Confirmed: 'bg-primary', Delivered: 'bg-success', Cancelled: 'bg-danger'};
                    badge.className = 'badge ' + (colors[status] || 'bg-dark');

                    var isEditable = status === 'Draft' || status === 'Sent';
                    document.querySelectorAll('#poForm input, #poForm select, #poForm textarea').forEach(function (el) {
                        el.disabled = !isEditable;
                    });

                    document.querySelectorAll('.action-btn, #printReceiptBtn').forEach(btn => btn.style.display = 'none');
                    document.getElementById('add-product-container').innerHTML = '';

                    if (status === 'Draft') {
                        document.querySelector('[data-action="sendOrder"]').style.display = 'inline-block';
                        document.querySelector('[data-action="cancelOrder"]').style.display = 'inline-block';
                        document.getElementById('add-product-container').innerHTML =
                                '<button type="button" class="btn btn-info" data-bs-toggle="modal" data-bs-target="#productSelectorModal">' +
                                '<i class="fa-solid fa-magnifying-glass-plus me-1"></i>Search & Add Products' +
                                '</button>';
                    } else if (status === 'Sent') {
                        if (currentUserRole === 'Admin')
                            document.querySelector('[data-action="confirmOrder"]').style.display = 'inline-block';
                        document.querySelector('[data-action="cancelOrder"]').style.display = 'inline-block';
                    } else if (status === 'Confirmed') {
                        document.querySelector('[data-action="receiveDelivery"]').style.display = 'inline-block';
                        document.getElementById('printReceiptBtn').style.display = 'inline-block';
                    } else if (status === 'Delivered') {
                        document.getElementById('printReceiptBtn').style.display = 'inline-block';
                    }

                    document.querySelectorAll('#po-item-list tr .item-actions').forEach(function (cell) {
                        var podId = cell.closest('tr').dataset.podId;
                        cell.innerHTML = status === 'Draft'
                                ? '<button type="button" class="btn btn-danger btn-sm" data-action="delete-item" data-pod-id="' + podId + '"><i class="fas fa-trash-alt"></i></button>'
                                : '';
                    });
                };

                // ===== Events: form input =====
                poForm.addEventListener('input', function (e) {
                    var t = e.target;
                    var valueStr = t.value.trim();
                    var updateType = null, podId = null, timerKey = null;

                    if (t.classList.contains('quantity-input')) {
                        if (valueStr !== "") {
                            var q = parseInt(valueStr, 10);
                            if (isNaN(q) || q <= 0) {
                                showToast('Quantity must be a positive number.', true);
                                t.value = 1;
                            }
                        }
                        updateType = 'quantity';
                        podId = t.closest('tr').dataset.podId;
                        timerKey = 'quantity-' + podId;
                    } else if (t.classList.contains('price-input')) {
                        if (valueStr !== "") {
                            var p = parseFloat(valueStr);
                            if (isNaN(p) || p < 0) {
                                showToast('Unit Price cannot be negative.', true);
                                t.value = 0;
                            }
                        }
                        updateType = 'price';
                        podId = t.closest('tr').dataset.podId;
                        timerKey = 'price-' + podId;
                    } else if (t.id === 'poNotes') {
                        updateType = 'notes';
                        timerKey = 'notes';
                    } else {
                        return;
                    }

                    if (inputTimers[timerKey])
                        clearTimeout(inputTimers[timerKey]);
                    inputTimers[timerKey] = setTimeout(function () {
                        if (t.value.trim() !== "")
                            autoSave(updateType, t.value, podId);
                    }, 800);
                });

                poForm.addEventListener('change', function (e) {
                    if (e.target.id === 'supplierId')
                        autoSave('supplier', e.target.value);
                });

                document.querySelector('.action-buttons').addEventListener('click', function (e) {
                    var btn = e.target.closest('.action-btn');
                    if (!btn)
                        return;
                    var action = btn.dataset.action;

                    if (action === 'cancelOrder' && poData.status === 'Draft') {
                        showModal('Delete Draft Order', 'Are you sure you want to permanently <b>delete</b> this draft order?', function () {
                            sendAjaxRequest('deleteDraft').then(function (r) {
                                showToast(r.message);
                                setTimeout(function () {
                                    window.location.href = '${pageContext.request.contextPath}/Admindashboard?action=purchaseorder&module=stock';
                                }, 1200);
                            });
                        });
                        return;
                    }

                    if (action === 'sendOrder') {
                        var supplierId = document.getElementById('supplierId').value;
                        if (!supplierId) {
                            showToast('Please select a supplier before sending the order.', true);
                            return;
                        }
                        if (itemsInPO.length === 0) {
                            showToast('Cannot send an empty purchase order. Please add products.', true);
                            return;
                        }
                        for (var i = 0; i < itemsInPO.length; i++) {
                            var item = itemsInPO[i];
                            var row = document.querySelector('tr[data-pod-id="' + item.podId + '"]');
                            var q = parseInt(row.querySelector('.quantity-input').value, 10);
                            if (isNaN(q) || q <= 0) {
                                showToast('Quantity for "' + item.productName + '" must be a positive number.', true);
                                row.querySelector('.quantity-input').focus();
                                return;
                            }
                        }
                    }

                    showModal('Confirmation', 'Are you sure you want to <b>' + action.replace(/([A-Z])/g, ' $1').toLowerCase() + '</b>?', function () {
                        sendAjaxRequest(action).then(function (res) {
                            showToast(res.message);
                            var map = {sendOrder: 'Sent', confirmOrder: 'Confirmed', receiveDelivery: 'Delivered', cancelOrder: 'Cancelled'};
                            if (map[action])
                                updateUIForStatus(map[action]);
                        });
                    });
                });

                document.getElementById('po-item-list').addEventListener('click', function (e) {
                    var del = e.target.closest('[data-action="delete-item"]');
                    if (!del)
                        return;
                    var podId = del.dataset.podId;
                    showModal('Delete Item', 'Are you sure?', function () {
                        sendAjaxRequest('deleteItem', {podId}).then(function () {
                            itemsInPO = itemsInPO.filter(it => it.podId != podId);
                            renderUI();
                            showToast('Item deleted.');
                        });
                    });
                });

                // ===== Print modal =====
                printModalEl.addEventListener('show.bs.modal', function () {
                    pdfIframe.src = contextPath + '/PurchaseOrder?action=printReceipt&poId=' + poData.poId;
                });
                printModalEl.addEventListener('hidden.bs.modal', function () {
                    pdfIframe.src = 'about:blank';
                });

                // ===== Product selector modal =====
                var productModalEl = document.getElementById('productSelectorModal');
                var productModal = new bootstrap.Modal(productModalEl);
                var productModalBody = document.getElementById('product-selector-list');
                var productSearchInput = document.getElementById('productSearchInput');

                productModalEl.addEventListener('show.bs.modal', function () {
                    productModalBody.innerHTML = '<tr><td colspan="5" class="text-center"><i class="fas fa-spinner fa-spin"></i> Loading...</td></tr>';
                    sendAjaxRequest('getProductsForSelection').then(function (result) {
                        allProducts = result.data;
                        renderProductSelector(allProducts);
                    }).catch(function () {
                        productModalBody.innerHTML = '<tr><td colspan="5" class="text-center text-danger">Failed to load products.</td></tr>';
                    });
                });

                function renderProductSelector(products) {
                    var existing = itemsInPO.map(it => it.variantId);
                    productModalBody.innerHTML = products.map(function (p) {
                        var added = existing.indexOf(p.variantId) > -1;
                        return '<tr data-product-name="' + (p.productName || '').toLowerCase() + '" data-sku="' + (p.sku || '').toLowerCase() + '"' + (added ? ' class="table-secondary"' : '') + '>' +
                                '<td><input type="checkbox" class="select-product-cb" value="' + p.variantId + '" ' + (added ? 'disabled' : '') + '></td>' +
                                '<td>' + p.productName + '</td>' +
                                '<td>' + (p.sku || 'N/A') + '</td>' +
                                '<td>' + p.size + ' / ' + p.color + '</td>' +
                                '<td>' + p.currentStock + '</td>' +
                                '</tr>';
                    }).join('');
                }

                productSearchInput.addEventListener('keyup', function () {
                    var term = productSearchInput.value.toLowerCase();
                    document.querySelectorAll('#product-selector-list tr').forEach(function (row) {
                        var match = row.dataset.productName.includes(term) || row.dataset.sku.includes(term);
                        row.style.display = match ? '' : 'none';
                    });
                });

                document.getElementById('addSelectedProductsBtn').addEventListener('click', function () {
                    var ids = Array.from(document.querySelectorAll('.select-product-cb:checked')).map(cb => cb.value);
                    if (ids.length === 0) {
                        showToast('Please select at least one product.', true);
                        return;
                    }
                    sendAjaxRequest('addProducts', {'variantIds[]': ids}).then(function (result) {
                        itemsInPO = result.data;
                        renderUI();
                        productModal.hide();
                        showToast(result.message);
                    });
                });

                // ====== Nâng cấp UX chọn row (click cả hàng, Shift range, Select-All thông minh) ======
                (function () {
                    const list = document.getElementById('product-selector-list');
                    const addBtn = document.getElementById('addSelectedProductsBtn');
                    const selectAllTop = document.getElementById('selectAllProducts');
                    const searchBox = document.getElementById('productSearchInput');

                    function updateAddBtn() {
                        const count = list.querySelectorAll('.select-product-cb:checked').length;
                        addBtn.textContent = count > 0 ? `Add Selected Products (${count})` : 'Add Selected Products';
                        addBtn.disabled = count === 0;
                    }
                    function toggleRow(row, explicitChecked) {
                        const cb = row.querySelector('.select-product-cb');
                        if (!cb || cb.disabled)
                            return;
                        cb.checked = explicitChecked != null ? explicitChecked : !cb.checked;
                        row.classList.toggle('is-selected', cb.checked);
                    }
                    function visibleRows() {
                        return Array.from(list.querySelectorAll('tr')).filter(r => r.style.display !== 'none');
                    }

                    let lastClickedIndex = null;

                    list.addEventListener('click', (e) => {
                        const row = e.target.closest('tr');
                        if (!row)
                            return;

                        // Click trực tiếp vào checkbox
                        if (e.target.matches('.select-product-cb')) {
                            row.classList.toggle('is-selected', e.target.checked);
                            lastClickedIndex = visibleRows().indexOf(row);
                            updateAddBtn();
                            return;
                        }

                        // Click vùng còn lại của row
                        e.preventDefault();
                        toggleRow(row);

                        // Shift-click chọn dải
                        const rows = visibleRows();
                        const idx = rows.indexOf(row);
                        if (e.shiftKey && lastClickedIndex != null) {
                            const [a, b] = [Math.min(lastClickedIndex, idx), Math.max(lastClickedIndex, idx)];
                            const shouldCheck = row.querySelector('.select-product-cb').checked;
                            for (let i = a; i <= b; i++)
                                toggleRow(rows[i], shouldCheck);
                        }
                        lastClickedIndex = idx;
                        updateAddBtn();
                    });

                    if (searchBox) {
                        searchBox.addEventListener('input', () => {
                            selectAllTop.checked = false;
                            updateAddBtn();
                        });
                    }

                    if (selectAllTop) {
                        selectAllTop.addEventListener('change', () => {
                            for (const row of visibleRows())
                                toggleRow(row, selectAllTop.checked);
                            updateAddBtn();
                        });
                    }

                    document.getElementById('productSelectorModal')
                            .addEventListener('shown.bs.modal', updateAddBtn);
                })();

                // ===== Init =====
                renderUI();
            });
        </script>
    </body>
</html>
