<%-- 
    Document   : history-order
    Created on : Aug 22, 2025, 7:23:40 AM
    Author     : default
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>${requestScope.pageTitle != null ? requestScope.pageTitle : "Order History"}</title>
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
        .customer-info {
            background-color: #fff;
            padding: 15px;
            border-radius: 5px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            margin-bottom: 20px;
            text-align: center;
        }
        .customer-info h3 {
            margin: 0;
            color: #007bff;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
            background-color: #fff;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        th, td {
            padding: 12px;
            text-align: left;
            border: 1px solid #ddd;
        }
        th {
            background-color: #007bff;
            color: white;
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
        .btn-secondary {
            background-color: #6c757d;
        }
        .btn-secondary:hover {
            background-color: #5a6268;
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
        .btn-delete {
            background-color: #dc3545;
        }
        .btn-delete:hover {
            background-color: #c82333;
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
            padding: 20px;
        }
        .status-indicator {
            display: inline-block;
            width: 10px;
            height: 10px;
            border-radius: 50%;
            margin-right: 5px;
        }
        .status-pending {
            background-color: #ffc107;
        }
        .status-confirmed {
            background-color: #17a2b8;
        }
        .status-shipped {
            background-color: #007bff;
        }
        .status-delivered {
            background-color: #28a745;
        }
        .status-cancelled {
            background-color: #dc3545;
        }
        .status-paid {
            background-color: #28a745;
        }
        .status-unpaid {
            background-color: #6c757d;
        }
        .amount {
            font-weight: bold;
            color: #007bff;
        }
        .back-button-container {
            margin-bottom: 20px;
        }
        .order-notes {
            max-width: 150px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }
    </style>
</head>
<body>

    <%-- Sidebar & Header --%>
    <c:set var="currentAction" value="orderHistory" scope="request"/>
    <c:set var="currentModule" value="order" scope="request"/>
    <c:set var="pageTitle" value="Order History" scope="request"/>

    <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp" />
    <div class="main-content-wrapper">
        <jsp:include page="/WEB-INF/includes/admin-header.jsp" />

        <div class="content-area">
            <div class="back-button-container">
                <a href="${pageContext.request.contextPath}/CustomerManagement" class="btn btn-secondary">
                    <i class="fa fa-arrow-left"></i> Back to Customer List
                </a>
            </div>

            <div class="customer-info">
                <h3>Order History for Customer ID: ${customerId}</h3>
            </div>

            <h2>Order History</h2>

            <c:if test="${not empty param.successMessage}">
                <div class="success">${param.successMessage}</div>
            </c:if>
            <c:if test="${not empty param.errorMessage}">
                <div class="error">${param.errorMessage}</div>
            </c:if>

            <table>
                <thead>
                    <tr>
                        <th>Order ID</th>
                        <th>Order Date</th>
                        <th>Shipping Address</th>
                        <th>Voucher</th>
                        <th>Subtotal</th>
                        <th>Discount</th>
                        <th>Shipping Fee</th>
                        <th>Total Price</th>
                        <th>Status</th>
                        <th>Payment Status</th>
                        <th>Notes</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${not empty orders}">
                            <c:forEach var="order" items="${orders}">
                                <tr>
                                    <td>${order.orderId}</td>
                                    <td>
                                        <fmt:formatDate value="${order.createdAt}" pattern="yyyy-MM-dd HH:mm"/>
                                    </td>
                                    <td>${order.shippingAddressId}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty order.voucherId}">
                                                ${order.voucherId}
                                            </c:when>
                                            <c:otherwise>
                                                <span style="color: #6c757d;">No voucher</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="amount">
                                        <fmt:formatNumber value="${order.subtotal}" type="currency" currencyCode="VND"/>
                                    </td>
                                    <td class="amount">
                                        <fmt:formatNumber value="${order.discountAmount}" type="currency" currencyCode="VND"/>
                                    </td>
                                    <td class="amount">
                                        <fmt:formatNumber value="${order.shippingFee}" type="currency" currencyCode="VND"/>
                                    </td>
                                    <td class="amount">
                                        <fmt:formatNumber value="${order.totalPrice}" type="currency" currencyCode="VND"/>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${order.status eq 'Pending'}">
                                                <span class="status-indicator status-pending"></span>
                                            </c:when>
                                            <c:when test="${order.status eq 'Confirmed'}">
                                                <span class="status-indicator status-confirmed"></span>
                                            </c:when>
                                            <c:when test="${order.status eq 'Shipped'}">
                                                <span class="status-indicator status-shipped"></span>
                                            </c:when>
                                            <c:when test="${order.status eq 'Delivered'}">
                                                <span class="status-indicator status-delivered"></span>
                                            </c:when>
                                            <c:when test="${order.status eq 'Cancelled'}">
                                                <span class="status-indicator status-cancelled"></span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="status-indicator" style="background-color: #6c757d;"></span>
                                            </c:otherwise>
                                        </c:choose>
                                        ${order.status}
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${order.paymentStatus eq 'Paid'}">
                                                <span class="status-indicator status-paid"></span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="status-indicator status-unpaid"></span>
                                            </c:otherwise>
                                        </c:choose>
                                        ${order.paymentStatus}
                                    </td>
                                    <td class="order-notes" title="${order.notes}">
                                        <c:choose>
                                            <c:when test="${not empty order.notes}">
                                                ${order.notes}
                                            </c:when>
                                            <c:otherwise>
                                                <span style="color: #6c757d;">No notes</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr><td colspan="11" class="no-data">No orders found for this customer</td></tr>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
    </div>

    <%-- JS --%>
    <script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>
</body>
</html>
