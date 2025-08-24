<%-- 
    Document   : staff-form
    Created on : Jun 14, 2025, 5:58:14 AM
    Author     : Lenovo
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>${requestScope.pageTitle != null ? requestScope.pageTitle : "Create Staff Account"}</title>

        <%-- Link đến thư viện ngoài --%>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">

        <%-- Link đến file CSS dùng chung --%>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/admin-dashboard/css/admin-css.css">

        <%-- CSS nội tuyến cho trang staff form --%>
        <style>
            body {
                font-family: Arial, sans-serif;
                background-color: #f4f4f9;
            }

            .content-area {
                padding: 20px;
            }

            .form-container {
                max-width: 800px;
                margin: 0 auto;
                background: #fff;
                padding: 30px;
                border-radius: 8px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            }

            .form-header {
                text-align: center;
                margin-bottom: 30px;
                padding-bottom: 20px;
                border-bottom: 2px solid #007bff;
            }

            .form-header h2 {
                color: #333;
                margin: 0;
                font-size: 28px;
                font-weight: 600;
            }

            .form-header p {
                color: #666;
                margin: 10px 0 0 0;
                font-size: 14px;
            }

            .form-row {
                display: flex;
                gap: 20px;
                margin-bottom: 20px;
            }

            .form-group {
                flex: 1;
                margin-bottom: 20px;
            }

            .form-group.full-width {
                flex: 100%;
            }

            .form-group label {
                display: block;
                margin-bottom: 8px;
                color: #333;
                font-weight: 500;
                font-size: 14px;
            }

            .form-group label .required {
                color: #dc3545;
                margin-left: 3px;
            }

            .form-group input,
            .form-group textarea,
            .form-group select {
                width: 100%;
                padding: 12px 15px;
                border: 1px solid #ddd;
                border-radius: 6px;
                font-size: 14px;
                transition: all 0.3s ease;
                box-sizing: border-box;
            }

            .form-group input:focus,
            .form-group textarea:focus,
            .form-group select:focus {
                outline: none;
                border-color: #007bff;
                box-shadow: 0 0 0 3px rgba(0,123,255,0.1);
            }

            .form-group textarea {
                resize: vertical;
                min-height: 80px;
            }

            .password-strength {
                margin-top: 5px;
                font-size: 12px;
                color: #666;
            }

            .strength-indicator {
                display: flex;
                gap: 3px;
                margin-top: 5px;
            }

            .strength-bar {
                height: 4px;
                flex: 1;
                background-color: #e9ecef;
                border-radius: 2px;
                transition: background-color 0.3s ease;
            }

            .strength-bar.active {
                background-color: #28a745;
            }

            .strength-bar.medium {
                background-color: #ffc107;
            }

            .strength-bar.weak {
                background-color: #dc3545;
            }

            .form-actions {
                display: flex;
                gap: 15px;
                justify-content: center;
                margin-top: 30px;
                padding-top: 20px;
                border-top: 1px solid #e9ecef;
            }

            .btn {
                padding: 12px 30px;
                border: none;
                border-radius: 6px;
                font-size: 14px;
                font-weight: 500;
                cursor: pointer;
                text-decoration: none;
                display: inline-flex;
                align-items: center;
                gap: 8px;
                transition: all 0.3s ease;
                min-width: 120px;
                justify-content: center;
            }

            .btn-primary {
                background-color: #007bff;
                color: white;
            }

            .btn-primary:hover {
                background-color: #0056b3;
                transform: translateY(-2px);
                box-shadow: 0 4px 12px rgba(0,123,255,0.3);
            }

            .btn-secondary {
                background-color: #6c757d;
                color: white;
            }

            .btn-secondary:hover {
                background-color: #545b62;
                transform: translateY(-2px);
                box-shadow: 0 4px 12px rgba(108,117,125,0.3);
            }

            .btn-back {
                background-color: #28a745;
                color: white;
            }

            .btn-back:hover {
                background-color: #218838;
                transform: translateY(-2px);
                box-shadow: 0 4px 12px rgba(40,167,69,0.3);
            }

            .error-message {
                background-color: #f8d7da;
                color: #721c24;
                border: 1px solid #f5c6cb;
                padding: 12px 15px;
                border-radius: 6px;
                margin-bottom: 20px;
                display: flex;
                align-items: center;
                gap: 10px;
            }

            .success-message {
                background-color: #d4edda;
                color: #155724;
                border: 1px solid #c3e6cb;
                padding: 12px 15px;
                border-radius: 6px;
                margin-bottom: 20px;
                display: flex;
                align-items: center;
                gap: 10px;
            }

            .input-group {
                position: relative;
            }

            .input-group .form-icon {
                position: absolute;
                right: 15px;
                top: 50%;
                transform: translateY(-50%);
                color: #6c757d;
                cursor: pointer;
            }

            .input-group input {
                padding-right: 45px;
            }

            .form-section {
                margin-bottom: 30px;
            }

            .form-section-title {
                font-size: 18px;
                font-weight: 600;
                color: #333;
                margin-bottom: 15px;
                padding-bottom: 8px;
                border-bottom: 1px solid #e9ecef;
            }

            @media (max-width: 768px) {
                .form-row {
                    flex-direction: column;
                    gap: 0;
                }

                .form-container {
                    padding: 20px;
                    margin: 10px;
                }

                .form-actions {
                    flex-direction: column;
                    align-items: center;
                }

                .btn {
                    width: 100%;
                    max-width: 200px;
                }
            }
            .content-area {
        position: relative;
        margin-left: 260px;
        padding: 1.5rem;
        width: calc(100% - 260px);
        transition: all 0.5s ease;
        min-height: 100vh;
    }
    .sidebar.close ~ .content-area {
        margin-left: 88px;
        width: calc(100% - 88px);
    }
    .sidebar.hidden ~ .content-area {
        margin-left: 0;
        width: 100%;
    }
        </style>
    </head>
    <body>

        <%-- Đặt các biến requestScope cho sidebar/header --%>
        <c:set var="currentAction" value="staff" scope="request"/>
        <c:set var="currentModule" value="admin" scope="request"/>
        <c:set var="pageTitle" value="Create Staff Account" scope="request"/>

        <%-- Nhúng Sidebar --%>
        <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp" />

        <div class="main-content-wrapper">
            <%-- Nhúng Header --%>
            

            <%-- Nội dung chính của trang Create Staff --%>
            <div class="content-area">
                <div class="form-container">
                    <div class="form-header">
                        <h2><i class="fa fa-user-plus"></i> Create Staff Account</h2>
                        <p>Fill in the information below to create a new staff member account</p>
                    </div>

                    <%-- Hiển thị thông báo lỗi --%>
                    <c:if test="${not empty errorMessage}">
                        <div class="error-message">
                            <i class="fa fa-exclamation-triangle"></i>
                            ${errorMessage}
                        </div>
                    </c:if>

                    <%-- Hiển thị thông báo thành công --%>
                    <c:if test="${not empty successMessage}">
                        <div class="success-message">
                            <i class="fa fa-check-circle"></i>
                            ${successMessage}
                        </div>
                    </c:if>

                    <form action="${pageContext.request.contextPath}/CreateAccount" method="post" id="staffForm">
                        <%-- Account Information Section --%>
                        <div class="form-section">
                            <h3 class="form-section-title">Account Information</h3>

                            <div class="form-row">
                                <div class="form-group">
                                    <label for="email">Email Address <span class="required">*</span></label>
                                    <input type="email" id="email" name="email" required 
                                           value="${email}" placeholder="Enter email address">
                                </div>
                            </div>
                        </div>

                        <%-- Personal Information Section --%>
                        <div class="form-section">
                            <h3 class="form-section-title">Personal Information</h3>

                            <div class="form-row">
                                <div class="form-group">
                                    <label for="fullName">Full Name <span class="required">*</span></label>
                                    <input type="text" id="fullName" name="fullName" required 
                                           value="${fullName}" placeholder="Enter full name">
                                </div>

                                <div class="form-group">
                                    <label for="phoneNumber">Phone Number <span class="required">*</span></label>
                                    <input type="tel" id="phoneNumber" name="phoneNumber" required 
                                           value="${phoneNumber}" placeholder="Enter phone number">
                                </div>
                            </div>
                        </div>

                        <%-- Work Information Section --%>
                        <div class="form-section">
                            <h3 class="form-section-title">Work Information</h3>

                            <div class="form-row">
                                <div class="form-group">
                                    <label for="position">Position <span class="required">*</span></label>
                                    <input type="text" id="position" name="position" required 
                                           value="${position}" placeholder="Enter position">
                                </div>
                            </div>

                            <div class="form-row">
                                <div class="form-group full-width">
                                    <label for="notes">Notes</label>
                                    <textarea id="notes" name="notes" rows="4" 
                                              placeholder="Enter any additional notes or comments...">${notes}</textarea>
                                </div>
                            </div>
                        </div>

                        <%-- Form Actions --%>
                        <div class="form-actions">
                            <a href="${pageContext.request.contextPath}/StaffManagement" class="btn btn-back">
                                <i class="fa fa-arrow-left"></i> Back to List
                            </a>
                            <button type="reset" class="btn btn-secondary">
                                <i class="fa fa-refresh"></i> Reset Form
                            </button>
                            <button type="submit" class="btn btn-primary">
                                <i class="fa fa-save"></i> Create Account
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
        <%-- Link đến file JS dùng chung --%>
        <script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>

        <script>
            // Toggle password visibility
            document.getElementById('togglePassword').addEventListener('click', function () {
                const passwordInput = document.getElementById('password');
                const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
                passwordInput.setAttribute('type', type);
                this.classList.toggle('fa-eye');
                this.classList.toggle('fa-eye-slash');
            });

            document.getElementById('toggleConfirmPassword').addEventListener('click', function () {
                const confirmPasswordInput = document.getElementById('confirmPassword');
                const type = confirmPasswordInput.getAttribute('type') === 'password' ? 'text' : 'password';
                confirmPasswordInput.setAttribute('type', type);
                this.classList.toggle('fa-eye');
                this.classList.toggle('fa-eye-slash');
            });

            // Password strength checker
            document.getElementById('password').addEventListener('input', function () {
                const password = this.value;
                const strengthText = document.getElementById('passwordStrength');
                const strengthBars = document.querySelectorAll('.strength-bar');

                let strength = 0;
                let strengthLabel = '';

                if (password.length >= 8)
                    strength++;
                if (password.match(/[a-z]/))
                    strength++;
                if (password.match(/[A-Z]/))
                    strength++;
                if (password.match(/[0-9]/))
                    strength++;
                if (password.match(/[^a-zA-Z0-9]/))
                    strength++;

                // Reset all bars
                strengthBars.forEach(bar => {
                    bar.classList.remove('active', 'weak', 'medium');
                });

                if (strength < 2) {
                    strengthLabel = 'Weak';
                    for (let i = 0; i < Math.min(strength, 2); i++) {
                        strengthBars[i].classList.add('weak');
                    }
                } else if (strength < 4) {
                    strengthLabel = 'Medium';
                    for (let i = 0; i < Math.min(strength, 4); i++) {
                        strengthBars[i].classList.add('medium');
                    }
                } else {
                    strengthLabel = 'Strong';
                    for (let i = 0; i < 4; i++) {
                        strengthBars[i].classList.add('active');
                    }
                }

                strengthText.textContent = password.length > 0 ? `Password strength: ${strengthLabel}` : '';
            });

            // Form validation
            document.getElementById('staffForm').addEventListener('submit', function (e) {
                const password = document.getElementById('password').value;
                const confirmPassword = document.getElementById('confirmPassword').value;

                if (password !== confirmPassword) {
                    alert('Passwords do not match!');
                    e.preventDefault();
                    return false;
                }

                if (password.length < 6) {
                    alert('Password must be at least 6 characters long!');
                    e.preventDefault();
                    return false;
                }
            });
        </script>
    </body>
</html>