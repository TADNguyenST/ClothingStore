
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title>Danh sách Voucher Công khai</title>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
</head>
<body class="bg-gray-100">
    <div class="container mx-auto px-4 py-8">
        <h1 class="text-3xl font-bold mb-6">Danh sách Voucher Công khai</h1>
        
        <!-- Error/Success Messages -->
        <c:if test="${not empty errorMessage}">
            <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
                ${errorMessage}
            </div>
        </c:if>
        <c:if test="${not empty successMessage}">
            <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded mb-4">
                ${successMessage}
            </div>
        </c:if>

        <!-- Search Form -->
        <form action="${pageContext.request.contextPath}/VoucherPublic" method="get" class="mb-6">
            <div class="flex gap-4">
                <input type="text" name="code" placeholder="Tìm kiếm theo mã voucher" 
                       class="border rounded px-4 py-2 w-full">
                <input type="text" name="name" placeholder="Tìm kiếm theo tên voucher" 
                       class="border rounded px-4 py-2 w-full">
                <button type="submit" class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600">
                    Tìm kiếm
                </button>
            </div>
        </form>

        <!-- Voucher List -->
        <div class="bg-white shadow rounded-lg overflow-hidden">
            <table class="min-w-full divide-y divide-gray-200">
                <thead class="bg-gray-50">
                    <tr>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Mã</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Tên</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Loại</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Giá trị</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Hết hạn</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Hành động</th>
                    </tr>
                </thead>
                <tbody class="bg-white divide-y divide-gray-200">
                    <c:forEach var="voucher" items="${voucherList}">
                        <tr>
                            <td class="px-6 py-4 whitespace-nowrap">${voucher.code}</td>
                            <td class="px-6 py-4 whitespace-nowrap">${voucher.name}</td>
                            <td class="px-6 py-4 whitespace-nowrap">${voucher.discountType}</td>
                            <td class="px-6 py-4 whitespace-nowrap">
                                <c:choose>
                                    <c:when test="${voucher.discountType == 'Percentage'}">
                                        ${voucher.discountValue}%
                                    </c:when>
                                    <c:otherwise>
                                        ${voucher.discountValue} VNĐ
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap">
                                <fmt:formatDate value="${voucher.expirationDate}" pattern="dd/MM/yyyy"/>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap flex space-x-2">
                                <button onclick="openVoucherModal(${voucher.voucherId}, '${voucher.code}', '${voucher.name}', '${voucher.description}', '${voucher.discountType}', ${voucher.discountValue}, ${voucher.minimumOrderAmount}, ${voucher.maximumDiscountAmount}, ${voucher.usageLimit}, ${voucher.usedCount}, '${voucher.expirationDate}', ${voucher.isActive}, ${voucher.visibility}, '${voucher.createdAt}')" 
                                        class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600">
                                    Detail
                                </button>
                                <c:choose>
                                    <c:when test="${sessionScope.customerId != null}">
                                        <form action="${pageContext.request.contextPath}/VoucherPublic" method="post">
                                            <input type="hidden" name="voucherId" value="${voucher.voucherId}">
                                            <input type="hidden" name="customerId" value="${sessionScope.customerId}">
                                            <button type="submit" class="bg-green-500 text-white px-4 py-2 rounded hover:bg-green-600">
                                                Lưu Voucher
                                            </button>
                                        </form>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="text-gray-500">Vui lòng đăng nhập để lưu voucher</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty voucherList}">
                        <tr>
                            <td colspan="6" class="px-6 py-4 text-center text-gray-500">
                                Không tìm thấy voucher công khai nào.
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Modal for Voucher Details -->
    <div id="voucherModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center hidden">
        <div class="bg-white rounded-lg shadow-lg p-6 w-full max-w-md">
            <h2 class="text-2xl font-bold mb-4">Chi tiết Voucher</h2>
            <div id="voucherDetails">
                <p><strong>Mã:</strong> <span id="modalCode"></span></p>
                <p><strong>Tên:</strong> <span id="modalName"></span></p>
                <p><strong>Mô tả:</strong> <span id="modalDescription"></span></p>
                <p><strong>Loại giảm giá:</strong> <span id="modalDiscountType"></span></p>
                <p><strong>Giá trị giảm:</strong> <span id="modalDiscountValue"></span></p>
                <p><strong>Đơn hàng tối thiểu:</strong> <span id="modalMinimumOrderAmount"></span> VNĐ</p>
                <p><strong>Giảm tối đa:</strong> <span id="modalMaximumDiscountAmount"></span> VNĐ</p>
                <p><strong>Giới hạn sử dụng:</strong> <span id="modalUsageLimit"></span></p>
                <p><strong>Đã sử dụng:</strong> <span id="modalUsedCount"></span></p>
                <p>< sterke>Ngày hết hạn:</strong> <span id="modalExpirationDate"></span></p>
                <p><strong>Trạng thái:</strong> <span id="modalIsActive"></span></p>
                <p><strong>Hiển thị:</strong> <span id="modalVisibility"></span></p>
                <p><strong>Ngày tạo:</strong> <span id="modalCreatedAt"></span></p>
            </div>
            <div class="mt-6 flex justify-end">
                <button onclick="closeVoucherModal()" class="bg-gray-500 text-white px-4 py-2 rounded hover:bg-gray-600">
                    Đóng
                </button>
            </div>
        </div>
    </div>

    <script>
        function openVoucherModal(id, code, name, description, discountType, discountValue, minimumOrderAmount, maximumDiscountAmount, usageLimit, usedCount, expirationDate, isActive, visibility, createdAt) {
            document.getElementById('modalCode').textContent = code;
            document.getElementById('modalName').textContent = name;
            document.getElementById('modalDescription').textContent = description;
            document.getElementById('modalDiscountType').textContent = discountType;
            document.getElementById('modalDiscountValue').textContent = discountType === 'Percentage' ? discountValue + '%' : discountValue + ' VNĐ';
            document.getElementById('modalMinimumOrderAmount').textContent = minimumOrderAmount ? minimumOrderAmount.toLocaleString() : '0';
            document.getElementById('modalMaximumDiscountAmount').textContent = maximumDiscountAmount ? maximumDiscountAmount.toLocaleString() : 'Không giới hạn';
            document.getElementById('modalUsageLimit').textContent = usageLimit ? usageLimit : 'Không giới hạn';
            document.getElementById('modalUsedCount').textContent = usedCount;
            document.getElementById('modalExpirationDate').textContent = new Date(expirationDate).toLocaleDateString('vi-VN');
            document.getElementById('modalIsActive').textContent = isActive ? 'Hoạt động' : 'Không hoạt động';
            document.getElementById('modalVisibility').textContent = visibility ? 'Công khai' : 'Riêng tư';
            document.getElementById('modalCreatedAt').textContent = new Date(createdAt).toLocaleDateString('vi-VN');
            document.getElementById('voucherModal').classList.remove('hidden');
        }

        function closeVoucherModal() {
            document.getElementById('voucherModal').classList.add('hidden');
        }
    </script>
</body>
</html>
```