<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="Address Book" scope="request"/>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<style>
    body {
        background-color: #f8f9fa;
        font-family: 'Jost', sans-serif;
    }
    .profile-section-container {
        background: #f4f7f6;
        padding: 2rem 0;
    }
    .profile-card {
        background: #fff;
        border-radius: 15px;
        box-shadow: 0 8px 30px rgba(0,0,0,0.07);
        padding: 2rem;
    }
    .section-title {
        font-size: 1.5rem;
        font-weight: 600;
        color: #333;
        margin-bottom: 1.5rem;
        border-bottom: 2px solid #667eea;
        padding-bottom: .75rem;
        position: relative;
    }
    .section-title::after {
        content:'';
        position:absolute;
        bottom:-2px;
        left:0;
        width:60px;
        height:2px;
        background:#764ba2;
    }
    .sidebar {
        background:#fff;
        border-right:1px solid #e9ecef;
        padding:1rem;
        border-radius:15px;
        box-shadow:0 8px 30px rgba(0,0,0,0.07);
    }
    .list-group-item {
        border:none;
        padding:1rem 1.5rem;
        background:transparent;
        transition:.3s;
        border-left:4px solid transparent;
        color:#333;
        font-weight:500;
        border-radius:8px!important;
        margin-bottom:.5rem;
    }
    .list-group-item.active {
        background:#e8eaf6;
        color:#3f51b5;
        border-left-color:#3f51b5;
        font-weight:700;
    }
    .list-group-item:hover:not(.active) {
        background:#f5f5f5;
        border-left-color:#ddd;
    }
    .btn-profile-action {
        padding:.5rem 1rem;
        font-weight:600;
        border-radius:50px;
        transition:.3s;
    }
    .badge.bg-primary {
        display:inline-block;
    }
</style>

<div class="profile-section-container">
    <div class="container">
        <div class="row">
            <!-- Sidebar -->
            <div class="col-lg-3 mb-4 mb-lg-0">
                <div class="sidebar">
                    <div class="list-group">
                        <a href="${pageContext.request.contextPath}/Profile" class="list-group-item list-group-item-action">
                            <i class="fas fa-user me-2"></i> My Profile
                        </a>
                        <a href="${pageContext.request.contextPath}/customer/address" class="list-group-item list-group-item-action active" aria-current="true">
                            <i class="fas fa-address-book me-2"></i> Address Book
                        </a>
                        <a href="${pageContext.request.contextPath}/orders" class="list-group-item list-group-item-action">
                            <i class="fas fa-box-open me-2"></i> My Orders
                        </a>
                        <a href="${pageContext.request.contextPath}/Logout" class="list-group-item list-group-item-action text-danger">
                            <i class="fas fa-sign-out-alt me-2"></i> Logout
                        </a>
                    </div>
                </div>
            </div>

            <!-- Content -->
            <div class="col-lg-9">
                <div class="profile-card">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h3 class="section-title mb-0" style="border-bottom:none;">My Address Book</h3>
                        <button class="btn btn-primary btn-profile-action" onclick="openAddModal()">
                            <i class="fas fa-plus me-2"></i>Add New
                        </button>
                    </div>
                    <hr>
                    <div id="address-list-container"></div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Modal Add/Edit -->
<div class="modal fade" id="addressModal" tabindex="-1" aria-labelledby="modalTitle" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <form id="addressForm" novalidate>
                <div class="modal-header">
                    <h5 class="modal-title" id="modalTitle"></h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" name="action" id="formAction">
                    <input type="hidden" name="addressId" id="formAddressId">

                    <div class="mb-3">
                        <label for="recipientName" class="form-label">Full Name</label>
                        <input type="text" id="recipientName" name="recipientName" class="form-control" required>
                        <div class="invalid-feedback">Please enter recipient name.</div>
                    </div>

                    <div class="mb-3">
                        <label for="phoneNumber" class="form-label">Phone Number</label>
                        <input type="tel" id="phoneNumber" name="phoneNumber" class="form-control"
                               required pattern="(\+84|0)[0-9]{9,10}">
                        <div class="invalid-feedback">Phone number must start with +84 or 0 and have 10–11 digits.</div>
                    </div>

                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label for="province" class="form-label">Province/City</label>
                            <select id="province" name="provinceId" class="form-select" required></select>
                            <div class="invalid-feedback">Please select a province.</div>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label for="ward" class="form-label">Ward</label>
                            <select id="ward" name="wardId" class="form-select" required disabled></select>
                            <div class="invalid-feedback">Please select a ward.</div>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label for="streetAddress" class="form-label">Street, House Number</label>
                        <input type="text" id="streetAddress" name="streetAddress" class="form-control" required>
                        <div class="invalid-feedback">Please enter street and house number.</div>
                    </div>

                    <div class="form-check">
                        <input class="form-check-input" type="checkbox" name="isDefault" value="true" id="isDefault">
                        <label class="form-check-label" for="isDefault">Set as default address</label>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    <button type="submit" class="btn btn-primary">Save Address</button>
                </div>
            </form>
        </div>
    </div>
</div>

<div class="toast-container position-fixed bottom-0 end-0 p-3"></div>

<script>
    const YOUR_BACKEND_URL = '${pageContext.request.contextPath}/customer/address';
    const form = document.getElementById('addressForm');
    const provinceSelect = document.getElementById('province');
    const wardSelect = document.getElementById('ward');
    let savedAddresses = [];

    /* Lazy init Bootstrap Modal (tránh lỗi khi bundle chưa sẵn sàng) */
    let addressModal;
    function ensureModal() {
        if (!addressModal) {
            if (!window.bootstrap || !bootstrap.Modal) {
                console.error('Bootstrap bundle not loaded yet');
                return null;
            }
            addressModal = new bootstrap.Modal(document.getElementById('addressModal'));
        }
        return addressModal;
    }

    /* Cache sessionStorage + TTL */
    const TTL_MS = 7 * 24 * 60 * 60 * 1000;
    function saveCache(k, d) {
        try {
            sessionStorage.setItem(k, JSON.stringify({ts: Date.now(), data: d}))
        } catch (e) {
        }
    }
    function loadCache(k) {
        try {
            const raw = sessionStorage.getItem(k);
            if (!raw)
                return null;
            const o = JSON.parse(raw);
            if (!o || typeof o.ts !== 'number')
                return null;
            if (Date.now() - o.ts > TTL_MS)
                return null;
            return o.data;
        } catch (e) {
            return null;
        }
    }

    function fillSelectFromArray(sel, items, placeholder) {
        const cur = sel.value;
        sel.innerHTML = '<option value="">' + placeholder + '</option>';
        if (!Array.isArray(items))
            items = [];
        for (let i = 0; i < items.length; i++) {
            const it = items[i], code = (it.code != null) ? String(it.code) : '';
            sel.add(new Option(it.name, code));
        }
        if (cur) {
            for (let j = 0; j < sel.options.length; j++) {
                if (sel.options[j].value === cur) {
                    sel.value = cur;
                    break;
                }
            }
        }
        sel.disabled = false;
    }
    function fetchJsonNoStore(url) {
        return fetch(url, {cache: 'no-store'}).then(r => {
            if (!r.ok)
                throw new Error('HTTP ' + r.status);
            return r.json();
        });
    }

    /* Loaders */
    function ensureProvincesLoaded() {
        const cached = loadCache('provinces');
        if (cached) {
            fillSelectFromArray(provinceSelect, cached, 'Select Province');
            fetchJsonNoStore(YOUR_BACKEND_URL + '?action=getProvinces').then(fresh => {
                if (JSON.stringify(fresh) !== JSON.stringify(cached)) {
                    saveCache('provinces', fresh);
                    if (!provinceSelect.value)
                        fillSelectFromArray(provinceSelect, fresh, 'Select Province');
                }
            }).catch(() => {
            });
            return Promise.resolve(cached);
        }
        provinceSelect.innerHTML = '<option value="">Loading...</option>';
        provinceSelect.disabled = true;
        return fetchJsonNoStore(YOUR_BACKEND_URL + '?action=getProvinces')
                .then(data => {
                    saveCache('provinces', data);
                    fillSelectFromArray(provinceSelect, data, 'Select Province');
                    return data;
                })
                .catch(err => {
                    console.error('load provinces failed', err);
                    provinceSelect.innerHTML = '<option value="">Load failed</option>';
                    provinceSelect.disabled = false;
                    return [];
                });
    }

    function ensureWardsLoaded(provinceCode) {
        if (!provinceCode) {
            wardSelect.innerHTML = '<option value="">Select Ward</option>';
            wardSelect.disabled = true;
            return Promise.resolve([]);
        }
        const key = 'wards_' + provinceCode;
        const cached = loadCache(key);
        wardSelect.disabled = true;
        if (cached) {
            fillSelectFromArray(wardSelect, cached, 'Select Ward');
            fetchJsonNoStore(YOUR_BACKEND_URL + '?action=getWards&id=' + encodeURIComponent(provinceCode))
                    .then(fresh => {
                        if (JSON.stringify(fresh) !== JSON.stringify(cached)) {
                            saveCache(key, fresh);
                            if (!wardSelect.value)
                                fillSelectFromArray(wardSelect, fresh, 'Select Ward');
                        }
                    }).catch(() => {
            });
            return Promise.resolve(cached);
        }
        wardSelect.innerHTML = '<option value="">Loading...</option>';
        return fetchJsonNoStore(YOUR_BACKEND_URL + '?action=getWards&id=' + encodeURIComponent(provinceCode))
                .then(data => {
                    saveCache(key, data);
                    fillSelectFromArray(wardSelect, data, 'Select Ward');
                    return data;
                })
                .catch(err => {
                    console.error('load wards failed', err);
                    wardSelect.innerHTML = '<option value="">Load failed</option>';
                    wardSelect.disabled = false;
                    return [];
                });
    }

    /* UI list */
    function renderAddressList() {
        const container = document.getElementById('address-list-container');
        if (!savedAddresses || savedAddresses.length === 0) {
            container.innerHTML = '<div class="text-center p-5 border rounded bg-light" style="border-style:dashed!important;color:#6c757d;"><i class="fas fa-map-marker-alt fa-2x mb-3"></i><p>You have no saved addresses.</p></div>';
            return;
        }
        let html = '';
        const onlyOne = savedAddresses.length <= 1;
        for (let i = 0; i < savedAddresses.length; i++) {
            const a = savedAddresses[i];
            const isDefault = a.default === true;
            const badge = isDefault ? '<span class="badge bg-primary ms-2">Default</span>' : '';
            const setDefaultBtn = !isDefault ? '<button type="button" class="btn btn-sm btn-outline-success" onclick="handleSetDefault(' + a.addressId + ')">Set Default</button>' : '';
            const delBtn = '<button class="btn btn-sm btn-outline-danger" ' + (onlyOne ? 'disabled ' : '') + 'onclick="handleDelete(' + a.addressId + ')">Delete</button>';
            const full = (a.streetAddress || '') + ', ' + (a.wardName || 'N/A') + ', ' + (a.provinceName || 'N/A');
            html += '<div class="card mb-3 shadow-sm"><div class="card-body">' +
                    '<div class="d-flex justify-content-between align-items-start">' +
                    '<div><h5 class="card-title mb-1">' + a.recipientName + ' ' + badge + '</h5>' +
                    '<p class="card-text text-muted mb-1">' + full + '</p>' +
                    '<p class="card-text text-muted small">Phone: ' + a.phoneNumber + '</p></div>' +
                    '<div class="d-flex align-items-center gap-2 flex-wrap justify-content-end" style="min-width:200px;">' +
                    '<button class="btn btn-sm btn-outline-secondary" onclick="openEditModal(' + a.addressId + ')">Edit</button>' +
                    setDefaultBtn + delBtn +
                    '</div></div></div></div>';
        }
        container.innerHTML = html;
    }

    /* Modal */
    function openAddModal() {
        form.reset();
        document.getElementById('modalTitle').textContent = 'Add New Address';
        document.getElementById('formAction').value = 'add';
        document.getElementById('formAddressId').value = '';
        wardSelect.innerHTML = '<option value="">Select Ward</option>';
        wardSelect.disabled = true;
        ensureProvincesLoaded();
        const m = ensureModal();
        if (!m)
            return;
        m.show();
    }
    function openEditModal(id) {
        const a = savedAddresses.find(x => x.addressId === id);
        if (!a) {
            showToast('Address not found.', false);
            return;
        }
        form.reset();
        document.getElementById('modalTitle').textContent = 'Edit Address';
        document.getElementById('formAction').value = 'update';
        document.getElementById('formAddressId').value = a.addressId;
        document.getElementById('recipientName').value = a.recipientName;
        document.getElementById('phoneNumber').value = a.phoneNumber;
        document.getElementById('streetAddress').value = a.streetAddress;
        document.getElementById('isDefault').checked = a.default === true;

        ensureProvincesLoaded().then(() => {
            provinceSelect.value = String(a.provinceCode || '');
            return ensureWardsLoaded(provinceSelect.value);
        }).then(() => {
            wardSelect.value = String(a.wardCode || '');
        });

        const m = ensureModal();
        if (!m)
            return;
        m.show();
    }

    /* Toast & API helpers */
    function showToast(msg, ok) {
        const c = document.querySelector('.toast-container');
        if (!window.bootstrap || !bootstrap.Toast) {
            alert(msg || (ok ? 'OK' : 'Error'));
            return;
        }
        const t = '<div class="toast align-items-center text-white ' + (ok ? 'bg-success' : 'bg-danger') + ' border-0" role="alert" aria-live="assertive" aria-atomic="true"><div class="d-flex"><div class="toast-body">' + (msg || '') + '</div><button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button></div></div>';
        c.insertAdjacentHTML('beforeend', t);
        new bootstrap.Toast(c.lastElementChild, {delay: 3000}).show();
    }
    function fetchAPI(url, opt) {
        opt = opt || {};
        return fetch(url, opt).then(r => {
            if (!r.ok)
                throw new Error('HTTP ' + r.status);
            return r.json();
        })
                .then(j => {
                    if (j.message)
                        showToast(j.message, j.success);
                    if (j.success)
                        return j.data || [];
                    throw new Error(j.message || 'API failed');
                })
                .catch(e => {
                    console.error(e);
                    showToast('An error occurred. Please try again.', false);
                    return [];
                });
    }

    /* CRUD */
    function loadSavedAddresses() {
        const container = document.getElementById('address-list-container');
        container.innerHTML = '<div class="text-center p-5"><i class="fas fa-spinner fa-spin fa-2x"></i><p>Loading addresses...</p></div>';
        return fetchAPI(YOUR_BACKEND_URL + '?action=getAddresses&_=' + Date.now())
                .then(data => {
                    savedAddresses = data || [];
                    renderAddressList();
                })
                .catch(() => {
                    renderAddressList();
                });
    }
    function handleFormSubmit(e) {
        e.preventDefault();
        if (!form.checkValidity()) {
            form.reportValidity();
            return;
        }
        const body = new URLSearchParams(new FormData(form));
        fetchAPI(YOUR_BACKEND_URL, {method: 'POST', body, headers: {'Content-Type': 'application/x-www-form-urlencoded'}})
                .then(() => {
                    const m = ensureModal();
                    if (m)
                        m.hide();
                    return loadSavedAddresses();
                });
    }
    function handleDelete(id) {
        if (savedAddresses.length <= 1) {
            showToast('You must keep at least one address.', false);
            return;
        }
        if (confirm('Are you sure you want to delete this address?')) {
            fetchAPI(YOUR_BACKEND_URL, {method: 'POST', body: new URLSearchParams({action: 'delete', addressId: id})})
                    .then(() => loadSavedAddresses());
        }
    }
    function handleSetDefault(id) {
        fetchAPI(YOUR_BACKEND_URL, {method: 'POST', body: new URLSearchParams({action: 'setDefault', addressId: id})})
                .then(() => loadSavedAddresses());
    }

    /* Init */
    document.addEventListener('DOMContentLoaded', function () {
        ensureProvincesLoaded();
        loadSavedAddresses();
        form.addEventListener('submit', handleFormSubmit);
        provinceSelect.addEventListener('change', function () {
            ensureWardsLoaded(provinceSelect.value);
        });
    });
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
