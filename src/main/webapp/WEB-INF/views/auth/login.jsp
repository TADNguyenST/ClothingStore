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
            background: linear-gradient(135deg, #008cff, #00d4ff);
            font-family: Arial, sans-serif;
            height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .login-container {
            width: 350px;
            background: #fff;
            border-radius: 15px;
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
            padding: 40px 30px;
            text-align: center;
        }
        h2 {
            color: #333;
            margin-bottom: 30px;
            font-size: 28px;
            font-weight: 600;
        }
        .form-control {
            position: relative;
            margin-bottom: 20px;
        }
        input[type="email"],
        input[type="password"] {
            width: 100%;
            padding: 15px 45px 15px 15px;
            border: 2px solid #e0e0e0;
            border-radius: 10px;
            font-size: 16px;
            background-color: #f8f9fa;
            box-sizing: border-box;
            transition: all 0.3s ease;
        }
        input[type="email"]:focus,
        input[type="password"]:focus {
            outline: none;
            border-color: #007bff;
            background-color: #fff;
        }
        .form-control i {
            position: absolute;
            right: 15px;
            top: 50%;
            transform: translateY(-50%);
            cursor: pointer;
            color: #666;
            font-size: 18px;
        }
        .login-btn {
            width: 100%;
            padding: 15px;
            background: linear-gradient(135deg, #007bff, #0056b3);
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            margin-top: 10px;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(0, 123, 255, 0.3);
        }
        .login-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(0, 123, 255, 0.4);
        }
        .links {
            margin-top: 25px;
            display: flex;
            justify-content: space-between;
            gap: 10px;
        }
        .link-btn {
            flex: 1;
            padding: 12px 15px;
            text-decoration: none;
            color: #007bff;
            border: 2px solid #007bff;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 500;
            transition: all 0.3s ease;
            display: inline-block;
            text-align: center;
        }
        .link-btn:hover {
            background-color: #007bff;
            color: white;
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(0, 123, 255, 0.3);
        }
        .alert {
            background-color: #ffe6e6;
            color: #d63384;
            padding: 12px;
            margin: 15px 0;
            border-radius: 8px;
            border-left: 4px solid #d63384;
            font-size: 14px;
        }
    </style>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"/>
</head>
<body>
<div class="login-container">
    <h2>Sign In</h2>
    <form action="${pageContext.request.contextPath}/Login" method="post">
        <div class="form-control">
            <input type="email" name="email" placeholder="johndoe@example.com" required />
        </div>
        <div class="form-control">
            <input type="password" id="password" name="password" placeholder="••••••••••" required />
            <i class="fas fa-eye" id="togglePassword"></i>
        </div>
        <c:if test="${not empty error}">
            <div class="alert">${error}</div>
        </c:if>
        <button type="submit" class="login-btn">Login</button>
        <div class="links">
            <a href="${pageContext.request.contextPath}/ForgotPassword" class="link-btn">Forgot Password?</a>
            <a href="${pageContext.request.contextPath}/Register" class="link-btn">Create an Account?</a>
        </div>
    </form>
</div>
<script>
    // Toggle show/hide password
    const togglePassword = document.getElementById('togglePassword');
    const password = document.getElementById('password');
    
    togglePassword.addEventListener('click', function () {
        const type = password.getAttribute('type') === 'password' ? 'text' : 'password';
        password.setAttribute('type', type);
        this.classList.toggle('fa-eye-slash');
    });
</script>
</body>
</html>