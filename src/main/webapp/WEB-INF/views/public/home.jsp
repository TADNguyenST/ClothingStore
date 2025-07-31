<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="model.Product" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="dao.CategoryDAO" %>
<%@ page import="model.Category" %>
<%@ page import="java.sql.SQLException" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    String pageTitle = (String) request.getAttribute("pageTitle");
    if (pageTitle == null) {
        pageTitle = "Welcome to ClothingStore";
    }
    List<Product> newProducts = (List<Product>) request.getAttribute("newProducts");
    List<Product> bestSellers = (List<Product>) request.getAttribute("bestSellers");
    Map<Long, Integer> availableMap = (Map<Long, Integer>) request.getAttribute("availableMap");
    Set<Integer> wishlistProductIds = (Set<Integer>) request.getAttribute("wishlistProductIds");
    NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
    request.setAttribute("pageTitle", pageTitle);

    Long menCategoryId = null;
    Long womenCategoryId = null;
    boolean showMenCategory = false;
    boolean showWomenCategory = false;
    String categoryError = null;
    try {
        CategoryDAO categoryDAO = new CategoryDAO();
        List<Category> parentCategories = categoryDAO.getParentCategories();
        if (parentCategories == null || parentCategories.isEmpty()) {
            System.out.println("Warning: parentCategories is null or empty from CategoryDAO.getParentCategories() in home.jsp");
            categoryError = "No categories available. Please contact the administrator.";
            parentCategories = new ArrayList<>();
        } else {
            System.out.println("Parent Categories (home.jsp): " + parentCategories.size() + " found");
            for (Category c : parentCategories) {
                System.out.println("Parent Category [id=" + (c != null ? c.getCategoryId() : "null")
                        + ", name=" + (c != null && c.getName() != null ? c.getName() : "null")
                        + ", parentCategoryId=" + (c != null ? c.getParentCategoryId() : "null")
                        + ", isActive=" + (c != null ? c.isActive() : "null") + "]");
            }

            List<Category> parentCats = parentCategories;

            if (!parentCats.isEmpty()) {
                menCategoryId = parentCats.get(0).getCategoryId();
                showMenCategory = true;
                if (parentCats.size() > 1) {
                    womenCategoryId = parentCats.get(1).getCategoryId();
                    showWomenCategory = true;
                } else {
                    System.out.println("Warning: Only one parent category found, hiding Women section");
                    categoryError = "Only one category available.";
                }
            } else {
                System.out.println("Warning: No parent categories found, hiding Men and Women sections");
                categoryError = "No categories available. Please contact the administrator.";
            }

            System.out.println("Men Category ID: " + menCategoryId);
            System.out.println("Women Category ID: " + womenCategoryId);
        }
    } catch (Exception e) {
        System.err.println("Error fetching categories in home.jsp: " + e.getMessage());
        e.printStackTrace();
        showMenCategory = false;
        showWomenCategory = false;
        categoryError = "Error loading categories: " + e.getMessage();
    }
%>

<jsp:include page="/WEB-INF/views/common/header.jsp" />

<style>
    body {
        font-family: 'Poppins', sans-serif;
        background-color: #f8fafc;
    }
    .hero-section {
        position: relative;
        height: 80vh;
        background: linear-gradient(rgba(0, 0, 0, 0.5), rgba(0, 0, 0, 0.5)), url('https://images.unsplash.com/photo-1511556820780-d912e42b4980?q=80&w=2070&auto=format&fit=crop');
        background-size: cover;
        background-position: center;
        display: flex;
        align-items: center;
        justify-content: center;
        color: white;
        text-align: center;
    }
    .hero-section .content {
        max-width: 700px;
        padding: 20px;
    }
    .hero-section h1 {
        font-size: 3.5rem;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 2px;
        margin-bottom: 1rem;
    }
    .hero-section p {
        font-size: 1.2rem;
        font-weight: 300;
        margin-bottom: 2rem;
    }
    .hero-section .btn {
        padding: 0.8rem 2rem;
        font-size: 1rem;
        font-weight: 600;
        border-radius: 30px;
        transition: all 0.3s ease;
    }
    .hero-section .btn:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
    }
    .category-section {
        padding: 4rem 0;
        background-color: #fff;
    }
    .category-card {
        position: relative;
        overflow: hidden;
        border-radius: 10px;
        box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
        transition: transform 0.3s ease;
    }
    .category-card:hover {
        transform: translateY(-5px);
    }
    .category-card img {
        width: 100%;
        height: 300px;
        object-fit: cover;
        transition: transform 0.5s ease;
    }
    .category-card:hover img {
        transform: scale(1.1);
    }
    .category-card .content {
        position: absolute;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        text-align: center;
        color: white;
        text-shadow: 1px 1px 5px rgba(0, 0, 0, 0.7);
    }
    .category-card h3 {
        font-size: 2rem;
        font-weight: 600;
    }
    .category-card .btn {
        border-radius: 30px;
        padding: 0.5rem 1.5rem;
        font-weight: 500;
    }
    .section-title {
        font-size: 2rem;
        font-weight: 700;
        text-align: center;
        margin-bottom: 3rem;
        color: #1e3a8a;
    }
    .product-section {
        padding: 4rem 0;
        background-color: #f1f5f9;
    }
    .product-card {
        background: white;
        border-radius: 10px;
        overflow: hidden;
        box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
        transition: transform 0.3s ease, box-shadow 0.3s ease;
    }
    .product-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 8px 20px rgba(0, 0, 0, 0.15);
    }
    .product-card img {
        width: 100%;
        height: 280px;
        object-fit: cover;
        transition: transform 0.4s ease;
    }
    .product-card:hover img {
        transform: scale(1.05);
    }
    .product-card .card-body {
        padding: 1.5rem;
        text-align: center;
    }
    .product-card .product-title {
        font-size: 1rem;
        font-weight: 500;
        color: #1e3a8a;
        text-decoration: none;
        display: -webkit-box;
        -webkit-line-clamp: 2;
        -webkit-box-orient: vertical;
        overflow: hidden;
        height: 40px;
        margin-bottom: 0.5rem;
    }
    .product-card .product-price {
        font-size: 1.1rem;
        font-weight: 600;
        color: #111;
        margin-bottom: 1rem;
    }
    .product-card .btn-container {
        display: flex;
        justify-content: center;
        gap: 10px;
    }
    .product-card .btn {
        padding: 0.5rem 1rem;
        font-size: 0.9rem;
        border-radius: 20px;
        transition: all 0.3s ease;
    }
    .product-card .add-to-cart-btn.added {
        background-color: #10b981 !important;
        transform: scale(1.1);
    }
    .promo-section {
        padding: 4rem 0;
        background: linear-gradient(135deg, #60a5fa, #3b82f6);
        color: white;
        text-align: center;
    }
    .promo-section h2 {
        font-size: 2.5rem;
        font-weight: 700;
        margin-bottom: 1rem;
    }
    .promo-section p {
        font-size: 1.2rem;
        font-weight: 300;
        max-width: 600px;
        margin: 0 auto 2rem;
    }
    .promo-section .btn {
        padding: 0.8rem 2rem;
        font-size: 1rem;
        border-radius: 30px;
    }
    .error-message {
        color: #dc2626;
        font-weight: 500;
        text-align: center;
        margin-top: 2rem;
    }
    .wishlist-icon {
        position: absolute;
        top: 10px;
        right: 10px;
        z-index: 10;
    }
    .wishlist-icon-circle {
        background-color: white;
        border: 1px solid #ddd;
        border-radius: 50%;
        width: 32px;
        height: 32px;
        display: flex;
        align-items: center;
        justify-content: center;
        color: #666;
        font-size: 14px;
        cursor: pointer;
        transition: all 0.3s ease;
    }
    .wishlist-icon-circle:hover, .wishlist-icon-circle.active {
        border-color: #ef4444;
        color: #ef4444;
    }
    .toast-container {
        z-index: 1055;
    }
    @media (max-width: 992px) {
        .hero-section h1 {
            font-size: 2.5rem;
        }
        .category-card img {
            height: 200px;
        }
        .product-card img {
            height: 220px;
        }
    }
    @media (max-width: 576px) {
        .hero-section h1 {
            font-size: 2rem;
        }
        .hero-section p {
            font-size: 1rem;
        }
        .category-card img {
            height: 150px;
        }
        .product-card img {
            height: 180px;
        }
    }
</style>

<div class="hero-section">
    <div class="content">
        <h1>Discover Your Style</h1>
        <p>Elevate your wardrobe with our latest trends and timeless pieces.</p>
        <a href="${pageContext.request.contextPath}/ProductList" class="btn btn-light">Shop Now</a>
    </div>
</div>

<div class="category-section">
    <div class="container">
        <h2 class="section-title">Shop by Category</h2>
        <div class="row g-4">
            <% if (showMenCategory) { %>
            <div class="col-md-6">
                <div class="category-card">
                    <img src="https://images.unsplash.com/photo-1532453288672-3a27e9be9efd?q=80&w=2070&auto=format&fit=crop" alt="Men's Collection">
                    <div class="content">
                        <h3>Men's Collection</h3>
                        <a href="<%= request.getContextPath()%>/ProductList/men" class="btn btn-outline-light">Explore Men</a>
                    </div>
                </div>
            </div>
            <% } %>
            <% if (showWomenCategory) { %>
            <div class="col-md-6">
                <div class="category-card">
                    <img src="https://images.unsplash.com/photo-1529139574466-a303027c1d8b?q=80&w=2070&auto=format&fit=crop" alt="Women's Collection">
                    <div class="content">
                        <h3>Women's Collection</h3>
                        <a href="<%= request.getContextPath()%>/ProductList/women" class="btn btn-outline-light">Explore Women</a>
                    </div>
                </div>
            </div>
            <% } %>
            <% if (!showMenCategory && !showWomenCategory && categoryError != null) { %>
            <div class="col-12">
                <p class="error-message"><%= categoryError %></p>
            </div>
            <% } %>
        </div>
    </div>
</div>

<div class="product-section">
    <div class="container">
        <h2 class="section-title">New Arrivals</h2>
        <div class="row g-4">
            <%
                if (newProducts != null && !newProducts.isEmpty()) {
                    for (Product product : newProducts) {
                        String imageUrl = product.getImageUrl() != null ? product.getImageUrl() : "https://placehold.co/400x500/eee/333?text=No+Image";
                        String name = product.getName() != null ? product.getName() : "Unknown Product";
                        String price = product.getPrice() != null ? currencyFormat.format(product.getPrice()) : "N/A";
                        Long variantId = product.getDefaultVariantId();
                        boolean hasVariant = variantId != null && variantId != 0;
                        int available = (availableMap != null) ? availableMap.getOrDefault(product.getProductId(), 0) : 0;
                        System.out.println("home.jsp - New Arrival Product ID: " + product.getProductId() + ", variantId: " + variantId + ", available: " + available);
                        boolean hasStock = hasVariant && (available > 0);
                        String buttonTextCart = hasStock ? "Add to Cart" : "Out of Stock";
                        String buttonTextBuy = hasStock ? "Buy Now" : "Out of Stock";
            %>
            <div class="col-lg-3 col-md-6 col-sm-6 col-12">
                <div class="product-card">
                    <div class="wishlist-icon">
                        <form action="<%= request.getContextPath()%>/wishlist" method="post">
                            <input type="hidden" name="action" value="add">
                            <input type="hidden" name="productId" value="<%= product.getProductId()%>">
                            <button type="submit" class="wishlist-icon-circle <%= (wishlistProductIds != null && wishlistProductIds.contains(product.getProductId())) ? "active" : ""%>">
                                <i class="fas fa-heart"></i>
                            </button>
                        </form>
                    </div>
                    <img src="<%= imageUrl%>" alt="<%= name%>">
                    <div class="card-body">
                        <a href="<%= request.getContextPath()%>/ProductList/detail?productId=<%= product.getProductId()%>" class="product-title"><%= name%></a>
                        <p class="product-price"><%= price%></p>
                        <div class="btn-container">
                            <form id="addToCartForm-<%= product.getProductId()%>" data-product-id="<%= product.getProductId()%>" data-variant-id="<%= hasVariant ? variantId : 0%>" data-has-stock="<%= hasStock%>">
                                <input type="hidden" name="action" value="add">
                                <input type="hidden" name="variantId" value="<%= hasVariant ? variantId : 0%>">
                                <input type="hidden" name="quantity" value="1" min="1" max="<%= available %>">
                                <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                <button type="button" class="btn btn-dark add-to-cart-btn" <%= !hasStock ? "disabled" : ""%>><%= buttonTextCart%></button>
                            </form>
                            <form action="<%= request.getContextPath()%>/customer/checkout" method="post">
                                <input type="hidden" name="action" value="buy">
                                <input type="hidden" name="variantId" value="<%= hasVariant ? variantId : 0%>">
                                <input type="hidden" name="quantity" value="1">
                                <button type="submit" class="btn btn-primary" <%= !hasStock ? "disabled" : ""%>><%= buttonTextBuy%></button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
            <%
                }
            } else {
            %>
            <div class="col-12">
                <p class="error-message">No new products available.</p>
            </div>
            <%
                }
            %>
        </div>
    </div>
</div>

<div class="promo-section">
    <div class="container">
        <h2>Exclusive Offers Await</h2>
        <p>Discover unbeatable deals on our curated collections. Shop now to save big!</p>
        <a href="${pageContext.request.contextPath}/ProductList/sale" class="btn btn-light">Explore Deals</a>
    </div>
</div>

<div class="product-section">
    <div class="container">
        <h2 class="section-title">Best Sellers</h2>
        <div class="row g-4">
            <%
                if (bestSellers != null && !bestSellers.isEmpty()) {
                    for (Product product : bestSellers) {
                        String imageUrl = product.getImageUrl() != null ? product.getImageUrl() : "https://placehold.co/400x500/eee/333?text=No+Image";
                        String name = product.getName() != null ? product.getName() : "Unknown Product";
                        String price = product.getPrice() != null ? currencyFormat.format(product.getPrice()) : "N/A";
                        Long variantId = product.getDefaultVariantId();
                        boolean hasVariant = variantId != null && variantId != 0;
                        int available = (availableMap != null) ? availableMap.getOrDefault(product.getProductId(), 0) : 0;
                        System.out.println("home.jsp - Best Seller Product ID: " + product.getProductId() + ", variantId: " + variantId + ", available: " + available);
                        boolean hasStock = hasVariant && (available > 0);
                        String buttonTextCart = hasStock ? "Add to Cart" : "Out of Stock";
                        String buttonTextBuy = hasStock ? "Buy Now" : "Out of Stock";
            %>
            <div class="col-lg-3 col-md-6 col-sm-6 col-12">
                <div class="product-card">
                    <div class="wishlist-icon">
                        <form action="<%= request.getContextPath()%>/wishlist" method="post">
                            <input type="hidden" name="action" value="add">
                            <input type="hidden" name="productId" value="<%= product.getProductId()%>">
                            <button type="submit" class="wishlist-icon-circle <%= (wishlistProductIds != null && wishlistProductIds.contains(product.getProductId())) ? "active" : ""%>">
                                <i class="fas fa-heart"></i>
                            </button>
                        </form>
                    </div>
                    <img src="<%= imageUrl%>" alt="<%= name%>">
                    <div class="card-body">
                        <a href="<%= request.getContextPath()%>/ProductList/detail?productId=<%= product.getProductId()%>" class="product-title"><%= name%></a>
                        <p class="product-price"><%= price%></p>
                        <div class="btn-container">
                            <form id="addToCartForm-<%= product.getProductId()%>" data-product-id="<%= product.getProductId()%>" data-variant-id="<%= hasVariant ? variantId : 0%>" data-has-stock="<%= hasStock%>">
                                <input type="hidden" name="action" value="add">
                                <input type="hidden" name="variantId" value="<%= hasVariant ? variantId : 0%>">
                                <input type="hidden" name="quantity" value="1" min="1" max="<%= available %>">
                                <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                <button type="button" class="btn btn-dark add-to-cart-btn" <%= !hasStock ? "disabled" : ""%>><%= buttonTextCart%></button>
                            </form>
                            <form action="<%= request.getContextPath()%>/customer/checkout" method="post">
                                <input type="hidden" name="action" value="buy">
                                <input type="hidden" name="variantId" value="<%= hasVariant ? variantId : 0%>">
                                <input type="hidden" name="quantity" value="1">
                                <button type="submit" class="btn btn-primary" <%= !hasStock ? "disabled" : ""%>><%= buttonTextBuy%></button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
            <%
                }
            } else {
            %>
            <div class="col-12">
                <p class="error-message">No best sellers available.</p>
            </div>
            <%
                }
            %>
        </div>
    </div>
</div>

<!-- Toast Container -->
<div class="toast-container position-fixed bottom-0 end-0 p-3">
    <div id="successToast" class="toast" role="alert" aria-live="assertive" aria-atomic="true">
        <div class="toast-header bg-success text-white">
            <strong class="me-auto">Success</strong>
            <button type="button" class="btn-close" data-bs-dismiss="toast" aria-label="Close"></button>
        </div>
        <div class="toast-body" id="successToastBody"></div>
    </div>
    <div id="errorToast" class="toast" role="alert" aria-live="assertive" aria-atomic="true">
        <div class="toast-header bg-danger text-white">
            <strong class="me-auto">Error</strong>
            <button type="button" class="btn-close" data-bs-dismiss="toast" aria-label="Close"></button>
        </div>
        <div class="toast-body" id="errorToastBody"></div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

<script>
    document.addEventListener('DOMContentLoaded', function () {
        var toastSuccess = new bootstrap.Toast(document.getElementById('successToast'), {delay: 3000});
        var toastError = new bootstrap.Toast(document.getElementById('errorToast'), {delay: 3000});

        function showToast(message, isSuccess) {
            var toast = isSuccess ? toastSuccess : toastError;
            var toastBody = document.getElementById(isSuccess ? 'successToastBody' : 'errorToastBody');
            toastBody.textContent = message;
            toast.show();
        }

        // Use the global updateCartCount function from header.jsp
        function updateCartCount() {
            if (window.updateCartCount) {
                window.updateCartCount();
            } else {
                // Fallback if global function is not available
                fetch('${pageContext.request.contextPath}/customer/cart/count', {
                    method: 'GET',
                    headers: {
                        'Accept': 'application/json'
                    }
                })
                        .then(response => {
                            if (!response.ok)
                                throw new Error('Network response was not ok: ' + response.statusText);
                            return response.json();
                        })
                        .then(data => {
                            const cartCountElement = document.getElementById('cartCount');
                            if (cartCountElement) {
                                cartCountElement.textContent = data.count || 0;
                                console.log('Cart count updated:', data.count);
                            }
                        })
                        .catch(error => {
                            console.error('Error updating cart count:', error);
                            const cartCountElement = document.getElementById('cartCount');
                            if (cartCountElement)
                                cartCountElement.textContent = '0';
                        });
            }
        }

        document.querySelectorAll('.add-to-cart-btn').forEach(button => {
            button.addEventListener('click', function (e) {
                e.preventDefault();
                const form = this.closest('form');
                const productId = form.getAttribute('data-product-id');
                const variantId = form.getAttribute('data-variant-id');
                const hasStock = form.getAttribute('data-has-stock') === 'true';
                const quantity = parseInt(form.querySelector('input[name="quantity"]').value);
                const csrfToken = form.querySelector('input[name="csrfToken"]').value;

                if (!hasStock) {
                    showToast('Product is out of stock.', false);
                    return;
                }
                if (isNaN(quantity) || quantity < 1) {
                    showToast('Invalid quantity.', false);
                    return;
                }

                this.classList.add('added');
                this.textContent = 'Adding...';
                fetch('${pageContext.request.contextPath}/customer/cart', {
                    method: 'POST',
                    body: new URLSearchParams({
                        action: 'add',
                        variantId: variantId,
                        quantity: quantity,
                        csrfToken: csrfToken
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
                            console.log('Add to Cart response:', result);
                            if (result.success) {
                                showToast(result.message, true);
                                // Update cart count in header
                                if (window.updateCartCount) {
                                    window.updateCartCount();
                                } else {
                                    updateCartCount();
                                }
                            } else {
                                showToast(result.message || 'Failed to add to cart.', false);
                            }
                            this.classList.remove('added');
                            this.textContent = 'Add to Cart';
                        })
                        .catch(error => {
                            console.error('Error adding to cart:', error);
                            showToast('Error adding to cart: ' + error.message, false);
                            this.classList.remove('added');
                            this.textContent = 'Add to Cart';
                        });
            });
        });

        updateCartCount();
    });
</script>