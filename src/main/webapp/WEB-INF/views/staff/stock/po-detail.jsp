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
            .info-label {
                font-weight: bold;
                color: #555;
            }
            .box {
                background-color: #fff;
                border: 1px solid #ddd;
                border-radius: 5px;
                margin-bottom: 20px;
            }
            .box-header {
                padding: 15px;
                border-bottom: 1px solid #ddd;
            }
            .box-title {
                margin: 0;
                font-size: 1.5rem;
                font-weight: 500;
            }
            .box-body {
                padding: 20px;
            }
            .action-buttons-container {
                display: flex;
                justify-content: flex-end;
                align-items: center;
            }
            .action-buttons {
                margin-top: 20px;
                text-align: right;
                padding-top: 20px;
                border-top: 1px solid #eee;
            }
            .action-buttons .btn, #save-status {
                margin-left: 10px;
            }
            .table-secondary {
                background-color: #e9ecef !important;
            }
        </style>
    </head>
    <body>
        <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp"/>
        <div class="main-content-wrapper">
            <jsp:include page="/WEB-INF/includes/admin-header.jsp"/>
            <main class="content-area">
                <div class="box">
                    <div class="box-header">
                        <h3 class="box-title">Purchase Order Detail</h3>
                    </div>
                    <div class="box-body">
                        <div class="toast-container position-fixed top-0 end-0 p-3" style="z-index: 1100"></div>

                        <div id="po-header-info" class="mb-4">
                            <%-- Dữ liệu sẽ được JS render vào đây --%>
                        </div>
                        <hr>

                        <div id="add-product-container" class="mb-3">
                            <%-- Nút Add Product sẽ được JS quản lý hiển thị --%>
                        </div>

                        <form id="poForm">
                            <%-- Dữ liệu PO được truyền từ Controller dưới dạng JSON và lưu vào các thẻ ẩn --%>
                            <div id="po-data-json" style="display: none;">${poData}</div>
                            <div id="po-items-json" style="display: none;">${itemsInPO}</div>

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
                                        <textarea class="form-control" id="userNotes" name="userNotes" rows="3" 
                                                  placeholder="Add additional notes..."></textarea>
                                    </div>
                                </div>
                            </div>

                            <h4 class="mt-4 mb-3">Products in Purchase Order</h4>
                            <table class="table table-bordered table-hover">
                                <thead>
                                    <tr>
                                        <th>Product</th>
                                        <th>SKU</th>
                                        <th>Quantity</th>
                                        <th>Unit Price (VND)</th>
                                        <th>Subtotal (VND)</th>
                                        <th style="width: 100px;">Action</th>
                                    </tr>
                                </thead>
                                <tbody id="po-item-list">
                                    <%-- Dữ liệu sẽ được JS render vào đây --%>
                                </tbody>
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

                            <div class="action-buttons-container">
                                <div id="save-status"></div>
                                <div class="action-buttons" style="border-top: none; padding-top: 0; margin-top: 0;">
                                    <a href="${pageContext.request.contextPath}/Admindashboard?action=purchaseorder&module=stock" class="btn btn-secondary"><i class="fa fa-arrow-left me-1"></i> Back to List</a>

                                    <button type="button" class="btn btn-info action-btn" data-action="sendOrder"><i class="fas fa-paper-plane me-1"></i> Send Order</button>
                                    <button type="button" class="btn btn-success action-btn" data-action="confirmOrder"><i class="fas fa-check-double me-1"></i> Confirm Order</button>
                                    <button type="button" class="btn btn-success action-btn" data-action="receiveDelivery"><i class="fas fa-truck-loading me-1"></i> Mark as Delivered</button>
                                    <button type="button" class="btn btn-danger action-btn" data-action="cancelOrder"><i class="fas fa-times me-1"></i> Cancel Order</button>

                                    <button type="button" id="printReceiptBtn" class="btn btn-warning" data-bs-toggle="modal" data-bs-target="#printReceiptModal" style="display: none;">
                                        <i class="fas fa-print me-1"></i> In Phiếu Nhập Kho
                                    </button>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>
            </main>
        </div>

        <%-- MODAL CHỌN SẢN PHẨM --%>
        <div class="modal fade" id="productSelectorModal" tabindex="-1" style="z-index: 1060;">
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
                        <table class="table table-sm table-hover">
                            <thead>
                                <tr>
                                    <th><input type="checkbox" id="selectAllProducts"></th>
                                    <th>Product</th>
                                    <th>SKU</th>
                                    <th>Size/Color</th>
                                    <th>Stock</th>
                                </tr>
                            </thead>
                            <tbody id="product-selector-list"></tbody>
                        </table>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                        <button type="button" class="btn btn-primary" id="addSelectedProductsBtn">Add Selected Products</button>
                    </div>
                </div>
            </div>
        </div>

        <%-- MODAL XÁC NHẬN CHUNG --%>
        <div class="modal fade" id="customModal" tabindex="-1">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content">
                    <div class="modal-header"><h5 class="modal-title" id="modalLabel">Confirmation</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
                    <div class="modal-body" id="modalBody"></div>
                    <div class="modal-footer"><button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button><button type="button" class="btn btn-primary" id="modalConfirmButton">Confirm</button></div>
                </div>
            </div>
        </div>
        <div class="modal fade" id="printReceiptModal" tabindex="-1" aria-labelledby="printModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-xl modal-fullscreen-lg-down">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="printModalLabel">Phiếu Nhập Kho</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body p-0" style="height: 80vh;">
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
                // --- STATE & DATA ---
                var poData = JSON.parse(document.getElementById('po-data-json').textContent);
                var itemsInPO = JSON.parse(document.getElementById('po-items-json').textContent);
                var poId = poData.poId;
                var poForm = document.getElementById('poForm');
                var customModal = new bootstrap.Modal(document.getElementById('customModal'));
                var productModal = new bootstrap.Modal(document.getElementById('productSelectorModal'));
                var saveStatusEl = document.getElementById('save-status');
                var currentUserRole = 'Admin'; // Giả lập vai trò user, nên truyền từ server
                var allProducts = []; // Lưu trữ toàn bộ danh sách sản phẩm để chọn
                var printModalEl = document.getElementById('printReceiptModal');
                var pdfIframe = document.getElementById('pdf-iframe');
                var contextPath = '${pageContext.request.contextPath}';
                var inputTimers = {};

                // --- HELPERS ---
                var formatCurrency = function (num) {
                    return new Intl.NumberFormat('vi-VN').format(num);
                };

                var debounce = function (func, delay) {
                    var timeout;
                    return function () {
                        var context = this;
                        var args = arguments;
                        clearTimeout(timeout);
                        timeout = setTimeout(function () {
                            func.apply(context, args);
                        }, delay);
                    };
                };

                function showToast(message, isError) {
                    isError = isError || false;
                    var toastContainer = document.querySelector('.toast-container');
                    var toastId = 'toast-' + Date.now();
                    var toastHTML = '<div id="' + toastId + '" class="toast align-items-center text-white ' + (isError ? 'bg-danger' : 'bg-success') + '" role="alert" aria-live="assertive" aria-atomic="true"><div class="d-flex"><div class="toast-body">' + message + '</div><button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button></div></div>';
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

                // --- AJAX ---
                function sendAjaxRequest(action, data) {
                    if (data === void 0) {
                        data = {};
                    }
                    var formData = new FormData();
                    formData.append('action', action);
                    formData.append('poId', poId);
                    for (var key in data) {
                        if (Array.isArray(data[key])) {
                            data[key].forEach(function (value) {
                                formData.append(key, value);
                            });
                        } else {
                            formData.append(key, data[key]);
                        }
                    }

                    return fetch('PurchaseOrder', {method: 'POST', body: new URLSearchParams(formData)})
                            .then(function (response) {
                                return response.json().then(function (result) {
                                    if (!response.ok) {
                                        throw new Error(result.message || 'An unknown error occurred.');
                                    }
                                    return result;
                                });
                            })
                            .catch(function (error) {
                                showToast(error.message, true);
                                throw error;
                            });
                }

                var autoSave = function (updateType, value, podId) {
                    if (podId === void 0) {
                        podId = null;
                    }
                    updateSaveStatus('saving');
                    sendAjaxRequest('autoSave', {updateType: updateType, value: value, podId: podId})
                            .then(function () {
                                updateSaveStatus('saved');
                                updateTotals();
                            })
                            .catch(function () {
                                updateSaveStatus('error');
                            });
                };
                var debouncedAutoSave = debounce(autoSave, 800);

                // --- RENDER & UI UPDATE ---
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
                    document.getElementById('total-quantity').querySelector('strong').textContent = totalQty;
                    document.getElementById('total-amount').querySelector('strong').textContent = formatCurrency(totalAmt);
                };

                var renderUI = function () {
                    document.getElementById('po-header-info').innerHTML =
                            '<p><span class="info-label">PO ID:</span> #' + poData.poId + '</p>' +
                            '<p><span class="info-label">Status:</span> <span id="poStatusBadge" class="badge"></span></p>' +
                            '<p><span class="info-label">Created Date:</span> ' + new Date(poData.orderDate).toLocaleString('vi-VN') + '</p>';

                    document.getElementById('supplierId').value = poData.supplierId || '';
                    document.getElementById('notePrefix').textContent = poData.notePrefix || '';
                    document.getElementById('userNotes').value = poData.userNotes || '';

                    var itemListBody = document.getElementById('po-item-list');
                    itemListBody.innerHTML = itemsInPO.length > 0 ? itemsInPO.map(function (item) {
                        return '<tr data-pod-id="' + item.podId + '">' +
                                '<td>' + item.productName + ' (' + item.size + '/' + item.color + ')</td>' +
                                '<td>' + item.sku + '</td>' +
                                '<td><input type="number" class="form-control quantity-input" value="' + item.quantity + '" min="1"></td>' +
                                '<td><input type="number" class="form-control price-input" value="' + item.unitPrice + '" min="0" step="1000"></td>' +
                                '<td class="subtotal">' + formatCurrency(item.totalPrice) + '</td>' +
                                '<td class="item-actions"></td>' +
                                '</tr>';
                    }).join('') : '<tr id="no-items-row"><td colspan="6" class="text-center">No products in this order.</td></tr>';

                    updateUIForStatus(poData.status);
                    updateTotals();
                };

                var updateUIForStatus = function (status) {
                    poData.status = status;
                    var statusBadge = document.getElementById('poStatusBadge');
                    statusBadge.textContent = status;
                    var statusColors = {Draft: 'bg-secondary', Sent: 'bg-info', Confirmed: 'bg-primary', Delivered: 'bg-success', Cancelled: 'bg-danger'};
                    statusBadge.className = 'badge ' + (statusColors[status] || 'bg-dark');

                    var isEditable = status === 'Draft' || status === 'Sent';
                    document.querySelectorAll('#poForm input, #poForm select, #poForm textarea').forEach(function (el) {
                        el.disabled = !isEditable;
                    });

                    // Reset: Ẩn tất cả các nút hành động, bao gồm cả nút In
                    document.querySelectorAll('.action-btn, #printReceiptBtn').forEach(function (btn) {
                        btn.style.display = 'none';
                    });
                    document.getElementById('add-product-container').innerHTML = '';

                    // Hiển thị các nút dựa trên trạng thái
                    if (status === 'Draft') {
                        document.querySelector('[data-action="sendOrder"]').style.display = 'inline-block';
                        document.querySelector('[data-action="cancelOrder"]').style.display = 'inline-block';
                        document.getElementById('add-product-container').innerHTML = '<button type="button" class="btn btn-info" data-bs-toggle="modal" data-bs-target="#productSelectorModal"><i class="fa-solid fa-magnifying-glass-plus me-1"></i>Search & Add Products</button>';
                    } else if (status === 'Sent') {
                        if (currentUserRole === 'Admin') {
                            document.querySelector('[data-action="confirmOrder"]').style.display = 'inline-block';
                        }
                        document.querySelector('[data-action="cancelOrder"]').style.display = 'inline-block';
                    } else if (status === 'Confirmed') {
                        document.querySelector('[data-action="receiveDelivery"]').style.display = 'inline-block';
                        document.getElementById('printReceiptBtn').style.display = 'inline-block'; // Hiển thị nút in
                    } else if (status === 'Delivered') {
                        document.getElementById('printReceiptBtn').style.display = 'inline-block'; // Vẫn hiển thị nút in
                    }

                    // Xử lý nút xóa cho từng dòng sản phẩm
                    document.querySelectorAll('#po-item-list tr .item-actions').forEach(function (cell) {
                        var podId = cell.closest('tr').dataset.podId;
                        if (status === 'Draft') {
                            cell.innerHTML = '<button type="button" class="btn btn-danger btn-sm" data-action="delete-item" data-pod-id="' + podId + '"><i class="fas fa-trash-alt"></i></button>';
                        } else {
                            cell.innerHTML = '';
                        }
                    });
                };

                // --- EVENT LISTENERS ---
                poForm.addEventListener('input', function (e) {
                    var target = e.target;
                    var podId = null;
                    var updateType = null;
                    var timerKey = null;
                    var valueStr = target.value.trim();
                    if (target.classList.contains('quantity-input')) {
                        // Chỉ validate khi người dùng đã gõ gì đó
                        if (valueStr !== "") {
                            var quantity = parseInt(valueStr, 10);
                            if (isNaN(quantity) || quantity <= 0) {
                                showToast('Quantity must be a positive number.', true);
                                target.value = 1; // Tự động sửa lại thành 1
                            }
                        }
                    }

                    if (target.classList.contains('price-input')) {
                        // Chỉ validate khi người dùng đã gõ gì đó
                        if (valueStr !== "") {
                            var price = parseFloat(valueStr);
                            if (isNaN(price) || price < 0) {
                                showToast('Unit Price cannot be negative.', true);
                                target.value = 0; // Tự động sửa lại thành 0
                            }
                        }
                    }
                    if (target.classList.contains('quantity-input') || target.classList.contains('price-input')) {
                        podId = target.closest('tr').dataset.podId;
                        updateType = target.classList.contains('quantity-input') ? 'quantity' : 'price';
                        timerKey = updateType + '-' + podId; // Tạo key duy nhất, ví dụ: "quantity-101"
                    } else if (target.id === 'poNotes') {
                        updateType = 'notes';
                        timerKey = 'notes'; // Key cho ô notes
                    } else {
                        return; // Bỏ qua nếu không phải input cần auto-save
                    }

                    // Xóa bộ đếm thời gian cũ của CHÍNH Ô NÀY (nếu có)
                    if (inputTimers[timerKey]) {
                        clearTimeout(inputTimers[timerKey]);
                    }

                    // Tạo một bộ đếm thời gian mới cho CHÍNH Ô NÀY
                    inputTimers[timerKey] = setTimeout(function () {
                        if (target.value.trim() !== "") {
                            autoSave(updateType, target.value, podId);
                        }
                    }, 800); // Delay 0.8 giây
                });

                poForm.addEventListener('change', function (e) {
                    if (e.target.id === 'supplierId')
                        autoSave('supplier', e.target.value);
                });
                document.querySelector('.action-buttons').addEventListener('click', function (e) {
                    var button = e.target.closest('.action-btn');
                    if (!button)
                        return;
                    var action = button.dataset.action;

                    // --- LOGIC MỚI: XỬ LÝ RIÊNG CHO NÚT CANCEL/DELETE ---
                    if (action === 'cancelOrder') {
                        if (poData.status === 'Draft') {
                            showModal('Delete Draft Order', 'Are you sure you want to permanently <b>delete</b> this draft order?', function () {
                                sendAjaxRequest('deleteDraft')
                                        .then(function (result) {
                                            if (result) {
                                                showToast(result.message);
                                                setTimeout(function () {
                                                    window.location.href = '${pageContext.request.contextPath}/Admindashboard?action=purchaseorder&module=stock';
                                                }, 1500);
                                            }
                                        })
                                        .catch(function (error) { /* Lỗi đã được xử lý */
                                        });
                            });
                            return; // Dừng lại, không chạy code chung bên dưới
                        }
                    }

                    // --- VALIDATION LOGIC CHO NÚT SEND ---
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
                            var quantityInput = row.querySelector('.quantity-input');
                            var quantity = parseInt(quantityInput.value, 10);
                            if (isNaN(quantity) || quantity <= 0) {
                                showToast('Quantity for "' + item.productName + '" must be a positive number.', true);
                                quantityInput.focus();
                                return;
                            }
                        }
                    }

                    // --- LOGIC CHUNG CHO CÁC NÚT CÒN LẠI ---
                    showModal('Confirmation', 'Are you sure you want to <b>' + action.replace(/([A-Z])/g, ' $1').toLowerCase() + '</b>?', function () {
                        sendAjaxRequest(action)
                                .then(function (result) {
                                    if (result) {
                                        showToast(result.message);
                                        var newStatusMap = {sendOrder: 'Sent', confirmOrder: 'Confirmed', receiveDelivery: 'Delivered', cancelOrder: 'Cancelled'};
                                        if (newStatusMap[action]) {
                                            updateUIForStatus(newStatusMap[action]);
                                        }
                                    }
                                })
                                .catch(function (error) {
                                    console.error("Action failed:", error);
                                });
                    });
                });

                document.getElementById('po-item-list').addEventListener('click', function (e) {
                    var deleteButton = e.target.closest('[data-action="delete-item"]');
                    if (deleteButton) {
                        var podId = deleteButton.dataset.podId;
                        showModal('Delete Item', 'Are you sure?', function () {
                            sendAjaxRequest('deleteItem', {podId: podId})
                                    .then(function () {
                                        itemsInPO = itemsInPO.filter(function (item) {
                                            return item.podId != podId;
                                        });
                                        renderUI();
                                        showToast('Item deleted.');
                                    })
                                    .catch(function (error) {});
                        });
                    }
                });

                // --- LOGIC CHO MODAL CHỌN SẢN PHẨM ---
                var productModalEl = document.getElementById('productSelectorModal');
                var productModal = new bootstrap.Modal(productModalEl);
                var productModalBody = document.getElementById('product-selector-list');
                var productSearchInput = document.getElementById('productSearchInput');
                var pdfIframe = document.getElementById('pdf-iframe');
                printModalEl.addEventListener('show.bs.modal', function () {
                    var pdfUrl = contextPath + '/PurchaseOrder?action=printReceipt&poId=' + poData.poId;
                    console.log("Loading PDF from:", pdfUrl);
                    pdfIframe.src = pdfUrl;
                });

                printModalEl.addEventListener('hidden.bs.modal', function () {
                    pdfIframe.src = 'about:blank';
                });

                productModalEl.addEventListener('show.bs.modal', function () {
                    productModalBody.innerHTML = '<tr><td colspan="5" class="text-center"><i class="fas fa-spinner fa-spin"></i> Loading...</td></tr>';
                    sendAjaxRequest('getProductsForSelection')
                            .then(function (result) {
                                allProducts = result.data;
                                renderProductSelector(allProducts);
                            })
                            .catch(function () {
                                productModalBody.innerHTML = '<tr><td colspan="5" class="text-center text-danger">Failed to load products.</td></tr>';
                            });
                });

                var renderProductSelector = function (products) {
                    var existingVariantIds = itemsInPO.map(function (item) {
                        return item.variantId;
                    });
                    productModalBody.innerHTML = products.map(function (p) {
                        var isAlreadyAdded = existingVariantIds.indexOf(p.variantId) > -1;
                        return '<tr data-product-name="' + p.productName.toLowerCase() + '" data-sku="' + (p.sku || '').toLowerCase() + '"' + (isAlreadyAdded ? ' class="table-secondary"' : '') + '>' +
                                '<td><input type="checkbox" class="select-product-cb" value="' + p.variantId + '"' + (isAlreadyAdded ? ' disabled' : '') + '></td>' +
                                '<td>' + p.productName + '</td>' +
                                '<td>' + (p.sku || 'N/A') + '</td>' +
                                '<td>' + p.size + ' / ' + p.color + '</td>' +
                                '<td>' + p.currentStock + '</td>' +
                                '</tr>';
                    }).join('');
                };

                productSearchInput.addEventListener('keyup', function () {
                    var searchTerm = productSearchInput.value.toLowerCase();
                    document.querySelectorAll('#product-selector-list tr').forEach(function (row) {
                        var name = row.dataset.productName;
                        var sku = row.dataset.sku;
                        row.style.display = (name.indexOf(searchTerm) > -1 || sku.indexOf(searchTerm) > -1) ? '' : 'none';
                    });
                });

                document.getElementById('addSelectedProductsBtn').addEventListener('click', function () {
                    var selectedIds = Array.from(document.querySelectorAll('.select-product-cb:checked')).map(function (cb) {
                        return cb.value;
                    });
                    if (selectedIds.length === 0) {
                        showToast('Please select at least one product.', true);
                        return;
                    }

                    sendAjaxRequest('addProducts', {'variantIds[]': selectedIds})
                            .then(function (result) {
                                itemsInPO = result.data;
                                renderUI();
                                productModal.hide();
                                showToast(result.message);
                            })
                            .catch(function (e) {});
                });

                // --- INITIALIZATION ---
                renderUI();
            });
        </script>
    </body>
</html>