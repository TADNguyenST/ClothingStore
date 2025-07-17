
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

    <%-- Link to external libraries --%>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">

    <%-- Link to shared CSS file --%>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/admin-dashboard/css/admin-css.css">

    <%-- Inline CSS for add voucher page --%>
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
        .error-text {
            font-size: 12px;
            color: red;
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

    <%-- Set requestScope variables for sidebar/header --%>
    <c:set var="currentAction" value="addVoucher" scope="request"/>
    <c:set var="currentModule" value="admin" scope="request"/>
    <c:set var="pageTitle" value="Add Voucher" scope="request"/>

    <%-- Include Sidebar --%>
    <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp" />

    <div class="main-content-wrapper">
        <%-- Include Header --%>
        <jsp:include page="/WEB-INF/includes/admin-header.jsp" />

        <%-- Main content of Add Voucher page --%>
        <div class="content-area">
            <h2>Add Voucher</h2>
            <c:if test="${not empty param.successMessage}">
                <div class="success">${param.successMessage}</div>
            </c:if>
            <c:if test="${not empty param.errorMessage}">
                <div class="error">${param.errorMessage}</div>
            </c:if>
            <div class="form-container">
                <form action="${pageContext.request.contextPath}/addVoucher" method="post" id="voucherForm">
                    <div class="form-group">
                        <label for="code">Voucher Code <span style="color: red;">*</span></label>
                        <div class="input-group">
                            <input type="text" id="code" name="code" required placeholder="e.g., SUMMER2025">
                            <button type="button" class="btn btn-random" onclick="generateRandomCode()">Random</button>
                        </div>
                        <span class="help-text">Enter a unique code (e.g., SUMMER2025 or DISCOUNT10) or click Random to generate one.</span>
                        <span class="error-text" id="codeError"></span>
                    </div>
                    <div class="form-group">
                        <label for="name">Name <span style="color: red;">*</span></label>
                        <input type="text" id="name" name="name" required placeholder="e.g., Summer Sale Voucher">
                        <span class="help-text">Provide a descriptive name for the voucher.</span>
                        <span class="error-text" id="nameError"></span>
                    </div>
                    <div class="form-group">
                        <label for="description">Description</label>
                        <textarea id="description" name="description" placeholder="e.g., 10% off for orders above 50,000 VNĐ"></textarea>
                        <span class="help-text">Optional: Describe the voucher's purpose or conditions.</span>
                        <span class="error-text" id="descriptionError"></span>
                    </div>
                    <div class="form-group">
                        <label for="discountType">Discount Type <span style="color: red;">*</span></label>
                        <select id="discountType" name="discountType" required>
                            <option value="" disabled selected>Select a discount type</option>
                            <option value="Percentage">Percentage</option>
                            <option value="Fixed Amount">Fixed Amount</option>
                        </select>
                        <span class="help-text">Choose whether the discount is a percentage or fixed amount.</span>
                        <span class="error-text" id="discountTypeError"></span>
                    </div>
                    <div class="form-group">
                        <label for="discountValue">Discount Value <span style="color: red;">*</span></label>
                        <input type="number" id="discountValue" name="discountValue" step="0.01" min="0" required placeholder="e.g., 10 for Percentage or 1000 for Fixed Amount">
                        <span class="help-text">Enter 1-90 for Percentage or 1000-10000000 for Fixed Amount.</span>
                        <span class="error-text" id="discountValueError"></span>
                    </div>
                    <div class="form-group">
                        <label for="minimumOrderAmount">Minimum Order Amount</label>
                        <input type="number" id="minimumOrderAmount" name="minimumOrderAmount" step="0.01" min="0" placeholder="e.g., 50000">
                        <span class="help-text">Optional: Minimum order value to apply the voucher (e.g., 50,000 VNĐ).</span>
                        <span class="error-text" id="minimumOrderAmountError"></span>
                    </div>
                    <div class="form-group">
                        <label for="maximumDiscountAmount">Maximum Discount Amount</label>
                        <input type="number" id="maximumDiscountAmount" name="maximumDiscountAmount" step="0.01" min="0" placeholder="e.g., 20000">
                        <span class="help-text">Optional: Maximum discount cap for percentage-based vouchers (e.g., 20,000 VNĐ).</span>
                        <span class="error-text" id="maximumDiscountAmountError"></span>
                    </div>
                    <div class="form-group">
                        <label for="usageLimit">Usage Limit</label>
                        <input type="number" id="usageLimit" name="usageLimit" min="0" placeholder="e.g., 100">
                        <span class="help-text">Optional: Maximum number of times the voucher can be used.</span>
                        <span class="error-text" id="usageLimitError"></span>
                    </div>
                    <div class="form-group">
                        <label for="expirationDate">Expiration Date <span style="color: red;">*</span></label>
                        <input type="date" id="expirationDate" name="expirationDate" required placeholder="e.g., 2025-12-31">
                        <span class="help-text">Enter the date when the voucher expires (YYYY-MM-DD).</span>
                        <span class="error-text" id="expirationDateError"></span>
                    </div>
                    <div class="form-group">
                        <label for="isActive">Active</label>
                        <input type="checkbox" id="isActive" name="isActive" checked>
                        <span class="help-text">Check to make the voucher active immediately.</span>
                        <span class="error-text" id="isActiveError"></span>
                    </div>
                    <div class="form-group">
                        <label for="visibility">Visibility <span style="color: red;">*</span></label>
                        <select id="visibility" name="visibility" required>
                            <option value="true">Visible</option>
                            <option value="false" selected>Hidden</option>
                        </select>
                        <span class="help-text">Select whether the voucher is visible or hidden.</span>
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

    <%-- JS for active menu, client-side validation, and random code --%>
    <script>
        // Random code generation
        function generateRandomCode() {
            console.log('generateRandomCode called');
            const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
            const codeLength = 10;
            let randomCode = '';
            for (let i = 0; i < codeLength; i++) {
                const randomIndex = Math.floor(Math.random() * characters.length);
                randomCode += characters[randomIndex];
            }
            const codeInput = document.getElementById('code');
            if (codeInput) {
                codeInput.value = randomCode;
                console.log('Generated code:', randomCode);
            } else {
                console.error('Code input element not found');
            }
        }

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
                    if (value.length < 3) return 'Voucher Code must be at least 3 characters.';
                    return '';
                }},
                { id: 'name', validate: value => {
                    if (!value.trim()) return 'Name is required.';
                    if (value.length < 3) return 'Name must be at least 3 characters.';
                    return '';
                }},
                { id: 'discountType', validate: value => {
                    if (!value) return 'Discount Type is required.';
                    if (value !== 'Percentage' && value !== 'Fixed Amount') return 'Discount Type must be Percentage or Fixed Amount.';
                    return '';
                }},
                { id: 'discountValue', validate: value => {
                    if (!value) return 'Discount Value is required.';
                    const numValue = parseFloat(value);
                    if (isNaN(numValue) || numValue <= 0) return 'Discount Value must be greater than 0.';
                    const discountType = discountTypeSelect.value;
                    if (discountType === 'Percentage' && (numValue < 1 || numValue > 90)) {
                        return 'Percentage discount must be between 1 and 90.';
                    }
                    if (discountType === 'Fixed Amount' && (numValue < 1000 || numValue > 10000000)) {
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
                    if (!value) return 'Expiration Date is required.';
                    if (new Date(value) < new Date().setHours(0, 0, 0, 0)) return 'Expiration Date cannot be in the past.';
                    return '';
                }},
                { id: 'visibility', validate: value => {
                    if (!value) return 'Visibility is required.';
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

            // Validate on input change
            fields.forEach(field => {
                const element = document.getElementById(field.id);
                element.addEventListener('input', function() {
                    validateField(field.id, element.type === 'checkbox' ? element.checked : element.value);
                });
                element.addEventListener('change', function() {
                    validateField(field.id, element.type === 'checkbox' ? element.checked : element.value);
                });
            });

            // Re-validate discountValue when discountType changes
            discountTypeSelect.addEventListener('change', function() {
                validateField('discountValue', discountValueInput.value);
            });
        });
    </script>
</body>
</html>
