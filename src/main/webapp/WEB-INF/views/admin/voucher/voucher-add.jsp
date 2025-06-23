<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${requestScope.pageTitle != null ? requestScope.pageTitle : "Add Voucher"}</title>

    <%-- Link đến thư viện ngoài --%>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">

    <%-- Link đến file CSS dùng chung --%>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/admin-dashboard/css/admin-css.css">

    <%-- CSS nội tuyến cho trang add voucher --%>
    <style>
        body { font-family: Arial, sans-serif; background-color: #f4f4f9; }
        h2 { text-align: center; color: #333; }
        .content-area { padding: 20px; }
        .form-container {
            background-color: #fff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            max-width: 600px;
            margin: 0 auto;
        }
        .form-group { margin-bottom: 15px; }
        .form-group label {
            display: block;
            font-weight: bold;
            margin-bottom: 5px;
            color: #333;
        }
        .form-group input, .form-group select, .form-group textarea {
            width: 100%;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
            box-sizing: border-box;
        }
        .form-group textarea { resize: vertical; min-height: 100px; }
        .form-group input[type="checkbox"] { width: auto; }
        .error, .success {
            text-align: center;
            margin: 10px 0;
            padding: 10px;
            border-radius: 4px;
        }
        .error { color: red; background-color: #ffe6e6; }
        .success { color: green; background-color: #e6ffe6; }
        .btn { padding: 8px 16px; text-decoration: none; border-radius: 4px; color: white; font-size: 14px; border: none; cursor: pointer; margin-right: 10px; }
        .btn-submit { background-color: #28a745; }
        .btn-submit:hover { background-color: #218838; }
        .btn-cancel { background-color: #6c757d; }
        .btn-cancel:hover { background-color: #5a6268; }
        .btn-random { background-color: #17a2b8; }
        .btn-random:hover { background-color: #138496; }
        .help-text {
            font-size: 12px;
            color: #666;
            margin-top: 5px;
            display: block;
        }
        .input-group {
            display: flex;
            gap: 10px;
        }
        .input-group input { flex: 1; }
    </style>
</head>
<body>

    <%-- Đặt các biến requestScope cho sidebar/header --%>
    <c:set var="currentAction" value="addVoucher" scope="request"/>
    <c:set var="currentModule" value="admin" scope="request"/>
    <c:set var="pageTitle" value="Add Voucher" scope="request"/>

    <%-- Nhúng Sidebar --%>
    <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp" />

    <div class="main-content-wrapper">
        <%-- Nhúng Header --%>
        <jsp:include page="/WEB-INF/includes/admin-header.jsp" />

        <%-- Nội dung chính của trang Add Voucher --%>
        <div class="content-area">
            <h2>Add Voucher</h2>
            <c:if test="${not empty param.successMessage}">
                <div class="success">${param.successMessage}</div>
            </c:if>
            <c:if test="${not empty param.errorMessage}">
                <div class="error">${param.errorMessage}</div>
            </c:if>
            <div class="form-container">
                <form action="${pageContext.request.contextPath}/addVoucher" method="post">
                    <div class="form-group">
                        <label for="code">Voucher Code <span style="color: red;">*</span></label>
                        <div class="input-group">
                            <input type="text" id="code" name="code" required placeholder="e.g., SUMMER2025">
                            <button type="button" class="btn btn-random" onclick="generateRandomCode()">Random</button>
                        </div>
                        <span class="help-text">Enter a unique code (e.g., SUMMER2025 or DISCOUNT10) or click Random to generate one.</span>
                    </div>
                    <div class="form-group">
                        <label for="name">Name <span style="color: red;">*</span></label>
                        <input type="text" id="name" name="name" required placeholder="e.g., Summer Sale Voucher">
                        <span class="help-text">Provide a descriptive name for the voucher.</span>
                    </div>
                    <div class="form-group">
                        <label for="description">Description</label>
                        <textarea id="description" name="description" placeholder="e.g., 10% off for orders above $50"></textarea>
                        <span class="help-text">Optional: Describe the voucher's purpose or conditions.</span>
                    </div>
                    <div class="form-group">
                        <label for="discountType">Discount Type <span style="color: red;">*</span></label>
                        <select id="discountType" name="discountType" required>
                            <option value="" disabled selected>Select a discount type</option>
                            <option value="Percentage">Percentage</option>
                            <option value="Fixed">Fixed</option>
                        </select>
                        <span class="help-text">Choose whether the discount is a percentage or fixed amount.</span>
                    </div>
                    <div class="form-group">
                        <label for="discountValue">Discount Value <span style="color: red;">*</span></label>
                        <input type="number" id="discountValue" name="discountValue" step="0.01" min="0" required placeholder="e.g., 10">
                        <span class="help-text">Enter the discount amount (e.g., 10 for 10% or $10).</span>
                    </div>
                    <div class="form-group">
                        <label for="minimumOrderAmount">Minimum Order Amount</label>
                        <input type="number" id="minimumOrderAmount" name="minimumOrderAmount" step="0.01" min="0" placeholder="e.g., 50">
                        <span class="help-text">Optional: Minimum order value to apply the voucher (e.g., $50).</span>
                    </div>
                    <div class="form-group">
                        <label for="maximumDiscountAmount">Maximum Discount Amount</label>
                        <input type="number" id="maximumDiscountAmount" name="maximumDiscountAmount" step="0.01" min="0" placeholder="e.g., 20">
                        <span class="help-text">Optional: Maximum discount cap for percentage-based vouchers (e.g., $20).</span>
                    </div>
                    <div class="form-group">
                        <label for="usageLimit">Usage Limit</label>
                        <input type="number" id="usageLimit" name="usageLimit" min="0" placeholder="e.g., 100">
                        <span class="help-text">Optional: Maximum number of times the voucher can be used.</span>
                    </div>
                    <div class="form-group">
                        <label for="expirationDate">Expiration Date</label>
                        <input type="date" id="expirationDate" name="expirationDate" placeholder="e.g., 2025-12-31">
                        <span class="help-text">Optional: Date when the voucher expires (YYYY-MM-DD).</span>
                    </div>
                    <div class="form-group">
                        <label for="isActive">Active</label>
                        <input type="checkbox" id="isActive" name="isActive" checked>
                        <span class="help-text">Check to make the voucher active immediately.</span>
                    </div>
                    <div class="form-group">
                        <button type="submit" class="btn btn-submit">Save</button>
                        <a href="${pageContext.request.contextPath}/vouchers" class="btn btn-cancel">Cancel</a>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <%-- Link đến file JS dùng chung --%>
    <script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>

    <%-- Phần JS để active menu, client-side validation, và random code --%>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Active menu logic
            const currentAction = "${requestScope.currentAction}";
            const currentModule = "${requestScope.currentModule}";

            document.querySelectorAll('.sidebar-menu li.active').forEach(li => li.classList.remove('active'));
            document.querySelectorAll('.sidebar-menu .treeview.menu-open').forEach(li => li.classList.remove('menu-open'));

            if (currentAction && currentModule) {
                const activeLink = document.querySelector(`.sidebar-menu a[href*="${currentAction}"][href*="${currentModule}"]`);
                if (activeLink) {
                    activeLink.parentElement.classList.add('active');
                    const parentTreeview = activeLink.closest('.treeview');
                    if (parentTreeview) {
                        parentTreeview.classList.add('active');
                        parentTreeview.classList.add('menu-open');
                    }
                } else {
                    console.warn('No matching link found for currentAction and currentModule');
                }
            }

            // Client-side form validation
            document.querySelector('form').addEventListener('submit', function(e) {
                const code = document.getElementById('code').value.trim();
                const name = document.getElementById('name').value.trim();
                const discountValue = document.getElementById('discountValue').value;
                const discountType = document.getElementById('discountType').value;

                if (!code) {
                    alert('Voucher Code is required.');
                    e.preventDefault();
                    return;
                }
                if (!name) {
                    alert('Name is required.');
                    e.preventDefault();
                    return;
                }
                if (!discountType) {
                    alert('Discount Type is required.');
                    e.preventDefault();
                    return;
                }
                if (!discountValue || discountValue <= 0) {
                    alert('Discount Value must be greater than 0.');
                    e.preventDefault();
                    return;
                }
            });
        });

        // Random code generation
        function generateRandomCode() {
            const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
            const codeLength = 10;
            let randomCode = '';
            for (let i = 0; i < codeLength; i++) {
                const randomIndex = Math.floor(Math.random() * characters.length);
                randomCode += characters[randomIndex];
            }
            document.getElementById('code').value = randomCode;
        }
    </script>
</body>
</html>