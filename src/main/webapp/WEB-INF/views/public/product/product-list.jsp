<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="dao.CategoryDAO" %>
<%@ page import="model.Category" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Product" %>
<%@ page import="java.util.Set" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%
    NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
    String categoryName = "All Products";
    String categoryIdStr = request.getParameter("categoryId");
    String parentCategoryIdStr = request.getParameter("parentCategoryId");
    try {
        CategoryDAO cateDAO = new CategoryDAO();
        List<Category> allCategories = cateDAO.getAllCategories();
        if (allCategories != null) {
            if (categoryIdStr != null && !categoryIdStr.trim().isEmpty()) {
                try {
                    Long categoryId = Long.parseLong(categoryIdStr);
                    for (Category cat : allCategories) {
                        if (cat.getCategoryId().equals(categoryId) && cat.isActive()) {
                            categoryName = cat.getName();
                            break;
                        }
                    }
                } catch (NumberFormatException e) {
                    System.err.println("Invalid categoryId in productList.jsp: " + categoryIdStr);
                }
            } else if (parentCategoryIdStr != null && !parentCategoryIdStr.trim().isEmpty()) {
                try {
                    Long parentCategoryId = Long.parseLong(parentCategoryIdStr);
                    for (Category cat : allCategories) {
                        if (cat.getCategoryId().equals(parentCategoryId) && cat.isActive()) {
                            categoryName = cat.getName();
                            break;
                        }
                    }
                } catch (NumberFormatException e) {
                    System.err.println("Invalid parentCategoryId in productList.jsp: " + parentCategoryIdStr);
                }
            }
        } else {
            System.out.println("Warning: allCategories is null in productList.jsp");
        }
        request.setAttribute("categoryName", categoryName);
    } catch (Exception e) {
        System.err.println("Error fetching categories in productList.jsp: " + e.getMessage());
        e.printStackTrace();
        request.setAttribute("categoryError", "Error loading category name: " + e.getMessage());
    }
   Set<?> wishlistProductIds = (Set<?>) request.getAttribute("wishlistProductIds");
%>

<jsp:include page="/WEB-INF/views/common/header.jsp" />
<jsp:include page="/WEB-INF/views/public/product/filter-product.jsp" />

<style>
    .section-title {
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 1px;
        margin-bottom: 40px;
        font-size: 1.8rem;
        text-align: center;
        color: #111;
    }
    .product-card {
        border: 1px solid #eee;
        text-align: center;
        margin-bottom: 1.5rem;
        border-radius: 10px;
        overflow: hidden;
        background: #fff;
        transition: transform 0.2s ease, box-shadow 0.2s ease;
        padding: 10px;
        position: relative;
    }
    .product-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 8px 20px rgba(0,0,0,0.08);
    }
    .product-card .product-image {
        overflow: hidden;
        margin-bottom: 0.8rem;
        position: relative; /* for OOS badge */
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
        font-size: 0.9rem;
        font-weight: 500;
        color: #1e3a8a;
        text-decoration: none;
        display: -webkit-box;
        -webkit-line-clamp: 2;
        -webkit-box-orient: vertical;
        overflow: hidden;
        height: 38px;
        padding: 0 6px;
        margin-bottom: 6px;
    }
    .product-card .product-title:hover {
        color: #000;
    }
    .product-card .product-price {
        font-size: 1rem;
        font-weight: 600;
        color: #111;
        margin-bottom: 10px;
    }
    .product-card .btn-container {
        display: flex;
        justify-content: center;
        gap: 10px; /* giống home.jsp */
        padding-bottom: 10px;
    }
    .product-card .btn {
        padding: 0.5rem 1rem;
        font-size: 0.9rem;
        border-radius: 20px;
        transition: all 0.3s ease;
    }
    .wishlist-icon {
        position: absolute;
        top: 12px;
        right: 12px;
        z-index: 10;
    }
    .wishlist-icon-circle {
        background-color: white;
        border: 1px solid #ddd;
        border-radius: 50%;
        width: 36px;
        height: 36px;
        display: flex;
        align-items: center;
        justify-content: center;
        color: #666;
        font-size: 16px;
        cursor: pointer;
        transition: all 0.3s ease;
        box-shadow: 0 2px 5px rgba(0,0,0,0.1);
    }
    .wishlist-icon-circle:hover,
    .wishlist-icon-circle.active {
        border-color: #ef4444;
        color: #ef4444;
    }
    .error-message {
        color: red;
        font-weight: 500;
        margin-top: 20px;
        text-align: center;
    }
    /* Out of stock badge */
    .oos-badge {
        position:absolute;
        top:10px;
        left:10px;
        background:rgba(17,17,17,.9);
        color:#fff;
        padding:4px 8px;
        border-radius:6px;
        font-size:.75rem;
    }
</style>

<div class="container my-5 py-5">
    <div class="text-center">
        <h2 class="section-title"><%= categoryName %></h2>
    </div>

    <% if (request.getAttribute("categoryError") != null) { %>
    <div class="alert alert-danger text-center"><%= request.getAttribute("categoryError") %></div>
    <% } %>

    <div class="row">
        <%
            List<Product> products = (List<Product>) request.getAttribute("products");
            if (products != null && !products.isEmpty()) {
                for (Product product : products) {
                    String imageUrl = product.getImageUrl() != null ? product.getImageUrl() : "https://placehold.co/400x500/f0f0f0/333?text=No+Image";
                    String name = product.getName() != null ? product.getName() : "Unknown Product";
                    String price = product.getPrice() != null ? currencyFormat.format(product.getPrice()) : "N/A";
                    boolean hasStock = product.getQuantity() > 0;
        %>
        <div class="col-lg-3 col-md-6 col-sm-6 col-12">
            <div class="product-card">
                <!-- Wishlist -->
<!-- Wishlist -->
<div class="wishlist-icon">
  <%
    boolean wished = false;
    try {
      if (wishlistProductIds != null && product.getProductId() != null) {
        // Hỗ trợ cả Set<Long> lẫn Set<Integer>
        wished = wishlistProductIds.contains(product.getProductId())
              || wishlistProductIds.contains(product.getProductId().intValue());
      }
    } catch (Exception ignore) {}
  %>

  <form class="js-wishlist-form"
        action="<%= request.getContextPath() %>/wishlist"
        method="post">
    <input type="hidden" name="action" value="toggle">
    <input type="hidden" name="productId" value="<%= product.getProductId() %>">
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

                <!-- Image + OOS badge -->
                <div class="product-image">
                    <a href="<%= request.getContextPath()%>/ProductDetail?productId=<%= product.getProductId()%>">
                        <img src="<%= imageUrl%>" alt="<%= name%>">
                    </a>
                </div>

                <!-- Title & price -->
                <a href="<%= request.getContextPath()%>/ProductDetail?productId=<%= product.getProductId()%>" class="product-title"><%= name%></a>
                <p class="product-price"><%= price%></p>

                <!-- Buttons: style đồng bộ với home.jsp -->
                <div class="btn-container">
                    <% if (hasStock) { %>
                    <a href="<%= request.getContextPath()%>/ProductDetail?productId=<%= product.getProductId()%>"
                       class="btn btn-primary">
                        View details
                    </a>
                    <% } else { %>
                    <button class="btn btn-secondary disabled">
                        Out of stock
                    </button>
                    <% } %>
                </div>
            </div>
        </div>
        <%
                }
            } else {
        %>
        <div class="col-12 text-center">
            <p class="error-message">No products in this category.</p>
        </div>
        <%
            }
        %>
    </div>
</div>
<!-- Modal: Added to Wishlist -->
<!-- Wishlist Modal (đồng bộ với home) -->
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
  function showWishlistModal({ added, productName, autoCloseMs = 1500 }) {
    const modalEl  = document.getElementById('wishlistModal');
    const titleEl  = document.getElementById('wishlistModalLabel');
    const mainEl   = document.getElementById('wishlistModalMain');
    const subEl    = document.getElementById('wishlistModalSub');
    const iconWrap = document.getElementById('wishlistModalIcon');

    if (!modalEl || !window.bootstrap || !bootstrap.Modal) {
      alert((added ? 'Added to wishlist: ' : 'Removed from wishlist: ') + (productName || ''));
      return;
    }
    titleEl.textContent = 'Wishlist';
    mainEl.textContent  = added ? 'Added to your wishlist' : 'Removed from your wishlist';
    subEl.textContent   = productName || '';
    iconWrap.classList.remove('text-success','text-secondary');
    iconWrap.classList.add(added ? 'text-success' : 'text-secondary');
    iconWrap.innerHTML  = added ? '<i class="fa-solid fa-heart"></i>' : '<i class="fa-regular fa-heart"></i>';

    const modal = bootstrap.Modal.getOrCreateInstance(modalEl, { backdrop: 'static', keyboard: true });
    modal.show();

    if (autoCloseMs) {
      clearTimeout(modalEl._autoCloseTimer);
      modalEl._autoCloseTimer = setTimeout(() => modal.hide(), autoCloseMs);
    }
  }

  document.querySelectorAll('form.js-wishlist-form').forEach(form => {
    form.addEventListener('submit', async (e) => {
      e.preventDefault();
      const btn = form.querySelector('.wishlist-icon-circle');
      if (!btn || btn.dataset.loading === '1') return;

      const url = form.getAttribute('action');
      const fd  = new FormData(form);

      const isWishedNow = btn.classList.contains('active');
      if ((fd.get('action')||'').toLowerCase() === 'toggle') {
        fd.set('action', isWishedNow ? 'remove' : 'add');
      }
      let nextWished = fd.get('action') === 'add';
      const productName = btn.closest('.product-card')?.querySelector('.product-title')?.textContent?.trim() || '';

      const body = new URLSearchParams();
      fd.forEach((v,k)=>body.append(k,v));

      try {
        btn.dataset.loading = '1';
        btn.disabled = true;

        const res = await fetch(url, {
          method: 'POST',
          headers: { 'Accept':'application/json', 'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8' },
          body: body.toString(),
          credentials: 'same-origin',
          cache: 'no-store'
        });

        if (res.redirected && res.url.includes('/Login')) { window.location.href = res.url; return; }

        if (res.headers.get('content-type')?.includes('application/json')) {
          const data = await res.json();
          if (typeof data.wished === 'boolean') nextWished = data.wished;
          if (typeof data.count === 'number' && typeof window.updateWishlistCount === 'function') {
            window.updateWishlistCount(data.count);
          }
          if (data.ok === false) throw new Error('server');
        } else {
          await res.text(); // swallow
        }

        btn.classList.toggle('active', nextWished);
        btn.setAttribute('aria-pressed', String(nextWished));
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
