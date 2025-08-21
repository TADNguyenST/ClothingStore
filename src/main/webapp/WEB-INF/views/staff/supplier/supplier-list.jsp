<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<c:set var="pageTitle" value="Supplier Management" scope="request"/>
<c:set var="currentModule" value="supplier" scope="request"/>
<c:set var="currentUser" value="${sessionScope.admin != null ? sessionScope.admin : sessionScope.staff}"/>
<c:set var="isAdmin" value="${currentUser.role == 'Admin'}"/>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Supplier Management</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css"/>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/admin-dashboard/css/admin-css.css">

        <%-- ================== CSS TÍCH HỢP ================== --%>
        <style>
            .modal {
                display: none;
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background-color: rgba(0, 0, 0, 0.5);
                display: none; /* Sửa lại: Dùng display để ẩn/hiện */
                justify-content: center;
                align-items: center;
                z-index: 1055;
            }
            .modal.is-visible {
                display: flex; /* Hiện modal khi cần */
            }
            .modal-content-custom {
                background: white;
                padding: 25px;
                border-radius: 8px;
                width: 50%;
                max-width: 800px;
                box-shadow: 0 5px 15px rgba(0,0,0,0.3);
                max-height: 90vh;
                overflow-y: auto;
            }
            .po-list-container {
                max-height: 300px;
                overflow-y: auto;
                border: 1px solid #dee2e6;
                border-radius: .375rem;
            }
            .is-invalid {
                border-color: #dc3545;
            }
            .invalid-feedback {
                display: block;
                width: 100%;
                margin-top: .25rem;
                font-size: .875em;
                color: #dc3545;
            }
            /* Thêm style cho table để tối ưu hiển thị */
            .table th, .table td {
                vertical-align: middle;
            }
            .content-area {
        position: relative;
        margin-left: 260px;
        padding: 1.5rem;
        width: calc(100% - 260px);
        transition: all 0.5s ease;
        min-height: 100vh;
    }
    .sidebar.close ~ .content-area {
        margin-left: 88px;
        width: calc(100% - 88px);
    }
    .sidebar.hidden ~ .content-area {
        margin-left: 0;
        width: 100%;
    }
        </style>
    </head>
    <body data-is-admin="${isAdmin}" data-context-path="${pageContext.request.contextPath}">

        <%-- ================== CÁC MODAL (BẢNG NỔI) ================== --%>

        <%-- Modal Form Add/Edit --%>
        <div class="modal" id="supplierFormModal">
            <div class="modal-content-custom">
                <h3 id="formModalTitle">Supplier Form</h3>
                <hr>
                <form id="supplierForm" novalidate>
                    <input type="hidden" name="action" value="save">
                    <input type="hidden" name="id" id="supplierId">

                    <div id="form-errors" class="alert alert-danger" style="display: none;"></div>

                    <div class="mb-3">
                        <label class="form-label">Name (*)</label>
                        <input type="text" name="name" id="supplierName" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Email (*)</label>
                        <input type="email" name="email" id="supplierEmail" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Phone (*)</label>
                        <input type="text" name="phone" id="supplierPhone" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Address (*)</label>
                        <textarea name="address" id="supplierAddress" class="form-control" rows="3" required></textarea>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Status</label>
                        <select name="isActive" id="supplierIsActive" class="form-select">
                            <option value="true">Active</option>
                            <option value="false">Inactive</option>
                        </select>
                    </div>
                    <hr>
                    <button type="submit" class="btn btn-primary">Save</button>
                    <button type="button" class="btn btn-secondary" id="cancelFormBtn">Cancel</button>
                </form>
            </div>
        </div>

        <%-- Modal Chi tiết --%>
        <div class="modal" id="supplierDetailModal">
            <div class="modal-content-custom">
                <h3>Details for: <span id="detailSupplierName" class="text-primary"></span></h3>
                <hr>

                <div class="row mb-3">
                    <div class="col-md-6"><p><strong>Email:</strong> <span id="detailEmail"></span></p><p><strong>Phone:</strong> <span id="detailPhone"></span></p></div>
                    <div class="col-md-6"><p><strong>Address:</strong> <span id="detailAddress"></span></p><p><strong>Status:</strong> <span id="detailStatus"></span></p></div>
                </div>

                <div class="p-3 bg-light rounded border mb-3">
                    <form id="reportFilterForm" class="d-flex gap-2 align-items-end flex-wrap">
                        <input type="hidden" name="id" id="detailSupplierId">
                        <div><label for="startDate" class="form-label-sm fw-bold">From Date</label><input type="date" name="startDate" id="startDate" class="form-control"></div>
                        <div><label for="endDate" class="form-label-sm fw-bold">To Date</label><input type="date" name="endDate" id="endDate" class="form-control"></div>
                        <button type="submit" class="btn btn-primary btn-sm align-self-end">View Report</button>
                    </form>
                </div>

                <ul class="nav nav-tabs" id="supplierDetailTab" role="tablist">
                    <li class="nav-item" role="presentation"><button class="nav-link active" id="financial-tab" data-bs-toggle="tab" data-bs-target="#financial" type="button" role="tab">Financials</button></li>
                    <li class="nav-item" role="presentation"><button class="nav-link" id="products-tab" data-bs-toggle="tab" data-bs-target="#products" type="button" role="tab">Products Supplied</button></li>
                    <li class="nav-item" role="presentation"><button class="nav-link" id="po-tab" data-bs-toggle="tab" data-bs-target="#po" type="button" role="tab">Purchase Orders</button></li>
                </ul>

                <div class="tab-content" id="supplierDetailTabContent">
                    <div class="tab-pane fade show active" id="financial" role="tabpanel">
                        <div class="p-3">
                            <div class="row g-3">
                                <div class="col-md-6"><div class="card card-body text-center"><h6 class="card-title">Delivered Orders</h6><p class="card-text fs-4 fw-bold" id="statsOrderCount">-</p></div></div>
                                <div class="col-md-6"><div class="card card-body text-center"><h6 class="card-title">Total Value</h6><p class="card-text fs-4 fw-bold" id="statsTotalValue">-</p></div></div>
                            </div>
                        </div>
                    </div>

                    <div class="tab-pane fade" id="products" role="tabpanel">
                        <div class="po-list-container p-2"><table class="table table-sm table-striped"><thead><tr><th>Product Name</th><th>SKU</th><th>Total Quantity</th></tr></thead><tbody id="suppliedProductsTableBody"></tbody></table></div>
                    </div>

                    <div class="tab-pane fade" id="po" role="tabpanel">
                        <div class="po-list-container p-2"><table class="table table-sm table-striped"><thead><tr><th>PO ID</th><th>Notes</th><th>Date</th><th>Status</th><th>Action</th></tr></thead><tbody id="poListTableBody"></tbody></table></div>
                    </div>
                </div>
                <hr>
                <button type="button" class="btn btn-secondary" id="closeDetailBtn">Close</button>
            </div>
        </div>

        <%-- ================== MAIN CONTENT ================== --%>

        <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp"/>
        <div class="main-content-wrapper">
            
            <main class="content-area">
                <div class="box">
                    <div class="box-header with-border d-flex justify-content-between align-items-center">
                        <h3 class="box-title mb-0">Suppliers</h3>
                        <c:if test="${isAdmin}">
                            <button id="addSupplierBtn" class="btn btn-success"><i class="fas fa-plus me-1"></i> Add New Supplier</button>
                        </c:if>
                    </div>
                    <div class="box-body table-responsive">
                        <table class="table table-bordered table-hover">
                            <thead><tr><th>Name</th><th>Email</th><th>Phone</th><th>Status</th><th>Actions</th></tr></thead>
                            <tbody id="supplierTableBody">
                                <%-- Dữ liệu sẽ được chèn vào đây bởi JavaScript --%>
                            </tbody>
                        </table>
                    </div>
                </div>
            </main>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
         <script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>

        <%-- ================== JAVASCRIPT TÍCH HỢP ================== --%>
        <script>
            document.addEventListener('DOMContentLoaded', function () {
                // --- DOM Elements & Constants ---
                const isAdmin = document.body.dataset.isAdmin === 'true';
                const contextPath = document.body.dataset.contextPath;
                const supplierTableBody = document.getElementById('supplierTableBody');
                const addSupplierBtn = document.getElementById('addSupplierBtn');
                const formModal = document.getElementById('supplierFormModal');
                const formModalTitle = document.getElementById('formModalTitle');
                const supplierForm = document.getElementById('supplierForm');
                const cancelFormBtn = document.getElementById('cancelFormBtn');
                const formErrorsDiv = document.getElementById('form-errors');
                const detailModal = document.getElementById('supplierDetailModal');
                const closeDetailBtn = document.getElementById('closeDetailBtn');
                const reportFilterForm = document.getElementById('reportFilterForm');

                // --- Helper Functions ---
                const showModal = (modal) => modal.classList.add('is-visible');
                const hideModal = (modal) => modal.classList.remove('is-visible');

                const showToast = (icon, title) => {
                    Swal.fire({
                        toast: true,
                        position: 'top-end',
                        icon: icon,
                        title: title,
                        showConfirmButton: false,
                        timer: 3000,
                        timerProgressBar: true
                    });
                };

                const currencyFormatter = new Intl.NumberFormat('vi-VN', {
                    style: 'currency',
                    currency: 'VND'
                });

                // --- Core Functions ---

                /**
                 * Tải và hiển thị danh sách nhà cung cấp
                 */
                async function loadSuppliers() {
                    supplierTableBody.innerHTML = '<tr><td colspan="5" class="text-center"><div class="spinner-border" role="status"><span class="visually-hidden">Loading...</span></div></td></tr>';
                    try {
                        const url = contextPath + '/Supplier?action=list';
                        const response = await fetch(url);

                        if (!response.ok) {
                            const error = await response.json();
                            throw new Error(error.message || 'HTTP error! status: ' + response.status);
                        }
                        const suppliers = await response.json();

                        supplierTableBody.innerHTML = '';
                        if (!suppliers || suppliers.length === 0) {
                            supplierTableBody.innerHTML = '<tr><td colspan="5" class="text-center">No suppliers found.</td></tr>';
                            return;
                        }

                        suppliers.forEach(s => {
                            const statusBadge = s.isActive ? '<span class="badge bg-success">Active</span>' : '<span class="badge bg-danger">Inactive</span>';
                            let adminButtons = '';
                            if (isAdmin) {
                                const toggleAction = s.isActive ? 'deactivate' : 'reactivate';
                                const toggleBtnClass = s.isActive ? 'btn-danger' : 'btn-success';
                                const toggleBtnText = s.isActive ? 'Deactivate' : 'Reactivate';
                                adminButtons =
                                        '<button class="btn btn-warning btn-sm edit-btn" data-id="' + s.supplierId + '">Edit</button>' +
                                        '<button class="btn ' + toggleBtnClass + ' btn-sm toggle-status-btn" data-id="' + s.supplierId + '" data-action="' + toggleAction + '">' + toggleBtnText + '</button>';
                            }
                            const row =
                                    '<tr>' +
                                    '<td>' + s.name + '</td>' +
                                    '<td>' + s.contactEmail + '</td>' +
                                    '<td>' + s.phoneNumber + '</td>' +
                                    '<td>' + statusBadge + '</td>' +
                                    '<td>' +
                                    '<div class="btn-group" role="group">' +
                                    '<button class="btn btn-info btn-sm detail-btn" data-id="' + s.supplierId + '">Details</button>' +
                                    adminButtons +
                                    '</div>' +
                                    '</td>' +
                                    '</tr>';
                            supplierTableBody.insertAdjacentHTML('beforeend', row);
                        });
                    } catch (error) {
                        console.error('Failed to load suppliers:', error);
                        supplierTableBody.innerHTML = '<tr><td colspan="5" class="text-center text-danger">Error loading data: ' + error.message + '</td></tr>';
                    }
                }

                /**
                 * Mở modal để thêm hoặc sửa nhà cung cấp
                 */
                function openFormModal(supplier = null) {
                    formErrorsDiv.style.display = 'none';
                    supplierForm.reset();
                    document.getElementById('supplierId').value = '';
                    if (supplier) { // Chế độ sửa
                        formModalTitle.textContent = 'Edit Supplier';
                        document.getElementById('supplierId').value = supplier.supplierId;
                        document.getElementById('supplierName').value = supplier.name;
                        document.getElementById('supplierEmail').value = supplier.contactEmail;
                        document.getElementById('supplierPhone').value = supplier.phoneNumber;
                        document.getElementById('supplierAddress').value = supplier.address;
                        document.getElementById('supplierIsActive').value = supplier.isActive.toString();
                    } else { // Chế độ thêm
                        formModalTitle.textContent = 'Add New Supplier';
                    }
                    showModal(formModal);
                }

                /**
                 * Xử lý việc lưu (thêm mới/cập nhật) nhà cung cấp
                 */
                async function handleSaveSupplier(event) {
                    event.preventDefault();
                    const formData = new FormData(supplierForm);
                    const url = contextPath + '/Supplier';

                    let formBody = [];
                    for (const [key, value] of formData.entries()) {
                        const encodedKey = encodeURIComponent(key);
                        const encodedValue = encodeURIComponent(value);
                        formBody.push(encodedKey + "=" + encodedValue);
                    }
                    formBody = formBody.join("&");

                    try {
                        const response = await fetch(url, {
                            method: 'POST',
                            headers: {
                                'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'
                            },
                            body: formBody
                        });

                        const result = await response.json();

                        if (response.ok) {
                            hideModal(formModal);
                            showToast('success', result.message);
                            loadSuppliers();
                        } else {
                            let errorHtml = 'Please correct the following errors:<ul>';
                            result.errors.forEach(err => {
                                errorHtml += '<li>' + err + '</li>';
                            });
                            errorHtml += '</ul>';
                            formErrorsDiv.innerHTML = errorHtml;
                            formErrorsDiv.style.display = 'block';
                        }
                    } catch (error) {
                        console.error('Save failed:', error);
                        showToast('error', 'An unexpected error occurred.');
                    }
                }

                /**
                 * Thay đổi trạng thái (kích hoạt/vô hiệu hóa)
                 */
                async function handleToggleStatus(supplierId, action) {
                    const confirmText = action === 'deactivate' ?
                            'Are you sure you want to deactivate this supplier?' :
                            'Are you sure you want to reactivate this supplier?';

                    const result = await Swal.fire({
                        title: 'Confirm Action',
                        text: confirmText,
                        icon: 'warning',
                        showCancelButton: true,
                        confirmButtonColor: '#0d6efd',
                        cancelButtonColor: '#6c757d',
                        confirmButtonText: 'Yes, proceed!'
                    });

                    if (result.isConfirmed) {
                        try {
                            const url = contextPath + '/Supplier';
                            const body = 'action=' + action + '&id=' + supplierId;

                            const response = await fetch(url, {
                                method: 'POST',
                                headers: {
                                    'Content-Type': 'application/x-www-form-urlencoded'
                                },
                                body: body
                            });

                            const resData = await response.json();
                            if (response.ok) {
                                showToast('success', resData.message);
                                loadSuppliers();
                            } else {
                                showToast('error', resData.message || 'Action failed.');
                            }
                        } catch (error) {
                            console.error('Status toggle failed:', error);
                            showToast('error', 'An error occurred.');
                        }
                    }
                }

                /**
                 * Hiển thị chi tiết nhà cung cấp
                 */
                async function showDetails(supplierId, filterData = null) {
                    const detailTab = new bootstrap.Tab(document.getElementById('financial-tab'));
                    detailTab.show();

                    let url = contextPath + '/Supplier?action=detail&id=' + supplierId;
                    if (filterData) {
                        for (const key in filterData) {
                            if (key !== 'id') {
                                url += '&' + encodeURIComponent(key) + '=' + encodeURIComponent(filterData[key]);
                            }
                        }
                    }

                    try {
                        const response = await fetch(url);
                        if (!response.ok)
                            throw new Error('Supplier not found or error fetching details');
                        const data = await response.json();

                        // Populate basic info
                        document.getElementById('detailSupplierName').textContent = data.supplier.name;
                        document.getElementById('detailEmail').textContent = data.supplier.contactEmail;
                        document.getElementById('detailPhone').textContent = data.supplier.phoneNumber;
                        document.getElementById('detailAddress').textContent = data.supplier.address;
                        document.getElementById('detailStatus').innerHTML = data.supplier.isActive ? '<span class="badge bg-success">Active</span>' : '<span class="badge bg-danger">Inactive</span>';

                        // Populate filter form
                        document.getElementById('detailSupplierId').value = data.supplier.supplierId;
                        document.getElementById('startDate').value = data.startDate;
                        document.getElementById('endDate').value = data.endDate;

                        // Populate financials
                        document.getElementById('statsOrderCount').textContent = data.stats.orderCount || 0;
                        document.getElementById('statsTotalValue').textContent = currencyFormatter.format(data.stats.totalValue || 0);

                        // Populate supplied products table
                        const suppliedProductsBody = document.getElementById('suppliedProductsTableBody');
                        suppliedProductsBody.innerHTML = '';
                        if (data.suppliedProducts && data.suppliedProducts.length > 0) {
                            data.suppliedProducts.forEach(p => {
                                suppliedProductsBody.innerHTML += '<tr><td>' + p.productName + '</td><td>' + p.sku + '</td><td><span class="badge bg-primary rounded-pill">' + p.totalQuantity + '</span></td></tr>';
                            });
                        } else {
                            suppliedProductsBody.innerHTML = '<tr><td colspan="3" class="text-center">No products found in the selected date range.</td></tr>';
                        }

                        // Populate PO list
                        const poListBody = document.getElementById('poListTableBody');
                        poListBody.innerHTML = '';
                        if (data.poList && data.poList.length > 0) {
                            data.poList.forEach(p => {
                                const orderDate = new Date(p.orderDate).toLocaleDateString('vi-VN');
                                poListBody.innerHTML += '<tr><td>#' + p.poId + '</td><td>' + (p.notes || '') + '</td><td>' + orderDate + '</td><td><span class="badge bg-secondary">' + p.status + '</span></td><td><a href="' + contextPath + '/PurchaseOrder?action=edit&poId=' + p.poId + '" class="btn btn-sm btn-outline-primary">View</a></td></tr>';
                            });
                        } else {
                            poListBody.innerHTML = '<tr><td colspan="5" class="text-center">No purchase orders found.</td></tr>';
                        }

                        showModal(detailModal);
                    } catch (error) {
                        console.error('Failed to load details:', error);
                        showToast('error', 'Could not load supplier details.');
                }
                }

                // --- Event Listeners ---
                if (addSupplierBtn) {
                    addSupplierBtn.addEventListener('click', () => openFormModal());
                }

                cancelFormBtn.addEventListener('click', () => hideModal(formModal));
                closeDetailBtn.addEventListener('click', () => hideModal(detailModal));
                supplierForm.addEventListener('submit', handleSaveSupplier);

                supplierTableBody.addEventListener('click', async (event) => {
                    const button = event.target.closest('button');
                    if (!button)
                        return;

                    const supplierId = button.dataset.id;

                    if (button.classList.contains('edit-btn')) {
                        const url = contextPath + '/Supplier?action=detail&id=' + supplierId;
                        const response = await fetch(url);
                        const data = await response.json();
                        openFormModal(data.supplier);
                    } else if (button.classList.contains('detail-btn')) {
                        showDetails(supplierId);
                    } else if (button.classList.contains('toggle-status-btn')) {
                        const action = button.dataset.action;
                        handleToggleStatus(supplierId, action);
                    }
                });

                reportFilterForm.addEventListener('submit', (event) => {
                    event.preventDefault();
                    const formData = new FormData(reportFilterForm);
                    const supplierId = formData.get('id');
                    showDetails(supplierId, Object.fromEntries(formData));
                });

                document.addEventListener('keydown', (event) => {
                    if (event.key === 'Escape') {
                        hideModal(formModal);
                        hideModal(detailModal);
                    }
                });

                // --- Initial Load ---
                loadSuppliers();
            });
        </script>
    </body>
</html>