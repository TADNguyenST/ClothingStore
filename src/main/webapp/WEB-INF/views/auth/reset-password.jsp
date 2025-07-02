<%-- 
    Document   : reset-password
    Created on : Jun 14, 2025, 4:33:05 AM
    Author     : Lenovo
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Reset Password</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f6f7fb;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }

        .reset-container {
            background-color: white;
            padding: 30px 40px;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            width: 400px;
        }

        h2 {
            text-align: center;
            margin-bottom: 25px;
        }

        .form-group {
            margin-bottom: 18px;
        }

        label {
            font-weight: bold;
            display: block;
            margin-bottom: 6px;
        }

        input[type="password"] {
            width: 100%;
            padding: 10px;
            border-radius: 6px;
            border: 1px solid #ccc;
        }

        .btn-submit {
            width: 100%;
            background-color: #007bff;
            color: white;
            border: none;
            padding: 12px;
            font-size: 16px;
            border-radius: 6px;
            cursor: pointer;
        }

        .btn-submit:hover {
            background-color: #0056b3;
        }

        .message {
            text-align: center;
            color: red;
            margin-bottom: 15px;
        }

        .success {
            color: green;
        }
    </style>
</head>
<body>
<div class="reset-container">
    <h2>Reset Password</h2>

    <!-- Error or success messages -->
    <c:if test="${not empty error}">
        <div class="message">${error}</div>
    </c:if>

    <c:if test="${not empty success}">
        <div class="message success">${success}</div>
    </c:if>

    <!-- Reset password form -->
    <form method="post" action="ResetPassword">
        <div class="form-group">
            <label for="newPassword">New Password</label>
            <input type="password" id="newPassword" name="newPassword" required />
        </div>
        <div class="form-group">
            <label for="confirmPassword">Confirm Password</label>
            <input type="password" id="confirmPassword" name="confirmPassword" required />
        </div>
        <button type="submit" class="btn-submit">Confirm</button>
    </form>
</div>
</body>
</html>

