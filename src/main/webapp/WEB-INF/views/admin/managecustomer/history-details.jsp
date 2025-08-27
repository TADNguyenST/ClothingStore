<%-- 
    Document   : history-details
    Created on : Aug 25, 2025, 8:40:04 PM
    Author     : default
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:setLocale value="vi_VN" />

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>${requestScope.pageTitle != null ? requestScope.pageTitle : "Order Detail History"}</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        
        <%-- Font Awesome --%>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        <%-- Google Fonts --%>
        <link href="https://fonts.googleapis.com/css2?family=Jost:wght@400;500;600;700&display=swap" rel="stylesheet">
        <%-- Common CSS --%>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/admin-dashboard/css/admin-css.css">

        <style>
            body {
                font-family: 'Jost', sans-serif;
                background: #f4f7f6;
                margin: 0;
                padding: 0;
                color: #333;
            }
            
            .order-details-container {
                background: #f4f7f6;
                padding: 2rem 0;
                font-family: 'Jost', sans-serif;
                min-height: 100vh;
            }
            
            .order-card {
                background: white;
                border-radius: 15px;
                box-shadow: 0 8px 30px rgba(0,0,0,0.07);
                padding: 2rem;
                transition: all 0.3s ease;
                margin-bottom: 2rem;
            }
            
            .order-card:hover {
                box-shadow: 0 12px 40px rgba(0,0,0,0.1);
            }
            
            .page-header {
                text-align: center;
                margin-bottom: 2rem;
                padding-bottom: 1rem;
                border-bottom: 2px solid #667eea;
                position: relative;
            }
            
            .page-header::after {
                content: '';
                position: absolute;
                bottom: -2px;
                left: 50%;
                transform: translateX(-50%);
                width: 60px;
                height: 2px;
                background: #764ba2;
            }
            
            .page-header h2 {
                font-size: 2.2rem;
                font-weight: 700;
                color: #333;
                margin: 0;
                text-transform: uppercase;
                letter-spacing: 1px;
            }
            
            .back-button {
                display: inline-flex;
                align-items: center;
                gap: 0.5rem;
                padding: 0.75rem 1.5rem;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                text-decoration: none;
                border-radius: 50px;
                font-weight: 600;
                transition: all 0.3s ease;
                margin-bottom: 1.5rem;
                box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
            }
            
            .back-button:hover {
                transform: translateY(-2px);
                box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
                color: white;
                text-decoration: none;
            }
            
            .order-summary {
                background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
                border-radius: 12px;
                padding: 1.5rem;
                margin-bottom: 2rem;
                border: 1px solid #ddd;
            }
            
            .order-summary-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
                gap: 1.5rem;
            }
            
            .summary-item {
                background: #ffffff;
                padding: 1.2rem;
                border-radius: 10px;
                border-left: 4px solid #764ba2;
                transition: all 0.3s ease;
                text-align: center;
            }
            
            .summary-item:hover {
                transform: translateY(-5px);
                box-shadow: 0 6px 15px rgba(0,0,0,0.05);
            }
            
            .summary-label {
                font-weight: 600;
                color: #555;
                font-size: 0.9rem;
                text-transform: uppercase;
                letter-spacing: 0.5px;
                margin-bottom: 0.5rem;
            }
            
            .summary-value {
                font-size: 1.1rem;
                color: #111;
                font-weight: 600;
            }
            
            .section-title {
                font-size: 1.3rem;
                font-weight: 600;
                color: #333;
                text-transform: uppercase;
                letter-spacing: 0.5px;
                margin-bottom: 1.5rem;
                border-bottom: 2px solid #667eea;
                padding-bottom: 0.5rem;
                position: relative;
            }
            
            .section-title::after {
                content: '';
                position: absolute;
                bottom: -2px;
                left: 0;
                width: 50px;
                height: 2px;
                background: #764ba2;
            }
            
            .products-grid {
                display: grid;
                gap: 1rem;
            }
            
            .product-item {
                background: #f8f9fa;
                border-radius: 12px;
                padding: 1.5rem;
                border-left: 4px solid #667eea;
                transition: all 0.3s ease;
                position: relative;
                overflow: hidden;
            }
            
            .product-item::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                height: 3px;
                background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
            }
            
            .product-item:hover {
                transform: translateY(-3px);
                box-shadow: 0 8px 25px rgba(0,0,0,0.08);
            }
            
            .product-header {
                display: flex;
                justify-content: space-between;
                align-items: flex-start;
                margin-bottom: 1rem;
                flex-wrap: wrap;
                gap: 1rem;
            }
            
            .product-name {
                font-size: 1.2rem;
                font-weight: 700;
                color: #333;
                margin: 0;
            }
            
            .product-status {
                display: flex;
                gap: 0.5rem;
                align-items: center;
            }
            
            .product-details-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
                gap: 1rem;
                margin-bottom: 1rem;
            }
            
            .product-detail {
                text-align: center;
            }
            
            .detail-label {
                font-size: 0.8rem;
                color: #666;
                text-transform: uppercase;
                letter-spacing: 0.3px;
                margin-bottom: 0.25rem;
            }
            
            .detail-value {
                font-size: 1rem;
                font-weight: 600;
                color: #333;
            }
            
            .price-highlight {
                color: #28a745;
                font-weight: 700;
            }
            
            .status-badge {
                padding: 0.4rem 1rem;
                border-radius: 20px;
                color: white;
                font-size: 0.8rem;
                font-weight: 600;
                text-transform: uppercase;
                letter-spacing: 0.3px;
            }
            
            .status-pending {
                background: linear-gradient(135deg, #ffc107 0%, #ffb300 100%);
            }
            
            .status-processing {
                background: linear-gradient(135deg, #17a2b8 0%, #138496 100%);
            }
            
            .status-shipped {
                background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
            }
            
            .status-delivered {
                background: linear-gradient(135deg, #007bff 0%, #0056b3 100%);
            }
            
            .status-cancelled {
                background: linear-gradient(135deg, #dc3545 0%, #c82333 100%);
            }
            
            .payment-paid {
                background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
            }
            
            .payment-unpaid {
                background: linear-gradient(135deg, #dc3545 0%, #c82333 100%);
            }
            
            .voucher-info {
                background: linear-gradient(135deg, #e3f2fd 0%, #f3e5f5 100%);
                padding: 1rem;
                border-radius: 10px;
                margin-top: 1rem;
                border: 1px solid #e1bee7;
            }
            
            .voucher-grid {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 1rem;
                text-align: center;
            }
            
            .total-section {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                padding: 2rem;
                border-radius: 15px;
                text-align: center;
                margin-top: 2rem;
            }
            
            .total-amount {
                font-size: 2.5rem;
                font-weight: 700;
                margin-bottom: 0.5rem;
            }
            
            .total-label {
                font-size: 1.1rem;
                opacity: 0.9;
                text-transform: uppercase;
                letter-spacing: 1px;
            }
            
            .no-data {
                text-align: center;
                padding: 3rem 2rem;
                color: #666;
                font-size: 1.1rem;
            }
            
            .no-data i {
                font-size: 3rem;
                color: #ddd;
                margin-bottom: 1rem;
                display: block;
            }
            
            .success-message, .error-message {
                padding: 1rem 1.5rem;
                border-radius: 10px;
                margin-bottom: 1.5rem;
                font-weight: 500;
            }
            
            .success-message {
                background: #d4edda;
                color: #155724;
                border: 1px solid #c3e6cb;
            }
            
            .error-message {
                background: #f8d7da;
                color: #721c24;
                border: 1px solid #f5c6cb;
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
            
            @media (max-width: 768px) {
                .order-details-container {
                    padding: 1rem 0;
                }
                
                .order-card {
                    margin: 0 1rem 1rem;
                    padding: 1rem;
                }
                
                .page-header h2 {
                    font-size: 1.8rem;
                }
                
                .product-header {
                    flex-direction: column;
                    text-align: center;
                }
                
                .product-details-grid {
                    grid-template-columns: 1fr 1fr;
                }
                
                .total-amount {
                    font-size: 2rem;
                }
                
                .content-area {
                    margin-left: 0;
                    width: 100%;
                }
            }
        </style>
    </head>
    <body>

        <%-- Sidebar & Header --%>
        <c:set var="currentAction" value="orderDetails" scope="request"/>
        <c:set var="currentModule" value="customer" scope="request"/>
        <c:set var="pageTitle" value="Order Detail History" scope="request"/>

        <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp" />
        <div class="main-content-wrapper">
            <jsp:include page="/WEB-INF/includes/admin-header.jsp" />

            <div class="content-area">
                <div class="order-details-container">
                    <div class="container-fluid">
                        
                        <%-- Back Button --%>
                        <c:choose>
                            <c:when test="${not empty details and details.size() > 0}">
                                <a href="${pageContext.request.contextPath}/CustomerOrderHistoryController?customerId=${details[0].customerId}" 
                                   class="back-button">
                                   <i class="fas fa-arrow-left"></i> Back to Order History
                                </a>
                            </c:when>
                            <c:otherwise>
                                <a href="${pageContext.request.contextPath}/CustomerManagement" 
                                   class="back-button">
                                   <i class="fas fa-arrow-left"></i> Back to Customer List
                                </a>
                            </c:otherwise>
                        </c:choose>

                        <%-- Success/Error Messages --%>
                        <c:if test="${not empty param.successMessage}">
                            <div class="success-message">
                                <i class="fas fa-check-circle"></i> ${param.successMessage}
                            </div>
                        </c:if>
                        <c:if test="${not empty param.errorMessage}">
                            <div class="error-message">
                                <i class="fas fa-exclamation-circle"></i> ${param.errorMessage}
                            </div>
                        </c:if>

                        <div class="order-card">
                            <div class="page-header">
                                <h2><i class="fas fa-receipt"></i> Order Detail History</h2>
                            </div>

                            <c:choose>
                                <c:when test="${not empty details and details.size() > 0}">
                                    <%-- Order Summary --%>
                                    <div class="order-summary">
                                        <div class="order-summary-grid">
                                            <div class="summary-item">
                                                <div class="summary-label">
                                                    <i class="fas fa-hashtag"></i> Order ID
                                                </div>
                                                <div class="summary-value">#${orderId}</div>
                                            </div>
                                            <div class="summary-item">
                                                <div class="summary-label">
                                                    <i class="fas fa-user"></i> Customer ID
                                                </div>
                                                <div class="summary-value">${details[0].customerId}</div>
                                            </div>
                                            <div class="summary-item">
                                                <div class="summary-label">
                                                    <i class="fas fa-calendar-alt"></i> Order Date
                                                </div>
                                                <div class="summary-value">${details[0].orderDate}</div>
                                            </div>
                                            <div class="summary-item">
                                                <div class="summary-label">
                                                    <i class="fas fa-credit-card"></i> Payment Status
                                                </div>
                                                <div class="summary-value">
                                                    <span class="status-badge payment-${details[0].paymentStatus.toLowerCase()}">${details[0].paymentStatus}</span>
                                                </div>
                                            </div>
                                            <c:if test="${details[0].voucherCode != null}">
                                                <div class="summary-item">
                                                    <div class="summary-label">
                                                        <i class="fas fa-ticket-alt"></i> Voucher
                                                    </div>
                                                    <div class="summary-value">${details[0].voucherCode}</div>
                                                </div>
                                            </c:if>
                                        </div>
                                    </div>

                                    <%-- Products Section --%>
                                    <h3 class="section-title">
                                        <i class="fas fa-shopping-bag"></i> Order Items
                                    </h3>
                                    
                                    <div class="products-grid">
                                        <c:forEach var="d" items="${details}">
                                            <div class="product-item">
                                                <div class="product-header">
                                                    <h4 class="product-name">
                                                        <i class="fas fa-box"></i> ${d.productName}
                                                    </h4>
                                                    <div class="product-status">
                                                        <span class="status-badge status-${d.orderStatus.toLowerCase().replace(' ', '-')}">${d.orderStatus}</span>
                                                        <span class="status-badge payment-${d.paymentStatus.toLowerCase()}">${d.paymentStatus}</span>
                                                    </div>
                                                </div>
                                                
                                                <div class="product-details-grid">
                                                    <div class="product-detail">
                                                        <div class="detail-label">Size</div>
                                                        <div class="detail-value">${d.size}</div>
                                                    </div>
                                                    <div class="product-detail">
                                                        <div class="detail-label">Color</div>
                                                        <div class="detail-value">${d.color}</div>
                                                    </div>
                                                    <div class="product-detail">
                                                        <div class="detail-label">Quantity</div>
                                                        <div class="detail-value">×${d.quantity}</div>
                                                    </div>
                                                    <div class="product-detail">
                                                        <div class="detail-label">Unit Price</div>
                                                        <div class="detail-value price-highlight">
                                                            <fmt:formatNumber value="${d.priceAtPurchase}" type="number" pattern="#,##0" /> VND
                                                        </div>
                                                    </div>
                                                    <div class="product-detail">
                                                        <div class="detail-label">Total Price</div>
                                                        <div class="detail-value price-highlight">
                                                            <strong><fmt:formatNumber value="${d.totalPrice}" type="number" pattern="#,##0" /> VND</strong>
                                                        </div>
                                                    </div>
                                                </div>
                                                
                                                <c:if test="${d.voucherCode != null or d.voucherName != null}">
                                                    <div class="voucher-info">
                                                        <div class="voucher-grid">
                                                            <div>
                                                                <div class="detail-label">
                                                                    <i class="fas fa-ticket-alt"></i> Voucher Code
                                                                </div>
                                                                <div class="detail-value">
                                                                    <c:out value="${d.voucherCode != null ? d.voucherCode : 'N/A'}"/>
                                                                </div>
                                                            </div>
                                                            <div>
                                                                <div class="detail-label">
                                                                    <i class="fas fa-tag"></i> Voucher Name
                                                                </div>
                                                                <div class="detail-value">
                                                                    <c:out value="${d.voucherName != null ? d.voucherName : 'N/A'}"/>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </c:if>
                                            </div>
                                        </c:forEach>
                                    </div>

                                    <%-- Total Amount --%>
                                    <c:set var="totalOrderAmount" value="0" />
                                    <c:forEach var="d" items="${details}">
                                        <c:set var="totalOrderAmount" value="${totalOrderAmount + d.totalPrice}" />
                                    </c:forEach>
                                    
                                    <div class="total-section">
                                        <div class="total-label">
                                            <i class="fas fa-calculator"></i> Total Order Amount
                                        </div>
                                        <div class="total-amount">
                                            <fmt:formatNumber value="${totalOrderAmount}" type="number" pattern="#,##0" /> VND
                                        </div>
                                    </div>
                                    
                                </c:when>
                                <c:otherwise>
                                    <div class="no-data">
                                        <i class="fas fa-inbox"></i>
                                        <h3>No Order Details Found</h3>
                                        <p>We couldn't find any details for this order. Please check the order ID and try again.</p>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <%-- JS --%>
        <script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>
    </body>
</html>