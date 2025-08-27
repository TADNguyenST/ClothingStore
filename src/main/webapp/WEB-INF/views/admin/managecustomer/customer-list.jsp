<%-- 
    Document   : customer-list
    Created on : Jul 26, 2025, 2:30:39 PM
    Author     : default
--%>


<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>${requestScope.pageTitle != null ? requestScope.pageTitle : "Customer List"}</title>
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
            .status-indicator {
                display: inline-block;
                width: 10px;
                height: 10px;
                border-radius: 50%;
                margin-right: 5px;
            }
            .status-active {
                background-color: #28a745;
            }
            .status-inactive {
                background-color: #6c757d;
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
        </style>
    </head>
    <body>

        <%-- Sidebar & Header --%>
        <c:set var="currentAction" value="customerList" scope="request"/>
        <c:set var="currentModule" value="customer" scope="request"/>
        <c:set var="pageTitle" value="Customer List" scope="request"/>

        <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp" />
        
            

            <div class="content-area">
                <div class="header-container">
                    <h2>Customer List</h2>
                    <div class="search-container">
                        <form action="${pageContext.request.contextPath}/CustomerManagement" method="get" style="display: inline;">
                            <input type="text" name="keyword" class="search-input" placeholder="Enter name or email" value="${param.keyword}">
                            <button type="submit" class="btn btn-search"><i class="fa fa-search"></i> Search</button>
                            <a href="${pageContext.request.contextPath}/CustomerManagement" class="btn btn-delete"><i class="fa fa-refresh"></i> Reset</a>
                        </form>
                    </div>
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
                            <th>Customer ID</th>
                            <th>Email</th>
                            <th>Full Name</th>
                            <th>Phone</th>
                            <th>Gender</th>
                            <th>Status</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty customerList}">
                                <c:forEach var="info" items="${customerList}">
                                    <tr>
                                        <td>${info.customerId}</td>
                                        <td>${info.user.email}</td>
                                        <td>${info.user.fullName}</td>
                                        <td>${info.user.phoneNumber}</td>
                                        <td>${info.customer.gender}</td>
                                        <td>
                                            <span class="status-indicator ${info.user.status == 'Active' ? 'status-active' : 'status-inactive'}"></span>
                                            ${info.user.status}
                                        </td>
                                        <td>
                                            <a href="${pageContext.request.contextPath}/viewCustomer?userId=${info.user.userId}" 
                                               class="btn btn-detail">Detail</a>
                                            <a href="${pageContext.request.contextPath}/CustomerOrderHistoryController?customerId=${info.customer.customerId}" 
                                               class="btn btn-detail">Order History</a>

                                            <c:choose>
                                                <c:when test="${info.user.status eq 'Active'}">
                                                    <a href="${pageContext.request.contextPath}/ChangeStatusController?userId=${info.user.userId}" 
                                                       class="btn btn-delete">Block</a>
                                                </c:when>
                                                <c:otherwise>
                                                    <a href="${pageContext.request.contextPath}/ChangeStatusController?userId=${info.user.userId}" 
                                                       class="btn btn-add">Unblock</a>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr><td colspan="7" class="no-data">No customer available to display</td></tr>
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
