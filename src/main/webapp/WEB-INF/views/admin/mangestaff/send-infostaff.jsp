<%--  
    Document   : send-infostaff
    Created on : Aug 20, 2025, 3:14:21 PM
    Author     : default
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-Frame-Options" content="DENY">
    <meta http-equiv="X-Content-Type-Options" content="nosniff">
    <title>Send Staff Info</title>
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

        .forgot-container {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.15);
            padding: 3rem 2.5rem;
            width: 100%;
            max-width: 480px;
            position: relative;
            overflow: hidden;
        }

        .forgot-container::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }

        .forgot-header {
            text-align: center;
            margin-bottom: 2.5rem;
        }

        .forgot-icon {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 1.5rem;
            font-size: 2.2rem;
            color: white;
            box-shadow: 0 8px 25px rgba(102, 126, 234, 0.3);
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0% {
                transform: scale(1);
            }
            50% {
                transform: scale(1.05);
            }
            100% {
                transform: scale(1);
            }
        }

        .forgot-header h2 {
            font-size: 1.8rem;
            font-weight: 700;
            color: #333;
            margin-bottom: 0.5rem;
        }

        .forgot-subtitle {
            color: #666;
            font-size: 0.95rem;
            line-height: 1.5;
            margin-bottom: 1rem;
        }

        .forgot-info {
            background: #f8f9fa;
            padding: 1rem;
            border-radius: 12px;
            border-left: 4px solid #667eea;
            margin-bottom: 2rem;
        }

        .forgot-info p {
            color: #666;
            font-size: 0.85rem;
            line-height: 1.4;
            margin: 0;
        }

        .form-group {
            margin-bottom: 2rem;
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

        .email-input-container {
            position: relative;
        }

        .email-input {
            width: 100%;
            padding: 1.2rem 3rem 1.2rem 1.2rem;
            border: 2px solid #e1e5e9;
            border-radius: 12px;
            font-size: 1rem;
            background: #f8f9fa;
            transition: all 0.3s ease;
            color: #333;
            font-weight: 500;
        }

        .email-input:focus {
            outline: none;
            border-color: #667eea;
            background: white;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
            transform: translateY(-2px);
        }

        .email-input::placeholder {
            color: #999;
            font-weight: 400;
        }

        .email-icon {
            position: absolute;
            top: 50%;
            right: 1rem;
            transform: translateY(-50%);
            font-size: 1.2rem;
            color: #666;
            transition: color 0.3s ease;
        }

        .email-input:focus + .email-icon {
            color: #667eea;
        }

        .email-validation {
            margin-top: 0.5rem;
            font-size: 0.8rem;
            opacity: 0;
            transition: opacity 0.3s ease;
        }

        .email-validation.show {
            opacity: 1;
        }

        .email-validation.valid {
            color: #2ed573;
        }

        .email-validation.invalid {
            color: #ff4757;
        }

        .button-group {
            display: flex;
            justify-content: center;
            gap: 1rem;
            margin-top: 1.5rem;
            flex-wrap: wrap;
        }

        .btn {
            padding: 1rem 2rem;
            border-radius: 50px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-width: 120px;
            position: relative;
            overflow: hidden;
        }

        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
        }

        .btn-primary:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 30px rgba(102, 126, 234, 0.4);
        }

        .btn-primary:disabled {
            opacity: 0.6;
            cursor: not-allowed;
            transform: none;
        }

        .btn-secondary {
            background: transparent;
            color: #667eea;
            border: 2px solid #667eea;
        }

        .btn-secondary:hover {
            background: #667eea;
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(102, 126, 234, 0.3);
        }

        .btn:active {
            transform: translateY(-1px);
        }

        .loading-spinner {
            width: 20px;
            height: 20px;
            border: 2px solid rgba(255, 255, 255, 0.3);
            border-top: 2px solid white;
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin-right: 0.5rem;
            display: none;
        }

        @keyframes spin {
            0% {
                transform: rotate(0deg);
            }
            100% {
                transform: rotate(360deg);
            }
        }

        .btn-primary.loading .loading-spinner {
            display: inline-block;
        }

        .btn-primary.loading .btn-text {
            opacity: 0.7;
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
            animation: slideIn 0.3s ease;
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

        .back-section {
            margin-top: 2rem;
            text-align: center;
            padding-top: 1.5rem;
            border-top: 1px solid #e9ecef;
        }

        .back-text {
            color: #666;
            font-size: 0.9rem;
            margin-bottom: 0.5rem;
        }

        .back-link {
            color: #667eea;
            text-decoration: none;
            font-weight: 600;
            transition: color 0.3s ease;
        }

        .back-link:hover {
            color: #764ba2;
            text-decoration: underline;
        }

        @media (max-width: 480px) {
            .forgot-container {
                padding: 2rem 1.5rem;
                margin: 1rem;
            }

            .forgot-header h2 {
                font-size: 1.5rem;
            }

            .button-group {
                flex-direction: column;
                align-items: center;
            }

            .btn {
                width: 100%;
                max-width: 200px;
            }

            .email-input {
                font-size: 1rem;
                padding: 1rem 3rem 1rem 1rem;
            }
        }
    </style>
</head>
<body>
    <div class="forgot-container">
        <div class="forgot-header">
            <div class="forgot-icon">👨‍💼</div>
            <h2>Send Staff Info</h2>
            <p class="forgot-subtitle">Send account information to staff email address</p>
        </div>

        <div class="forgot-info">
            <p>Enter the email address where you want to send the new password and account information for this staff member.</p>
        </div>

        <form action="${pageContext.request.contextPath}/sendInfoStaff" method="post" id="sendInfoForm">
            <input type="hidden" name="userId" value="${userId}" />
            
            <div class="form-group">
                <label class="form-label" for="email">Recipient Email Address</label>
                <div class="email-input-container">
                    <input type="email" id="email" name="email" class="email-input" placeholder="Enter recipient email address" required />
                    <span class="email-icon">📧</span>
                </div>
                <div class="email-validation" id="emailValidation"></div>
            </div>

            <div class="button-group">
                <button type="submit" class="btn btn-primary" id="submitBtn">
                    <div class="loading-spinner"></div>
                    <span class="btn-text">Send</span>
                </button>
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

        <div class="back-section">
            <p class="back-text">Need to go back?</p>
            <c:if test="${not empty userId}">
                <a href="${pageContext.request.contextPath}/viewStaff?userId=${userId}" class="back-link">Back to Staff Details</a>
            </c:if>
        </div>
    </div>

    <script>
        // Email validation
        const emailInput = document.getElementById('email');
        const emailValidation = document.getElementById('emailValidation');
        const submitBtn = document.getElementById('submitBtn');
        const form = document.getElementById('sendInfoForm');

        // Real-time email validation
        emailInput.addEventListener('input', function () {
            const email = this.value;
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

            if (email.length > 0) {
                emailValidation.classList.add('show');
                if (emailRegex.test(email)) {
                    emailValidation.textContent = '✓ Valid email format';
                    emailValidation.className = 'email-validation show valid';
                } else {
                    emailValidation.textContent = '✗ Please enter a valid email address';
                    emailValidation.className = 'email-validation show invalid';
                }
            } else {
                emailValidation.classList.remove('show');
            }
        });

        // Form submission with loading state
        form.addEventListener('submit', function (e) {
            const email = emailInput.value;
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

            if (!emailRegex.test(email)) {
                e.preventDefault();
                emailValidation.textContent = '✗ Please enter a valid email address';
                emailValidation.className = 'email-validation show invalid';
                return;
            }

            // Show loading state
            submitBtn.classList.add('loading');
            submitBtn.disabled = true;

            // Optional: Add a small delay to show loading state
            setTimeout(() => {
                // Form will submit naturally
            }, 500);
        });

        // Add input animations
        emailInput.addEventListener('focus', function () {
            this.parentElement.style.transform = 'scale(1.02)';
        });

        emailInput.addEventListener('blur', function () {
            this.parentElement.style.transform = 'scale(1)';
        });

        // Add keyboard navigation
        document.addEventListener('keydown', function (e) {
            if (e.key === 'Enter') {
                if (document.activeElement === emailInput) {
                    form.submit();
                }
            }
        });

        // Auto-focus email input
        window.addEventListener('load', function () {
            emailInput.focus();
        });
    </script>
</body>
</html>