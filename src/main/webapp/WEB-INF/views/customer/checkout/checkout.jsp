<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<!-- ===== Brand theme (#143592) & Payment card styles ===== -->
<style>
    :root{
        --brand:#143592;
        --brand-500:#1b46b0;
        --brand-400:#3b62c0;
        --brand-50:#eef2ff;
        --brand-glow:0 0 0 2px rgba(20,53,146,.15), 0 6px 18px rgba(20,53,146,.18);
    }
    .btn-primary{
        --bs-btn-bg:var(--brand);
        --bs-btn-border-color:var(--brand);
        --bs-btn-hover-bg:var(--brand-500);
        --bs-btn-hover-border-color:var(--brand-500);
        --bs-btn-active-bg:var(--brand);
        --bs-btn-active-border-color:var(--brand);
        box-shadow:0 6px 14px rgba(20,53,146,.25);
    }
    .btn-outline-primary{
        --bs-btn-color:var(--brand);
        --bs-btn-border-color:var(--brand);
        --bs-btn-hover-bg:var(--brand);
        --bs-btn-hover-border-color:var(--brand);
    }
    .form-check-input:checked{
        background-color:var(--brand);
        border-color:var(--brand);
    }
    .badge.bg-primary{
        background-color:var(--brand)!important;
    }

    /* Payment method cards */
    .pm-grid{
        display:grid;
        gap:12px;
    }
    .pm-card{
        position:relative;
        display:flex;
        align-items:center;
        justify-content:space-between;
        gap:16px;
        padding:14px 16px;
        border-radius:16px;
        border:2px solid transparent;
        cursor:pointer;
        outline:none;
        background:linear-gradient(180deg,#fff,#fff) padding-box,
            linear-gradient(135deg, rgba(20,53,146,.2), rgba(59,98,192,.15)) border-box;
        transition:transform .15s ease, box-shadow .15s ease, border-color .15s ease, background .15s ease;
    }
    .pm-card:hover{
        transform:translateY(-1px);
        box-shadow:var(--brand-glow);
    }
    .pm-card:focus-visible{
        box-shadow:var(--brand-glow);
    }
    .pm-card.active{
        border-color:var(--brand);
        box-shadow:var(--brand-glow);
        background:linear-gradient(180deg,#fff,#f7f9ff) padding-box,
            linear-gradient(135deg, var(--brand-400), rgba(20,53,146,.35)) border-box;
    }
    .pm-left{
        display:flex;
        align-items:center;
        gap:12px;
    }
    .pm-logo{
        width:40px;
        height:40px;
        object-fit:contain;
        border-radius:8px;
        background:#fff;
    }
    .pm-title{
        font-weight:700;
        color:#111;
    }
    .pm-desc{
        font-size:.9rem;
        color:#6b7280;
    }
    .pm-right{
        width:28px;
        height:28px;
        border-radius:50%;
        display:grid;
        place-items:center;
        color:#fff;
        background:var(--brand-500);
        opacity:0;
        transform:scale(.8);
        transition:all .15s ease;
    }
    .pm-card.active .pm-right{
        opacity:1;
        transform:scale(1);
    }
    .visually-hidden{
        position:absolute !important;
        width:1px;
        height:1px;
        padding:0;
        margin:-1px;
        overflow:hidden;
        clip:rect(0,0,0,0);
        border:0;
    }
</style>

<div class="container py-4">
    <h2 class="mb-3">Checkout</h2>

    <c:if test="${not empty error}">
        <div class="alert alert-danger">${error}</div>
    </c:if>

    <div class="card mb-3">
        <div class="card-header fw-bold d-flex justify-content-between align-items-center">
            <span>Shipping Address</span>
            <button class="btn btn-outline-primary btn-sm" type="button"
                    data-bs-toggle="collapse" data-bs-target="#addAddressCollapse"
                    aria-expanded="false" aria-controls="addAddressCollapse">+ Add new address</button>
        </div>

        <div class="card-body">
            <form id="placeForm" method="post" action="${pageContext.request.contextPath}/customer/checkout">
                <!-- Only ONE action field -->
                <input type="hidden" name="action" value="placeOrder"/>

                <!-- Extras per mode -->
                <c:if test="${isDraft}">
                    <input type="hidden" name="draftOrderId" value="${draftOrderId}"/>
                </c:if>
                <c:if test="${not isDraft}">
                    <input type="hidden" name="selectedCartItemIds" value="${selectedCartItemIds}"/>
                    <input type="hidden" name="cartItemIds" value="${selectedCartItemIds}"/>
                </c:if>

                <!-- Addresses -->
                <div class="vstack gap-2">
                    <c:choose>
                        <c:when test="${empty addresses}">
                            <div class="text-muted">You have no saved addresses. Click “Add new address” to create one.</div>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="a" items="${addresses}">
                                <label class="border rounded p-2 d-flex align-items-start gap-2 w-100">
                                    <input type="radio" name="shippingAddressId" value="${a.addressId}"
                                           <c:if test="${a['default']}">checked="checked"</c:if> />
                                           <div>
                                               <div class="fw-semibold">
                                               ${a.recipientName}
                                               <span class="text-muted">(${a.phoneNumber})</span>
                                           </div>
                                           <div class="text-muted small">${a.streetAddress}, ${a.wardName}, ${a.provinceName}</div>
                                           <c:if test="${a['default']}"><span class="badge bg-primary">Default</span></c:if>
                                           </div>
                                    </label>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- Quick Add Address -->
                <div class="collapse mt-3" id="addAddressCollapse">
                    <div class="card">
                        <div class="card-header fw-bold">Add new address</div>
                        <div class="card-body">
                            <div id="qaForm" class="row g-3" role="form">
                                <div class="col-md-6">
                                    <label class="form-label">Recipient name *</label>
                                    <input type="text" class="form-control" name="recipientName" required minlength="2" maxlength="80">
                                    <div class="invalid-feedback">Please enter recipient name (2–80 chars).</div>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Phone number *</label>
                                    <input type="tel" class="form-control" name="phoneNumber" required pattern="(\\+84|0)[0-9]{9,10}">
                                    <div class="invalid-feedback">Phone must start with +84 or 0 and have 10–11 digits.</div>
                                </div>
                                <div class="col-12">
                                    <label class="form-label">Street address *</label>
                                    <input type="text" class="form-control" name="streetAddress" required minlength="3" maxlength="200"
                                           placeholder="House no., street...">
                                    <div class="invalid-feedback">Please enter street and house number.</div>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Province *</label>
                                    <select class="form-select" id="qaProvince" name="provinceId" required>
                                        <option value="">-- Select province --</option>
                                    </select>
                                    <div class="invalid-feedback">Please select a province.</div>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Ward *</label>
                                    <select class="form-select" id="qaWard" name="wardId" required disabled>
                                        <option value="">-- Select ward --</option>
                                    </select>
                                    <div class="invalid-feedback">Please select a ward.</div>
                                </div>
                                <div class="col-12">
                                    <div class="form-check">
                                        <input class="form-check-input" type="checkbox" id="qaDefault" name="isDefault" value="true">
                                        <label class="form-check-label" for="qaDefault">Set as default</label>
                                    </div>
                                </div>
                                <div class="col-12 d-flex align-items-center gap-3">
                                    <button type="button" class="btn btn-success" id="qaSubmit">Save address</button>
                                    <small id="qaMsg" class="text-muted"></small>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <hr/>

                <!-- Items -->
                <div class="table-responsive mt-3">
                    <table class="table align-middle">
                        <thead class="table-light">
                            <tr>
                                <th>Product</th>
                                <th style="width:110px;">Size</th>
                                <th style="width:110px;">Color</th>
                                <th style="width:90px;">Qty</th>
                                <th style="width:140px;">Unit</th>
                                <th style="width:160px;">Line Total</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="it" items="${items}">
                                <tr>
                                    <td>
                                        <div class="d-flex align-items-center gap-2">
                                            <img src="${empty it.imageUrl ? 'https://placehold.co/56x56' : it.imageUrl}"
                                                 width="56" height="56" class="rounded"
                                                 onerror="this.src='https://placehold.co/56x56'"/>
                                            <div class="fw-semibold">${it.productName}</div>
                                        </div>
                                    </td>
                                    <td>${it.size}</td>
                                    <td>${it.color}</td>
                                    <td>${it.quantity}</td>
                                    <td>
                                        <span class="money" data-raw="${it.unitPrice}">
                                            <fmt:formatNumber value="${it.unitPrice}" type="number" groupingUsed="true"/>đ
                                        </span>
                                    </td>
                                    <td>
                                        <span class="money" data-raw="${it.totalPrice}">
                                            <fmt:formatNumber value="${it.totalPrice}" type="number" groupingUsed="true"/>đ
                                        </span>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>

                <!-- Voucher -->
                <div class="card mt-3">
                    <div class="card-body">
                        <label class="form-label mb-1">Voucher</label>
                        <div class="row g-2 align-items-center">
                            <div class="col-sm-6 col-md-8">
                                <input type="text" id="voucherCodeInput" name="voucherCode" value="${voucherCode}"
                                       class="form-control" placeholder="Enter voucher code">
                            </div>
                            <div class="col-auto">
                                <button type="button" id="applyVoucherBtn" class="btn btn-outline-primary">Apply</button>
                                <button type="button" id="clearVoucherBtn"
                                        class="btn btn-outline-secondary <c:if test='${empty voucher}'>d-none</c:if>">Remove</button>
                                </div>
                            </div>

                            <small id="voucherStatus" class="text-muted d-block mt-2" aria-live="polite"></small>

                            <div id="voucherApplied" class="mt-2 <c:if test='${empty voucher}'>d-none</c:if>">
                            <c:if test="${not empty voucher}">
                                <div>
                                    <strong id="vName">${fn:escapeXml(voucher.name)}</strong> —
                                    <span class="text-muted">code:</span>
                                    <span id="vCode" class="font-monospace">${fn:escapeXml(voucher.code)}</span>
                                </div>
                                <div class="text-muted">
                                    Type: <span id="vType">${fn:escapeXml(voucherViewType)}</span>,
                                    Value: <span id="vValue">
                                        <c:choose>
                                            <c:when test="${voucherViewType eq 'percentage'}">${voucherViewValue}</c:when>
                                            <c:otherwise><c:out value="${voucherViewValue}"/>đ</c:otherwise>
                                        </c:choose>
                                    </span>
                                </div>
                            </c:if>
                        </div>

                        <div id="voucherError" class="text-danger mt-2 <c:if test='${empty voucherError}'>d-none</c:if>">
                            ${fn:escapeXml(voucherError)}
                        </div>

                        <!-- Wallet -->
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
                </div>

                <!-- Payment Method -->
                <div class="card mt-3">
                    <div class="card-header fw-bold d-flex align-items-center gap-2">
                        <i class="fas fa-credit-card"></i> Payment Method
                    </div>
                    <div class="card-body">
                        <div class="pm-grid">
                            <!-- VNPAY default -->
                            <label class="pm-card active" data-value="VNPAY" tabindex="0" aria-label="Pay with VNPAY">
                                <input type="radio" name="paymentMethod" value="VNPAY" class="visually-hidden" checked>
                                <div class="pm-left">
                                    <img src="${pageContext.request.contextPath}/assets/img/payments/vnpay.svg"
                                         alt="VNPAY" class="pm-logo"
                                         onerror="this.src='https://placehold.co/48x48?text=VNPAY';">
                                    <div>
                                        <div class="pm-title">VNPAY</div>
                                        <div class="pm-desc">Fast and secure payment via VNPAY</div>
                                    </div>
                                </div>
                                <div class="pm-right" aria-hidden="true">
                                    <i class="fas fa-check"></i>
                                </div>
                            </label>
                        </div>
                    </div>
                </div>

                <!-- Totals -->
                <div class="card mt-3">
                    <div class="card-body">
                        <div class="d-flex justify-content-between">
                            <div>Subtotal</div>
                            <div id="subtotal" class="money" data-raw="${empty subtotal ? 0 : subtotal}">
                                <fmt:formatNumber value="${empty subtotal ? 0 : subtotal}" type="number" groupingUsed="true"/>đ
                            </div>
                        </div>
                        <div class="d-flex justify-content-between">
                            <div>Voucher discount</div>
                            <div id="discount" class="money text-danger" data-raw="${empty discount ? 0 : discount}">
                                -<fmt:formatNumber value="${empty discount ? 0 : discount}" type="number" groupingUsed="true"/>đ
                            </div>
                        </div>
                        <hr/>
                        <div class="d-flex justify-content-between fw-bold">
                            <div>Payable</div>
                            <div id="total" class="money" data-raw="${empty total ? 0 : total}">
                                <fmt:formatNumber value="${empty total ? 0 : total}" type="number" groupingUsed="true"/>đ
                            </div>
                        </div>
                    </div>
                </div>

                <div class="mt-3">
                    <label class="form-label">Note (optional)</label>
                    <textarea class="form-control" name="note" rows="2" placeholder="Any notes for this order..."></textarea>
                </div>

                <div class="d-grid gap-2 mt-3">
                    <button type="submit" class="btn btn-primary">Place Order</button>

                    <c:choose>
                        <c:when test="${isDraft}">
                            <a class="btn btn-outline-secondary"
                               href="${pageContext.request.contextPath}/ProductDetail?productId=${items[0].productId}">
                                Back to Product
                            </a>
                        </c:when>
                        <c:otherwise>
                            <a class="btn btn-outline-secondary"
                               href="${pageContext.request.contextPath}/customer/cart">Back to Cart</a>
                        </c:otherwise>
                    </c:choose>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Toast riêng cho quick-add -->
<div class="toast-container position-fixed bottom-0 end-0 p-3"></div>

<script>
    /* ================= Quick Add Address (fix required khi collapse) ================= */
    (function () {
        const base = '${pageContext.request.contextPath}/customer/address';
        const selProvince = document.getElementById('qaProvince');
        const selWard = document.getElementById('qaWard');
        const qaForm = document.getElementById('qaForm'); // container của quick-add
        const qaBtn = document.getElementById('qaSubmit');
        const mainForm = document.getElementById('placeForm');
        let qaInited = false;

        function toast(msg, ok) {
            const c = document.querySelector('.toast-container') || document.body;
            const t = document.createElement('div');
            t.className = 'toast align-items-center text-white ' + (ok ? 'bg-success' : 'bg-danger') + ' border-0';
            t.setAttribute('role', 'alert');
            t.innerHTML = '<div class="d-flex"><div class="toast-body">' + (msg || '') + '</div>'
                    + '<button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button></div>';
            c.appendChild(t);
            (window.bootstrap && bootstrap.Toast) ? new bootstrap.Toast(t, {delay: 3000}).show() : alert(msg);
        }
        function fetchJson(url, opt) {
            return fetch(url, opt || {}).then(r => {
                if (!r.ok)
                    throw new Error('HTTP ' + r.status);
                return r.json();
            });
        }
        function markInvalid(el) {
            el.classList.add('is-invalid');
        }
        function clearInvalid(el) {
            el.classList.remove('is-invalid');
        }

        // >>> QUAN TRỌNG: bật/tắt toàn bộ input trong quick-add
        function setQaDisabled(disabled) {
            if (!qaForm)
                return;
            qaForm.querySelectorAll('input,select,textarea,button').forEach(el => {
                // cho phép bấm nút Save ngay cả khi đang bật (nhưng khi collapsed thì cũng ẩn nên không sao)
                el.disabled = disabled;
            });
        }

        function loadProvinces() {
            if (!selProvince)
                return;
            selProvince.innerHTML = '<option value="">Loading...</option>';
            selProvince.disabled = true;
            return fetchJson(base + '?action=getProvinces')
                    .then(list => {
                        selProvince.innerHTML = '<option value="">-- Select province --</option>';
                        (list || []).forEach(p => {
                            const o = document.createElement('option');
                            o.value = p.code;
                            o.textContent = p.name;
                            selProvince.appendChild(o);
                        });
                    })
                    .catch(() => {
                        selProvince.innerHTML = '<option value="">Load failed</option>';
                    })
                    .finally(() => {
                        selProvince.disabled = false;
                    });
        }
        function loadWards(provinceCode) {
            if (!selWard)
                return;
            selWard.innerHTML = '<option value="">Loading...</option>';
            selWard.disabled = true;
            if (!provinceCode) {
                selWard.innerHTML = '<option value="">-- Select ward --</option>';
                selWard.disabled = false;
                return;
            }
            fetchJson(base + '?action=getWards&id=' + encodeURIComponent(provinceCode))
                    .then(list => {
                        selWard.innerHTML = '<option value="">-- Select ward --</option>';
                        (list || []).forEach(w => {
                            const o = document.createElement('option');
                            o.value = w.code;
                            o.textContent = w.name;
                            selWard.appendChild(o);
                        });
                    })
                    .catch(() => {
                        selWard.innerHTML = '<option value="">Load failed</option>';
                    })
                    .finally(() => {
                        selWard.disabled = false;
                    });
        }
        selProvince && selProvince.addEventListener('change', function () {
            loadWards(this.value);
        });

        function renderAddressRadios(addresses) {
            const container = document.querySelector('.vstack.gap-2');
            if (!container)
                return;
            container.innerHTML = '';
            if (!addresses || !addresses.length) {
                container.innerHTML = '<div class="text-muted">You have no saved addresses. Click “Add new address” to create one.</div>';
                return;
            }
            addresses.forEach((a, idx) => {
                const lbl = document.createElement('label');
                lbl.className = 'border rounded p-2 d-flex align-items-start gap-2 w-100';
                const checked = (a.default === true) || (idx === 0) ? 'checked' : '';
                lbl.innerHTML =
                        '<input type="radio" name="shippingAddressId" value="' + a.addressId + '" ' + checked + ' />' +
                        '<div>' +
                        '<div class="fw-semibold">' + (a.recipientName || '') + ' <span class="text-muted">(' + (a.phoneNumber || '') + ')</span></div>' +
                        '<div class="text-muted small">' + (a.streetAddress || '') + ', ' + (a.wardName || '') + ', ' + (a.provinceName || '') + '</div>' +
                        (a.default ? '<span class="badge bg-primary">Default</span>' : '') +
                        '</div>';
                container.appendChild(lbl);
            });
        }
        function refreshAddresses(selectDefaultAfter) {
            return fetchJson(base + '?action=getAddresses&_=' + Date.now())
                    .then(j => {
                        const list = (j && j.data) ? j.data : [];
                        renderAddressRadios(list);
                        if (selectDefaultAfter) {
                            const r = document.querySelector('input[name="shippingAddressId"]:checked');
                            r && r.scrollIntoView({block: 'nearest'});
                        }
                    })
                    .catch(() => {
                    });
        }

        function validateQA() {
            if (!qaForm)
                return false;
            let ok = true;
            const name = qaForm.querySelector('input[name="recipientName"]');
            const phone = qaForm.querySelector('input[name="phoneNumber"]');
            const street = qaForm.querySelector('input[name="streetAddress"]');
            const prov = qaForm.querySelector('select[name="provinceId"]');
            const ward = qaForm.querySelector('select[name="wardId"]');
            [name, phone, street, prov, ward].forEach(clearInvalid);

            if (!name.value || name.value.trim().length < 2)
                markInvalid(name), ok = false;
            if (!phone.value || !/^(\+84|0)\d{9,10}$/.test(phone.value.trim()))
                markInvalid(phone), ok = false;
            if (!street.value || street.value.trim().length < 3)
                markInvalid(street), ok = false;
            if (!prov.value)
                markInvalid(prov), ok = false;
            if (!ward.value)
                markInvalid(ward), ok = false;

            return ok;
        }

        qaBtn && qaBtn.addEventListener('click', function () {
            if (!validateQA()) {
                toast('Please complete required fields.', false);
                return;
            }
            const btn = qaBtn;
            btn.disabled = true;
            const old = btn.textContent;
            btn.textContent = 'Saving...';

            const f = qaForm;
            const fd = new FormData();
            fd.append('action', 'add');
            fd.append('recipientName', f.querySelector('[name="recipientName"]').value.trim());
            fd.append('phoneNumber', f.querySelector('[name="phoneNumber"]').value.trim());
            fd.append('streetAddress', f.querySelector('[name="streetAddress"]').value.trim());
            fd.append('provinceId', f.querySelector('[name="provinceId"]').value);
            fd.append('wardId', f.querySelector('[name="wardId"]').value);
            if (f.querySelector('#qaDefault').checked)
                fd.append('isDefault', 'true');

            fetch(base, {method: 'POST', headers: {'Accept': 'application/json'}, body: new URLSearchParams(fd)})
                    .then(r => r.json())
                    .then(j => {
                        toast(j.message || (j.success ? 'Saved.' : 'Failed.'), !!j.success);
                        if (j.success) {
                            qaForm.querySelectorAll('input,select').forEach(el => {
                                if (el.type === 'checkbox')
                                    el.checked = false;
                                else
                                    el.value = '';
                            });
                            selWard.innerHTML = '<option value="">-- Select ward --</option>';
                            selWard.disabled = true;
                            refreshAddresses(true);
                        }
                    })
                    .catch(() => toast('Network error.', false))
                    .finally(() => {
                        btn.disabled = false;
                        btn.textContent = old;
                    });
        });

        document.addEventListener('DOMContentLoaded', function () {
            // Mặc định: tắt quick-add để không can thiệp HTML5 validation
            setQaDisabled(true);

            const collapseEl = document.getElementById('addAddressCollapse');
            if (collapseEl && window.bootstrap) {
                collapseEl.addEventListener('shown.bs.collapse', function () {
                    if (!qaInited) {
                        qaInited = true;
                        loadProvinces();
                    }
                    setQaDisabled(false);
                });
                collapseEl.addEventListener('hide.bs.collapse', function () {
                    setQaDisabled(true);
                    qaForm.querySelectorAll('.is-invalid').forEach(clearInvalid);
                });
            }

            // Khi submit đơn hàng (Place Order / Pay), luôn tắt quick-add để tránh chặn submit
            mainForm && mainForm.addEventListener('submit', function () {
                setQaDisabled(true);
            });

            // nạp lại danh sách địa chỉ
            refreshAddresses();
        });
    })();
</script>


<script>
    /* ================= Money + Voucher + Wallet + Payment pick ================= */
    (function () {
        function fmtDot(v) {
            v = Number(v) || 0;
            return v.toString().replace(/\B(?=(\d{3})+(?!\d))/g, '.') + 'đ';
        }
        document.addEventListener('DOMContentLoaded', function () {
            document.querySelectorAll('.money[data-raw]').forEach(function (el) {
                var raw = el.getAttribute('data-raw');
                if (raw !== null && raw !== '')
                    el.textContent = el.id === 'discount' ? '-' + fmtDot(raw) : fmtDot(raw);
            });
        });

        var form = document.getElementById('placeForm');
        var actionInp = form.querySelector('input[name="action"]');
        var applyBtn = document.getElementById('applyVoucherBtn');
        var clearBtn = document.getElementById('clearVoucherBtn');
        var codeInp = document.getElementById('voucherCodeInput');
        var applyMode = false;
        var IS_DRAFT = ${isDraft ? 'true' : 'false'};

        applyBtn && applyBtn.addEventListener('click', function () {
            applyMode = true;
            actionInp.value = IS_DRAFT ? 'reviewDraft' : 'checkoutSelected';
            form.submit();
        });
        clearBtn && clearBtn.addEventListener('click', function () {
            codeInp.value = '';
            applyMode = true;
            actionInp.value = IS_DRAFT ? 'reviewDraft' : 'checkoutSelected';
            form.submit();
        });
        form.addEventListener('submit', function () {
            if (!applyMode)
                actionInp.value = 'placeOrder';
            applyMode = false;
        });

        // Payment card select + change submit text
        var pmCards = document.querySelectorAll('.pm-card');
        var submitBtn = document.querySelector('#placeForm .btn.btn-primary');
        function selectCard(card) {
            pmCards.forEach(function (c) {
                c.classList.toggle('active', c === card);
                var r = c.querySelector('input[name="paymentMethod"]');
                if (r)
                    r.checked = (c === card);
            });
            var val = (card.getAttribute('data-value') || '').toUpperCase();
            if (submitBtn)
                submitBtn.textContent = (val === 'VNPAY') ? 'Pay with VNPAY' : 'Place Order';
        }
        pmCards.forEach(function (card) {
            card.addEventListener('click', function () {
                selectCard(card);
            });
            card.addEventListener('keydown', function (e) {
                if (e.key === 'Enter' || e.key === ' ') {
                    e.preventDefault();
                    selectCard(card);
                }
            });
        });
        // default text for VNPAY
        if (submitBtn)
            submitBtn.textContent = 'Pay with VNPAY';

        // Wallet
        var walletBtn = document.getElementById('toggleWalletBtn');
        var walletWrap = document.getElementById('voucherWallet');
        var walletLoading = document.getElementById('voucherWalletLoading');
        var walletError = document.getElementById('voucherWalletError');
        var walletList = document.getElementById('voucherWalletList');
        var loaded = false;

        function renderWallet(vs) {
            walletList.innerHTML = '';
            if (!vs || !vs.length) {
                walletList.innerHTML = '<div class="text-muted small">No saved vouchers.</div>';
                return;
            }
            vs.forEach(function (v) {
                var col = document.createElement('div');
                col.className = 'col-12';
                var disabled = (v.isUsed === true) || (v.isExpired === true);
                var btn = document.createElement('button');
                btn.type = 'button';
                btn.className = 'btn w-100 d-flex justify-content-between align-items-center ' + (disabled ? 'btn-outline-secondary' : 'btn-outline-success');
                btn.disabled = disabled;

                var left = document.createElement('div');
                left.className = 'text-start';
                left.innerHTML = '<div class="fw-semibold">' + (v.name || 'Voucher') + '</div>' +
                        '<div class="small text-muted">Code: <span class="font-monospace">' + (v.code || '') + '</span></div>';

                var right = document.createElement('div');
                right.className = 'text-end';
                var label = String(v.type).toLowerCase() === 'percentage'
                        ? (((Number(v.value) || 0) <= 1 ? Math.round((Number(v.value) || 0) * 10000) / 100 : (Number(v.value) || 0)) + '%')
                        : fmtDot(v.value);
                right.innerHTML = '<span class="badge bg-light text-dark">' + label + '</span>';

                btn.appendChild(left);
                btn.appendChild(right);
                if (!disabled) {
                    btn.addEventListener('click', function () {
                        document.getElementById('voucherCodeInput').value = v.code || '';
                        actionInp.value = IS_DRAFT ? 'reviewDraft' : 'checkoutSelected';
                        form.submit();
                    });
                } else {
                    btn.title = v.isUsed ? 'Already used' : 'Expired';
                }

                col.appendChild(btn);
                walletList.appendChild(col);
            });
        }

        function loadWallet() {
            walletLoading.classList.remove('d-none');
            walletError.classList.add('d-none');
            walletError.textContent = '';
            walletList.innerHTML = '';
            fetch('${pageContext.request.contextPath}/customer/voucher/saved', {headers: {'Accept': 'application/json'}})
                    .then(function (res) {
                        if (!res.ok) {
                            if (res.status === 401 || res.status === 403)
                                throw new Error('Please log in to view saved vouchers.');
                            throw new Error('Failed to load vouchers. HTTP ' + res.status);
                        }
                        return res.json();
                    })
                    .then(function (json) {
                        walletLoading.classList.add('d-none');
                        renderWallet((json && (json.vouchers || json.data || [])) || []);
                        loaded = true;
                    })
                    .catch(function (e) {
                        walletLoading.classList.add('d-none');
                        walletError.classList.remove('d-none');
                        walletError.textContent = e.message || 'Cannot load saved vouchers.';
                    });
        }

        walletBtn && walletBtn.addEventListener('click', function () {
            var hidden = walletWrap.classList.contains('d-none');
            if (hidden) {
                walletWrap.classList.remove('d-none');
                if (!loaded)
                    loadWallet();
            } else {
                walletWrap.classList.add('d-none');
            }
        });
    })();
</script>

<c:if test="${not empty voucherError}">
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            if (window.showToast)
                window.showToast('${fn:escapeXml(voucherError)}', false);
        });
    </script>
</c:if>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
