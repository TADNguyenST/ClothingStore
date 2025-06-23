<%-- 
    Document   : edit-profile
    Created on : Jun 23, 2025, 2:12:53 AM
    Author     : Khoa
--%>

<%-- 
    Document   : edit-profile
    Created on : Jun 23, 2025, 2:12:53 AM
    Author     : Khoa
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- Đặt tiêu đề cho trang này, header.jsp sẽ dùng biến này --%>
<c:set var="pageTitle" value="Edit Profile" scope="request"/>

<%-- Nhúng header --%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<style>
    /* CSS cho trang edit profile - Compact Responsive Design */
    .edit-profile-container {
        min-height: 70vh;
        background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
        padding: 1.5rem 1rem;
    }

    .edit-profile-card {
        background: white;
        border-radius: 12px;
        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
        padding: 1.5rem;
        position: relative;
        overflow: hidden;
        margin: 0 auto;
        max-width: 600px;
        width: 100%;
    }

    .edit-profile-card::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        height: 3px;
        background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
    }

    .edit-profile-header {
        text-align: center;
        margin-bottom: 1.5rem;
        position: relative;
    }

    .edit-profile-avatar {
        width: 50px;
        height: 50px;
        border-radius: 50%;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        display: flex;
        align-items: center;
        justify-content: center;
        margin: 0 auto 0.8rem;
        font-size: 1.4rem;
        color: white;
        font-weight: 700;
        text-transform: uppercase;
        box-shadow: 0 6px 15px rgba(102, 126, 234, 0.3);
    }

    .edit-profile-header h2 {
        font-size: clamp(1.1rem, 3.5vw, 1.4rem);
        font-weight: 700;
        color: #333;
        text-transform: uppercase;
        letter-spacing: 0.8px;
        margin-bottom: 0.3rem;
    }

    .edit-profile-subtitle {
        color: #666;
        font-size: clamp(0.8rem, 2vw, 0.9rem);
        margin: 0;
    }

    .edit-form {
        background: #f8f9fa;
        border-radius: 8px;
        padding: 1.2rem;
        margin-bottom: 1rem;
    }

    .form-group {
        margin-bottom: 1.2rem;
    }

    .form-label {
        display: block;
        font-weight: 600;
        color: #333;
        text-transform: uppercase;
        font-size: clamp(0.7rem, 1.8vw, 0.8rem);
        letter-spacing: 0.4px;
        margin-bottom: 0.4rem;
    }

    .form-input, .form-select {
        width: 100%;
        padding: 0.7rem 0.8rem;
        border: 2px solid #e9ecef;
        border-radius: 6px;
        font-size: clamp(0.9rem, 2.2vw, 1rem);
        color: #555;
        background: white;
        transition: all 0.3s ease;
        box-sizing: border-box;
    }

    .form-input:focus, .form-select:focus {
        outline: none;
        border-color: #667eea;
        box-shadow: 0 0 0 2px rgba(102, 126, 234, 0.1);
    }

    .form-input:hover, .form-select:hover {
        border-color: #667eea;
    }

    .form-select {
        cursor: pointer;
        background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 20 20'%3e%3cpath stroke='%236b7280' stroke-linecap='round' stroke-linejoin='round' stroke-width='1.5' d='m6 8 4 4 4-4'/%3e%3c/svg%3e");
        background-position: right 0.5rem center;
        background-repeat: no-repeat;
        background-size: 1.2em 1.2em;
        padding-right: 2.2rem;
        appearance: none;
    }

    .form-actions {
        display: flex;
        gap: 0.8rem;
        justify-content: center;
        flex-wrap: wrap;
        margin-top: 1.5rem;
    }

    .btn-form {
        padding: 0.7rem 1.2rem;
        border-radius: 6px;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.8px;
        text-decoration: none;
        transition: all 0.3s ease;
        border: none;
        cursor: pointer;
        font-size: clamp(0.75rem, 1.8vw, 0.85rem);
        text-align: center;
        min-width: 100px;
        flex: 1;
        max-width: 140px;
    }

    .btn-save {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
    }

    .btn-save:hover {
        transform: translateY(-1px);
        box-shadow: 0 6px 20px rgba(102, 126, 234, 0.3);
    }

    .btn-cancel {
        background: transparent;
        color: #667eea;
        border: 2px solid #667eea;
    }

    .btn-cancel:hover {
        background: #667eea;
        color: white;
        transform: translateY(-1px);
        text-decoration: none;
    }

    /* Alert Messages */
    .alert {
        padding: 0.8rem;
        border-radius: 6px;
        margin-bottom: 1.2rem;
        font-weight: 500;
        text-align: center;
        font-size: clamp(0.8rem, 2vw, 0.9rem);
    }

    .alert-success {
        background-color: #d4edda;
        color: #155724;
        border: 1px solid #c3e6cb;
    }

    .alert-error {
        background-color: #f8d7da;
        color: #721c24;
        border: 1px solid #f5c6cb;
    }

    /* Responsive Breakpoints */

    /* Large Desktop (1200px+) */
    @media (min-width: 1200px) {
        .edit-profile-container {
            padding: 2rem 1.5rem;
        }

        .edit-profile-card {
            padding: 2rem;
            max-width: 650px;
        }

        .edit-form {
            padding: 1.5rem;
        }
    }

    /* Desktop (992px - 1199px) */
    @media (min-width: 992px) and (max-width: 1199px) {
        .edit-profile-container {
            padding: 1.8rem 1.2rem;
        }

        .edit-profile-card {
            padding: 1.8rem;
        }
    }

    /* Tablet (768px - 991px) */
    @media (min-width: 768px) and (max-width: 991px) {
        .edit-profile-container {
            padding: 1.5rem 1rem;
        }

        .edit-profile-card {
            padding: 1.5rem;
            max-width: 550px;
        }

        .edit-form {
            padding: 1.2rem;
        }

        .form-actions {
            gap: 0.7rem;
        }

        .btn-form {
            flex: 1 1 calc(50% - 0.35rem);
            max-width: 120px;
        }
    }

    /* Small Tablet (576px - 767px) */
    @media (min-width: 576px) and (max-width: 767px) {
        .edit-profile-container {
            padding: 1.2rem 0.8rem;
        }

        .edit-profile-card {
            padding: 1.2rem;
            max-width: 500px;
        }

        .edit-form {
            padding: 1rem;
        }

        .form-actions {
            flex-direction: column;
            gap: 0.7rem;
        }

        .btn-form {
            width: 100%;
            max-width: none;
            flex: none;
        }

        .edit-profile-avatar {
            width: 45px;
            height: 45px;
            font-size: 1.3rem;
        }
    }

    /* Mobile (320px - 575px) */
    @media (max-width: 575px) {
        .edit-profile-container {
            padding: 1rem 0.5rem;
            min-height: auto;
        }

        .edit-profile-card {
            padding: 1rem;
            margin: 0;
            border-radius: 8px;
        }

        .edit-form {
            padding: 0.8rem;
            margin-bottom: 0.8rem;
        }

        .form-actions {
            flex-direction: column;
            gap: 0.6rem;
        }

        .btn-form {
            width: 100%;
            max-width: none;
            flex: none;
            padding: 0.6rem 1rem;
        }

        .edit-profile-avatar {
            width: 40px;
            height: 40px;
            font-size: 1.2rem;
            margin-bottom: 0.6rem;
        }

        .edit-profile-header {
            margin-bottom: 1.2rem;
        }

        .form-group {
            margin-bottom: 1rem;
        }
    }

    /* Extra Small Mobile (320px and below) */
    @media (max-width: 320px) {
        .edit-profile-container {
            padding: 0.8rem 0.3rem;
        }

        .edit-profile-card {
            padding: 0.8rem;
        }

        .edit-form {
            padding: 0.6rem;
        }

        .edit-profile-avatar {
            width: 35px;
            height: 35px;
            font-size: 1rem;
        }

        .btn-form {
            padding: 0.5rem 0.8rem;
            font-size: 0.75rem;
        }
    }

    /* Landscape Mobile Optimization */
    @media (max-height: 500px) and (orientation: landscape) {
        .edit-profile-container {
            min-height: auto;
            padding: 0.8rem;
        }

        .edit-profile-header {
            margin-bottom: 1rem;
        }

        .edit-form {
            margin-bottom: 0.8rem;
        }

        .form-actions {
            margin-top: 1rem;
        }
    }

    /* Print Styles */
    @media print {
        .edit-profile-container {
            background: none;
            padding: 0;
        }

        .edit-profile-card {
            box-shadow: none;
            border: 1px solid #ccc;
        }

        .form-actions {
            display: none;
        }
    }
</style>

<div class="edit-profile-container">
    <div class="edit-profile-card">
        <div class="edit-profile-header">
            <div class="edit-profile-avatar">
                ${user.fullName.substring(0,1)}
            </div>
            <h2>Edit Profile</h2>
            <p class="edit-profile-subtitle">Update your account information</p>
        </div>

        <!-- ✅ Hiển thị thông báo -->
        <c:if test="${not empty success}">
            <div class="alert alert-success">
                ${success}
            </div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="alert alert-error">
                ${error}
            </div>
        </c:if>

        <!-- Form chỉnh sửa thông tin -->
        <div class="edit-form">
            <form action="${pageContext.request.contextPath}/EditProfile" method="post">
                <div class="form-group">
                    <label class="form-label" for="fullName">Full Name</label>
                    <input type="text" id="fullName" name="fullName" class="form-input"
                           value="${user.fullName}" required placeholder="Enter your full name"/>
                </div>

                <div class="form-group">
                    <label class="form-label" for="phoneNumber">Phone Number</label>
                    <input type="text" id="phoneNumber" name="phoneNumber" class="form-input"
                           value="${user.phoneNumber}" required placeholder="Enter your phone number"/>
                </div>

                <div class="form-group">
                    <label class="form-label" for="gender">Gender</label>
                    <select name="gender" id="gender" class="form-select">
                        <option value="Male" ${customer.gender == 'Male' ? 'selected' : ''}>Male</option>
                        <option value="Female" ${customer.gender == 'Female' ? 'selected' : ''}>Female</option>
                    </select>
                </div>

                <div class="form-group">
                    <label class="form-label" for="birthDate">Birth Date</label>
                    <input type="date" id="birthDate" name="birthDate" class="form-input"
                           value="${customer.birthDate}"/>
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn-form btn-save">Save Changes</button>
                    <a href="${pageContext.request.contextPath}/Profile" class="btn-form btn-cancel">Back Profile</a>
                </div>
            </form>
        </div>
    </div>
</div>

<%-- Tự động ẩn thông báo sau 3 giây --%>
<script>
    setTimeout(function () {
        const alerts = document.querySelectorAll('.alert');
        alerts.forEach(alert => {
            alert.style.transition = 'opacity 0.5s ease';
            alert.style.opacity = '0';
            setTimeout(() => alert.style.display = 'none', 500);
        });
    }, 3000);
</script>

<%-- Nhúng footer --%>
<jsp:include page="/WEB-INF/views/common/footer.jsp" />


