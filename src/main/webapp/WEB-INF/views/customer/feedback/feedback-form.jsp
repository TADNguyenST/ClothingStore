<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
    <head>
        <title>Submit Feedback</title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <style>
            body {
                background-color: #f4f6f9;
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            }
            .feedback-card {
                background-color: white;
                border-radius: 10px;
                padding: 30px;
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
                margin-top: 60px;
            }
            .form-label {
                font-weight: 600;
            }
            h2 {
                font-weight: bold;
                color: #333;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="row justify-content-center">
                <div class="col-md-8 col-lg-6">
                    <div class="feedback-card">
                        <h2 class="mb-4 text-center">Submit Your Feedback</h2>

                        <c:if test="${not empty sessionScope.user}">
                            <form action="feedback" method="post">
                                <input type="hidden" name="productId" value="${param.productId}" />
                                <input type="hidden" name="customerId" value="${sessionScope.user.userId}" />
                                <input type="hidden" name="orderId" value="${param.orderId}" />

                                <div class="mb-3">
                                    <label class="form-label">Rating (1-5):</label>
                                    <input type="number" name="rating" class="form-control" min="1" max="5" required />
                                </div>

                                <div class="mb-3">
                                    <label class="form-label">Comments:</label>
                                    <textarea name="comments" class="form-control" rows="4" required></textarea>
                                </div>

                                <div class="d-grid">
                                    <button type="submit" class="btn btn-primary btn-lg">Submit Feedback</button>
                                </div>
                            </form>
                        </c:if>

                        <c:if test="${empty sessionScope.user}">
                            <div class="alert alert-warning text-center">
                                You must <a href="${pageContext.request.contextPath}/Login">login</a> to submit feedback.
                            </div>
                        </c:if>

                    </div>
                </div>
            </div>
        </div>
    </body>
</html>
