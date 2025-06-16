<%--
    File: stock-import.jsp
    Path: src/main/webapp/WEB-INF/views/staff/stock/stock-import.jsp
    Description: Stock import page for staff.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${requestScope.pageTitle != null ? requestScope.pageTitle : "Nhập Kho Sản Phẩm"}</title>

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">

    <style>
        /* CSS của bạn giữ nguyên */
        body { margin: 0; font-family: Arial, sans-serif; display: flex; min-height: 100vh; }
        .sidebar { width: 250px; background-color: #222d32; color: #b8c7ce; padding-top: 20px; flex-shrink: 0; box-shadow: 2px 0 5px rgba(0,0,0,0.2); }
        .sidebar-header { color: white; padding: 10px 15px; text-align: center; font-size: 20px; font-weight: bold; border-bottom: 1px solid #4b646f; margin-bottom: 15px; }
        .sidebar-menu { list-style: none; padding: 0; margin: 0; }
        .sidebar-menu li a { display: block; padding: 12px 15px; color: #b8c7ce; text-decoration: none; }
        .sidebar-menu li a:hover, .sidebar-menu li.active > a { background-color: #1e282c; color: white; }
        .sidebar-menu .header { color: #4b646f; background-color: #1a2226; padding: 10px 15px; font-size: 12px; text-transform: uppercase; }
        .sidebar-menu .treeview-menu { list-style: none; padding-left: 20px; display: none; }
        .sidebar-menu .treeview.active.menu-open > .treeview-menu { display: block; }
        .sidebar-menu .pull-right-container { float: right; }

        .main-content-wrapper { flex-grow: 1; display: flex; flex-direction: column; }
        .content-header { background-color: #f8f8f8; padding: 15px 20px; border-bottom: 1px solid #eee; display: flex; justify-content: space-between; align-items: center; }
        .content-header h1 { margin: 0; font-size: 24px; color: #333; }
        .content-header ol.breadcrumb { padding: 0; margin: 0; background: none; list-style: none; }
        .content-header ol.breadcrumb li { display: inline-block; }
        .content-header ol.breadcrumb li + li::before { content: "/\00a0"; padding: 0 5px; color: #ccc; }
        .content-area { padding: 20px; background-color: #ecf0f5; flex-grow: 1; }
        .box { background: #fff; border-radius: 3px; border-top: 3px solid #d2d6de; margin-bottom: 20px; width: 100%; box-shadow: 0 1px 1px rgba(0,0,0,0.1); }
        .box-header { color: #444; display: block; padding: 10px; position: relative; border-bottom: 1px solid #f4f4f4; }
        .box-title { display: inline-block; font-size: 18px; margin: 0; line-height: 1; }
        .box-body { padding: 10px; }
        .box-tools { float: right; }
        .btn { display: inline-block; padding: 6px 12px; margin-bottom: 0; font-size: 14px; font-weight: 400; line-height: 1.42857143; text-align: center; white-space: nowrap; vertical-align: middle; cursor: pointer; border: 1px solid transparent; border-radius: 4px; }
        .btn-primary { color: #fff; background-color: #3c8dbc; border-color: #367fa9; }
        .btn-warning { color: #fff; background-color: #f39c12; border-color: #e08e0b; }
        .btn-danger { color: #fff; background-color: #dd4b39; border-color: #d73925; }
        .btn-xs { padding: 1px 5px; font-size: 12px; line-height: 1.5; border-radius: 3px; }
        .table { width: 100%; max-width: 100%; margin-bottom: 20px; border-collapse: collapse; border-spacing: 0; }
        .table th, .table td { padding: 8px; line-height: 1.42857143; vertical-align: top; border-top: 1px solid #ddd; text-align: left; }
        .table thead th { vertical-align: bottom; border-bottom: 2px solid #ddd; }
        .small-box {
            position: relative;
            display: block;
            border-radius: 2px;
            box-shadow: 0 1px 1px rgba(0,0,0,0.1);
            margin-bottom: 20px;
            color: white;
            padding: 15px;
        }
        .small-box .inner {
            padding: 10px;
        }
        .small-box h3 {
            font-size: 38px;
            font-weight: bold;
            margin: 0 0 10px 0;
            white-space: nowrap;
            padding: 0;
        }
        .small-box p {
            font-size: 15px;
        }
        .small-box .icon {
            position: absolute;
            top: auto;
            bottom: 5px;
            right: 5px;
            z-index: 0;
            font-size: 90px;
            color: rgba(0,0,0,0.15);
        }
        .small-box .small-box-footer {
            position: relative;
            text-align: center;
            padding: 3px 0;
            color: #fff;
            color: rgba(255,255,255,0.8);
            display: block;
            z-index: 10;
            background: rgba(0,0,0,0.1);
            text-decoration: none;
        }
        .small-box .small-box-footer:hover {
            color: #fff;
            background: rgba(0, 0, 0, 0.15);
        }
        /* Custom styles for stock levels */
        .no-stock {
            background-color: #fce4e4; /* Light red */
        }
        .low-stock {
            background-color: #fffacd; /* Lemon Chiffon */
        }
        .search-sort-form {
            margin-bottom: 20px;
            padding: 15px;
            background-color: #f9f9f9;
            border: 1px solid #ddd;
            border-radius: 4px;
            display: flex;
            gap: 10px;
            align-items: center;
            flex-wrap: wrap; /* Allow wrapping on smaller screens */
        }
        .search-sort-form label {
            margin-right: 5px;
        }
        .search-sort-form input[type="text"],
        .search-sort-form select {
            padding: 8px;
            border: 1px solid #ccc;
            border-radius: 4px;
            flex-grow: 1; /* Allow inputs/selects to grow */
            min-width: 150px; /* Minimum width for inputs/selects */
        }
        .search-sort-form button {
            padding: 8px 15px;
            background-color: #3c8dbc;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        .search-sort-form button:hover {
            background-color: #367fa9;
        }

        /* Original styles from stock-import.jsp - Preserved */
        .container {
            max-width: 900px;
            margin: 30px auto;
            background-color: #ffffff;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 6px 20px rgba(0, 0, 0, 0.1);
            border: 1px solid #e0e0e0;
        }
        h2 {
            text-align: center;
            color: #2c3e50;
            margin-bottom: 30px;
            font-weight: 600;
        }
        h3 {
            color: #34495e;
            margin-top: 25px;
            margin-bottom: 15px;
            border-bottom: 1px solid #eee;
            padding-bottom: 8px;
        }
        .form-group {
            margin-bottom: 20px;
        }
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: bold;
            color: #555;
        }
        .form-group input[type="text"],
        .form-group input[type="number"],
        .form-group textarea,
        .form-group select {
            width: calc(100% - 24px); /* Adjusted for padding */
            padding: 12px;
            border: 1px solid #ccd;
            border-radius: 8px;
            font-size: 16px;
            box-sizing: border-box; /* Include padding in width */
            transition: border-color 0.3s ease, box-shadow 0.3s ease;
        }
        .form-group input[type="text"]:focus,
        .form-group input[type="number"]:focus,
        .form-group textarea:focus,
        .form-group select:focus {
            border-color: #007bff;
            box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.25);
            outline: none;
        }
        .form-group textarea {
            resize: vertical;
            min-height: 90px;
        }
        .select-and-new-input-group {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .select-and-new-input-group select,
        .select-and-new-input-group input[type="text"] {
            flex: 1;
        }
        .button-group {
            text-align: center;
            margin-top: 30px;
        }
        .button-group button {
            padding: 12px 28px;
            background-color: #28a745; /* Green for success/import */
            color: white;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-size: 18px;
            font-weight: 600;
            transition: background-color 0.3s ease, transform 0.2s ease;
        }
        .button-group button:hover {
            background-color: #218838;
            transform: translateY(-2px);
        }
        .error-message {
            color: #dc3545; /* Red for errors */
            background-color: #f8d7da;
            border: 1px solid #f5c6cb;
            padding: 12px;
            margin-bottom: 20px;
            border-radius: 8px;
            text-align: center;
            font-weight: bold;
        }
        .success-message {
            color: #28a745; /* Green for success */
            background-color: #d4edda;
            border: 1px solid #c3e6cb;
            padding: 12px;
            margin-bottom: 20px;
            border-radius: 8px;
            text-align: center;
            font-weight: bold;
        }
        .required-asterisk {
            color: #dc3545;
            margin-left: 4px;
        }
    </style>
</head>
<body>

    <%-- Set necessary requestScope variables for sidebar/header --%>
    <c:set var="currentAction" value="stock-import" scope="request"/>
    <c:set var="currentModule" value="stock" scope="request"/>
    <c:set var="pageTitle" value="Nhập Kho Sản Phẩm" scope="request"/>

    <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp" />

    <div class="main-content-wrapper">
        <jsp:include page="/WEB-INF/includes/admin-header.jsp" />

        <div class="content-area">
            <div class="row" style="width: 100%; display: flex; justify-content: center;">
                <div class="col-xs-12" style="width: 100%;">
                    <div class="box box-primary">
                        <div class="box-header with-border">
                            <h3 class="box-title">Nhập Kho Sản Phẩm</h3>
                        </div>
                        <div class="box-body">
                            <%-- The container class will bring back your original form styling and centering --%>
                            <div class="container">
                                <h2>Chức năng Nhập Kho Sản Phẩm</h2>

                                <%-- Hiển thị thông báo lỗi hoặc thành công --%>
                                <c:if test="${not empty errorMessage}">
                                    <div class="error-message">
                                        <c:out value="${errorMessage}"/>
                                    </div>
                                </c:if>
                                <c:if test="${not empty successMessage}">
                                    <div class="success-message">
                                        <c:out value="${successMessage}"/>
                                    </div>
                                </c:if>

                                <form id="stockImportForm" action="${pageContext.request.contextPath}/StockImport" method="post">
                                    <h3>Thông tin sản phẩm <small>(điền nếu là sản phẩm mới hoặc để cập nhật thông tin chi tiết)</small></h3>

                                    <%-- Product Selection Field --%>

                                    <hr/> <%-- Separator for product details --%>

                                    <div class="form-group">
                                        <label for="productName">Tên sản phẩm <span class="required-asterisk">*</span>:</label>
                                        <input type="text" id="productName" name="productName" required placeholder="Ví dụ: Áo thun nam Cotton" oninput="handleNewProductDetailInput()">
                                        <input type="hidden" id="hiddenProductName" name="productName_hidden">
                                    </div>
                                    <div class="form-group">
                                        <label for="productDescription">Mô tả sản phẩm:</label>
                                        <textarea id="productDescription" name="productDescription" placeholder="Mô tả chi tiết về sản phẩm" oninput="handleNewProductDetailInput()"></textarea>
                                        <input type="hidden" id="hiddenProductDescription" name="productDescription_hidden">
                                    </div>
                                    <div class="form-group">
                                        <label for="productPrice">Giá sản phẩm (VD: 150000.00) <span class="required-asterisk">(*)</span>:</label>
                                        <input type="number" step="0.01" id="productPrice" name="productPrice" placeholder="Chỉ bắt buộc nếu là sản phẩm mới" oninput="handleNewProductDetailInput()">
                                        <input type="hidden" id="hiddenProductPrice" name="productPrice_hidden">
                                    </div>

                                    <div class="form-group">
                                        <label for="supplierId">Nhà cung cấp <span class="required-asterisk">(*)</span>:</label>
                                        <div class="select-and-new-input-group">
                                            <select id="supplierId" name="supplierId" onchange="handleSupplierCategoryBrandChange('supplierId', 'newSupplierName')">
                                                <option value="">-- Chọn Nhà cung cấp --</option>
                                                <c:forEach var="supplier" items="${suppliers}">
                                                    <option value="${supplier.supplierId}">${supplier.name}</option>
                                                </c:forEach>
                                            </select>
                                            <input type="text" id="newSupplierName" name="newSupplierName" placeholder="Hoặc nhập tên nhà cung cấp mới" oninput="handleSupplierCategoryBrandInput('supplierId', 'newSupplierName')">
                                            <input type="hidden" id="hiddenSupplierId" name="supplierId_hidden">
                                            <input type="hidden" id="hiddenNewSupplierName" name="newSupplierName_hidden">
                                        </div>
                                    </div>

                                    <div class="form-group">
                                        <label for="categoryId">Danh mục <span class="required-asterisk">(*)</span>:</label>
                                        <div class="select-and-new-input-group">
                                            <select id="categoryId" name="categoryId" onchange="handleSupplierCategoryBrandChange('categoryId', 'newCategoryName')">
                                                <option value="">-- Chọn Danh mục --</option>
                                                <c:forEach var="category" items="${categories}">
                                                    <option value="${category.categoryId}">${category.name}</option>
                                                </c:forEach>
                                            </select>
                                            <input type="text" id="newCategoryName" name="newCategoryName" placeholder="Hoặc nhập tên danh mục mới" oninput="handleSupplierCategoryBrandInput('categoryId', 'newCategoryName')">
                                            <input type="hidden" id="hiddenCategoryId" name="categoryId_hidden">
                                            <input type="hidden" id="hiddenNewCategoryName" name="newCategoryName_hidden">
                                        </div>
                                    </div>

                                    <div class="form-group">
                                        <label for="brandId">Thương hiệu <span class="required-asterisk">(*)</span>:</label>
                                        <div class="select-and-new-input-group">
                                            <select id="brandId" name="brandId" onchange="handleSupplierCategoryBrandChange('brandId', 'newBrandName')">
                                                <option value="">-- Chọn Thương hiệu --</option>
                                                <c:forEach var="brand" items="${brands}">
                                                    <option value="${brand.brandId}">${brand.name}</option>
                                                </c:forEach>
                                            </select>
                                            <input type="text" id="newBrandName" name="newBrandName" placeholder="Hoặc nhập tên thương hiệu mới" oninput="handleSupplierCategoryBrandInput('brandId', 'newBrandName')">
                                            <input type="hidden" id="hiddenBrandId" name="brandId_hidden">
                                            <input type="hidden" id="hiddenNewBrandName" name="newBrandName_hidden">
                                        </div>
                                    </div>

                                    <div class="form-group">
                                        <label for="material">Chất liệu:</label>
                                        <input type="text" id="material" name="material" placeholder="Ví dụ: Cotton, Polyester" oninput="handleNewProductDetailInput()">
                                        <input type="hidden" id="hiddenMaterial" name="material_hidden">
                                    </div>

                                    <hr/>

                                    <h3>Thông tin Biến thể & Số lượng nhập kho</h3>
                                    <div class="form-group">
                                        <label for="variantSize">Kích cỡ <span class="required-asterisk">*</span>:</label>
                                        <input type="text" id="variantSize" name="variantSize" required placeholder="Ví dụ: S, M, L, XL">
                                    </div>
                                    <div class="form-group">
                                        <label for="variantColor">Màu sắc <span class="required-asterisk">*</span>:</label>
                                        <input type="text" id="variantColor" name="variantColor" required placeholder="Ví dụ: Đỏ, Xanh, Đen">
                                    </div>
                                    <div class="form-group">
                                        <label for="importQuantity">Số lượng nhập <span class="required-asterisk">*</span>:</label>
                                        <input type="number" id="importQuantity" name="importQuantity" min="1" required placeholder="Số lượng sản phẩm muốn nhập">
                                    </div>
                                    <div class="form-group">
                                        <label for="variantPrice">Giá biến thể (để trống nếu giống giá sản phẩm chính):</label>
                                        <input type="number" step="0.01" id="variantPrice" name="variantPrice" placeholder="Giá riêng cho biến thể này (nếu có)">
                                    </div>
                                    <div class="form-group">
                                        <label for="sku">SKU (Mã kho hàng - để trống để hệ thống tự tạo):</label>
                                        <input type="text" id="sku" name="sku" placeholder="Mã SKU duy nhất cho biến thể">
                                    </div>
                                    <div class="form-group">
                                        <label for="notes">Ghi chú nhập kho:</label>
                                        <textarea id="notes" name="notes" placeholder="Ghi chú thêm về đợt nhập kho này"></textarea>
                                    </div>
                                    
                                    <input type="hidden" id="hiddenProductIdSelected" name="productId_selected">


                                    <div class="button-group">
                                        <button type="submit">Nhập kho</button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        /* ALL JAVASCRIPT CODE IS PASTED FROM admin-scripts.js HERE */
        document.addEventListener('DOMContentLoaded', function() {
            const treeviews = document.querySelectorAll('.sidebar-menu .treeview > a');
            treeviews.forEach(function(treeviewLink) {
                treeviewLink.addEventListener('click', function(e) {
                    const parentLi = this.parentElement;
                    if (parentLi.classList.contains('treeview')) {
                        e.preventDefault();
                        document.querySelectorAll('.sidebar-menu .treeview.menu-open').forEach(li => {
                            if (li !== parentLi) {
                                li.classList.remove('menu-open');
                                li.classList.remove('active');
                            }
                        });
                        parentLi.classList.toggle('menu-open');
                        parentLi.classList.toggle('active');
                    }
                });
            });
            const currentAction = "${requestScope.currentAction}";
            const currentModule = "${requestScope.currentModule}";

            document.querySelectorAll('.sidebar-menu li.active').forEach(li => li.classList.remove('active'));
            document.querySelectorAll('.sidebar-menu .treeview.menu-open').forEach(li => li.classList.remove('menu-open'));
            if (currentAction && currentModule) {
                const activeLink = document.querySelector(`.sidebar-menu a[href*="action=${currentAction}"][href*="module=${currentModule}"]`);
                if (activeLink) {
                    activeLink.parentElement.classList.add('active');
                    const parentTreeview = activeLink.closest('.treeview');
                    if (parentTreeview) {
                        parentTreeview.classList.add('active');
                        parentTreeview.classList.add('menu-open');
                    }
                }
            } else if (!currentAction || currentAction === 'home' || currentAction === 'dashboard') {
                const dashboardLink = document.querySelector('.sidebar-menu a[href*="action=dashboard"]');
                if (dashboardLink) {
                    dashboardLink.parentElement.classList.add('active');
                }
            }

            // --- Initial state setup on page load ---
            const productIdSelect = document.getElementById('productId');
            const productNameInput = document.getElementById('productName');
            
            // Check if a product ID is pre-selected (e.g. from a failed form submission)
            if (productIdSelect.value !== "") {
                handleProductSelection(); // Apply disable logic for pre-selected product
                copyValuesToHiddenInputs(); // Copy initial values to hidden inputs
            } else if (productNameInput.value.trim() !== "") {
                // Or if product name is manually entered (for a new product scenario)
                handleNewProductDetailInput(); // Apply disable logic for manual entry
                copyValuesToHiddenInputs();
            } else {
                // Otherwise, enable all fields for new product entry by default
                enableProductDetailsFields();
                enableSupplierCategoryBrandFields();
                copyValuesToHiddenInputs(); // Clear hidden inputs
            }

            // Apply mutual exclusivity for Supplier, Category, Brand on load
            // Call change and input handlers to set initial state correctly
            handleSupplierCategoryBrandChange('supplierId', 'newSupplierName');
            handleSupplierCategoryBrandInput('supplierId', 'newSupplierName');
            handleSupplierCategoryBrandChange('categoryId', 'newCategoryName');
            handleSupplierCategoryBrandInput('categoryId', 'newCategoryName');
            handleSupplierCategoryBrandChange('brandId', 'newBrandName');
            handleSupplierCategoryBrandInput('brandId', 'newBrandName');
            
            // Add event listener for form submission to copy values before submit
            document.getElementById('stockImportForm').addEventListener('submit', function(event) {
                copyValuesToHiddenInputs();
            });
        });

        // --- JavaScript functions for mutual exclusivity and auto-fill ---

        // Helper function to disable/enable a list of elements
        function setElementsDisabled(elements, isDisabled) {
            elements.forEach(el => {
                if (el) { // Check if element exists
                    el.disabled = isDisabled;
                    // For required fields, temporarily remove 'required' when disabled
                    // and restore when re-enabled to prevent browser validation issues.
                    if (el.hasAttribute('required') && isDisabled) {
                        el.dataset.originalRequired = 'true';
                        el.removeAttribute('required');
                    } else if (el.dataset.originalRequired === 'true' && !isDisabled) {
                        el.setAttribute('required', 'required');
                        delete el.dataset.originalRequired;
                    }
                }
            });
        }
        
        // List of Product Detail elements
        const productDetailElements = [
            document.getElementById('productName'),
            document.getElementById('productDescription'),
            document.getElementById('productPrice'),
            document.getElementById('material')
        ];

        // List of Supplier, Category, Brand SELECT and new INPUT elements
        const supplierCategoryBrandElements = [
            { select: document.getElementById('supplierId'), input: document.getElementById('newSupplierName') },
            { select: document.getElementById('categoryId'), input: document.getElementById('newCategoryName') },
            { select: document.getElementById('brandId'), input: document.getElementById('newBrandName') }
        ];

        const productIdSelect = document.getElementById('productId');

        // Copies values from active input/select fields to their hidden counterparts
        function copyValuesToHiddenInputs() {
            // Product details
            productDetailElements.forEach(el => {
                const hiddenEl = document.getElementById('hidden' + el.id.charAt(0).toUpperCase() + el.id.slice(1));
                if (hiddenEl) {
                    hiddenEl.name = el.name; // Ensure hidden field has the same name
                    hiddenEl.value = el.value;
                }
            });

            // Supplier, Category, Brand
            supplierCategoryBrandElements.forEach(pair => {
                const selectEl = pair.select;
                const newInEl = pair.input;

                const hiddenSelectEl = document.getElementById('hidden' + selectEl.id.charAt(0).toUpperCase() + selectEl.id.slice(1));
                const hiddenNewInEl = document.getElementById('hidden' + newInEl.id.charAt(0).toUpperCase() + newInEl.id.slice(1));

                if (selectEl.disabled && hiddenNewInEl) { // Select is disabled, new input is active (or vice versa, but new input holds the effective value)
                    hiddenSelectEl.name = selectEl.name + '_disabled'; // Change name to prevent sending disabled value
                    hiddenNewInEl.name = newInEl.name; // Keep new input name
                    hiddenNewInEl.value = newInEl.value;
                    hiddenSelectEl.value = ''; // Ensure no value from disabled select is sent

                } else if (newInEl.disabled && hiddenSelectEl) { // New input is disabled, select is active
                    hiddenNewInEl.name = newInEl.name + '_disabled'; // Change name to prevent sending disabled value
                    hiddenSelectEl.name = selectEl.name; // Keep select name
                    hiddenSelectEl.value = selectEl.value;
                    hiddenNewInEl.value = ''; // Ensure no value from disabled new input is sent
                } else if (!selectEl.disabled && !newInEl.disabled) { // Both are enabled, likely on form load or reset
                    // If both are enabled, assume select is preferred, or both might be empty
                    hiddenSelectEl.name = selectEl.name;
                    hiddenNewInEl.name = newInEl.name;
                    hiddenSelectEl.value = selectEl.value;
                    hiddenNewInEl.value = newInEl.value; // Send both, controller handles logic
                }
            });
            
            // Handle hiddenProductIdSelected
            const hiddenProductIdSelected = document.getElementById('hiddenProductIdSelected');
            if (hiddenProductIdSelected) {
                hiddenProductIdSelected.value = productIdSelect.value;
            }
        }


        function disableProductDetailsFields() {
            setElementsDisabled(productDetailElements, true);
            setElementsDisabled(supplierCategoryBrandElements.map(p => p.select), true);
            setElementsDisabled(supplierCategoryBrandElements.map(p => p.input), true);
        }

        function enableProductDetailsFields() {
            setElementsDisabled(productDetailElements, false);
            // Re-enable supplier/category/brand select/input pairs separately
            enableSupplierCategoryBrandFields(); // Re-apply mutual exclusivity
        }

        function handleProductSelection() {
            const productId = productIdSelect.value;
            const form = document.querySelector('form');

            if (productId) {
                const selectedOption = document.querySelector(`#productId option[value="${productId}"]`);
                if (selectedOption) {
                    // Fill product details
                    form.querySelector('#productName').value = selectedOption.dataset.name || '';
                    form.querySelector('#productDescription').value = selectedOption.dataset.description || '';
                    form.querySelector('#productPrice').value = selectedOption.dataset.price || '';
                    form.querySelector('#material').value = selectedOption.dataset.material || '';

                    // Set Supplier
                    const supplierId = selectedOption.dataset.supplierId;
                    form.querySelector('#supplierId').value = supplierId || '';
                    form.querySelector('#newSupplierName').value = ''; // Clear new input

                    // Set Category
                    const categoryId = selectedOption.dataset.categoryId;
                    form.querySelector('#categoryId').value = categoryId || '';
                    form.querySelector('#newCategoryName').value = '';

                    // Set Brand
                    const brandId = selectedOption.dataset.brandId;
                    form.querySelector('#brandId').value = brandId || '';
                    form.querySelector('#newBrandName').value = '';

                    // Disable all product detail fields
                    disableProductDetailsFields();
                    productIdSelect.disabled = false; // Keep product ID select enabled
                }
            } else {
                // If "-- Chọn Sản phẩm --" is selected, enable all fields for new product entry
                enableProductDetailsFields();
                // Clear inputs that were filled by previous selection (if any)
                productDetailElements.forEach(el => el.value = '');
                supplierCategoryBrandElements.forEach(pair => {
                    pair.select.value = '';
                    pair.input.value = '';
                });
            }
            copyValuesToHiddenInputs(); // Copy values to hidden fields after change
        }

        function clearProductSelection() {
            productIdSelect.value = ''; // Clear the product selection dropdown
            handleProductSelection(); // Trigger to clear and enable fields
            productIdSelect.disabled = false; // Ensure it's re-enabled after "Tạo mới"
            document.getElementById('productName').focus(); // Optionally focus on product name
            copyValuesToHiddenInputs(); // Copy values to hidden fields after clear
        }

        // Handle input into any of the product detail fields (product name, description, price, material)
        function handleNewProductDetailInput() {
            const isAnyDetailFieldFilled = productDetailElements.some(el => el.value.trim() !== '');
            const isAnySCBInputFilled = supplierCategoryBrandElements.some(pair => pair.input.value.trim() !== '' || pair.select.value !== '');

            if (isAnyDetailFieldFilled || isAnySCBInputFilled) {
                productIdSelect.disabled = true;
                productIdSelect.value = ''; // Clear selection to avoid conflict
            } else {
                productIdSelect.disabled = false;
            }
            copyValuesToHiddenInputs();
        }
        
        // Handles change on Supplier/Category/Brand dropdowns
        function handleSupplierCategoryBrandChange(selectId, newInputId) {
            const selectElement = document.getElementById(selectId);
            const newInputElement = document.getElementById(newInputId);

            if (selectElement.value !== "") {
                setElementsDisabled([newInputElement], true);
                newInputElement.value = ''; // Clear the new input field
            } else {
                setElementsDisabled([newInputElement], false);
            }
            handleNewProductDetailInput(); // Re-evaluate product selection state
            copyValuesToHiddenInputs();
        }

        // Handles input on new Supplier/Category/Brand text inputs
        function handleSupplierCategoryBrandInput(selectId, newInputId) {
            const selectElement = document.getElementById(selectId);
            const newInputElement = document.getElementById(newInputId);

            if (newInputElement.value.trim() !== "") {
                setElementsDisabled([selectElement], true);
                selectElement.value = ''; // Clear the dropdown selection
            } else {
                setElementsDisabled([selectElement], false);
            }
            handleNewProductDetailInput(); // Re-evaluate product selection state
            copyValuesToHiddenInputs();
        }

        // Function to enable all supplier/category/brand fields
        // This is called when "Tạo mới" is clicked or product dropdown is reset
        function enableSupplierCategoryBrandFields() {
            supplierCategoryBrandElements.forEach(pair => {
                setElementsDisabled([pair.select, pair.input], false);
            });

            // Re-apply mutual exclusivity within each group after enabling all
            supplierCategoryBrandElements.forEach(pair => {
                handleSupplierCategoryBrandChange(pair.select.id, pair.input.id);
                handleSupplierCategoryBrandInput(pair.select.id, pair.input.id);
            });
        }

    </script>
</body>
</html>