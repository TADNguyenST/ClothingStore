<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:setLocale value="en_US" />

<c:set var="pageTitle" value="My Account" scope="request"/>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<style>
    .profile-section-container {
        background: #f4f7f6;
        padding: 2rem 0;
        font-family: 'Jost', sans-serif;
    }
    .profile-card {
        background: white;
        border-radius: 15px;
        box-shadow: 0 8px 30px rgba(0,0,0,0.07);
        padding: 2rem;
        transition: all 0.3s ease;
    }
    .profile-card:hover {
        box-shadow: 0 12px 40px rgba(0,0,0,0.1);
    }
    .profile-header {
        text-align: center;
        margin-bottom: 1.5rem;
    }
    .profile-avatar {
        width: 100px;
        height: 100px;
        border-radius: 50%;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        display: flex;
        align-items: center;
        justify-content: center;
        margin: 0 auto 1rem;
        font-size: 2.5rem;
        color: white;
        font-weight: 700;
        text-transform: uppercase;
        border: 4px solid #fff;
        box-shadow: 0 4px 12px rgba(0,0,0,0.1);
    }
    .profile-header h2 {
        font-size: 1.8rem;
        font-weight: 600;
        color: #333;
        margin-bottom: 0.5rem;
    }
    .profile-subtitle {
        color: #777;
        font-size: 1rem;
        margin-bottom: 1.5rem;
    }
    .section-title {
        font-size: 1.2rem;
        font-weight: 600;
        color: #333;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        margin-bottom: 1rem;
        border-bottom: 2px solid #667eea;
        padding-bottom: 0.5rem;
        position: relative;
    }
    .section-title::after {
        content: '';
        position: absolute;
        bottom: -2px;
        left: 0;
        width: 50px;
        height: 2px;
        background: #764ba2;
    }
    .profile-info {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
        gap: 1.5rem;
    }
    .info-item {
        background: #f8f9fa;
        padding: 1.2rem;
        border-radius: 10px;
        border-left: 4px solid #764ba2;
        transition: all 0.3s ease;
    }
    .info-item:hover {
        transform: translateY(-5px);
        box-shadow: 0 6px 15px rgba(0,0,0,0.05);
    }
    .info-label {
        font-weight: 600;
        color: #555;
        font-size: 0.9rem;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        margin-bottom: 0.25rem;
    }
    .info-value {
        font-size: 1.1rem;
        color: #111;
        font-weight: 500;
    }
    .loyalty-points {
        text-align: center;
        margin-bottom: 1.5rem;
        padding: 1.5rem;
        background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
        border-radius: 12px;
        border: 1px solid #ddd;
    }
    .points-value {
        font-size: 2.8rem;
        font-weight: 700;
        color: #667eea;
        line-height: 1;
    }
    .points-label {
        font-size: 1rem;
        color: #666;
        text-transform: uppercase;
    }
    .profile-actions {
        display: flex;
        justify-content: center;
        gap: 1.5rem;
        margin-top: 2rem;
        flex-wrap: wrap;
    }
    .btn-profile {
        padding: 0.75rem 2rem;
        border-radius: 50px;
        font-weight: 600;
        text-decoration: none;
        transition: all 0.3s ease;
        border: 2px solid transparent;
        display: inline-flex;
        align-items: center;
        gap: 0.5rem;
    }
    .btn-primary {
        background-color: #667eea;
        color: white;
    }
    .btn-primary:hover {
        background-color: #5a6edc;
        transform: translateY(-2px);
        box-shadow: 0 4px 15px rgba(0,0,0,0.1);
    }
    .btn-outline {
        border-color: #667eea;
        color: #667eea;
    }
    .btn-outline:hover {
        background: #667eea;
        color: white;
    }
    .sidebar {
        min-height: 100vh;
        background: #fff;
        border-right: 1px solid #e9ecef;
        padding-top: 1rem;
    }
    .list-group-item {
        border: none;
        padding: 0.75rem 1.5rem;
        background: transparent;
        transition: all 0.3s;
        border-left: 4px solid transparent;
        color: #333;
        font-weight: 500;
    }
    .list-group-item.active {
        background: #f8f9fa;
        color: #667eea;
        border-left-color: #667eea;
        border-radius: 0;
    }
    .list-group-item:hover {
        background: #f0f0f0;
        color: #111;
        border-left-color: #ddd;
    }
</style>

<div class="profile-section-container">
    <div class="container">
        <div class="row">
            <div class="col-lg-3 mb-4 mb-lg-0 sidebar">
                <div class="list-group">
                    <a href="${pageContext.request.contextPath}/Profile" class="list-group-item list-group-item-action ${param.action == null || param.action == 'profile' ? 'active' : ''}" aria-current="true">
                        <i class="fas fa-user me-2"></i> My Profile
                    </a>
                    <a href="${pageContext.request.contextPath}/customer/address" class="list-group-item list-group-item-action">
                        <i class="fas fa-address-book me-2"></i> Address Book
                    </a>
                    <a href="${pageContext.request.contextPath}/orders" class="list-group-item list-group-item-action ${param.action == 'orders' ? 'active' : ''}">
                        <i class="fas fa-box-open me-2"></i> My Orders
                    </a>
                    <a href="${pageContext.request.contextPath}/Logout" class="list-group-item list-group-item-action text-danger ${param.action == 'logout' ? 'active' : ''}">
                        <i class="fas fa-sign-out-alt me-2"></i> Logout
                    </a>
                </div>
            </div>

            <div class="col-lg-9">
                <div class="profile-card">
                    <div class="profile-header">
                        <c:choose>
                            <c:when test="${not empty customer.avatarUrl}">
                                <img src="${customer.avatarUrl}" alt="Avatar"
                                     style="width: 100px; height: 100px; border-radius: 50%; object-fit: cover;
                                     box-shadow: 0 4px 12px rgba(0,0,0,0.1); margin: 0 auto 1rem; display: block;" />
                            </c:when>
                            <c:otherwise>
                                <div class="profile-avatar">
                                    <c:if test="${not empty user.fullName}">${user.fullName.substring(0,1)}</c:if>
                                    </div>
                            </c:otherwise>
                        </c:choose>
                        <h2>${user.fullName}</h2>

                        <div class="loyalty-points">
                            <div class="points-label">Loyalty Points</div>
                            <div class="points-value">${customer.loyaltyPoints}</div>
                        </div>

                        <h3 class="section-title">Account Information</h3>
                        <div class="profile-info">
                            <div class="info-item">
                                <span class="info-label">Phone Number</span>
                                <p class="info-value">${not empty user.phoneNumber ? user.phoneNumber : 'Not set'}</p>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Gender</span>
                                <p class="info-value">${not empty customer.gender ? customer.gender : 'Not set'}</p>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Email</span>
                                <p class="info-value">${user.email}</p>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Birth Date</span>
                                <p class="info-value">
                                    <c:if test="${not empty customer.birthDate}">
                                        <fmt:formatDate value="${customer.birthDate}" pattern="dd MMMM, yyyy" />
                                    </c:if>
                                    <c:if test="${empty customer.birthDate}">Not set</c:if>
                                    </p>
                                </div>
                                <div class="info-item">
                                    <span class="info-label">Member Since</span>
                                    <p class="info-value"><fmt:formatDate value="${user.createdAt}" pattern="dd MMMM, yyyy" /></p>
                            </div>
                        </div>
                    </div>

                    <div class="profile-actions">
                        <a href="${pageContext.request.contextPath}/EditProfile" class="btn-profile btn-primary">
                            <i class="fas fa-edit"></i> Edit Profile
                        </a>
                        <a href="${pageContext.request.contextPath}/ChangePassword" class="btn-profile btn-outline">
                            <i class="fas fa-lock"></i> Change Password
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />