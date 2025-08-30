<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Product" %>

<jsp:include page="/WEB-INF/views/common/header.jsp" />

<%
    List<Product> wishlist = (List<Product>) request.getAttribute("wishlistProducts");

    String ctx = request.getContextPath();
    java.util.function.Function<String, String> norm = (raw) -> {
        if (raw == null || raw.trim().isEmpty()) return ctx + "/assets/img/no-image.png";
        String r = raw.trim();
        if (r.startsWith("http://") || r.startsWith("https://") || r.startsWith("data:")) return r;
        if (r.startsWith("/")) return ctx + r;
        return ctx + "/" + r;
    };
%>

<style>
  body { background-color: #f8f9fa; }
  .wishlist-header { text-align: center; margin-top: 30px; font-weight: 700; }

  .product-card{
    border:1px solid #ddd;border-radius:10px;background:#fff;padding:16px;
    box-shadow:0 4px 10px rgba(0,0,0,.06);transition:transform .2s, box-shadow .2s;
    height:100%;display:flex;flex-direction:column;
  }
  .product-card:hover{ transform:translateY(-4px); box-shadow:0 8px 20px rgba(0,0,0,.12); }

  .product-thumb{ height:280px; overflow:hidden; border-radius:8px; background:#f3f4f6; }
  .product-thumb img{ width:100%; height:100%; object-fit:cover; transition:transform .4s ease; display:block; }
  .product-card:hover .product-thumb img{ transform:scale(1.03); }

  .product-meta{ min-height:110px; display:flex; flex-direction:column; justify-content:flex-start; margin-top:12px; }
  .product-name{
    font-weight:600; min-height:48px; text-decoration:none; color:#111827;
    display:-webkit-box; -webkit-line-clamp:2; -webkit-box-orient:vertical; overflow:hidden;
  }
  .product-price{ color:#111; font-size:16px; font-weight:700; margin:8px 0 0; }

  .actions{ margin-top:auto; }
  .actions .btn + .btn{ margin-left:8px; }

  @media (max-width: 992px){
    .product-thumb{ height:220px; }
    .product-meta{ min-height:100px; }
  }
  @media (max-width: 576px){
    .product-thumb{ height:180px; }
    .product-meta{ min-height:90px; }
  }
</style>

<div class="container mt-5">
  <h2 class="wishlist-header">Wishlist</h2>

  <div class="row row-cols-1 row-cols-sm-2 row-cols-md-2 row-cols-lg-4 g-4 mt-2">
    <%
      if (wishlist != null && !wishlist.isEmpty()) {
        for (Product product : wishlist) {
          String raw = null;
          try {
            if (product.getImageUrl() != null && !product.getImageUrl().trim().isEmpty()) {
              raw = product.getImageUrl();
            } else if (product.getImages() != null && !product.getImages().isEmpty()
                       && product.getImages().get(0).getImageUrl() != null) {
              raw = product.getImages().get(0).getImageUrl();
            }
          } catch (Exception ignore) {}

          String imageUrl = norm.apply(raw);
          String detailUrl = ctx + "/ProductDetail?productId=" + product.getProductId();
    %>
      <div class="col">
        <div class="product-card">
          <div class="product-thumb">
            <a href="<%= detailUrl %>">
              <img src="<%= imageUrl %>"
                   alt="<%= product.getName() %>"
                   loading="lazy" decoding="async"
                   onerror="this.onerror=null;this.src='<%= ctx %>/assets/img/no-image.png';">
            </a>
          </div>

          <div class="product-meta">
            <a href="<%= detailUrl %>" class="product-name"><%= product.getName() %></a>
            <div class="product-price"><%= String.format("%,.0f", product.getPrice()) %> đ</div>
          </div>

          <div class="actions">
            <!-- ✅ chỉ thêm class & data để hiện modal xác nhận, KHÔNG đổi hành vi -->
            <form action="<%= ctx %>/wishlist" method="get"
                  class="d-inline js-remove"
                  data-pname="<%= product.getName() %>">
              <input type="hidden" name="action" value="remove">
              <input type="hidden" name="productId" value="<%= product.getProductId() %>">
              <button type="submit" class="btn btn-outline-danger btn-sm">Remove</button>
            </form>
            <a href="<%= detailUrl %>" class="btn btn-dark btn-sm">Choose Options</a>
          </div>
        </div>
      </div>
    <%
        } // end for
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

<!-- ✅ Modal xác nhận (Bootstrap 5) -->
<div class="modal fade" id="confirmRemoveModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content border-0 shadow">
      <div class="modal-header">
        <h5 class="modal-title">Remove from wishlist?</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <p id="confirmText" class="mb-0">Are you sure you want to remove this item?</p>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
        <button type="button" class="btn btn-danger" id="confirmRemoveBtn">Remove</button>
      </div>
    </div>
  </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

<script>
document.addEventListener('DOMContentLoaded', () => {
  // Nếu header.jsp đã nhúng bootstrap.bundle, đoạn này sẽ chạy modal mượt
  const el = document.getElementById('confirmRemoveModal');
  const txt = document.getElementById('confirmText');
  const ok  = document.getElementById('confirmRemoveBtn');

  // Fallback nếu thiếu Bootstrap → dùng confirm()
  const hasBs = !!(window.bootstrap && bootstrap.Modal);
  const modal = hasBs ? new bootstrap.Modal(el) : null;

  let pendingForm = null;

  document.querySelectorAll('form.js-remove').forEach(form => {
    form.addEventListener('submit', (e) => {
      if (!hasBs) {
        // không có Bootstrap → confirm cổ điển, vẫn giữ hành vi cũ
        if (!confirm('Remove this item from your wishlist?')) e.preventDefault();
        return;
      }
      e.preventDefault(); // chặn submit, mở modal
      pendingForm = form;
      const name = form.dataset.pname || 'this item';
      const a ='Remove ';
      const b = ' from your wishlist?';
      txt.textContent = a + name + b;
      modal.show();
    });
  });

  ok.addEventListener('click', () => {
    if (pendingForm) {
      modal.hide();
      // submit lại form như bình thường (GET /wishlist?action=remove&productId=…)
      pendingForm.submit();
      pendingForm = null;
    }
  });
});
</script>
