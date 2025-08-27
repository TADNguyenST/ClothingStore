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
    .btn-brand{
        background:var(--brand);
        color:#fff;
        border:none;
    }
    .btn-brand:hover{
        opacity:.92;
        color:#fff;
    }
    .badge-soft {
        background: rgba(102,126,234,.08);
        color: var(--brand);
        border: 1px solid rgba(102,126,234,.18);
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
    .list-group-item {
        border:none;
        padding:.75rem 1.25rem;
        background:transparent;
        transition:all .25s;
        border-left:4px solid transparent;
        color:#333;
        font-weight:500;
    }
    .list-group-item.active {
        background:#f8f9fa;
        color:var(--brand);
        border-left-color:var(--brand);
        border-radius:0;
    }
    .list-group-item:hover {
        background:#f0f0f0;
        color:#111;
        border-left-color:#ddd;
    }

    .profile-card {
        background:#fff;
        border-radius:15px;
        box-shadow:0 8px 30px rgba(0,0,0,.07);
        padding:1.25rem;
    }
    .nav-pills .nav-link {
        color:#334155;
        border:1px solid #e5e7eb;
        margin-right:.5rem;
    }
    .nav-pills .nav-link.active {
        background:var(--brand);
        color:#fff;
        border-color:var(--brand);
    }
    .table thead th {
        white-space:nowrap;
    }
</style>

<div class="account-section-container">
    <div class="container">
        <div class="row g-3">
            <!-- Sidebar -->
            <div class="col-lg-3">
                <div class="sidebar">
                    <div class="list-group">
                        <a href="${pageContext.request.contextPath}/Profile" class="list-group-item list-group-item-action">
                            <i class="fas fa-user me-2"></i> My Profile
                        </a>
                        <a href="${pageContext.request.contextPath}/customer/address" class="list-group-item list-group-item-action">
                            <i class="fas fa-address-book me-2"></i> Address Book
                        </a>
                        <a href="${pageContext.request.contextPath}/customer/orders" class="list-group-item list-group-item-action active">
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
                        <h2 class="mb-0 text-brand">My Orders</h2>
                        <a href="${pageContext.request.contextPath}/home" class="btn btn-outline-secondary">
                            <i class="fa fa-arrow-left me-1"></i> Continue Shopping
                        </a>
                    </div>

                    <!-- Filters -->
                    <ul class="nav nav-pills mb-3">
                        <li class="nav-item"><a class="nav-link ${status=='all'?'active':''}" href="?status=all">All</a></li>
                        <li class="nav-item"><a class="nav-link ${status=='PENDING'?'active':''}" href="?status=PENDING">Pending</a></li>
                        <li class="nav-item"><a class="nav-link ${status=='PROCESSING'?'active':''}" href="?status=PROCESSING">Processing</a></li>
                        <li class="nav-item"><a class="nav-link ${status=='SHIPPED'?'active':''}" href="?status=SHIPPED">Shipped</a></li>
                        <li class="nav-item"><a class="nav-link ${status=='COMPLETED'?'active':''}" href="?status=COMPLETED">Completed</a></li>
                        <li class="nav-item"><a class="nav-link ${status=='CANCELED'?'active':''}" href="?status=CANCELED">Canceled</a></li>
                    </ul>

                    <div class="table-responsive">
                        <table class="table align-middle">
                            <thead class="table-light">
                                <tr>
                                    <th style="width:120px;">Order #</th>
                                    <th style="width:160px;">Created</th>
                                    <th style="width:100px;">Items</th>
                                    <th style="width:160px;">Total</th>
                                    <th style="width:160px;">Status</th>
                                    <th style="width:160px;">Payment</th>
                                    <th style="width:130px;"></th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${empty orders}">
                                        <tr><td colspan="7" class="text-center text-muted py-4">You have no orders yet.</td></tr>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="o" items="${orders}">
                                            <tr>
                                                <td class="fw-semibold">#${o.orderId}</td>
                                                <td>
                                                    <fmt:timeZone value="GMT+7">
                                                        <fmt:formatDate value="${o.createdAt}" pattern="yyyy-MM-dd HH:mm"/>
                                                    </fmt:timeZone>
                                                </td>
                                                <td>${o.itemCount}</td>
                                                <td class="text-brand fw-semibold">
                                                    <fmt:formatNumber value="${o.totalPrice}" type="number" groupingUsed="true"/>đ
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${o.status=='PENDING'}"><span class="badge badge-soft">PENDING</span></c:when>
                                                        <c:when test="${o.status=='PROCESSING'}"><span class="badge bg-primary">PROCESSING</span></c:when>
                                                        <c:when test="${o.status=='SHIPPED'}"><span class="badge bg-info">SHIPPED</span></c:when>
                                                        <c:when test="${o.status=='COMPLETED'}"><span class="badge bg-success">COMPLETED</span></c:when>
                                                        <c:when test="${o.status=='CANCELED'}"><span class="badge bg-secondary">CANCELED</span></c:when>
                                                        <c:otherwise><span class="badge bg-light text-dark">${o.status}</span></c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${o.paymentStatus=='PAID'}"><span class="badge bg-success">PAID</span></c:when>
                                                        <c:when test="${o.paymentStatus=='FAILED'}"><span class="badge bg-danger">FAILED</span></c:when>
                                                        <c:when test="${o.paymentStatus=='REFUND_PENDING'}"><span class="badge bg-warning text-dark">REFUND_PENDING</span></c:when>
                                                        <c:when test="${o.paymentStatus=='REFUNDED'}"><span class="badge bg-dark">REFUNDED</span></c:when>
                                                        <c:otherwise><span class="badge bg-secondary">${o.paymentStatus}</span></c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <a class="btn btn-sm btn-outline-secondary"
                                                       href="${pageContext.request.contextPath}/customer/orders/detail?orderId=${o.orderId}">
                                                        View
                                                    </a>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>

                    <c:if test="${totalPages > 1}">
                        <nav>
                            <ul class="pagination justify-content-end mb-0">
                                <li class="page-item ${page<=1?'disabled':''}">
                                    <a class="page-link" href="?status=${status}&page=${page-1}&size=${size}">Prev</a>
                                </li>
                                <c:forEach begin="1" end="${totalPages}" var="p">
                                    <li class="page-item ${p==page?'active':''}">
                                        <a class="page-link" href="?status=${status}&page=${p}&size=${size}">${p}</a>
                                    </li>
                                </c:forEach>
                                <li class="page-item ${page>=totalPages?'disabled':''}">
                                    <a class="page-link" href="?status=${status}&page=${page+1}&size=${size}">Next</a>
                                </li>
                            </ul>
                        </nav>
                    </c:if>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
