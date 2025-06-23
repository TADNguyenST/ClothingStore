<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${requestScope.pageTitle != null ? requestScope.pageTitle : "Edit Voucher"}</title>

    <%-- Link đến thư viện ngoài --%>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">

    <%-- Link đến file CSS dùng chung --%>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/admin-dashboard/css/admin-css.css">

    <%-- CSS nội tuyến cho trang edit voucher --%>
    <style>
        body { font-family: Arial, sans-serif; background-color: #f4f4f9; }
        h2 { text-align: center; color: #333; }
        .content-area { padding: 20px; }
        .form-container {
            max-width: 600px; margin: 0 auto; background-color: #fff;
            padding: 20px; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        .form-group { margin-bottom: 15px; }
        .form-group label {
            display: block; font-weight: bold; margin-bottom: 5px; color: #333;
        }
        .form-group input, .form-group select, .form-group textarea {
            width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px; font-size: 14px; box-sizing: border-box;
        }
        .form-group input[readonly] {
            background-color: #f8f9fa; cursor: not-allowed; color: #666;
        }
        .form-group textarea { resize: vertical; min-height: 100px; }
        .form-group input[type="checkbox"] { width: auto; }
        .error, .success {
            text-align: center; margin: 10px 0; padding: 10px; border-radius: 4px;
        }
        .error { color: red; background-color: #ffe6e6; }
        .success { color: green; background-color: #e6ffe6; }
        .btn {
            padding: 8px 16px; text-decoration: none; border-radius: 4px; color: white;
            font-size: 14px; border: none; cursor: pointer; margin-right: 10px;
        }
        .btn-submit { background-color: #28a745; }
        .btn-submit:hover { background-color: #218838; }
        .btn-cancel { background-color: #6c757d; }
        .btn-cancel:hover { background-color: #5a6268; }
        .help-text {
            font-size: 12px; color: #666; margin-top: 5px; display: block;
        }
        .error-text {
            font-size: 12px; color: red; margin-top: 5px; display: block;
        }
    </style>
</head>
<body>

    <%-- Đặt các biến requestScope cho sidebar/header --%>
    <c:set var="currentAction" value="vouchers" scope="request"/>
    <c:set var="currentModule" value="admin" scope="request"/>
    <c:set var="pageTitle" value="Edit Voucher" scope="request"/>

    <%-- Nhúng Sidebar --%>
    <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp" />

    <div class="main-content-wrapper">
        <%-- Nhúng Header --%>
        <jsp:include page="/WEB-INF/includes/admin-header.jsp" />

        <%-- Nội dung chính của trang Edit Voucher --%>
        <div class="content-area">
            <h2>Edit Voucher</h2>
            <c:if test="${not empty param.successMessage}">
                <div class="success">${param.successMessage}</div>
            </c:if>
            <c:if test="${not empty param.errorMessage}">
                <div class="error">${param.errorMessage}</div>
            </c:if>
            <div class="form-container">
                <form action="${pageContext.request.contextPath}/editVoucher" method="post" id="voucherForm">
                    <input type="hidden" name="voucherId" value="${voucher.voucherId}"/>
                    <div class="form-group">
                        <label for="code">Voucher Code <span style="color: red;">*</span></label>
                        <input type="text" id="code" name="code" value="${voucher.code}" readonly>
                        <span class="help-text">The voucher code cannot be changed.</span>
                        <span class="error-text" id="codeError"></span>
                    </div>
                    <div class="form-group">
                        <label for="name">Voucher Name <span style="color: red;">*</span></label>
                        <input type="text" id="name" name="name" value="${voucher.name}" required placeholder="e.g., Summer Sale Voucher">
                        <span class="help-text">Provide a descriptive name for the voucher.</span>
                        <span class="error-text" id="nameError"></span>
                    </div>
                    <div class="form-group">
                        <label for="description">Description</label>
                        <textarea id="description" name="description" placeholder="e.g., 10% off for orders above $50">${voucher.description}</textarea>
                        <span class="help-text">Optional: Describe the voucher's purpose or conditions.</span>
                        <span class="error-text" id="descriptionError"></span>
                    </div>
                    <div class="form-group">
                        <label for="discountType">Discount Type <span style="color: red;">*</span></label>
                        <select id="discountType" name="discountType" required>
                            <option value="" disabled>Select a discount type</option>
                            <option value="Percentage" ${voucher.discountType == 'Percentage' ? 'selected' : ''}>Percentage</option>
                            <option value="Fixed" ${voucher.discountType == 'Fixed' ? 'selected' : ''}>Fixed</option>
                        </select>
                        <span class="help-text">Choose whether the discount is a percentage or fixed amount.</span>
                        <span class="error-text" id="discountTypeError"></span>
                    </div>
                    <div class="form-group">
                        <label for="discountValue">Discount Value <span style="color: red;">*</span></label>
                        <input type="number" id="discountValue" name="discountValue" step="0.01" min="0" value="${voucher.discountValue}" required placeholder="e.g., 10">
                        <span class="help-text">Enter the discount amount (e.g., 10 for 10% or $10).</span>
                        <span class="error-text" id="discountValueError"></span>
                    </div>
                    <div class="form-group">
                        <label for="minimumOrderAmount">Minimum Order Amount</label>
                        <input type="number" id="minimumOrderAmount" name="minimumOrderAmount" step="0.01" min="0" value="${voucher.minimumOrderAmount}" placeholder="e.g., 50">
                        <span class="help-text">Optional: Minimum order value to apply the voucher (e.g., $50).</span>
                        <span class="error-text" id="minimumOrderAmountError"></span>
                    </div>
                    <div class="form-group">
                        <label for="maximumDiscountAmount">Maximum Discount Amount</label>
                        <input type="number" id="maximumDiscountAmount" name="maximumDiscountAmount" step="0.01" min="0" value="${voucher.maximumDiscountAmount}" placeholder="e.g., 20">
                        <span class="help-text">Optional: Maximum discount cap for percentage-based vouchers (e.g., $20).</span>
                        <span class="error-text" id="maximumDiscountAmountError"></span>
                    </div>
                    <div class="form-group">
                        <label for="usageLimit">Usage Limit</label>
                        <input type="number" id="usageLimit" name="usageLimit" min="0" value="${voucher.usageLimit}" placeholder="e.g., 100">
                        <span class="help-text">Optional: Maximum number of times the voucher can be used.</span>
                        <span class="error-text" id="usageLimitError"></span>
                    </div>
                    <div class="form-group">
                        <label for="expirationDate">Expiration Date</label>
                        <input type="date" id="expirationDate" name="expirationDate" value="${voucher.expirationDate != null ? voucher.expirationDate.toLocalDate() : ''}" placeholder="e.g., 2025-12-31">
                        <span class="help-text">Optional: Date when the voucher expires (YYYY-MM-DD).</span>
                        <span class="error-text" id="expirationDateError"></span>
                    </div>
                    <div class="form-group">
                        <label for="isActive">Status <span style="color: red;">*</span></label>
                        <select id="isActive" name="isActive" required>
                            <option value="true" ${voucher.isActive ? 'selected' : ''}>Active</option>
                            <option value="false" ${voucher.isActive ? '' : 'selected'}>Inactive</option>
                        </select>
                        <span class="help-text">Select whether the voucher is active or inactive.</span>
                        <span class="error-text" id="isActiveError"></span>
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

    <%-- Phần JS để active menu và client-side validation --%>
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
            const form = document.getElementById('voucherForm');
            const fields = [
                { id: 'code', validate: value => {
                    if (!value.trim()) return 'Voucher Code is required.';
                    return '';
                }},
                { id: 'name', validate: value => {
                    if (!value.trim()) return 'Name is required.';
                    if (value.length < 3) return 'Name must be at least 3 characters.';
                    return '';
                }},
                { id: 'discountType', validate: value => {
                    if (!value) return 'Discount Type is required.';
                    return '';
                }},
                { id: 'discountValue', validate: value => {
                    if (!value) return 'Discount Value is required.';
                    if (parseFloat(value) <= 0) return 'Discount Value must be greater than 0.';
                    return '';
                }},
                { id: 'minimumOrderAmount', validate: value => {
                    if (value && parseFloat(value) < 0) return 'Minimum Order Amount cannot be negative.';
                    return '';
                }},
                { id: 'maximumDiscountAmount', validate: value => {
                    if (value && parseFloat(value) < 0) return 'Maximum Discount Amount cannot be negative.';
                    return '';
                }},
                { id: 'usageLimit', validate: value => {
                    if (value && parseInt(value) < 0) return 'Usage Limit cannot be negative.';
                    return '';
                }},
                { id: 'expirationDate', validate: value => {
                    if (value && new Date(value) < new Date().setHours(0, 0, 0, 0)) return 'Expiration Date cannot be in the past.';
                    return '';
                }},
                { id: 'isActive', validate: value => {
                    if (!value) return 'Status is required.';
                    return '';
                }}
            ];

            function validateField(fieldId, value) {
                const field = fields.find(f => f.id === fieldId);
                if (!field) return true;
                const errorElement = document.getElementById(`${fieldId}Error`);
                const errorMessage = field.validate(value);
                errorElement.innerText = errorMessage;
                return !errorMessage;
            }

            function validateForm() {
                let isValid = true;
                fields.forEach(field => {
                    const element = document.getElementById(field.id);
                    const value = element.type === 'checkbox' ? element.checked : element.value;
                    if (!validateField(field.id, value)) isValid = false;
                });
                return isValid;
            }

            // Validate on form submission
            form.addEventListener('submit', function(e) {
                if (!validateForm()) {
                    e.preventDefault();
                    console.log('Form submission prevented due to validation errors');
                }
            });

            // Validate on input change (exclude readonly code field)
            fields.forEach(field => {
                if (field.id === 'code') return; // Skip code field
                const element = document.getElementById(field.id);
                element.addEventListener('input', function() {
                    validateField(field.id, element.type === 'checkbox' ? element.checked : element.value);
                });
                element.addEventListener('change', function() {
                    validateField(field.id, element.type === 'checkbox' ? element.checked : element.value);
                });
            });
        });
    </script>
</body>
</html>