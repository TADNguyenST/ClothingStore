<%-- 
    Document   : reset-password
    Created on : Jun 14, 2025, 4:33:05 AM
    Author     : Lenovo
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Reset Password</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 1rem;
        }
        
        .reset-password-container {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.15);
            padding: 3rem 2.5rem;
            width: 100%;
            max-width: 450px;
            position: relative;
            overflow: hidden;
        }
        
        .reset-password-container::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        
        .reset-header {
            text-align: center;
            margin-bottom: 2.5rem;
        }
        
        .reset-icon {
            width: 70px;
            height: 70px;
            border-radius: 50%;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 1.5rem;
            font-size: 2rem;
            color: white;
            box-shadow: 0 8px 25px rgba(102, 126, 234, 0.3);
        }
        
        .reset-header h2 {
            font-size: 1.8rem;
            font-weight: 700;
            color: #333;
            margin-bottom: 0.5rem;
        }
        
        .reset-subtitle {
            color: #666;
            font-size: 0.95rem;
            line-height: 1.5;
        }
        
        .form-group {
            margin-bottom: 1.5rem;
            position: relative;
        }
        
        .form-label {
            display: block;
            font-weight: 600;
            color: #333;
            font-size: 0.9rem;
            margin-bottom: 0.5rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .password-field {
            position: relative;
        }
        
        .password-field input {
            width: 100%;
            padding: 1rem 3.5rem 1rem 1rem;
            border: 2px solid #e1e5e9;
            border-radius: 12px;
            font-size: 1rem;
            background: #f8f9fa;
            transition: all 0.3s ease;
            color: #333;
        }
        
        .password-field input:focus {
            outline: none;
            border-color: #667eea;
            background: white;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
            transform: translateY(-2px);
        }
        
        .password-field input::placeholder {
            color: #999;
            font-weight: 400;
        }
        
        .toggle-visibility {
            position: absolute;
            top: 50%;
            right: 1rem;
            transform: translateY(-50%);
            cursor: pointer;
            font-size: 1.2rem;
            color: #666;
            transition: color 0.3s ease;
            user-select: none;
        }
        
        .toggle-visibility:hover {
            color: #667eea;
        }
        
        .submit-btn {
            width: 100%;
            padding: 1rem 2rem;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 50px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-top: 1rem;
        }
        
        .submit-btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 30px rgba(102, 126, 234, 0.4);
        }
        
        .submit-btn:active {
            transform: translateY(-1px);
        }
        
        .message-container {
            margin-top: 1.5rem;
        }
        
        .msg {
            padding: 1rem;
            border-radius: 12px;
            font-weight: 500;
            text-align: center;
            font-size: 0.9rem;
        }
        
        .error {
            background: #fee;
            color: #d63384;
            border: 1px solid #f5c2c7;
        }
        
        .success {
            background: #d1e7dd;
            color: #0f5132;
            border: 1px solid #badbcc;
        }
        
        .login-link {
            text-align: center;
            margin-top: 1.5rem;
        }
        
        .btn-login {
            display: inline-block;
            padding: 0.75rem 2rem;
            background: transparent;
            color: #667eea;
            border: 2px solid #667eea;
            border-radius: 50px;
            font-size: 0.9rem;
            font-weight: 600;
            text-decoration: none;
            transition: all 0.3s ease;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .btn-login:hover {
            background: #667eea;
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(102, 126, 234, 0.3);
        }
        
        .btn-login:active {
            transform: translateY(-1px);
        }
        
        .security-note {
            margin-top: 2rem;
            padding: 1rem;
            background: #f8f9fa;
            border-radius: 12px;
            border-left: 4px solid #667eea;
        }
        
        .security-note h4 {
            color: #333;
            font-size: 0.9rem;
            margin-bottom: 0.5rem;
            font-weight: 600;
        }
        
        .security-note p {
            color: #666;
            font-size: 0.8rem;
            line-height: 1.4;
            margin: 0;
        }
        
        @media (max-width: 480px) {
            .reset-password-container {
                padding: 2rem 1.5rem;
                margin: 1rem;
            }
            
            .reset-header h2 {
                font-size: 1.5rem;
            }
            
            .password-field input {
                padding: 0.9rem 3rem 0.9rem 0.9rem;
            }
        }
    </style>
</head>
<body>
    <div class="reset-password-container">
        <div class="reset-header">
            <div class="reset-icon">🔐</div>
            <h2>Reset Password</h2>
            <p class="reset-subtitle">Create a new secure password for your account</p>
        </div>
        
        <form action="ResetPassword" method="post">
            <div class="form-group">
                <label class="form-label">New Password</label>
                <div class="password-field">
                    <input type="password" name="password" placeholder="Enter your new password" id="password" required>
                    <span class="toggle-visibility" onclick="togglePassword('password', this)">👁️</span>
                </div>
            </div>
            
            <div class="form-group">
                <label class="form-label">Confirm Password</label>
                <div class="password-field">
                    <input type="password" name="confirm" placeholder="Confirm your new password" id="confirm" required>
                    <span class="toggle-visibility" onclick="togglePassword('confirm', this)">👁️</span>
                </div>
            </div>
            
            <button type="submit" class="submit-btn">Update Password</button>
            
            <div class="login-link">
                <a href="${pageContext.request.contextPath}/Login" class="btn-login">Back to Login</a>
            </div>
        </form>
        
        <div class="message-container">
            <c:if test="${not empty error}">
                <div class="msg error">${error}</div>
            </c:if>
            <c:if test="${not empty success}">
                <div class="msg success">${success}</div>
            </c:if>
        </div>
        
        <div class="security-note">
            <h4>Password Security Tips</h4>
            <p>Use at least 8 characters with a mix of uppercase, lowercase, numbers, and special characters for better security.</p>
        </div>
    </div>

    <script>
        function togglePassword(fieldId, element) {
            const input = document.getElementById(fieldId);
            if (input.type === "password") {
                input.type = "text";
                element.textContent = "🙈";
            } else {
                input.type = "password";
                element.textContent = "👁️";
            }
        }
        
        // Add form validation
        document.querySelector('form').addEventListener('submit', function(e) {
            const password = document.getElementById('password').value;
            const confirm = document.getElementById('confirm').value;
            
            if (password !== confirm) {
                e.preventDefault();
                alert('Passwords do not match!');
                return false;
            }
            
            if (password.length < 6) {
                e.preventDefault();
                alert('Password must be at least 6 characters long!');
                return false;
            }
        });
        
        // Add input animations
        document.querySelectorAll('input').forEach(input => {
            input.addEventListener('focus', function() {
                this.parentElement.style.transform = 'scale(1.02)';
            });
            
            input.addEventListener('blur', function() {
                this.parentElement.style.transform = 'scale(1)';
            });
        });
    </script>
</body>
</html>