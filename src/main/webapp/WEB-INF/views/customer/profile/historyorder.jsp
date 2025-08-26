<%-- 
    Document   : historyorder
    Created on : Aug 26, 2025, 12:44:48 PM
    Author     : default
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:setLocale value="en_US" />

<c:set var="pageTitle" value="Order History" scope="request"/>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<style>
    .profile-section-container {
        background: #f4f7f6;
        padding: 2rem 0;
        font-family: 'Jost', sans-serif;
        min-height: 100vh;
    }
    .profile-card {
        background: white;
        border-radius: 15px;
        box-shadow: 0 8px 30px rgba(0,0,0,0.07);
        padding: 2rem;
        transition: all 0.3s ease;
    }
    .profile-card:hover {
        box-shadow: 0 12px 40px rgba(0,0,0,0.1);
    }
    .section-title {
        font-size: 1.8rem;
        font-weight: 600;
        color: #333;
        text-align: center;
        margin-bottom: 2rem;
        position: relative;
        padding-bottom: 1rem;
    }
    .section-title::after {
        content: '';
        position: absolute;
        bottom: 0;
        left: 50%;
        transform: translateX(-50%);
        width: 80px;
        height: 3px;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        border-radius: 2px;
    }
    .sidebar {
        min-height: 100vh;
        background: #fff;
        border-right: 1px solid #e9ecef;
        padding-top: 1rem;
        border-radius: 15px 0 0 15px;
        box-shadow: 0 8px 30px rgba(0,0,0,0.07);
    }
    .list-group-item {
        border: none;
        padding: 0.75rem 1.5rem;
        background: transparent;
        transition: all 0.3s;
        border-left: 4px solid transparent;
        color: #333;
        font-weight: 500;
        text-decoration: none;
    }
    .list-group-item.active {
        background: #f8f9fa;
        color: #667eea;
        border-left-color: #667eea;
        border-radius: 0;
    }
    .list-group-item:hover {
        background: #f0f0f0;
        color: #111;
        border-left-color: #ddd;
        text-decoration: none;
    }
    
    /* Order History Specific Styles */
    .empty-orders {
        text-align: center;
        padding: 3rem;
        color: #666;
    }
    .empty-orders i {
        font-size: 4rem;
        color: #ddd;
        margin-bottom: 1rem;
    }
    .empty-orders h3 {
        color: #999;
        margin-bottom: 0.5rem;
    }
    .empty-orders p {
        font-size: 1.1rem;
    }
    
    .order-item {
        background: #f8f9fa;
        border-radius: 12px;
        padding: 1.5rem;
        margin-bottom: 1.5rem;
        border-left: 4px solid #764ba2;
        transition: all 0.3s ease;
        position: relative;
        overflow: hidden;
    }
    .order-item::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        height: 2px;
        background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
    }
    .order-item:hover {
        transform: translateY(-3px);
        box-shadow: 0 8px 25px rgba(0,0,0,0.1);
    }
    
    .order-header {
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        margin-bottom: 1rem;
        flex-wrap: wrap;
        gap: 1rem;
    }
    .order-id {
        font-size: 1.2rem;
        font-weight: 700;
        color: #333;
    }
    .order-date {
        color: #666;
        font-size: 0.95rem;
    }
    
    .order-details {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
        gap: 1rem;
        margin-bottom: 1rem;
    }
    .detail-item {
        background: white;
        padding: 1rem;
        border-radius: 8px;
        border: 1px solid #e9ecef;
    }
    .detail-label {
        font-weight: 600;
        color: #555;
        font-size: 0.85rem;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        margin-bottom: 0.25rem;
    }
    .detail-value {
        font-size: 1rem;
        color: #111;
        font-weight: 500;
    }
    .product-name {
        font-weight: 700;
        color: #667eea;
    }
    
    .order-footer {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding-top: 1rem;
        border-top: 1px solid #e9ecef;
        flex-wrap: wrap;
        gap: 1rem;
    }
    .status-badges {
        display: flex;
        gap: 0.75rem;
        flex-wrap: wrap;
    }
    .status-badge {
        padding: 0.4rem 1rem;
        border-radius: 20px;
        color: #fff;
        font-size: 0.8rem;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }
    .status-pending { background: linear-gradient(135deg, #ffc107 0%, #ff8f00 100%); }
    .status-processing { background: linear-gradient(135deg, #17a2b8 0%, #007bff 100%); }
    .status-shipped { background: linear-gradient(135deg, #28a745 0%, #20c997 100%); }
    .status-delivered { background: linear-gradient(135deg, #007bff 0%, #667eea 100%); }
    .status-completed { background: linear-gradient(135deg, #6f42c1 0%, #9b59b6 100%); }
    .status-cancelled { background: linear-gradient(135deg, #dc3545 0%, #c82333 100%); }
    .payment-paid { background: linear-gradient(135deg, #28a745 0%, #20c997 100%); }
    .payment-unpaid { background: linear-gradient(135deg, #dc3545 0%, #c82333 100%); }
    
    .total-price {
        font-size: 1.4rem;
        font-weight: 700;
        color: #667eea;
    }
    
    .btn-profile {
        padding: 0.75rem 2rem;
        border-radius: 50px;
        font-weight: 600;
        text-decoration: none;
        transition: all 0.3s ease;
        border: 2px solid transparent;
        display: inline-flex;
        align-items: center;
        gap: 0.5rem;
    }
    .btn-primary {
        background-color: #667eea;
        color: white;
    }
    .btn-primary:hover {
        background-color: #5a6edc;
        transform: translateY(-2px);
        box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        color: white;
        text-decoration: none;
    }
    
    @media (max-width: 768px) {
        .order-header {
            flex-direction: column;
            align-items: flex-start;
        }
        .order-details {
            grid-template-columns: 1fr;
        }
        .order-footer {
            flex-direction: column;
            align-items: flex-start;
        }
        .status-badges {
            width: 100%;
            justify-content: flex-start;
        }
    }
</style>

<div class="profile-section-container">
    <div class="container">
        <div class="row">
            <div class="col-lg-3 mb-4 mb-lg-0 sidebar">
                <div class="list-group">
                    <a href="${pageContext.request.contextPath}/Profile" class="list-group-item list-group-item-action">
                        <i class="fas fa-user me-2"></i> My Profile
                    </a>
                    <a href="${pageContext.request.contextPath}/customer/address" class="list-group-item list-group-item-action">
                        <i class="fas fa-address-book me-2"></i> Address Book
                    </a>
                    <a href="${pageContext.request.contextPath}/historyorder" class="list-group-item list-group-item-action active">
                        <i class="fas fa-box-open me-2"></i> My Orders
                    </a>
                    <a href="${pageContext.request.contextPath}/Logout" class="list-group-item list-group-item-action text-danger">
                        <i class="fas fa-sign-out-alt me-2"></i> Logout
                    </a>
                </div>
            </div>

            <div class="col-lg-9">
                <div class="profile-card">
                    <h2 class="section-title">
                        <i class="fas fa-history me-2"></i>
                        Order History
                    </h2>

                    <!-- Orders List -->
                    <c:choose>
                        <c:when test="${empty historyList}">
                            <div class="empty-orders">
                                <i class="fas fa-shopping-bag"></i>
                                <h3>No Orders Found</h3>
                                <p>You haven't placed any orders yet. Start shopping to see your order history here!</p>
                                <a href="${pageContext.request.contextPath}/products" class="btn-profile btn-primary mt-3">
                                    <i class="fas fa-shopping-cart me-2"></i>Start Shopping
                                </a>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="order" items="${historyList}">
                                <div class="order-item">
                                    <div class="order-header">
                                        <div>
                                            <div class="order-id">#${order.orderId}</div>
                                            <div class="order-date">
                                                <i class="fas fa-calendar-alt me-1"></i>
                                                <fmt:formatDate value="${order.orderDate}" pattern="dd MMMM, yyyy 'at' HH:mm" />
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <div class="order-details">
                                        <div class="detail-item">
                                            <div class="detail-label">Product</div>
                                            <div class="detail-value product-name">${order.productName}</div>
                                        </div>
                                        <div class="detail-item">
                                            <div class="detail-label">Size</div>
                                            <div class="detail-value">${order.size}</div>
                                        </div>
                                        <div class="detail-item">
                                            <div class="detail-label">Color</div>
                                            <div class="detail-value">${order.color}</div>
                                        </div>
                                        <div class="detail-item">
                                            <div class="detail-label">Voucher</div>
                                            <div class="detail-value">
                                                <c:choose>
                                                    <c:when test="${not empty order.voucherCode}">
                                                        <i class="fas fa-ticket-alt me-1"></i>${order.voucherCode}
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-muted">No voucher used</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <div class="order-footer">
                                        <div class="status-badges">
                                            <span class="status-badge status-${order.orderStatus != null ? order.orderStatus.toLowerCase().replace(' ', '-') : 'pending'}">
                                                ${order.orderStatus}
                                            </span>
                                            <span class="status-badge payment-${order.paymentStatus != null ? order.paymentStatus.toLowerCase() : 'unpaid'}">
                                                ${order.paymentStatus}
                                            </span>
                                        </div>
                                        <div class="total-price">
                                            <fmt:formatNumber value="${order.totalPrice}" type="currency" currencySymbol="$" />
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />