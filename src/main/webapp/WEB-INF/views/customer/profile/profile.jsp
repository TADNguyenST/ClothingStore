<%-- 
    Document   : profile
    Created on : Jun 14, 2025, 4:34:40 AM
    Author     : Khoa
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<html>
<head>
    <title>Customer Profile</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    <style>
        .profile-card {
            width: 60%;
            margin: 50px auto;
            padding: 30px;
            box-shadow: 0 0 15px rgba(0,0,0,0.1);
            border-radius: 10px;
            background-color: white;
        }
        .profile-card h2 {
            text-align: center;
            font-weight: bold;
        }
        .profile-info {
            margin-top: 20px;
            line-height: 2em;
        }
        .profile-info b {
            display: inline-block;
            width: 150px;
        }
        .action-buttons {
            text-align: center;
            margin-top: 30px;
        }
    </style>
</head>
<body>
    <div class="profile-card">
        <h2>Customer Profile</h2>

        <div class="profile-info">
            <p><b>Full Name:</b> <c:out value="${user.fullName}" /></p>
            <p><b>Email:</b> <c:out value="${user.email}" /></p>
            <p><b>Phone Number:</b> <c:out value="${user.phoneNumber}" /></p>
            <p><b>Gender:</b> <c:out value="${customer.gender}" /></p>
            <p><b>Birth Date:</b> <fmt:formatDate value="${customer.birthDate}" pattern="yyyy-MM-dd" /></p>
            <p><b>Loyalty Points:</b> <c:out value="${customer.loyaltyPoints}" /></p>
            <p><b>Account Created At:</b> <fmt:formatDate value="${customer.createdAt}" pattern="yyyy-MM-dd HH:mm:ss" /></p>
        </div>

        <!-- Nút được đặt bên dưới thông tin -->
        <div class="action-buttons">
            <a href="#" class="btn btn-outline-primary me-2">
                <i class="bi bi-pencil-square"></i> Edit Profile
            </a>
            <a href="${pageContext.request.contextPath}/ChangePassword" class="btn btn-outline-secondary">
                <i class="bi bi-key"></i> Change Password
            </a>
        </div>
    </div>
</body>
</html>
