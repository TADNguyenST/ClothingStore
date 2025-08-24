<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

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
    .product-detail-container .thumbnail-img.active, .product-detail-container .thumbnail-img:hover {
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
    .product-detail-container .btn-dark, .product-detail-container .btn-primary {
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
    .wishlist-icon-circle:hover, .wishlist-icon-circle.active {
        border-color: #ff4d4f;
        color: #ff4d4f;
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
        .product-detail-container .btn-dark, .product-detail-container .btn-primary {
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
                <!-- Gallery -->
                <div class="col-lg-6">
                    <div class="row g-2">
                        <div class="col-lg-2 order-lg-1 order-2">
                            <div class="thumbnail-list">
                                <c:choose>
                                    <c:when test="${not empty product.images}">
                                        <c:forEach var="image" items="${product.images}" varStatus="loop">
                                            <img
                                                src="${empty image.imageUrl ? 'https://placehold.co/100x125/f0f0f0/333?text=No+Image' : image.imageUrl}"
                                                alt="Thumbnail ${loop.count}"
                                                class="thumbnail-img ${image.main ? 'active' : ''}">
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <img src="https://placehold.co/100x125/f0f0f0/333?text=No+Image"
                                             alt="No Image" class="thumbnail-img active">
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
                                        <button type="submit"
                                                class="wishlist-icon-circle ${wishlistProductIds != null && wishlistProductIds.contains(product.productId) ? 'active' : ''}">
                                            <i class="fas fa-heart"></i>
                                        </button>
                                    </form>
                                </div>

                                <img src="${mainImageUrl}" alt="${product.name}" id="mainProductImage">
                                <button class="nav-arrow prev" id="prevImageBtn" aria-label="Previous Image">❮</button>
                                <button class="nav-arrow next" id="nextImageBtn" aria-label="Next Image">❯</button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Info -->
                <div class="col-lg-6">
                    <h1 class="mb-2 fs-2 fw-bold">${product.name}</h1>

                    <!-- Price is set by JS based on selected variant -->
                    <p class="fs-3 text-danger fw-light" id="productPrice"></p>

                    <dl class="row product-info mb-3">
                        <dt class="col-sm-3">Category:</dt>
                        <dd class="col-sm-9">${product.category != null ? product.category.name : 'N/A'}</dd>
                        <dt class="col-sm-3">Brand:</dt>
                        <dd class="col-sm-9">${product.brand != null ? product.brand.name : 'N/A'}</dd>
                        <dt class="col-sm-3">Material:</dt>
                        <dd class="col-sm-9">${empty product.material ? 'N/A' : product.material}</dd>
                    </dl>

                    <p class="text-muted">${empty product.description ? 'No description.' : product.description}</p>

                    <form id="productForm">
                        <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">

                        <div class="mb-3">
                            <label for="variantSelect" class="form-label fw-bold">Select Variant:</label>
                            <select id="variantSelect" name="variantId" class="form-select">
                                <c:choose>
                                    <c:when test="${not empty product.variants}">
                                        <c:forEach var="variant" items="${product.variants}">
                                            <%-- FINAL PRICE = variant.priceModifier if present; fallback product.price --%>
                                            <option value="${variant.variantId}"
                                                    data-price="<fmt:formatNumber value='${empty variant.priceModifier ? product.price : variant.priceModifier}' groupingUsed='false' maxFractionDigits='2'/>"
                                                    data-available="${variant.quantity}"
                                                    ${defaultVariant != null && defaultVariant.variantId == variant.variantId ? 'selected' : ''}>
                                                ${variant.size} - ${variant.color}
                                                <c:if test="${variant.quantity <= 0}"> (Out of stock)</c:if>
                                                </option>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <option value="0"
                                                data-price="<fmt:formatNumber value='${empty product.price ? 0 : product.price}' groupingUsed='false'/>"
                                                data-available="0">No variants</option>
                                    </c:otherwise>
                                </c:choose>
                            </select>
                        </div>

                        <div class="mb-3">
                            <label for="quantity" class="form-label fw-bold">Quantity:</label>
                            <div class="d-flex align-items-center gap-2 quantity-selector">
                                <button type="button" class="btn btn-outline-secondary" id="decreaseQtyBtn">-</button>
                                <input type="number" id="quantity" name="quantity" value="1" min="1"
                                       class="form-control" readonly>
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
            <div class="alert alert-warning text-center" role="alert">
                Product does not exist or is discontinued.
            </div>
        </c:otherwise>
    </c:choose>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

<script>
    document.addEventListener('DOMContentLoaded', () => {
        // Use global toast from header for consistency
        const showToast = (message, isSuccess) => {
            if (window.showToast) {
                window.showToast(message, !!isSuccess);
                return;
            }
            alert(message);
        };

        // ----- Gallery -----
        const mainImage = document.getElementById('mainProductImage');
        const thumbnails = document.querySelectorAll('.product-detail-container .thumbnail-img');
        const prevImageBtn = document.getElementById('prevImageBtn');
        const nextImageBtn = document.getElementById('nextImageBtn');
        let currentIndex = Array.from(thumbnails).findIndex(t => t.classList.contains('active'));

        const updateMainImage = (thumb) => {
            if (!thumb || !mainImage)
                return;
            mainImage.src = thumb.src;
            mainImage.alt = thumb.alt;
            thumbnails.forEach(t => t.classList.remove('active'));
            thumb.classList.add('active');
            currentIndex = Array.from(thumbnails).indexOf(thumb);
        };
        const navigateImage = (dir) => {
            if (thumbnails.length === 0)
                return;
            let idx = currentIndex + dir;
            if (idx >= thumbnails.length)
                idx = 0;
            if (idx < 0)
                idx = thumbnails.length - 1;
            updateMainImage(thumbnails[idx]);
        };
        thumbnails.forEach(t => t.addEventListener('click', () => updateMainImage(t)));
        if (prevImageBtn)
            prevImageBtn.addEventListener('click', () => navigateImage(-1));
        if (nextImageBtn)
            nextImageBtn.addEventListener('click', () => navigateImage(1));

        // ----- Pricing & stock -----
        const variantSelect = document.getElementById('variantSelect');
        const priceElement = document.getElementById('productPrice');
        const quantityInput = document.getElementById('quantity');
        const decreaseBtn = document.getElementById('decreaseQtyBtn');
        const increaseBtn = document.getElementById('increaseQtyBtn');
        const stockStatus = document.getElementById('stockStatus');
        const addToCartBtn = document.getElementById('addToCartBtn');
        const buyNowBtn = document.getElementById('buyNowBtn');
        const productForm = document.getElementById('productForm');

        const fmt = new Intl.NumberFormat('vi-VN', {style: 'currency', currency: 'VND'});
        let currentAvailable = 0;

        const updateUIFromVariant = () => {
            const opt = variantSelect.options[variantSelect.selectedIndex];
            if (!opt)
                return;

            // Price is already the final variant price (no accumulation)
            const price = Number(opt.dataset.price || 0);
            currentAvailable = Number(opt.dataset.available || 0);

            if (priceElement)
                priceElement.textContent = fmt.format(price);
            if (stockStatus)
                stockStatus.textContent = currentAvailable > 0
                        ? `In stock: ${currentAvailable}`
                        : 'Out of stock';

            quantityInput.value = 1;
            quantityInput.max = currentAvailable;

            const enabled = currentAvailable > 0 && opt.value !== '0';
            addToCartBtn.disabled = !enabled;
            buyNowBtn.disabled = !enabled;
            increaseBtn.disabled = !enabled || Number(quantityInput.value) >= currentAvailable;
            decreaseBtn.disabled = !enabled || Number(quantityInput.value) <= 1;

            addToCartBtn.innerHTML = enabled
                    ? '<i class="fas fa-cart-plus"></i> Add to Cart'
                    : '<i class="fas fa-x-circle"></i> Out of Stock';
            buyNowBtn.innerHTML = enabled
                    ? '<i class="fas fa-bag-check"></i> Buy Now'
                    : '<i class="fas fa-x-circle"></i> Out of Stock';
        };

        if (increaseBtn)
            increaseBtn.addEventListener('click', () => {
                let q = Number(quantityInput.value || 1);
                if (q < currentAvailable) {
                    quantityInput.value = q + 1;
                    decreaseBtn.disabled = false;
                    increaseBtn.disabled = (q + 1) >= currentAvailable;
                }
            });
        if (decreaseBtn)
            decreaseBtn.addEventListener('click', () => {
                let q = Number(quantityInput.value || 1);
                if (q > 1) {
                    quantityInput.value = q - 1;
                    increaseBtn.disabled = false;
                    decreaseBtn.disabled = (q - 1) <= 1;
                }
            });

        if (variantSelect) {
            variantSelect.addEventListener('change', updateUIFromVariant);
            updateUIFromVariant(); // init
        }

        // ----- Add to cart -----
        if (addToCartBtn)
            addToCartBtn.addEventListener('click', () => {
                if (!variantSelect)
                    return;
                const variantId = variantSelect.value;
                if (!variantId || variantId === '0') {
                    showToast('Please choose a variant first.', false);
                    return;
                }
                if (currentAvailable <= 0) {
                    showToast('This product is out of stock.', false);
                    return;
                }

                const fd = new FormData(productForm);
                fd.append('action', 'add');

                fetch('${pageContext.request.contextPath}/customer/cart', {
                    method: 'POST',
                    body: new URLSearchParams(fd),
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                        'Accept': 'application/json'
                    }
                })
                        .then(res => {
                            if (!res.ok)
                                throw new Error('HTTP ' + res.status);
                            return res.json();
                        })
                        .then(result => {
                            if (result && result.success) {
                                showToast(result.message || 'Added to cart!', true);
                                if (typeof window.handleAddToCartResult === 'function') {
                                    window.handleAddToCartResult(result);
                                } else if (typeof window.updateCartCount === 'function') {
                                    if (typeof result.cartCount === 'number')
                                        window.updateCartCount(result.cartCount);
                                    else
                                        window.updateCartCount();
                                }
                            } else {
                                showToast((result && result.message) || 'Unable to add to cart.', false);
                            }
                        })
                        .catch(err => {
                            console.error(err);
                            showToast('An error occurred while adding to cart.', false);
                        });
            });

        // ----- Buy now -----
        if (buyNowBtn)
            buyNowBtn.addEventListener('click', () => {
                if (!variantSelect)
                    return;
                if (currentAvailable <= 0 || variantSelect.value === '0') {
                    showToast('This product is out of stock.', false);
                    return;
                }
                productForm.action = '${pageContext.request.contextPath}/customer/checkout';
                productForm.method = 'POST';
                // If backend requires action=buy:
                // const h = document.createElement('input'); h.type='hidden'; h.name='action'; h.value='buy'; productForm.appendChild(h);
                productForm.submit();
            });
    });
</script>
