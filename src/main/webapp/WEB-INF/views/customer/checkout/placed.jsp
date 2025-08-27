<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<div class="container py-5 text-center">
    <i class="fas fa-check-circle text-success" style="font-size:64px;"></i>
    <h2 class="mt-3">Order placed successfully!</h2>
    <p class="text-muted">Your order ID: <strong>#${param.placed != null ? param.placed : orderId}</strong></p>
    <a href="${pageContext.request.contextPath}/orders" class="btn btn-primary mt-2">View my orders</a>
    <a href="${pageContext.request.contextPath}/home" class="btn btn-outline-secondary mt-2">Continue shopping</a>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
