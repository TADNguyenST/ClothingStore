<%@ page import="java.util.ArrayList"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
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
    Map<Long, Integer> availableMap = (Map<Long, Integer>) request.getAttribute("availableMap");
    NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
    Integer totalPages = (Integer) request.getAttribute("totalPages");
    if (totalPages == null || totalPages <= 0) {
        totalPages = 1;
    }
    Integer currentPage = (Integer) request.getAttribute("currentPage");
    if (currentPage == null || currentPage <= 0) {
        currentPage = 1;
    }
    String sort = request.getParameter("sort");
    if (sort == null || sort.trim().isEmpty()) {
        sort = "default";
    }
    if (products == null) {
        products = new ArrayList<>();
    }
    request.setAttribute("pageTitle", pageTitle);
    request.setAttribute("sort", sort);
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
        aspect-ratio: 1 / 2.2;
        object-fit: cover;
        max-height: 320px;
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
    .error-message {
        color: red;
        font-weight: 500;
        margin-bottom: 20px;
    }
    .filter-panel-container {
        position: sticky;
        top: 20px;
        background: #f8f9fa;
        padding: 15px;
        border-radius: 5px;
    }
    .pagination {
        display: flex;
        justify-content: center;
        align-items: center;
        gap: 10px;
        font-size: 1rem;
    }
    .pagination button {
        padding: 0.5rem 1rem;
        font-size: 0.9rem;
        border: none;
        background: #007bff;
        color: white;
        border-radius: 5px;
        cursor: pointer;
    }
    .pagination button:disabled {
        background: #ccc;
        cursor: not-allowed;
    }
    .sort-panel select {
        padding: 0.5rem;
        font-size: 0.9rem;
        border-radius: 5px;
        border: 1px solid #ccc;
        width: 100%;
        max-width: 200px;
    }
    @media (max-width: 1200px) {
        .col-lg-4 {
            flex: 0 0 33.333333%;
            max-width: 33.333333%;
        }
    }
    @media (max-width: 992px) {
        .col-lg-3, .col-lg-9 {
            flex: 0 0 100%;
            max-width: 100%;
        }
        .filter-panel-container {
            position: static;
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

<div class="container my-3 ">
    <div class="text-center">
        <h2 class="section-title"><%= pageTitle %></h2>
        <% if (error != null && !error.isEmpty()) { %>
        <p class="error-message"><%= error %></p>
        <% } %>
    </div>

    <div class="row">
        <div class="col-lg-3 col-md-4">
            <div class="filter-panel-container">
                <jsp:include page="/WEB-INF/views/public/product/filter-product.jsp" />
            </div>
        </div>
        <div class="col-lg-9 col-md-8">
            <div class="sort-panel mb-3">
                <label for="sort">Sort by:</label>
                <select id="sort" name="sort" onchange="submitFilter()">
                    <option value="default" <%= "default".equals(sort) ? "selected" : "" %>>Default</option>
                    <option value="created_at_desc" <%= "created_at_desc".equals(sort) ? "selected" : "" %>>Newest Arrivals</option>
                    <option value="name_asc" <%= "name_asc".equals(sort) ? "selected" : "" %>>Name (A-Z)</option>
                    <option value="name_desc" <%= "name_desc".equals(sort) ? "selected" : "" %>>Name (Z-A)</option>
                    <option value="price_asc" <%= "price_asc".equals(sort) ? "selected" : "" %>>Price (Low to High)</option>
                    <option value="price_desc" <%= "price_desc".equals(sort) ? "selected" : "" %>>Price (High to Low)</option>
                </select>
            </div>
            <div class="row" id="productList" data-total-pages="<%= totalPages %>">
                <% if (products != null && !products.isEmpty()) {
                    for (Product product : products) {
                        String imageUrl = product.getImageUrl() != null ? product.getImageUrl() : "https://placehold.co/400x500/f0f0f0/333?text=No+Image";
                        String name = product.getName() != null ? product.getName() : "Unknown Product";
                        String price = product.getPrice() != null ? currencyFormat.format(product.getPrice()) : "N/A";
                        Long variantId = product.getDefaultVariantId();
                        boolean hasVariant = variantId != null && variantId != 0;
                        int available = availableMap.getOrDefault(product.getProductId(), 0);
                        boolean hasStock = hasVariant && (available > 0);
                        String buttonTextCart = hasStock ? "Add to Cart" : "Out Stock";
                        String buttonTextBuy = hasStock ? "Buy Now" : "Out Stock";
                %>
                <div class="col-lg-4 col-md-6 col-sm-6 col-12">
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
                                <button type="submit" class="btn btn-dark btn-custom-sm" <%= hasStock ? "" : "disabled" %>><%= buttonTextCart %></button>
                            </form>
                            <form action="<%= request.getContextPath() %>/customer/checkout" method="post">
                                <input type="hidden" name="action" value="buy">
                                <input type="hidden" name="variantId" value="<%= hasVariant ? variantId : 0 %>">
                                <input type="hidden" name="quantity" value="1">
                                <button type="submit" class="btn btn-primary btn-custom-sm" <%= hasStock ? "" : "disabled" %>><%= buttonTextBuy %></button>
                            </form>
                        </div>
                    </div>
                </div>
                <% }
                } else { %>
                <div class="col-12 text-center">
                    <p>No products found.</p>
                </div>
                <% } %>
            </div>
            <div class="pagination d-flex justify-content-center mt-4">
                <button id="prevPage" class="btn btn-outline-secondary mx-2" onclick="changePage(-1)" <%= currentPage == 1 ? "disabled" : "" %>>Previous</button>
                <span id="pageNumber">Page <%= currentPage %></span>
                <span id="totalPages"> of <%= totalPages %></span>
                <button id="nextPage" class="btn btn-outline-secondary mx-2" onclick="changePage(1)" <%= currentPage >= totalPages ? "disabled" : "" %>>Next</button>
            </div>
        </div>
    </div>
</div>

<script>
let currentPage = <%= currentPage %>;
const pageSize = 6; // Updated to 6 products per page as requested
let totalPages = <%= totalPages %>;
let currentSort = '<%= sort %>';

function changePage(delta) {
    currentPage += delta;
    if (currentPage < 1) currentPage = 1;
    if (currentPage > totalPages) currentPage = totalPages;
    updatePagination();
    submitFilter();
}

function updatePagination() {
    document.getElementById('pageNumber').textContent = 'Page ' + currentPage;
    document.getElementById('prevPage').disabled = currentPage === 1;
    document.getElementById('nextPage').disabled = currentPage === totalPages;
}

function submitFilter() {
    const productList = document.getElementById('productList');
    productList.innerHTML = '<div class="text-center"><p>Loading...</p></div>';

    const colors = [];
    const sizes = [];
    const brands = [];
    const priceRange = document.querySelector('input[name="priceRange"]')?.value || null;
    const parentCategoryId = document.querySelector('input[name="parentCategoryId"]')?.value || null;
    const categoryId = document.querySelector('input[name="categoryId"]')?.value || null;
    const sort = document.querySelector('#sort')?.value || 'default';
    currentSort = sort;

    document.querySelectorAll('input[name="colors"]:checked').forEach(cb => colors.push(cb.value));
    document.querySelectorAll('input[name="sizes"]:checked').forEach(cb => sizes.push(cb.value));
    document.querySelectorAll('input[name="brands"]:checked').forEach(cb => brands.push(cb.value));

    const params = new URLSearchParams();
    colors.forEach(color => params.append('colors', color));
    sizes.forEach(size => params.append('sizes', size));
    brands.forEach(brand => params.append('brands', brand));
    if (priceRange && priceRange !== '0') params.append('priceRange', priceRange);
    if (parentCategoryId) params.append('parentCategoryId', parentCategoryId);
    if (categoryId) params.append('categoryId', categoryId);
    if (currentPage !== 1) params.append('page', currentPage);
    if (sort !== 'default') params.append('sort', sort);

    const actionPath = window.location.pathname.split('/').pop() || '';
    const url = '${pageContext.request.contextPath}/ProductList' + (actionPath ? '/' + actionPath : '') + (params.toString() ? '?' + params.toString() : '');
    console.log('submitFilter - Request URL:', url);

    fetch(url, {
        method: 'GET',
        headers: {
            'Accept': 'text/html',
            'X-Requested-With': 'XMLHttpRequest'
        }
    })
        .then(response => {
            if (!response.ok) throw new Error('Network response was not ok: ' + response.statusText);
            return response.text();
        })
        .then(data => {
            const parser = new DOMParser();
            const doc = parser.parseFromString(data, 'text/html');
            const row = doc.querySelector('.row');
            if (row) {
                productList.innerHTML = row.outerHTML;
                totalPages = parseInt(row.getAttribute('data-total-pages')) || 1;
                document.getElementById('totalPages').textContent = ' of ' + totalPages;
                updatePagination();
                const newUrl = window.location.pathname + (params.toString() ? '?' + params.toString() : '');
                window.history.replaceState({}, '', newUrl);
                console.log('submitFilter - Updated URL:', newUrl);
            } else {
                productList.innerHTML = '<div class="text-center"><p>No products found.</p></div>';
            }
        })
        .catch(error => {
            console.error('submitFilter - Error:', error);
            productList.innerHTML = '<div class="text-center"><p>An error occurred while fetching products. Please try again.</p></div>';
        });
}

window.onload = function() {
    const urlParams = new URLSearchParams(window.location.search);
    currentPage = parseInt(urlParams.get('page')) || 1;
    currentSort = urlParams.get('sort') || 'default';

    const sortSelect = document.querySelector('#sort');
    if (sortSelect) {
        sortSelect.value = currentSort;
    }

    document.getElementById('pageNumber').textContent = 'Page ' + currentPage;
    document.getElementById('prevPage').disabled = currentPage === 1;
    document.getElementById('nextPage').disabled = currentPage >= totalPages;

    urlParams.getAll('colors').forEach(color => {
        const checkbox = document.querySelector(`input[name="colors"][value="${color}"]`);
        if (checkbox) checkbox.checked = true;
    });
    urlParams.getAll('sizes').forEach(size => {
        const checkbox = document.querySelector(`input[name="sizes"][value="${size}"]`);
        if (checkbox) checkbox.checked = true;
    });
    urlParams.getAll('brands').forEach(brand => {
        const checkbox = document.querySelector(`input[name="brands"][value="${brand}"]`);
        if (checkbox) checkbox.checked = true;
    });
    const priceRange = urlParams.get('priceRange');
    if (priceRange) {
        const rangeInput = document.querySelector('input[name="priceRange"]');
        if (rangeInput) {
            rangeInput.value = priceRange;
            rangeInput.nextElementSibling.value = priceRange + ' VND';
        }
    }

    const hasFilters = urlParams.getAll('colors').length > 0 ||
                      urlParams.getAll('sizes').length > 0 ||
                      urlParams.getAll('brands').length > 0 ||
                      (urlParams.get('priceRange') && urlParams.get('priceRange') !== '0') ||
                      urlParams.get('parentCategoryId') ||
                      urlParams.get('categoryId') ||
                      currentPage !== 1 ||
                      currentSort !== 'default';
    if (hasFilters) {
        submitFilter();
    }
};

window.addEventListener('popstate', function(event) {
    const urlParams = new URLSearchParams(window.location.search);
    currentPage = parseInt(urlParams.get('page')) || 1;
    currentSort = urlParams.get('sort') || 'default';

    const sortSelect = document.querySelector('#sort');
    if (sortSelect) {
        sortSelect.value = currentSort;
    }

    document.querySelectorAll('input[name="colors"]').forEach(cb => cb.checked = false);
    document.querySelectorAll('input[name="sizes"]').forEach(cb => cb.checked = false);
    document.querySelectorAll('input[name="brands"]').forEach(cb => cb.checked = false);
    urlParams.getAll('colors').forEach(color => {
        const checkbox = document.querySelector(`input[name="colors"][value="${color}"]`);
        if (checkbox) checkbox.checked = true;
    });
    urlParams.getAll('sizes').forEach(size => {
        const checkbox = document.querySelector(`input[name="sizes"][value="${size}"]`);
        if (checkbox) checkbox.checked = true;
    });
    urlParams.getAll('brands').forEach(brand => {
        const checkbox = document.querySelector(`input[name="brands"][value="${brand}"]`);
        if (checkbox) checkbox.checked = true;
    });
    const priceRange = urlParams.get('priceRange');
    if (priceRange) {
        const rangeInput = document.querySelector('input[name="priceRange"]');
        if (rangeInput) {
            rangeInput.value = priceRange;
            rangeInput.nextElementSibling.value = priceRange + ' VND';
        }
    }

    submitFilter();
});
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />