<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Edit Voucher</title>
    <style>
        /* same styles as before */
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f4f4f9; }
        h2 { text-align: center; color: #333; }
        .form-container {
            max-width: 600px; margin: 0 auto; background-color: #fff;
            padding: 20px; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; margin-bottom: 5px; font-weight: bold; color: #333; }
        .form-group input, .form-group select, .form-group textarea {
            width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px; font-size: 14px;
        }
        .form-group textarea { height: 100px; resize: vertical; }
        .error { color: red; margin-bottom: 10px; text-align: center; }
        .btn {
            padding: 8px 16px; text-decoration: none; border-radius: 4px; color: white;
            font-size: 14px; border: none; cursor: pointer; margin-right: 10px;
        }
        .btn-submit { background-color: #28a745; }
        .btn-submit:hover { background-color: #218838; }
        .btn-cancel { background-color: #6c757d; }
        .btn-cancel:hover { background-color: #5a6268; }
    </style>
</head>
<body>
    <div class="form-container">
        <h2>Edit Voucher</h2>
        <c:if test="${not empty errorMessage}">
            <div class="error">${errorMessage}</div>
        </c:if>
        <form action="${pageContext.request.contextPath}/editVoucher" method="post">
            <input type="hidden" name="voucherId" value="${voucher.voucherId}"/>
            <div class="form-group">
                <label for="code">Voucher Code:</label>
                <input type="text" id="code" name="code" value="${voucher.code}" required/>
            </div>
            <div class="form-group">
                <label for="name">Voucher Name:</label>
                <input type="text" id="name" name="name" value="${voucher.name}" required/>
            </div>
            <div class="form-group">
                <label for="description">Description:</label>
                <textarea id="description" name="description">${voucher.description}</textarea>
            </div>
            <div class="form-group">
                <label for="discountType">Discount Type:</label>
                <select id="discountType" name="discountType" required>
                    <option value="Percentage" ${voucher.discountType == 'Percentage' ? 'selected' : ''}>Percentage</option>
                    <option value="Fixed Amount" ${voucher.discountType == 'Fixed Amount' ? 'selected' : ''}>Fixed Amount</option>
                </select>
            </div>
            <div class="form-group">
                <label for="discountValue">Discount Value:</label>
                <input type="number" id="discountValue" name="discountValue" step="0.01" min="0.01" value="${voucher.discountValue}" required/>
            </div>
            <div class="form-group">
                <label for="minimumOrderAmount">Minimum Order Amount:</label>
                <input type="number" id="minimumOrderAmount" name="minimumOrderAmount" step="0.01" min="0" value="${voucher.minimumOrderAmount}"/>
            </div>
            <div class="form-group">
                <label for="maximumDiscountAmount">Maximum Discount Amount:</label>
                <input type="number" id="maximumDiscountAmount" name="maximumDiscountAmount" step="0.01" min="0" value="${voucher.maximumDiscountAmount}"/>
            </div>
            <div class="form-group">
                <label for="usageLimit">Usage Limit:</label>
                <input type="number" id="usageLimit" name="usageLimit" min="0" value="${voucher.usageLimit}"/>
            </div>
            <div class="form-group">
                <label for="expirationDate">Expiration Date:</label>
                <input type="date" id="expirationDate" name="expirationDate"
                       value="${voucher.expirationDate != null ? voucher.expirationDate.toLocalDate() : ''}" required/>
            </div>
            <div class="form-group">
                <label for="isActive">Status:</label>
                <select id="isActive" name="isActive" required>
                    <option value="true" ${voucher.isActive ? 'selected' : ''}>Active</option>
                    <option value="false" ${voucher.isActive ? '' : 'selected'}>Inactive</option>
                </select>
            </div>
            <div class="form-group">
                <button type="submit" class="btn btn-submit">Save</button>
                <a href="${pageContext.request.contextPath}/voucherList" class="btn btn-cancel">Cancel</a>
            </div>
        </form>
    </div>
</body>
</html>
