<%-- 
    Document   : history-order
    Created on : Aug 22, 2025, 7:23:40 AM
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
        <title>${requestScope.pageTitle != null ? requestScope.pageTitle : "Customer Order History"}</title>
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
            .add-container {
                text-align: left;
                margin-bottom: 10px;
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
            .customer-info {
                background-color: #e9ecef;
                padding: 15px;
                border-radius: 5px;
                margin-bottom: 20px;
                text-align: center;
            }
            .back-button-container {
                margin-bottom: 20px;
            }
            .currency-vnd {
                font-weight: bold;
                color: #28a745;
            }
        </style>
    </head>
    <body>

        <%-- Sidebar & Header --%>
        <c:set var="currentAction" value="orderHistory" scope="request"/>
        <c:set var="currentModule" value="customer" scope="request"/>
        <c:set var="pageTitle" value="Customer Order History" scope="request"/>

        <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp" />
        <div class="main-content-wrapper">
            <jsp:include page="/WEB-INF/includes/admin-header.jsp" />

            <div class="content-area">
                <div class="back-button-container">
                    <a href="${pageContext.request.contextPath}/CustomerManagement" class="btn btn-back">
                        <i class="fa fa-arrow-left"></i> Back to Customer List
                    </a>
                </div>

                <div class="header-container">
                    <h2>Order History</h2>
                </div>

                <div class="customer-info">
                    <strong>Customer ID: ${customerId}</strong>
                </div>

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
                            <th>Total Amount</th>
                            <th>Voucher Code</th>
                            <th>Order Date</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty historyList}">
                                <c:forEach var="order" items="${historyList}">
                                    <tr>
                                        <td>${order.orderId}</td>
                                        <td class="currency-vnd">
                                            <fmt:formatNumber value="${order.totalAmount}" type="number" pattern="#,##0" /> VND
                                        </td>
                                        <td><c:out value="${order.voucherCode != null ? order.voucherCode : 'N/A'}"/></td>
                                        <td>${order.orderDate}</td>
                                        <td>
                                            <a href="${pageContext.request.contextPath}/OrderDetailHistoryController?orderId=${order.orderId}" 
                                               class="btn btn-detail">View Order Detail</a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr><td colspan="5" class="no-data">No orders found for this customer</td></tr>
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