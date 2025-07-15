<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<html>
<head>
    <title>Customer Vouchers</title>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
</head>
<body class="bg-gray-100">
    <div class="container mx-auto px-4 py-8">
        <h1 class="text-3xl font-bold mb-6 text-center">Your Vouchers</h1>
        
        <c:if test="${not empty errorMessage}">
            <p class="text-center text-red-600">${errorMessage}</p>
        </c:if>
        
        <c:if test="${not empty voucherList}">
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                <c:forEach var="voucher" items="${voucherList}">
                    <div class="bg-white rounded-lg shadow-md p-6">
                        <h2 class="text-xl font-semibold mb-2">${voucher.voucherName}</h2>
                        <p class="text-gray-600 mb-2"><strong>Code:</strong> ${voucher.voucherCode}</p>
                        <p class="text-gray-600 mb-2"><strong>Discount:</strong> 
                            <c:choose>
                                <c:when test="${voucher.discountType == 'Percentage'}">
                                    ${voucher.discountValue}% off
                                </c:when>
                                <c:otherwise>
                                    <fmt:formatNumber value="${voucher.discountValue}" type="currency" currencySymbol="VNĐ"/>
                                </c:otherwise>
                            </c:choose>
                        </p>
                        <p class="text-gray-600 mb-2"><strong>Sent Date:</strong> 
                            <fmt:formatDate value="${voucher.sentDate}" pattern="dd/MM/yyyy HH:mm"/>
                        </p>
                        <p class="text-gray-600 mb-2"><strong>Status:</strong> 
                            <c:choose>
                                <c:when test="${voucher.isUsed}">
                                    Used <c:if test="${not empty voucher.usedDate}">
                                        on <fmt:formatDate value="${voucher.usedDate}" pattern="dd/MM/yyyy HH:mm"/>
                                    </c:if>
                                </c:when>
                                <c:otherwise>Available</c:otherwise>
                            </c:choose>
                        </p>
                        <c:if test="${voucher.orderId != null}">
                            <p class="text-gray-600"><strong>Order ID:</strong> ${voucher.orderId}</p>
                        </c:if>
                    </div>
                </c:forEach>
            </div>
        </c:if>
        
        <c:if test="${empty voucherList}">
            <p class="text-center text-gray-600">No vouchers available for this customer.</p>
        </c:if>
    </div>
</body>
</html>