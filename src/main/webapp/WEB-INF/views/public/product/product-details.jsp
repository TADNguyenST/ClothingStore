<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Product" %>
<%@ page import="model.ProductVariant" %>
<%@ page import="model.ProductImage" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%
    Product product = (Product) request.getAttribute("product");
    String error = (String) request.getAttribute("error");
    NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
%>

<jsp:include page="/WEB-INF/views/common/header.jsp" />

<style>
    .product-detail-container {
        max-width: 1200px;
        margin: 0 auto;
        padding: 40px 20px;
    }

    /* === BẮT ĐẦU CSS MỚI CHO GALLERY ẢNH === */
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
    .nav-arrow.prev { left: 10px; }
    .nav-arrow.next { right: 10px; }
    /* === KẾT THÚC CSS MỚI CHO GALLERY ẢNH === */

    .product-detail-container .product-title {
        font-size: 2rem;
        font-weight: 700;
        margin-bottom: 20px;
    }
    .product-detail-container .product-price {
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
    <% if (error != null && !error.isEmpty()) { %>
        <p class="error-message"><%= error %></p>
    <% } else if (product != null) { %>
        <div class="row">
            
            <div class="col-md-6">
                <div class="image-gallery-container">
                    <div class="thumbnail-column">
                        <%
                            if (product.getImages() != null && !product.getImages().isEmpty()) {
                                for (ProductImage image : product.getImages()) {
                        %>
                                    <img src="<%= image.getImageUrl() %>" alt="Thumbnail" class="<%= image.isMain() ? "active" : "" %>"
                                         onclick="updateMainImage(this)">
                        <%
                                }
                            }
                        %>
                    </div>

                    <div class="main-image-wrapper">
                         <%
                             String mainImageUrl = product.getImageUrl() != null ? product.getImageUrl() : "https://placehold.co/500x600/f0f0f0/333?text=No+Image";
                             if (product.getImages() != null && !product.getImages().isEmpty()) {
                                 for (ProductImage image : product.getImages()) {
                                     if (image.isMain()) {
                                         mainImageUrl = image.getImageUrl();
                                         break;
                                     }
                                 }
                             }
                         %>
                        <img src="<%= mainImageUrl %>" alt="<%= product.getName() != null ? product.getName() : "Product Image" %>" class="product-image-main">
                        
                        <button class="nav-arrow prev" onclick="navigateImage(-1)">&#10094;</button>
                        <button class="nav-arrow next" onclick="navigateImage(1)">&#10095;</button>
                    </div>
                </div>
            </div>
            <div class="col-md-6">
                <h1 class="product-title"><%= product.getName() != null ? product.getName() : "Unknown Product" %></h1>
                <p class="product-status">Tình trạng: <%= product.getStatus() != null ? product.getStatus() : "N/A" %> | Mã SKU: <%= (product.getVariants() != null && !product.getVariants().isEmpty()) ? product.getVariants().get(0).getSku() : "N/A" %></p>
                <p class="product-price"><%= product.getPrice() != null ? currencyFormat.format(product.getPrice()) : "N/A" %></p>
                <div class="product-info">
                    <p><strong>Description:</strong> <%= product.getDescription() != null ? product.getDescription() : "No description available" %></p>
                    <p><strong>Category:</strong> <%= product.getCategory() != null ? product.getCategory().getName() : "N/A" %></p>
                    <p><strong>Brand:</strong> <%= product.getBrand() != null ? product.getBrand().getName() : "N/A" %></p>
                    <p><strong>Material:</strong> <%= product.getMaterial() != null ? product.getMaterial() : "N/A" %></p>
                </div>
                <div class="variant-selector">
                    <label for="variantSelect">Select Variant:</label>
                    <select id="variantSelect" name="variantId" class="form-select">
                        <%
                            if (product.getVariants() != null && !product.getVariants().isEmpty()) {
                                for (ProductVariant variant : product.getVariants()) {
                                    String variantLabel = (variant.getSize() != null ? variant.getSize() : "") + " - " + 
                                                        (variant.getColor() != null ? variant.getColor() : "") + 
                                                        (variant.getPriceModifier() != null ? " (" + currencyFormat.format(variant.getPriceModifier()) + ")" : "");
                        %>
                            <option value="<%= variant.getVariantId() %>" <%= product.getDefaultVariantId() != null && product.getDefaultVariantId().equals(variant.getVariantId()) ? "selected" : "" %>>
                                <%= variantLabel %>
                            </option>
                        <%
                                }
                            } else {
                        %>
                            <option value="0">No variants available</option>
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
                    <a href="#" class="btn btn-dark">Thêm Vào Giỏ</a>
                    <a href="#" class="btn btn-orange">Mua Ngay</a>
                </div>
                <div class="shipping-info">
                    <ul>
                        <li>⚡ Sản phẩm hiện có 4 người đang xem</li>
                        <li>🚚 Giao hàng toàn quốc: Thanh toán (COD) khi nhận hàng</li>
                        <li>🎁 Miễn phí giao hàng: Theo chính sách</li>
                        <li>🔄 Đổi trả trong 7 ngày: Nếu không vừa hoặc lỗi</li>
                        <li>📞 Hỗ trợ 24/7: Theo chính sách</li>
                    </ul>
                </div>
            </div>
        </div>
    <% } else { %>
        <p class="text-center">No product details available.</p>
    <% } %>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        const mainImage = document.querySelector('.product-image-main');
        const thumbnails = document.querySelectorAll('.thumbnail-column img');
        let currentIndex = 0;

        thumbnails.forEach((thumb, index) => {
            if (thumb.classList.contains('active')) {
                currentIndex = index;
            }
        });

        window.updateMainImage = function(selectedThumb) {
            mainImage.src = selectedThumb.src;
            thumbnails.forEach(t => t.classList.remove('active'));
            selectedThumb.classList.add('active');
            thumbnails.forEach((thumb, index) => {
                if (thumb.classList.contains('active')) {
                    currentIndex = index;
                }
            });
        }

        window.navigateImage = function(direction) {
            let newIndex = currentIndex + direction;
            if (newIndex >= thumbnails.length) {
                newIndex = 0;
            } else if (newIndex < 0) {
                newIndex = thumbnails.length - 1;
            }
            updateMainImage(thumbnails[newIndex]);
        }
        
        const quantityInput = document.getElementById('quantity');
        window.decreaseQuantity = function() {
            let value = parseInt(quantityInput.value);
            if (value > 1) quantityInput.value = value - 1;
        }
        window.increaseQuantity = function() {
            let value = parseInt(quantityInput.value);
            quantityInput.value = value + 1;
        }
    });
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />