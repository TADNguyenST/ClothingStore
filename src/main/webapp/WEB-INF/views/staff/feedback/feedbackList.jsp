<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<html>
<head>
    <title>Feedback List</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            background-color: #f4f4f4;
        }
        h2 {
            color: #333;
            text-align: center;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            background-color: white;
            box-shadow: 0 1px 3px rgba(0,0,0,0.2);
            margin-bottom: 20px;
        }
        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        th {
            background-color: #4CAF50;
            color: white;
        }
        tr:hover {
            background-color: #f5f5f5;
        }
        .error {
            color: red;
            text-align: center;
            margin-bottom: 20px;
        }
        .export-btn {
            display: inline-block;
            padding: 10px 20px;
            background-color: #4CAF50;
            color: white;
            text-decoration: none;
            border-radius: 4px;
            margin-bottom: 20px;
        }
        .export-btn:hover {
            background-color: #45a049;
        }
        .reply-btn {
            padding: 8px 16px;
            background-color: #2196F3;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
        }
        .reply-btn:hover {
            background-color: #1976D2;
        }
        .disabled-btn {
            padding: 8px 16px;
            background-color: #cccccc;
            color: #666666;
            border: none;
            border-radius: 4px;
            cursor: not-allowed;
            text-decoration: none;
            display: inline-block;
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
    <jsp:include page="/WEB-INF/views/staff/staff-sidebar.jsp" />
    <div class="content-area">
    <h2>Customer Feedback List</h2>
    <c:if test="${not empty error}">
        <p class="error">${error}</p>
    </c:if>
   
    <table>
        <tr>
            <th>Product ID</th>
            <th>Customer ID</th>
            <th>Rating</th>
            <th>Comments</th>
            <th>Creation Date</th>
            <th>Reply</th>
            <th>Action</th>
        </tr>
        <c:forEach items="${feedbackList}" var="feedback">
            <tr>
                <td>${feedback.productId}</td>
                <td>${feedback.customerId}</td>
                <td>${feedback.rating}/5</td>
                <td><c:out value="${empty feedback.comments ? 'N/A' : feedback.comments}" /></td>
                <td><fmt:formatDate value="${feedback.creationDate}" pattern="dd-MM-yyyy HH:mm" /></td>
                <td><c:out value="${empty feedback.replyContent ? 'No reply' : feedback.replyContent}" /></td>
                <td>
                    <c:choose>
                        <c:when test="${empty feedback.replyContent}">
                            <a href="${pageContext.request.contextPath}/feedbackReply?feedbackId=${feedback.feedbackId}" class="reply-btn">Reply</a>
                        </c:when>
                        <c:otherwise>
                            <span class="disabled-btn">Replied</span>
                        </c:otherwise>
                    </c:choose>
                </td>
            </tr>
        </c:forEach>
    </table>
        </div>
</body>
</html>