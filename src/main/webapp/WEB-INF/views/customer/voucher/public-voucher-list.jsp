<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>ClothingStore - Public Voucher List</title>
        <!-- Bootstrap CSS -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <!-- Font Awesome -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
        <!-- Google Fonts: Jost -->
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Jost:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <!-- Custom Styles -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
        <style>
            body {
                font-family: 'Jost', sans-serif;
            }
            .voucher-card {
                border: 1px solid #eee;
                border-radius: 8px;
                overflow: hidden;
                transition: transform 0.3s ease, box-shadow 0.3s ease;
            }
            .voucher-card:hover {
                transform: scale(1.05);
                box-shadow: 0 8px 20px rgba(0,0,0,0.1);
            }
            .voucher-header {
                padding: 1.5rem;
                background-color: #fff;
            }
            .voucher-discount {
                padding: 1.5rem;
                background-color: #e7f3ff;
                text-align: center;
            }
            .voucher-footer {
                padding: 1.5rem;
                background-color: #f8f9fa;
            }
            .voucher-title {
                font-size: 1.25rem;
                font-weight: 600;
                color: #333;
            }
            .voucher-code {
                font-size: 0.9rem;
                color: #666;
            }
            .voucher-discount-value {
                font-size: 2.25rem;
                font-weight: 700;
                color: #0d6efd;
            }
            .voucher-expiry {
                font-size: 0.85rem;
                color: #dc3545;
            }
            .voucher-status {
                font-size: 0.85rem;
            }
            .status-active {
                color: #28a745;
            }
            .status-inactive {
                color: #dc3545;
            }
            .error-message, .success-message {
                position: fixed;
                bottom: 20px;
                right: 20px;
                width: 300px; /* Suitable size */
                max-width: 90%; /* Limit for small screens */
                padding: 0.75rem 1rem;
                border-left: 4px solid;
                border-radius: 4px;
                box-shadow: 0 4px 8px rgba(0,0,0,0.1);
                z-index: 1050; /* Ensure notifications appear above other elements */
            }
            .error-message {
                background-color: #f8d7da;
                border-color: #dc3545;
                color: #721c24;
            }
            .success-message {
                background-color: #d4edda;
                border-color: #28a745;
                color: #155724;
            }
            .modal-content {
                border-radius: 0;
                border: 1px solid #eee;
                box-shadow: 0 10px 20px rgba(0,0,0,0.05);
            }
            .modal-body {
                padding: 1rem; /* Reduced padding for smaller modal */
            }
            .modal-body p {
                font-size: 0.9rem; /* Smaller font size */
                margin-bottom: 0.5rem; /* Reduced spacing between lines */
            }
            .modal-header, .modal-footer {
                padding: 0.75rem; /* Reduced padding */
            }
            .modal-title {
                font-size: 1.1rem; /* Smaller title */
            }
            .fade-out {
                animation: fadeOut 1s ease-in-out forwards;
            }
            @keyframes fadeOut {
                0% { opacity: 1; }
                100% { opacity: 0; display: none; }
            }
        </style>
    </head>
    <body class="d-flex flex-column min-vh-100">
        <!-- Include Header -->
        <jsp:include page="/WEB-INF/views/common/header.jsp" />
        <!-- Main Content -->
        <main class="flex-grow-1">
            <div class="container my-5 py-5">
                <!-- Header -->
                <header class="text-center mb-4">
                    <h1 class="display-4 fw-bold">Public Vouchers</h1>
                    <p class="lead text-muted">Discover and save our latest offers!</p>
                </header>
                <!-- Error/Success Messages -->
                <div class="position-fixed bottom-0 end-0 p-3" style="z-index: 1050;">
                    <c:if test="${not empty errorMessage}">
                        <div class="error-message temp-message" id="errorMessage">
                            <p class="fw-bold mb-1 fs-6">Error</p>
                            <p class="mb-0 fs-6">${errorMessage}</p>
                            <button type="button" class="btn-close position-absolute top-0 end-0 m-2" onclick="this.parentElement.remove()"></button>
                        </div>
                    </c:if>
                    <c:if test="${not empty successMessage}">
                        <div class="success-message temp-message" id="successMessage">
                            <p class="fw-bold mb-1 fs-6">Success</p>
                            <p class="mb-0 fs-6">${successMessage}</p>
                            <button type="button" class="btn-close position-absolute top-0 end-0 m-2" onclick="this.parentElement.remove()"></button>
                        </div>
                    </c:if>
                </div>
                <!-- Search Form -->
                <form action="${pageContext.request.contextPath}/VoucherPublic" method="get" class="mb-5">
                    <div class="row g-3 justify-content-center">
                        <div class="col-lg-4 col-md-6">
                            <label for="code" class="form-label">Voucher Code</label>
                            <input type="text" id="code" name="code" placeholder="e.g., SALE50" class="form-control" value="${param.code}">
                        </div>
                        <div class="col-lg-4 col-md-6">
                            <label for="name" class="form-label">Voucher Name</label>
                            <input type="text" id="name" name="name" placeholder="e.g., Summer Sale" class="form-control" value="${param.name}">
                        </div>
                        <div class="col-auto align-self-end">
                            <button type="submit" class="btn btn-primary">Search</button>
                        </div>
                    </div>
                </form>
                <!-- Voucher Grid -->
                <c:if test="${not empty voucherList}">
                    <div class="row row-cols-1 row-cols-md-2 row-cols-lg-3 g-4">
                        <c:forEach var="voucher" items="${voucherList}">
                            <div class="col">
                                <div class="voucher-card">
                                    <!-- Card Header -->
                                    <div class="voucher-header">
                                        <h3 class="voucher-title">${voucher.name}</h3>
                                        <p class="voucher-code">Code: <span class="fw-semibold">${voucher.code}</span></p>
                                    </div>
                                    <!-- Discount Info -->
                                    <div class="voucher-discount">
                                        <div class="voucher-discount-value">
                                            <c:choose>
                                                <c:when test="${voucher.discountType == 'Percentage'}">
                                                    ${voucher.discountValue}% <span class="fs-4">OFF</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <fmt:formatNumber value="${voucher.discountValue}" type="number" pattern="#,##0" /> VND
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                    <!-- Expiry and Actions -->
                                    <div class="voucher-footer">
                                        <div class="d-flex align-items-center mb-3 voucher-expiry">
                                            <i class="fas fa-clock me-2"></i>
                                            <span>Expires on: <fmt:formatDate value="${voucher.expirationDate}" pattern="dd MMM, yyyy"/></span>
                                        </div>
                                        <div class="d-flex align-items-center mb-3 voucher-status">
                                            <i class="fas fa-check-circle me-2 ${voucher.isActive ? 'status-active' : 'status-inactive'}"></i>
                                            <span>Status: <span class="${voucher.isActive ? 'status-active' : 'status-inactive'}">${voucher.isActive ? 'Active' : 'Inactive'}</span></span>
                                        </div>
                                        <div class="d-flex flex-column flex-sm-row gap-2">
                                            <button onclick="openVoucherModal(${voucher.voucherId}, '${voucher.code}', '${voucher.name}', '${voucher.description}', '${voucher.discountType}', ${voucher.discountValue}, ${voucher.minimumOrderAmount}, ${voucher.maximumDiscountAmount}, ${voucher.usageLimit}, ${voucher.usedCount}, '${voucher.expirationDate}', ${voucher.isActive}, ${voucher.visibility}, '${voucher.createdAt}', '${voucher.startDate}')"
                                                    class="btn btn-outline-secondary w-100">
                                                Details
                                            </button>
                                            <c:if test="${not empty sessionScope.userId}">
                                                <form action="${pageContext.request.contextPath}/VoucherPublic" method="post" class="w-100">
                                                    <input type="hidden" name="voucherId" value="${voucher.voucherId}">
                                                    <button type="submit" class="btn btn-success w-100">Save Voucher</button>
                                                </form>
                                            </c:if>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:if>
                <c:if test="${empty voucherList}">
                    <div class="text-center py-5">
                        <i class="fas fa-search fa-3x text-muted mb-3"></i>
                        <h3 class="h4 fw-medium">No Vouchers Found</h3>
                        <p class="text-muted">No public vouchers match your search. Try different keywords or check back later.!</p>
                    </div>
                </c:if>
            </div>
            <!-- Modal for Voucher Details -->
            <div class="modal fade" id="voucherModal" tabindex="-1" aria-labelledby="voucherModalLabel" aria-hidden="true">
                <div class="modal-dialog modal-md"> <!-- Changed from modal-lg to modal-md -->
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title" id="voucherModalLabel">Voucher Details</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body">
                            <div id="voucherDetails">
                                <p><strong>Code:</strong> <span id="modalCode" class="font-monospace bg-light p-1 rounded"></span></p>
                                <p><strong>Name:</strong> <span id="modalName"></span></p>
                                <p><strong>Description:</strong> <span id="modalDescription"></span></p>
                                <p><strong>Discount Type:</strong> <span id="modalDiscountType"></span></p>
                                <p><strong>Discount Value:</strong> <span id="modalDiscountValue" class="fw-bold text-primary"></span></p>
                                <p><strong>Minimum Order:</strong> <span id="modalMinimumOrderAmount"></span></p>
                                <p><strong>Maximum Discount:</strong> <span id="modalMaximumDiscountAmount"></span></p>
                                <p><strong>Usage Limit:</strong> <span id="modalUsageLimit"></span></p>
                                <p><strong>Times Used:</strong> <span id="modalUsedCount"></span></p>
                                <p><strong>Start Date:</strong> <span id="modalStartDate"></span></p>
                                <p><strong>Expires On:</strong> <span id="modalExpirationDate"></span></p>
                                <p><strong>Status:</strong> <span id="modalIsActive"></span></p>
                                <p><strong>Visibility:</strong> <span id="modalVisibility"></span></p>
                                <p><strong>Created On:</strong> <span id="modalCreatedAt"></span></p>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                        </div>
                    </div>
                </div>
            </div>
        </main>
        <!-- Scripts -->
        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <script>
            function openVoucherModal(id, code, name, description, discountType, discountValue, minimumOrderAmount, maximumDiscountAmount, usageLimit, usedCount, expirationDate, isActive, visibility, createdAt, startDate) {
                document.getElementById('modalCode').textContent = code;
                document.getElementById('modalName').textContent = name || 'N/A';
                document.getElementById('modalDescription').textContent = description || 'No description provided.';
                document.getElementById('modalDiscountType').textContent = discountType;
                document.getElementById('modalDiscountValue').textContent = discountType === 'Percentage' ? discountValue + '%' : new Intl.NumberFormat('vi-VN', {minimumFractionDigits: 0, maximumFractionDigits: 0}).format(discountValue) + ' VND';
                document.getElementById('modalMinimumOrderAmount').textContent = minimumOrderAmount ? new Intl.NumberFormat('vi-VN', {minimumFractionDigits: 0, maximumFractionDigits: 0}).format(minimumOrderAmount) + ' VND' : 'None';
                document.getElementById('modalMaximumDiscountAmount').textContent = maximumDiscountAmount ? new Intl.NumberFormat('vi-VN', {minimumFractionDigits: 0, maximumFractionDigits: 0}).format(maximumDiscountAmount) + ' VND' : 'Unlimited';
                document.getElementById('modalUsageLimit').textContent = usageLimit ? usageLimit.toLocaleString() : 'Unlimited';
                document.getElementById('modalUsedCount').textContent = usedCount.toLocaleString();
                document.getElementById('modalStartDate').textContent = new Date(startDate).toLocaleDateString('en-GB');
                document.getElementById('modalExpirationDate').textContent = new Date(expirationDate).toLocaleDateString('en-GB');
                document.getElementById('modalIsActive').textContent = isActive ? 'Active' : 'Inactive';
                document.getElementById('modalVisibility').textContent = visibility ? 'Public' : 'Private';
                document.getElementById('modalCreatedAt').textContent = new Date(createdAt).toLocaleDateString('en-GB');
                new bootstrap.Modal(document.getElementById('voucherModal')).show();
            }
            // Automatically hide notifications after 2 seconds
            document.addEventListener('DOMContentLoaded', function() {
                const messages = document.querySelectorAll('.temp-message');
                messages.forEach(function(message) {
                    setTimeout(function() {
                        message.classList.add('fade-out');
                        // Remove element after animation completes
                        setTimeout(function() {
                            message.remove();
                        }, 1000); // Matches the fadeOut animation duration (1 second)
                    }, 2000); // Display for 2 seconds before starting fade-out
                });
            });
        </script>
    </body>
</html>