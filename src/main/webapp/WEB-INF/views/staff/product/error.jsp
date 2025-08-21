```jsp
<%--
    Document : error
    Created on : Aug 9, 2025
    Author : DANGVUONGTHINH
--%>
<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Lỗi</title>
    <style>
        .error-container {
            max-width: 600px;
            margin: 20px auto;
            padding: 20px;
            border: 1px solid #ddd;
            border-radius: 4px;
            text-align: center;
        }
        .error-container p {
            color: red;
        }
    </style>
</head>
<body>
    <div class="error-container">
        <h2>Có lỗi xảy ra</h2>
        <p><%= request.getAttribute("error") %></p>
        <a href="${pageContext.request.contextPath}/ProductsManager">Quay lại danh sách sản phẩm</a>
    </div>
</body>
</html>
```