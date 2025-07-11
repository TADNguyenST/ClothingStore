<%-- 
    Document   : verify-otp
    Created on : Jun 14, 2025, 4:07:02 AM
    Author     : Khoa 
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Verify OTP</title>
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
        
        .otp-container {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.15);
            padding: 3rem 2.5rem;
            width: 100%;
            max-width: 480px;
            position: relative;
            overflow: hidden;
        }
        
        .otp-container::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        
        .otp-header {
            text-align: center;
            margin-bottom: 2.5rem;
        }
        
        .otp-icon {
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
            0% { transform: scale(1); }
            50% { transform: scale(1.05); }
            100% { transform: scale(1); }
        }
        
        .otp-header h2 {
            font-size: 1.8rem;
            font-weight: 700;
            color: #333;
            margin-bottom: 0.5rem;
        }
        
        .otp-subtitle {
            color: #666;
            font-size: 0.95rem;
            line-height: 1.5;
            margin-bottom: 1rem;
        }
        
        .otp-info {
            background: #f8f9fa;
            padding: 1rem;
            border-radius: 12px;
            border-left: 4px solid #667eea;
            margin-bottom: 2rem;
        }
        
        .otp-info p {
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
        
        .otp-input-container {
            position: relative;
        }
        
        .otp-input {
            width: 100%;
            padding: 1.2rem;
            border: 2px solid #e1e5e9;
            border-radius: 12px;
            font-size: 1.5rem;
            background: #f8f9fa;
            transition: all 0.3s ease;
            color: #333;
            text-align: center;
            letter-spacing: 0.3rem;
            font-weight: 600;
        }
        
        .otp-input:focus {
            outline: none;
            border-color: #667eea;
            background: white;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
            transform: translateY(-2px);
        }
        
        .otp-input::placeholder {
            color: #999;
            font-weight: 400;
            letter-spacing: normal;
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
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
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
        
        .resend-section {
            margin-top: 2rem;
            text-align: center;
            padding-top: 1.5rem;
            border-top: 1px solid #e9ecef;
        }
        
        .resend-text {
            color: #666;
            font-size: 0.9rem;
            margin-bottom: 0.5rem;
        }
        
        .resend-link {
            color: #667eea;
            text-decoration: none;
            font-weight: 600;
            transition: color 0.3s ease;
        }
        
        .resend-link:hover {
            color: #764ba2;
            text-decoration: underline;
        }
        
        .timer {
            display: inline-block;
            padding: 0.3rem 0.8rem;
            background: #f8f9fa;
            border-radius: 20px;
            font-size: 0.8rem;
            color: #666;
            font-weight: 600;
            margin-left: 0.5rem;
        }
        
        @media (max-width: 480px) {
            .otp-container {
                padding: 2rem 1.5rem;
                margin: 1rem;
            }
            
            .otp-header h2 {
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
            
            .otp-input {
                font-size: 1.2rem;
                padding: 1rem;
            }
        }
    </style>
</head>
<body>
    <div class="otp-container">
        <div class="otp-header">
            <div class="otp-icon">📱</div>
            <h2>Verify OTP</h2>
            <p class="otp-subtitle">We've sent a verification code to your email address</p>
        </div>
        
        <div class="otp-info">
            <p>Please enter the 6-digit verification code sent to your email.</p>
        </div>
        
        <form action="VerifyOTP" method="post">
            <div class="form-group">
                <label class="form-label">Verification Code</label>
                <div class="otp-input-container">
                    <input type="text" name="otp" class="otp-input" placeholder="000000" maxlength="6" required />
                </div>
            </div>
            
            <div class="button-group">
                <button type="submit" class="btn btn-primary">Verify Code</button>
                <a href="${pageContext.request.contextPath}/Login" class="btn btn-secondary">Back to Login</a>
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
        
        <div class="resend-section">
            <p class="resend-text">Didn't receive the code?</p>
            <a href="#" class="resend-link" onclick="resendOTP()">Resend Code</a>
            <span class="timer" id="timer" style="display: none;">Resend in <span id="countdown">5m 0s</span></span>
        </div>
    </div>

    <script>
        let timerInterval;
        let isTimerRunning = false;
        
        // Auto-format OTP input
        document.querySelector('.otp-input').addEventListener('input', function(e) {
            // Remove any non-numeric characters
            this.value = this.value.replace(/\D/g, '');
            
            // Auto-submit when 6 digits are entered
            if (this.value.length === 6) {
                setTimeout(() => {
                    this.form.submit();
                }, 500);
            }
        });
        
        // Add input animations
        document.querySelector('.otp-input').addEventListener('focus', function() {
            this.parentElement.style.transform = 'scale(1.02)';
        });
        
        document.querySelector('.otp-input').addEventListener('blur', function() {
            this.parentElement.style.transform = 'scale(1)';
        });
        
        // Resend OTP functionality
        function resendOTP() {
            if (isTimerRunning) return;
            
            // Simulate resend request
            const resendLink = document.querySelector('.resend-link');
            const timer = document.getElementById('timer');
            const countdown = document.getElementById('countdown');
            
            resendLink.style.display = 'none';
            timer.style.display = 'inline-block';
            isTimerRunning = true;
            
            let timeLeft = 300; // 5 minutes = 300 seconds
            countdown.textContent = Math.floor(timeLeft / 60) + 'm ' + (timeLeft % 60) + 's';
            
            timerInterval = setInterval(() => {
                timeLeft--;
                const minutes = Math.floor(timeLeft / 60);
                const seconds = timeLeft % 60;
                countdown.textContent = minutes + 'm ' + seconds + 's';
                
                if (timeLeft <= 0) {
                    clearInterval(timerInterval);
                    timer.style.display = 'none';
                    resendLink.style.display = 'inline';
                    isTimerRunning = false;
                }
            }, 1000);
            
            // Here you would make an AJAX call to resend OTP
            console.log('Resending OTP...');
        }
        
        // Start timer on page load (optional)
        window.addEventListener('load', function() {
            setTimeout(() => {
                resendOTP();
            }, 1000);
        });
        
        // Add keyboard navigation
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Enter') {
                const otpInput = document.querySelector('.otp-input');
                if (document.activeElement === otpInput && otpInput.value.length === 6) {
                    otpInput.form.submit();
                }
            }
        });
    </script>
</body>
</html>