<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<style>
    body {
        font-family: 'Jost', sans-serif;
        background-color: #f8f9fa;
    }
    .product-detail-container {
        margin-top: 3rem;
        margin-bottom: 2rem;
        background-color: white;
        padding: 2rem;
        border-radius: 0.5rem;
        box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        position: relative;
        z-index: 500;
    }
    .product-detail-container .thumbnail-list {
        display: flex;
        flex-direction: column;
        gap: 0.75rem;
    }
    .product-detail-container .thumbnail-img {
        width: 100%;
        aspect-ratio: 4/5;
        object-fit: cover;
        cursor: pointer;
        border-radius: 0.25rem;
        border: 2px solid transparent;
        transition: all 0.2s ease;
    }
    .product-detail-container .thumbnail-img.active,
    .product-detail-container .thumbnail-img:hover {
        border-color: #0d6efd;
        transform: scale(1.05);
    }
    .product-detail-container .main-image-wrapper {
        position: relative;
        aspect-ratio: 4/5;
        display: flex;
        align-items: center;
        justify-content: center;
        background-color: #f1f1f1;
        border-radius: 0.25rem;
        overflow: hidden;
    }
    .product-detail-container .main-image-wrapper img {
        max-width: 100%;
        max-height: 100%;
        object-fit: cover;
    }
    .product-detail-container .nav-arrow {
        position: absolute;
        top: 50%;
        transform: translateY(-50%);
        background-color: rgba(255, 255, 255, 0.9);
        border: none;
        border-radius: 50%;
        width: 40px;
        height: 40px;
        font-size: 1.2rem;
        color: #333;
        cursor: pointer;
        transition: background-color 0.3s ease;
        box-shadow: 0 2px 8px rgba(0,0,0,0.15);
    }
    .product-detail-container .nav-arrow:hover {
        background-color: #fff;
    }
    .product-detail-container .nav-arrow.prev {
        left: 1rem;
    }
    .product-detail-container .nav-arrow.next {
        right: 1rem;
    }
    .product-detail-container .quantity-selector .btn {
        width: 40px;
        height: 40px;
        font-size: 1rem;
    }
    .product-detail-container .quantity-selector input {
        width: 70px;
        text-align: center;
        font-size: 1rem;
    }
    .product-detail-container .product-info dt {
        font-weight: 600;
        color: #495057;
    }
    .product-detail-container .product-info dd {
        color: #6c757d;
    }
    .product-detail-container .alert {
        border-radius: 6px;
        margin-bottom: 1.5rem;
        font-size: 0.9rem;
    }
    .product-detail-container .btn-dark,
    .product-detail-container .btn-primary {
        font-size: 1rem;
        padding: 0.75rem 1.5rem;
        border-radius: 50px;
        text-transform: uppercase;
        letter-spacing: 1px;
    }
    .wishlist-icon {
        position: absolute;
        top: 12px;
        right: 12px;
        z-index: 10;
    }
    .wishlist-icon-circle {
        background-color: white;
        border: 1px solid #ddd;
        border-radius: 50%;
        width: 36px;
        height: 36px;
        display: flex;
        align-items: center;
        justify-content: center;
        color: #666;
        font-size: 16px;
        cursor: pointer;
        transition: all 0.3s ease;
        box-shadow: 0 2px 5px rgba(0,0,0,0.1);
    }
    .wishlist-icon-circle:hover {
        border-color: #ff4d4f;
        color: #ff4d4f;
    }
    .wishlist-icon-circle.active {
        border-color: #ff4d4f;
        color: #ff4d4f;
    }
    .toast-container {
        position: fixed;
        top: 20px;
        right: 20px;
        z-index: 1050;
    }
    @media (max-width: 991.98px) {
        .product-detail-container .thumbnail-list {
            flex-direction: row;
            overflow-x: auto;
            padding-bottom: 0.75rem;
            gap: 0.5rem;
        }
        .product-detail-container .thumbnail-img {
            width: 80px;
            height: 100px;
            flex-shrink: 0;
        }
    }
    @media (max-width: 767.98px) {
        .product-detail-container {
            padding: 1.25rem;
            margin-top: 4rem;
        }
        .product-detail-container .main-image-wrapper {
            aspect-ratio: 1/1;
        }
        .product-detail-container .btn-dark,
        .product-detail-container .btn-primary {
            padding: 0.5rem 1rem;
            font-size: 0.9rem;
        }
    }
</style>
<div class="container-lg product-detail-container">
    <c:choose>
        <c:when test="${not empty errorMessage}">
            <div class="alert alert-danger text-center" role="alert">${errorMessage}</div>
        </c:when>
        <c:when test="${not empty product and product.status eq 'Active'}">
            <div class="row g-4">
                <div class="col-lg-6">
                    <div class="row g-2">
                        <div class="col-lg-2 order-lg-1 order-2">
                            <div class="thumbnail-list">
                                <c:choose>
                                    <c:when test="${not empty product.images}">
                                        <c:forEach var="image" items="${product.images}" varStatus="loop">
                                            <img src="<c:out value='${image.imageUrl}' default='https://placehold.co/100x125/f0f0f0/333?text=No+Image' />"
                                                 alt="Thumbnail ${loop.count}"
                                                 class="thumbnail-img ${image.main ? 'active' : ''}">
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <img src="https://placehold.co/100x125/f0f0f0/333?text=No+Image" alt="No Image" class="thumbnail-img active">
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                        <div class="col-lg-10 order-lg-2 order-1">
                            <div class="main-image-wrapper">
                                <c:set var="mainImageUrl" value="https://placehold.co/500x625/f0f0f0/333?text=No+Image" />
                                <c:forEach var="image" items="${product.images}">
                                    <c:if test="${image.main}">
                                        <c:set var="mainImageUrl" value="${image.imageUrl}" />
                                    </c:if>
                                </c:forEach>
                                <div class="wishlist-icon">
                                    <form action="${pageContext.request.contextPath}/wishlist" method="post">
                                        <input type="hidden" name="action" value="add">
                                        <input type="hidden" name="productId" value="${product.productId}">
                                        <button type="submit" class="wishlist-icon-circle ${wishlistProductIds != null && wishlistProductIds.contains(product.productId) ? 'active' : ''}">
                                            <i class="fas fa-heart"></i>
                                        </button>
                                    </form>
                                </div>
                                <img src="${mainImageUrl}" alt="<c:out value='${product.name}'/>" id="mainProductImage">
                                <button class="nav-arrow prev" id="prevImageBtn" aria-label="Previous Image">❮</button>
                                <button class="nav-arrow next" id="nextImageBtn" aria-label="Next Image">❯</button>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-lg-6">
                    <h1 class="mb-2 fs-2 fw-bold"><c:out value="${product.name}" default="Undefined Product"/></h1>
                    <p class="fs-3 text-danger fw-light" id="productPrice">
                        <%= NumberFormat.getCurrencyInstance(new Locale("vi", "VN")).format(request.getAttribute("lowestPrice") != null ? (Double) request.getAttribute("lowestPrice") : 0) %>
                    </p>
                    <dl class="row product-info mb-3">
                        <dt class="col-sm-3">Category:</dt>
                        <dd class="col-sm-9"><c:out value="${product.category.name}" default="N/A"/></dd>
                        <dt class="col-sm-3">Brand:</dt>
                        <dd class="col-sm-9"><c:out value="${product.brand.name}" default="N/A"/></dd>
                        <dt class="col-sm-3">Material:</dt>
                        <dd class="col-sm-9"><c:out value="${product.material}" default="N/A"/></dd>
                    </dl>
                    <p class="text-muted"><c:out value="${product.description}" default="No description."/></p>
                    <form id="productForm">
                        <div class="mb-3">
                            <label for="variantSelect" class="form-label fw-bold">Select Variant:</label>
                            <select id="variantSelect" name="variantId" class="form-select">
                                <c:choose>
                                    <c:when test="${not empty product.variants}">
                                        <c:forEach var="variant" items="${product.variants}">
                                            <option value="${variant.variantId}"
                                                    data-price="${variant.priceModifier}"
                                                    data-available="${variant.quantity}"
                                                    ${defaultVariant.variantId eq variant.variantId ? 'selected' : ''}>
                                                ${variant.size} - ${variant.color}
                                                <c:if test="${variant.quantity <= 0}"> (Out of stock)</c:if>
                                            </option>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <option value="0" data-price="${lowestPrice}" data-available="0">No variants</option>
                                    </c:otherwise>
                                </c:choose>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label for="quantity" class="form-label fw-bold">Quantity:</label>
                            <div class="d-flex align-items-center gap-2 quantity-selector">
                                <button type="button" class="btn btn-outline-secondary" id="decreaseQtyBtn">-</button>
                                <input type="number" id="quantity" name="quantity" value="1" min="1" class="form-control" readonly>
                                <button type="button" class="btn btn-outline-secondary" id="increaseQtyBtn">+</button>
                                <small id="stockStatus" class="ms-2 text-muted"></small>
                            </div>
                        </div>
                        <div class="d-flex gap-2 flex-wrap mt-4">
                            <button type="button" id="addToCartBtn" class="btn btn-dark flex-grow-1">
                                <i class="fas fa-cart-plus"></i> Add to Cart
                            </button>
                            <button type="button" id="buyNowBtn" class="btn btn-primary flex-grow-1">
                                <i class="fas fa-bag-check"></i> Buy Now
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <div class="alert alert-warning text-center" role="alert">Product does not exist or is discontinued.</div>
        </c:otherwise>
    </c:choose>
</div>
<div class="toast-container"></div>
<jsp:include page="/WEB-INF/views/common/footer.jsp" />
<script>
    document.addEventListener('DOMContentLoaded', () => {
        const showToast = function (message, isSuccess) {
            const toast = document.createElement('div');
            toast.className = `toast align-items-center text-white ${isSuccess ? 'bg-success' : 'bg-danger'} border-0`;
            toast.setAttribute('role', 'alert');
            toast.setAttribute('aria-live', 'assertive');
            toast.setAttribute('aria-atomic', 'true');
            toast.innerHTML = `
                <div class="d-flex">
                    <div class="toast-body">${message}</div>
                    <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
                </div>
            `;
            document.querySelector('.toast-container').appendChild(toast);
            new bootstrap.Toast(toast, {delay: 3000}).show();
        };

        const mainImage = document.getElementById('mainProductImage');
        const thumbnails = document.querySelectorAll('.product-detail-container .thumbnail-img');
        const prevImageBtn = document.getElementById('prevImageBtn');
        const nextImageBtn = document.getElementById('nextImageBtn');
        const variantSelect = document.getElementById('variantSelect');
        const priceElement = document.getElementById('productPrice');
        const quantityInput = document.getElementById('quantity');
        const decreaseQtyBtn = document.getElementById('decreaseQtyBtn');
        const increaseQtyBtn = document.getElementById('increaseQtyBtn');
        const stockStatus = document.getElementById('stockStatus');
        const addToCartBtn = document.getElementById('addToCartBtn');
        const buyNowBtn = document.getElementById('buyNowBtn');
        const productForm = document.getElementById('productForm');
        let currentIndex = Array.from(thumbnails).findIndex(thumb => thumb.classList.contains('active'));
        let currentAvailable = 0;

        const updateMainImage = (selectedThumb) => {
            if (!mainImage || !selectedThumb) return;
            mainImage.src = selectedThumb.src;
            mainImage.alt = selectedThumb.alt;
            thumbnails.forEach(t => t.classList.remove('active'));
            selectedThumb.classList.add('active');
            currentIndex = Array.from(thumbnails).indexOf(selectedThumb);
        };

        const navigateImage = (direction) => {
            if (thumbnails.length === 0) return;
            let newIndex = currentIndex + direction;
            if (newIndex >= thumbnails.length) newIndex = 0;
            if (newIndex < 0) newIndex = thumbnails.length - 1;
            updateMainImage(thumbnails[newIndex]);
        };

        thumbnails.forEach(thumb => thumb.addEventListener('click', () => updateMainImage(thumb)));
        prevImageBtn.addEventListener('click', () => navigateImage(-1));
        nextImageBtn.addEventListener('click', () => navigateImage(1));

        const currencyFormatter = new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' });

        const updateUIFromVariant = () => {
            const selectedOption = variantSelect.options[variantSelect.selectedIndex];
            if (!selectedOption) return;
            const price = parseFloat(selectedOption.dataset.price || '0');
            currentAvailable = parseInt(selectedOption.dataset.available || '0', 10);
            priceElement.textContent = currencyFormatter.format(price);
            stockStatus.textContent = currentAvailable > 0 ? `(Available: ${currentAvailable} items)` : '(Out of stock)';
            quantityInput.value = 1;
            quantityInput.max = currentAvailable;
            const isAvailable = currentAvailable > 0;
            addToCartBtn.disabled = !isAvailable;
            buyNowBtn.disabled = !isAvailable;
            increaseQtyBtn.disabled = !isAvailable || quantityInput.value >= currentAvailable;
            decreaseQtyBtn.disabled = !isAvailable || quantityInput.value <= 1;
            addToCartBtn.innerHTML = isAvailable ? '<i class="fas fa-cart-plus"></i> Add to Cart' : '<i class="fas fa-x-circle"></i> Out of Stock';
            buyNowBtn.innerHTML = isAvailable ? '<i class="fas fa-bag-check"></i> Buy Now' : '<i class="fas fa-x-circle"></i> Out of Stock';
        };

        increaseQtyBtn.addEventListener('click', () => {
            let currentQty = parseInt(quantityInput.value, 10);
            if (currentQty < currentAvailable) {
                quantityInput.value = currentQty + 1;
                decreaseQtyBtn.disabled = false;
                increaseQtyBtn.disabled = currentQty + 1 >= currentAvailable;
            }
        });

        decreaseQtyBtn.addEventListener('click', () => {
            let currentQty = parseInt(quantityInput.value, 10);
            if (currentQty > 1) {
                quantityInput.value = currentQty - 1;
                increaseQtyBtn.disabled = false;
                decreaseQtyBtn.disabled = currentQty - 1 <= 1;
            }
        });

        addToCartBtn.addEventListener('click', () => {
            if (currentAvailable <= 0) {
                showToast('This product is out of stock.', false);
                return;
            }
            const formData = new FormData(productForm);
            formData.append('action', 'add');
            fetch('${pageContext.request.contextPath}/customer/cart', {
                method: 'POST',
                body: new URLSearchParams(formData),
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                    'Accept': 'application/json'
                }
            })
            .then(response => {
                if (!response.ok) throw new Error('Network response was not ok: ' + response.statusText);
                return response.json();
            })
            .then(result => {
                console.log('Add to Cart response:', result);
                if (result.success) {
                    showToast(result.message || 'Product added to cart!', true);
                    setTimeout(() => {
                        window.location.href = '${pageContext.request.contextPath}/customer/cart';
                    }, 1000);
                } else {
                    showToast(result.message || 'Unable to add to cart.', false);
                }
            })
            .catch(error => {
                console.error('Error adding to cart:', error);
                showToast('An error occurred while adding to cart: ' + error.message, false);
            });
        });

        buyNowBtn.addEventListener('click', () => {
            if (currentAvailable <= 0) {
                showToast('This product is out of stock.', false);
                return;
            }
            productForm.action = '${pageContext.request.contextPath}/customer/checkout';
            productForm.method = 'POST';
            productForm.submit();
        });

        variantSelect.addEventListener('change', updateUIFromVariant);
        updateUIFromVariant();

        document.querySelectorAll('[data-bs-toggle="dropdown"]').forEach(toggle => {
            toggle.addEventListener('click', function (e) {
                const dropdown = document.getElementById(this.getAttribute('aria-controls'));
                if (dropdown) {
                    const isOpen = dropdown.classList.contains('show');
                    document.querySelectorAll('.dropdown-menu.show').forEach(d => d.classList.remove('show'));
                    if (!isOpen) {
                        dropdown.classList.add('show');
                    }
                }
            });
        });

        document.addEventListener('click', function (e) {
            if (!e.target.closest('.dropdown')) {
                document.querySelectorAll('.dropdown-menu.show').forEach(dropdown => {
                    dropdown.classList.remove('show');
                });
            }
        });
    });
</script>