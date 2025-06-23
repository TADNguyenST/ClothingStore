<%-- 
    Document   : change-password
    Created on : Jun 14, 2025, 4:07:02 AM
    Author     : Khoa
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- Đặt tiêu đề cho trang này, header.jsp sẽ dùng biến này --%>
<c:set var="pageTitle" value="Change Password" scope="request"/>

<%-- Nhúng header --%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<style>
    /* CSS cho trang change password - Responsive Design */
    .password-container {
        min-height: 80vh;
        background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
        padding: 2rem 1rem;
        display: flex;
        align-items: center;
        justify-content: center;
    }

    .password-card {
        background: white;
        border-radius: 15px;
        box-shadow: 0 15px 35px rgba(0, 0, 0, 0.1);
        padding: 2rem;
        position: relative;
        overflow: hidden;
        max-width: 500px;
        width: 100%;
    }

    .password-card::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        height: 4px;
        background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
    }

    .password-header {
        text-align: center;
        margin-bottom: 2rem;
        position: relative;
    }

    .password-icon {
        width: 60px;
        height: 60px;
        border-radius: 50%;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        display: flex;
        align-items: center;
        justify-content: center;
        margin: 0 auto 1rem;
        font-size: 1.5rem;
        color: white;
        font-weight: 700;
        box-shadow: 0 8px 20px rgba(102, 126, 234, 0.3);
    }

    .password-header h2 {
        font-size: clamp(1.3rem, 4vw, 1.6rem);
        font-weight: 700;
        color: #333;
        text-transform: uppercase;
        letter-spacing: 1px;
        margin-bottom: 0.5rem;
    }

    .password-subtitle {
        color: #666;
        font-size: clamp(0.9rem, 2.5vw, 1rem);
        margin: 0;
    }

    .password-form {
        margin-bottom: 1.5rem;
    }

    .form-group {
        margin-bottom: 1.5rem;
        position: relative;
    }

    .form-label {
        display: block;
        font-weight: 600;
        color: #333;
        text-transform: uppercase;
        font-size: clamp(0.8rem, 2vw, 0.9rem);
        letter-spacing: 0.5px;
        margin-bottom: 0.5rem;
    }

    .form-input {
        width: 100%;
        padding: 0.75rem 1rem;
        border: 2px solid #e1e5e9;
        border-radius: 8px;
        font-size: clamp(0.9rem, 2.5vw, 1rem);
        transition: all 0.3s ease;
        background: #f8f9fa;
        box-sizing: border-box;
    }

    .form-input:focus {
        outline: none;
        border-color: #667eea;
        background: white;
        box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
    }

    .form-input:hover {
        border-color: #667eea;
        background: white;
    }

    .password-toggle {
        position: absolute;
        right: 10px;
        top: 50%;
        transform: translateY(-50%);
        background: none;
        border: none;
        color: #666;
        cursor: pointer;
        font-size: 1rem;
        padding: 5px;
        border-radius: 4px;
        transition: color 0.3s ease;
    }

    .password-toggle:hover {
        color: #667eea;
    }

    .btn-submit {
        width: 100%;
        padding: 0.8rem 1.5rem;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        border: none;
        border-radius: 8px;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 1px;
        font-size: clamp(0.9rem, 2.5vw, 1rem);
        cursor: pointer;
        transition: all 0.3s ease;
        margin-bottom: 1rem;
    }

    .btn-submit:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 25px rgba(102, 126, 234, 0.3);
    }

    .btn-submit:active {
        transform: translateY(0);
    }

    .btn-cancel {
        width: 100%;
        padding: 0.8rem 1.5rem;
        background: transparent;
        color: #667eea;
        border: 2px solid #667eea;
        border-radius: 8px;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 1px;
        font-size: clamp(0.9rem, 2.5vw, 1rem);
        cursor: pointer;
        transition: all 0.3s ease;
        text-decoration: none;
        display: inline-block;
        text-align: center;
        box-sizing: border-box;
    }

    .btn-cancel:hover {
        background: #667eea;
        color: white;
        transform: translateY(-2px);
        text-decoration: none;
    }

    /* Alert Messages */
    .alert {
        padding: 0.75rem 1rem;
        border-radius: 8px;
        margin-bottom: 1rem;
        font-size: clamp(0.85rem, 2vw, 0.9rem);
        font-weight: 500;
        border-left: 4px solid;
    }

    .alert-error {
        background: #f8d7da;
        color: #721c24;
        border-left-color: #dc3545;
    }

    .alert-success {
        background: #d4edda;
        color: #155724;
        border-left-color: #28a745;
    }

    .alert-icon {
        display: inline-block;
        margin-right: 0.5rem;
        font-weight: 700;
    }

    /* Password Strength Indicator */
    .password-strength {
        margin-top: 0.5rem;
        font-size: 0.8rem;
    }

    .strength-bar {
        height: 4px;
        background: #e1e5e9;
        border-radius: 2px;
        overflow: hidden;
        margin: 0.25rem 0;
    }

    .strength-fill {
        height: 100%;
        transition: all 0.3s ease;
        border-radius: 2px;
    }

    .strength-weak .strength-fill {
        width: 33%;
        background: #dc3545;
    }

    .strength-medium .strength-fill {
        width: 66%;
        background: #ffc107;
    }

    .strength-strong .strength-fill {
        width: 100%;
        background: #28a745;
    }

    /* Responsive Breakpoints */

    /* Large Desktop (1200px+) */
    @media (min-width: 1200px) {
        .password-container {
            padding: 3rem 2rem;
        }

        .password-card {
            padding: 3rem;
        }
    }

    /* Tablet (768px - 991px) */
    @media (min-width: 768px) and (max-width: 991px) {
        .password-container {
            padding: 1.5rem 1rem;
        }

        .password-card {
            padding: 1.5rem;
        }
    }

    /* Small Tablet (576px - 767px) */
    @media (min-width: 576px) and (max-width: 767px) {
        .password-container {
            padding: 1rem 0.5rem;
        }

        .password-card {
            padding: 1.2rem;
        }

        .password-icon {
            width: 50px;
            height: 50px;
            font-size: 1.3rem;
        }
    }

    /* Mobile (320px - 575px) */
    @media (max-width: 575px) {
        .password-container {
            padding: 0.5rem 0.25rem;
            min-height: auto;
        }

        .password-card {
            padding: 1rem;
            border-radius: 10px;
        }

        .password-icon {
            width: 45px;
            height: 45px;
            font-size: 1.2rem;
        }

        .password-header {
            margin-bottom: 1.5rem;
        }

        .form-group {
            margin-bottom: 1.2rem;
        }

        .form-input {
            padding: 0.6rem 0.8rem;
        }

        .btn-submit, .btn-cancel {
            padding: 0.7rem 1rem;
        }
    }

    /* Extra Small Mobile (320px and below) */
    @media (max-width: 320px) {
        .password-container {
            padding: 0.25rem;
        }

        .password-card {
            padding: 0.8rem;
        }

        .password-icon {
            width: 40px;
            height: 40px;
            font-size: 1rem;
        }
    }

    /* Landscape Mobile Optimization */
    @media (max-height: 500px) and (orientation: landscape) {
        .password-container {
            min-height: auto;
            padding: 1rem;
        }

        .password-header {
            margin-bottom: 1rem;
        }

        .password-icon {
            width: 40px;
            height: 40px;
            font-size: 1rem;
        }
    }
</style>

<div class="password-container">
    <div class="password-card">
        <div class="password-header">
            <div class="password-icon">
                🔒
            </div>
            <h2>Change Password</h2>
            <p class="password-subtitle">Update your account security</p>
        </div>

        <!-- Alert Messages -->
        <c:if test="${not empty error}">
            <div class="alert alert-error">
                <span class="alert-icon">⚠</span>${error}
            </div>
        </c:if>
        <c:if test="${not empty message}">
            <div class="alert alert-success">
                <span class="alert-icon">✓</span>${message}
            </div>
        </c:if>

        <!-- Change Password Form -->
        <form method="post" action="${pageContext.request.contextPath}/ChangePassword" class="password-form" id="changePasswordForm">
            <div class="form-group">
                <label class="form-label" for="oldPassword">Current Password</label>
                <div style="position: relative;">
                    <input type="password" 
                           class="form-input" 
                           name="oldPassword" 
                           id="oldPassword"
                           required 
                           placeholder="Enter your current password">
                    <button type="button" class="password-toggle" onclick="togglePassword('oldPassword')">
                        👁
                    </button>
                </div>
            </div>

            <div class="form-group">
                <label class="form-label" for="newPassword">New Password</label>
                <div style="position: relative;">
                    <input type="password" 
                           class="form-input" 
                           name="newPassword" 
                           id="newPassword"
                           required 
                           placeholder="Enter your new password"
                           onkeyup="checkPasswordStrength()">
                    <button type="button" class="password-toggle" onclick="togglePassword('newPassword')">
                        👁
                    </button>
                </div>
                <div class="password-strength" id="passwordStrength" style="display: none;">
                    <div class="strength-bar">
                        <div class="strength-fill" id="strengthFill"></div>
                    </div>
                    <span id="strengthText"></span>
                </div>
            </div>

            <div class="form-group">
                <label class="form-label" for="confirmPassword">Confirm New Password</label>
                <div style="position: relative;">
                    <input type="password" 
                           class="form-input" 
                           name="confirmPassword" 
                           id="confirmPassword"
                           required 
                           placeholder="Confirm your new password"
                           onkeyup="checkPasswordMatch()">
                    <button type="button" class="password-toggle" onclick="togglePassword('confirmPassword')">
                        👁
                    </button>
                </div>
                <div id="passwordMatch" style="margin-top: 0.5rem; font-size: 0.8rem;"></div>
            </div>

            <button type="submit" class="btn-submit" id="submitBtn">
                Change Password
            </button>

            <a href="${pageContext.request.contextPath}/Profile" class="btn-cancel">
                Back Profile
            </a>
        </form>
    </div>
</div>

<script>
    function togglePassword(inputId) {
        const input = document.getElementById(inputId);
        const button = input.nextElementSibling;

        if (input.type === 'password') {
            input.type = 'text';
            button.innerHTML = '🙈';
        } else {
            input.type = 'password';
            button.innerHTML = '👁';
        }
    }

    function checkPasswordStrength() {
        const password = document.getElementById('newPassword').value;
        const strengthDiv = document.getElementById('passwordStrength');
        const strengthFill = document.getElementById('strengthFill');
        const strengthText = document.getElementById('strengthText');

        if (password.length === 0) {
            strengthDiv.style.display = 'none';
            return;
        }

        strengthDiv.style.display = 'block';

        let strength = 0;
        let feedback = [];

        // Length check
        if (password.length >= 8)
            strength++;
        else
            feedback.push('at least 8 characters');

        // Uppercase check
        if (/[A-Z]/.test(password))
            strength++;
        else
            feedback.push('uppercase letter');

        // Lowercase check
        if (/[a-z]/.test(password))
            strength++;
        else
            feedback.push('lowercase letter');

        // Number check
        if (/[0-9]/.test(password))
            strength++;
        else
            feedback.push('number');

        // Special character check
        if (/[^A-Za-z0-9]/.test(password))
            strength++;
        else
            feedback.push('special character');

        // Update UI based on strength
        strengthDiv.className = 'password-strength';
        if (strength <= 2) {
            strengthDiv.classList.add('strength-weak');
            strengthText.innerHTML = '⚠ Weak - Need: ' + feedback.slice(0, 2).join(', ');
            strengthText.style.color = '#dc3545';
        } else if (strength <= 3) {
            strengthDiv.classList.add('strength-medium');
            strengthText.innerHTML = '⚡ Medium - Need: ' + feedback.slice(0, 1).join(', ');
            strengthText.style.color = '#ffc107';
        } else {
            strengthDiv.classList.add('strength-strong');
            strengthText.innerHTML = '✓ Strong password';
            strengthText.style.color = '#28a745';
        }
    }

    function checkPasswordMatch() {
        const newPassword = document.getElementById('newPassword').value;
        const confirmPassword = document.getElementById('confirmPassword').value;
        const matchDiv = document.getElementById('passwordMatch');

        if (confirmPassword.length === 0) {
            matchDiv.innerHTML = '';
            return;
        }

        if (newPassword === confirmPassword) {
            matchDiv.innerHTML = '<span style="color: #28a745;">✓ Passwords match</span>';
        } else {
            matchDiv.innerHTML = '<span style="color: #dc3545;">⚠ Passwords do not match</span>';
        }
    }

    // Form submission validation
    document.getElementById('changePasswordForm').addEventListener('submit', function (e) {
        const newPassword = document.getElementById('newPassword').value;
        const confirmPassword = document.getElementById('confirmPassword').value;

        if (newPassword !== confirmPassword) {
            e.preventDefault();
            alert('Passwords do not match. Please check and try again.');
            return false;
        }

        if (newPassword.length < 8) {
            e.preventDefault();
            alert('New password must be at least 8 characters long.');
            return false;
        }
    });
</script>

<%-- Nhúng footer --%>
<jsp:include page="/WEB-INF/views/common/footer.jsp" />