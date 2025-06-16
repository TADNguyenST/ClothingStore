<%-- 
    Document   : login
    Created on : Jun 14, 2025, 4:05:48 AM
    Author     : Khoa
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Login</title>
    <style>
        body {
            margin: 0;
            padding: 0;
            background: linear-gradient(135deg, #5fb0bd, #a2d4e6);
            font-family: Arial, sans-serif;
            height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .login-container {
            width: 350px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 15px;
            box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
            backdrop-filter: blur(10px);
            -webkit-backdrop-filter: blur(10px);
            padding: 40px 30px;
            color: #fff;
            text-align: center;
        }

        .login-container .avatar {
            background: #0d2b4e;
            width: 80px;
            height: 80px;
            margin: 0 auto 20px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .login-container .avatar i {
            font-size: 36px;
            color: white;
        }

        .login-container input[type="email"],
        .login-container input[type="password"] {
            width: 100%;
            padding: 10px 15px;
            margin: 10px 0;
            border: none;
            border-radius: 5px;
            background: #f1f1f1;
            color: #333;
        }

        .login-container .options {
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 14px;
            margin: 10px 0;
            color: #eee;
        }

        .login-container button {
            width: 100%;
            padding: 12px;
            background-color: #0d2b4e;
            color: white;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            margin-top: 10px;
        }

        .alert {
            background-color: #ffdddd;
            color: red;
            padding: 10px;
            margin-top: 10px;
            border-radius: 5px;
        }
    </style>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"/>
</head>
<body>

<div class="login-container">
    <div class="avatar">
        <i class="fas fa-user"></i>
    </div>
    <form action="${pageContext.request.contextPath}/Login" method="post">
        <input type="email" name="email" placeholder="Email" required />
        <input type="password" name="password" placeholder="Password" required />
        <div class="options">
            <label><input type="checkbox" /> Remember me</label>
            <a href="${pageContext.request.contextPath}/ForgotPassword" style="color: #eee;">Forgot Password?</a>
        </div>

        <c:if test="${not empty error}">
            <div class="alert">${error}</div>
        </c:if>

        <button type="submit">LOGIN</button>
    </form>
</div>

</body>
</html>


