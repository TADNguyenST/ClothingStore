
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" crossorigin="anonymous">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <title>${requestScope.pageTitle != null ? requestScope.pageTitle : "Voucher List"}</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/admin-dashboard/css/admin-css.css">
    <style>
        body { font-family: Arial, sans-serif; background-color: #f4f4f9; }
        h2 { text-align: center; color: #333; }
        table {
            width: 100%; border-collapse: collapse; margin-top: 20px;
            background-color: #fff; box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        th, td { padding: 12px; text-align: left; border: 1px solid #ddd; }
        th { background-color: #007bff; color: white; }
        tr:nth-child(even) { background-color: #f9f9f9; }
        tr:hover { background-color: #f1f1f1; }
        .no-data { text-align: center; color: #555; padding: 20px; }
        .btn { padding: 6px 12px; text-decoration: none; border-radius: 4px; color: white; font-size: 14px; border: none; cursor: pointer; margin-right: 5px; }
        .btn-add { background-color: #28a745; }
        .btn-add:hover { background-color: #218838; }
        .btn-edit { background-color: #28a745; }
        .btn-edit:hover { background-color: #218838; }
        .btn-delete { background-color: #dc3545; }
        .btn-delete:hover { background-color: #c82333; }
        .btn-detail { background-color: #ffc107; }
        .btn-detail:hover { background-color: #e0a800; }
        .btn-search { background-color: #17a2b8; }
        .btn-search:hover { background-color: #138496; }
        .btn-clear { background-color: #6c757d; }
        .btn-clear:hover { background-color: #5a6268; }
        .error, .success {
            position: fixed; bottom: 20px; right: 20px;
            margin: 10px; padding: 10px; border-radius: 4px;
            z-index: 1000; min-width: 200px; max-width: 300px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.2);
        }
        .error { color: red; background-color: #ffe6e6; }
        .success { color: green; background-color: #e6ffe6; }
        .header-container { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .search-container { text-align: right; }
        .search-container form { display: flex; gap: 10px; align-items: center; }
        .search-input {
            padding: 6px; border: 1px solid #ddd; border-radius: 4px; font-size: 14px; width: 200px;
        }
        .content-area { padding: 20px; }
        .status-indicator {
            display: inline-block;
            width: 10px;
            height: 10px;
            border-radius: 50%;
            margin-right: 5px;
        }
        .status-active { background-color: #28a745; }
        .status-inactive { background-color: #6c757d; }
        .visibility-indicator {
            display: inline-block;
            width: 10px;
            height: 10px;
            border-radius: 50%;
            margin-right: 5px;
        }
        .visibility-visible { background-color: #28a745; }
        .visibility-hidden { background-color: #6c757d; }
        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.5);
            justify-content: center;
            align-items: center;
            z-index: 1000;
        }
        .modal-content {
            background-color: #fff;
            width: 500px;
            max-width: 90%;
            border-radius: 8px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.2);
            padding: 20px;
            position: relative;
            max-height: 80vh;
            overflow-y: auto;
        }
        .modal-close {
            position: absolute;
            top: 10px;
            right: 10px;
            font-size: 20px;
            color: #333;
            cursor: pointer;
            background: none;
            border: none;
        }
        .modal-close:hover {
            color: #dc3545;
        }
        .modal-content h3 {
            margin-top: 0;
            color: #333;
            border-bottom: 1px solid #ddd;
            padding-bottom: 10px;
        }
        .modal-content p {
            margin: 10px 0;
            color: #555;
        }
        .modal-content p strong {
            color: #333;
            display: inline-block;
            width: 150px;
        }

        .status-help-text {
            font-size: 12px;
            color: #666;
            margin-top: 5px;
            display: block;
        }

        .content-area {
        position: relative;
        margin-left: 260px;
        padding: 1.5rem;
        width: calc(100% - 260px);
        transition: all 0.5s ease;
        min-height: 100vh;
    }
    .sidebar.close ~ .content-area {
        margin-left: 88px;
        width: calc(100% - 88px);
    }
    .sidebar.hidden ~ .content-area {
        margin-left: 0;
        width: 100%;
    }

    </style>
</head>
<body>
    <c:set var="currentAction" value="vouchers" scope="request"/>
    <c:set var="currentModule" value="admin" scope="request"/>
    <c:set var="pageTitle" value="Voucher List" scope="request"/>
    <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp" />
    <div class="content-area">
        <div class="header-container">
            <h2>Voucher List</h2>
            <div class="search-container">
                <form action="${pageContext.request.contextPath}/vouchers" method="get" style="display: inline;">
                    <input type="text" name="code" class="search-input" placeholder="Enter voucher code" value="${param.code}">
                    <input type="text" name="name" class="search-input" placeholder="Enter voucher name" value="${param.name}">
                    <button type="submit" class="btn btn-search">Search</button>
                    <a href="${pageContext.request.contextPath}/vouchers" class="btn btn-clear">Clear</a>
                </form>
            </div>
        </div>
        <c:if test="${not empty param.successMessage}">
            <div id="success-message" class="success">${param.successMessage}</div>
        </c:if>
        <c:if test="${not empty param.errorMessage}">
            <div id="error-message" class="error">${param.errorMessage}</div>
        </c:if>
        <div class="add-container">
            <a href="${pageContext.request.contextPath}/addVoucher" class="btn btn-add">Add Voucher</a>
        </div>
        <table>
            <thead>
                <tr>
                    <th>Voucher Code</th>
                    <th>Name</th>
                    <th>Discount Type</th>
                    <th>Discount Value</th>
                    <th>Status</th>
                    <th>Visibility</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${not empty voucherList}">
                        <c:forEach var="voucher" items="${voucherList}">
                            <tr>
                                <td>${voucher.code}</td>
                                <td>${voucher.name}</td>
                                <td>${voucher.discountType}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${voucher.discountType == 'Percentage'}">
                                            <fmt:formatNumber value="${voucher.discountValue}" pattern="#" />%
                                        </c:when>
                                        <c:otherwise>
                                            <fmt:formatNumber value="${voucher.discountValue}" pattern="#" /> $
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <span class="status-indicator ${voucher.isActive ? 'status-active' : 'status-inactive'}"></span>
                                    ${voucher.isActive ? 'Active' : 'Inactive'}
                                    <span class="status-help-text">Auto-updated based on start and expiration dates</span>
                                </td>
                                <td>
                                    <span class="visibility-indicator ${voucher.visibility ? 'visibility-visible' : 'visibility-hidden'}"></span>
                                    ${voucher.visibility ? 'Visible' : 'Hidden'}
                                </td>
                                <td>
                                    <button class="btn btn-detail"
                                            data-voucher-id="${voucher.voucherId}"
                                            data-code="${voucher.code}"
                                            data-name="${voucher.name}"
                                            data-description="${voucher.description != null ? voucher.description : ''}"
                                            data-discount-type="${voucher.discountType}"
                                            data-discount-value="${voucher.discountValue}"
                                            data-minimum-order-amount="${voucher.minimumOrderAmount != null ? voucher.minimumOrderAmount : ''}"
                                            data-maximum-discount-amount="${voucher.maximumDiscountAmount != null ? voucher.maximumDiscountAmount : ''}"
                                            data-usage-limit="${voucher.usageLimit != null ? voucher.usageLimit : ''}"
                                            data-used-count="${voucher.usedCount != null ? voucher.usedCount : ''}"
                                            data-expiration-date="${voucher.expirationDate != null ? voucher.expirationDate : ''}"
                                            data-is-active="${voucher.isActive}"
                                            data-visibility="${voucher.visibility}"
                                            data-created-at="${voucher.createdAt != null ? voucher.createdAt : ''}"
                                            data-start-date="${voucher.startDate != null ? voucher.startDate : ''}"
                                            onclick="showVoucherDetails(this)">Detail</button>
                                    <a href="${pageContext.request.contextPath}/editVoucher?voucherId=${voucher.voucherId}" class="btn btn-edit">Edit</a>
                                    <a href="${pageContext.request.contextPath}/deleteVoucher?voucherId=${voucher.voucherId}" class="btn btn-delete" onclick="return confirm('Are you sure you want to delete this voucher?')">Delete</a>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <tr>
                            <td colspan="7" class="no-data">No vouchers available to display</td>
                        </tr>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
        <div id="voucherModal" class="modal">
            <div class="modal-content">
                <button class="modal-close" onclick="closeModal()">×</button>
                <h3>Voucher Details</h3>
                <p><strong>Voucher ID:</strong> <span id="modal-voucher-id"></span></p>
                <p><strong>Code:</strong> <span id="modal-code"></span></p>
                <p><strong>Name:</strong> <span id="modal-name"></span></p>
                <p><strong>Description:</strong> <span id="modal-description"></span></p>
                <p><strong>Discount Type:</strong> <span id="modal-discount-type"></span></p>
                <p><strong>Discount Value:</strong> <span id="modal-discount-value"></span></p>
                <p><strong>Minimum Order Amount:</strong> <span id="modal-minimum-order-amount"></span></p>
                <p><strong>Maximum Discount Amount:</strong> <span id="modal-maximum-discount-amount"></span></p>
                <p><strong>Usage Limit:</strong> <span id="modal-usage-limit"></span></p>
                <p><strong>Used Count:</strong> <span id="modal-used-count"></span></p>
                <p><strong>Start Date:</strong> <span id="modal-start-date"></span></p>
                <p><strong>Expiration Date:</strong> <span id="modal-expiration-date"></span></p>
                <p><strong>Status:</strong> <span id="modal-is-active"></span> <span class="status-help-text">(Auto-updated based on start and expiration dates)</span></p>
                <p><strong>Visibility:</strong> <span id="modal-visibility"></span></p>
                <p><strong>Created At:</strong> <span id="modal-created-at"></span></p>
            </div>
        </div>
    </div>
    <script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" crossorigin="anonymous"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const currentAction = "${requestScope.currentAction}";
            document.querySelectorAll('.sidebar-menu li.active').forEach(li => li.classList.remove('active'));
            document.querySelectorAll('.sidebar-menu .treeview.menu-open').forEach(treeview => treeview.classList.remove('menu-open'));
            if (currentAction) {
                const activeLink = document.querySelector(`.sidebar-menu a[href*="${currentAction.toLowerCase()}"], .sidebar-menu a[href*="/voucher"]`);
                if (activeLink) {
                    activeLink.parentElement.classList.add('active');
                    const parentTreeview = activeLink.closest('.treeview');
                    if (parentTreeview) {
                        parentTreeview.classList.add('active', 'menu-open');
                    }
                }
            }
            function hideMessages() {
                const successMessage = document.getElementById('success-message');
                const errorMessage = document.getElementById('error-message');
                if (successMessage) {
                    setTimeout(() => {
                        successMessage.style.opacity = '0';
                        successMessage.style.transition = 'opacity 0.5s ease';
                        setTimeout(() => {
                            successMessage.remove();
                        }, 500);
                    }, 3000);
                }
                if (errorMessage) {
                    setTimeout(() => {
                        errorMessage.style.opacity = '0';
                        errorMessage.style.transition = 'opacity 0.5s ease';
                        setTimeout(() => {
                            errorMessage.remove();
                        }, 500);
                    }, 3000);
                }
            }
            hideMessages();
        });
        function showVoucherDetails(button) {
            const modal = document.getElementById('voucherModal');
            const discountValue = button.dataset.discountValue + (button.dataset.discountType === 'Percentage' ? '%' : ' $');
            const isActive = button.dataset.isActive === 'true' ? 'Active' : 'Inactive';
            const visibility = button.dataset.visibility === 'true' ? 'Visible' : 'Hidden';
            document.getElementById('modal-voucher-id').textContent = button.dataset.voucherId;
            document.getElementById('modal-code').textContent = button.dataset.code;
            document.getElementById('modal-name').textContent = button.dataset.name;
            document.getElementById('modal-description').textContent = button.dataset.description || 'N/A';
            document.getElementById('modal-discount-type').textContent = button.dataset.discountType;
            document.getElementById('modal-discount-value').textContent = discountValue;
            document.getElementById('modal-minimum-order-amount').textContent = button.dataset.minimumOrderAmount ? button.dataset.minimumOrderAmount + ' $' : 'N/A';
            document.getElementById('modal-maximum-discount-amount').textContent = button.dataset.maximumDiscountAmount ? button.dataset.maximumDiscountAmount + ' $' : 'N/A';
            document.getElementById('modal-usage-limit').textContent = button.dataset.usageLimit || 'N/A';
            document.getElementById('modal-used-count').textContent = button.dataset.usedCount || 'N/A';
            document.getElementById('modal-start-date').textContent = button.dataset.startDate || 'N/A';
            document.getElementById('modal-expiration-date').textContent = button.dataset.expirationDate || 'N/A';
            document.getElementById('modal-is-active').textContent = isActive;
            document.getElementById('modal-visibility').textContent = visibility;
            document.getElementById('modal-created-at').textContent = button.dataset.createdAt || 'N/A';
            modal.style.display = 'flex';
        }
        function closeModal() {
            document.getElementById('voucherModal').style.display = 'none';
        }
        window.addEventListener('click', function(event) {
            const modal = document.getElementById('voucherModal');
            if (event.target === modal) {
                closeModal();
            }
        });
    </script>
</body>
</html>
