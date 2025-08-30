<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="model.Product" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="dao.CategoryDAO" %>
<%@ page import="model.Category" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%
    String pageTitle = (String) request.getAttribute("pageTitle");
    if (pageTitle == null) {
        pageTitle = "Welcome to ClothingStore";
    }
    List<Product> newProducts = (List<Product>) request.getAttribute("newProducts");
    List<Product> bestSellers = (List<Product>) request.getAttribute("bestSellers");
    Map<Long, Integer> availableMap = (Map<Long, Integer>) request.getAttribute("availableMap");

    // Cho phép chứa cả Set<Integer> hoặc Set<Long> để tránh mismatch kiểu
    Set<?> wishlistProductIds = (Set<?>) request.getAttribute("wishlistProductIds");

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
            categoryError = "No categories available. Please contact the administrator.";
            parentCategories = new ArrayList<>();
        } else {
            List<Category> parentCats = parentCategories;
            if (!parentCats.isEmpty()) {
                menCategoryId = parentCats.get(0).getCategoryId();
                showMenCategory = true;
                if (parentCats.size() > 1) {
                    womenCategoryId = parentCats.get(1).getCategoryId();
                    showWomenCategory = true;
                } else {
                    categoryError = "Only one category available.";
                }
            } else {
                categoryError = "No categories available. Please contact the administrator.";
            }
        }
    } catch (Exception e) {
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
        background: linear-gradient(rgba(0, 0, 0, 0.5), rgba(0, 0, 0, 0.5)),
            url('https://images.unsplash.com/photo-1511556820780-d912e42b4980?q=80&w=2070&auto=format&fit=crop');
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
        box-shadow: 0 4px 15px rgba(0,0,0,0.2);
    }

    .category-section {
        padding: 4rem 0;
        background-color: #fff;
    }
    .category-card {
        position: relative;
        overflow: hidden;
        border-radius: 10px;
        box-shadow: 0 4px 10px rgba(0,0,0,0.1);
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
        text-shadow: 1px 1px 5px rgba(0,0,0,0.7);
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
        box-shadow: 0 4px 10px rgba(0,0,0,0.1);
        transition: transform 0.3s ease, box-shadow 0.3s ease;
        position: relative;
    }
    .product-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 8px 20px rgba(0,0,0,0.15);
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

<!-- Categories -->
<div class="category-section">
    <div class="container">
        <h2 class="section-title">Shop by Category</h2>
        <div class="row g-4">
            <% if (showMenCategory) { %>
            <div class="col-md-6">
                <div class="category-card">
                    <img src="https://images.unsplash.com/photo-1532453288672-3a27e9be9efd?q=80&w=2070&auto=format&fit=crop" alt="Men's Collection" loading="lazy" decoding="async">
                    <div class="content">
                        <h3>Men's Collection</h3>
                        <a href="<%= request.getContextPath()%>/ProductList?parentCategoryId=<%= menCategoryId%>" class="btn btn-outline-light">Explore Men</a>
                    </div>
                </div>
            </div>
            <% } %>
            <% if (showWomenCategory) { %>
            <div class="col-md-6">
                <div class="category-card">
                    <img src="https://images.unsplash.com/photo-1529139574466-a303027c1d8b?q=80&w=2070&auto=format&fit=crop" alt="Women's Collection" loading="lazy" decoding="async">
                    <div class="content">
                        <h3>Women's Collection</h3>
                        <a href="<%= request.getContextPath()%>/ProductList?parentCategoryId=<%= womenCategoryId%>" class="btn btn-outline-light">Explore Women</a>
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

<!-- New Arrivals -->
<div class="product-section">
    <div class="container">
        <h2 class="section-title">New Arrivals</h2>
        <div class="row g-4">
            <% if (newProducts != null && !newProducts.isEmpty()) {
                for (Product product : newProducts) {
                    String imageUrl = product.getImageUrl() != null ? product.getImageUrl() : "https://placehold.co/400x500/eee/333?text=No+Image";
                    String name = product.getName() != null ? product.getName() : "Unknown Product";
                    String price = product.getPrice() != null ? currencyFormat.format(product.getPrice()) : "N/A";

                    int available = 0;
                    Long pid = product.getProductId();
                    if (pid != null && availableMap != null) {
                        Integer v = availableMap.get(pid);
                        available = (v == null) ? 0 : v;
                    } else {
                        try { available = product.getQuantity(); } catch (Exception ex) { available = 0; }
                    }

                    boolean wished = false;
                    try {
                        if (wishlistProductIds != null && product.getProductId() != null) {
                            // khớp cả Long lẫn Integer trong set
                            Integer pidInt = product.getProductId().intValue();
                            wished = wishlistProductIds.contains(product.getProductId()) || wishlistProductIds.contains(pidInt);
                        }
                    } catch (Exception ignore) {}
            %>
            <div class="col-lg-3 col-md-6 col-sm-6 col-12">
                <div class="product-card">
                    <div class="wishlist-icon">
                        <form class="js-wishlist-form" action="<%= request.getContextPath()%>/wishlist" method="post">
                            <input type="hidden" name="action" value="toggle">
                            <input type="hidden" name="productId" value="<%= product.getProductId()%>">
                            <c:if test="${not empty sessionScope.csrfToken}">
                                <input type="hidden" name="csrf" value="${sessionScope.csrfToken}">
                            </c:if>
                            <button type="submit"
                                    class="wishlist-icon-circle <%= wished ? "active" : "" %>"
                                    aria-pressed="<%= wished %>">
                                <i class="fas fa-heart"></i>
                            </button>
                        </form>
                    </div>
                    <img src="<%= imageUrl%>" alt="<%= name%>" loading="lazy" decoding="async">
                    <div class="card-body">
                        <a href="<%= request.getContextPath()%>/ProductDetail?productId=<%= product.getProductId()%>" class="product-title"><%= name%></a>
                        <p class="product-price"><%= price%></p>
                        <div class="btn-container">
                            <a class="btn <%= (available > 0 ? "btn-primary" : "btn-secondary disabled") %>"
                               href="<%= request.getContextPath()%>/ProductDetail?productId=<%= product.getProductId()%>">
                                <%= (available > 0 ? "View details" : "Out of stock") %>
                            </a>
                        </div>
                    </div>
                </div>
            </div>
            <% }
            } else { %>
            <div class="col-12">
                <p class="error-message">No new products available.</p>
            </div>
            <% } %>
        </div>
    </div>
</div>

<!-- Promo -->
<div class="promo-section">
    <div class="container">
        <h2>Exclusive Offers Await</h2>
        <p>Discover unbeatable deals on our curated collections. Shop now to save big!</p>
        <a href="${pageContext.request.contextPath}/ProductList?sale=true" class="btn btn-light">Explore Deals</a>
    </div>
</div>

<!-- Best Sellers -->
<div class="product-section">
    <div class="container">
        <h2 class="section-title">Best Sellers</h2>
        <div class="row g-4">
            <% if (bestSellers != null && !bestSellers.isEmpty()) {
                for (Product product : bestSellers) {
                    String imageUrl = product.getImageUrl() != null ? product.getImageUrl() : "https://placehold.co/400x500/eee/333?text=No+Image";
                    String name = product.getName() != null ? product.getName() : "Unknown Product";
                    String price = product.getPrice() != null ? currencyFormat.format(product.getPrice()) : "N/A";

                    int available = 0;
                    try { available = product.getQuantity(); } catch (Exception ex) { available = 0; }

                    boolean wished = false;
                    try {
                        if (wishlistProductIds != null && product.getProductId() != null) {
                            Integer pidInt = product.getProductId().intValue();
                            wished = wishlistProductIds.contains(product.getProductId()) || wishlistProductIds.contains(pidInt);
                        }
                    } catch (Exception ignore) {}
            %>
            <div class="col-lg-3 col-md-6 col-sm-6 col-12">
                <div class="product-card">
                    <div class="wishlist-icon">
                        <form class="js-wishlist-form" action="<%= request.getContextPath()%>/wishlist" method="post">
                            <input type="hidden" name="action" value="toggle">
                            <input type="hidden" name="productId" value="<%= product.getProductId()%>">
                            <c:if test="${not empty sessionScope.csrfToken}">
                                <input type="hidden" name="csrf" value="${sessionScope.csrfToken}">
                            </c:if>
                            <button type="submit"
                                    class="wishlist-icon-circle <%= wished ? "active" : "" %>"
                                    aria-pressed="<%= wished %>">
                                <i class="fas fa-heart"></i>
                            </button>
                        </form>
                    </div>
                    <img src="<%= imageUrl%>" alt="<%= name%>" loading="lazy" decoding="async">
                    <div class="card-body">
                        <a href="<%= request.getContextPath()%>/ProductDetail?productId=<%= product.getProductId()%>" class="product-title"><%= name%></a>
                        <p class="product-price"><%= price%></p>
                        <div class="btn-container">
                            <a class="btn <%= (available > 0 ? "btn-primary" : "btn-secondary disabled") %>"
                               href="<%= request.getContextPath()%>/ProductDetail?productId=<%= product.getProductId()%>">
                                <%= (available > 0 ? "View details" : "Out of stock") %>
                            </a>
                        </div>
                    </div>
                </div>
            </div>
            <% }
            } else { %>
            <div class="col-12">
                <p class="error-message">No best sellers available.</p>
            </div>
            <% } %>
        </div>
    </div>
</div>
<!-- Wishlist Modal -->
<div class="modal fade" id="wishlistModal" tabindex="-1" aria-labelledby="wishlistModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content border-0 shadow">
      <div class="modal-header">
        <h5 class="modal-title" id="wishlistModalLabel">Wishlist</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <div class="d-flex align-items-center gap-3">
          <span id="wishlistModalIcon" class="fs-3 text-success"><i class="fa-solid fa-heart"></i></span>
          <div>
            <div id="wishlistModalMain" class="fw-semibold">Added to your wishlist</div>
            <div id="wishlistModalSub" class="text-muted small">Product name here</div>
          </div>
        </div>
      </div>
      <div class="modal-footer">
        <a href="${pageContext.request.contextPath}/wishlist?action=view" class="btn btn-primary">View wishlist</a>
        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Continue shopping</button>
      </div>
    </div>
  </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />


<script>
document.addEventListener('DOMContentLoaded', () => {
  if (typeof window.updateCartCount === 'function') window.updateCartCount();

  // Helper: hiển thị modal
  function showWishlistModal({ added, productName, autoCloseMs = 5000 }) {
    const modalEl   = document.getElementById('wishlistModal');
    const titleEl   = document.getElementById('wishlistModalLabel');
    const mainEl    = document.getElementById('wishlistModalMain');
    const subEl     = document.getElementById('wishlistModalSub');
    const iconWrap  = document.getElementById('wishlistModalIcon');

    if (!modalEl || !window.bootstrap || !bootstrap.Modal) {
      // fallback an toàn nếu chưa có bootstrap.js
      alert((added ? 'Added to wishlist: ' : 'Removed from wishlist: ') + (productName || ''));
      return;
    }

    // Nội dung
    titleEl.textContent = 'Wishlist';
    mainEl.textContent  = added ? 'Added to your wishlist' : 'Removed from your wishlist';
    subEl.textContent   = productName || '';

    // Icon/màu
    iconWrap.classList.remove('text-success','text-secondary');
    iconWrap.classList.add(added ? 'text-success' : 'text-secondary');
    iconWrap.innerHTML = added ? '<i class="fa-solid fa-heart"></i>' : '<i class="fa-regular fa-heart"></i>';

    const modal = bootstrap.Modal.getOrCreateInstance(modalEl, { backdrop: 'static', keyboard: true });
    modal.show();

    // Tự đóng sau 1.5s (có thể đổi thời gian hoặc bỏ nếu muốn người dùng tự đóng)
    if (autoCloseMs && autoCloseMs > 0) {
      clearTimeout(modalEl._autoCloseTimer);
      modalEl._autoCloseTimer = setTimeout(() => modal.hide(), autoCloseMs);
    }
  }

  document.querySelectorAll('form.js-wishlist-form').forEach(form => {
    form.addEventListener('submit', async (e) => {
      e.preventDefault();

      const btn = form.querySelector('button.wishlist-icon-circle');
      if (!btn || btn.dataset.loading === '1') return;

      const url = form.getAttribute('action'); // KHÔNG dùng form.action vì trùng name="action"
      const fd  = new FormData(form);

      // Nếu form đặt action="toggle" → map sang add/remove theo trạng thái hiện tại
      const isToggle    = (fd.get('action') || '').toLowerCase() === 'toggle';
      const isWishedNow = btn.classList.contains('active');
      if (isToggle) {
        fd.set('action', isWishedNow ? 'remove' : 'add');
      }
      let nextWished = isToggle ? !isWishedNow : (fd.get('action') === 'add');

      // Lấy tên sản phẩm để hiển thị modal
      const productName =
        btn.closest('.product-card')?.querySelector('.product-title')?.textContent?.trim() || '';

      // Gửi dạng URL-encoded để Servlet đọc getParameter()
      const body = new URLSearchParams();
      fd.forEach((v, k) => body.append(k, v));

      try {
        btn.dataset.loading = '1';
        btn.disabled = true;

        const res = await fetch(url, {
          method: 'POST',
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
          },
          body: body.toString(),
          credentials: 'same-origin',
          cache: 'no-store'
        });

        // Nếu bị chuyển hướng tới login
        if (res.redirected && res.url.includes('/Login')) {
          window.location.href = res.url;
          return;
        }

        let ok = res.ok, count = null;
        const ct = res.headers.get('content-type') || '';
        if (ct.includes('application/json')) {
          const data = await res.json();
          ok = !!data.ok;
          if ('wished' in data) nextWished = !!data.wished; // ưu tiên trạng thái từ server
          if ('count'  in data) count = data.count;
        } else {
          // Server trả HTML (error/redirect) → đọc text để tránh lỗi parse
          await res.text();
        }

        if (!ok) throw new Error('server');

        // Cập nhật UI trái tim
        btn.classList.toggle('active', nextWished);
        btn.setAttribute('aria-pressed', String(nextWished));

        // Badge wishlist (nếu có)
        if (typeof window.updateWishlistCount === 'function' && count != null) {
          window.updateWishlistCount(count);
        } else {
          const badge = document.querySelector('[data-role="wishlist-count"]');
          if (badge && count != null) badge.textContent = count;
        }

        // ✅ Hiển thị modal thông báo
        showWishlistModal({ added: nextWished, productName });

      } catch (err) {
        console.error(err);
        alert('Network error. Please try again.');
      } finally {
        btn.disabled = false;
        delete btn.dataset.loading;
      }
    });
  });
});
</script>



