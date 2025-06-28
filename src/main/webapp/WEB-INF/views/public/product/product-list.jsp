<%-- FILE: /WEB-INF/views/public/product/product-list.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Product" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>

<%
    String pageTitle = (String) request.getAttribute("pageTitle");
    if (pageTitle == null) {
        pageTitle = "Products";
    }
    String error = (String) request.getAttribute("error");
    List<Product> products = (List<Product>) request.getAttribute("products");
    NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
    request.setAttribute("pageTitle", pageTitle);
%>

<jsp:include page="/WEB-INF/views/common/header.jsp" />

<style>
    .section-title {
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 1px;
        margin-bottom: 40px;
        font-size: 1.8rem;
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
        aspect-ratio: 4 / 5;
        object-fit: cover;
    }
    .product-card:hover img {
        transform: scale(1.05);
    }
    .product-card .product-title {
        font-size: 1rem;
        font-weight: 500;
        color: #333;
        text-decoration: none;
        display: block;
        height: 40px;
    }
    .product-card .product-title:hover {
        color: #000;
    }
    .product-card .product-price {
        font-size: 1.1rem;
        font-weight: 600;
        color: #111;
    }
    .product-card .btn-container {
        display: flex;
        justify-content: center;
        gap: 10px;
    }
    .error-message {
        color: red;
        font-weight: 500;
        margin-bottom: 20px;
    }
</style>

<div class="container my-5 py-5">
    <div class="text-center">
        <h2 class="section-title"><%= pageTitle %></h2>
        <%
            if (error != null && !error.isEmpty()) {
        %>
        <p class="error-message"><%= error %></p>
        <%
            }
        %>
    </div>
    <div class="row">
        <%
            if (products != null && !products.isEmpty()) {
                for (Product product : products) {
                    String imageUrl = product.getImageUrl() != null ? product.getImageUrl() : "https://placehold.co/400x500/f0f0f0/333?text=No+Image";
                    String name = product.getName() != null ? product.getName() : "Unknown Product";
                    String price = product.getPrice() != null ? currencyFormat.format(product.getPrice()) : "N/A";
                    Long variantId = product.getDefaultVariantId();
                    boolean hasVariant = variantId != null && variantId != 0;
        %>
        <div class="col-lg-3 col-md-4 col-6">
            <div class="product-card">
                <div class="product-image">
                    <a href="<%= request.getContextPath() %>/ProductList/detail?productId=<%= product.getProductId() %>">
                        <img src="<%= imageUrl %>" alt="<%= name %>">
                    </a>
                </div>
                <a href="<%= request.getContextPath() %>/ProductList/detail?productId=<%= product.getProductId() %>" class="product-title"><%= name %></a>
                <p class="product-price"><%= price %></p>
                <div class="btn-container">
                    <form action="<%= request.getContextPath() %>/customer/cart" method="post">
                        <input type="hidden" name="action" value="add">
                        <input type="hidden" name="variantId" value="<%= hasVariant ? variantId : 0 %>">
                        <input type="hidden" name="quantity" value="1">
                        <button type="submit" class="btn btn-dark btn-sm" <%= hasVariant ? "" : "disabled" %>>Add to Cart</button>
                    </form>
                    <form action="<%= request.getContextPath() %>/customer/checkout" method="post">
                        <input type="hidden" name="action" value="buy">
                        <input type="hidden" name="variantId" value="<%= hasVariant ? variantId : 0 %>">
                        <input type="hidden" name="quantity" value="1">
                        <button type="submit" class="btn btn-primary btn-sm" <%= hasVariant ? "" : "disabled" %>>Buy Now</button>
                    </form>
                </div>
            </div>
        </div>
        <%
                }
            } else {
        %>
        <div class="col-12 text-center">
            <p>No products available in this category.</p>
        </div>
        <%
            }
        %>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />