<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title>Public Voucher List</title>
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
    </style>
</head>
<body class="bg-gray-50">
    <div class="container mx-auto px-4 sm:px-6 lg:px-8 py-12">

        <!-- Header -->
        <header class="text-center mb-6">
            <h1 class="text-4xl md:text-5xl font-extrabold text-gray-900 tracking-tight">Public Vouchers</h1>
            <p class="mt-2 text-lg text-gray-600">Discover and save our latest offers!</p>
        </header>

        <!-- Login/Logout Section -->
        <div class="text-center mb-8">
            <c:choose>
                <c:when test="${not empty sessionScope.userId}">
                    <span class="text-gray-700">Welcome, User #${sessionScope.userId}</span>
                    <a href="${pageContext.request.contextPath}/logout" class="ml-4 inline-block bg-red-500 text-white font-semibold px-4 py-2 rounded-lg shadow-md hover:bg-red-600 transition-colors">Logout</a>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/Login" class="bg-blue-600 text-white font-semibold px-6 py-2 rounded-lg shadow-md hover:bg-blue-700 transition-colors">Login to Save Vouchers</a>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- Error/Success Messages -->
        <div class="max-w-4xl mx-auto mb-8 space-y-4">
            <c:if test="${not empty errorMessage}">
                <div class="bg-red-100 border-l-4 border-red-500 text-red-700 p-4 rounded-md shadow" role="alert">
                    <p class="font-bold">Error</p>
                    <p>${errorMessage}</p>
                </div>
            </c:if>
            <c:if test="${not empty successMessage}">
                <div class="bg-green-100 border-l-4 border-green-500 text-green-700 p-4 rounded-md shadow" role="alert">
                    <p class="font-bold">Success</p>
                    <p>${successMessage}</p>
                </div>
            </c:if>
        </div>

        <!-- Search Form -->
        <form action="${pageContext.request.contextPath}/VoucherPublic" method="get" class="mb-10 max-w-4xl mx-auto p-6 bg-white rounded-xl shadow-md">
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4 items-end">
                <div class="md:col-span-1">
<label for="code" class="block text-sm font-medium text-gray-700 mb-1">Voucher Code</label>
                    <input type="text" id="code" name="code" placeholder="e.g., SALE50"
                           class="border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 block w-full" value="${param.code}">
                </div>
                <div class="md:col-span-1">
                    <label for="name" class="block text-sm font-medium text-gray-700 mb-1">Voucher Name</label>
                    <input type="text" id="name" name="name" placeholder="e.g., Summer Sale"
                           class="border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 block w-full" value="${param.name}">
                </div>
                <button type="submit" class="w-full md:w-auto bg-blue-600 text-white px-6 py-2 rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 font-semibold shadow-sm">
                    Search
                </button>
            </div>
        </form>

        <!-- Voucher Grid -->
        <c:if test="${not empty voucherList}">
            <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-8">
                <c:forEach var="voucher" items="${voucherList}">
                    <div class="bg-white rounded-xl shadow-lg transition-transform duration-300 hover:scale-105 flex flex-col overflow-hidden">
                        <!-- Card Header -->
                        <div class="p-6">
                            <h3 class="text-xl font-bold text-gray-800">${voucher.name}</h3>
                            <p class="text-sm text-gray-500 mt-1">Code: <span class="font-semibold text-gray-600">${voucher.code}</span></p>
                        </div>

                        <!-- Discount Info -->
                        <div class="bg-blue-50 p-6 flex-grow text-center flex items-center justify-center">
                            <div class="font-black text-4xl text-blue-600 tracking-wider">
                                <c:choose>
                                    <c:when test="${voucher.discountType == 'Percentage'}">
                                        ${voucher.discountValue}% <span class="text-2xl">OFF</span>
                                    </c:when>
                                    <c:otherwise>
                                       <fmt:formatNumber value="${voucher.discountValue}" type="currency" currencyCode="VND" currencySymbol="₫" />
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                        
                        <!-- Expiry and Actions -->
                        <div class="p-6 bg-gray-100">
                             <div class="flex items-center space-x-2 text-sm text-red-600 font-medium mb-4">
<svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-12a1 1 0 10-2 0v4a1 1 0 00.293.707l2.828 2.829a1 1 0 101.414-1.415L11 9.586V6z" clip-rule="evenodd" /></svg>
                                <span>Expires on: <fmt:formatDate value="${voucher.expirationDate}" pattern="dd MMM, yyyy"/></span>
                            </div>
                            <div class="flex flex-col sm:flex-row gap-3">
                                <button onclick="openVoucherModal(${voucher.voucherId}, '${voucher.code}', '${voucher.name}', '${voucher.description}', '${voucher.discountType}', ${voucher.discountValue}, ${voucher.minimumOrderAmount}, ${voucher.maximumDiscountAmount}, ${voucher.usageLimit}, ${voucher.usedCount}, '${voucher.expirationDate}', ${voucher.isActive}, ${voucher.visibility}, '${voucher.createdAt}')"
                                        class="w-full text-center bg-gray-200 text-gray-800 font-semibold py-2 px-4 rounded-lg hover:bg-gray-300 transition-colors">
                                    Details
                                </button>
                                <c:choose>
                                    <c:when test="${not empty sessionScope.userId}">
                                        <form action="${pageContext.request.contextPath}/VoucherPublic" method="post" class="w-full">
                                            <input type="hidden" name="voucherId" value="${voucher.voucherId}">
                                            <button type="submit" class="w-full bg-green-500 text-white font-semibold py-2 px-4 rounded-lg hover:bg-green-600 transition-colors">
                                                Save Voucher
                                            </button>
                                        </form>
                                    </c:when>
                                    <c:otherwise>
                                        <a href="${pageContext.request.contextPath}/Login" class="w-full text-center bg-gray-500 text-white font-semibold py-2 px-4 rounded-lg hover:bg-gray-600 transition-colors">
                                            Login to Save
                                        </a>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </c:if>

        <c:if test="${empty voucherList}">
            <div class="text-center py-16">
                 <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
                    <path vector-effect="non-scaling-stroke" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0zM10 7v3m0 0v3m0-3h3m-3 0H7" />
</svg>
                <h3 class="mt-2 text-lg font-medium text-gray-900">No Vouchers Found</h3>
                <p class="mt-1 text-sm text-gray-500">No public vouchers match your search. Try different keywords or check back later!</p>
            </div>
        </c:if>

    </div>

    <!-- Modal for Voucher Details -->
    <div id="voucherModal" class="fixed inset-0 bg-gray-800 bg-opacity-75 flex items-center justify-center hidden z-50">
        <div class="bg-white rounded-lg shadow-xl p-6 m-4 w-full max-w-lg relative" onclick="event.stopPropagation()">
            <button onclick="closeVoucherModal()" class="absolute top-3 right-3 text-gray-400 hover:text-gray-600">
                 <svg class="h-6 w-6" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" /></svg>
            </button>
            <h2 class="text-2xl font-bold mb-4 text-gray-800">Voucher Details</h2>
            <div id="voucherDetails" class="space-y-2 text-gray-700">
                <p><strong>Code:</strong> <span id="modalCode" class="font-mono bg-gray-100 px-2 py-1 rounded"></span></p>
                <p><strong>Name:</strong> <span id="modalName"></span></p>
                <p><strong>Description:</strong> <span id="modalDescription"></span></p>
                <p><strong>Discount Type:</strong> <span id="modalDiscountType"></span></p>
                <p><strong>Discount Value:</strong> <span id="modalDiscountValue" class="font-bold text-blue-600"></span></p>
                <p><strong>Minimum Order:</strong> <span id="modalMinimumOrderAmount"></span></p>
                <p><strong>Maximum Discount:</strong> <span id="modalMaximumDiscountAmount"></span></p>
                <p><strong>Usage Limit:</strong> <span id="modalUsageLimit"></span></p>
                <p><strong>Times Used:</strong> <span id="modalUsedCount"></span></p>
                <p><strong>Expires On:</strong> <span id="modalExpirationDate"></span></p>
                <p><strong>Status:</strong> <span id="modalIsActive"></span></p>
                <p><strong>Visibility:</strong> <span id="modalVisibility"></span></p>
                <p><strong>Created On:</strong> <span id="modalCreatedAt"></span></p>
            </div>
            <div class="mt-6 flex justify-end">
                <button onclick="closeVoucherModal()" class="bg-gray-500 text-white px-4 py-2 rounded-lg hover:bg-gray-600">
                    Close
                </button>
            </div>
        </div>
    </div>

    <script>
        const modal = document.getElementById('voucherModal');

        function openVoucherModal(id, code, name, description, discountType, discountValue, minimumOrderAmount, maximumDiscountAmount, usageLimit, usedCount, expirationDate, isActive, visibility, createdAt) {
            document.getElementById('modalCode').textContent = code;
document.getElementById('modalName').textContent = name || 'N/A';
            document.getElementById('modalDescription').textContent = description || 'No description provided.';
            document.getElementById('modalDiscountType').textContent = discountType;
            document.getElementById('modalDiscountValue').textContent = discountType === 'Percentage' ? discountValue + '%' : new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(discountValue);
            document.getElementById('modalMinimumOrderAmount').textContent = minimumOrderAmount ? new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(minimumOrderAmount) : 'None';
            document.getElementById('modalMaximumDiscountAmount').textContent = maximumDiscountAmount ? new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(maximumDiscountAmount) : 'Unlimited';
            document.getElementById('modalUsageLimit').textContent = usageLimit ? usageLimit.toLocaleString() : 'Unlimited';
            document.getElementById('modalUsedCount').textContent = usedCount.toLocaleString();
            document.getElementById('modalExpirationDate').textContent = new Date(expirationDate).toLocaleDateString('en-GB');
            document.getElementById('modalIsActive').textContent = isActive ? 'Active' : 'Inactive';
            document.getElementById('modalVisibility').textContent = visibility ? 'Public' : 'Private';
            document.getElementById('modalCreatedAt').textContent = new Date(createdAt).toLocaleDateString('en-GB');
            modal.classList.remove('hidden');
        }

        function closeVoucherModal() {
            modal.classList.add('hidden');
        }
        
        // Close modal if backdrop is clicked
        modal.addEventListener('click', (event) => {
            if (event.target === modal) {
                closeVoucherModal();
            }
        });

    </script>
</body>
</html>
