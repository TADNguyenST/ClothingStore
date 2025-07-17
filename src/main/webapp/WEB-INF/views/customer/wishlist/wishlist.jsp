<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Product" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<%
    List<Product> wishlist = (List<Product>) request.getAttribute("wishlistProducts");
%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Wishlist</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <style>
            body {
                background-color: #f8f9fa;
            }
            .wishlist-header {
                text-align: center;
                margin-top: 30px;
            }
            .product-card {
                border: 1px solid #ddd;
                border-radius: 8px;
                background-color: #fff;
                padding: 15px;
                margin-bottom: 20px;
                box-shadow: 0 2px 6px rgba(0,0,0,0.05);
                transition: transform 0.2s;
            }
            .product-card:hover {
                transform: translateY(-4px);
            }
            .product-image {
                height: 180px;
                object-fit: cover;
                width: 100%;
                border-radius: 6px;
            }
            .product-name {
                font-weight: 600;
                margin-top: 10px;
                min-height: 48px;
                display: block;
                text-decoration: none;
                color: black;
            }
            .product-price {
                color: #d00;
                font-size: 16px;
                font-weight: bold;
            }
            .btn-group-sm .btn {
                margin-right: 4px;
            }
        </style>
    </head>
    <body>
        <div class="container mt-5">
            <h2 class="wishlist-header">Wishlist</h2>
            <div class="row mt-4">
                <%
                    if (wishlist != null && !wishlist.isEmpty()) {
                        for (Product product : wishlist) {
                            String imageUrl = (product.getImages() != null && !product.getImages().isEmpty())
                                    ? product.getImages().get(0).getImageUrl()
                                    : request.getContextPath() + "/assets/img/no-image.png";

                            // Lấy variantId từ danh sách biến thể (nếu có)
                            Long variantId = null;
                            boolean hasVariant = false;
                            if (product.getVariants() != null && !product.getVariants().isEmpty()) {
                                variantId = product.getVariants().get(0).getVariantId();
                                hasVariant = variantId != null && variantId != 0;
                            }
                %>
                <div class="col-md-4 col-sm-6">
                    <div class="product-card">
                        <div class="product-image">
                            <a href="<%= request.getContextPath()%>/ProductList/detail?productId=<%= product.getProductId()%>">
                                <img src="<%= imageUrl%>" alt="<%= product.getName()%>" class="product-image">
                            </a>
                        </div>
                        <a href="<%= request.getContextPath()%>/ProductList/detail?productId=<%= product.getProductId()%>" class="product-name">
                            <%= product.getName()%>
                        </a>
                        <div class="product-price">
                            <%= String.format("%,.0f", product.getPrice())%> đ
                        </div>
                        <div class="d-flex gap-2 mt-2">
                            <!-- Remove from wishlist -->
                            <form action="wishlist" method="get" onsubmit="return confirm('Remove from wishlist?');">
                                <input type="hidden" name="action" value="remove">
                                <input type="hidden" name="productId" value="<%= product.getProductId()%>">
                                <button type="submit" class="btn btn-outline-danger btn-sm">Remove</button>
                            </form>

                            <!-- Add to cart -->
                            <form action="<%= request.getContextPath()%>/customer/cart" method="post">
                                <input type="hidden" name="action" value="add">
                                <input type="hidden" name="variantId" value="<%= variantId != null ? variantId : 0%>">
                                <input type="hidden" name="quantity" value="1">
                                <button type="submit" class="btn btn-dark btn-sm" <%= hasVariant ? "" : "disabled"%>>Add to Cart</button>
                            </form>
                        </div>
                    </div>
                </div>
                <%
                    }
                } else {
                %>
                <div class="col-12 text-center">
                    <p class="text-muted">You haven't added any products to your wishlist yet.</p>
                </div>
                <%
                    }
                %>
            </div>
        </div>
    </body>
</html>
<jsp:include page="/WEB-INF/views/common/footer.jsp" />
