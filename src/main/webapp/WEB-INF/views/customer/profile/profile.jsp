<%--
    File: /WEB-INF/views/customer/profile.jsp
    Description: Trang My Account tích hợp giao diện đẹp và sidebar điều hướng.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="My Account" scope="request"/>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<style>
    /* Toàn bộ CSS từ file profile.jsp mới của Khoa */
    .profile-section-container {
        background: #f4f7f6; /* Nền nhẹ cho toàn bộ khu vực */
        padding: 2rem 0;
    }
    .profile-card {
        background: white;
        border-radius: 15px;
        box-shadow: 0 8px 30px rgba(0,0,0,0.07);
        padding: 2rem;
    }
    .profile-header {
        text-align: center;
        margin-bottom: 1.5rem;
    }
    .profile-avatar {
        width: 80px;
        height: 80px;
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
    }
    .profile-header h2 {
        font-size: 1.5rem;
        font-weight: 600;
        color: #333;
    }
    .profile-subtitle {
        color: #777;
        font-size: 0.95rem;
    }
    .section-title {
        font-size: 1rem;
        font-weight: 600;
        color: #333;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        margin-bottom: 1rem;
        border-bottom: 2px solid #667eea;
        padding-bottom: 0.5rem;
    }
    .profile-info {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
        gap: 1rem;
    }
    .info-item {
        background: #f8f9fa;
        padding: 1rem;
        border-radius: 8px;
        border-left: 4px solid #764ba2;
    }
    .info-label {
        font-weight: 600;
        color: #555;
        font-size: 0.8rem;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        margin-bottom: 0.25rem;
        display: block;
    }
    .info-value {
        font-size: 1rem;
        color: #111;
        font-weight: 500;
    }
    .loyalty-points {
        text-align: center;
        margin-bottom: 1.5rem;
        padding: 1.5rem;
        background-color: #f8f9fa;
        border-radius: 12px;
    }
    .points-value {
        font-size: 2.5rem;
        font-weight: 700;
        color: #667eea;
        line-height: 1;
    }
    .points-label {
        font-size: 0.9rem;
        color: #666;
    }
    .profile-actions {
        display: flex;
        justify-content: center;
        gap: 1rem;
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
    }
    .btn-primary {
        background-color: #667eea;
        color: white;
    }
    .btn-primary:hover {
        background-color: #5a6edc;
        transform: translateY(-2px);
        box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        color: white;
    }
    .btn-outline {
        border-color: #667eea;
        color: #667eea;
    }
    .btn-outline:hover {
        background: #667eea;
        color: white;
    }
</style>

<div class="profile-section-container">
    <div class="container">
        <div class="row">
            <div class="col-lg-3 mb-4 mb-lg-0">
                <div class="list-group">
                    <a href="${pageContext.request.contextPath}/Profile" class="list-group-item list-group-item-action active" aria-current="true">My Profile</a>
                    <a href="${pageContext.request.contextPath}/customer/address" class="list-group-item list-group-item-action">Address Book</a>
                    <a href="#" class="list-group-item list-group-item-action">My Orders</a>
                    <a href="${pageContext.request.contextPath}/logout" class="list-group-item list-group-item-action text-danger">Logout</a>
                </div>
            </div>

            <div class="col-lg-9">
                <div class="profile-card">
                    <div class="profile-header">
                        <div class="profile-avatar">
                            <%-- Lấy ký tự đầu của tên làm avatar --%>
                            <c:if test="${not empty user.fullName}">${user.fullName.substring(0,1)}</c:if>
                            </div>
                            <h2>${user.fullName}</h2>
                        <p class="profile-subtitle">${user.email}</p>
                    </div>

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

                    <div class="profile-actions">
                        <a href="${pageContext.request.contextPath}/customer/edit-profile" class="btn-profile btn-primary">Edit Profile</a>
                        <a href="${pageContext.request.contextPath}/customer/change-password" class="btn-profile btn-outline">Change Password</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />