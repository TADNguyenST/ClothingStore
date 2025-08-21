<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:setLocale value="en_US" />

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
        background: white;
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
        padding-bottom: 0.75rem;
        position: relative;
    }
    .section-title::after {
        content: '';
        position: absolute;
        bottom: -2px;
        left: 0;
        width: 60px;
        height: 2px;
        background: #764ba2;
    }
    .sidebar {
        background: #fff;
        border-right: 1px solid #e9ecef;
        padding: 1rem;
        border-radius: 15px;
        box-shadow: 0 8px 30px rgba(0,0,0,0.07);
    }
    .list-group-item {
        border: none;
        padding: 1rem 1.5rem;
        background: transparent;
        transition: all 0.3s;
        border-left: 4px solid transparent;
        color: #333;
        font-weight: 500;
        border-radius: 8px !important;
        margin-bottom: 0.5rem;
    }
    .list-group-item.active {
        background: #e8eaf6;
        color: #3f51b5;
        border-left-color: #3f51b5;
        font-weight: 700;
    }
    .list-group-item:hover:not(.active) {
        background: #f5f5f5;
        border-left-color: #ddd;
    }
    .btn-profile-action {
        padding: 0.5rem 1rem;
        font-weight: 600;
        border-radius: 50px;
        transition: all 0.3s ease;
    }
    .badge.bg-primary {
        display: inline-block;
    }
</style>

<div class="profile-section-container">
    <div class="container">
        <div class="row">
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

            <div class="col-lg-9">
                <div class="profile-card">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h3 class="section-title mb-0" style="border-bottom: none;">My Address Book</h3>
                        <button class="btn btn-primary btn-profile-action" onclick="openAddModal()">
                            <i class="fas fa-plus me-2"></i>Add New
                        </button>
                    </div>
                    <hr>
                    <div id="address-list-container">
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="addressModal" tabindex="-1" aria-labelledby="modalTitle" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <form id="addressForm">
                <div class="modal-header">
                    <h5 class="modal-title" id="modalTitle"></h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" name="action" id="formAction">
                    <input type="hidden" name="addressId" id="formAddressId">
                    <div class="mb-3"><label for="recipientName" class="form-label">Full Name</label><input type="text" id="recipientName" name="recipientName" class="form-control" required></div>
                    <div class="mb-3"><label for="phoneNumber" class="form-label">Phone Number</label><input type="tel" id="phoneNumber" name="phoneNumber" class="form-control" required pattern="(\\+84|0)[0-9]{9,10}"></div>
                    <div class="row">
                        <div class="col-md-4 mb-3"><label for="province" class="form-label">Province/City</label><select id="province" name="provinceId" class="form-select" required></select></div>
                        <div class="col-md-4 mb-3"><label for="district" class="form-label">District</label><select id="district" name="districtId" class="form-select" required disabled></select></div>
                        <div class="col-md-4 mb-3"><label for="ward" class="form-label">Ward</label><select id="ward" name="wardId" class="form-select" required disabled></select></div>
                    </div>
                    <div class="mb-3"><label for="streetAddress" class="form-label">Street, House Number</label><input type="text" id="streetAddress" name="streetAddress" class="form-control" required></div>
                    <div class="form-check">
                        <input class="form-check-input" type="checkbox" name="isDefault" value="true" id="isDefault">
                        <label class="form-check-label" for="isDefault">Set as default address</label>
                    </div>
                </div>
                <div class="modal-footer"><button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button><button type="submit" class="btn btn-primary">Save Address</button></div>
            </form>
        </div>
    </div>
</div>
<div class="toast-container position-fixed bottom-0 end-0 p-3"></div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
                            /* =========================
                             Biến & hằng số
                             ========================= */
                            const YOUR_BACKEND_URL = '${pageContext.request.contextPath}/customer/address';
                            const addressModal = new bootstrap.Modal(document.getElementById('addressModal'));
                            const form = document.getElementById('addressForm');
                            const provinceSelect = document.getElementById('province');
                            const districtSelect = document.getElementById('district');
                            const wardSelect = document.getElementById('ward');
                            let savedAddresses = [];

                            /* =========================
                             Cache đơn giản (sessionStorage) + TTL
                             ========================= */
                            var TTL_MS = 7 * 24 * 60 * 60 * 1000; // 7 ngày

                            function saveCache(key, data) {
                                try {
                                    sessionStorage.setItem(key, JSON.stringify({ts: Date.now(), data: data}));
                                } catch (e) {
                                }
                            }
                            function loadCache(key) {
                                try {
                                    var raw = sessionStorage.getItem(key);
                                    if (!raw)
                                        return null;
                                    var obj = JSON.parse(raw);
                                    if (!obj || typeof obj.ts !== 'number')
                                        return null;
                                    if (Date.now() - obj.ts > TTL_MS)
                                        return null;
                                    return obj.data;
                                } catch (e) {
                                    return null;
                                }
                            }

                            function fillSelectFromArray(selectElement, items, placeholder) {
                                var current = selectElement.value;
                                selectElement.innerHTML = '<option value="">' + placeholder + '</option>';
                                if (!Array.isArray(items))
                                    items = [];
                                for (var i = 0; i < items.length; i++) {
                                    var item = items[i];
                                    var code = (item.code !== undefined && item.code !== null) ? String(item.code) : '';
                                    selectElement.add(new Option(item.name, code));
                                }
                                if (current) {
                                    for (var j = 0; j < selectElement.options.length; j++) {
                                        if (selectElement.options[j].value === current) {
                                            selectElement.value = current;
                                            break;
                                        }
                                    }
                                }
                                selectElement.disabled = false;
                            }

                            function fetchJsonNoStore(url) {
                                return fetch(url, {cache: 'no-store'}).then(function (res) {
                                    if (!res.ok)
                                        throw new Error('HTTP ' + res.status);
                                    return res.json();
                                });
                            }

                            /* =========================
                             Ensure loaders (có cache)
                             ========================= */
                            function ensureProvincesLoaded() {
                                var cached = loadCache('provinces');
                                if (cached) {
                                    fillSelectFromArray(provinceSelect, cached, 'Select Province');
                                    // stale-while-revalidate âm thầm
                                    fetchJsonNoStore(YOUR_BACKEND_URL + '?action=getProvinces').then(function (fresh) {
                                        if (JSON.stringify(fresh) !== JSON.stringify(cached)) {
                                            saveCache('provinces', fresh);
                                            if (!provinceSelect.value)
                                                fillSelectFromArray(provinceSelect, fresh, 'Select Province');
                                        }
                                    }).catch(function () {});
                                    return Promise.resolve(cached);
                                }
                                provinceSelect.innerHTML = '<option value="">Loading...</option>';
                                provinceSelect.disabled = true;
                                return fetchJsonNoStore(YOUR_BACKEND_URL + '?action=getProvinces')
                                        .then(function (data) {
                                            var items = Array.isArray(data) ? data : (data.districts || data.wards || []);
                                            saveCache('provinces', items);
                                            fillSelectFromArray(provinceSelect, items, 'Select Province');
                                            return items;
                                        })
                                        .catch(function (err) {
                                            console.error('load provinces failed', err);
                                            provinceSelect.innerHTML = '<option value="">Load failed</option>';
                                            provinceSelect.disabled = false;
                                            return [];
                                        });
                            }

                            function ensureDistrictsLoaded(provinceCode) {
                                if (!provinceCode) {
                                    resetDropdowns(true);
                                    return Promise.resolve([]);
                                }
                                var key = 'districts_' + provinceCode;
                                var cached = loadCache(key);
                                districtSelect.disabled = true;
                                if (cached) {
                                    fillSelectFromArray(districtSelect, cached, 'Select District');
                                    // revalidate âm thầm
                                    fetchJsonNoStore(YOUR_BACKEND_URL + '?action=getDistricts&id=' + encodeURIComponent(provinceCode))
                                            .then(function (fresh) {
                                                if (JSON.stringify(fresh) !== JSON.stringify(cached)) {
                                                    saveCache(key, fresh);
                                                    if (!districtSelect.value)
                                                        fillSelectFromArray(districtSelect, fresh, 'Select District');
                                                }
                                            }).catch(function () {});
                                    return Promise.resolve(cached);
                                }
                                districtSelect.innerHTML = '<option value="">Loading...</option>';
                                return fetchJsonNoStore(YOUR_BACKEND_URL + '?action=getDistricts&id=' + encodeURIComponent(provinceCode))
                                        .then(function (data) {
                                            var items = Array.isArray(data) ? data : (data.districts || []);
                                            saveCache(key, items);
                                            fillSelectFromArray(districtSelect, items, 'Select District');
                                            return items;
                                        })
                                        .catch(function (err) {
                                            console.error('load districts failed', err);
                                            districtSelect.innerHTML = '<option value="">Load failed</option>';
                                            districtSelect.disabled = false;
                                            return [];
                                        });
                            }

                            function ensureWardsLoaded(districtCode) {
                                if (!districtCode) {
                                    resetDropdowns(true, true);
                                    return Promise.resolve([]);
                                }
                                var key = 'wards_' + districtCode;
                                var cached = loadCache(key);
                                wardSelect.disabled = true;
                                if (cached) {
                                    fillSelectFromArray(wardSelect, cached, 'Select Ward');
                                    // revalidate âm thầm
                                    fetchJsonNoStore(YOUR_BACKEND_URL + '?action=getWards&id=' + encodeURIComponent(districtCode))
                                            .then(function (fresh) {
                                                if (JSON.stringify(fresh) !== JSON.stringify(cached)) {
                                                    saveCache(key, fresh);
                                                    if (!wardSelect.value)
                                                        fillSelectFromArray(wardSelect, fresh, 'Select Ward');
                                                }
                                            }).catch(function () {});
                                    return Promise.resolve(cached);
                                }
                                wardSelect.innerHTML = '<option value="">Loading...</option>';
                                return fetchJsonNoStore(YOUR_BACKEND_URL + '?action=getWards&id=' + encodeURIComponent(districtCode))
                                        .then(function (data) {
                                            var items = Array.isArray(data) ? data : (data.wards || []);
                                            saveCache(key, items);
                                            fillSelectFromArray(wardSelect, items, 'Select Ward');
                                            return items;
                                        })
                                        .catch(function (err) {
                                            console.error('load wards failed', err);
                                            wardSelect.innerHTML = '<option value="">Load failed</option>';
                                            wardSelect.disabled = false;
                                            return [];
                                        });
                            }

                            /* =========================
                             UI danh sách địa chỉ
                             ========================= */
                            function renderAddressList() {
                                console.log("Rendering addresses:", savedAddresses);
                                const container = document.getElementById('address-list-container');
                                if (!savedAddresses || savedAddresses.length === 0) {
                                    container.innerHTML = '<div class="text-center p-5 border rounded bg-light" style="border-style: dashed!important; color: #6c757d;"><i class="fas fa-map-marker-alt fa-2x mb-3"></i><p>You have no saved addresses.</p></div>';
                                    return;
                                }
                                let listHtml = '';
                                for (var i = 0; i < savedAddresses.length; i++) {
                                    var addr = savedAddresses[i];
                                    console.log("Address ID:", addr.addressId, "Default:", addr.default);
                                    var isDefault = addr.default === true;
                                    var defaultBadge = isDefault ? '<span class="badge bg-primary ms-2">Default</span>' : '';
                                    var setDefaultButton = !isDefault ? '<button type="button" class="btn btn-sm btn-outline-success" onclick="handleSetDefault(' + addr.addressId + ')">Set Default</button>' : '';
                                    var fullAddress = (addr.streetAddress || '') + ', ' + (addr.wardName || 'N/A') + ', ' + (addr.districtName || 'N/A') + ', ' + (addr.provinceName || 'N/A');

                                    listHtml +=
                                            '<div class="card mb-3 shadow-sm">' +
                                            '  <div class="card-body">' +
                                            '    <div class="d-flex justify-content-between align-items-start">' +
                                            '      <div>' +
                                            '        <h5 class="card-title mb-1">' + addr.recipientName + ' ' + defaultBadge + '</h5>' +
                                            '        <p class="card-text text-muted mb-1">' + fullAddress + '</p>' +
                                            '        <p class="card-text text-muted small">Phone: ' + addr.phoneNumber + '</p>' +
                                            '      </div>' +
                                            '      <div class="d-flex align-items-center gap-2 flex-wrap justify-content-end" style="min-width: 200px;">' +
                                            '        <button class="btn btn-sm btn-outline-secondary" onclick="openEditModal(' + addr.addressId + ')">Edit</button>' +
                                            '        ' + setDefaultButton +
                                            '        <button class="btn btn-sm btn-outline-danger" onclick="handleDelete(' + addr.addressId + ')">Delete</button>' +
                                            '      </div>' +
                                            '    </div>' +
                                            '  </div>' +
                                            '</div>';
                                }
                                container.innerHTML = listHtml;
                            }

                            /* =========================
                             Modal Add/Edit
                             ========================= */
                            function openAddModal() {
                                form.reset();
                                document.getElementById('modalTitle').textContent = 'Add New Address';
                                document.getElementById('formAction').value = 'add';
                                document.getElementById('formAddressId').value = '';
                                resetDropdowns();
                                // ⚡ Dùng cache: mượt, không nhấp nháy
                                ensureProvincesLoaded();
                                addressModal.show();
                            }

                            function openEditModal(addressId) {
                                var address = null;
                                for (var i = 0; i < savedAddresses.length; i++) {
                                    if (savedAddresses[i].addressId === addressId) {
                                        address = savedAddresses[i];
                                        break;
                                    }
                                }
                                if (!address) {
                                    showToast('Address not found.', false);
                                    return;
                                }
                                form.reset();
                                document.getElementById('modalTitle').textContent = 'Edit Address';
                                document.getElementById('formAction').value = 'update';
                                document.getElementById('formAddressId').value = address.addressId;
                                document.getElementById('recipientName').value = address.recipientName;
                                document.getElementById('phoneNumber').value = address.phoneNumber;
                                document.getElementById('streetAddress').value = address.streetAddress;
                                document.getElementById('isDefault').checked = address.default === true;

                                // ⚡ Chuỗi load dùng cache
                                ensureProvincesLoaded()
                                        .then(function () {
                                            provinceSelect.value = String(address.provinceCode || '');
                                            return ensureDistrictsLoaded(provinceSelect.value);
                                        })
                                        .then(function () {
                                            districtSelect.value = String(address.districtCode || '');
                                            return ensureWardsLoaded(districtSelect.value);
                                        })
                                        .then(function () {
                                            wardSelect.value = String(address.wardCode || '');
                                        });

                                addressModal.show();
                            }

                            /* =========================
                             Toast & API helper
                             ========================= */
                            function showToast(message, isSuccess) {
                                if (typeof isSuccess === 'undefined')
                                    isSuccess = true;
                                const container = document.querySelector('.toast-container');
                                const toastHTML = '<div class="toast align-items-center text-white ' + (isSuccess ? 'bg-success' : 'bg-danger') + ' border-0" role="alert" aria-live="assertive" aria-atomic="true"><div class="d-flex"><div class="toast-body">' + message + '</div><button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button></div></div>';
                                container.insertAdjacentHTML('beforeend', toastHTML);
                                new bootstrap.Toast(container.lastElementChild, {delay: 3000}).show();
                            }

                            function fetchAPI(url, options) {
                                options = options || {};
                                return fetch(url, options)
                                        .then(function (response) {
                                            if (!response.ok) {
                                                throw new Error('Network response was not ok. Status: ' + response.status);
                                            }
                                            return response.json();
                                        })
                                        .then(function (result) {
                                            if (result.message) {
                                                showToast(result.message, result.success);
                                            }
                                            if (result.success) {
                                                return result.data || [];
                                            }
                                            throw new Error(result.message || 'API call failed');
                                        })
                                        .catch(function (error) {
                                            console.error("API call failed:", error);
                                            showToast('An error occurred. Please try again.', false);
                                            return [];
                                        });
                            }

                            /* =========================
                             CRUD actions
                             ========================= */
                            function loadSavedAddresses() {
                                const container = document.getElementById('address-list-container');
                                container.innerHTML = '<div class="text-center p-5"><i class="fas fa-spinner fa-spin fa-2x"></i><p>Loading addresses...</p></div>';
                                return fetchAPI(YOUR_BACKEND_URL + '?action=getAddresses&_=' + new Date().getTime())
                                        .then(function (data) {
                                            console.log("Loaded addresses:", data);
                                            savedAddresses = data || [];
                                            renderAddressList();
                                        })
                                        .catch(function (error) {
                                            console.error("Failed to load addresses:", error);
                                            showToast('Failed to load addresses. Displaying cached data.', false);
                                            renderAddressList();
                                        });
                            }

                            function handleFormSubmit(event) {
                                event.preventDefault();
                                const body = new URLSearchParams(new FormData(form));
                                console.log("Form data:", body.toString());
                                fetchAPI(YOUR_BACKEND_URL, {
                                    method: 'POST',
                                    body: body,
                                    headers: {'Content-Type': 'application/x-www-form-urlencoded'}
                                }).then(function () {
                                    addressModal.hide();
                                    return loadSavedAddresses();
                                }).catch(function (error) {
                                    console.error("Form submission failed:", error);
                                    showToast('Failed to save address.', false);
                                });
                            }

                            function handleDelete(addressId) {
                                if (confirm('Are you sure you want to delete this address?')) {
                                    fetchAPI(YOUR_BACKEND_URL, {
                                        method: 'POST',
                                        body: new URLSearchParams({action: 'delete', addressId: addressId})
                                    }).then(function () {
                                        return loadSavedAddresses();
                                    });
                                }
                            }

                            function handleSetDefault(addressId) {
                                fetchAPI(YOUR_BACKEND_URL, {
                                    method: 'POST',
                                    body: new URLSearchParams({action: 'setDefault', addressId: addressId})
                                }).then(function () {
                                    return loadSavedAddresses();
                                });
                            }

                            /* =========================
                             Hỗ trợ cũ (wrapper) để giữ tên hàm nếu nơi khác còn gọi
                             ========================= */
                            function loadDistricts() {
                                return ensureDistrictsLoaded(provinceSelect.value);
                            }
                            function loadWards() {
                                return ensureWardsLoaded(districtSelect.value);
                            }

                            function resetDropdowns(keepProvince, keepDistrict) {
                                if (typeof keepDistrict === 'undefined')
                                    keepDistrict = false;
                                if (!keepDistrict) {
                                    districtSelect.innerHTML = '<option value="">Select District</option>';
                                    districtSelect.disabled = true;
                                }
                                wardSelect.innerHTML = '<option value="">Select Ward</option>';
                                wardSelect.disabled = true;
                            }

                            /* =========================
                             Init
                             ========================= */
                            document.addEventListener('DOMContentLoaded', function () {
                                ensureProvincesLoaded(); // ⚡ mượt vì có cache
                                loadSavedAddresses();
                                form.addEventListener('submit', handleFormSubmit);
                                provinceSelect.addEventListener('change', function () {
                                    ensureDistrictsLoaded(provinceSelect.value).then(function () {
                                        wardSelect.innerHTML = '<option value="">Select Ward</option>';
                                        wardSelect.disabled = true;
                                    });
                                });
                                districtSelect.addEventListener('change', function () {
                                    ensureWardsLoaded(districtSelect.value);
                                });
                            });
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
