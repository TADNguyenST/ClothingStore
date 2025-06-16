<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Danh sách Voucher</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            background-color: #f4f4f9;
        }
        h2 {
            text-align: center;
            color: #333;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
            background-color: #fff;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        th, td {
            padding: 12px;
            text-align: left;
            border: 1px solid #ddd;
        }
        th {
            background-color: #007bff;
            color: white;
        }
        tr:nth-child(even) {
            background-color: #f9f9f9;
        }
        tr:hover {
            background-color: #f1f1f1;
        }
        .no-data {
            text-align: center;
            color: #555;
            padding: 20px;
        }
        .btn {
            padding: 6px 12px;
            text-decoration: none;
            border-radius: 4px;
            color: white;
            font-size: 14px;
            border: none;
            cursor: pointer;
        }
        .btn-edit {
            background-color: #28a745;
        }
        .btn-edit:hover {
            background-color: #218838;
        }
        .btn-delete {
            background-color: #dc3545;
        }
        .btn-delete:hover {
            background-color: #c82333;
        }
        .btn-search {
            background-color: #17a2b8;
        }
        .btn-search:hover {
            background-color: #138496;
        }
        .error {
            color: red;
            text-align: center;
            margin: 10px 0;
        }
        .header-container {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        .search-container {
            text-align: right;
        }
        .search-input {
            padding: 6px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <div class="header-container">
        <h2>Danh sách Voucher</h2>
        <div class="search-container">
            <form action="searchVoucher" method="post" style="display: inline;">
                <input type="text" name="code" class="search-input" placeholder="Nhập mã voucher">
                <button type="submit" class="btn btn-search">Tìm kiếm</button>
            </form>
        </div>
    </div>
    <c:if test="${not empty errorMessage}">
        <div class="error">${errorMessage}</div>
    </c:if>
    <table>
        <thead>
            <tr>
                <th>Voucher Code</th>
                <th>Name</th>
                <th>Description</th>
                <th>Discount Type</th>
                <th>Discount Value</th>
                <th>Minimum Order</th>
                <th>Quantity</th>
                <th>Expiration Date</th>
                <th>Status</th>
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
                            <td>${voucher.description}</td>
                            <td>${voucher.discountType}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${voucher.discountType == 'Percentage'}">
                                        <fmt:formatNumber value="${voucher.discountValue}" type="percent"/>
                                    </c:when>
                                    <c:otherwise>
                                        <fmt:formatNumber value="${voucher.discountValue}" type="currency" currencySymbol="$"/>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <fmt:formatNumber value="${voucher.minimumOrderAmount}" type="currency" currencySymbol="$"/>
                            </td>
                            <td>${voucher.usageLimit != null ? voucher.usageLimit : 'Không giới hạn'}</td>
                            <td><fmt:formatDate value="${voucher.expirationDate}" pattern="dd-MM-yyyy"/></td>
                            <td>${voucher.isActive ? 'Active' : 'Inactive'}</td>
                            <td>
                                <a href="editVoucher?voucher_id=${voucher.voucherId}" class="btn btn-edit">Edit</a>
                                <a href="deleteVoucher?voucher_id=${voucher.voucherId}" class="btn btn-delete" onclick="return confirm('Bạn có chắc muốn xóa voucher này?')">Delete</a>
                            </td>
                        </tr>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <tr>
                        <td colspan="10" class="no-data">Không có voucher nào để hiển thị</td>
                    </tr>
                </c:otherwise>
            </c:choose>
        </tbody>
    </table>
</body>
</html>