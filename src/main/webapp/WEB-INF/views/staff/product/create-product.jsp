<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@page import="java.math.BigDecimal"%>
<%@page import="model.Category"%>
<%@page import="model.Brand"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="java.text.DecimalFormatSymbols"%>
<%@page import="java.util.List"%>
<%
    String err = (String) request.getAttribute("err");
    List<Category> categories = (List<Category>) request.getAttribute("categories");
    List<Brand> brands = (List<Brand>) request.getAttribute("brands");
%>
<%!
    private String formatPrice(BigDecimal price) {
        if (price == null) {
            return "N/A";
        }
        DecimalFormatSymbols symbols = new DecimalFormatSymbols();
        symbols.setGroupingSeparator('.');
        symbols.setDecimalSeparator(',');
        DecimalFormat df = new DecimalFormat("#,###", symbols);
        return df.format(price);
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Add New Product</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/admin-dashboard/css/admin-css.css">
    <!-- Disable browser caching -->
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <meta http-equiv="Pragma" content="no-cache">
    <meta http-equiv="Expires" content="0">
</head>
<body>
    <c:set var="currentAction" value="products" scope="request"/>
    <c:set var="currentModule" value="admin" scope="request"/>
    <c:set var="pageTitle" value="Add New Product" scope="request"/>
    <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp" />
    <div class="main-content-wrapper">
        <jsp:include page="/WEB-INF/includes/admin-header.jsp" />
        <div class="content-area">
            <div class="row">
                <div class="col-xs-12">
                    <div class="box box-primary">
                        <div class="box-header with-border">
                            <h3 class="box-title">Add New Product</h3>
                        </div>
                        <div class="box-body">
                            <% if (err != null && !err.isEmpty()) { %>
                                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                    <%= err %>
                                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                                </div>
                            <% } %>
                            <form action="${pageContext.request.contextPath}/ProductManager" method="post" enctype="multipart/form-data" class="mt-3">
                                <input type="hidden" name="action" value="create">
                                <div class="mb-3">
                                    <label class="form-label">Name <span class="text-danger">*</span></label>
                                    <input type="text" name="name" class="form-control" required>
                                    <div class="invalid-feedback">Tên sản phẩm là bắt buộc.</div>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Description</label>
                                    <textarea name="description" class="form-control"></textarea>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Price <span class="text-danger">*</span></label>
                                    <input type="text" name="price" class="form-control" placeholder="e.g., 450000 or 450.000" required oninput="validatePrice(this)">
                                    <div class="invalid-feedback">Định dạng giá không hợp lệ (ví dụ: 450000 hoặc 450.000).</div>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Parent Category</label>
                                    <select name="parentCategoryId" id="parentCategoryId" class="form-select" onchange="filterChildCategories()">
                                        <option value="">Chọn danh mục cha</option>
                                        <%
                                            if (categories != null) {
                                                for (Category category : categories) {
                                                    if (category.getParentCategoryId() == null) {
                                        %>
                                        <option value="<%= category.getCategoryId() %>"><%= category.getName() %></option>
                                        <%
                                                    }
                                                }
                                            }
                                        %>
                                    </select>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Category <span class="text-danger">*</span></label>
                                    <select name="categoryId" id="categoryId" class="form-select" required>
                                        <option value="">Chọn danh mục</option>
                                        <%
                                            if (categories != null) {
                                                for (Category category : categories) {
                                                    if (category.getParentCategoryId() != null) {
                                        %>
                                        <option value="<%= category.getCategoryId() %>" data-parent-id="<%= category.getParentCategoryId() %>">
                                            <%= category.getName() %>
                                        </option>
                                        <%
                                                    }
                                                }
                                            }
                                        %>
                                    </select>
                                    <div class="invalid-feedback">Danh mục là bắt buộc.</div>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Brand <span class="text-danger">*</span></label>
                                    <select name="brandId" class="form-select" required>
                                        <option value="">Chọn thương hiệu</option>
                                        <%
                                            if (brands != null) {
                                                for (Brand brand : brands) {
                                        %>
                                        <option value="<%= brand.getBrandId() %>"><%= brand.getName() %></option>
                                        <%
                                                }
                                            }
                                        %>
                                    </select>
                                    <div class="invalid-feedback">Thương hiệu là bắt buộc.</div>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Material <span class="text-danger">*</span></label>
                                    <input type="text" name="material" class="form-control" required>
                                    <div class="invalid-feedback">Chất liệu là bắt buộc.</div>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Status</label>
                                    <select name="status" class="form-select">
                                        <option value="Active" selected>Active</option>
                                        <option value="Discontinued">Discontinued</option>
                                    </select>
                                </div>
                                <h4>Variants</h4>
                                <div id="variants-container" class="mb-3">
                                    <!-- Initial variant row -->
                                    <div class="variant-row mb-3">
                                        <div class="row">
                                            <div class="col-md-4">
                                                <select name="size" class="form-control" required onchange="validateField(this)">
                                                    <option value="" disabled selected>Chọn Kích Cỡ</option>
                                                    <option value="S">S</option>
                                                    <option value="M">M</option>
                                                    <option value="L">L</option>
                                                    <option value="XL">XL</option>
                                                    <option value="XS">XS</option>
                                                </select>
                                                <div class="invalid-feedback">Vui lòng chọn một kích cỡ hợp lệ.</div>
                                            </div>
                                            <div class="col-md-4">
                                                <select name="color" class="form-control" required onchange="validateField(this)">
                                                    <option value="" disabled selected>Chọn Màu Sắc</option>
                                                    <option value="Red">Red</option>
                                                    <option value="Blue">Blue</option>
                                                    <option value="Green">Green</option>
                                                    <option value="Black">Black</option>
                                                    <option value="White">White</option>
                                                    <option value="Yellow">Yellow</option>
                                                </select>
                                                <div class="invalid-feedback">Vui lòng chọn một màu sắc hợp lệ.</div>
                                            </div>
                                            <div class="col-md-3">
                                                <input type="text" name="priceModifier" class="form-control" placeholder="e.g., 450000 or 450.000" required oninput="validateField(this)">
                                                <div class="invalid-feedback">Giá biến thể phải lớn hơn hoặc bằng giá cơ bản.</div>
                                            </div>
                                            <div class="col-md-1">
                                                <button type="button" class="btn btn-danger btn-sm" onclick="removeElement(this)">
                                                    <i class="bi bi-trash"></i> Remove
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <button type="button" class="btn btn-outline-primary mb-3" onclick="addVariant()">
                                    <i class="bi bi-plus-circle"></i> Add Variant
                                </button>
                                <h4>Images</h4>
                                <div id="images-container" class="mb-3">
                                    <div class="image-row mb-3">
                                        <div class="row">
                                            <div class="col-md-7">
                                                <input type="file" name="images" class="form-control" accept="image/jpeg,image/png,image/gif" required>
                                                <div class="invalid-feedback">Vui lòng chọn một ảnh hợp lệ (jpg, png, gif).</div>
                                            </div>
                                            <div class="col-md-3">
                                                <div class="form-check">
                                                    <input type="checkbox" name="isMainImage" value="true" class="form-check-input" onchange="toggleMainImage(this)">
                                                    <label class="form-check-label">Main Image</label>
                                                </div>
                                            </div>
                                            <div class="col-md-2">
                                                <button type="button" class="btn btn-danger btn-sm" onclick="removeElement(this)">
                                                    <i class="bi bi-trash"></i> Remove
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <button type="button" class="btn btn-outline-primary mb-3" onclick="addImage()">
                                    <i class="bi bi-plus-circle"></i> Add Image
                                </button>
                                <div>
                                    <button type="submit" class="btn btn-primary"><i class="bi bi-save"></i> Add Product</button>
                                    <a href="${pageContext.request.contextPath}/ProductManager" class="btn btn-secondary">Cancel</a>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
        <script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>
        <script>
            // Initialize variants container
            function initializeVariants() {
                console.log("Khởi tạo biến thể...");
                const container = document.getElementById('variants-container');
                if (container) {
                    const variantRows = container.querySelectorAll('.variant-row');
                    console.log("Tìm thấy " + variantRows.length + " hàng biến thể ban đầu.");
                    variantRows.forEach(row => row.remove());
                    console.log("Đã xóa tất cả hàng biến thể ban đầu.");
                    addVariant();
                } else {
                    console.error("Không tìm thấy container 'variants-container'!");
                }
            }

            // Remove element (variant or image)
            function removeElement(button) {
                const row = button.closest('.variant-row') || button.closest('.image-row');
                if (row) {
                    row.parentElement.removeChild(row);
                    console.log("Đã xóa phần tử.");
                    updateVariantOptions();
                } else {
                    console.error("Không tìm thấy hàng để xóa!");
                }
            }

            // Add new variant
            function addVariant() {
                console.log("Thêm biến thể mới...");
                const container = document.getElementById('variants-container');
                if (!container) {
                    console.error("Container 'variants-container' không được tìm thấy!");
                    return;
                }
                const variantDiv = document.createElement('div');
                variantDiv.className = 'variant-row mb-3';
                variantDiv.innerHTML = `
                    <div class="row">
                        <div class="col-md-4">
                            <select name="size" class="form-control" required onchange="validateField(this)">
                                <option value="" disabled selected>Chọn Kích Cỡ</option>
                                <option value="S">S</option>
                                <option value="M">M</option>
                                <option value="L">L</option>
                                <option value="XL">XL</option>
                                <option value="XS">XS</option>
                            </select>
                            <div class="invalid-feedback">Vui lòng chọn một kích cỡ hợp lệ.</div>
                        </div>
                        <div class="col-md-4">
                            <select name="color" class="form-control" required onchange="validateField(this)">
                                <option value="" disabled selected>Chọn Màu Sắc</option>
                                <option value="Red">Red</option>
                                <option value="Blue">Blue</option>
                                <option value="Green">Green</option>
                                <option value="Black">Black</option>
                                <option value="White">White</option>
                                <option value="Yellow">Yellow</option>
                            </select>
                            <div class="invalid-feedback">Vui lòng chọn một màu sắc hợp lệ.</div>
                        </div>
                        <div class="col-md-3">
                            <input type="text" name="priceModifier" class="form-control" placeholder="e.g., 450000 or 450.000" required oninput="validateField(this)">
                            <div class="invalid-feedback">Giá biến thể phải lớn hơn hoặc bằng giá cơ bản.</div>
                        </div>
                        <div class="col-md-1">
                            <button type="button" class="btn btn-danger btn-sm" onclick="removeElement(this)">
                                <i class="bi bi-trash"></i> Remove
                            </button>
                        </div>
                    </div>
                `;
                container.appendChild(variantDiv);
                console.log("Đã thêm biến thể thành công.");
                updateVariantOptions();
            }

            // Add new image
            function addImage() {
                console.log("Thêm ảnh mới...");
                const container = document.getElementById('images-container');
                if (!container) {
                    console.error("Container 'images-container' không được tìm thấy!");
                    return;
                }
                const imageDiv = document.createElement('div');
                imageDiv.className = 'image-row mb-3';
                imageDiv.innerHTML = `
                    <div class="row">
                        <div class="col-md-7">
                            <input type="file" name="images" class="form-control" accept="image/jpeg,image/png,image/gif" required>
                            <div class="invalid-feedback">Vui lòng chọn một ảnh hợp lệ (jpg, png, gif).</div>
                        </div>
                        <div class="col-md-3">
                            <div class="form-check">
                                <input type="checkbox" name="isMainImage" value="true" class="form-check-input" onchange="toggleMainImage(this)">
                                <label class="form-check-label">Main Image</label>
                            </div>
                        </div>
                        <div class="col-md-2">
                            <button type="button" class="btn btn-danger btn-sm" onclick="removeElement(this)">
                                <i class="bi bi-trash"></i> Remove
                            </button>
                        </div>
                    </div>
                `;
                container.appendChild(imageDiv);
                console.log("Đã thêm ảnh thành công.");
            }

            // Toggle main image checkbox
            function toggleMainImage(checkbox) {
                console.log("Chuyển đổi ảnh chính...");
                const checkboxes = document.querySelectorAll('input[name="isMainImage"]');
                if (checkbox.checked) {
                    checkboxes.forEach(cb => {
                        if (cb !== checkbox) {
                            cb.checked = false;
                            cb.disabled = true;
                        }
                    });
                } else {
                    checkboxes.forEach(cb => {
                        cb.disabled = false;
                    });
                }
            }

            // Update variant options after removal or addition
            function updateVariantOptions() {
                console.log("Cập nhật tùy chọn biến thể...");
                const variants = document.querySelectorAll('#variants-container .variant-row');
                console.log("Tìm thấy " + variants.length + " hàng biến thể.");
                variants.forEach((variant, index) => {
                    const sizeSelect = variant.querySelector('select[name="size"]');
                    const colorSelect = variant.querySelector('select[name="color"]');
                    if (sizeSelect && colorSelect) {
                        console.log(`Kiểm tra biến thể ${index + 1}: Size=${sizeSelect.value}, Color=${colorSelect.value}`);
                        validateField(sizeSelect);
                        validateField(colorSelect);
                    } else {
                        console.error(`Biến thể ${index + 1} thiếu phần tử select kích cỡ hoặc màu sắc.`);
                    }
                });
            }

            // Validate price input
            function validatePrice(field) {
                const value = field.value.replace(/\./g, '');
                const numberRegex = /^\d+(\.\d{3})*$|^\d+$/;
                field.classList.remove('is-invalid');
                if (!value || !numberRegex.test(value) || parseInt(value) <= 0) {
                    console.log(`Giá không hợp lệ: ${value}`);
                    field.classList.add('is-invalid');
                }
                // Trigger variant validation to check priceModifier against price
                const variants = document.querySelectorAll('#variants-container .variant-row');
                variants.forEach(variant => {
                    const priceModifierInput = variant.querySelector('input[name="priceModifier"]');
                    if (priceModifierInput) {
                        validateField(priceModifierInput);
                    }
                });
            }

            // Validate field
            function validateField(field) {
                const variantRow = field.closest('.variant-row');
                if (!variantRow) {
                    console.error("Không tìm thấy hàng biến thể cho trường:", field);
                    return;
                }
                const name = field.name;
                const value = field.value;
                const validSizes = ['S', 'M', 'L', 'XL', 'XS'];
                const validColors = ['Red', 'Blue', 'Green', 'Black', 'White', 'Yellow'];
                const numberRegex = /^\d+(\.\d{3})*$|^\d+$/;

                console.log(`Kiểm tra trường: Name=${name}, Value=${value}`);

                field.classList.remove('is-invalid');

                if (name === 'size' && (!value || !validSizes.includes(value))) {
                    field.classList.add('is-invalid');
                    field.nextElementSibling.textContent = 'Vui lòng chọn một kích cỡ hợp lệ.';
                } else if (name === 'color' && (!value || !validColors.includes(value))) {
                    field.classList.add('is-invalid');
                    field.nextElementSibling.textContent = 'Vui lòng chọn một màu sắc hợp lệ.';
                } else if (name === 'priceModifier') {
                    const priceInput = document.querySelector('input[name="price"]');
                    const priceStr = priceInput ? priceInput.value.replace(/\./g, '') : '0';
                    const price = priceStr && numberRegex.test(priceStr) ? parseInt(priceStr) : 0;
                    const modifierStr = value.replace(/\./g, '');
                    if (!modifierStr || !numberRegex.test(modifierStr)) {
                        field.classList.add('is-invalid');
                        field.nextElementSibling.textContent = 'Giá biến thể không hợp lệ (ví dụ: 450000).';
                    } else {
                        const modifier = parseInt(modifierStr);
                        if (modifier < price) {
                            field.classList.add('is-invalid');
                            field.nextElementSibling.textContent = `Giá biến thể (${modifier}) phải lớn hơn hoặc bằng giá cơ bản (${price}).`;
                        }
                    }
                }

                // Kiểm tra trùng lặp chỉ khi cả size và color hợp lệ
                const sizeSelect = variantRow.querySelector('select[name="size"]');
                const colorSelect = variantRow.querySelector('select[name="color"]');
                if (sizeSelect && colorSelect) {
                    const size = sizeSelect.value;
                    const color = colorSelect.value;
                    console.log(`Kiểm tra trùng lặp: Size=${size}, Color=${color} trong ${variantRow}`);
                    if (validSizes.includes(size) && validColors.includes(color)) {
                        const variants = document.querySelectorAll('#variants-container .variant-row');
                        let duplicateCount = 0;
                        variants.forEach((variant, index) => {
                            if (variant !== variantRow) { // Loại trừ biến thể hiện tại
                                const vSize = variant.querySelector('select[name="size"]')?.value || '';
                                const vColor = variant.querySelector('select[name="color"]')?.value || '';
                                if (vSize && vColor && validSizes.includes(vSize) && validColors.includes(vColor) && vSize === size && vColor === color) {
                                    duplicateCount++;
                                    console.log(`Tìm thấy trùng lặp với biến thể ${index + 1}: Size=${vSize}, Color=${vColor}`);
                                }
                            }
                        });
                        if (duplicateCount > 0) {
                            sizeSelect.classList.add('is-invalid');
                            colorSelect.classList.add('is-invalid');
                            sizeSelect.nextElementSibling.textContent = `Trùng kích cỡ (${size}) và màu (${color}) với biến thể khác.`;
                            colorSelect.nextElementSibling.textContent = `Trùng kích cỡ (${size}) và màu (${color}) với biến thể khác.`;
                        } else {
                            sizeSelect.classList.remove('is-invalid');
                            colorSelect.classList.remove('is-invalid');
                        }
                    } else if (!size || !color) {
                        // Không báo lỗi nếu size hoặc color chưa chọn
                        sizeSelect.classList.remove('is-invalid');
                        colorSelect.classList.remove('is-invalid');
                    }
                }
            }

            // Filter child categories
            function filterChildCategories() {
                console.log("Lọc danh mục con...");
                const parentCategoryId = document.getElementById('parentCategoryId')?.value || '';
                const categorySelect = document.getElementById('categoryId');
                if (categorySelect) {
                    const options = categorySelect.querySelectorAll('option:not([value=""])');
                    options.forEach(option => {
                        const parentId = option.getAttribute('data-parent-id');
                        option.style.display = parentCategoryId === '' || parentId === parentCategoryId ? 'block' : 'none';
                    });
                    categorySelect.value = '';
                    console.log("Đã lọc danh mục con.");
                } else {
                    console.error("Không tìm thấy select danh mục!");
                }
            }

            // Form validation on submit
            document.addEventListener('DOMContentLoaded', function() {
                console.log("Trang đã tải, thiết lập sự kiện...");
                initializeVariants();

                const form = document.querySelector('form');
                if (form) {
                    form.addEventListener('submit', function(e) {
                        console.log("Hành động gửi form...");
                        const priceInput = document.querySelector('input[name="price"]');
                        const nameInput = document.querySelector('input[name="name"]');
                        const categorySelect = document.querySelector('select[name="categoryId"]');
                        const brandSelect = document.querySelector('select[name="brandId"]');
                        const materialInput = document.querySelector('input[name="material"]');
                        const sizes = document.querySelectorAll('#variants-container .variant-row select[name="size"]');
                        const colors = document.querySelectorAll('#variants-container .variant-row select[name="color"]');
                        const priceModifiers = document.querySelectorAll('#variants-container .variant-row input[name="priceModifier"]');
                        const images = document.querySelectorAll('input[name="images"]');
                        const numberRegex = /^\d+(\.\d{3})*$|^\d+$/;
                        const validSizes = ['S', 'M', 'L', 'XL', 'XS'];
                        const validColors = ['Red', 'Blue', 'Green', 'Black', 'White', 'Yellow'];
                        const errors = [];

                        // Xóa trạng thái kiểm tra trước đó
                        nameInput.classList.remove('is-invalid');
                        priceInput.classList.remove('is-invalid');
                        categorySelect.classList.remove('is-invalid');
                        brandSelect.classList.remove('is-invalid');
                        materialInput.classList.remove('is-invalid');
                        sizes.forEach(s => s.classList.remove('is-invalid'));
                        colors.forEach(c => c.classList.remove('is-invalid'));
                        priceModifiers.forEach(p => p.classList.remove('is-invalid'));

                        // Kiểm tra các trường cơ bản
                        if (!nameInput.value.trim()) {
                            errors.push('Tên sản phẩm là bắt buộc.');
                            nameInput.classList.add('is-invalid');
                        }
                        let price = 0;
                        if (priceInput) {
                            const priceStr = priceInput.value.replace(/\./g, '');
                            if (!numberRegex.test(priceStr) || parseInt(priceStr) <= 0) {
                                errors.push('Định dạng giá không hợp lệ (ví dụ: 450000 hoặc 450.000).');
                                priceInput.classList.add('is-invalid');
                            } else {
                                price = parseInt(priceStr);
                            }
                        }
                        if (!categorySelect.value) {
                            errors.push('Danh mục là bắt buộc.');
                            categorySelect.classList.add('is-invalid');
                        }
                        if (!brandSelect.value) {
                            errors.push('Thương hiệu là bắt buộc.');
                            brandSelect.classList.add('is-invalid');
                        }
                        if (!materialInput.value.trim()) {
                            errors.push('Chất liệu là bắt buộc.');
                            materialInput.classList.add('is-invalid');
                        }

                        // Kiểm tra biến thể
                        if (sizes.length === 0) {
                            errors.push('Ít nhất một biến thể là bắt buộc.');
                        } else {
                            sizes.forEach((size, i) => {
                                if (!validSizes.includes(size.value)) {
                                    errors.push(`Kích cỡ không hợp lệ trong biến thể ${i + 1}.`);
                                    size.classList.add('is-invalid');
                                }
                            });
                            colors.forEach((color, i) => {
                                if (!validColors.includes(color.value)) {
                                    errors.push(`Màu sắc không hợp lệ trong biến thể ${i + 1}.`);
                                    color.classList.add('is-invalid');
                                }
                            });
                            priceModifiers.forEach((pm, i) => {
                                const modifierStr = pm.value.replace(/\./g, '');
                                if (!modifierStr || !numberRegex.test(modifierStr)) {
                                    errors.push(`Giá biến thể không hợp lệ trong biến thể ${i + 1}.`);
                                    pm.classList.add('is-invalid');
                                } else {
                                    const modifier = parseInt(modifierStr);
                                    if (modifier < price) {
                                        errors.push(`Giá biến thể (${modifier}) trong biến thể ${i + 1} phải lớn hơn hoặc bằng giá cơ bản (${price}).`);
                                        pm.classList.add('is-invalid');
                                    }
                                }
                            });
                        }

                        // Kiểm tra ảnh
                        if (images.length === 0) {
                            errors.push('Ít nhất một ảnh là bắt buộc.');
                        }
                        for (let i = 0; i < images.length; i++) {
                            if (!images[i].value) {
                                errors.push(`Vui lòng chọn ảnh để tải lên ${i + 1}.`);
                                images[i].classList.add('is-invalid');
                            }
                        }

                        const mainImages = document.querySelectorAll('input[name="isMainImage"]:checked');
                        if (mainImages.length > 1) {
                            errors.push('Chỉ được chọn một ảnh chính.');
                        } else if (mainImages.length === 0 && images.length > 0) {
                            errors.push('Vui lòng chọn một ảnh chính.');
                        }

                        if (errors.length > 0) {
                            e.preventDefault();
                            console.log("Tìm thấy lỗi: ", errors);
                            alert('Vui lòng sửa các lỗi sau:\n- ' + errors.join('\n- '));
                        } else {
                            console.log("Không có lỗi, gửi form...");
                        }
                    });
                }

                const variantsContainer = document.getElementById('variants-container');
                if (variantsContainer) {
                    variantsContainer.addEventListener('input', function(e) {
                        if (e.target.name === 'size' || e.target.name === 'color' || e.target.name === 'priceModifier') {
                            validateField(e.target);
                        }
                    });
                    variantsContainer.addEventListener('click', function(e) {
                        if (e.target.closest('.btn-danger')) {
                            updateVariantOptions();
                        }
                    });
                }

                filterChildCategories();
            });
        </script>
    </body>
</html>