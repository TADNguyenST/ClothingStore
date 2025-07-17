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

    <%-- Link to external library --%>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">

    <%-- Link to shared CSS file --%>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/admin-dashboard/css/admin-css.css">

    <%-- Inline CSS for the edit voucher page --%>
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

    <%-- Set requestScope variables for sidebar/header --%>
    <c:set var="currentAction" value="vouchers" scope="request"/>
    <c:set var="currentModule" value="admin" scope="request"/>
    <c:set var="pageTitle" value="Edit Voucher" scope="request"/>

    <%-- Include Sidebar --%>
    <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp" />

    <div class="main-content-wrapper">
        <%-- Include Header --%>
        <jsp:include page="/WEB-INF/includes/admin-header.jsp" />

        <%-- Main content of the Edit Voucher page --%>
        <div class="content-area">
            <h2>Edit Voucher</h2>
            <c:if test="${not empty param.successMessage}">
                <div class="success">${param.successMessage}</div>
            </c:if>
            <c:if test="${not empty requestScope.errorMessage}">
                <div class="error">${requestScope.errorMessage}</div>
            </c:if>
            <div class="form-container">
                <form action="${pageContext.request.contextPath}/editVoucher" method="post" id="voucherForm">
                    <input type="hidden" name="voucherId" value="${voucher.voucherId}"/>
                    <div class="form-group">
                        <label for="code">Voucher Code <span style="color: red;">*</span></label>
                        <input type="text" id="code" name="code" value="${voucher.code}" readonly>
                        <span class="help-text">Voucher code cannot be changed.</span>
                        <span class="error-text" id="codeError"></span>
                    </div>
                    <div class="form-group">
                        <label for="name">Voucher Name <span style="color: red;">*</span></label>
                        <input type="text" id="name" name="name" value="${voucher.name}" required placeholder="E.g., Summer Discount Voucher">
                        <span class="help-text">Provide a descriptive name for the voucher.</span>
                        <span class="error-text" id="nameError"></span>
                    </div>
                    <div class="form-group">
                        <label for="description">Description</label>
                        <textarea id="description" name="description" placeholder="E.g., 10% off for orders above 50,000 VND">${voucher.description}</textarea>
                        <span class="help-text">Optional: Describe the purpose or conditions of the voucher.</span>
                        <span class="error-text" id="descriptionError"></span>
                    </div>
                    <div class="form-group">
                        <label for="discountType">Discount Type <span style="color: red;">*</span></label>
                        <select id="discountType" name="discountType" required>
                            <option value="" disabled ${voucher.discountType == null ? 'selected' : ''}>Select discount type</option>
                            <option value="Percentage" ${voucher.discountType == 'Percentage' ? 'selected' : ''}>Percentage</option>
                            <option value="Fixed Amount" ${voucher.discountType == 'Fixed Amount' ? 'selected' : ''}>Fixed Amount</option>
                        </select>
                        <span class="help-text">Choose whether the discount is a percentage or a fixed amount.</span>
                        <span class="error-text" id="discountTypeError"></span>
                    </div>
                    <div class="form-group">
                        <label for="discountValue">Discount Value <span style="color: red;">*</span></label>
                        <input type="text" id="discountValue" name="discountValue" value="${voucher.discountValue}" required placeholder="E.g., 10 for Percentage or 1000 for Fixed Amount">
                        <span class="help-text">Enter 1-90 for Percentage or 1000-10000000 for Fixed Amount.</span>
                        <span class="error-text" id="discountValueError"></span>
                    </div>
                    <div class="form-group">
                        <label for="minimumOrderAmount">Minimum Order Amount</label>
                        <input type="number" id="minimumOrderAmount" name="minimumOrderAmount" step="0.01" min="0" value="${voucher.minimumOrderAmount}" placeholder="E.g., 50000">
                        <span class="help-text">Optional: Minimum order amount to apply the voucher (e.g., 50,000 VND).</span>
                        <span class="error-text" id="minimumOrderAmountError"></span>
                    </div>
                    <div class="form-group">
                        <label for="maximumDiscountAmount">Maximum Discount Amount</label>
                        <input type="number" id="maximumDiscountAmount" name="maximumDiscountAmount" step="0.01" min="0" value="${voucher.maximumDiscountAmount}" placeholder="E.g., 20000">
                        <span class="help-text">Optional: Maximum discount limit for percentage vouchers (e.g., 20,000 VND).</span>
                        <span class="error-text" id="maximumDiscountAmountError"></span>
                    </div>
                    <div class="form-group">
                        <label for="usageLimit">Usage Limit</label>
                        <input type="number" id="usageLimit" name="usageLimit" min="0" value="${voucher.usageLimit}" placeholder="E.g., 100">
                        <span class="help-text">Optional: Maximum number of times the voucher can be used.</span>
                        <span class="error-text" id="usageLimitError"></span>
                    </div>
                    <div class="form-group">
                        <label for="expirationDate">Expiration Date</label>
                        <input type="date" id="expirationDate" name="expirationDate" value="${voucher.expirationDate != null ? voucher.expirationDate.toLocalDate() : ''}" placeholder="E.g., 2025-12-31">
                        <span class="help-text">Optional: Date the voucher expires (YYYY-MM-DD).</span>
                        <span class="error-text" id="expirationDateError"></span>
                    </div>
                    <div class="form-group">
                        <label for="isActive">Status <span style="color: red;">*</span></label>
                        <select id="isActive" name="isActive" required>
                            <option value="true" ${voucher.isActive ? 'selected' : ''}>Active</option>
                            <option value="false" ${voucher.isActive ? '' : 'selected'}>Inactive</option>
                        </select>
                        <span class="help-text">Choose whether the voucher is active or inactive.</span>
                        <span class="error-text" id="isActiveError"></span>
                    </div>
                    <div class="form-group">
                        <label for="visibility">Visibility <span style="color: red;">*</span></label>
                        <select id="visibility" name="visibility" required>
                            <option value="true" ${voucher.visibility ? 'selected' : ''}>Visible</option>
                            <option value="false" ${voucher.visibility ? '' : 'selected'}>Hidden</option>
                        </select>
                        <span class="help-text">Choose whether the voucher is visible or hidden.</span>
                        <span class="error-text" id="visibilityError"></span>
                    </div>
                    <div class="form-group">
                        <button type="submit" class="btn btn-submit">Save</button>
                        <a href="${pageContext.request.contextPath}/vouchers" class="btn btn-cancel">Cancel</a>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <%-- Link to shared JS file --%>
    <script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>

    <%-- JS for active menu and client-side validation --%>
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
            const discountTypeSelect = document.getElementById('discountType');
            const discountValueInput = document.getElementById('discountValue');

            const fields = [
                { id: 'code', validate: value => {
                    if (!value.trim()) return 'Voucher Code is required.';
                    return '';
                }},
                { id: 'name', validate: value => {
                    if (!value.trim()) return 'Voucher Name is required.';
                    return '';
                }},
                { id: 'discountType', validate: value => {
                    if (!value) return 'Discount Type is required.';
                    if (value !== 'Percentage' && value !== 'Fixed Amount') return 'Discount Type must be Percentage or Fixed Amount.';
                    return '';
                }},
                { id: 'discountValue', validate: value => {
                    if (!value.trim()) return 'Discount Value is required.';
                    const num = parseFloat(value);
                    if (isNaN(num)) return 'Discount Value must be a number.';
                    if (discountTypeSelect.value === 'Percentage' && (num < 1 || num > 90)) {
                        return 'Percentage discount must be between 1 and 90.';
                    }
                    if (discountTypeSelect.value === 'Fixed Amount' && (num < 1000 || num > 10000000)) {
                        return 'Fixed Amount discount must be between 1000 and 10000000.';
                    }
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
                    if (value) {
                        const inputDate = new Date(value);
                        const today = new Date();
                        today.setHours(0, 0, 0, 0);
                        if (inputDate < today) return 'Expiration Date cannot be in the past.';
                    }
                    return '';
                }},
                { id: 'isActive', validate: value => {
                    if (value === '') return 'Status is required.';
                    return '';
                }},
                { id: 'visibility', validate: value => {
                    if (value === '') return 'Visibility is required.';
                    return '';
                }}
            ];

            form.addEventListener('submit', function(event) {
                let hasError = false;
                fields.forEach(field => {
                    const input = document.getElementById(field.id);
                    const errorElement = document.getElementById(field.id + 'Error');
                    const errorMessage = field.validate(input.value);
                    if (errorMessage) {
                        errorElement.textContent = errorMessage;
                        hasError = true;
                    } else {
                        errorElement.textContent = '';
                    }
                });

                if (hasError) {
                    event.preventDefault();
                }
            });

            // Real-time validation for discount value based on discount type
            discountTypeSelect.addEventListener('change', function() {
                const errorElement = document.getElementById('discountValueError');
                const value = discountValueInput.value;
                if (value) {
                    const num = parseFloat(value);
                    if (this.value === 'Percentage' && (num < 1 || num > 90)) {
                        errorElement.textContent = 'Percentage discount must be between 1 and 90.';
                    } else if (this.value === 'Fixed Amount' && (num < 1000 || num > 10000000)) {
                        errorElement.textContent = 'Fixed Amount discount must be between 1000 and 10000000.';
                    } else {
                        errorElement.textContent = '';
                    }
                }
            });

            discountValueInput.addEventListener('input', function() {
                const errorElement = document.getElementById('discountValueError');
                const value = this.value;
                if (value) {
                    const num = parseFloat(value);
                    if (isNaN(num)) {
                        errorElement.textContent = 'Discount Value must be a number.';
                    } else if (discountTypeSelect.value === 'Percentage' && (num < 1 || num > 90)) {
                        errorElement.textContent = 'Percentage discount must be between 1 and 90.';
                    } else if (discountTypeSelect.value === 'Fixed Amount' && (num < 1000 || num > 10000000)) {
                        errorElement.textContent = 'Fixed Amount discount must be between 1000 and 10000000.';
                    } else {
                        errorElement.textContent = '';
                    }
                } else {
                    errorElement.textContent = 'Discount Value is required.';
                }
            });
        });
    </script>
</body>
</html>