<%-- 
    Document   : register
    Created on : Jun 23, 2025
    Author     : Khoa
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- Đặt tiêu đề cho trang này, header.jsp sẽ dùng biến này --%>
<c:set var="pageTitle" value="Customer Registration" scope="request"/>

<style>
    /* CSS cho trang register - Optimized Responsive Design */
    .register-container {
        min-height: 70vh;
        background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
        padding: 1rem 0.5rem;
    }

    .register-card {
        background: white;
        border-radius: 12px;
        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.08);
        padding: 1.5rem;
        position: relative;
        overflow: hidden;
        margin: 0 auto;
        max-width: 600px;
        width: 100%;
    }

    .register-card::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        height: 3px;
        background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
    }

    .register-header {
        text-align: center;
        margin-bottom: 1.5rem;
        position: relative;
    }

    .register-avatar {
        width: 60px;
        height: 60px;
        border-radius: 50%;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        display: flex;
        align-items: center;
        justify-content: center;
        margin: 0 auto 0.8rem;
        font-size: 1.5rem;
        color: white;
        font-weight: 700;
        box-shadow: 0 6px 15px rgba(102, 126, 234, 0.25);
    }

    .register-header h2 {
        font-size: 1.4rem;
        font-weight: 700;
        color: #333;
        text-transform: uppercase;
        letter-spacing: 1px;
        margin-bottom: 0.3rem;
    }

    .register-subtitle {
        color: #666;
        font-size: 0.9rem;
        margin: 0;
    }

    .alert {
        padding: 0.75rem 1rem;
        margin-bottom: 1rem;
        border-radius: 6px;
        font-size: 0.9rem;
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

    .register-form {
        display: grid;
        gap: 1rem;
    }

    .form-group {
        display: flex;
        flex-direction: column;
        position: relative;
    }

    .form-row {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 1rem;
    }

    .form-label {
        font-weight: 600;
        color: #333;
        text-transform: uppercase;
        font-size: 0.75rem;
        letter-spacing: 0.5px;
        margin-bottom: 0.5rem;
        display: block;
    }

    .form-input,
    .form-select {
        padding: 0.8rem;
        border: 2px solid #e9ecef;
        border-radius: 6px;
        font-size: 0.95rem;
        transition: all 0.3s ease;
        background: white;
        outline: none;
        box-sizing: border-box;
    }

    /* Password input với toggle button */
    .password-input-container {
        position: relative;
    }

    .password-input-container .form-input {
        padding-right: 3rem;
    }

    .password-toggle {
        position: absolute;
        right: 12px;
        top: 50%;
        transform: translateY(-50%);
        background: none;
        border: none;
        color: #666;
        cursor: pointer;
        font-size: 1.1rem;
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

    .form-input:focus,
    .form-select:focus {
        border-color: #667eea;
        box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
    }

    .form-input:hover,
    .form-select:hover {
        border-color: #ced4da;
    }

    .form-select {
        cursor: pointer;
    }

    /* Password Strength Indicator */
    .password-strength {
        margin-top: 0.5rem;
        font-size: 0.75rem;
        display: none;
    }

    .strength-bar {
        height: 3px;
        background: #e9ecef;
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

    /* Password Match Indicator */
    .password-match {
        margin-top: 0.5rem;
        font-size: 0.8rem;
    }

    .btn-register {
        padding: 0.9rem 2rem;
        border-radius: 6px;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        border: none;
        cursor: pointer;
        font-size: 0.9rem;
        transition: all 0.3s ease;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        margin-top: 1rem;
    }

    .btn-register:hover {
        transform: translateY(-1px);
        box-shadow: 0 6px 20px rgba(102, 126, 234, 0.25);
    }

    .btn-register:disabled {
        background: #ccc;
        cursor: not-allowed;
        transform: none;
        box-shadow: none;
    }

    .login-link {
        text-align: center;
        margin-top: 1.5rem;
        padding-top: 1rem;
        border-top: 1px solid #e9ecef;
    }

    .login-link a {
        color: #667eea;
        text-decoration: none;
        font-weight: 600;
        transition: color 0.3s ease;
    }

    .login-link a:hover {
        color: #764ba2;
        text-decoration: underline;
    }

    /* Responsive Breakpoints */

    /* Large Desktop (1200px+) */
    @media (min-width: 1200px) {
        .register-container {
            padding: 2rem 1rem;
        }

        .register-card {
            padding: 2rem;
        }
    }

    /* Desktop (992px - 1199px) */
    @media (min-width: 992px) and (max-width: 1199px) {
        .register-card {
            padding: 1.8rem;
        }
    }

    /* Tablet (768px - 991px) */
    @media (min-width: 768px) and (max-width: 991px) {
        .register-container {
            padding: 1rem 0.5rem;
        }

        .register-card {
            padding: 1.5rem;
            max-width: 500px;
        }

        .form-row {
            gap: 0.8rem;
        }
    }

    /* Small Tablet (576px - 767px) */
    @media (min-width: 576px) and (max-width: 767px) {
        .register-container {
            padding: 0.8rem 0.3rem;
        }

        .register-card {
            padding: 1.2rem;
        }

        .form-row {
            grid-template-columns: 1fr;
            gap: 0.8rem;
        }

        .register-avatar {
            width: 50px;
            height: 50px;
            font-size: 1.3rem;
        }

        .password-input-container .form-input {
            padding-right: 2.5rem;
        }

        .password-toggle {
            right: 10px;
            font-size: 1rem;
        }
    }

    /* Mobile (320px - 575px) */
    @media (max-width: 575px) {
        .register-container {
            padding: 0.5rem 0.2rem;
            min-height: auto;
        }

        .register-card {
            padding: 1rem;
            margin: 0;
            border-radius: 8px;
        }

        .form-row {
            grid-template-columns: 1fr;
            gap: 0.8rem;
        }

        .register-avatar {
            width: 45px;
            height: 45px;
            font-size: 1.2rem;
        }

        .register-header h2 {
            font-size: 1.2rem;
        }

        .form-input,
        .form-select {
            padding: 0.7rem;
        }

        .password-input-container .form-input {
            padding-right: 2.3rem;
        }

        .password-toggle {
            right: 8px;
            font-size: 0.9rem;
        }

        .btn-register {
            padding: 0.8rem 1.5rem;
            font-size: 0.85rem;
        }
    }

    /* Extra Small Mobile (320px and below) */
    @media (max-width: 320px) {
        .register-container {
            padding: 0.3rem 0.1rem;
        }

        .register-card {
            padding: 0.8rem;
        }

        .register-avatar {
            width: 40px;
            height: 40px;
            font-size: 1rem;
        }

        .form-input,
        .form-select {
            padding: 0.6rem;
            font-size: 0.9rem;
        }

        .password-input-container .form-input {
            padding-right: 2rem;
        }

        .password-toggle {
            right: 6px;
            font-size: 0.8rem;
        }

        .btn-register {
            padding: 0.7rem 1.2rem;
            font-size: 0.8rem;
        }
    }

    /* Landscape Mobile Optimization */
    @media (max-height: 500px) and (orientation: landscape) {
        .register-container {
            min-height: auto;
            padding: 0.5rem;
        }

        .register-header {
            margin-bottom: 1rem;
        }

        .register-form {
            gap: 0.8rem;
        }
    }

    /* Print Styles */
    @media print {
        .register-container {
            background: none;
            padding: 0;
        }

        .register-card {
            box-shadow: none;
            border: 1px solid #ccc;
        }

        .btn-register {
            display: none;
        }
    }
</style>

<div class="register-container">
    <div class="register-card">
        <div class="register-header">
            <div class="register-avatar">
                👤
            </div>
            <h2>Customer Registration</h2>
            <p class="register-subtitle">Create your account to get started</p>
        </div>

        <!-- Error/Success Messages -->
        <c:if test="${not empty error}">
            <div class="alert alert-error">
                <span class="alert-icon">⚠</span>${error}
            </div>
        </c:if>
        <c:if test="${not empty success}">
            <div class="alert alert-success">
                <span class="alert-icon">✓</span>${success}
            </div>
        </c:if>

        <!-- Registration Form -->
        <form action="${pageContext.request.contextPath}/Register" method="post" class="register-form" id="registerForm">
            <div class="form-group">
                <label class="form-label">Full Name</label>
                <input type="text" 
                       name="fullName" 
                       class="form-input" 
                       value="${param.fullName != null ? param.fullName : ''}"
                       required>
            </div>

            <div class="form-group">
                <label class="form-label">Email Address</label>
                <input type="email" 
                       name="email" 
                       class="form-input" 
                       value="${param.email != null ? param.email : ''}"
                       required>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">Password</label>
                    <div class="password-input-container">
                        <input type="password" 
                               name="password" 
                               id="password"
                               class="form-input" 
                               onkeyup="checkPasswordStrength()"
                               required>
                        <button type="button" 
                                class="password-toggle" 
                                onclick="togglePassword('password')"
                                title="Show/Hide Password">
                            👁
                        </button>
                    </div>
                    <div class="password-strength" id="passwordStrength">
                        <div class="strength-bar">
                            <div class="strength-fill" id="strengthFill"></div>
                        </div>
                        <span id="strengthText"></span>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label">Confirm Password</label>
                    <div class="password-input-container">
                        <input type="password" 
                               name="confirmPassword" 
                               id="confirmPassword"
                               class="form-input" 
                               onkeyup="checkPasswordMatch()"
                               required>
                        <button type="button" 
                                class="password-toggle" 
                                onclick="togglePassword('confirmPassword')"
                                title="Show/Hide Password">
                            👁
                        </button>
                    </div>
                    <div class="password-match" id="passwordMatch"></div>
                </div>
            </div>

            <div class="form-group">
                <label class="form-label">Phone Number</label>
                <input type="text" 
                       name="phoneNumber" 
                       class="form-input" 
                       value="${param.phoneNumber != null ? param.phoneNumber : ''}"
                       required>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">Gender</label>
                    <select name="gender" class="form-select" required>
                        <option value="">Select Gender</option>
                        <option value="Male" ${param.gender == 'Male' ? 'selected' : ''}>Male</option>
                        <option value="Female" ${param.gender == 'Female' ? 'selected' : ''}>Female</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Birth Date</label>
                    <input type="date" 
                           name="birthDate" 
                           class="form-input"
                           value="${param.birthDate != null ? param.birthDate : ''}">
                </div>
            </div>

            <button type="submit" class="btn-register" id="submitBtn">Create Account</button>
        </form>

        <!-- Login Link -->
        <div class="login-link">
            <p>Already have an account? <a href="${pageContext.request.contextPath}/Login">Login in here</a></p>
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

    function checkPasswordStrength() {
        const password = document.getElementById('password').value;
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

        // Re-check password match when password changes
        checkPasswordMatch();
    }

    function checkPasswordMatch() {
        const password = document.getElementById('password').value;
        const confirmPassword = document.getElementById('confirmPassword').value;
        const matchDiv = document.getElementById('passwordMatch');
        const submitBtn = document.getElementById('submitBtn');

        if (confirmPassword.length === 0) {
            matchDiv.innerHTML = '';
            submitBtn.disabled = false;
            return;
        }

        if (password === confirmPassword) {
            matchDiv.innerHTML = '<span style="color: #28a745;">✓ Passwords match</span>';
            submitBtn.disabled = false;
        } else {
            matchDiv.innerHTML = '<span style="color: #dc3545;">⚠ Passwords do not match</span>';
            submitBtn.disabled = true;
        }
    }

    // Form submission validation
    document.getElementById('registerForm').addEventListener('submit', function (e) {
        const password = document.getElementById('password').value;
        const confirmPassword = document.getElementById('confirmPassword').value;

        if (password !== confirmPassword) {
            e.preventDefault();
            alert('Passwords do not match. Please check and try again.');
            return false;
        }

        if (password.length < 8) {
            e.preventDefault();
            alert('Password must be at least 8 characters long.');
            return false;
        }
    });

    // Prevent form submission when clicking password toggle
    document.querySelectorAll('.password-toggle').forEach(button => {
        button.addEventListener('click', function (e) {
            e.preventDefault();
            e.stopPropagation();
        });
    });

    // Add keyboard support for accessibility
    document.addEventListener('keydown', function (e) {
        if (e.key === 'Enter' && e.target.classList.contains('password-toggle')) {
            e.preventDefault();
            const inputId = e.target.previousElementSibling.id;
            togglePassword(inputId);
        }
    });
</script>