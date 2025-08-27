<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<style>
    :root {
        --brand:#667eea;
    }
    .text-brand{
        color:var(--brand)!important;
    }
    .badge-soft {
        background: rgba(102,126,234,.08);
        color: var(--brand);
        border:1px solid rgba(102,126,234,.18);
    }
    .account-section-container {
        background:#f4f7f6;
        padding:2rem 0;
        font-family:'Jost',sans-serif;
    }
    .sidebar {
        background:#fff;
        border-right:1px solid #e9ecef;
        padding-top:1rem;
        min-height:100%;
        border-radius:12px;
    }
    .list-group-item{
        border:none;
        padding:.75rem 1.25rem;
        background:transparent;
        transition:all .25s;
        border-left:4px solid transparent;
        color:#333;
        font-weight:500;
    }
    .list-group-item.active{
        background:#f8f9fa;
        color:var(--brand);
        border-left-color:var(--brand);
        border-radius:0;
    }
    .list-group-item:hover{
        background:#f0f0f0;
        color:#111;
        border-left-color:#ddd;
    }
    .profile-card{
        background:#fff;
        border-radius:15px;
        box-shadow:0 8px 30px rgba(0,0,0,.07);
        padding:1.25rem;
    }
</style>

<div class="account-section-container">
    <div class="container">
        <div class="row g-3">
            <!-- Sidebar -->
            <div class="col-lg-3">
                <div class="sidebar">
                    <div class="list-group">
                        <a href="${pageContext.request.contextPath}/Profile" class="list-group-item list-group-item-action"><i class="fas fa-user me-2"></i> My Profile</a>
                        <a href="${pageContext.request.contextPath}/customer/address" class="list-group-item list-group-item-action"><i class="fas fa-address-book me-2"></i> Address Book</a>
                        <a href="${pageContext.request.contextPath}/customer/orders" class="list-group-item list-group-item-action active"><i class="fas fa-box-open me-2"></i> My Orders</a>
                        <a href="${pageContext.request.contextPath}/Logout" class="list-group-item list-group-item-action text-danger"><i class="fas fa-sign-out-alt me-2"></i> Logout</a>
                    </div>
                </div>
            </div>

            <!-- Content -->
            <div class="col-lg-9">
                <div class="profile-card">

                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h2 class="mb-0 text-brand">Order #${order.orderId}</h2>
                        <a href="${pageContext.request.contextPath}/customer/orders" class="btn btn-outline-secondary">
                            <i class="fa fa-arrow-left me-1"></i> Back to Orders
                        </a>
                    </div>

                    <!-- Banners: chỉ dựa theo query param để hiển thị đúng 1 lần -->
                    <c:if test="${param.paid == '1'}">
                        <div class="alert alert-success d-flex align-items-center auto-dismiss" role="alert">
                            <i class="fas fa-check-circle me-2"></i>
                            Payment successful. Thank you!
                        </div>
                    </c:if>
                    <c:if test="${param.payfail == '1'}">
                        <div class="alert alert-danger d-flex align-items-center auto-dismiss" role="alert">
                            <i class="fas fa-times-circle me-2"></i>
                            Payment failed or canceled.
                        </div>
                    </c:if>
                    <c:if test="${param.canceled == '1'}">
                        <div class="alert alert-success d-flex align-items-center auto-dismiss" role="alert">
                            <i class="fas fa-check-circle me-2"></i>
                            Order canceled successfully.
                        </div>
                    </c:if>
                    <c:if test="${param.refund_req == '1'}">
                        <div class="alert alert-warning d-flex align-items-center auto-dismiss" role="alert">
                            <i class="fas fa-undo me-2"></i>
                            Cancel requested. A refund will be processed soon.
                        </div>
                    </c:if>
                    <c:if test="${param.cantCancel == '1'}">
                        <div class="alert alert-danger d-flex align-items-center auto-dismiss" role="alert">
                            <i class="fas fa-ban me-2"></i>
                            Unable to cancel this order.
                        </div>
                    </c:if>

                    <div class="row g-3">
                        <div class="col-lg-7">
                            <div class="card">
                                <div class="card-header fw-semibold">Items</div>
                                <div class="card-body">
                                    <div class="table-responsive">
                                        <table class="table align-middle">
                                            <thead class="table-light">
                                                <tr>
                                                    <th>Product</th>
                                                    <th style="width:110px;">Size</th>
                                                    <th style="width:110px;">Color</th>
                                                    <th style="width:80px;">Qty</th>
                                                    <th style="width:140px;">Unit</th>
                                                    <th style="width:160px;">Line Total</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="it" items="${items}">
                                                    <tr>
                                                        <td>
                                                            <div class="d-flex align-items-center gap-2">
                                                                <img src="${empty it.imageUrl ? 'https://placehold.co/56x56' : it.imageUrl}" width="56" height="56" class="rounded" onerror="this.src='https://placehold.co/56x56'"/>
                                                                <div class="fw-semibold">${it.productName}</div>
                                                            </div>
                                                        </td>
                                                        <td>${it.size}</td>
                                                        <td>${it.color}</td>
                                                        <td>${it.quantity}</td>
                                                        <td><fmt:formatNumber value="${it.unitPrice}" type="number" groupingUsed="true"/>đ</td>
                                                        <td><fmt:formatNumber value="${it.totalPrice}" type="number" groupingUsed="true"/>đ</td>
                                                    </tr>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="col-lg-5">
                            <div class="card mb-3">
                                <div class="card-header fw-semibold">Summary</div>
                                <div class="card-body">
                                    <div class="d-flex justify-content-between"><div>Subtotal</div><div><fmt:formatNumber value="${order.subtotal}" type="number" groupingUsed="true"/>đ</div></div>
                                    <div class="d-flex justify-content-between"><div>Discount</div><div class="text-danger">-<fmt:formatNumber value="${order.discountAmount}" type="number" groupingUsed="true"/>đ</div></div>
                                    <div class="d-flex justify-content-between"><div>Shipping</div><div><fmt:formatNumber value="${order.shippingFee}" type="number" groupingUsed="true"/>đ</div></div>
                                    <hr/>
                                    <div class="d-flex justify-content-between fw-bold"><div>Total</div><div class="text-brand"><fmt:formatNumber value="${order.totalPrice}" type="number" groupingUsed="true"/>đ</div></div>
                                </div>
                            </div>

                            <div class="card mb-3">
                                <div class="card-header fw-semibold">Status</div>
                                <div class="card-body">
                                    <div class="mb-2">
                                        Order:
                                        <c:choose>
                                            <c:when test="${order.status=='PENDING'}"><span class="badge badge-soft">PENDING</span></c:when>
                                            <c:when test="${order.status=='PROCESSING'}"><span class="badge bg-primary">PROCESSING</span></c:when>
                                            <c:when test="${order.status=='SHIPPED'}"><span class="badge bg-info">SHIPPED</span></c:when>
                                            <c:when test="${order.status=='COMPLETED'}"><span class="badge bg-success">COMPLETED</span></c:when>
                                            <c:when test="${order.status=='CANCELED'}"><span class="badge bg-secondary">CANCELED</span></c:when>
                                            <c:otherwise><span class="badge bg-light text-dark">${order.status}</span></c:otherwise>
                                        </c:choose>
                                    </div>
                                    <div>
                                        Payment:
                                        <c:choose>
                                            <c:when test="${order.paymentStatus=='PAID'}"><span class="badge bg-success">PAID</span></c:when>
                                            <c:when test="${order.paymentStatus=='FAILED'}"><span class="badge bg-danger">FAILED</span></c:when>
                                            <c:when test="${order.paymentStatus=='REFUND_PENDING'}"><span class="badge bg-warning text-dark">REFUND_PENDING</span></c:when>
                                            <c:when test="${order.paymentStatus=='REFUNDED'}"><span class="badge bg-dark">REFUNDED</span></c:when>
                                            <c:otherwise><span class="badge bg-secondary">${order.paymentStatus}</span></c:otherwise>
                                        </c:choose>
                                    </div>
                                    <c:if test="${not empty order.createdAt}">
                                        <hr/>
                                        <div class="small text-muted">
                                            Created:
                                            <fmt:timeZone value="GMT+7">
                                                <fmt:formatDate value="${order.createdAt}" pattern="yyyy-MM-dd HH:mm"/>
                                            </fmt:timeZone>
                                        </div>
                                    </c:if>
                                </div>

                                <!-- Actions -->
                                <div class="card-footer d-flex gap-2">
                                    <c:if test="${order.status=='PENDING'}">
                                        <form method="post" action="${pageContext.request.contextPath}/customer/orders/cancel"
                                              onsubmit="return confirm('Cancel this order?');">
                                            <input type="hidden" name="orderId" value="${order.orderId}">
                                            <button type="submit" class="btn btn-outline-danger">
                                                Cancel Order
                                            </button>
                                        </form>
                                    </c:if>
                                </div>
                            </div>

                            <c:if test="${not empty order.recipientName}">
                                <div class="card">
                                    <div class="card-header fw-semibold">Shipping Address</div>
                                    <div class="card-body">
                                        <div class="fw-semibold">${order.recipientName} <span class="text-muted">(${order.phoneNumber})</span></div>
                                        <div class="text-muted small">${order.streetAddress}, ${order.wardName}, ${order.provinceName}</div>
                                    </div>
                                </div>
                            </c:if>
                        </div>
                    </div>
                </div>
            </div>

        </div>
    </div>
</div>

<script>
    // Ẩn alert sau 3.5s + xóa tham số URL để lần sau mở lại không hiện nữa
    window.addEventListener('DOMContentLoaded', () => {
        setTimeout(() => {
            document.querySelectorAll('.auto-dismiss').forEach(el => {
                el.style.transition = 'opacity .35s ease';
                el.style.opacity = '0';
                setTimeout(() => el.remove(), 400);
            });
        }, 3500);

        // Xóa param sau khi đã render
        try {
            const url = new URL(window.location.href);
            ['paid', 'payfail', 'canceled', 'refund_req', 'cantCancel'].forEach(k => {
                if (url.searchParams.has(k))
                    url.searchParams.delete(k);
            });
            window.history.replaceState({}, document.title, url.toString());
        } catch (e) {
        }
    });
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
