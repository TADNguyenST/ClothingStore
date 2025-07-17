<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<style>
    .feedback-section {
        margin-top: 40px;
    }

    .rating-summary {
        display: flex;
        align-items: center;
        gap: 20px;
        padding: 20px;
        border-radius: 10px;
        background-color: #fff8f1;
        border: 1px solid #ffe0b3;
        margin-bottom: 30px;
    }

    .rating-score {
        font-size: 2.8rem;
        font-weight: bold;
        color: #ff5722;
    }

    .rating-stars {
        color: #ffc107;
        font-size: 1.4rem;
    }

    .total-feedback {
        font-size: 1rem;
        color: #666;
    }

    .feedback-card {
        background: #fff;
        border: 1px solid #eee;
        border-radius: 10px;
        padding: 20px;
        margin-bottom: 25px;
        box-shadow: 0 2px 6px rgba(0,0,0,0.05);
    }

    .feedback-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .feedback-user {
        display: flex;
        align-items: center;
    }

    .feedback-user img {
        width: 40px;
        height: 40px;
        border-radius: 50%;
        margin-right: 10px;
    }

    .feedback-user-name {
        font-weight: bold;
        color: #333;
    }

    .feedback-time {
        font-size: 0.9rem;
        color: #999;
        margin: 5px 0;
    }

    .feedback-stars {
        color: #ffc107;
        font-size: 1rem;
    }

    .feedback-comment {
        font-size: 1rem;
        margin: 10px 0;
        color: #444;
    }

    .feedback-media {
        display: flex;
        gap: 10px;
        margin-top: 10px;
        flex-wrap: wrap;
    }

    .feedback-media img,
    .feedback-media video {
        width: 100px;
        height: 100px;
        object-fit: cover;
        border-radius: 6px;
        border: 1px solid #ddd;
    }

    .feedback-variant {
        font-size: 0.9rem;
        color: #777;
    }
</style>

<div class="container feedback-section">
    <!-- Rating Summary -->
    <c:choose>
        <c:when test="${not empty feedbacks}">
            <div class="rating-summary">
                <div class="rating-score">
                    <c:out value="${avgRatingStr}" /> / 5
                </div>
                <div class="rating-stars">
                    <c:forEach var="i" begin="1" end="${roundedRating}">
                        <i class="fa-solid fa-star"></i>
                    </c:forEach>
                    <c:forEach var="i" begin="${roundedRating + 1}" end="5">
                        <i class="fa-regular fa-star"></i>
                    </c:forEach>
                </div>
                <div class="total-feedback">(<c:out value="${totalFeedbacks}"/> reviews)</div>
            </div>
        </c:when>
    </c:choose>

    <!-- Feedback List -->
    <c:forEach var="fb" items="${feedbacks}">
        <div class="feedback-card">
            <div class="feedback-header">
                <div class="feedback-user">
                    <img src="https://placehold.co/40x40" alt="avatar">
                    <div class="feedback-user-name">
                        <c:out value="${empty fb.customerName ? 'Anonymous' : fb.customerName}" />
                    </div>
                </div>
                <div class="feedback-stars">
                    <c:forEach var="i" begin="1" end="${fb.rating}">
                        <i class="fa-solid fa-star"></i>
                    </c:forEach>
                    <c:forEach var="i" begin="${fb.rating + 1}" end="5">
                        <i class="fa-regular fa-star"></i>
                    </c:forEach>
                </div>
            </div>

            <div class="feedback-time">
                ${fb.creationDate} | <span class="feedback-variant">Variant: ${fb.variantInfo}</span>
            </div>

            <div class="feedback-comment">
                <c:out value="${fb.comments}" />
            </div>

            <!-- Media -->
            <c:if test="${not empty fb.mediaUrls}">
                <div class="feedback-media">
                    <c:forEach var="media" items="${fb.mediaUrls}">
                        <c:choose>
                            <c:when test="${fn:endsWith(media, '.mp4')}">
                                <video controls>
                                    <source src="${media}" type="video/mp4" />
                                </video>
                            </c:when>
                            <c:otherwise>
                                <img src="${media}" alt="feedback media" />
                            </c:otherwise>
                        </c:choose>
                    </c:forEach>
                </div>
            </c:if>
        </div>
    </c:forEach>
</div>
