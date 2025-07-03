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
        <title>Customer Login</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    </head>
    <body>

        <style>
            /* CSS cho trang login */
            .login-container {
                min-height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
                background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
                padding: 2rem 1rem;
            }

            .login-card {
                background: white;
                border-radius: 15px;
                box-shadow: 0 15px 35px rgba(0, 0, 0, 0.1);
                padding: 3rem 2.5rem;
                width: 100%;
                max-width: 450px;
                position: relative;
                overflow: hidden;
            }

            .login-card::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                height: 4px;
                background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
            }

            .login-header {
                text-align: center;
                margin-bottom: 2rem;
            }

            .login-header h2 {
                font-size: 2rem;
                font-weight: 700;
                color: #333;
                text-transform: uppercase;
                letter-spacing: 1px;
                margin-bottom: 0.5rem;
            }

            .login-header p {
                color: #666;
                font-size: 1rem;
                margin: 0;
            }

            .form-group {
                margin-bottom: 1.5rem;
                position: relative;
            }

            .form-label {
                display: block;
                font-weight: 600;
                color: #333;
                margin-bottom: 0.5rem;
                text-transform: uppercase;
                font-size: 0.9rem;
                letter-spacing: 0.5px;
            }

            .form-input {
                width: 100%;
                padding: 1rem 1.2rem;
                border: 2px solid #e1e5e9;
                border-radius: 8px;
                font-size: 1rem;
                transition: all 0.3s ease;
                background: #f8f9fa;
                box-sizing: border-box;
            }

            /* Điều chỉnh padding cho input có nút toggle */
            .password-input-container .form-input {
                padding-right: 3rem;
            }

            .form-input:focus {
                outline: none;
                border-color: #667eea;
                background: white;
                box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
                transform: translateY(-1px);
            }

            .form-input:hover {
                border-color: #667eea;
                background: white;
            }

            /* Nút toggle password */
            .password-toggle {
                position: absolute;
                right: 12px;
                top: 50%;
                transform: translateY(-50%);
                background: none;
                border: none;
                color: #666;
                cursor: pointer;
                font-size: 1.2rem;
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
                padding: 1rem 2rem;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                border: none;
                border-radius: 8px;
                font-size: 1.1rem;
                font-weight: 600;
                text-transform: uppercase;
                letter-spacing: 1px;
                cursor: pointer;
                transition: all 0.3s ease;
                margin-top: 1rem;
            }

            .login-btn:hover {
                transform: translateY(-2px);
                box-shadow: 0 8px 25px rgba(102, 126, 234, 0.3);
            }

            .login-btn:active {
                transform: translateY(0);
            }

            .error-message {
                background: #ff6b6b;
                color: white;
                padding: 1rem;
                border-radius: 8px;
                text-align: center;
                margin-top: 1rem;
                font-weight: 500;
                animation: slideIn 0.3s ease;
            }

            .login-footer {
                text-align: center;
                margin-top: 2rem;
                padding-top: 2rem;
                border-top: 1px solid #e1e5e9;
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

            .divider {
                display: flex;
                align-items: center;
                margin: 2rem 0;
                color: #999;
                font-size: 0.9rem;
            }

            .divider::before,
            .divider::after {
                content: '';
                flex: 1;
                height: 1px;
                background: #e1e5e9;
            }

            .divider span {
                padding: 0 1rem;
            }

            @keyframes slideIn {
                from {
                    opacity: 0;
                    transform: translateY(-10px);
                }
                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }

            /* Responsive */
            @media (max-width: 576px) {
                .login-card {
                    padding: 2rem 1.5rem;
                    margin: 1rem;
                }

                .login-header h2 {
                    font-size: 1.5rem;
                }

                .form-input {
                    padding: 0.8rem 1rem;
                    font-size: 0.9rem;
                }

                .password-input-container .form-input {
                    padding-right: 2.5rem;
                }

                .password-toggle {
                    right: 10px;
                    font-size: 1rem;
                }
            }

            @media (max-width: 400px) {
                .login-card {
                    padding: 1.5rem 1rem;
                }

                .login-header h2 {
                    font-size: 1.3rem;
                }
            }
        </style>

        <div class="login-container">
            <div class="login-card">
                <div class="login-header">
                    <h2>Welcome Clothing Store</h2>
                    <p>Please, Enter your Mail and Password</p>
                </div>

                <form action="${pageContext.request.contextPath}/Login" method="post">
                    <div class="form-group">
                        <label class="form-label" for="email">Email Address</label>
                        <input type="email" 
                               id="email" 
                               name="email" 
                               class="form-input" 
                               placeholder="Enter your email"
                               required>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="password">Password</label>
                        <div class="password-input-container" style="position: relative;">
                            <input type="password" 
                                   id="password" 
                                   name="password" 
                                   class="form-input" 
                                   placeholder="Enter your password"
                                   required>
                            <button type="button" 
                                    class="password-toggle" 
                                    onclick="togglePassword('password')"
                                    title="Show/Hide Password">
                                👁
                            </button>
                        </div>
                    </div>

                    <button type="submit" class="login-btn">Login</button>

                    <c:if test="${not empty error}">
                        <div class="error-message">
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

                if (input.type === 'password') {
                    input.type = 'text';
                    button.innerHTML = '🙈';
                    button.title = 'Hide Password';
                } else {
                    input.type = 'password';
                    button.innerHTML = '👁';
                    button.title = 'Show Password';
                }
            }

            // Optional: Add keyboard support for accessibility
            document.addEventListener('keydown', function (e) {
                // Allow Enter key to toggle password when focused on toggle button
                if (e.key === 'Enter' && e.target.classList.contains('password-toggle')) {
                    e.preventDefault();
                    const inputId = e.target.previousElementSibling.id;
                    togglePassword(inputId);
                }
            });

            // Optional: Prevent form submission when clicking password toggle
            document.querySelectorAll('.password-toggle').forEach(button => {
                button.addEventListener('click', function (e) {
                    e.preventDefault();
                    e.stopPropagation();
                });
            });
        </script>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>