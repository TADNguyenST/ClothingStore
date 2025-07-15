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
    <title>Purchase Order Detail #${poData.get("poId")}</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/admin-dashboard/css/admin-css.css">
    <style>
        .info-label { font-weight: bold; color: #555; }
        .box { background-color: #fff; border: 1px solid #ddd; border-radius: 5px; margin-bottom: 20px; }
        .box-header { padding: 15px; border-bottom: 1px solid #ddd; }
        .box-title { margin: 0; font-size: 1.5rem; font-weight: 500; }
        .box-body { padding: 20px; }
        .action-buttons { margin-top: 20px; text-align: right; padding-top: 20px; border-top: 1px solid #eee; }
        .action-buttons .btn { margin-left: 10px; }
        .table-footer { background-color: #f8f9fa; }
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
                <c:if test="${not empty errorMessage}">
                    <div class="alert alert-danger"><i class="fas fa-exclamation-triangle me-1"></i> ${errorMessage}</div>
                </c:if>
                <c:if test="${param.confirm == 'success'}">
                    <div class="alert alert-success"><i class="fas fa-check-circle me-1"></i>Purchase Order confirmed and inventory updated successfully!</div>
                </c:if>
                <c:if test="${param.save == 'success'}">
                    <div class="alert alert-info"><i class="fas fa-save me-1"></i>Draft saved successfully!</div>
                </c:if>

                <div class="mb-4">
                    <p><span class="info-label">PO ID:</span> #${poData.get("poId")}</p>
                    <p><span class="info-label">Status:</span> <span class="badge bg-secondary">${poData.get("status")}</span></p>
                    <p><span class="info-label">Created Date:</span> <fmt:formatDate value="${poData.get('orderDate')}" pattern="HH:mm:ss dd/MM/yyyy"/></p>
                </div>
                <hr>

                <c:if test="${poData.get('status') == 'Draft'}">
                    <a href="PurchaseOrder?action=showProductSelector&poId=${poData.get('poId')}" class="btn btn-info mb-3">
                        <i class="fa-solid fa-magnifying-glass-plus me-1"></i>Search & Add Products
                    </a>
                </c:if>

                <h4 class="mt-4 mb-3">Products in Purchase Order</h4>
                <form action="PurchaseOrder" method="post" id="poForm">
                    <input type="hidden" id="formAction" name="action" value="">
                    <input type="hidden" name="poId" value="${poData.get('poId')}">

                    <div class="mb-4 row">
                        <label for="supplierId" class="col-sm-2 col-form-label"><b>Supplier (*)</b></label>
                        <div class="col-sm-10">
                            <select name="supplierId" id="supplierId" class="form-select" required <c:if test="${poData.get('status') != 'Draft'}">disabled</c:if>>
                                <option value="">-- Select Supplier --</option>
                                <c:forEach var="supplier" items="${suppliers}">
                                    <option value="${supplier.supplierId}" ${poData.get('supplierId') == supplier.supplierId ? 'selected' : ''}>${supplier.name}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>
                    
                    <div class="mb-4 row">
                        <label for="poNotes" class="col-sm-2 col-form-label"><b>Notes</b></label>
                        <div class="col-sm-10">
                            <textarea class="form-control" id="poNotes" name="notes" rows="3" placeholder="Add any notes for this purchase order..." <c:if test="${poData.get('status') != 'Draft'}">disabled</c:if>>${poData.get('notes')}</textarea>
                        </div>
                    </div>
                    <table class="table table-bordered table-hover">
                        <thead>
                            <tr>
                                <th>Product</th>
                                <th>SKU</th>
                                <th>Quantity</th>
                                <th>Unit Price (VND)</th>
                                <th>Subtotal (VND)</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:set var="totalQuantity" value="0"/>
                            <c:set var="totalAmount" value="0"/>
                            <c:forEach var="item" items="${itemsInPO}">
                                <tr>
                                    <td>${item.get("productName")} (${item.get("size")}/${item.get("color")})</td>
                                    <td>${item.get("sku")}</td>
                                    <td><input type="number" class="form-control quantity-input" name="quantity_${item.get('podId')}" value="${item.get('quantity')}" required min="1" <c:if test="${poData.get('status') != 'Draft'}">disabled</c:if>></td>
                                    <td><input type="number" class="form-control price-input" name="price_${item.get('podId')}" value="${item.get('unitPrice')}" required min="0" step="1000" <c:if test="${poData.get('status') != 'Draft'}">disabled</c:if>></td>
                                    <td class="subtotal"><fmt:formatNumber value="${item.get('quantity') * item.get('unitPrice')}" type="number" pattern="#,##0"/></td>
                                    <td>
                                        <c:if test="${poData.get('status') == 'Draft'}">
                                            <button type="button" class="btn btn-danger btn-sm" onclick="showConfirmationModal('Delete Product', 'Are you sure you want to delete this product from the order?', () => { window.location.href = 'PurchaseOrder?action=deleteItem&podId=${item.get('podId')}&poId=${poData.get('poId')}' })">
                                                <i class="fas fa-trash-alt"></i> Delete
                                            </button>
                                        </c:if>
                                    </td>
                                    <c:set var="totalQuantity" value="${totalQuantity + item.get('quantity')}"/>
                                    <c:set var="totalAmount" value="${totalAmount + (item.get('quantity') * item.get('unitPrice'))}"/>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty itemsInPO}">
                                <tr><td colspan="6" class="text-center">No products in this order. Please add products.</td></tr>
                            </c:if>
                        </tbody>
                        <tfoot>
                            <tr class="table-footer">
                                <td colspan="2" class="text-end"><strong>Total:</strong></td>
                                <td id="total-quantity"><strong>${totalQuantity}</strong></td>
                                <td></td>
                                <td id="total-amount"><strong><fmt:formatNumber value="${totalAmount}" type="number" pattern="#,##0"/></strong></td>
                                <td></td>
                            </tr>
                        </tfoot>
                    </table>

                    <div class="action-buttons">
                        <a href="${pageContext.request.contextPath}/PurchaseOrderList" class="btn btn-secondary"><i class="fa fa-arrow-left me-1"></i> Back to List</a>
                        <c:if test="${poData.get('status') == 'Draft'}">
                            <button type="button" class="btn btn-primary" onclick="submitFormAction('saveDraft')">
                                <i class="fas fa-save me-1"></i> Save Draft
                            </button>
                            <button type="button" class="btn btn-success" onclick="submitFormAction('finalize')">
                                <i class="fas fa-check me-1"></i> Confirm & Complete Order
                            </button>
                            <button type="button" class="btn btn-danger" onclick="showConfirmationModal('Cancel Order', 'Are you sure you want to cancel this draft?', () => { window.location.href = 'PurchaseOrder?action=cancel&poId=${poData.get('poId')}' })">
                                <i class="fas fa-times me-1"></i> Cancel Order
                            </button>
                        </c:if>
                    </div>
                </form>
            </div>
        </div>
    </main>
</div>

<div class="modal fade" id="customModal" tabindex="-1" aria-labelledby="modalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header"><h5 class="modal-title" id="modalLabel">Confirmation</h5><button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button></div>
            <div class="modal-body" id="modalBody">...</div>
            <div class="modal-footer"><button type="button" class="btn btn-secondary" data-bs-dismiss="modal" id="modalCancelButton">Cancel</button><button type="button" class="btn btn-primary" id="modalConfirmButton">Confirm</button></div>
        </div>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/moment@2.29.4/moment.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/daterangepicker/daterangepicker.min.js"></script>
<script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', function () {
        const poForm = document.getElementById('poForm');
        const customModalEl = document.getElementById('customModal');
        if (!customModalEl) { console.error('Modal element #customModal not found!'); return; }
        const customModal = new bootstrap.Modal(customModalEl);
        const modalTitle = document.getElementById('modalLabel');
        const modalBody = document.getElementById('modalBody');
        const modalCancelButton = document.getElementById('modalCancelButton');
        let modalConfirmButton = document.getElementById('modalConfirmButton');
        let hasUnsavedChanges = false;

        function updateTotals() {
            let totalQty = 0; let totalAmt = 0;
            poForm.querySelectorAll('tbody tr:not(:has(td[colspan]))').forEach(row => {
                const qtyInput = row.querySelector('.quantity-input');
                const priceInput = row.querySelector('.price-input');
                if (qtyInput && priceInput) {
                    const quantity = parseInt(qtyInput.value, 10) || 0;
                    const price = parseFloat(priceInput.value) || 0;
                    const subtotal = quantity * price;
                    row.querySelector('.subtotal').textContent = subtotal.toLocaleString('vi-VN');
                    totalQty += quantity; totalAmt += subtotal;
                }
            });
            document.getElementById('total-quantity').querySelector('strong').textContent = totalQty;
            document.getElementById('total-amount').querySelector('strong').textContent = totalAmt.toLocaleString('vi-VN');
        }

        function showModal(title, body, onConfirm, isAlert = false) {
            modalTitle.textContent = title; modalBody.innerHTML = body;
            const newConfirmButton = modalConfirmButton.cloneNode(true);
            modalConfirmButton.parentNode.replaceChild(newConfirmButton, modalConfirmButton);
            modalConfirmButton = newConfirmButton;
            modalConfirmButton.addEventListener('click', () => { if (onConfirm) onConfirm(); customModal.hide(); }, { once: true });
            if (isAlert) {
                modalCancelButton.style.display = 'none'; modalConfirmButton.textContent = 'OK'; modalConfirmButton.className = 'btn btn-primary';
            } else {
                modalCancelButton.style.display = 'inline-block'; modalConfirmButton.textContent = 'Confirm';
                if (title.toLowerCase().includes('delete') || title.toLowerCase().includes('cancel') || title.toLowerCase().includes('unsaved')) {
                    modalConfirmButton.className = 'btn btn-danger';
                } else {
                    modalConfirmButton.className = 'btn btn-success';
                }
            }
            customModal.show();
        }

        function handleFormAction(action) {
            document.getElementById('formAction').value = action;
            const doSubmit = () => { hasUnsavedChanges = false; poForm.submit(); };
            if (action === 'finalize') {
                const itemRows = poForm.querySelectorAll('tbody tr:not(:has(td[colspan]))');
                const supplierId = document.getElementById('supplierId').value;
                if (!supplierId) { showModal('Validation Error', 'Please select a supplier before completing the order.', null, true); return; }
                if (itemRows.length === 0) { showModal('Validation Error', 'Cannot complete the order because there are no products.', null, true); return; }
                showModal('Confirm Order Completion', 'Are you sure you want to complete this order? This action will update the inventory and cannot be undone.', doSubmit);
            } else { doSubmit(); }
        }

        // *** START: CẬP NHẬT JAVASCRIPT ĐỂ THEO DÕI Ô NOTES ***
        poForm.addEventListener('input', (e) => {
            // Bao gồm cả #poNotes trong điều kiện kiểm tra
            if (e.target.classList.contains('quantity-input') || e.target.classList.contains('price-input') || e.target.id === 'poNotes') {
                if (!e.target.closest('[disabled]')) {
                    hasUnsavedChanges = true;
                }
            }
            // Chỉ tính lại tổng khi số lượng hoặc giá thay đổi
            if (e.target.classList.contains('quantity-input') || e.target.classList.contains('price-input')) {
                updateTotals();
            }
        });
        // *** END: CẬP NHẬT JAVASCRIPT ***

        poForm.addEventListener('click', (e) => {
            const button = e.target.closest('button[onclick]');
            if (!button) return;
            e.preventDefault();
            const onclickAttr = button.getAttribute('onclick');
            if (onclickAttr.includes("submitFormAction('saveDraft')")) { handleFormAction('saveDraft'); } 
            else if (onclickAttr.includes("submitFormAction('finalize')")) { handleFormAction('finalize'); } 
            else if (onclickAttr.includes('action=cancel')) {
                const url = onclickAttr.match(/window\.location\.href = '(.+?)'/)[1];
                showModal('Cancel Order', '<b>Any unsaved changes will be lost.</b><br>Are you sure you want to cancel this draft?', () => { window.location.href = url; });
            } else if (onclickAttr.includes('action=deleteItem')) {
                const url = onclickAttr.match(/window\.location\.href = '(.+?)'/)[1];
                showModal('Delete Product', '<b>Any unsaved changes will be lost.</b><br>Are you sure you want to delete this product?', () => { window.location.href = url; });
            }
        });

        document.addEventListener('click', function (event) {
            const link = event.target.closest('a[href]');
            if (!link || poForm.contains(link) || !hasUnsavedChanges || link.getAttribute('href').startsWith('#') || link.hasAttribute('data-bs-toggle')) { return; }
            event.preventDefault();
            showModal('Unsaved Changes', 'You have unsaved changes that will be lost. Are you sure you want to leave this page?', () => { hasUnsavedChanges = false; window.location.href = link.href; });
        });

        window.addEventListener('beforeunload', (event) => {
            if (hasUnsavedChanges) { event.preventDefault(); event.returnValue = ''; }
        });

        updateTotals();
    });
</script>
</body>
</html>