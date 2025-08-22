<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Edit Product</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
        <link href='https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css' rel='stylesheet'>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/admin-dashboard/css/admin-css.css">
        <style>
            body {
                background-color: #f8f9fa;
                font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                color: #2d3748;
                margin: 0;
                overflow-x: hidden;
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
            .form-container {
                max-width: 800px;
                margin: 0 auto;
                background-color: #fff;
                padding: 2rem;
                border-radius: 8px;
                box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            }
            .form-label {
                font-weight: 600;
                font-size: 0.9rem;
            }
            .form-control, .form-select {
                border-radius: 6px;
                font-size: 0.9rem;
            }
            .btn {
                border-radius: 6px;
                padding: 0.4rem 0.8rem;
                font-size: 0.85rem;
            }
            .alert {
                border-radius: 6px;
                margin-bottom: 1rem;
                font-size: 0.9rem;
            }
            .variant-container, .image-container {
                border: 1px solid #dee2e6;
                padding: 1rem;
                border-radius: 6px;
                margin-bottom: 1rem;
            }
            .variant-row, .image-row {
                display: flex;
                gap: 1rem;
                align-items: center;
                margin-bottom: 0.5rem;
            }
            .image-row input[type="file"] {
                flex-grow: 1;
            }
            .image-row input[type="radio"] {
                margin-left: 1rem;
            }

            /* CSS FOR IMAGE PREVIEW */
            .image-preview {
                width: 80px;
                height: 80px;
                object-fit: cover;
                border-radius: 6px;
                border: 1px solid #dee2e6;
            }

            @media (max-width: 768px) {
                .content-area {
                    margin-left: 0;
                    width: 100%;
                }
                .form-container {
                    padding: 1rem;
                }
                .variant-row, .image-row {
                    flex-direction: column;
                    align-items: stretch;
                }
            }
        </style>
    </head>
    <body>
        <c:set var="currentAction" value="products" scope="request"/>
        <c:set var="currentModule" value="admin" scope="request"/>
        <c:set var="pageTitle" value="Edit Product" scope="request"/>
        <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp" />
        <div class="content-area">
            <h2 style="text-align: center;">Edit Product</h2>
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger"><c:out value="${errorMessage}"/></div>
            </c:if>
            <c:if test="${param.success == 'true'}">
                <div class="alert alert-success">Product updated successfully!</div>
            </c:if>
            <div class="form-container">
                <form action="${pageContext.request.contextPath}/ProductEditAdmin" method="post" enctype="multipart/form-data">
                    <input type="hidden" name="productId" value="${product.productId}">
                    <div class="mb-3">
                        <label for="name" class="form-label">Product Name</label>
                        <input type="text" class="form-control" id="name" name="name"
                               value="${product.name}" required>
                    </div>
                    <div class="mb-3">
                        <label for="status" class="form-label">Status</label>
                        <select class="form-select" id="status" name="status">
                            <option value="Active" ${product.status == 'Active' ? 'selected' : ''}>Active</option>
                            <option value="Inactive" ${product.status == 'Inactive' ? 'selected' : ''}>Inactive</option>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label for="categoryId" class="form-label">Category <span class="text-danger">*</span></label>
                        <select class="form-select" id="categoryId" name="categoryId" required>
                            <option value="" disabled 
                                    <c:if test="${empty product.category || empty product.category.categoryId}">selected</c:if>>
                                        Select Category
                                    </option>
                            <c:forEach var="category" items="${categories}">
                                <c:if test="${category != null && category.parentCategoryId != 0}">
                                    <c:set var="displayName" value="${category.name != null ? category.name : 'N/A'}" />
                                    <c:if test="${category.parentCategoryId != 0 && category.parentCategoryName != null}">
                                        <c:set var="displayName" value="${category.parentCategoryName} / ${category.name}" />
                                    </c:if>
                                    <option value="${category.categoryId}"
                                            <c:if test="${product.category != null && product.category.categoryId == category.categoryId}">selected</c:if>>
                                        <c:if test="${category.parentCategoryId != 0}">&nbsp;&nbsp;&nbsp;</c:if>
                                        <c:out value="${displayName}"/>
                                    </option>
                                </c:if>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="mb-3">
                        <label for="brandName" class="form-label">Brand <span class="text-danger">*</span></label>
                        <select class="form-select" id="brandName" name="brandName" required>
                            <option value="" disabled>Select Brand</option>
                            <c:forEach var="brand" items="${brands}">
                                <option value="${fn:escapeXml(brand.name)}" ${product.brand.name == brand.name ? 'selected' : ''}>
                                    <c:out value="${brand.name}"/>
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label for="material" class="form-label">Material</label>
                        <input type="text" class="form-control" id="material" name="material" value="${product.material}">
                    </div>
                    <div class="mb-3">
                        <label for="description" class="form-label">Description</label>
                        <textarea class="form-control" id="description" name="description" rows="4" required>${product.description}</textarea>
                    </div>


                    <div class="variant-container">
                        <h5>Product Variants <span class="text-danger">*</span></h5>
                        <div id="variants">
                            <c:forEach var="variant" items="${variants}">
                                <div class="variant-row">
                                    <input type="hidden" name="variantId[]" value="${variant.variantId}">
                                    <div class="flex-grow-1">
                                        <label class="form-label">Size <span class="text-danger">*</span></label>
                                        <select class="form-select" name="size[]" required>
                                            <option value="" disabled>Select Size</option>
                                            <option value="S" ${variant.size == 'S' ? 'selected' : ''}>S</option>
                                            <option value="M" ${variant.size == 'M' ? 'selected' : ''}>M</option>
                                            <option value="L" ${variant.size == 'L' ? 'selected' : ''}>L</option>
                                            <option value="XL" ${variant.size == 'XL' ? 'selected' : ''}>XL</option>
                                            <option value="XXL" ${variant.size == 'XXL' ? 'selected' : ''}>XXL</option>
                                        </select>
                                    </div>
                                    <div class="flex-grow-1">
                                        <label class="form-label">Color <span class="text-danger">*</span></label>
                                        <select class="form-select" name="color[]" required>
                                            <option value="" disabled>Select Color</option>
                                            <option value="Red" ${variant.color == 'Red' ? 'selected' : ''}>Red</option>
                                            <option value="Blue" ${variant.color == 'Blue' ? 'selected' : ''}>Blue</option>
                                            <option value="Black" ${variant.color == 'Black' ? 'selected' : ''}>Black</option>
                                            <option value="White" ${variant.color == 'White' ? 'selected' : ''}>White</option>
                                            <option value="Green" ${variant.color == 'Green' ? 'selected' : ''}>Green</option>
                                        </select>
                                    </div>
                                    <div class="flex-grow-1">
                                        <label class="form-label">Price Modifier (VND)</label>
                                        <input type="number" class="form-control" name="priceModifier[]" 
                                               value="${variant.priceModifier != null ? variant.priceModifier.longValue() : ''}" 
                                               step="1000" min="0" required>

                                    </div>
                                    <div>
                                        <button type="button" class="btn btn-danger mt-4 remove-variant"><i class="bi bi-trash"></i></button>
                                    </div>
                                    <input type="hidden" name="deleteVariant[]" class="deleteVariant" value="">
                                </div>
                            </c:forEach>
                        </div>
                        <button type="button" class="btn btn-primary mt-2" id="addVariant"><i class="bi bi-plus-circle"></i> Add Variant</button>
                    </div>

                    <div class="image-container">
                        <h5>Product Images <span class="text-danger">*</span></h5>
                        <div id="images">
                            <c:forEach var="image" items="${images}" varStatus="status">
                                <div class="image-row p-2 mb-2 border rounded">
                                    <input type="hidden" name="imageId[]" value="${image.imageId}">
                                    <input type="hidden" name="imageUrl[]" value="${image.imageUrl}"> <img src="${fn:escapeXml(image.imageUrl)}" alt="Image Preview" class="image-preview">

                                    <div class="form-check mx-3">
                                        <input class="form-check-input" type="radio" name="mainImage" id="mainImage${status.index}" value="${status.index}" ${image.main ? 'checked' : ''}>
                                        <label class="form-check-label" for="mainImage${status.index}">
                                            Main Image
                                        </label>
                                    </div>

                                    <button type="button" class="btn btn-danger ms-auto remove-image"><i class="bi bi-trash"></i></button>
                                    <input type="hidden" name="deleteImage[]" class="deleteImage" value="">
                                </div>
                            </c:forEach>

                            <div class="image-row new-image p-2 mb-2">
                                <div class="flex-grow-1">
                                    <label class="form-label">Add New Image</label>
                                    <input type="file" class="form-control" name="images[]" accept="image/*">
                                </div>
                                <div class="form-check mx-3">
                                    <input class="form-check-input" type="radio" name="mainImage" value="${fn:length(images)}">
                                    <label class="form-check-label">Main Image</label>
                                </div>
                                <div>
                                    <button type="button" class="btn btn-danger mt-4 remove-image"><i class="bi bi-trash"></i></button>
                                </div>
                            </div>
                        </div>
                        <button type="button" class="btn btn-primary mt-2" id="addImage"><i class="bi bi-plus-circle"></i> Add Image</button>
                    </div>

                    <div class="d-flex gap-2">
                        <button type="submit" class="btn btn-success"><i class="bi bi-save"></i> Save Changes</button>
                        <a href="${pageContext.request.contextPath}/ProductListAdmin" class="btn btn-secondary"><i class="bi bi-x-circle"></i> Cancel</a>
                    </div>
                </form>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
        <script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
        <script>
            // JavaScript code remains unchanged
            document.getElementById('addVariant').addEventListener('click', function () {
                const variantContainer = document.getElementById('variants');
                const variantRow = variantContainer.querySelector('.variant-row').cloneNode(true);
                variantRow.querySelectorAll('input').forEach(input => input.value = '');
                variantRow.querySelector('input[name="priceModifier[]"]').value = 0;
                variantRow.querySelectorAll('select').forEach(select => select.selectedIndex = 0);
                variantRow.querySelector('.deleteVariant').value = '';
                variantRow.querySelector('input[name="variantId[]"]').value = '0'; // Mark as new variant
                variantContainer.appendChild(variantRow);
            });
            document.addEventListener('click', function (e) {
                const removeBtn = e.target.closest('.remove-variant');
                if (removeBtn) {
                    const variantRow = removeBtn.closest('.variant-row');
                    if (document.querySelectorAll('.variant-row').length > 1) {
                        const variantIdInput = variantRow.querySelector('input[name="variantId"]');
                        if (variantIdInput.value && variantIdInput.value !== '0') {
                            variantRow.querySelector('.deleteVariant').value = variantIdInput.value;
                            variantRow.style.display = 'none';
                        } else {
                            variantRow.remove();
                        }
                    } else {
                        Swal.fire({icon: 'warning', title: 'Cannot Delete', text: 'At least one variant is required.'});
                    }
                }
            });
            document.getElementById('addImage').addEventListener('click', function () {
                const imageContainer = document.getElementById('images');
                const imageRow = imageContainer.querySelector('.new-image').cloneNode(true);
                const index = imageContainer.querySelectorAll('.image-row, .new-image').length;
                imageRow.querySelector('input[type="file"]').value = '';
                imageRow.querySelector('input[type="radio"]').value = index;
                imageRow.querySelector('input[type="radio"]').checked = false;
                imageContainer.appendChild(imageRow);
            });
            document.addEventListener('click', function (e) {
                const removeBtn = e.target.closest('.remove-image');
                if (removeBtn) {
                    const imageRow = removeBtn.closest('.image-row, .new-image');
                    if (document.querySelectorAll('.image-row, .new-image').length > 1) {
                        const imageIdInput = imageRow.querySelector('input[name="imageId"]');
                        if (imageIdInput && imageIdInput.value) {
                            imageRow.querySelector('.deleteImage').value = imageIdInput.value;
                            imageRow.style.display = 'none';
                        } else {
                            imageRow.remove();
                        }
                        const imageRows = document.querySelectorAll('.image-row, .new-image');
                        let mainImageChecked = false;
                        imageRows.forEach(row => {
                            if (row.querySelector('input[name="mainImage"]:checked')) {
                                mainImageChecked = true;
                            }
                        });
                        if (!mainImageChecked && imageRows.length > 0) {
                            const firstVisibleRow = Array.from(imageRows).find(row => row.style.display !== 'none');
                            if (firstVisibleRow) {
                                firstVisibleRow.querySelector('input[type="radio"]').checked = true;
                            }
                        }
                    } else {
                        Swal.fire({icon: 'warning', title: 'Cannot Delete', text: 'At least one image is required.'});
                    }
                }
            });
            document.querySelector('form').addEventListener('submit', function (e) {
                // Form validation logic remains unchanged
            });
        </script>
    </body>
</html>