<%-- 
    Document   : staff-list
    Created on : Jun 14, 2025, 5:58:06 AM
    Author     : Lenovo
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" crossorigin="anonymous">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
        <title>${requestScope.pageTitle != null ? requestScope.pageTitle : "Staff List"}</title>

        <%-- Link đến thư viện ngoài --%>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">

        <%-- Link đến file CSS dùng chung --%>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/admin-dashboard/css/admin-css.css">

        <%-- CSS nội tuyến cho trang staff list --%>
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
                padding: 20px;
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
        </style>
    </head>
    <body>

        <%-- Đặt các biến requestScope cho sidebar/header --%>
        <c:set var="currentAction" value="staff" scope="request"/>
        <c:set var="currentModule" value="admin" scope="request"/>
        <c:set var="pageTitle" value="Staff List" scope="request"/>

        <%-- Nhúng Sidebar --%>
        <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp" />

        
           

            <%-- Nội dung chính của trang Staff List --%>
            <div class="content-area">
                <div class="header-container">
                    <h2>Staff List</h2>
                    <div class="search-container">
                        <form action="${pageContext.request.contextPath}/StaffManagement" method="get" style="display: inline;">
                            <input type="text" name="keyword" class="search-input" placeholder="Enter name or email" value="${param.keyword}">
                            <button type="submit" class="btn btn-search"><i class="fa fa-search"></i> Search</button>
                            <a href="${pageContext.request.contextPath}/StaffManagement" class="btn btn-delete"><i class="fa fa-refresh"></i> Reset</a>
                        </form>
                    </div>
                </div>
                <c:if test="${not empty param.successMessage}">
                    <div class="success">${param.successMessage}</div>
                </c:if>
                <c:if test="${not empty param.errorMessage}">
                    <div class="error">${param.errorMessage}</div>
                </c:if>
                <div class="add-container">
                    <a href="${pageContext.request.contextPath}/CreateAccount" class="btn btn-add">Add Staff</a>
                </div>
                <table>
                    <thead>
                        <tr>
                            <th>Staff ID</th>
                            <th>Email</th>
                            <th>Full Name</th>
                            <th>Phone</th>
                            <th>Position</th>
                            <th>Status</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty staffList}">
                                <c:forEach var="staffInfo" items="${staffList}">
                                    <tr>
                                        <td>${staffInfo.staffId}</td>
                                        <td>${staffInfo.user.email}</td>
                                        <td>${staffInfo.user.fullName}</td>
                                        <td>${staffInfo.user.phoneNumber}</td>
                                        <td>${staffInfo.staff.position}</td>
                                        <td>
                                            <span class="status-indicator ${staffInfo.user.status == 'Active' ? 'status-active' : 'status-inactive'}"></span>
                                            ${staffInfo.user.status}
                                        </td>
                                        <td>
                                            <a href="${pageContext.request.contextPath}/viewStaff?userId=${staffInfo.user.userId}" class="btn btn-detail">Detail</a>
                                            <a href="${pageContext.request.contextPath}/EditStaff?userId=${staffInfo.user.userId}" class="btn btn-edit">Edit</a>
                                          <a href="${pageContext.request.contextPath}/deleteStaff?userId=${staffInfo.user.userId}" class="btn btn-delete" onclick="return confirm('Are you sure?')">Delete</a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr><td colspan="7" class="no-data">No staff available to display</td></tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>

        <%-- Link đến file JS dùng chung --%>
       <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" crossorigin="anonymous"></script>
    <script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>
    </body>
   
</html>
