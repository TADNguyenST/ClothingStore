<%-- 
Document   : profile
Created on : Jun 14, 2025, 4:07:02 AM
Author     : Khoa
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- Đặt tiêu đề cho trang này, header.jsp sẽ dùng biến này --%>
<c:set var="pageTitle" value="Customer Profile" scope="request"/>

<%-- Nhúng header --%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<style>
    /* CSS cho trang profile - Optimized Responsive Design */
    .profile-container {
        min-height: 60vh;
        background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
        padding: 1rem;
    }

    .profile-card {
        background: white;
        border-radius: 12px;
        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.08);
        padding: 1.2rem;
        position: relative;
        overflow: hidden;
        margin: 0 auto;
        max-width: 700px;
        width: 100%;
    }

    .profile-card::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        height: 3px;
        background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
    }

    .profile-header {
        text-align: center;
        margin-bottom: 1rem;
        position: relative;
    }

    .profile-avatar {
        width: 50px;
        height: 50px;
        border-radius: 50%;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        display: flex;
        align-items: center;
        justify-content: center;
        margin: 0 auto 0.6rem;
        font-size: 1.3rem;
        color: white;
        font-weight: 700;
        text-transform: uppercase;
        box-shadow: 0 6px 15px rgba(102, 126, 234, 0.25);
    }

    .profile-header h2 {
        font-size: 1.2rem;
        font-weight: 700;
        color: #333;
        text-transform: uppercase;
        letter-spacing: 1px;
        margin-bottom: 0.2rem;
    }

    .profile-subtitle {
        color: #666;
        font-size: 0.85rem;
        margin: 0;
    }

    .profile-section {
        background: #f8f9fa;
        border-radius: 8px;
        padding: 1rem;
        margin-bottom: 1rem;
    }

    .section-title {
        font-size: 0.9rem;
        font-weight: 700;
        color: #333;
        text-transform: uppercase;
        letter-spacing: 1px;
        margin-bottom: 0.6rem;
        border-bottom: 2px solid #667eea;
        padding-bottom: 0.3rem;
    }

    .profile-info {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
        gap: 0.6rem;
    }

    .info-item {
        background: white;
        padding: 0.6rem;
        border-radius: 6px;
        border-left: 3px solid #667eea;
        transition: all 0.3s ease;
        min-height: 55px;
        display: flex;
        flex-direction: column;
        justify-content: center;
    }

    .info-item:hover {
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
    }

    .info-label {
        font-weight: 600;
        color: #333;
        text-transform: uppercase;
        font-size: 0.75rem;
        letter-spacing: 0.5px;
        margin-bottom: 0.4rem;
        display: block;
    }

    .info-value {
        font-size: 0.95rem;
        color: #555;
        font-weight: 500;
        margin: 0;
        word-break: break-word;
    }

    .loyalty-points {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        text-align: center;
        padding: 1.5rem 1.2rem;
        border-radius: 12px;
        margin-bottom: 1.2rem;
    }

    .loyalty-points h3 {
        font-size: 1rem;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 1px;
        margin-bottom: 0.8rem;
    }

    .points-value {
        font-size: 2rem;
        font-weight: 700;
        margin-bottom: 0.4rem;
        line-height: 1;
    }

    .points-label {
        font-size: 0.9rem;
        opacity: 0.9;
    }

    /* FIXED BUTTON STYLES */
    .profile-actions {
        display: flex;
        justify-content: center;
        align-items: center;
        gap: 1rem;
        margin-top: 1.5rem;
        flex-wrap: wrap;
    }

    .btn-profile {
        padding: 0.8rem 1.5rem;
        border-radius: 8px;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        text-decoration: none;
        transition: all 0.3s ease;
        border: none;
        cursor: pointer;
        font-size: 0.85rem;
        text-align: center;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        min-height: 45px;
        min-width: 140px;
        flex: 0 0 auto;
    }

    .btn-primary {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        border: 2px solid transparent;
    }

    .btn-primary:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 25px rgba(102, 126, 234, 0.3);
        color: white;
    }

    .btn-outline {
        background: transparent;
        color: #667eea;
        border: 2px solid #667eea;
    }

    .btn-outline:hover {
        background: #667eea;
        color: white;
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(102, 126, 234, 0.2);
    }

    .btn-cancel {
        background: transparent;
        color: #6c757d;
        border: 2px solid #6c757d;
    }

    .btn-cancel:hover {
        background: #6c757d;
        color: white;
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(108, 117, 125, 0.2);
    }

    /* Status badge */
    .status-badge {
        display: inline-block;
        padding: 0.2rem 0.6rem;
        border-radius: 15px;
        font-size: 0.7rem;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }

    .status-active {
        background: #d4edda;
        color: #155724;
    }

    /* Responsive Breakpoints - Optimized for smaller screens */

    /* Large Desktop (1200px+) */
    @media (min-width: 1200px) {
        .profile-container {
            padding: 2rem 1rem;
        }

        .profile-card {
            padding: 2rem;
        }

        .profile-info {
            grid-template-columns: repeat(3, 1fr);
        }
    }

    /* Desktop (992px - 1199px) */
    @media (min-width: 992px) and (max-width: 1199px) {
        .profile-info {
            grid-template-columns: repeat(2, 1fr);
        }
    }

    /* Tablet (768px - 991px) */
    @media (min-width: 768px) and (max-width: 991px) {
        .profile-container {
            padding: 1rem 0.5rem;
        }

        .profile-card {
            padding: 1.2rem;
        }

        .profile-info {
            grid-template-columns: repeat(2, 1fr);
            gap: 0.6rem;
        }

        .loyalty-points {
            padding: 1.2rem 1rem;
        }

        .profile-section {
            padding: 1rem;
        }

        .profile-actions {
            justify-content: space-between;
        }

        .btn-profile {
            flex: 1;
            max-width: 180px;
        }
    }

    /* Small Tablet (576px - 767px) */
    @media (min-width: 576px) and (max-width: 767px) {
        .profile-container {
            padding: 0.8rem 0.3rem;
        }

        .profile-card {
            padding: 1rem;
        }

        .profile-info {
            grid-template-columns: 1fr;
            gap: 0.6rem;
        }

        .profile-avatar {
            width: 50px;
            height: 50px;
            font-size: 1.3rem;
        }

        .loyalty-points {
            padding: 1rem 0.8rem;
        }

        .profile-section {
            padding: 0.8rem;
        }

        .info-item {
            padding: 0.6rem;
            min-height: 55px;
        }

        .profile-actions {
            flex-direction: column;
            gap: 0.8rem;
            align-items: stretch;
        }

        .btn-profile {
            width: 100%;
            min-width: auto;
            max-width: 300px;
            margin: 0 auto;
        }
    }

    /* Mobile (320px - 575px) */
    @media (max-width: 575px) {
        .profile-container {
            padding: 0.5rem 0.2rem;
            min-height: auto;
        }

        .profile-card {
            padding: 0.8rem;
            margin: 0;
            border-radius: 8px;
        }

        .profile-info {
            grid-template-columns: 1fr;
            gap: 0.5rem;
        }

        .profile-avatar {
            width: 45px;
            height: 45px;
            font-size: 1.2rem;
        }

        .loyalty-points {
            padding: 0.8rem 0.6rem;
            margin-bottom: 0.8rem;
        }

        .profile-section {
            padding: 0.6rem;
            margin-bottom: 0.8rem;
        }

        .info-item {
            padding: 0.5rem;
            min-height: 50px;
        }

        .profile-header {
            margin-bottom: 1rem;
        }

        .profile-header h2 {
            font-size: 1.2rem;
        }

        .points-value {
            font-size: 1.6rem;
        }

        .profile-actions {
            flex-direction: column;
            gap: 0.8rem;
            align-items: stretch;
        }

        .btn-profile {
            width: 100%;
            min-width: auto;
            max-width: 300px;
            margin: 0 auto;
            padding: 0.7rem 1.2rem;
            font-size: 0.8rem;
            min-height: 42px;
        }
    }

    /* Extra Small Mobile (320px and below) */
    @media (max-width: 320px) {
        .profile-container {
            padding: 0.3rem 0.1rem;
        }

        .profile-card {
            padding: 0.6rem;
        }

        .profile-avatar {
            width: 40px;
            height: 40px;
            font-size: 1rem;
        }

        .loyalty-points {
            padding: 0.6rem;
        }

        .profile-section {
            padding: 0.5rem;
        }

        .info-item {
            padding: 0.4rem;
            min-height: 45px;
        }

        .btn-profile {
            padding: 0.5rem 0.6rem;
            font-size: 0.7rem;
            min-height: 35px;
        }
    }

    /* Landscape Mobile Optimization */
    @media (max-height: 500px) and (orientation: landscape) {
        .profile-container {
            min-height: auto;
            padding: 0.5rem;
        }

        .profile-header {
            margin-bottom: 0.8rem;
        }

        .loyalty-points {
            padding: 0.8rem;
            margin-bottom: 0.8rem;
        }

        .profile-section {
            margin-bottom: 0.8rem;
        }

        .profile-actions {
            margin-top: 1rem;
        }
    }

    /* Print Styles */
    @media print {
        .profile-container {
            background: none;
            padding: 0;
        }

        .profile-card {
            box-shadow: none;
            border: 1px solid #ccc;
        }

        .profile-actions {
            display: none;
        }

        .loyalty-points {
            background: #f8f9fa !important;
            color: #333 !important;
        }
    }
</style>

<div class="profile-container">
    <div class="profile-card">
        <div class="profile-header">
            <div class="profile-avatar">
                ${user.fullName.substring(0,1)}
            </div>
            <h2>Customer Profile</h2>
            <p class="profile-subtitle">Manage your account information</p>
        </div>

        <!-- Loyalty Points Section -->
        <div class="loyalty-points">
            <h3>Loyalty Points</h3>
            <div class="points-value">${customer.loyaltyPoints}</div>
            <div class="points-label">Points Available</div>
        </div>

        <!-- Personal Information Section -->
        <div class="profile-section">
            <h3 class="section-title">Personal Information</h3>
            <div class="profile-info">
                <div class="info-item">
                    <span class="info-label">Full Name</span>
                    <p class="info-value">${user.fullName}</p>
                </div>
                <div class="info-item">
                    <span class="info-label">Email Address</span>
                    <p class="info-value">${user.email}</p>
                </div>
                <div class="info-item">
                    <span class="info-label">Phone Number</span>
                    <p class="info-value">${user.phoneNumber}</p>
                </div>
                <div class="info-item">
                    <span class="info-label">Gender</span>
                    <p class="info-value">${customer.gender}</p>
                </div>
                <div class="info-item">
                    <span class="info-label">Birth Date</span>
                    <p class="info-value">${customer.birthDate}</p>
                </div>
                <div class="info-item">
                    <span class="info-label">Account Status</span>
                    <p class="info-value">
                        <span class="status-badge status-active">Active</span>
                    </p>
                </div>
            </div>
        </div>

        <!-- Account Details Section -->
        <div class="profile-section">
            <h3 class="section-title">Account Details</h3>
            <div class="profile-info">
                <div class="info-item">
                    <span class="info-label">Member Since</span>
                    <p class="info-value">${user.createdAt}</p>
                </div>
                <div class="info-item">
                    <span class="info-label">Customer ID</span>
                    <p class="info-value">#${customer.customerId}</p>
                </div>
            </div>
        </div>

        <!-- Action Buttons -->
        <div class="profile-actions">
            <a href="${pageContext.request.contextPath}/EditProfile" class="btn-profile btn-primary">
                Edit Profile
            </a>
            <a href="${pageContext.request.contextPath}/ChangePassword" class="btn-profile btn-outline">
                Change Password
            </a>
            <a href="${pageContext.request.contextPath}/home" class="btn-profile btn-cancel">
                Cancel
            </a>
        </div>
    </div>
</div>

<%-- Nhúng footer --%>
<jsp:include page="/WEB-INF/views/common/footer.jsp" />