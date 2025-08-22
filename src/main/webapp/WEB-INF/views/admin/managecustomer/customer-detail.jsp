<%-- 
    Document   : customer-detail
    Created on : Jul 26, 2025, 2:31:06 PM
    Author     : ClothingStore Team
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Customer Information</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/admin-dashboard/css/admin-css.css">
        <style>
            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background-color: #f4f4f9;
                margin: 0;
                padding: 0;
            }

            .main-content-wrapper {
                margin-left: 250px;
            }

            .content-area {
                padding: 30px;
            }

            h2 {
                text-align: center;
                color: #333;
                margin-bottom: 30px;
            }

            .info-table {
                width: 100%;
                max-width: 950px;
                margin: 0 auto;
                background-color: #fff;
                border-collapse: collapse;
                border-radius: 8px;
                overflow: hidden;
                box-shadow: 0 4px 12px rgba(0,0,0,0.05);
            }

            .info-table th {
                background-color: #007bff;
                color: white;
                text-align: left;
                font-size: 16px;
                padding: 14px;
            }

            .info-table td {
                padding: 14px;
                border-bottom: 1px solid #f0f0f0;
                color: #333;
            }

            .info-table tr:nth-child(even) {
                background-color: #f9f9f9;
            }

            .info-table tr:hover {
                background-color: #f1f1f1;
            }

            .info-label {
                font-weight: 600;
                width: 200px;
            }

            .back-link {
                display: block;
                width: fit-content;
                margin: 30px auto 0;
                padding: 10px 20px;
                background-color: #17a2b8;
                color: white;
                text-decoration: none;
                border-radius: 5px;
                font-size: 14px;
                text-align: center;
            }

            .back-link:hover {
                background-color: #138496;
            }
        </style>
    </head>
    <body>

        <c:set var="currentAction" value="customerDetails" scope="request"/>
        <c:set var="currentModule" value="customer" scope="request"/>
        <c:set var="pageTitle" value="Customer Information" scope="request"/>
        <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp" />

        <div class="main-content-wrapper">
            <jsp:include page="/WEB-INF/includes/admin-header.jsp" />
            <div class="content-area">
                <h2>Customer Information</h2>

                <c:if test="${not empty customerInfo}">
                    <table class="info-table">
                        <tbody>
                            <tr><th colspan="2">Customer Account Details</th></tr>
                            <tr><td class="info-label">Customer ID</td><td>${customerInfo.customer.customerId}</td></tr>
                            <tr><td class="info-label">Email</td><td>${customerInfo.user.email}</td></tr>
                            <tr><td class="info-label">Full Name</td><td>${customerInfo.user.fullName}</td></tr>
                            <tr><td class="info-label">Phone Number</td><td>${customerInfo.user.phoneNumber}</td></tr>
                            <tr><td class="info-label">Status</td><td>${customerInfo.user.status}</td></tr>
                            <tr><td class="info-label">Role</td><td>${customerInfo.user.role}</td></tr>
                            <tr><td class="info-label">Created At</td><td>${customerInfo.user.createdAt}</td></tr>
                            <tr><td class="info-label">Updated At</td><td>${customerInfo.user.updatedAt}</td></tr>
                            <tr><td class="info-label">Loyalty Points</td><td>${customerInfo.customer.loyaltyPoints}</td></tr>
                            <tr><td class="info-label">Birth Date</td><td>${customerInfo.customer.birthDate}</td></tr>
                            <tr><td class="info-label">Gender</td><td>${customerInfo.customer.gender}</td></tr>
                            <tr><td class="info-label">Avatar URL</td>
                                <td>
                                    <c:if test="${not empty customerInfo.customer.avatarUrl}">
                                        <img src="${customerInfo.customer.avatarUrl}" alt="Avatar" style="max-height: 100px; border-radius: 5px;">
                                    </c:if>
                                    <c:if test="${empty customerInfo.customer.avatarUrl}">
                                        <em>No avatar provided</em>
                                    </c:if>
                                </td>
                            </tr>
                            <tr><td class="info-label">Customer Created At</td><td>${customerInfo.customer.createdAt}</td></tr>
                        </tbody>
                    </table>
                    <div style="text-align:center; margin-top:20px;">
                        <a href="${pageContext.request.contextPath}/ViewCustomerOrderHistory?customerId=${customerInfo.customer.customerId}" 
                           class="order-history-btn"
                           style="display:inline-block; padding:10px 20px; background:#28a745; color:#fff; border-radius:5px; text-decoration:none;">
                            <i class="fa fa-list"></i> View Order History
                        </a>
                    </div>
                </c:if>
            </div>
        </div>

        <script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>
    </body>
</html>
