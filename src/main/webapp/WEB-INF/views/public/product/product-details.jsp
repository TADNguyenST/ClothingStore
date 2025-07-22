<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Product" %>
<%@ page import="model.ProductVariant" %>
<%@ page import="model.ProductImage" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="dao.ProductDAO" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%
    Product product = (Product) request.getAttribute("product");
    String error = (String) request.getAttribute("error");
    NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
    ProductDAO productDAO = new ProductDAO();

    ProductVariant defaultVariant = null;
    double lowestPrice = Double.MAX_VALUE;
    if (product != null && product.getVariants() != null && !product.getVariants().isEmpty()) {
        for (ProductVariant variant : product.getVariants()) {
            if (variant.getPriceModifier() != null) {
                double price = variant.getPriceModifier().doubleValue();
                if (price < lowestPrice) {
                    lowestPrice = price;
                    defaultVariant = variant;
                }
            }
        }
    }
    if (lowestPrice == Double.MAX_VALUE) {
        lowestPrice = product != null && product.getPrice() != null ? product.getPrice().doubleValue() : 0;
    }
%>

<jsp:include page="/WEB-INF/views/common/header.jsp" />

<style>
    :root {
        --primary-color: #2563eb;
        --secondary-color: #f97316;
        --text-color: #1f2937;
        --border-color: #d1d5db;
        --background-color: #f9fafb;
    }

    body {
        font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
        background-color: var(--background-color);
        color: var(--text-color);
        margin: 0;
        padding: 0;
    }

    .product-detail-container {
        max-width: 1280px;
        margin: 2rem auto;
        padding: 1.5rem;
        background: #ffffff;
        border-radius: 16px;
        box-shadow: 0 8px 24px rgba(0, 0, 0, 0.05);
    }

    .image-gallery-container {
        display: grid;
        grid-template-columns: 120px 1fr;
        gap: 1rem;
        align-items: start;
    }

    .thumbnail-column {
        display: flex;
        flex-direction: column;
        gap: 0.75rem;
    }

    .thumbnail-column img {
        width: 100%;
        aspect-ratio: 4/5;
        object-fit: cover;
        border-radius: 8px;
        cursor: pointer;
        border: 2px solid transparent;
        transition: border-color 0.3s ease, transform 0.2s ease;
    }

    .thumbnail-column img.active, .thumbnail-column img:hover {
        border-color: var(--primary-color);
        transform: scale(1.03);
    }

    .main-image-wrapper {
        position: relative;
        background-color: #f1f5f9;
        border-radius: 12px;
        overflow: hidden;
        aspect-ratio: 4/5;
        display: flex;
        align-items: center;
        justify-content: center;
    }

    .main-image-wrapper .product-image-main {
        max-width: 100%;
        max-height: 100%;
        object-fit: contain;
    }

    .nav-arrow {
        position: absolute;
        top: 50%;
        transform: translateY(-50%);
        background-color: rgba(255, 255, 255, 0.95);
        border: none;
        border-radius: 50%;
        width: 48px;
        height: 48px;
        font-size: 1.5rem;
        color: var(--text-color);
        cursor: pointer;
        transition: all 0.3s ease;
        z-index: 10;
    }

    .nav-arrow:hover {
        background-color: #ffffff;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
    }

    .nav-arrow.prev { left: 1rem; }
    .nav-arrow.next { right: 1rem; }

    .product-info-section {
        padding: 1.5rem;
    }

    .product-title {
        font-size: 2rem;
        font-weight: 700;
        margin-bottom: 0.75rem;
        color: var(--text-color);
    }

    .product-current-price {
        font-size: 1.75rem;
        font-weight: 600;
        color: #dc2626;
        margin-bottom: 1rem;
    }

    .product-info {
        margin-bottom: 1.5rem;
        font-size: 1rem;
        line-height: 1.7;
    }

    .product-info p {
        margin: 0.5rem 0;
        color: #4b5563;
    }

    .product-info p strong {
        color: var(--text-color);
    }

    .variant-selector, .quantity-selector {
        margin-bottom: 1.5rem;
    }

    .variant-selector label, .quantity-selector label {
        font-weight: 600;
        margin-bottom: 0.5rem;
        display: block;
        color: var(--text-color);
    }

    .variant-selector select, .quantity-selector input {
        width: 100%;
        max-width: 320px;
        padding: 0.75rem;
        border: 1px solid var(--border-color);
        border-radius: 8px;
        font-size: 1rem;
        transition: border-color 0.3s ease, box-shadow 0.3s ease;
    }

    .variant-selector select:focus, .quantity-selector input:focus {
        border-color: var(--primary-color);
        box-shadow: 0 0 0 4px rgba(37, 99, 235, 0.1);
        outline: none;
    }

    .quantity-selector {
        display: flex;
        align-items: center;
        gap: 0.75rem;
    }

    .quantity-selector button {
        width: 48px;
        height: 48px;
        border: 1px solid var(--border-color);
        background: #ffffff;
        border-radius: 8px;
        font-size: 1.25rem;
        cursor: pointer;
        transition: all 0.3s ease;
    }

    .quantity-selector button:hover {
        background-color: #f3f4f6;
    }

    .quantity-selector input {
        width: 80px;
        text-align: center;
    }

    .btn-container {
        display: flex;
        gap: 1rem;
        flex-wrap: wrap;
    }

    .btn {
        flex: 1;
        padding: 0.75rem 1.5rem;
        border-radius: 8px;
        font-size: 1rem;
        font-weight: 600;
        text-align: center;
        transition: all 0.3s ease;
        text-decoration: none;
        cursor: pointer;
    }

    .btn-dark {
        background: var(--text-color);
        color: #ffffff;
    }

    .btn-dark:hover {
        background: #111827;
        transform: translateY(-2px);
    }

    .btn-orange {
        background: var(--secondary-color);
        color: #ffffff;
    }

    .btn-orange:hover {
        background: #ea580c;
        transform: translateY(-2px);
    }

    .btn.disabled {
        background: #e5e7eb;
        color: #9ca3af;
        cursor: not-allowed;
        transform: none;
    }

    .shipping-info {
        margin-top: 1.5rem;
        font-size: 0.875rem;
        color: #4b5563;
    }

    .shipping-info ul {
        list-style: none;
        padding: 0;
    }

    .shipping-info ul li {
        margin: 0.75rem 0;
        display: flex;
        align-items: center;
        gap: 0.5rem;
    }

    .shipping-info ul li i {
        color: var(--primary-color);
    }

    .error-message {
        color: #dc2626;
        font-weight: 500;
        margin-bottom: 1.5rem;
        text-align: center;
    }

    @media (max-width: 992px) {
        .image-gallery-container {
            grid-template-columns: 1fr;
        }

        .thumbnail-column {
            flex-direction: row;
            overflow-x: auto;
            white-space: nowrap;
            gap: 0.5rem;
        }

        .thumbnail-column img {
            width: 80px;
            height: 100px;
        }

        .main-image-wrapper {
            aspect-ratio: 3/4;
        }
    }

    @media (max-width: 576px) {
        .product-detail-container {
            margin: 1rem;
            padding: 1rem;
        }

        .product-title {
            font-size: 1.5rem;
        }

        .product-current-price {
            font-size: 1.25rem;
        }

        .btn-container {
            flex-direction: column;
        }

        .btn {
            width: 100%;
        }
    }
</style>

<div class="product-detail-container">
    <% if (error != null && !error.isEmpty()) { %>
        <p class="error-message"><%= error %></p>
    <% } else if (product != null && "Active".equalsIgnoreCase(product.getStatus())) { %>
        <div class="row">
            <div class="col-lg-6">
                <div class="image-gallery-container">
                    <div class="thumbnail-column">
                        <%
                            if (product.getImages() != null && !product.getImages().isEmpty()) {
                                for (ProductImage image : product.getImages()) {
                        %>
                            <img src="<%= image.getImageUrl() != null ? image.getImageUrl() : "https://placehold.co/100x120" %>"
                                 alt="Thumbnail of <%= product.getName() != null ? product.getName() : "Product" %>"
                                 class="<%= image.isMain() ? "active" : "" %>"
                                 onclick="updateMainImage(this)">
                        <%
                            }
                        } else {
                        %>
                            <img src="https://placehold.co/100x120" alt="No Thumbnail" class="active" onclick="updateMainImage(this)">
                        <%
                            }
                        %>
                    </div>
                    <div class="main-image-wrapper">
                        <%
                            String mainImageUrl = product.getImageUrl() != null ? product.getImageUrl() : "https://placehold.co/500x600/f0f0f0/333?text=No+Image";
                            if (product.getImages() != null && !product.getImages().isEmpty()) {
                                for (ProductImage image : product.getImages()) {
                                    if (image.isMain()) {
                                        mainImageUrl = image.getImageUrl() != null ? image.getImageUrl() : "https://placehold.co/500x600";
                                        break;
                                    }
                                }
                            }
                        %>
                        <img src="<%= mainImageUrl %>" alt="<%= product.getName() != null ? product.getName() : "Product Image" %>" class="product-image-main">
                        <button class="nav-arrow prev" onclick="navigateImage(-1)" aria-label="Previous Image">❮</button>
                        <button class="nav-arrow next" onclick="navigateImage(1)" aria-label="Next Image">❯</button>
                    </div>
                </div>
            </div>
            <div class="col-lg-6 product-info-section">
                <h1 class="product-title"><%= product.getName() != null ? product.getName() : "Unknown Product" %></h1>
                <p class="product-current-price" id="productPrice"><%= currencyFormat.format(lowestPrice) %></p>
                <div class="product-info">
                    <p><strong>Status:</strong> <%= product.getStatus() != null ? product.getStatus() : "N/A" %></p>
                    <p><strong>Category:</strong> <%= product.getCategory() != null ? product.getCategory().getName() : "N/A" %></p>
                    <p><strong>Brand:</strong> <%= product.getBrand() != null ? product.getBrand().getName() : "N/A" %></p>
                    <p><strong>Material:</strong> <%= product.getMaterial() != null ? product.getMaterial() : "N/A" %></p>
                    <p><strong>Description:</strong> <%= product.getDescription() != null ? product.getDescription() : "No description available" %></p>
                </div>
                <div class="variant-selector">
                    <label for="variantSelect">Select Variant:</label>
                    <select id="variantSelect" name="variantId" onchange="updatePrice()" aria-describedby="variantHelp">
                        <%
                            if (product.getVariants() != null && !product.getVariants().isEmpty()) {
                                for (ProductVariant variant : product.getVariants()) {
                                    String size = variant.getSize() != null
                                            ? variant.getSize().substring(0, 1).toUpperCase() + variant.getSize().substring(1).toLowerCase()
                                            : "N/A";
                                    String color = variant.getColor() != null
                                            ? variant.getColor().substring(0, 1).toUpperCase() + variant.getColor().substring(1).toLowerCase()
                                            : "N/A";
                                    String variantLabel = size + " - " + color;
                                    double finalPrice = variant.getPriceModifier() != null ? variant.getPriceModifier().doubleValue() : lowestPrice;
                                    int available = productDAO.getAvailableQuantityByVariantId(variant.getVariantId());
                        %>
                            <option value="<%= variant.getVariantId() %>"
                                    data-price="<%= finalPrice %>"
                                    data-sku="<%= variant.getSku() != null ? variant.getSku() : "N/A" %>"
                                    data-available="<%= available %>"
                                    <%= defaultVariant != null && defaultVariant.getVariantId().equals(variant.getVariantId()) ? "selected" : "" %>>
                                <%= variantLabel %> - <%= currencyFormat.format(finalPrice) %> <%= available > 0 ? "" : "(Out of Stock)" %>
                            </option>
                        <%
                            }
                        } else {
                        %>
                            <option value="0" data-price="<%= lowestPrice %>" data-available="0">No variants available</option>
                        <%
                            }
                        %>
                    </select>
                    <small id="variantHelp" class="form-text text-muted">Choose size and color combination.</small>
                </div>
                <div class="quantity-selector">
                    <label for="quantity">Quantity:</label>
                    <div>
                        <button onclick="decreaseQuantity()" aria-label="Decrease Quantity">-</button>
                        <input type="number" id="quantity" value="1" min="1" readonly aria-describedby="quantityHelp">
                        <button onclick="increaseQuantity()" aria-label="Increase Quantity">+</button>
                    </div>
                    <small id="quantityHelp" class="form-text text-muted">Select the number of items.</small>
                </div>
                <div class="btn-container">
                    <form id="addToCartForm" action="${pageContext.request.contextPath}/customer/cart" method="post">
                        <input type="hidden" name="action" value="add">
                        <input type="hidden" name="variantId" id="cartVariantId" value="<%= defaultVariant != null ? defaultVariant.getVariantId() : 0 %>">
                        <input type="hidden" name="quantity" id="cartQuantity" value="1">
                        <button type="submit" id="addToCartBtn" class="btn btn-dark <%= defaultVariant != null && productDAO.getAvailableQuantityByVariantId(defaultVariant.getVariantId()) > 0 ? "" : "disabled" %>">
                            <%= defaultVariant != null && productDAO.getAvailableQuantityByVariantId(defaultVariant.getVariantId()) > 0 ? "Add to Cart" : "Out of Stock" %>
                        </button>
                    </form>
                    <form id="buyNowForm" action="${pageContext.request.contextPath}/customer/checkout" method="post">
                        <input type="hidden" name="action" value="buy">
                        <input type="hidden" name="productId" value="<%= product != null ? product.getProductId() : 0 %>">
                        <input type="hidden" name="variantId" id="buyVariantId" value="<%= defaultVariant != null ? defaultVariant.getVariantId() : 0 %>">
                        <input type="hidden" name="quantity" id="buyQuantity" value="1">
                        <button type="submit" id="buyNowBtn" class="btn btn-orange <%= defaultVariant != null && productDAO.getAvailableQuantityByVariantId(defaultVariant.getVariantId()) > 0 ? "" : "disabled" %>">
                            <%= defaultVariant != null && productDAO.getAvailableQuantityByVariantId(defaultVariant.getVariantId()) > 0 ? "Buy Now" : "Out of Stock" %>
                        </button>
                    </form>
                </div>
                <div class="shipping-info">
                    <ul>
                        <li><i class="bi bi-truck"></i> Free shipping on orders over 500,000 VND</li>
                        <li><i class="bi bi-arrow-counterclockwise"></i> 30-day return policy</li>
                        <li><i class="bi bi-shield-check"></i> Secure payment methods</li>
                    </ul>
                </div>
            </div>
        </div>
    <% } else { %>
        <p class="error-message">No product details available or product is not active.</p>
    <% } %>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', () => {
        const mainImage = document.querySelector('.product-image-main');
        const thumbnails = document.querySelectorAll('.thumbnail-column img');
        let currentIndex = Array.from(thumbnails).findIndex(thumb => thumb.classList.contains('active'));

        window.updateMainImage = (selectedThumb) => {
            mainImage.src = selectedThumb.src;
            mainImage.alt = selectedThumb.alt;
            thumbnails.forEach(t => t.classList.remove('active'));
            selectedThumb.classList.add('active');
            currentIndex = Array.from(thumbnails).indexOf(selectedThumb);
        };

        window.navigateImage = (direction) => {
            let newIndex = currentIndex + direction;
            if (newIndex >= thumbnails.length) newIndex = 0;
            if (newIndex < 0) newIndex = thumbnails.length - 1;
            updateMainImage(thumbnails[newIndex]);
        };

        window.decreaseQuantity = () => {
            const quantityInput = document.getElementById('quantity');
            let value = parseInt(quantityInput.value);
            if (value > 1) {
                quantityInput.value = value - 1;
                updateFormQuantities();
            }
        };

        window.increaseQuantity = () => {
            const quantityInput = document.getElementById('quantity');
            const select = document.getElementById('variantSelect');
            const selectedOption = select.options[select.selectedIndex];
            const available = parseInt(selectedOption.getAttribute('data-available')) || 0;
            let value = parseInt(quantityInput.value);
            if (value < available) {
                quantityInput.value = value + 1;
                updateFormQuantities();
            } else {
                alert(`Maximum available quantity: ${available}`);
            }
        };

        const updateFormQuantities = () => {
            const quantityInput = document.getElementById('quantity');
            document.getElementById('cartQuantity').value = quantityInput.value;
            document.getElementById('buyQuantity').value = quantityInput.value;
        };

        window.updatePrice = () => {
            const select = document.getElementById('variantSelect');
            const priceElement = document.getElementById('productPrice');
            const addToCartBtn = document.getElementById('addToCartBtn');
            const buyNowBtn = document.getElementById('buyNowBtn');
            const selectedOption = select.options[select.selectedIndex];
            const finalPrice = parseFloat(selectedOption.getAttribute('data-price')) || <%= lowestPrice %>;
            const available = parseInt(selectedOption.getAttribute('data-available')) || 0;

            priceElement.textContent = new Intl.NumberFormat('vi-VN', {
                style: 'currency',
                currency: 'VND'
            }).format(finalPrice);

            const quantityInput = document.getElementById('quantity');
            if (available > 0) {
                addToCartBtn.textContent = 'Add to Cart';
                buyNowBtn.textContent = 'Buy Now';
                addToCartBtn.classList.remove('disabled');
                buyNowBtn.classList.remove('disabled');
                quantityInput.value = Math.min(parseInt(quantityInput.value), available);
            } else {
                addToCartBtn.textContent = 'Out of Stock';
                buyNowBtn.textContent = 'Out of Stock';
                addToCartBtn.classList.add('disabled');
                buyNowBtn.classList.add('disabled');
                quantityInput.value = 1;
            }

            document.getElementById('cartVariantId').value = selectedOption.value;
            document.getElementById('buyVariantId').value = selectedOption.value;
            updateFormQuantities();
        };

        updatePrice();
    });
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />