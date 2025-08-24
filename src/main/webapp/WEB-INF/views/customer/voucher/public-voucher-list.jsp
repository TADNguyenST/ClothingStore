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
            .error-message, .success-message {
                border-left: 4px solid;
                padding: 1rem;
                margin-bottom: 1.5rem;
                border-radius: 4px;
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
                <div class="row justify-content-center mb-4">
                    <div class="col-lg-8">
                        <c:if test="${not empty errorMessage}">
                            <div class="error-message">
                                <p class="fw-bold mb-1">Error</p>
                                <p>${errorMessage}</p>
                            </div>
                        </c:if>
                        <c:if test="${not empty successMessage}">
                            <div class="success-message">
                                <p class="fw-bold mb-1">Success</p>
                                <p>${successMessage}</p>
                            </div>
                        </c:if>
                    </div>
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
                                                    <fmt:formatNumber value="${voucher.discountValue}" type="currency" currencyCode="VND" currencySymbol="₫" />
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
                                        <div class="d-flex flex-column flex-sm-row gap-2">
                                            <button onclick="openVoucherModal(${voucher.voucherId}, '${voucher.code}', '${voucher.name}', '${voucher.description}', '${voucher.discountType}', ${voucher.discountValue}, ${voucher.minimumOrderAmount}, ${voucher.maximumDiscountAmount}, ${voucher.usageLimit}, ${voucher.usedCount}, '${voucher.expirationDate}', ${voucher.isActive}, ${voucher.visibility}, '${voucher.createdAt}')"
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
                        <p class="text-muted">No public vouchers match your search. Try different keywords or check back later!</p>
                    </div>
                </c:if>
            </div>

            <!-- Modal for Voucher Details -->
            <div class="modal fade" id="voucherModal" tabindex="-1" aria-labelledby="voucherModalLabel" aria-hidden="true">
                <div class="modal-dialog modal-lg">
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
                                                function openVoucherModal(id, code, name, description, discountType, discountValue, minimumOrderAmount, maximumDiscountAmount, usageLimit, usedCount, expirationDate, isActive, visibility, createdAt) {
                                                    document.getElementById('modalCode').textContent = code;
                                                    document.getElementById('modalName').textContent = name || 'N/A';
                                                    document.getElementById('modalDescription').textContent = description || 'No description provided.';
                                                    document.getElementById('modalDiscountType').textContent = discountType;
                                                    document.getElementById('modalDiscountValue').textContent = discountType === 'Percentage' ? discountValue + '%' : new Intl.NumberFormat('vi-VN', {style: 'currency', currency: 'VND'}).format(discountValue);
                                                    document.getElementById('modalMinimumOrderAmount').textContent = minimumOrderAmount ? new Intl.NumberFormat('vi-VN', {style: 'currency', currency: 'VND'}).format(minimumOrderAmount) : 'None';
                                                    document.getElementById('modalMaximumDiscountAmount').textContent = maximumDiscountAmount ? new Intl.NumberFormat('vi-VN', {style: 'currency', currency: 'VND'}).format(maximumDiscountAmount) : 'Unlimited';
                                                    document.getElementById('modalUsageLimit').textContent = usageLimit ? usageLimit.toLocaleString() : 'Unlimited';
                                                    document.getElementById('modalUsedCount').textContent = usedCount.toLocaleString();
                                                    document.getElementById('modalExpirationDate').textContent = new Date(expirationDate).toLocaleDateString('en-GB');
                                                    document.getElementById('modalIsActive').textContent = isActive ? 'Active' : 'Inactive';
                                                    document.getElementById('modalVisibility').textContent = visibility ? 'Public' : 'Private';
                                                    document.getElementById('modalCreatedAt').textContent = new Date(createdAt).toLocaleDateString('en-GB');
                                                    new bootstrap.Modal(document.getElementById('voucherModal')).show();
                                                }
        </script>
    </body>
</html>