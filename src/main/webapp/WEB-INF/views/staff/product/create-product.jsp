<%@page import="java.math.BigDecimal"%>
<%@page import="model.Users"%>
<%@page import="model.Category"%>
<%@page import="model.Brand"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="java.text.DecimalFormatSymbols"%>
<%@page import="java.util.List"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
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
        DecimalFormat df = new DecimalFormat("#,###.##", symbols);
        return df.format(price);
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Add New Product</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/admin-dashboard/css/admin-css.css">
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
                                <p class="text-danger"><%= err %></p>
                            <% } %>
                            <form action="${pageContext.request.contextPath}/ProductManager" method="post" enctype="multipart/form-data" class="mt-3">
                                <input type="hidden" name="action" value="create">
                                <div class="mb-3">
                                    <label class="form-label">Name</label>
                                    <input type="text" name="name" class="form-control" required>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Description</label>
                                    <textarea name="description" class="form-control"></textarea>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Price</label>
                                    <input type="text" name="price" min="1000" max="1000000" class="form-control" placeholder="e.g., 1.000.000" required>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Parent Category</label>
                                    <select name="parentCategoryId" id="parentCategoryId" class="form-select" onchange="filterChildCategories()">
                                        <option value="">Select a parent category</option>
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
                                    <label class="form-label">Category</label>
                                    <select name="categoryId" id="categoryId" class="form-select" required>
                                        <option value="">Select a category</option>
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
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Brand</label>
                                    <select name="brandId" class="form-select" required>
                                        <option value="">Select a brand</option>
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
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Material</label>
                                    <input type="text" name="material" class="form-control" required>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Status</label>
                                    <select name="status" class="form-select">
                                        <option value="Active">Active</option>
                                        <option value="Discontinued">Discontinued</option>
                                    </select>
                                </div>
                                <h4>Variants</h4>
                                <div id="variants-container" class="mb-3">
                                    <div class="variant-row mb-3">
                                        <div class="row">
                                            <div class="col-md-4">
                                                <input type="text" name="size" class="form-control" placeholder="Size" required>
                                            </div>
                                            <div class="col-md-4">
                                                <input type="text" name="color" class="form-control" placeholder="Color" required>
                                            </div>
                                            <div class="col-md-3">
                                                <input type="text" name="priceModifier" class="form-control" placeholder="Price Modifier (e.g., -5,00, 0,00)" required>
                                            </div>
                                            <div class="col-md-1">
                                                <button type="button" class="btn btn-danger btn-sm" onclick="removeElement(this); updateVariantOptions()">
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
                                            </div>
                                            <div class="col-md-3">
                                                <div class="form-check">
                                                    <input type="checkbox" name="isMainImage" value="true" class="form-check-input" onchange="toggleMainImage(this)">
                                                    <label class="form-check-label">Main Image</label>
                                                </div>
                                            </div>
                                            <div class="col-md-2">
                                                <button type="button" class="btn btn-danger btn-sm" onclick="removeElement(this); updateVariantOptions()">
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
            // Hàm xóa phần tử
            function removeElement(button) {
                const row = button.parentElement.parentElement.parentElement;
                if (row) {
                    row.parentElement.removeChild(row);
                    console.log("Element removed.");
                } else {
                    console.error("Row not found for removal!");
                }
            }

            // Hàm thêm Variant
            function addVariant() {
                console.log("Adding new variant...");
                const container = document.getElementById('variants-container');
                if (!container) {
                    console.error("Container 'variants-container' not found!");
                    return;
                }
                const variantDiv = document.createElement('div');
                variantDiv.className = 'variant-row mb-3';
                variantDiv.innerHTML = `
                    <div class="row">
                        <div class="col-md-4">
                            <input type="text" name="size" class="form-control" placeholder="Size" required>
                        </div>
                        <div class="col-md-4">
                            <input type="text" name="color" class="form-control" placeholder="Color" required>
                        </div>
                        <div class="col-md-3">
                            <input type="text" name="priceModifier" class="form-control" placeholder="Price Modifier (e.g., -5,00, 0,00)" required>
                        </div>
                        <div class="col-md-1">
                            <button type="button" class="btn btn-danger btn-sm" onclick="removeElement(this); updateVariantOptions()">
                                <i class="bi bi-trash"></i> Remove
                            </button>
                        </div>
                    </div>
                `;
                container.appendChild(variantDiv);
                updateVariantOptions();
                console.log("Variant added successfully.");
            }

            // Hàm thêm Image
            function addImage() {
                console.log("Adding new image...");
                const container = document.getElementById('images-container');
                if (!container) {
                    console.error("Container 'images-container' not found!");
                    return;
                }
                const imageDiv = document.createElement('div');
                imageDiv.className = 'image-row mb-3';
                imageDiv.innerHTML = `
                    <div class="row">
                        <div class="col-md-7">
                            <input type="file" name="images" class="form-control" accept="image/jpeg,image/png,image/gif" required>
                        </div>
                        <div class="col-md-3">
                            <div class="form-check">
                                <input type="checkbox" name="isMainImage" value="true" class="form-check-input" onchange="toggleMainImage(this)">
                                <label class="form-check-label">Main Image</label>
                            </div>
                        </div>
                        <div class="col-md-2">
                            <button type="button" class="btn btn-danger btn-sm" onclick="removeElement(this); updateVariantOptions()">
                                <i class="bi bi-trash"></i> Remove
                            </button>
                        </div>
                    </div>
                `;
                container.appendChild(imageDiv);
                updateVariantOptions();
                console.log("Image added successfully.");
            }

            // Hàm kiểm soát checkbox Main Image
            function toggleMainImage(checkbox) {
                console.log("Toggling Main Image...");
                const checkboxes = document.querySelectorAll('input[name="isMainImage"]');
                if (checkbox.checked) {
                    checkboxes.forEach(cb => {
                        if (cb !== checkbox) {
                            cb.checked = false;
                            cb.disabled = true; // Vô hiệu hóa các checkbox khác
                        }
                    });
                } else {
                    checkboxes.forEach(cb => {
                        cb.disabled = false; // Kích hoạt lại nếu không có checkbox nào được chọn
                    });
                }
            }

            // Hàm lấy danh sách tùy chọn biến thể (giờ không cần vì xóa No Variant)
            function getVariantOptions() {
                console.log("Generating variant options (no longer needed due to No Variant removal)...");
                return ""; // Không sử dụng nữa
            }

            // Hàm cập nhật danh sách biến thể (giờ chỉ để cập nhật UI)
            function updateVariantOptions() {
                console.log("Updating variant options (no action needed due to No Variant removal)...");
                // Không cần cập nhật select box nữa
            }

            // Hàm lọc danh mục con
            function filterChildCategories() {
                console.log("Filtering child categories...");
                const parentCategoryId = document.getElementById('parentCategoryId')?.value || '';
                const categorySelect = document.getElementById('categoryId');
                if (categorySelect) {
                    const options = categorySelect.querySelectorAll('option:not([value=""])');
                    options.forEach(option => {
                        const parentId = option.getAttribute('data-parent-id');
                        option.style.display = parentCategoryId === '' || parentId === parentCategoryId ? 'block' : 'none';
                    });
                    categorySelect.value = '';
                    console.log("Child categories filtered.");
                } else {
                    console.error("Category select not found!");
                }
            }

            // Sự kiện khi trang tải
            document.addEventListener('DOMContentLoaded', function() {
                console.log("Page loaded, setting up event listeners...");
                const form = document.querySelector('form');
                if (form) {
                    form.addEventListener('submit', function(e) {
                        console.log("Form submit triggered...");
                        const priceInput = document.querySelector('input[name="price"]');
                        const sizes = document.querySelectorAll('input[name="size"]');
                        const colors = document.querySelectorAll('input[name="color"]');
                        const priceModifiers = document.querySelectorAll('input[name="priceModifier"]');
                        const images = document.querySelectorAll('input[name="images"]');
                        const numberRegex = /^-?\d+(\,\d{1,2})?$/;

                        if (priceInput) {
                            const priceStr = priceInput.value.replace(/\./g, '').replace(',', '.');
                            if (!numberRegex.test(priceInput.value) || parseFloat(priceStr) <= 0) {
                                e.preventDefault();
                                alert('Price must be a valid positive number (e.g., 1.000.000,00)');
                                return;
                            }
                        } else {
                            console.error("Price input not found!");
                        }

                        if (sizes.length === 0) {
                            e.preventDefault();
                            alert('At least one variant is required');
                            return;
                        }
                        for (let i = 0; i < sizes.length; i++) {
                            if (!sizes[i].value.trim()) {
                                e.preventDefault();
                                alert('Size cannot be empty for variant ' + (i + 1));
                                return;
                            }
                            if (!colors[i].value.trim()) {
                                e.preventDefault();
                                alert('Color cannot be empty for variant ' + (i + 1));
                                return;
                            }
                            if (!priceModifiers[i].value.trim() || !numberRegex.test(priceModifiers[i].value)) {
                                e.preventDefault();
                                alert('Price Modifier must be a valid number for variant ' + (i + 1) + ' (e.g., -5,00, 0,00, 5,50)');
                                return;
                            }
                            const modifierStr = priceModifiers[i].value.replace(/\./g, '').replace(',', '.');
                            const modifier = parseFloat(modifierStr);
                            const price = priceInput ? parseFloat(priceInput.value.replace(/\./g, '').replace(',', '.')) : 0;
                            if (price + modifier < 0) {
                                e.preventDefault();
                                alert('Price Modifier for variant ' + (i + 1) + ' makes total price negative (' + (price + modifier) + '). Total price must be non-negative.');
                                return;
                            }
                        }

                        if (images.length === 0) {
                            e.preventDefault();
                            alert('At least one image is required');
                            return;
                        }
                        for (let i = 0; i < images.length; i++) {
                            if (!images[i].value) {
                                e.preventDefault();
                                alert('Please select an image for upload ' + (i + 1));
                                return;
                            }
                        }

                        const mainImages = document.querySelectorAll('input[name="isMainImage"]:checked');
                        if (mainImages.length > 1) {
                            e.preventDefault();
                            alert('Only one image can be set as the main image');
                            return;
                        } else if (mainImages.length === 0) {
                            e.preventDefault();
                            alert('Please select at least one image as the main image');
                            return;
                        }
                    });
                } else {
                    console.error("Form not found!");
                }

                const variantsContainer = document.getElementById('variants-container');
                if (variantsContainer) {
                    variantsContainer.addEventListener('input', updateVariantOptions);
                    variantsContainer.addEventListener('click', function(e) {
                        if (e.target.closest('.btn-danger')) {
                            updateVariantOptions();
                        }
                    });
                } else {
                    console.error("Variants container not found!");
                }

                const sidebarItems = document.querySelectorAll('.sidebar-menu li');
                if (sidebarItems.length > 0) {
                    sidebarItems.forEach(li => li.classList.remove('active'));
                    const treeviews = document.querySelectorAll('.sidebar-menu .treeview.menu-open');
                    treeviews.forEach(li => li.classList.remove('menu-open'));
                    const currentAction = "${requestScope.currentAction}";
                    const currentModule = "${requestScope.currentModule}";
                    if (currentAction && currentModule) {
                        const activeLink = document.querySelector(`.sidebar-menu a[href*="${currentAction}"][href*="${currentModule}"]`);
                        if (activeLink) {
                            activeLink.parentElement.classList.add('active');
                            const parentTreeview = activeLink.closest('.treeview');
                            if (parentTreeview) {
                                parentTreeview.classList.add('active');
                                parentTreeview.classList.add('menu-open');
                            }
                        }
                    }
                } else {
                    console.warn("No sidebar items found!");
                }

                filterChildCategories();
            });
        </script>
    </body>
</html>