<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="cpath" value="${pageContext.request.contextPath}" />

<style>
    :root{
        --brand:#0E4BF1;
        --ink:#111827;
        --muted:#6b7280;
        --line:#e5e7eb;
        --panel:#fff;
        --bg:#f3f4f6;
        --radius:14px;
        --success:#16a34a;
        --warn:#d97706;
    }
    .wrap{
        margin-left:230px;
        padding:24px;
        background:var(--bg);
        min-height:100vh;
        font-family:Inter,system-ui,-apple-system,Segoe UI,Roboto,Helvetica,Arial
    }
    @media (max-width: 991px){
        .wrap{
            margin-left:0;
            padding:16px
        }
    }
    .crumb{
        margin-bottom:12px
    }
    .btn{
        display:inline-flex;
        align-items:center;
        gap:8px;
        border-radius:10px;
        border:1px solid transparent;
        padding:10px 14px;
        font:700 14px Inter;
        cursor:pointer;
        text-decoration:none
    }
    .btn-ghost{
        background:#fff;
        border:1px solid var(--line);
        color:var(--ink)
    }
    .btn-primary{
        background:var(--brand);
        color:#fff
    }
    .btn-warn{
        background:#fef3c7;
        border:1px solid #f59e0b;
        color:#92400e
    }
    .btn:disabled{
        opacity:.6;
        cursor:not-allowed
    }
    .grid{
        display:grid;
        grid-template-columns:1.2fr .8fr;
        gap:16px
    }
    @media (max-width: 991px){
        .grid{
            grid-template-columns:1fr
        }
    }
    .card{
        background:var(--panel);
        border-radius:var(--radius);
        box-shadow:0 10px 30px rgba(17,24,39,.08)
    }
    .card-h{
        padding:14px 18px;
        border-bottom:1px solid var(--line);
        font-weight:700
    }
    .card-b{
        padding:16px 18px
    }
    .row{
        display:flex;
        justify-content:space-between;
        margin:6px 0;
        color:var(--ink)
    }
    .muted{
        color:var(--muted)
    }
    .chip{
        display:inline-block;
        padding:6px 10px;
        border-radius:999px;
        font:800 11px Inter;
        background:#eef3ff;
        color:#2451f5
    }
    .chip-dark{
        background:#e5e7eb;
        color:#111827
    }
    .chip-success{
        background:#dcfce7;
        color:#166534
    }
    .chip-warn{
        background:#fef3c7;
        color:#92400e
    }
    table{
        width:100%;
        border-collapse:separate;
        border-spacing:0
    }
    thead th{
        text-align:left;
        padding:10px;
        border-bottom:1px solid var(--line);
        color:#475569;
        font:700 12px Inter;
        text-transform:uppercase;
        letter-spacing:.04em
    }
    tbody td{
        padding:12px 10px;
        border-bottom:1px solid var(--line);
        font:500 14px Inter;
        color:#111
    }
    .actions{
        display:flex;
        gap:8px;
        flex-wrap:wrap;
        margin-top:10px
    }
    .notice{
        background:#f1f5f9;
        border:1px dashed #cbd5e1;
        padding:12px 14px;
        border-radius:12px;
        color:#0f172a
    }
</style>

<!-- Sidebar + Header -->
<jsp:include page="/WEB-INF/views/staff/staff-sidebar.jsp" />

<div class="wrap">
    <div class="crumb">
        <a href="${cpath}/Staffdashboard?action=orderList&module=order" class="btn btn-ghost">
            <i class="fa fa-arrow-left"></i> Back to Orders
        </a>
    </div>

    <div class="grid">
        <!-- LEFT: Items -->
        <div class="card">
            <div class="card-h">Order #${order.orderId} · Items</div>
            <div class="card-b" style="overflow:auto">
                <table>
                    <thead>
                        <tr>
                            <th>Product</th>
                            <th style="width:110px;">Size</th>
                            <th style="width:110px;">Color</th>
                            <th style="width:80px;">Qty</th>
                            <th style="width:140px;">Unit Price</th>
                            <th style="width:160px;">Line Total</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="it" items="${items}">
                            <tr>
                                <td>${it.productName}</td>
                                <td>${it.size}</td>
                                <td>${it.color}</td>
                                <td>${it.quantity}</td>
                                <td><fmt:formatNumber value="${it.unitPrice}" type="number" groupingUsed="true"/> ₫</td>
                                <td><fmt:formatNumber value="${it.totalPrice}" type="number" groupingUsed="true"/> ₫</td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- RIGHT: Summary + Status -->
        <div class="card">
            <div class="card-h">Summary & Status</div>
            <div class="card-b">
                <!-- Summary -->
                <div class="row"><span class="muted">Subtotal</span><span><fmt:formatNumber value="${order.subtotal}" type="number" groupingUsed="true"/> ₫</span></div>
                <div class="row"><span class="muted">Discount</span><span class="muted">- <fmt:formatNumber value="${order.discountAmount}" type="number" groupingUsed="true"/> ₫</span></div>
                <div class="row"><span class="muted">Shipping</span><span><fmt:formatNumber value="${order.shippingFee}" type="number" groupingUsed="true"/> ₫</span></div>
                <hr/>
                <div class="row" style="font-weight:800"><span>Total</span><span style="color:var(--brand)"><fmt:formatNumber value="${order.totalPrice}" type="number" groupingUsed="true"/> ₫</span></div>

                <hr/>
                <!-- Current status -->
                <div class="row">
                    <span class="muted">Order Status</span>
                    <span class="chip chip-dark">${order.status}</span>
                </div>
                <div class="row">
                    <span class="muted">Payment Status</span>
                    <span class="chip ${order.paymentStatus eq 'PAID' ? 'chip-success' : (order.paymentStatus eq 'REFUND_PENDING' ? 'chip-warn' : 'chip-dark')}">
                        ${order.paymentStatus}
                    </span>
                </div>

                <c:if test="${not empty order.createdAt}">
                    <div class="row muted" style="margin-top:10px">
                        <span>Created</span>
                        <span>
                            <fmt:timeZone value="GMT+7">
                                <fmt:formatDate value="${order.createdAt}" pattern="yyyy-MM-dd HH:mm"/>
                            </fmt:timeZone>
                        </span>
                    </div>
                </c:if>

                <hr/>

                <!-- Status actions -->
                <c:choose>
                    <%-- Locked when customer canceled --%>
                    <c:when test="${statusLocked}">
                        <div class="notice" style="margin-bottom:10px">
                            This order was canceled by the customer. Order status is locked.
                            <br/>You may only update the payment to <strong>REFUNDED</strong> after refund completion.
                        </div>

                        <c:if test="${canMarkRefunded}">
                            <form method="post" action="${cpath}/StaffOrder" class="actions">
                                <input type="hidden" name="action" value="markRefunded">
                                <input type="hidden" name="orderId" value="${order.orderId}">
                                <button class="btn btn-warn"><i class="fa fa-check-circle"></i> Mark as Refunded</button>
                            </form>
                        </c:if>
                    </c:when>

                    <%-- Normal forward-only flow --%>
                    <c:otherwise>
                        <form method="post" action="${cpath}/StaffOrder">
                            <input type="hidden" name="action" value="updateStatus">
                            <input type="hidden" name="orderId" value="${order.orderId}">
                            <div class="muted" style="margin-bottom:6px">Update Order Status (forward only)</div>
                            <select name="status" class="i" style="width:100%;max-width:260px" required>
                                <option value="">-- Select next status --</option>
                                <c:forEach var="s" items="${nextStatuses}">
                                    <option value="${s}">${s}</option>
                                </c:forEach>
                            </select>
                            <div class="actions">
                                <button class="btn btn-primary" type="submit"><i class="fa fa-save"></i> Save Changes</button>
                            </div>
                        </form>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- Shipping Address -->
        <c:if test="${not empty order.recipientName}">
            <div class="card" style="grid-column:1 / -1">
                <div class="card-h">Shipping Address</div>
                <div class="card-b">
                    <div style="font-weight:700">${order.recipientName} <span class="muted">(${order.phoneNumber})</span></div>
                    <div class="muted" style="margin-top:4px">${order.streetAddress}, ${order.wardName}, ${order.provinceName}</div>
                </div>
            </div>
        </c:if>
    </div>
</div>
