<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>Reply to Feedback</title>
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
        .form-container {
            max-width: 600px;
            margin: 0 auto;
            background-color: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.2);
        }
        .form-group {
            margin-bottom: 15px;
        }
        label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        textarea {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            resize: vertical;
        }
        select {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
        }
        .submit-btn {
            padding: 10px 20px;
            background-color: #4CAF50;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        .submit-btn:hover {
            background-color: #45a049;
        }
        .error {
            color: red;
            text-align: center;
            margin-bottom: 15px;
        }
        .back-btn {
            display: inline-block;
            padding: 10px 20px;
            background-color: #2196F3;
            color: white;
            text-decoration: none;
            border-radius: 4px;
            margin-bottom: 20px;
        }
        .back-btn:hover {
            background-color: #1976D2;
        }
    </style>
</head>
<body>
    <div class="form-container">
        <h2>Reply to Feedback</h2>
        <a href="${pageContext.request.contextPath}/feedbackList" class="back-btn">Back to Feedback List</a>
        <c:if test="${not empty error}">
            <p class="error">${error}</p>
        </c:if>
        <form action="${pageContext.request.contextPath}/feedbackReply" method="post">
            <input type="hidden" name="feedbackId" value="${param.feedbackId}"/>
            <div class="form-group">
                <label for="content">Reply Content:</label>
                <textarea id="content" name="content" rows="5" required></textarea>
            </div>
            <div class="form-group">
                <label for="visibility">Visibility:</label>
                <select id="visibility" name="visibility" required>
                    <option value="Public">Public</option>
                    <option value="Private">Private</option>
                </select>
            </div>
            <button type="submit" class="submit-btn">Submit Reply</button>
        </form>
    </div>
</body>
</html>