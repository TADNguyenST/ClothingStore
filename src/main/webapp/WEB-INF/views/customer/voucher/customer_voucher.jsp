<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<html>
<head>
    <title>Customer Vouchers</title>
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Google Fonts: Inter -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;900&display=swap" rel="stylesheet">
    <style>
        /* Applying the Inter font family */
        body {
            font-family: 'Inter', sans-serif;
        }
        /* Custom styles for the ticket-like appearance */
        .ticket-cutout-left {
            position: absolute;
            top: 50%;
            left: -15px;
            transform: translateY(-50%);
            width: 30px;
            height: 30px;
            background-color: #f0f4f8; /* Matches the body background */
            border-radius: 50%;
        }
        .ticket-cutout-right {
            position: absolute;
            top: 50%;
            right: -15px;
            transform: translateY(-50%);
            width: 30px;
            height: 30px;
            background-color: #f0f4f8; /* Matches the body background */
            border-radius: 50%;
        }
    </style>
</head>
<body class="bg-gray-100" style="background-color: #f0f4f8;">
    <div class="container mx-auto px-4 py-12">
        <header class="text-center mb-10">
            <h1 class="text-4xl md:text-5xl font-extrabold text-gray-800 tracking-tight">Your Vouchers</h1>
            <p class="mt-2 text-lg text-gray-500">Here are all the special offers we've sent you.</p>
        </header>
        
        <c:if test="${not empty errorMessage}">
            <div class="bg-red-100 border-l-4 border-red-500 text-red-700 p-4 rounded-md shadow-md text-center" role="alert">
                <p class="font-bold">Error</p>
                <p>${errorMessage}</p>
            </div>
        </c:if>

        <c:if test="${not empty voucherList}">
            <div class="grid grid-cols-1 lg:grid-cols-2 xl:grid-cols-3 gap-8">
                <c:forEach var="voucher" items="${voucherList}">
                    <!-- Only display vouchers that are not used -->
                    <c:if test="${not voucher.isUsed}">
                        <div class="relative bg-white rounded-xl shadow-lg transition-transform duration-300 ease-in-out hover:scale-105 flex flex-col">
                            <!-- Main Content -->
                            <div class="p-6">
                                <div class="flex justify-between items-start">
                                    <h2 class="text-xl font-bold text-gray-800 pr-4">${voucher.voucherName}</h2>
                                    <span class="text-sm font-semibold py-1 px-3 rounded-full bg-green-100 text-green-800">
                                        Available
                                    </span>
                                </div>
                                
                                <div class="flex items-center space-x-2 mt-4 text-sm text-gray-500">
                                    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" /></svg>
                                    <span>Sent on <fmt:formatDate value="${voucher.sentDate}" pattern="dd MMM, yyyy"/></span>
                                </div>
                            </div>

                            <!-- Dashed Separator with Cutouts -->
                            <div class="relative px-6">
                                <div class="border-t-2 border-dashed border-gray-200 w-full"></div>
                                <div class="ticket-cutout-left"></div>
                                <div class="ticket-cutout-right"></div>
                            </div>

                            <!-- Bottom Section with Code and Discount -->
                            <div class="p-6 bg-gray-50 rounded-b-xl flex justify-between items-center">
                                <div class="font-black text-2xl tracking-wider 
                                    <c:choose>
                                        <c:when test="${voucher.discountType == 'Percentage'}">text-purple-600</c:when>
                                        <c:otherwise>text-indigo-600</c:otherwise>
                                    </c:choose>">
                                    <c:choose>
                                        <c:when test="${voucher.discountType == 'Percentage'}">
                                            ${voucher.discountValue}% OFF
                                        </c:when>
                                        <c:otherwise>
                                            <fmt:formatNumber value="${voucher.discountValue}" type="currency" currencyCode="VND" currencySymbol="₫"/>
                                        </c:otherwise>
                                    </c:choose>
                                </div>

                                <button
                                    onclick="copyToClipboard(this, '${voucher.voucherCode}')"
                                    class="bg-gray-200 text-gray-700 font-bold py-2 px-4 rounded-lg hover:bg-gray-300 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 transition-colors duration-200"
                                    title="Copy Code">
                                    <span class="copy-text">${voucher.voucherCode}</span>
                                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 inline-block ml-2 -mt-1 copy-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z" />
                                    </svg>
                                </button>
                            </div>
                        </div>
                    </c:if>
                </c:forEach>
            </div>
        </c:if>

        <c:if test="${empty voucherList and empty errorMessage}">
            <div class="text-center py-16">
                 <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
                    <path vector-effect="non-scaling-stroke" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 13h6m-3-3v6m-9 1V7a2 2 0 012-2h6l2 2h6a2 2 0 012 2v8a2 2 0 01-2 2H5a2 2 0 01-2-2z" />
                </svg>
                <h3 class="mt-2 text-lg font-medium text-gray-900">No Vouchers Found</h3>
                <p class="mt-1 text-sm text-gray-500">It looks like you don't have any vouchers yet. Keep an eye out for new offers!</p>
            </div>
        </c:if>
    </div>

    <script>
        function copyToClipboard(buttonElement, codeToCopy) {
            if (!navigator.clipboard) {
                // Fallback for older browsers
                alert("Clipboard API not available. Please copy manually.");
                return;
            }
            
            navigator.clipboard.writeText(codeToCopy).then(() => {
                const copyTextElement = buttonElement.querySelector('.copy-text');
                const copyIconElement = buttonElement.querySelector('.copy-icon');
                
                // Store original content
                const originalText = copyTextElement.innerHTML;
                const originalIcon = copyIconElement.outerHTML;

                // Change to "Copied!" state
                copyTextElement.textContent = 'Copied!';
                copyIconElement.innerHTML = `<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />`;
                buttonElement.classList.add('bg-green-500', 'text-white');
                buttonElement.classList.remove('bg-gray-200', 'text-gray-700', 'hover:bg-gray-300');

                // Revert after 2 seconds
                setTimeout(() => {
                    copyTextElement.innerHTML = originalText;
                    copyIconElement.outerHTML = originalIcon;
                    buttonElement.classList.remove('bg-green-500', 'text-white');
                    buttonElement.classList.add('bg-gray-200', 'text-gray-700', 'hover:bg-gray-300');
                }, 2000);
            }).catch(err => {
                console.error('Failed to copy text: ', err);
                alert("Failed to copy. Please try again.");
            });
        }
    </script>
</body>
</html>