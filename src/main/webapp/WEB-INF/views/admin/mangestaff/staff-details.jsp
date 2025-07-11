<%-- 
    Document   : staff-details
    Created on : Jun 14, 2025, 5:58:25 AM
    Author     : Lenovo
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Staff Information</title>
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

<c:set var="currentAction" value="staffDetails" scope="request"/>
<c:set var="currentModule" value="admin" scope="request"/>
<c:set var="pageTitle" value="Staff Information" scope="request"/>
<jsp:include page="/WEB-INF/includes/admin-sidebar.jsp" />

<div class="main-content-wrapper">
    <jsp:include page="/WEB-INF/includes/admin-header.jsp" />
    <div class="content-area">
        <h2>Staff Information</h2>

        <c:if test="${not empty staffInfo}">
            <table class="info-table">
                <tbody>
                    <tr><th colspan="2">Staff Account Details</th></tr>
                    <tr><td class="info-label">Staff ID</td><td>${staffInfo.staff.staffId}</td></tr>
                    <tr><td class="info-label">Email</td><td>${staffInfo.user.email}</td></tr>
                    <tr><td class="info-label">Full Name</td><td>${staffInfo.user.fullName}</td></tr>
                    <tr><td class="info-label">Phone Number</td><td>${staffInfo.user.phoneNumber}</td></tr>
                    <tr><td class="info-label">Status</td><td>${staffInfo.user.status}</td></tr>
                    <tr><td class="info-label">Role</td><td>${staffInfo.user.role}</td></tr>
                    <tr><td class="info-label">Created At</td><td>${staffInfo.user.createdAt}</td></tr>
                    <tr><td class="info-label">Updated At</td><td>${staffInfo.user.updatedAt}</td></tr>
                    <tr><td class="info-label">Position</td><td>${staffInfo.staff.position}</td></tr>
                    <tr><td class="info-label">Notes</td><td>${staffInfo.staff.notes}</td></tr>
                    <tr><td class="info-label">Staff Created At</td><td>${staffInfo.staff.createdAt}</td></tr>
                </tbody>
            </table>
        </c:if>

        <a class="back-link" href="${pageContext.request.contextPath}/StaffManagement">&larr; Back to Staff List</a>
    </div>
</div>

<script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>
</body>
</html>

