<%--
    Document : createProduct
    Created on : Aug 10, 2025, 11:30:00 PM
    Author : Thinh
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Create New Product</title>
        <!-- Bootstrap CSS -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
        <!-- Font Awesome -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
        <!-- Bootstrap Icons -->
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
        <!-- BoxIcons -->
        <link href='https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css' rel='stylesheet'>
        <!-- Custom CSS -->
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
        <c:set var="pageTitle" value="Create New Product" scope="request"/>
        <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp" />
        <div class="content-area">
            <h2 style="text-align: center;">Create New Product</h2>
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger"><c:out value="${errorMessage}" escapeXml="false"/></div>
            </c:if>
            <div class="form-container">
                <form action="${pageContext.request.contextPath}/ProductCreateAdmin" method="post" enctype="multipart/form-data" id="createProductForm">
                    <div class="mb-3">
                        <label for="name" class="form-label">Product Name <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="name" name="name" 
                               value="${oldName != null ? oldName : ''}" required>

                    </div>
                    <!--                <div class="mb-3">
                                        <label for="price" class="form-label">Base Price (VND) <span class="text-danger">*</span></label>
                                        <input type="number" class="form-control" id="price" name="price" step="1000" min="0" required>
                                    </div>-->
                    <div class="mb-3">
                        <label for="categoryId" class="form-label">Category <span class="text-danger">*</span></label>
                        <select class="form-select" id="categoryId" name="categoryId" required>
                            <option value="" disabled 
                                    <c:if test="${empty oldCategoryId}">selected</c:if>>Select a category</option>
                            <c:forEach var="category" items="${categories}">
                                <c:if test="${category != null && category.parentCategoryId != 0}">
                                    <c:set var="displayName" value="${category.name != null ? category.name : 'N/A'}" />
                                    <c:if test="${category.parentCategoryId != 0 && category.parentCategoryName != null}">
                                        <c:set var="displayName" value="${category.parentCategoryName} / ${category.name}" />
                                    </c:if>
                                    <option value="${category.categoryId}"
                                            <c:if test="${oldCategoryId == category.categoryId}">selected</c:if>>
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
                            <option value="" disabled 
                                    <c:if test="${empty oldBrand}">selected</c:if>>Select a brand</option>
                            <c:forEach var="brand" items="${brands}">
                                <option value="${fn:escapeXml(brand.name)}"
                                        <c:if test="${oldBrand == brand.name}">selected</c:if>>
                                    <c:out value="${brand.name}"/>
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="mb-3">
                        <label for="material" class="form-label">Material</label>
                        <input type="text" class="form-control" id="material" name="material" 
                               value="${oldMaterial != null ? oldMaterial : ''}" required>

                    </div>
                    <div class="mb-3">
                        <label for="description" class="form-label">Description</label>
                        <textarea class="form-control" id="description" name="description" rows="4" required><c:out value="${oldDescription}" /></textarea>
                    </div>

                    <div class="variant-container">
                        <h5>Product Variants <span class="text-danger">*</span></h5>
                        <div id="variants">
                            <div class="variant-row">
                                <div class="flex-grow-1">
                                    <label class="form-label">Size <span class="text-danger">*</span></label>
                                    <select class="form-select" name="size[]" required>
                                        <option value="" disabled selected>Select size</option>
                                        <option value="S">S</option>
                                        <option value="M">M</option>
                                        <option value="L">L</option>
                                        <option value="XL">XL</option>
                                        <option value="XXL">XXL</option>
                                    </select>
                                </div>
                                <div class="flex-grow-1">
                                    <label class="form-label">Color <span class="text-danger">*</span></label>
                                    <select class="form-select" name="color[]" required>
                                        <option value="" disabled selected>Select color</option>
                                        <option value="Red">Red</option>
                                        <option value="Blue">Blue</option>
                                        <option value="Black">Black</option>
                                        <option value="White">White</option>
                                        <option value="Green">Green</option>
                                        <option value="Pink">Prink</option>
                                    </select>
                                </div>
                                <div class="flex-grow-1">
                                    <label class="form-label">Variant Price (VND) <span class="text-danger">*</span></label>
                                    <input type="number" class="form-control" name="priceModifier[]" 
                                           value="${oldPriceModifiers[0] != null ? oldPriceModifiers[0] : ''}" 
                                           step="1000" min="0" placeholder="Final price" required>
                                </div>
                                <div>
                                    <label>&nbsp;</label>
                                    <button type="button" class="btn btn-danger d-block remove-variant"><i class="bi bi-trash"></i></button>
                                </div>
                            </div>
                        </div>
                        <button type="button" class="btn btn-primary mt-2" id="addVariant"><i class="bi bi-plus-circle"></i> Add Variant</button>
                    </div>
                    <div class="image-container mt-3">
                        <h5>Product Images <span class="text-danger">*</span></h5>
                        <div id="images">
                            <div class="image-row">
                                <div class="flex-grow-1">
                                    <label class="form-label">Image <span class="text-danger">*</span></label>
                                    <input type="file" class="form-control" name="images" accept="image/*" required>
                                </div>
                                <div>
                                    <label class="form-label">Main</label>
                                    <input type="radio" class="form-check-input" name="mainImage" value="0" checked>
                                </div>
                                <div>
                                    <label>&nbsp;</label>
                                    <button type="button" class="btn btn-danger d-block remove-image"><i class="bi bi-trash"></i></button>
                                </div>
                            </div>
                        </div>
                        <button type="button" class="btn btn-primary mt-2" id="addImage"><i class="bi bi-plus-circle"></i> Add Image</button>
                    </div>
                    <div class="d-flex gap-2 mt-4">
                        <button type="submit" class="btn btn-success"><i class="bi bi-save"></i> Create Product</button>
                        <a href="${pageContext.request.contextPath}/ProductListAdmin" class="btn btn-secondary"><i class="bi bi-x-circle"></i> Cancel</a>
                    </div>
                </form>
            </div>
        </div>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
        <script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
        <script>
            document.addEventListener('DOMContentLoaded', function () {
                const variantsContainer = document.getElementById('variants');
                const imagesContainer = document.getElementById('images');

                // Add Variant Logic
                document.getElementById('addVariant').addEventListener('click', function () {
                    const newVariant = variantsContainer.querySelector('.variant-row').cloneNode(true);
                    newVariant.querySelectorAll('select').forEach(el => el.selectedIndex = 0);
                    newVariant.querySelectorAll('input').forEach(el => el.value = '');
                    variantsContainer.appendChild(newVariant);
                });

                // Remove Variant Logic
                variantsContainer.addEventListener('click', function (e) {
                    if (e.target.closest('.remove-variant')) {
                        if (variantsContainer.querySelectorAll('.variant-row').length > 1) {
                            e.target.closest('.variant-row').remove();
                        } else {
                            Swal.fire('Cannot Remove', 'At least one variant is required.', 'warning');
                        }
                    }
                });

                // Add Image Logic
                document.getElementById('addImage').addEventListener('click', function () {
                    const imageRow = imagesContainer.querySelector('.image-row').cloneNode(true);
                    const index = imagesContainer.querySelectorAll('.image-row').length;
                    imageRow.querySelector('input[type="file"]').value = '';
                    imageRow.querySelector('input[type="radio"]').value = index;
                    imageRow.querySelector('input[type="radio"]').checked = false;
                    imagesContainer.appendChild(imageRow);
                });

                // Remove Image Logic
                imagesContainer.addEventListener('click', function (e) {
                    if (e.target.closest('.remove-image')) {
                        if (imagesContainer.querySelectorAll('.image-row').length > 1) {
                            e.target.closest('.image-row').remove();
                        } else {
                            Swal.fire('Cannot Remove', 'At least one image is required.', 'warning');
                        }
                    }
                });
            });
        </script>
    </body>
</html>