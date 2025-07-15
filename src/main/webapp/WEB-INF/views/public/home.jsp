<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="model.Product" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="dao.CategoryDAO" %>
<%@ page import="model.Category" %>
<%@ page import="java.sql.SQLException" %>

<%
    String pageTitle = (String) request.getAttribute("pageTitle");
    if (pageTitle == null) {
        pageTitle = "Homepage";
    }
    List<Product> newProducts = (List<Product>) request.getAttribute("newProducts");
    List<Product> bestSellers = (List<Product>) request.getAttribute("bestSellers");
    Map<Long, Integer> availableMap = (Map<Long, Integer>) request.getAttribute("availableMap");
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
    .hero-banner {
        height: 85vh;
        background-size: cover;
        background-position: center;
        display: flex;
        align-items: center;
        justify-content: center;
        text-align: center;
        color: white;
        text-shadow: 2px 2px 8px rgba(0, 0, 0, 0.6);
    }
    .hero-banner h1 {
        font-size: 4rem;
        font-weight: 700;
        text-transform: uppercase;
    }
    .hero-banner .lead {
        font-size: 1.25rem;
        font-weight: 300;
        max-width: 600px;
        margin: 1rem auto;
    }
    .hero-banner .btn {
        padding: 0.8rem 2.5rem;
        font-size: 1rem;
        font-weight: 600;
        border-radius: 50px;
        text-transform: uppercase;
        letter-spacing: 1px;
    }
    .section-title {
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 1px;
        margin-bottom: 40px;
        font-size: 1.8rem;
    }
    .category-showcase-card {
        position: relative;
        overflow: hidden;
        border-radius: 5px;
    }
    .category-showcase-card img {
        transition: transform 0.5s ease;
        width: 100%;
        height: auto;
    }
    .category-showcase-card:hover img {
        transform: scale(1.05);
    }
    .category-showcase-card .content {
        position: absolute;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        text-align: center;
        color: white;
        text-shadow: 2px 2px 8px rgba(0, 0, 0, 0.7);
    }
    .category-showcase-card .content h2 {
        font-size: 2.5rem;
        font-weight: 700;
        text-transform: uppercase;
    }
    .category-showcase-card .btn-outline-light {
        border-radius: 50px;
        padding: 0.6rem 2rem;
        border-width: 2px;
        font-weight: 600;
    }
    .product-card {
        border: 1px solid #eee;
        text-align: center;
        margin-bottom: 1.5rem;
        border-radius: 5px;
        overflow: hidden;
        background: #fff;
        transition: transform 0.2s ease, box-shadow 0.2s ease;
        padding: 10px;
    }
    .product-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 8px 20px rgba(0,0,0,0.08);
    }
    .product-card .product-image {
        overflow: hidden;
        margin-bottom: 0.8rem;
    }
    .product-card img {
        width: 100%;
        transition: transform 0.4s ease;
        aspect-ratio: 1 / 2.2; /* Taller aspect ratio for even more vertical height */
        object-fit: cover;
        max-height: 320px; /* Increased height for taller image */
    }
    .product-card:hover img {
        transform: scale(1.05);
    }
    .product-card .product-title {
        font-size: 0.85rem;
        font-weight: 500;
        color: #333;
        text-decoration: none;
        display: -webkit-box;
        -webkit-line-clamp: 2;
        -webkit-box-orient: vertical;
        overflow: hidden;
        height: 34px;
        padding: 0 6px;
        margin-bottom: 5px;
    }
    .product-card .product-title:hover {
        color: #000;
    }
    .product-card .product-price {
        font-size: 0.95rem;
        font-weight: 600;
        color: #111;
        margin-bottom: 8px;
    }
    .product-card .btn-container {
        display: flex;
        justify-content: center;
        gap: 6px;
        padding: 0 6px 8px 6px;
    }
    .product-card .btn-custom-sm {
        padding: 0.25rem 0.7rem;
        font-size: 0.75rem;
        line-height: 1.5;
    }
    .promo-banner {
        background-color: #e9ecef;
        padding: 4rem 1rem;
        text-align: center;
    }
    .promo-banner h2 {
        font-weight: 700;
        font-size: 2.5rem;
    }
    .error-message {
        color: red;
        font-weight: 500;
        margin-top: 20px;
    }
    @media (max-width: 1200px) {
        .col-lg-3 {
            flex: 0 0 33.333333%;
            max-width: 33.333333%;
        }
    }
    @media (max-width: 992px) {
        .col-lg-3 {
            flex: 0 0 50%;
            max-width: 50%;
        }
    }
    @media (max-width: 768px) {
        .col-md-6 {
            flex: 0 0 50%;
            max-width: 50%;
        }
    }
    @media (max-width: 576px) {
        .col-md-6 {
            flex: 0 0 100%;
            max-width: 100%;
        }
    }
</style>

<div class="hero-banner" style="background-image: url('https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?q=80&w=2070&auto=format&fit=crop');">
    <div>
        <h1>New Season Styles</h1>
        <p class="lead">Explore our curated collection of contemporary fashion for the modern individual.</p>
        <a href="#" class="btn btn-light btn-lg mt-3">Discover Now</a>
    </div>
</div>

<div class="container my-5 py-5">
    <div class="row g-4">
        <% if (showMenCategory) {%>
        <div class="col-md-6">
            <div class="category-showcase-card">
                <img src="https://images.unsplash.com/photo-1552374196-1ab2a1c593e8?q=80&w=1974&auto=format&fit=crop" alt="Men's Fashion">
                <div class="content">
                    <h2>Men</h2>
                    <a href="<%= request.getContextPath()%>/ProductList/men" class="btn btn-outline-light mt-2">Shop Collection</a>
                </div>
            </div>
        </div>
        <% } %>
        <% if (showWomenCategory) {%>
        <div class="col-md-6">
            <div class="category-showcase-card">
                <img src="https://images.unsplash.com/photo-1581338834647-b0fb40704e21?q=80&w=1974&auto=format&fit=crop" alt="Women's Fashion">
                <div class="content">
                    <h2>Women</h2>
                    <a href="<%= request.getContextPath()%>/ProductList/women" class="btn btn-outline-light mt-2">Shop Collection</a>
                </div>
            </div>
        </div>
        <% } %>
        <% if (!showMenCategory && !showWomenCategory && categoryError != null) {%>
        <div class="col-12 text-center">
            <p class="error-message"><%= categoryError%></p>
        </div>
        <% } %>
    </div>

    <div class="text-center mt-5 pt-5">
        <h2 class="section-title">New Arrivals</h2>
    </div>
    <div class="row">
        <%
            if (newProducts != null && !newProducts.isEmpty()) {
                for (Product product : newProducts) {
                    String imageUrl = product.getImageUrl() != null ? product.getImageUrl() : "https://placehold.co/400x500/f0f0f0/333?text=No+Image";
                    String name = product.getName() != null ? product.getName() : "Unknown Product";
                    String price = product.getPrice() != null ? currencyFormat.format(product.getPrice()) : "N/A";
                    Long variantId = product.getDefaultVariantId();
                    boolean hasVariant = variantId != null && variantId != 0;
                    int available = (availableMap != null) ? availableMap.getOrDefault(product.getProductId(), 0) : 0;
                    System.out.println("home.jsp - New Arrival Product ID: " + product.getProductId() + ", variantId: " + variantId + ", available: " + available);  // Log debug
                    boolean hasStock = hasVariant && (available > 0);
                    String buttonTextCart = hasStock ? "Add to Cart" : "Out Stock";
                    String buttonTextBuy = hasStock ? "Buy Now" : "Out Stock";
        %>
        <div class="col-lg-3 col-md-6 col-sm-6 col-12">
            <div class="product-card">
                <div class="product-image">
                    <a href="<%= request.getContextPath()%>/ProductList/detail?productId=<%= product.getProductId()%>">
                        <img src="<%= imageUrl%>" alt="<%= name%>">
                    </a>
                </div>
                <a href="<%= request.getContextPath()%>/ProductList/detail?productId=<%= product.getProductId()%>" class="product-title"><%= name%></a>
                <p class="product-price"><%= price%></p>
                <div class="btn-container">
                    <form action="<%= request.getContextPath()%>/customer/cart" method="post">
                        <input type="hidden" name="action" value="add">
                        <input type="hidden" name="variantId" value="<%= hasVariant ? variantId : 0%>">
                        <input type="hidden" name="quantity" value="1">
                        <button type="submit" class="btn btn-dark btn-custom-sm" <%= hasStock ? "" : "disabled"%>><%= buttonTextCart %></button>
                    </form>
                    <form action="<%= request.getContextPath()%>/customer/checkout" method="post">
                        <input type="hidden" name="action" value="buy">
                        <input type="hidden" name="variantId" value="<%= hasVariant ? variantId : 0%>">
                        <input type="hidden" name="quantity" value="1">
                        <button type="submit" class="btn btn-primary btn-custom-sm" <%= hasStock ? "" : "disabled"%>><%= buttonTextBuy %></button>
                    </form>
                </div>
            </div>
        </div>
        <%
            }
        } else {
        %>
        <div class="col-12 text-center">
            <p>No new products available.</p>
        </div>
        <%
            }
        %>
    </div>
</div>

<div class="promo-banner my-5">
    <div class="container">
        <h2>END OF SEASON SALE</h2>
        <p class="lead">Get up to 60% off on your favorite styles. Limited time only!</p>
        <a href="#" class="btn btn-dark btn-lg mt-3">Shop The Sale</a>
    </div>
</div>

<div class="container my-5 py-5">
    <div class="text-center">
        <h2 class="section-title">Best Sellers</h2>
    </div>
    <div class="row">
        <%
            if (bestSellers != null && !bestSellers.isEmpty()) {
                for (Product product : bestSellers) {
                    String imageUrl = product.getImageUrl() != null ? product.getImageUrl() : "https://placehold.co/400x500/f0f0f0/333?text=No+Image";
                    String name = product.getName() != null ? product.getName() : "Unknown Product";
                    String price = product.getPrice() != null ? currencyFormat.format(product.getPrice()) : "N/A";
                    Long variantId = product.getDefaultVariantId();
                    boolean hasVariant = variantId != null && variantId != 0;
                    int available = (availableMap != null) ? availableMap.getOrDefault(product.getProductId(), 0) : 0;
                    System.out.println("home.jsp - Best Seller Product ID: " + product.getProductId() + ", variantId: " + variantId + ", available: " + available);  // Log debug
                    boolean hasStock = hasVariant && (available > 0);
                    String buttonTextCart = hasStock ? "Add to Cart" : "Out Stock";
                    String buttonTextBuy = hasStock ? "Buy Now" : "Out Stock";
        %>
        <div class="col-lg-3 col-md-6 col-sm-6 col-12">
            <div class="product-card">
                <div class="product-image">
                    <a href="<%= request.getContextPath()%>/ProductList/detail?productId=<%= product.getProductId()%>">
                        <img src="<%= imageUrl%>" alt="<%= name%>">
                    </a>
                </div>
                <a href="<%= request.getContextPath()%>/ProductList/detail?productId=<%= product.getProductId()%>" class="product-title"><%= name%></a>
                <p class="product-price"><%= price%></p>
                <div class="btn-container">
                    <form action="<%= request.getContextPath()%>/customer/cart" method="post">
                        <input type="hidden" name="action" value="add">
                        <input type="hidden" name="variantId" value="<%= hasVariant ? variantId : 0%>">
                        <input type="hidden" name="quantity" value="1">
                        <button type="submit" class="btn btn-dark btn-custom-sm" <%= hasStock ? "" : "disabled"%>><%= buttonTextCart %></button>
                    </form>
                    <form action="<%= request.getContextPath()%>/customer/checkout" method="post">
                        <input type="hidden" name="action" value="buy">
                        <input type="hidden" name="variantId" value="<%= hasVariant ? variantId : 0%>">
                        <input type="hidden" name="quantity" value="1">
                        <button type="submit" class="btn btn-primary btn-custom-sm" <%= hasStock ? "" : "disabled"%>><%= buttonTextBuy %></button>
                    </form>
                </div>
            </div>
        </div>
        <%
            }
        } else {
        %>
        <div class="col-12 text-center">
            <p>No best sellers available.</p>
        </div>
        <%
            }
        %>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />