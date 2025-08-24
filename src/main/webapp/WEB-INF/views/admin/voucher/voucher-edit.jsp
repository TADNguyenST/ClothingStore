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
            font-size: 12px; color: red; margin-top: 5px; display: none;
        }
        .error-text.show {
            display: block;
        }
        .invalid-field {
            border: 1px solid red !important;
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

    <%-- Set requestScope variables for sidebar/header --%>
    <c:set var="currentAction" value="vouchers" scope="request"/>
    <c:set var="currentModule" value="admin" scope="request"/>
    <c:set var="pageTitle" value="Edit Voucher" scope="request"/>

    <%-- Include Sidebar --%>
    <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp" />

    <div class="main-content-wrapper">
        <%-- Include Header --%>
        

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
                    <input type="hidden" name="voucherId" value="${requestScope.formData.voucherId != null ? requestScope.formData.voucherId : voucher.voucherId}"/>
                    <div class="form-group">
                        <label for="code">Voucher Code <span style="color: red;">*</span></label>
                        <input type="text" id="code" name="code" value="${requestScope.formData.code != null ? requestScope.formData.code : voucher.code}" readonly>
                        <span class="help-text">The voucher code cannot be changed.</span>
                        <span class="error-text" id="codeError">${requestScope.errors.code != null ? requestScope.errors.code : ''}</span>
                    </div>
                    <div class="form-group">
                        <label for="name">Voucher Name <span style="color: red;">*</span></label>
                        <input type="text" id="name" name="name" value="${requestScope.formData.name != null ? requestScope.formData.name : voucher.name}" required placeholder="Example: Summer Discount Voucher">
                        <span class="help-text">Provide a descriptive name for the voucher.</span>
                        <span class="error-text" id="nameError">${requestScope.errors.name != null ? requestScope.errors.name : ''}</span>
                    </div>
                    <div class="form-group">
                        <label for="description">Description</label>
                        <textarea id="description" name="description" placeholder="Example: 10% off on orders above $50">${requestScope.formData.description != null ? requestScope.formData.description : voucher.description}</textarea>
                        <span class="help-text">Optional: Describe the purpose or conditions of the voucher.</span>
                        <span class="error-text" id="descriptionError">${requestScope.errors.description != null ? requestScope.errors.description : ''}</span>
                    </div>
                    <div class="form-group">
                        <label for="discountType">Discount Type <span style="color: red;">*</span></label>
                        <select id="discountType" name="discountType" required>
                            <option value="" disabled ${requestScope.formData.discountType == null && voucher.discountType == null ? 'selected' : ''}>Select discount type</option>
                            <option value="Percentage" ${requestScope.formData.discountType == 'Percentage' || (requestScope.formData.discountType == null && voucher.discountType == 'Percentage') ? 'selected' : ''}>Percentage</option>
                            <option value="Fixed Amount" ${requestScope.formData.discountType == 'Fixed Amount' || (requestScope.formData.discountType == null && voucher.discountType == 'Fixed Amount') ? 'selected' : ''}>Fixed Amount</option>
                        </select>
                        <span class="help-text">Choose whether the discount is a percentage or a fixed amount.</span>
                        <span class="error-text" id="discountTypeError">${requestScope.errors.discountType != null ? requestScope.errors.discountType : ''}</span>
                    </div>
                    <div class="form-group">
                        <label for="discountValue">Discount Value <span style="color: red;">*</span></label>
                        <input type="number" step="0.01" id="discountValue" name="discountValue" value="${requestScope.formData.discountValue != null ? requestScope.formData.discountValue : voucher.discountValue}" required placeholder="Example: 10 for Percentage or 1000 for Fixed Amount">
                        <span class="help-text">Enter 1-90 for Percentage or 1000-10000000 for Fixed Amount.</span>
                        <span class="error-text" id="discountValueError">${requestScope.errors.discountValue != null ? requestScope.errors.discountValue : ''}</span>
                    </div>
                    <div class="form-group">
                        <label for="minimumOrderAmount">Minimum Order Amount <span style="color: red;">*</span></label>
                        <input type="number" step="0.01" id="minimumOrderAmount" name="minimumOrderAmount" value="${requestScope.formData.minimumOrderAmount != null ? requestScope.formData.minimumOrderAmount : voucher.minimumOrderAmount}" required placeholder="Example: 50000">
                        <span class="help-text">Enter the minimum order value to apply the voucher (e.g., $50).</span>
                        <span class="error-text" id="minimumOrderAmountError">${requestScope.errors.minimumOrderAmount != null ? requestScope.errors.minimumOrderAmount : ''}</span>
                    </div>
                    <div class="form-group">
                        <label for="maximumDiscountAmount">Maximum Discount Amount <span style="color: red;">*</span></label>
                        <input type="number" step="0.01" id="maximumDiscountAmount" name="maximumDiscountAmount" value="${requestScope.formData.maximumDiscountAmount != null ? requestScope.formData.maximumDiscountAmount : voucher.maximumDiscountAmount}" required placeholder="Example: 20000">
                        <span class="help-text">Enter the maximum discount amount for percentage-based vouchers (e.g., $20).</span>
                        <span class="error-text" id="maximumDiscountAmountError">${requestScope.errors.maximumDiscountAmount != null ? requestScope.errors.maximumDiscountAmount : ''}</span>
                    </div>
                    <div class="form-group">
                        <label for="usageLimit">Usage Limit <span style="color: red;">*</span></label>
                        <input type="number" id="usageLimit" name="usageLimit" value="${requestScope.formData.usageLimit != null ? requestScope.formData.usageLimit : voucher.usageLimit}" required placeholder="Example: 100">
                        <span class="help-text">Enter the maximum number of times the voucher can be used.</span>
                        <span class="error-text" id="usageLimitError">${requestScope.errors.usageLimit != null ? requestScope.errors.usageLimit : ''}</span>
                    </div>
                    <div class="form-group">
                        <label for="expirationDate">Expiration Date <span style="color: red;">*</span></label>
                        <input type="date" id="expirationDate" name="expirationDate" value="${requestScope.formData.expirationDate != null ? requestScope.formData.expirationDate : (voucher.expirationDate != null ? voucher.expirationDate.toLocalDate() : '')}" required placeholder="Example: 2025-12-31">
                        <span class="help-text">Enter the voucher's expiration date (YYYY-MM-DD).</span>
                        <span class="error-text" id="expirationDateError">${requestScope.errors.expirationDate != null ? requestScope.errors.expirationDate : ''}</span>
                    </div>
                    <div class="form-group">
                        <label for="isActive">Status <span style="color: red;">*</span></label>
                        <select id="isActive" name="isActive" required>
                            <option value="true" ${requestScope.formData.isActive != null ? (requestScope.formData.isActive ? 'selected' : '') : (voucher.isActive ? 'selected' : '')}>Active</option>
                            <option value="false" ${requestScope.formData.isActive != null ? (requestScope.formData.isActive ? '' : 'selected') : (voucher.isActive ? '' : 'selected')}>Inactive</option>
                        </select>
                        <span class="help-text">Choose whether the voucher is active or inactive.</span>
                        <span class="error-text" id="isActiveError">${requestScope.errors.isActive != null ? requestScope.errors.isActive : ''}</span>
                    </div>
                    <div class="form-group">
                        <label for="visibility">Visibility <span style="color: red;">*</span></label>
                        <select id="visibility" name="visibility" required>
                            <option value="true" ${requestScope.formData.visibility != null ? (requestScope.formData.visibility ? 'selected' : '') : (voucher.visibility ? 'selected' : '')}>Visible</option>
                            <option value="false" ${requestScope.formData.visibility != null ? (requestScope.formData.visibility ? '' : 'selected') : (voucher.visibility ? '' : 'selected')}>Hidden</option>
                        </select>
                        <span class="help-text">Choose whether the voucher is visible or hidden.</span>
                        <span class="error-text" id="visibilityError">${requestScope.errors.visibility != null ? requestScope.errors.visibility : ''}</span>
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
                    if (value.length < 3) return 'Voucher Name must be at least 3 characters long.';
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
                    if (!value.trim()) return 'Minimum Order Amount is required.';
                    const num = parseFloat(value);
                    if (isNaN(num) || num < 0) return 'Minimum Order Amount cannot be negative.';
                    return '';
                }},
                { id: 'maximumDiscountAmount', validate: value => {
                    if (!value.trim()) return 'Maximum Discount Amount is required.';
                    const num = parseFloat(value);
                    if (isNaN(num) || num < 0) return 'Maximum Discount Amount cannot be negative.';
                    return '';
                }},
                { id: 'usageLimit', validate: value => {
                    if (!value.trim()) return 'Usage Limit is required.';
                    const num = parseInt(value);
                    if (isNaN(num) || num < 0) return 'Usage Limit cannot be negative.';
                    return '';
                }},
                { id: 'expirationDate', validate: value => {
                    if (!value) return 'Expiration Date is required.';
                    const inputDate = new Date(value);
                    const today = new Date();
                    today.setHours(0, 0, 0, 0);
                    if (inputDate < today) return 'Expiration Date cannot be in the past.';
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

            function showTemporaryError(fieldId, message) {
                const errorElement = document.getElementById(`${fieldId}Error`);
                const fieldElement = document.getElementById(fieldId);
                if (errorElement && fieldElement) {
                    errorElement.textContent = message;
                    errorElement.classList.add('show');
                    fieldElement.classList.add('invalid-field');
                    setTimeout(() => {
                        errorElement.classList.remove('show');
                        errorElement.textContent = '';
                        fieldElement.classList.remove('invalid-field');
                    }, 5000);
                }
            }

            function validateField(fieldId, value) {
                const field = fields.find(f => f.id === fieldId);
                if (!field) return true;
                const errorMessage = field.validate(value);
                const fieldElement = document.getElementById(fieldId);
                const errorElement = document.getElementById(`${fieldId}Error`);
                if (errorMessage) {
                    showTemporaryError(fieldId, errorMessage);
                    return false;
                }
                if (errorElement && fieldElement) {
                    errorElement.classList.remove('show');
                    errorElement.textContent = '';
                    fieldElement.classList.remove('invalid-field');
                }
                return true;
            }

            function validateForm() {
                let isValid = true;
                let firstInvalidField = null;
                fields.forEach(field => {
                    const element = document.getElementById(field.id);
                    const value = element.type === 'checkbox' ? element.checked : element.value;
                    if (!validateField(field.id, value)) {
                        isValid = false;
                        if (!firstInvalidField) {
                            firstInvalidField = element;
                        }
                    }
                });
                if (!isValid && firstInvalidField) {
                    firstInvalidField.scrollIntoView({ behavior: 'smooth', block: 'center' });
                    firstInvalidField.focus();
                }
                return isValid;
            }

            form.addEventListener('submit', function(e) {
                if (!validateForm()) {
                    e.preventDefault();
                    console.log('Form submission prevented due to validation errors');
                }
            });

            fields.forEach(field => {
                const element = document.getElementById(field.id);
                element.addEventListener('input', function() {
                    validateField(field.id, element.type === 'checkbox' ? element.checked : element.value);
                });
                element.addEventListener('change', function() {
                    validateField(field.id, element.type === 'checkbox' ? element.checked : element.value);
                });
            });

            discountTypeSelect.addEventListener('change', function() {
                validateField('discountValue', discountValueInput.value);
            });

            document.querySelectorAll('.error-text').forEach(errorElement => {
                if (errorElement.textContent.trim()) {
                    const fieldId = errorElement.id.replace('Error', '');
                    const fieldElement = document.getElementById(fieldId);
                    if (fieldElement) {
                        errorElement.classList.add('show');
                        fieldElement.classList.add('invalid-field');
                        setTimeout(() => {
                            errorElement.classList.remove('show');
                            errorElement.textContent = '';
                            fieldElement.classList.remove('invalid-field');
                        }, 5000);
                    }
                }
            });
        });
    </script>
</body>
</html>