<%-- 
    Document   : edit-profile
    Created on : Jun 23, 2025, 2:12:53 AM
    Author     : Khoa
--%>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<style>
    body {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        min-height: 100vh;
        font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
        margin: 0;
        padding: 0;
    }

    .edit-profile-container {
        min-height: calc(100vh - 120px);
        padding: 20px 0;
        display: flex;
        justify-content: center;
        align-items: flex-start;
    }

    .profile-card {
        display: flex;
        background: white;
        border-radius: 20px;
        box-shadow: 0 20px 60px rgba(0, 0, 0, 0.1);
        overflow: hidden;
        max-width: 900px;
        width: 100%;
        margin: 0 20px;
    }

    .profile-left {
        flex: 0 0 400px;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        padding: 30px 20px;
        color: white;
        position: relative;
    }

    .avatar-container {
        position: relative;
        margin-bottom: 20px;
    }

    .avatar {
        width: 100px;
        height: 100px;
        border-radius: 50%;
        border: 3px solid rgba(255, 255, 255, 0.3);
        object-fit: cover;
        background: rgba(255, 255, 255, 0.1);
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 40px;
        color: rgba(255, 255, 255, 0.7);
    }

    .change-avatar-btn {
        margin-top: 10px;
        background: rgba(255, 255, 255, 0.2);
        border: 2px dashed rgba(255, 255, 255, 0.5);
        color: white;
        padding: 6px 12px;
        border-radius: 15px;
        font-size: 11px;
        cursor: pointer;
        transition: all 0.3s ease;
        backdrop-filter: blur(10px);
        display: block;
        text-align: center;
    }

    .change-avatar-btn:hover {
        background: rgba(255, 255, 255, 0.3);
        border-color: rgba(255, 255, 255, 0.8);
    }

    .profile-title {
        font-size: 24px;
        font-weight: 700;
        margin-bottom: 6px;
        text-align: center;
    }

    .profile-subtitle {
        font-size: 14px;
        opacity: 0.8;
        text-align: center;
        font-weight: 300;
    }

    .profile-right {
        flex: 1;
        padding: 30px 40px;
        display: flex;
        flex-direction: column;
        justify-content: flex-start;
        overflow-y: auto;
    }

    .form-group {
        margin-bottom: 20px;
    }

    .form-label {
        display: block;
        font-weight: 600;
        color: #374151;
        margin-bottom: 6px;
        font-size: 13px;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }

    .form-input {
        width: 100%;
        padding: 12px 16px;
        border: 2px solid #e5e7eb;
        border-radius: 10px;
        font-size: 14px;
        transition: all 0.3s ease;
        background: #f9fafb;
        box-sizing: border-box;
    }

    .form-input:focus {
        outline: none;
        border-color: #667eea;
        background: white;
        box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
    }

    .form-select {
        width: 100%;
        padding: 12px 16px;
        border: 2px solid #e5e7eb;
        border-radius: 10px;
        font-size: 14px;
        background: #f9fafb;
        cursor: pointer;
        transition: all 0.3s ease;
        box-sizing: border-box;
    }

    .form-select:focus {
        outline: none;
        border-color: #667eea;
        background: white;
        box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
    }

    .date-input {
        position: relative;
    }

    .date-input input[type="date"] {
        width: 100%;
        padding: 12px 16px;
        border: 2px solid #e5e7eb;
        border-radius: 10px;
        font-size: 14px;
        background: #f9fafb;
        transition: all 0.3s ease;
        box-sizing: border-box;
    }

    .date-input input[type="date"]:focus {
        outline: none;
        border-color: #667eea;
        background: white;
        box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
    }

    .button-group {
        display: flex;
        gap: 12px;
        margin-top: 20px;
    }

    .btn-primary {
        flex: 1;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        border: none;
        padding: 12px 24px;
        border-radius: 10px;
        font-size: 14px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.3s ease;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }

    .btn-primary:hover {
        transform: translateY(-1px);
        box-shadow: 0 6px 20px rgba(102, 126, 234, 0.3);
    }

    .btn-secondary {
        flex: 1;
        background: transparent;
        color: #667eea;
        border: 2px solid #667eea;
        padding: 12px 24px;
        border-radius: 10px;
        font-size: 14px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.3s ease;
        text-decoration: none;
        display: flex;
        align-items: center;
        justify-content: center;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }

    .btn-secondary:hover {
        background: #667eea;
        color: white;
        transform: translateY(-1px);
        text-decoration: none;
    }

    .alert-success {
        background: #d1fae5;
        color: #065f46;
        padding: 12px 20px;
        border-radius: 8px;
        margin-bottom: 20px;
        border-left: 4px solid #10b981;
    }

    .alert-danger {
        background: #fee2e2;
        color: #991b1b;
        padding: 12px 20px;
        border-radius: 8px;
        margin-bottom: 20px;
        border-left: 4px solid #ef4444;
    }

    .file-input-wrapper {
        position: relative;
        overflow: hidden;
        display: inline-block;
        width: 100%;
    }

    .file-input {
        position: absolute;
        left: -9999px;
    }

    .file-input-label {
        display: block;
        padding: 12px 16px;
        border: 2px dashed #d1d5db;
        border-radius: 10px;
        background: #f9fafb;
        text-align: center;
        cursor: pointer;
        transition: all 0.3s ease;
        color: #6b7280;
        font-size: 14px;
    }

    .file-input-label:hover {
        border-color: #667eea;
        background: rgba(102, 126, 234, 0.05);
        color: #667eea;
    }

    @media (max-width: 768px) {
        .profile-card {
            flex-direction: column;
            margin: 10px;
            max-width: none;
        }

        .profile-left {
            flex: none;
            padding: 20px;
        }

        .profile-right {
            padding: 20px;
        }

        .button-group {
            flex-direction: column;
        }
    }

    @media (max-width: 1200px) {
        .profile-left {
            flex: 0 0 350px;
        }
    }
</style>

<div class="edit-profile-container">
    <div class="profile-card">
        <div class="profile-left">
            <div class="avatar-container">
                <c:choose>
                    <c:when test="${not empty customer.avatarUrl}">
                        <img src="${customer.avatarUrl}" alt="Avatar" class="avatar" id="avatarPreview">
                    </c:when>
                    <c:otherwise>
                        <div class="avatar" id="avatarPreview">👤</div>
                    </c:otherwise>
                </c:choose>
                <label for="avatar" class="change-avatar-btn">📷 Change Avatar</label>
            </div>
            <h1 class="profile-title">EDIT PROFILE</h1>
            <p class="profile-subtitle">Update your account information</p>
        </div>

        <div class="profile-right">
            <c:if test="${not empty success}">
                <div class="alert-success">${success}</div>
            </c:if>
            <c:if test="${not empty err}">
                <div class="alert-danger">${err}</div>
            </c:if>

            <form action="${pageContext.request.contextPath}/EditProfile" method="post" enctype="multipart/form-data">
                <div class="form-group">
                    <label class="form-label">Full Name</label>
                    <input type="text" name="full_name" value="${user.fullName}" class="form-input" required>
                </div>

                <div class="form-group">
                    <label class="form-label">Phone Number</label>
                    <input type="text" name="phone_number" value="${user.phoneNumber}" class="form-input" required>
                </div>

                <div class="form-group">
                    <label class="form-label">Gender</label>
                    <select name="gender" class="form-select" required>
                        <option value="Male" ${customer.gender == 'Male' ? 'selected' : ''}>Male</option>
                        <option value="Female" ${customer.gender == 'Female' ? 'selected' : ''}>Female</option>
                    </select>
                </div>

                <div class="form-group">
                    <label class="form-label">Birth Date</label>
                    <div class="date-input">
                        <input type="date" name="birth_date" value="${customer.birthDate}" required>
                    </div>
                </div>

                <div class="form-group">
                    <div class="file-input-wrapper">
                        <input type="file" name="avatar" accept="image/*" class="file-input" id="avatar">
                    </div>
                </div>

                <div class="button-group">
                    <button type="submit" class="btn-primary">Save Changes</button>
                    <a href="${pageContext.request.contextPath}/Profile" class="btn-secondary">Back Profile</a>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    // Preview avatar when file is selected
    document.getElementById('avatar').addEventListener('change', function(e) {
        const file = e.target.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onload = function(e) {
                const avatarPreview = document.getElementById('avatarPreview');
                avatarPreview.innerHTML = '';
                const img = document.createElement('img');
                img.src = e.target.result;
                img.className = 'avatar';
                img.style.width = '100%';
                img.style.height = '100%';
                img.style.objectFit = 'cover';
                avatarPreview.appendChild(img);
            };
            reader.readAsDataURL(file);
        }
    });

    // Update file input label when file is selected
    document.getElementById('avatar').addEventListener('change', function(e) {
        const label = document.querySelector('.file-input-label');
        if (e.target.files.length > 0) {
            label.textContent = e.target.files[0].name;
        } else {
            label.textContent = 'Choose new avatar image or drag and drop';
        }
    });
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />