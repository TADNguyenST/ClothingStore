<%-- 
    Document   : history-details
    Created on : Aug 25, 2025, 8:40:04 PM
    Author     : default
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>${requestScope.pageTitle != null ? requestScope.pageTitle : "Order Detail History"}</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <%-- Font Awesome --%>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
        <%-- Common CSS --%>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/admin-dashboard/css/admin-css.css">

        <style>
            body {
                font-family: Arial, sans-serif;
                background-color: #f4f4f9;
            }
            h2 {
                text-align: center;
                color: #333;
            }
            table {
                width: 100%;
                border-collapse: collapse;
                margin-top: 20px;
                background-color: #fff;
                box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            }
            th, td {
                padding: 8px 10px;
                text-align: left;
                border: 1px solid #ddd;
                font-size: 13px;
            }
            th {
                background-color: #007bff;
                color: white;
                font-weight: bold;
            }
            tr:nth-child(even) {
                background-color: #f9f9f9;
            }
            tr:hover {
                background-color: #f1f1f1;
            }
            .no-data {
                text-align: center;
                color: #555;
                padding: 20px;
            }
            .btn {
                padding: 6px 12px;
                text-decoration: none;
                border-radius: 4px;
                color: white;
                font-size: 14px;
                border: none;
                cursor: pointer;
                margin-right: 5px;
            }
            .btn-add {
                background-color: #28a745;
            }
            .btn-add:hover {
                background-color: #218838;
            }
            .btn-edit {
                background-color: #28a745;
            }
            .btn-edit:hover {
                background-color: #218838;
            }
            .btn-delete {
                background-color: #dc3545;
            }
            .btn-delete:hover {
                background-color: #c82333;
            }
            .btn-detail {
                background-color: #ffc107;
            }
            .btn-detail:hover {
                background-color: #e0a800;
            }
            .btn-search {
                background-color: #17a2b8;
            }
            .btn-search:hover {
                background-color: #138496;
            }
            .btn-back {
                background-color: #6c757d;
            }
            .btn-back:hover {
                background-color: #5a6268;
            }
            .error, .success {
                text-align: center;
                margin: 10px 0;
                padding: 10px;
                border-radius: 4px;
            }
            .error {
                color: red;
                background-color: #ffe6e6;
            }
            .success {
                color: green;
                background-color: #e6ffe6;
            }
            .header-container {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 20px;
            }
            .search-container {
                text-align: right;
            }
            .search-input {
                padding: 6px;
                border: 1px solid #ddd;
                border-radius: 4px;
                font-size: 14px;
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
            .order-info {
                background-color: #e9ecef;
                padding: 15px;
                border-radius: 5px;
                margin-bottom: 20px;
            }
            .order-info-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                gap: 10px;
                text-align: center;
            }
            .info-item {
                background-color: #ffffff;
                padding: 10px;
                border-radius: 4px;
                border: 1px solid #dee2e6;
            }
            .info-item strong {
                display: block;
                color: #495057;
                margin-bottom: 5px;
            }
            .info-value {
                color: #007bff;
                font-weight: bold;
            }
            .back-button-container {
                margin-bottom: 20px;
            }
            .status-badge {
                padding: 3px 8px;
                border-radius: 12px;
                color: white;
                font-size: 11px;
                font-weight: bold;
            }
            .status-pending {
                background-color: #ffc107;
            }
            .status-processing {
                background-color: #17a2b8;
            }
            .status-shipped {
                background-color: #28a745;
            }
            .status-delivered {
                background-color: #007bff;
            }
            .status-cancelled {
                background-color: #dc3545;
            }
            .payment-paid {
                background-color: #28a745;
            }
            .payment-unpaid {
                background-color: #dc3545;
            }
            .table-responsive {
                overflow-x: auto;
            }
            @media (max-width: 1200px) {
                th, td {
                    font-size: 12px;
                    padding: 6px 8px;
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
                <div class="back-button-container">
                    <c:choose>
                        <c:when test="${not empty details and details.size() > 0}">
                            <a href="${pageContext.request.contextPath}/CustomerOrderHistoryController?customerId=${details[0].customerId}" 
                               class="btn btn-back">
                               <i class="fa fa-arrow-left"></i> Back to Order History
                            </a>
                        </c:when>
                        <c:otherwise>
                            <a href="${pageContext.request.contextPath}/CustomerManagement" 
                               class="btn btn-back">
                               <i class="fa fa-arrow-left"></i> Back to Customer List
                            </a>
                        </c:otherwise>
                    </c:choose>
                </div>

                <div class="header-container">
                    <h2>Order Detail History</h2>
                </div>

                <c:if test="${not empty details and details.size() > 0}">
                    <div class="order-info">
                        <div class="order-info-grid">
                            <div class="info-item">
                                <strong>Order ID</strong>
                                <div class="info-value">${orderId}</div>
                            </div>
                            <div class="info-item">
                                <strong>Customer ID</strong>
                                <div class="info-value">${details[0].customerId}</div>
                            </div>
                            <div class="info-item">
                                <strong>Order Date</strong>
                                <div class="info-value">${details[0].orderDate}</div>
                            </div>
                            <div class="info-item">
                                <strong>Payment Status</strong>
                                <div class="info-value">
                                    <span class="status-badge payment-${details[0].paymentStatus.toLowerCase()}">${details[0].paymentStatus}</span>
                                </div>
                            </div>
                            <c:if test="${details[0].voucherCode != null}">
                                <div class="info-item">
                                    <strong>Voucher</strong>
                                    <div class="info-value">${details[0].voucherCode}</div>
                                </div>
                            </c:if>
                        </div>
                    </div>
                </c:if>

                <c:if test="${not empty param.successMessage}">
                    <div class="success">${param.successMessage}</div>
                </c:if>
                <c:if test="${not empty param.errorMessage}">
                    <div class="error">${param.errorMessage}</div>
                </c:if>

                <div class="table-responsive">
                    <table>
                        <thead>
                            <tr>
                                <th>Product Name</th>
                                <th>Size</th>
                                <th>Color</th>
                                <th>Quantity</th>
                                <th>Price at Purchase</th>
                                <th>Total Price</th>
                                <th>Order Status</th>
                                <th>Payment Status</th>
                                <th>Voucher Code</th>
                                <th>Voucher Name</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty details}">
                                    <c:forEach var="d" items="${details}">
                                        <tr>
                                            <td><strong>${d.productName}</strong></td>
                                            <td>${d.size}</td>
                                            <td>${d.color}</td>
                                            <td>${d.quantity}</td>
                                            <td>$${d.priceAtPurchase}</td>
                                            <td><strong>$${d.totalPrice}</strong></td>
                                            <td>
                                                <span class="status-badge status-${d.orderStatus.toLowerCase().replace(' ', '-')}">${d.orderStatus}</span>
                                            </td>
                                            <td>
                                                <span class="status-badge payment-${d.paymentStatus.toLowerCase()}">${d.paymentStatus}</span>
                                            </td>
                                            <td><c:out value="${d.voucherCode != null ? d.voucherCode : 'N/A'}"/></td>
                                            <td><c:out value="${d.voucherName != null ? d.voucherName : 'N/A'}"/></td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr><td colspan="10" class="no-data">No details found for this order</td></tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>

                <c:if test="${not empty details}">
                    <div style="margin-top: 20px; text-align: right;">
                        <c:set var="totalOrderAmount" value="0" />
                        <c:forEach var="d" items="${details}">
                            <c:set var="totalOrderAmount" value="${totalOrderAmount + d.totalPrice}" />
                        </c:forEach>
                        <div style="background-color: #e9ecef; padding: 15px; border-radius: 5px; display: inline-block;">
                            <strong style="font-size: 16px;">Total Order Amount: $${totalOrderAmount}</strong>
                        </div>
                    </div>
                </c:if>
            </div>
        </div>

        <%-- JS --%>
        <script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>
    </body>
</html>