<%-- ================ FILE: home.jsp ================ --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%-- Đặt tiêu đề cho trang này, header.jsp sẽ dùng biến này --%>
<c:set var="pageTitle" value="Homepage" scope="request"/>

<%-- Nhúng header --%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<style>
    /* CSS cho riêng trang chủ */
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
        border: none;
        text-align: center;
        margin-bottom: 2rem;
    }
    .product-card .product-image {
        overflow: hidden;
        margin-bottom: 1rem;
    }
    .product-card img {
        width: 100%;
        transition: transform 0.4s ease;
    }
    .product-card:hover img {
        transform: scale(1.05);
    }
    .product-card .product-title {
        font-size: 1rem;
        font-weight: 500;
        color: #333;
        text-decoration: none;
    }
    .product-card .product-title:hover {
        color: #000;
    }
    .product-card .product-price {
        font-size: 1.1rem;
        font-weight: 600;
        color: #111;
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
        <div class="col-md-6">
            <div class="category-showcase-card">
                <img src="https://images.unsplash.com/photo-1552374196-1ab2a1c593e8?q=80&w=1974&auto=format&fit=crop" alt="Men's Fashion">
                <div class="content">
                    <h2>Men</h2>
                    <a href="#" class="btn btn-outline-light mt-2">Shop Collection</a>
                </div>
            </div>
        </div>
        <div class="col-md-6">
            <div class="category-showcase-card">
                <img src="https://images.unsplash.com/photo-1581338834647-b0fb40704e21?q=80&w=1974&auto=format&fit=crop" alt="Women's Fashion">
                <div class="content">
                    <h2>Women</h2>
                    <a href="#" class="btn btn-outline-light mt-2">Shop Collection</a>
                </div>
            </div>
        </div>
    </div>

    <div class="text-center mt-5 pt-5">
        <h2 class="section-title">New Arrivals</h2>
    </div>
    <div class="row">
        <%-- LƯU Ý: Vòng lặp này cần dữ liệu thật từ Controller. --%>
        <%-- Ví dụ: controller của bạn cần đặt request.setAttribute("newProducts", productList); --%>
        <c:forEach items="${newProducts}" var="product">
            <div class="col-lg-3 col-md-4 col-6">
                <div class="product-card">
                    <div class="product-image">
                        <a href="#"><img src="${product.imageUrl}" alt="${product.name}"></a>
                    </div>
                    <a href="#" class="product-title">${product.name}</a>
                    <p class="product-price">
                        <fmt:formatNumber value="${product.price}" type="currency" currencyCode="VND" />
                    </p>
                </div>
            </div>
        </c:forEach>
    </div>
    <div class="text-center mt-4">
        <a href="#" class="btn btn-outline-dark">View All New Arrivals</a>
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
        <%-- LƯU Ý: Vòng lặp này cần dữ liệu thật từ Controller. --%>
        <%-- Ví dụ: controller của bạn cần đặt request.setAttribute("bestSellers", productList); --%>
        <c:forEach items="${bestSellers}" var="product">
            <div class="col-lg-3 col-md-4 col-6">
                <div class="product-card">
                    <div class="product-image">
                        <a href="#"><img src="${product.imageUrl}" alt="${product.name}"></a>
                    </div>
                    <a href="#" class="product-title">${product.name}</a>
                    <p class="product-price">
                        <fmt:formatNumber value="${product.price}" type="currency" currencyCode="VND" />
                    </p>
                </div>
            </div>
        </c:forEach>
    </div>
</div>

<%-- Nhúng footer --%>
<jsp:include page="/WEB-INF/views/common/footer.jsp" />