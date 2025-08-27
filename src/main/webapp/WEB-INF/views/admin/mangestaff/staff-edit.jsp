<%-- 
    Document   : staff-edit
    Created on : Jul 10, 2025, 8:37:07 AM
    Author     : khoa
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Edit Staff</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/admin-dashboard/css/admin-css.css">
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f4f4f9;
            margin: 0;
            padding: 0;
        }

        .main-content-wrapper {
            margin-left: 250px; /* Giữ khoảng cho sidebar */
        }

        .content-area {
            padding: 30px;
            background-color: #f4f4f9;
        }

        h2 {
            text-align: center;
            color: #333;
            margin-bottom: 20px;
            font-size: 28px;
        }

        form {
            max-width: 800px;
            margin: auto;
            background-color: #fff;
            padding: 25px 30px;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
        }

        .form-row {
            display: block; /* Sửa từ flex thành block để các trường nằm dọc */
            gap: 20px;
            margin-bottom: 15px;
        }

        .form-group {
            margin-bottom: 15px; /* Thêm khoảng cách giữa các trường */
        }

        label {
            display: block;
            margin-bottom: 6px;
            font-weight: 600;
            color: #333;
        }

        input, textarea, select {
            width: 100%;
            padding: 10px 12px;
            border: 1px solid #ccc;
            border-radius: 6px;
            font-size: 14px;
            transition: border-color 0.3s ease;
        }

        input:focus, textarea:focus, select:focus {
            border-color: #007bff;
            outline: none;
        }

        textarea {
            resize: vertical;
            min-height: 80px;
        }

        .btn {
            padding: 10px 18px;
            background-color: #007bff;
            color: white;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 14px;
            text-decoration: none;
            margin-right: 10px;
            transition: background-color 0.3s ease;
        }

        .btn:hover {
            background-color: #0056b3;
        }

        .btn-cancel {
            background-color: #6c757d;
        }

        .btn-cancel:hover {
            background-color: #5a6268;
        }

        .error {
            color: #721c24;
            background-color: #f8d7da;
            border: 1px solid #f5c6cb;
            padding: 10px;
            border-radius: 6px;
            margin: 10px auto;
            max-width: 800px;
            font-weight: 500;
            text-align: center;
        }

        .form-actions {
            text-align: right;
            margin-top: 20px;
        }
        
    </style>
</head>
<body>

    <%-- Đặt các biến requestScope cho sidebar/header --%>
    <c:set var="currentAction" value="staff" scope="request"/>
    <c:set var="currentModule" value="admin" scope="request"/>
    <c:set var="pageTitle" value="Edit Staff" scope="request"/>

    <%-- Nhúng Sidebar --%>
    <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp" />

    <div class="main-content-wrapper">
        <%-- Nhúng Header --%>
        

        <%-- Nội dung chính của trang Edit Staff --%>
        <div class="content-area">
            <h2 style="text-align:center;">Edit Staff Account</h2>

            <c:if test="${not empty param.errorMessage}">
                <div class="error">${param.errorMessage}</div>
            </c:if>

            <form method="post" action="${pageContext.request.contextPath}/EditStaff">
                <input type="hidden" name="userId" value="${staffInfo.user.userId}" />

                <div class="form-row">
                    <div class="form-group">
                        <label>Full Name:</label>
                        <input type="text" name="fullName" value="${staffInfo.user.fullName}" required />
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label>Phone Number:</label>
                        <input type="text" name="phoneNumber" value="${staffInfo.user.phoneNumber}" required pattern="[0-9]{10}" title="Phone number must contain exactly 10 digits (0-9)" />
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label>Position:</label>
                        <input type="text" name="position" value="${staffInfo.staff.position}" required />
                    </div>
                </div>

                <div class="form-group">
                    <label>Notes:</label>
                    <textarea name="notes">${staffInfo.staff.notes}</textarea>
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn">Update</button>
                    <a href="${pageContext.request.contextPath}/StaffManagement" class="btn btn-cancel">Cancel</a>
                </div>
            </form>
        </div>
    </div>

    <%-- Link đến file JS dùng chung --%>
    <script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>
</body>
</html>
