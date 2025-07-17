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

    // Find the lowest price and default variant
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
    // If no valid variant, set default price to product price
    if (lowestPrice == Double.MAX_VALUE) {
        lowestPrice = product != null && product.getPrice() != null ? product.getPrice().doubleValue() : 0;
    }
%>

<jsp:include page="/WEB-INF/views/common/header.jsp" />

<style>
    .product-detail-container {
        max-width: 1200px;
        margin: 0 auto;
        padding: 40px 20px;
    }
    .image-gallery-container {
        display: flex;
        gap: 12px;
    }
    .thumbnail-column {
        display: flex;
        flex-direction: column;
        gap: 10px;
        flex-shrink: 0;
    }
    .thumbnail-column img {
        width: 80px;
        height: 95px;
        object-fit: cover;
        border-radius: 5px;
        cursor: pointer;
        border: 2px solid transparent;
        transition: border-color 0.3s ease;
    }
    .thumbnail-column img.active {
        border-color: #007bff;
    }
    .main-image-wrapper {
        position: relative;
        flex-grow: 1;
        display: flex;
        align-items: center;
        justify-content: center;
        background-color: #f8f9fa;
        border-radius: 5px;
        overflow: hidden;
    }
    .main-image-wrapper .product-image-main {
        max-width: 100%;
        max-height: 100%;
        height: auto;
        object-fit: contain;
        border-radius: 5px;
    }
    .nav-arrow {
        position: absolute;
        top: 50%;
        transform: translateY(-50%);
        background-color: rgba(255, 255, 255, 0.8);
        border: none;
        border-radius: 50%;
        width: 35px;
        height: 35px;
        font-size: 20px;
        font-weight: bold;
        color: #333;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 10;
    }
    .nav-arrow:hover {
        background-color: white;
    }
    .nav-arrow.prev {
        left: 10px;
    }
    .nav-arrow.next {
        right: 10px;
    }
    .product-detail-container .product-title {
        font-size: 2rem;
        font-weight: 700;
        margin-bottom: 10px;
    }
    .product-detail-container .product-original-price {
        font-size: 1.2rem;
        color: #666;
        margin-bottom: 5px;
    }
    .product-detail-container .product-current-price {
        font-size: 1.5rem;
        font-weight: 600;
        color: #111;
        margin-bottom: 20px;
    }
    .product-detail-container .product-info {
        margin-bottom: 20px;
    }
    .product-detail-container .product-info p {
        margin: 5px 0;
        font-size: 1rem;
    }
    .product-detail-container .variant-selector {
        margin-bottom: 20px;
    }
    .product-detail-container .variant-selector label {
        font-weight: 600;
        margin-right: 10px;
    }
    .product-detail-container .variant-selector select {
        width: 200px;
    }
    .product-detail-container .quantity-selector {
        display: flex;
        align-items: center;
        gap: 10px;
        margin-bottom: 20px;
    }
    .product-detail-container .quantity-selector button {
        width: 30px;
        height: 30px;
        border: 1px solid #ccc;
        background: #fff;
        border-radius: 5px;
        cursor: pointer;
    }
    .product-detail-container .quantity-selector input {
        width: 50px;
        text-align: center;
        border: 1px solid #ccc;
        border-radius: 5px;
        height: 30px;
    }
    .product-detail-container .btn-container {
        display: flex;
        gap: 10px;
    }
    .product-detail-container .btn {
        padding: 10px 20px;
        border-radius: 5px;
        text-align: center;
        text-decoration: none;
        font-weight: 600;
        width: 48%;
    }
    .product-detail-container .btn-dark {
        background: #000;
        color: #fff;
    }
    .product-detail-container .btn-orange {
        background: #ff5722;
        color: #fff;
    }
    .product-detail-container .btn.disabled {
        background: #ccc;
        cursor: not-allowed;
    }
    .product-detail-container .shipping-info {
        margin-top: 15px;
        font-size: 0.8rem;
        color: #666;
    }
    .product-detail-container .shipping-info ul {
        list-style: none;
        padding: 0;
    }
    .product-detail-container .shipping-info ul li {
        margin: 5px 0;
        display: flex;
        align-items: center;
        gap: 5px;
    }
    .product-detail-container .error-message {
        color: red;
        font-weight: 500;
        margin-bottom: 20px;
    }
</style>

<div class="product-detail-container">
    <% if (error != null && !error.isEmpty()) {%>
    <p class="error-message"><%= error%></p>
    <% } else if (product != null) { %>
    <div class="row">
        <div class="col-md-6">
            <div class="image-gallery-container">
                <div class="thumbnail-column">
                    <%
                        if (product.getImages() != null && !product.getImages().isEmpty()) {
                            for (ProductImage image : product.getImages()) {
                    %>
                    <img src="<%= image.getImageUrl() != null ? image.getImageUrl() : "https://placehold.co/80x95"%>" 
                         alt="Thumbnail" 
                         class="<%= image.isMain() ? "active" : ""%>"
                         onclick="updateMainImage(this)">
                    <%
                        }
                    } else {
                    %>
                    <img src="https://placehold.co/80x95" alt="No Thumbnail" class="active" onclick="updateMainImage(this)">
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
                    <img src="<%= mainImageUrl%>" alt="<%= product.getName() != null ? product.getName() : "Product Image"%>" class="product-image-main">
                    <button class="nav-arrow prev" onclick="navigateImage(-1)">❮</button>
                    <button class="nav-arrow next" onclick="navigateImage(1)">❯</button>
                </div>
            </div>
        </div>
        <div class="col-md-6">
            <h1 class="product-title"><%= product.getName() != null ? product.getName() : "Unknown Product"%></h1>
            <p class="product-current-price" id="productPrice"><%= currencyFormat.format(lowestPrice)%></p>
            <p class="product-status">Status: <%= product.getStatus() != null ? product.getStatus() : "N/A"%> </p>
            <div class="product-info">
                <p><strong>Description:</strong> <%= product.getDescription() != null ? product.getDescription() : "No description available"%></p>
                <p><strong>Category:</strong> <%= product.getCategory() != null ? product.getCategory().getName() : "N/A"%></p>
                <p><strong>Brand:</strong> <%= product.getBrand() != null ? product.getBrand().getName() : "N/A"%></p>
                <p><strong>Material:</strong> <%= product.getMaterial() != null ? product.getMaterial() : "N/A"%></p>
            </div>
            <div class="variant-selector">
                <label for="variantSelect">Select Variant:</label>
                <select id="variantSelect" name="variantId" class="form-select" onchange="updatePrice()">
                    <%
                        if (product.getVariants() != null && !product.getVariants().isEmpty()) {
                            for (ProductVariant variant : product.getVariants()) {
                                String size = variant.getSize() != null
                                        ? variant.getSize().substring(0, 1).toUpperCase()
                                        + variant.getSize().substring(1).toLowerCase() : "N/A";
                                String color = variant.getColor() != null
                                        ? variant.getColor().substring(0, 1).toUpperCase()
                                        + variant.getColor().substring(1).toLowerCase() : "N/A";
                                String variantLabel = size + " - " + color;
                                double finalPrice = variant.getPriceModifier() != null
                                        ? variant.getPriceModifier().doubleValue() : 0;
                                int available = productDAO.getAvailableQuantityByVariantId(variant.getVariantId());
                                System.out.println("product-details.jsp - Variant ID: " + variant.getVariantId() + ", Available: " + available); // Debug log
%>
                    <option value="<%= variant.getVariantId()%>" 
                            data-price="<%= finalPrice%>"
                            data-sku="<%= variant.getSku() != null ? variant.getSku() : "N/A"%>"
                            data-available="<%= available%>"
                            <%= defaultVariant != null && defaultVariant.getVariantId().equals(variant.getVariantId()) ? "selected" : ""%>>
                        <%= variantLabel%> - <%= currencyFormat.format(finalPrice)%> <%= available > 0 ? "" : "(Out of Stock)"%>
                    </option>
                    <%
                        }
                    } else {
                    %>
                    <option value="0" data-price="0" data-available="0">No variants available</option>
                    <%
                        }
                    %>
                </select>
            </div>
            <div class="quantity-selector">
                <button onclick="decreaseQuantity()">-</button>
                <input type="number" id="quantity" value="1" min="1" readonly>
                <button onclick="increaseQuantity()">+</button>
            </div>
            <div class="btn-container">
                <a href="#" id="addToCartBtn" class="btn btn-dark <%= defaultVariant != null && productDAO.getAvailableQuantityByVariantId(defaultVariant.getVariantId()) > 0 ? "" : "disabled"%>" 
                   onclick="addToCart()"><%= defaultVariant != null && productDAO.getAvailableQuantityByVariantId(defaultVariant.getVariantId()) > 0 ? "Add to Cart" : "Out of Stock"%></a>
                <a href="#" id="buyNowBtn" class="btn btn-orange <%= defaultVariant != null && productDAO.getAvailableQuantityByVariantId(defaultVariant.getVariantId()) > 0 ? "" : "disabled"%>" 
                   onclick="buyNow()"><%= defaultVariant != null && productDAO.getAvailableQuantityByVariantId(defaultVariant.getVariantId()) > 0 ? "Buy Now" : "Out of Stock"%></a>
            </div>
            <div class="shipping-info">
                <ul>
                    <li>⚡ 4 people are viewing this product</li>
                    <li>🚚 Nationwide shipping: Cash on Delivery (COD)</li>
                    <li>🎁 Free shipping: Per policy</li>
                    <li>🔄 7-day return: If unfit or defective</li>
                    <li>📞 24/7 support: Per policy</li>
                </ul>
            </div>
        </div>
    </div>
    <% } else { %>
    <p class="text-center">No product details available.</p>
    <% }%>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
                       document.addEventListener('DOMContentLoaded', function () {
                           const mainImage = document.querySelector('.product-image-main');
                           const thumbnails = document.querySelectorAll('.thumbnail-column img');
                           let currentIndex = 0;

                           thumbnails.forEach((thumb, index) => {
                               if (thumb.classList.contains('active')) {
                                   currentIndex = index;
                               }
                           });

                           window.updateMainImage = function (selectedThumb) {
                               mainImage.src = selectedThumb.src;
                               thumbnails.forEach(t => t.classList.remove('active'));
                               selectedThumb.classList.add('active');
                               thumbnails.forEach((thumb, index) => {
                                   if (thumb.classList.contains('active')) {
                                       currentIndex = index;
                                   }
                               });
                           };

                           window.navigateImage = function (direction) {
                               let newIndex = currentIndex + direction;
                               if (newIndex >= thumbnails.length) {
                                   newIndex = 0;
                               } else if (newIndex < 0) {
                                   newIndex = thumbnails.length - 1;
                               }
                               updateMainImage(thumbnails[newIndex]);
                           };

                           const quantityInput = document.getElementById('quantity');
                           window.decreaseQuantity = function () {
                               let value = parseInt(quantityInput.value);
                               if (value > 1)
                                   quantityInput.value = value - 1;
                           };
                           window.increaseQuantity = function () {
                               let value = parseInt(quantityInput.value);
                               quantityInput.value = value + 1;
                           };

                           function formatCurrency(amount) {
                               return new Intl.NumberFormat('vi-VN', {style: 'currency', currency: 'VND'}).format(amount);
                           }
                           ;

                           window.updatePrice = function () {
                               const select = document.getElementById("variantSelect");
                               const priceElement = document.getElementById("productPrice");
                               const addToCartBtn = document.getElementById("addToCartBtn");
                               const buyNowBtn = document.getElementById("buyNowBtn");
                               const selectedOption = select.options[select.selectedIndex];
                               const finalPrice = parseFloat(selectedOption.getAttribute('data-price')) || 0;
                               const available = parseInt(selectedOption.getAttribute('data-available')) || 0;
                               console.log('Selected variant ID:', selectedOption.value, 'Final Price:', finalPrice, 'Available:', available);
                               priceElement.innerText = formatCurrency(finalPrice);
                               if (available > 0) {
                                   addToCartBtn.innerText = "Add to Cart";
                                   buyNowBtn.innerText = "Buy Now";
                                   addToCartBtn.classList.remove('disabled');
                                   buyNowBtn.classList.remove('disabled');
                               } else {
                                   addToCartBtn.innerText = "Out of Stock";
                                   buyNowBtn.innerText = "Out of Stock";
                                   addToCartBtn.classList.add('disabled');
                                   buyNowBtn.classList.add('disabled');
                               }
                           };

                           window.addToCart = function () {
                               const select = document.getElementById("variantSelect");
                               if (!select) {
                                   alert('Variant selector not found.');
                                   return;
                               }
                               const selectedOption = select.options[select.selectedIndex];
                               const available = parseInt(selectedOption.getAttribute('data-available')) || 0;
                               if (available <= 0) {
                                   alert("This product is out of stock.");
                                   return;
                               }
                               const variantId = select.value;
                               const quantityInput = document.getElementById("quantity");
                               if (!quantityInput) {
                                   alert('Quantity input not found.');
                                   return;
                               }
                               const quantity = parseInt(quantityInput.value);

                               fetch('${pageContext.request.contextPath}/customer/cart', {
                                   method: 'POST',
                                   body: new URLSearchParams({
                                       action: 'add',
                                       variantId: variantId,
                                       quantity: quantity
                                   }),
                                   headers: {
                                       'Content-Type': 'application/x-www-form-urlencoded',
                                       'Accept': 'application/json'
                                   }
                               })
                                       .then(response => {
                                           if (!response.ok)
                                               throw new Error('Network response was not ok: ' + response.statusText);
                                           return response.json();
                                       })
                                       .then(result => {
                                           console.log('Add to Cart response:', result); // Debug
                                           if (result.success) {
                                               alert(result.message); // Sử dụng alert tạm thời để kiểm tra
                                               setTimeout(() => {
                                                   window.location.href = '${pageContext.request.contextPath}/customer/cart';
                                               }, 1000); // Chuyển hướng sau 1 giây
                                           } else {
                                               alert(result.message || 'Failed to add to cart.');
                                           }
                                       })
                                       .catch(error => {
                                           console.error('Error adding to cart:', error);
                                           alert('An error occurred while adding to cart: ' + error.message);
                                       });
                           };

                           window.buyNow = function () {
                               const select = document.getElementById("variantSelect");
                               const selectedOption = select.options[select.selectedIndex];
                               const available = parseInt(selectedOption.getAttribute('data-available')) || 0;
                               if (available <= 0) {
                                   alert("This product is out of stock.");
                                   return;
                               }
                               const variantId = select.value;
                               const quantity = document.getElementById("quantity").value;
                               console.log('Buy now: productId=${product.productId}, variantId=' + variantId, 'quantity=' + quantity);
                               window.location.href = "${pageContext.request.contextPath}/customer/checkout?productId=${product.productId}&variantId=" + variantId + "&quantity=" + quantity;
                           };

                           updatePrice();
                       });
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />