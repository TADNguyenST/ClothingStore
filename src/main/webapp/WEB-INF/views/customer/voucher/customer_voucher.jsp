<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="${empty pageTitle ? 'My Vouchers' : pageTitle}" />
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<style>
    :root{
        --primary:#1e3a8a;
        --border:#e5e7eb;
        --bg:#f8fafc;
    }
    .voucher-hero{
        padding: 32px 0 12px;
    }
    .voucher-hero h1{
        color: var(--primary);
        font-weight: 800;
        margin: 0;
    }
    .voucher-hero p{
        color:#475569;
        margin-top:6px;
    }

    .voucher-card{
        position:relative;
        border:1px solid var(--border);
        border-radius:16px;
        background:#fff;
        box-shadow:0 10px 30px rgba(30,58,138,.08);
        overflow:hidden;
        transition:transform .2s ease, box-shadow .2s ease;
    }
    .voucher-card:hover{
        transform: translateY(-2px);
        box-shadow:0 14px 34px rgba(30,58,138,.12);
    }
    .voucher-card.dim{
        filter: grayscale(1);
        opacity:.65;
    }

    .voucher-card .card-top{
        padding:16px 16px 10px;
    }

    .voucher-card .card-mid{
        position:relative;
        margin: 0 16px;
        height:16px;
    }
    .voucher-card .card-mid:before{
        content:"";
        position:absolute;
        left:0;
        right:0;
        top:7px;
        border-top:2px dashed #e2e8f0;
    }
    .voucher-card .cutout-left, .voucher-card .cutout-right{
        content:"";
        position:absolute;
        top:0;
        bottom:0;
        width:18px;
        background: transparent;
    }
    .voucher-card .cutout-left{
        left:-9px;
        border-right: 9px solid transparent;
    }
    .voucher-card .cutout-right{
        right:-9px;
        border-left: 9px solid transparent;
    }

    .voucher-card .card-bottom{
        background:#f8fafc;
        padding:14px 16px;
        display:flex;
        align-items:center;
        justify-content:space-between;
    }
    .voucher-name{
        font-weight:800;
        color:#0f172a;
        margin-right:10px;
    }

    .discount-txt{
        font-weight:900;
        letter-spacing:.5px;
    }
    .discount-txt.percent{
        color:#6d28d9;
    }  /* tím */
    .discount-txt.amount{
        color:#1e3a8a;
    }   /* primary */
    .discount-txt.used{
        color:#64748b;
    }     /* gray */

    .copy-btn.btn{
        border-radius:10px;
    }

    .empty-wrap{
        text-align:center;
        padding:48px 16px;
        border:2px dashed var(--border);
        border-radius:16px;
        background:#fff;
        color:#64748b;
    }
</style>

<section class="voucher-hero">
    <div class="container">
        <h1 class="display-6">${empty heroTitle ? 'My Vouchers' : heroTitle}</h1>
        <p>${empty heroSubtitle ? 'All vouchers you’ve saved to your wallet.' : heroSubtitle}</p>
    </div>
</section>

<div class="container pb-5">
    <!-- Error -->
    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger" role="alert">
            <strong>Error:</strong> ${errorMessage}
        </div>
    </c:if>

    <!-- List -->
    <c:if test="${not empty voucherList}">
        <c:set var="showOnlyAvailable" value="${param.onlyAvailable == 'true' or requestScope.onlyAvailable}" />
        <div class="row g-3">
            <c:forEach var="voucher" items="${voucherList}">
                <c:set var="isAvailable" value="${not voucher.isUsed}" />
                <c:if test="${not showOnlyAvailable or isAvailable}">
                    <div class="col-12 col-md-6 col-lg-4">
                        <div class="voucher-card ${isAvailable ? '' : 'dim'}">
                            <!-- top -->
                            <div class="card-top">
                                <div class="d-flex align-items-start justify-content-between">
                                    <div class="pe-2">
                                        <div class="voucher-name h5 mb-1">${voucher.voucherName}</div>
                                        <div class="text-muted small">
                                            <i class="fa-regular fa-paper-plane me-1"></i>
                                            Sent on
                                            <fmt:formatDate value="${voucher.sentDate}" pattern="dd MMM, yyyy" />
                                        </div>
                                        <c:if test="${not isAvailable and not empty voucher.usedDate}">
                                            <div class="text-muted small mt-1">
                                                <i class="fa-regular fa-circle-check me-1"></i>
                                                Used on
                                                <fmt:formatDate value="${voucher.usedDate}" pattern="dd MMM, yyyy" />
                                            </div>
                                        </c:if>
                                    </div>
                                    <span class="badge ${isAvailable ? 'bg-success-subtle text-success-emphasis' : 'bg-secondary-subtle text-secondary-emphasis'}">
                                        ${isAvailable ? 'Available' : 'Used'}
                                    </span>
                                </div>
                            </div>

                            <!-- dash -->
                            <div class="card-mid">
                                <span class="cutout-left"></span>
                                <span class="cutout-right"></span>
                            </div>

                            <!-- bottom -->
                            <div class="card-bottom">
                                <div class="discount-txt
                                     ${isAvailable ? (voucher.discountType == 'Percentage' ? 'percent' : 'amount') : 'used'} h4 mb-0">
                                    <c:choose>
                                        <c:when test="${voucher.discountType == 'Percentage'}">
                                            ${voucher.discountValue}% OFF
                                        </c:when>
                                        <c:otherwise>
                                            <fmt:formatNumber value="${voucher.discountValue}"
                                                              type="currency" currencySymbol="₫"
                                                              minFractionDigits="0" maxFractionDigits="0"/>
                                        </c:otherwise>
                                    </c:choose>
                                </div>

                                <c:if test="${isAvailable}">
                                    <button class="btn btn-outline-primary copy-btn"
                                            onclick="copyVoucherCode(this, '${voucher.voucherCode}')">
                                        <span class="copy-text">${voucher.voucherCode}</span>
                                        <i class="fa-regular fa-clone ms-1 copy-icon"></i>
                                    </button>
                                </c:if>
                                <c:if test="${not isAvailable}">
                                    <span class="text-muted small fw-semibold">${voucher.voucherCode}</span>
                                </c:if>
                            </div>
                        </div>
                    </div>
                </c:if>
            </c:forEach>
        </div>
    </c:if>

    <!-- Empty -->
    <c:if test="${empty voucherList and empty errorMessage}">
        <div class="empty-wrap">
            <i class="fa-solid fa-ticket fa-2x mb-3" style="color:var(--primary)"></i>
            <h5 class="mb-1">No vouchers found</h5>
            <div class="small">Save public vouchers to your wallet to use them here.</div>
        </div>
    </c:if>
</div>

<script>
    function copyVoucherCode(btn, code) {
        if (!code) return;

        if (!navigator.clipboard) {
            try {
                const ta = document.createElement('textarea');
                ta.value = code;
                document.body.appendChild(ta);
                ta.select();
                document.execCommand('copy');
                document.body.removeChild(ta);
                afterCopyUI(btn);
            } catch (_) {
                alert('Clipboard not available. Please copy manually.');
            }
            return;
        }

        navigator.clipboard.writeText(code).then(function () {
            afterCopyUI(btn);
        }).catch(function () {
            alert('Failed to copy. Please try again.');
        });
    }

    function afterCopyUI(btn) {
        var textEl = btn.querySelector('.copy-text');
        var iconEl = btn.querySelector('.copy-icon');
        var oldText = textEl ? textEl.textContent : null;

        if (textEl) textEl.textContent = 'Copied!';
        if (iconEl) {
            iconEl.classList.remove('fa-clone');
            iconEl.classList.add('fa-check');
        }

        try {
            if (window.showToast) window.showToast('Voucher code copied.', true);
        } catch (_) {}

        setTimeout(function () {
            if (textEl && oldText) textEl.textContent = oldText;
            if (iconEl) {
                iconEl.classList.remove('fa-check');
                iconEl.classList.add('fa-clone');
            }
        }, 1500);
    }
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
