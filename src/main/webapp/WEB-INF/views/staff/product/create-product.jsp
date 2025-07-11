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
        DecimalFormat df = new DecimalFormat("#,###", symbols);
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
                                    <label class="form-label">Name <span class="text-danger">*</span></label>
                                    <input type="text" name="name" class="form-control" required>
                                    <div class="invalid-feedback">Product name is required.</div>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Description</label>
                                    <textarea name="description" class="form-control"></textarea>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Price <span class="text-danger">*</span></label>
                                    <input type="text" name="price" class="form-control" placeholder="e.g., 450000 or 450.000" required>
                                    <div class="invalid-feedback">Invalid price format.</div>
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
                                    <label class="form-label">Category <span class="text-danger">*</span></label>
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
                                    <div class="invalid-feedback">Category is required.</div>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Brand <span class="text-danger">*</span></label>
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
                                    <div class="invalid-feedback">Brand is required.</div>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Material <span class="text-danger">*</span></label>
                                    <input type="text" name="material" class="form-control" required>
                                    <div class="invalid-feedback">Material is required.</div>
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
                                                <select name="size" class="form-control" required onchange="validateField(this)">
                                                    <option value="" disabled selected>Select Size</option>
                                                    <option value="S">S</option>
                                                    <option value="M">M</option>
                                                    <option value="L">L</option>
                                                    <option value="XL">XL</option>
                                                    <option value="XS">XS</option>
                                                </select>
                                                <div class="invalid-feedback">Invalid size.</div>
                                            </div>
                                            <div class="col-md-4">
                                                <select name="color" class="form-control" required onchange="validateField(this)">
                                                    <option value="" disabled selected>Select Color</option>
                                                    <option value="Red">Red</option>
                                                    <option value="Blue">Blue</option>
                                                    <option value="Green">Green</option>
                                                    <option value="Black">Black</option>
                                                    <option value="White">White</option>
                                                    <option value="Yellow">Yellow</option>
                                                </select>
                                                <div class="invalid-feedback">Invalid color.</div>
                                            </div>
                                            <div class="col-md-3">
                                                <input type="text" name="priceModifier" class="form-control" placeholder="e.g., 0 or 5000" required oninput="validateField(this)">
                                                <div class="invalid-feedback">Invalid price modifier.</div>
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
                            <select name="size" class="form-control" required onchange="validateField(this)">
                                <option value="" disabled selected>Select Size</option>
                                <option value="S">S</option>
                                <option value="M">M</option>
                                <option value="L">L</option>
                                <option value="XL">XL</option>
                                <option value="XS">XS</option>
                            </select>
                            <div class="invalid-feedback">Invalid size.</div>
                        </div>
                        <div class="col-md-4">
                            <select name="color" class="form-control" required onchange="validateField(this)">
                                <option value="" disabled selected>Select Color</option>
                                <option value="Red">Red</option>
                                <option value="Blue">Blue</option>
                                <option value="Green">Green</option>
                                <option value="Black">Black</option>
                                <option value="White">White</option>
                                <option value="Yellow">Yellow</option>
                            </select>
                            <div class="invalid-feedback">Invalid color.</div>
                        </div>
                        <div class="col-md-3">
                            <input type="text" name="priceModifier" class="form-control" placeholder="e.g., 0 or 5000" required oninput="validateField(this)">
                            <div class="invalid-feedback">Invalid price modifier.</div>
                        </div>
                        <div class="col-md-1">
                            <button type="button" class="btn btn-danger btn-sm" onclick="removeElement(this)">
                                <i class="bi bi-trash"></i> Remove
                            </button>
                        </div>
                    </div>
                `;
                container.appendChild(variantDiv);
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
                            <button type="button" class="btn btn-danger btn-sm" onclick="removeElement(this)">
                                <i class="bi bi-trash"></i> Remove
                            </button>
                        </div>
                    </div>
                `;
                container.appendChild(imageDiv);
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
                            cb.disabled = true;
                        }
                    });
                } else {
                    checkboxes.forEach(cb => {
                        cb.disabled = false;
                    });
                }
            }

            // Hàm validate field
            function validateField(field) {
                const variantRow = field.closest('.variant-row');
                const name = field.name;
                const value = field.value;
                const validSizes = ['S', 'M', 'L', 'XL', 'XS'];
                const validColors = ['Red', 'Blue', 'Green', 'Black', 'White', 'Yellow'];
                const numberRegex = /^\d+(\.\d{3})*$|^\d+$/;

                // Clear previous validation state for this field
                field.classList.remove('is-invalid');

                // Validate the specific field
                if (name === 'size' && (!value || !validSizes.includes(value))) {
                    field.classList.add('is-invalid');
                } else if (name === 'color' && (!value || !validColors.includes(value))) {
                    field.classList.add('is-invalid');
                } else if (name === 'priceModifier') {
                    const modifierStr = value.replace(/\./g, '');
                    if (!modifierStr || !numberRegex.test(modifierStr) || parseInt(modifierStr) < 0) {
                        field.classList.add('is-invalid');
                    }
                }

                // Check for duplicates only for the current variant
                if ((name === 'size' || name === 'color') && value) {
                    const size = variantRow.querySelector('select[name="size"]').value;
                    const color = variantRow.querySelector('select[name="color"]').value;
                    if (size && color) {
                        const variants = document.querySelectorAll('.variant-row');
                        let duplicateCount = 0;
                        variants.forEach(variant => {
                            const vSize = variant.querySelector('select[name="size"]').value;
                            const vColor = variant.querySelector('select[name="color"]').value;
                            if (vSize === size && vColor === color) {
                                duplicateCount++;
                            }
                        });
                        if (duplicateCount > 1) {
                            variantRow.querySelector('select[name="size"]').classList.add('is-invalid');
                            variantRow.querySelector('select[name="color"]').classList.add('is-invalid');
                        } else {
                            variantRow.querySelector('select[name="size"]').classList.remove('is-invalid');
                            variantRow.querySelector('select[name="color"]').classList.remove('is-invalid');
                        }
                    }
                }
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
                        const nameInput = document.querySelector('input[name="name"]');
                        const categorySelect = document.querySelector('select[name="categoryId"]');
                        const brandSelect = document.querySelector('select[name="brandId"]');
                        const materialInput = document.querySelector('input[name="material"]');
                        const sizes = document.querySelectorAll('select[name="size"]');
                        const colors = document.querySelectorAll('select[name="color"]');
                        const priceModifiers = document.querySelectorAll('input[name="priceModifier"]');
                        const images = document.querySelectorAll('input[name="images"]');
                        const numberRegex = /^\d+(\.\d{3})*$|^\d+$/;
                        const errors = [];

                        // Clear previous validation states
                        nameInput.classList.remove('is-invalid');
                        priceInput.classList.remove('is-invalid');
                        categorySelect.classList.remove('is-invalid');
                        brandSelect.classList.remove('is-invalid');
                        materialInput.classList.remove('is-invalid');
                        sizes.forEach(s => s.classList.remove('is-invalid'));
                        colors.forEach(c => c.classList.remove('is-invalid'));
                        priceModifiers.forEach(p => p.classList.remove('is-invalid'));

                        // Validate name
                        if (!nameInput.value.trim()) {
                            errors.push('Product name is required.');
                            nameInput.classList.add('is-invalid');
                        }

                        // Validate price
                        if (priceInput) {
                            const priceStr = priceInput.value.replace(/\./g, '');
                            if (!numberRegex.test(priceStr) || parseInt(priceStr) <= 0) {
                                errors.push('Invalid price format.');
                                priceInput.classList.add('is-invalid');
                            }
                        } else {
                            errors.push('Price input is missing.');
                        }
                        const price = priceInput ? parseInt(priceInput.value.replace(/\./g, '')) : 0;

                        // Validate category
                        if (!categorySelect.value) {
                            errors.push('Category is required.');
                            categorySelect.classList.add('is-invalid');
                        }

                        // Validate brand
                        if (!brandSelect.value) {
                            errors.push('Brand is required.');
                            brandSelect.classList.add('is-invalid');
                        }

                        // Validate material
                        if (!materialInput.value.trim()) {
                            errors.push('Material is required.');
                            materialInput.classList.add('is-invalid');
                        }

                        // Validate variants
                        if (sizes.length === 0) {
                            errors.push('At least one variant is required.');
                        } else {
                            const validSizes = ['S', 'M', 'L', 'XL', 'XS'];
                            const validColors = ['Red', 'Blue', 'Green', 'Black', 'White', 'Yellow'];
                            const combinations = new Set();
                            for (let i = 0; i < sizes.length; i++) {
                                const size = sizes[i].value;
                                const color = colors[i].value;
                                const priceModifier = priceModifiers[i].value;
                                if (!size || !validSizes.includes(size)) {
                                    errors.push(`Invalid size in variant ${i + 1}.`);
                                    sizes[i].classList.add('is-invalid');
                                }
                                if (!color || !validColors.includes(color)) {
                                    errors.push(`Invalid color in variant ${i + 1}.`);
                                    colors[i].classList.add('is-invalid');
                                }
                                if (!priceModifier || !numberRegex.test(priceModifier)) {
                                    errors.push(`Invalid price modifier in variant ${i + 1}.`);
                                    priceModifiers[i].classList.add('is-invalid');
                                } else {
                                    const modifierStr = priceModifier.replace(/\./g, '');
                                    const modifier = parseInt(modifierStr);
                                    if (modifier < 0) {
                                        errors.push(`Price modifier in variant ${i + 1} cannot be negative.`);
                                        priceModifiers[i].classList.add('is-invalid');
                                    }
                                    if (price + modifier < price) {
                                        errors.push(`Price modifier in variant ${i + 1} makes total price less than base price.`);
                                        priceModifiers[i].classList.add('is-invalid');
                                    }
                                }
                                if (size && color) {
                                    const combo = `${size}-${color}`;
                                    if (combinations.has(combo)) {
                                        errors.push(`Duplicate size and color in variant ${i + 1}.`);
                                        sizes[i].classList.add('is-invalid');
                                        colors[i].classList.add('is-invalid');
                                    } else {
                                        combinations.add(combo);
                                    }
                                }
                            }
                        }

                        // Validate images
                        if (images.length === 0) {
                            errors.push('At least one image is required.');
                        }
                        for (let i = 0; i < images.length; i++) {
                            if (!images[i].value) {
                                errors.push(`Please select an image for upload ${i + 1}.`);
                            }
                        }

                        const mainImages = document.querySelectorAll('input[name="isMainImage"]:checked');
                        if (mainImages.length > 1) {
                            errors.push('Only one image can be set as the main image.');
                        } else if (mainImages.length === 0) {
                            errors.push('A main image is required.');
                        }

                        // Display all errors in one alert
                        if (errors.length > 0) {
                            e.preventDefault();
                            alert('Please correct the following:\n- ' + errors.join('\n- '));
                        }
                    });
                } else {
                    console.error("Form not found!");
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