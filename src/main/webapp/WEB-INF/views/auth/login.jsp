<%-- 
    Document   : Login
    Created on : Jun 14, 2025, 4:07:02 AM
    Author     : Khoa
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Customer Login - ClothingStore</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }

            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                min-height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
                padding: 20px;
                position: relative;
            }

            body::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;
                background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><defs><pattern id="dots" width="20" height="20" patternUnits="userSpaceOnUse"><circle cx="10" cy="10" r="1" fill="rgba(255,255,255,0.1)"/></pattern></defs><rect width="100" height="100" fill="url(%23dots)"/></svg>');
                opacity: 0.5;
            }

            .login-container {
                background: rgba(255, 255, 255, 0.95);
                backdrop-filter: blur(10px);
                border-radius: 20px;
                box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
                overflow: hidden;
                width: 100%;
                max-width: 450px;
                animation: slideUp 0.6s ease-out;
                position: relative;
                z-index: 1;
            }

            @keyframes slideUp {
                from {
                    opacity: 0;
                    transform: translateY(30px);
                }
                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }

            .login-header {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                padding: 40px 30px;
                text-align: center;
                position: relative;
            }

            .login-header::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;
                background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><defs><pattern id="grain" width="100" height="100" patternUnits="userSpaceOnUse"><circle cx="25" cy="25" r="1" fill="rgba(255,255,255,0.1)"/><circle cx="75" cy="75" r="1" fill="rgba(255,255,255,0.1)"/></pattern></defs><rect width="100" height="100" fill="url(%23grain)"/></svg>');
                opacity: 0.3;
            }

            .login-header h2 {
                font-size: 2.2em;
                margin-bottom: 10px;
                position: relative;
                z-index: 1;
                font-weight: 700;
                text-transform: uppercase;
                letter-spacing: 1px;
            }

            .login-header p {
                font-size: 1em;
                opacity: 0.9;
                position: relative;
                z-index: 1;
                margin: 0;
            }

            .login-icon {
                font-size: 3em;
                margin-bottom: 20px;
                position: relative;
                z-index: 1;
            }

            .login-form {
                padding: 40px 30px;
            }

            .form-group {
                margin-bottom: 25px;
                position: relative;
            }

            .form-group label {
                display: block;
                margin-bottom: 8px;
                color: #333;
                font-weight: 600;
                font-size: 14px;
                text-transform: uppercase;
                letter-spacing: 0.5px;
            }

            .input-wrapper {
                position: relative;
            }

            .form-group input {
                width: 100%;
                padding: 15px 45px 15px 15px;
                border: 2px solid #e1e5e9;
                border-radius: 12px;
                font-size: 16px;
                transition: all 0.3s ease;
                background: #f8f9fa;
            }

            .form-group input:focus {
                outline: none;
                border-color: #667eea;
                background: white;
                box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
                transform: translateY(-1px);
            }

            .form-group input:hover {
                border-color: #667eea;
                background: white;
            }

            .input-icon {
                position: absolute;
                right: 15px;
                top: 50%;
                transform: translateY(-50%);
                color: #6c757d;
                font-size: 18px;
            }

            .password-toggle {
                position: absolute;
                right: 15px;
                top: 50%;
                transform: translateY(-50%);
                background: none;
                border: none;
                color: #6c757d;
                cursor: pointer;
                font-size: 18px;
                padding: 5px;
                border-radius: 4px;
                transition: color 0.3s ease;
                z-index: 10;
            }

            .password-toggle:hover {
                color: #667eea;
            }

            .password-toggle:focus {
                outline: none;
                color: #667eea;
            }

            .login-btn {
                width: 100%;
                padding: 15px;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                border: none;
                border-radius: 12px;
                font-size: 16px;
                font-weight: 600;
                text-transform: uppercase;
                letter-spacing: 1px;
                cursor: pointer;
                transition: all 0.3s ease;
                position: relative;
                overflow: hidden;
            }

            .login-btn::before {
                content: '';
                position: absolute;
                top: 0;
                left: -100%;
                width: 100%;
                height: 100%;
                background: linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent);
                transition: left 0.5s;
            }

            .login-btn:hover::before {
                left: 100%;
            }

            .login-btn:hover {
                transform: translateY(-2px);
                box-shadow: 0 10px 25px rgba(102, 126, 234, 0.3);
            }

            .login-btn:active {
                transform: translateY(0);
            }

            .error-message {
                background: #fee;
                color: #c53030;
                padding: 12px 15px;
                border-radius: 8px;
                margin-top: 20px;
                border-left: 4px solid #fc8181;
                font-size: 14px;
                animation: shake 0.5s ease-in-out;
            }

            @keyframes shake {
                0%, 100% {
                    transform: translateX(0);
                }
                25% {
                    transform: translateX(-5px);
                }
                75% {
                    transform: translateX(5px);
                }
            }

            .divider {
                display: flex;
                align-items: center;
                margin: 25px 0;
                color: #999;
                font-size: 14px;
            }

            .divider::before,
            .divider::after {
                content: '';
                flex: 1;
                height: 1px;
                background: #e1e5e9;
            }

            .divider span {
                padding: 0 15px;
                font-weight: 500;
            }

            .login-footer {
                text-align: center;
                margin-top: 25px;
                padding-top: 25px;
                border-top: 1px solid #e1e5e9;
            }

            .login-footer p {
                margin: 8px 0;
                color: #666;
                font-size: 14px;
            }

            .login-footer a {
                color: #667eea;
                text-decoration: none;
                font-weight: 500;
                transition: color 0.3s ease;
            }

            .login-footer a:hover {
                color: #764ba2;
                text-decoration: underline;
            }

            .loading {
                display: none;
                text-align: center;
                margin-top: 15px;
            }

            .loading i {
                animation: spin 1s linear infinite;
            }

            @keyframes spin {
                0% {
                    transform: rotate(0deg);
                }
                100% {
                    transform: rotate(360deg);
                }
            }

            /* Responsive Design */
            @media (max-width: 480px) {
                .login-container {
                    margin: 10px;
                    border-radius: 15px;
                    max-width: 100%;
                }

                .login-header {
                    padding: 30px 20px;
                }

                .login-form {
                    padding: 30px 20px;
                }

                .login-header h2 {
                    font-size: 1.8em;
                }

                .form-group input {
                    padding: 12px 40px 12px 12px;
                    font-size: 15px;
                }

                .password-toggle {
                    right: 12px;
                    font-size: 16px;
                }
            }

            @media (max-width: 400px) {
                .login-header h2 {
                    font-size: 1.5em;
                }

                .login-form {
                    padding: 25px 15px;
                }
            }

            /* Dark mode support */
            @media (prefers-color-scheme: dark) {
                .login-container {
                    background: rgba(30, 30, 30, 0.95);
                    color: #e0e0e0;
                }

                .form-group input {
                    background: #2a2a2a;
                    border-color: #404040;
                    color: #e0e0e0;
                }

                .form-group input:focus {
                    background: #333;
                    border-color: #667eea;
                }

                .form-group label {
                    color: #e0e0e0;
                }

                .login-footer p {
                    color: #ccc;
                }

                .divider {
                    color: #ccc;
                }

                .divider::before,
                .divider::after {
                    background: #404040;
                }
            }

            /* Ripple effect */
            .ripple {
                position: absolute;
                border-radius: 50%;
                background: rgba(255, 255, 255, 0.6);
                transform: scale(0);
                animation: ripple-animation 0.6s linear;
                pointer-events: none;
            }

            @keyframes ripple-animation {
                to {
                    transform: scale(4);
                    opacity: 0;
                }
            }
        </style>
    </head>
    <body>
        <div class="login-container">
            <div class="login-header">
                <div class="login-icon">
                    <i class="fas fa-user"></i>
                </div>
                <h2>Welcome Back</h2>
                <p>Please enter your email and password to continue</p>
            </div>

            <div class="login-form">
                <form action="${pageContext.request.contextPath}/Login" method="post" id="loginForm">
                    <div class="form-group">
                        <label for="email">
                            <i class="fas fa-envelope"></i> Email Address
                        </label>
                        <div class="input-wrapper">
                            <input type="email" 
                                   id="email" 
                                   name="email" 
                                   placeholder="Enter your email address"
                                   required>
                            <i class="fas fa-user input-icon"></i>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="password">
                            <i class="fas fa-lock"></i> Password
                        </label>
                        <div class="input-wrapper">
                            <input type="password" 
                                   id="password" 
                                   name="password" 
                                   placeholder="Enter your password"
                                   required>
                            <button type="button" 
                                    class="password-toggle" 
                                    onclick="togglePassword('password')"
                                    title="Show/Hide Password">
                                <i class="fas fa-eye-slash"></i>
                            </button>
                        </div>
                    </div>

                    <button type="submit" class="login-btn">
                        <i class="fas fa-sign-in-alt"></i>
                        Sign In
                    </button>

                    <div class="loading" id="loading">
                        <i class="fas fa-spinner"></i>
                        Signing you in...
                    </div>

                    <c:if test="${not empty error}">
                        <div class="error-message">
                            <i class="fas fa-exclamation-triangle"></i>
                            ${error}
                        </div>
                    </c:if>
                </form>

                <div class="divider">
                    <span>or</span>
                </div>

                <div class="login-footer">
                    <p>Don't have an account? <a href="${pageContext.request.contextPath}/Register">Create Account</a></p>
                    <p><a href="${pageContext.request.contextPath}/ForgotPassword">Forgot Password?</a></p>
                </div>
            </div>
        </div>

        <script>
            function togglePassword(inputId) {
                const input = document.getElementById(inputId);
                const button = input.nextElementSibling;
                const icon = button.querySelector('i');

                if (input.type === 'password') {
                    input.type = 'text';
                    icon.classList.remove('fa-eye-slash');
                    icon.classList.add('fa-eye');
                    button.title = 'Hide Password';
                } else {
                    input.type = 'password';
                    icon.classList.remove('fa-eye');
                    icon.classList.add('fa-eye-slash');
                    button.title = 'Show Password';
                }
            }

            // Form submission with loading state
            document.getElementById('loginForm').addEventListener('submit', function () {
                const submitBtn = this.querySelector('.login-btn');
                const loading = document.getElementById('loading');

                submitBtn.style.display = 'none';
                loading.style.display = 'block';
            });

            // Auto-focus on email field
            document.addEventListener('DOMContentLoaded', function () {
                const emailInput = document.getElementById('email');
                emailInput.focus();
            });

            // Add ripple effect to button
            document.querySelector('.login-btn').addEventListener('click', function (e) {
                const ripple = document.createElement('span');
                const rect = this.getBoundingClientRect();
                const size = Math.max(rect.width, rect.height);
                const x = e.clientX - rect.left - size / 2;
                const y = e.clientY - rect.top - size / 2;

                ripple.style.width = ripple.style.height = size + 'px';
                ripple.style.left = x + 'px';
                ripple.style.top = y + 'px';
                ripple.classList.add('ripple');

                this.appendChild(ripple);

                setTimeout(() => {
                    ripple.remove();
                }, 600);
            });

            // Prevent form submission when clicking password toggle
            document.querySelectorAll('.password-toggle').forEach(button => {
                button.addEventListener('click', function (e) {
                    e.preventDefault();
                    e.stopPropagation();
                });
            });

            // Keyboard support for accessibility
            document.addEventListener('keydown', function (e) {
                if (e.key === 'Enter' && e.target.classList.contains('password-toggle')) {
                    e.preventDefault();
                    const inputId = e.target.previousElementSibling.id;
                    togglePassword(inputId);
                }
            });
        </script>
    </body>
</html>