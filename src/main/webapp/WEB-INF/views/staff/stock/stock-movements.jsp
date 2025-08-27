<%@ page isELIgnored="false" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<c:set var="pageTitle" value="Inventory Change History" scope="request"/>
<c:set var="currentModule" value="stock" scope="request"/>
<c:set var="currentAction" value="stock-history" scope="request"/>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>${pageTitle} - Admin Panel</title>

  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/admin-dashboard/css/admin-css.css">

  <style>
    body{ background:#f4f6f9; }
    .content-area{ position:relative; margin-left:260px; padding:24px; width:calc(100% - 260px); transition:.4s; min-height:100vh }
    .sidebar.close ~ .content-area{ margin-left:88px; width:calc(100% - 88px) }
    .sidebar.hidden ~ .content-area{ margin-left:0; width:100% }
    .page-header{ background:#4A90E2; color:#fff; border-radius:10px; padding:14px 18px; margin-bottom:18px }
    .filter-card{ background:#fff; border-radius:10px; padding:16px; box-shadow:0 1px 3px rgba(0,0,0,.06); }
    .results-card{ background:#fff; border-radius:10px; padding:16px; box-shadow:0 1px 3px rgba(0,0,0,.06); }
    .tabs .btn{ border-radius:999px }
    .loading-overlay{ position:absolute; inset:0; background:rgba(255,255,255,.65); display:none; align-items:center; justify-content:center; z-index:10 }
    .badge-mono{ font-variant-numeric: tabular-nums; }
    .table thead th{ background:#f8f9fa }
    .btn-quick.active{ background:#4A90E2; color:#fff; }
  </style>
</head>
<body>

<jsp:include page="/WEB-INF/includes/admin-sidebar.jsp"/>

<div class="main-content-wrapper">
  <main class="content-area">
    <div class="page-header d-flex align-items-center justify-content-between">
      <h3 class="mb-0"><i class="fa fa-boxes-stacked me-2"></i>Inventory Change History</h3>
    </div>

    <!-- Tabs -->
    <div class="tabs mb-3">
      <button type="button" class="btn btn-outline-primary me-2" data-view="list">
        <i class="fa fa-list-ul me-1"></i> By Orders (List)
      </button>
      <button type="button" class="btn btn-primary me-2" data-view="grouped">
        <i class="fa fa-layer-group me-1"></i> Grouped
      </button>
      <button type="button" class="btn btn-outline-primary" data-view="product">
        <i class="fa fa-tag me-1"></i> By Product
      </button>
    </div>

    <!-- Filters -->
    <form id="filterForm" class="filter-card mb-3" autocomplete="off">
      <input type="hidden" name="viewMode" id="viewMode" value="grouped"><!-- default tab -->
      <input type="hidden" name="quick" id="quickRange" value="${empty quick ? '' : fn:escapeXml(quick)}"/>

      <div class="row g-3 align-items-end">
        <div class="col-md-3">
          <label class="form-label fw-bold">From</label>
          <input type="date" id="startDate" name="startDate"
                 class="form-control"
                 value="${empty startDate ? '' : fn:escapeXml(startDate)}"/>
        </div>
        <div class="col-md-3">
          <label class="form-label fw-bold">To</label>
          <input type="date" id="endDate" name="endDate"
                 class="form-control"
                 value="${empty endDate ? '' : fn:escapeXml(endDate)}"/>
        </div>

        <div class="col-md-4">
          <label class="form-label fw-bold">Search Product/SKU</label>
          <input type="text" id="searchInput" name="searchTerm" class="form-control"
                 placeholder="Enter product name or SKU..." value="${fn:escapeXml(searchTerm)}"/>
        </div>

        <div class="col-md-2 d-grid">
          <button type="submit" id="btnApply" class="btn btn-primary"><i class="fa fa-search me-1"></i>Apply</button>
        </div>

        <!-- Quick ranges (chỉ gửi quick lên server) -->
        <div class="col-12">
          <div class="btn-group btn-group-sm mt-2" role="group" aria-label="Quick ranges">
            <button type="button" class="btn btn-outline-secondary btn-quick" data-quick="7">7 days</button>
            <button type="button" class="btn btn-outline-secondary btn-quick" data-quick="30">30 days</button>
            <button type="button" class="btn btn-outline-secondary btn-quick" data-quick="ytd">YTD</button>
            <button type="button" class="btn btn-outline-secondary btn-quick" data-quick="year">This year</button>
          </div>
        </div>

        <!-- Group By chỉ hiện ở tab Grouped -->
        <div class="col-md-3" id="groupByWrap">
          <label class="form-label fw-bold">Group By</label>
          <select name="groupBy" id="groupBy" class="form-select">
            <option value="purchase_order" ${groupBy == 'purchase_order' ? 'selected' : ''}>Purchase Order</option>
            <option value="sale_order" ${groupBy == 'sale_order' ? 'selected' : ''}>Sale Order</option>
            <option value="adjustment" ${groupBy == 'adjustment' ? 'selected' : ''}>Adjustment</option>
          </select>
          <div class="form-text">Only for <strong>Grouped</strong> tab.</div>
        </div>
      </div>
    </form>

    <!-- Results -->
    <div class="results-card position-relative">
      <div id="loadingOverlay" class="loading-overlay">
        <div class="spinner-border text-primary" role="status"></div>
      </div>

      <p class="mb-3">
        Total Records: <strong id="totalRecords">${totalRecords}</strong>
        <span id="totalsBadge" class="ms-2"></span>
      </p>

      <div id="resultsContent"></div>
      <nav id="paginationContainer" class="mt-3 d-flex justify-content-center"></nav>
    </div>
  </main>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>

<script>
(function(){
  var ctx = '${pageContext.request.contextPath}';
  var form = document.getElementById('filterForm');
  var viewEl = document.getElementById('viewMode');
  var groupEl = document.getElementById('groupBy');
  var groupWrap = document.getElementById('groupByWrap');
  var resultsContent = document.getElementById('resultsContent');
  var paginationContainer = document.getElementById('paginationContainer');
  var totalRecordsSpan = document.getElementById('totalRecords');
  var totalsBadge = document.getElementById('totalsBadge');
  var loadingOverlay = document.getElementById('loadingOverlay');
  var startEl = document.getElementById('startDate');
  var endEl   = document.getElementById('endDate');
  var quickEl = document.getElementById('quickRange');

  function isISO(s){ return typeof s==='string' && /^\d{4}-\d{2}-\d{2}$/.test(s); }

  function syncGroupByVisibility(){
    var v = viewEl.value || 'grouped';
    groupWrap.style.display = (v === 'grouped') ? '' : 'none';
    if (v === 'grouped' && (!groupEl.value || groupEl.value==='none')) groupEl.value = 'purchase_order';
  }

  function normalizeDateOrder(){
    if(isISO(startEl.value) && isISO(endEl.value) && startEl.value > endEl.value){
      var t = startEl.value; startEl.value = endEl.value; endEl.value = t;
    }
  }

  function buildParams(page){
    var params = new URLSearchParams(new FormData(form));
    var v = params.get('viewMode') || 'grouped';
    params.set('ajax','true');
    params.set('page', page || 1);

    // gửi quick nếu có; nếu quick trống -> gửi start/end nếu hợp lệ
    if (quickEl.value) {
      params.set('quick', quickEl.value);
      params.delete('startDate');
      params.delete('endDate');
    } else {
      if (isISO(startEl.value)) params.set('startDate', startEl.value);
      if (isISO(endEl.value))   params.set('endDate', endEl.value);
    }

    if (v === 'list') {
      params.set('groupBy','none');
    } else if (v === 'grouped') {
      if (!params.get('groupBy') || params.get('groupBy') === 'none') params.set('groupBy','purchase_order');
    } else if (v === 'product') {
      params.delete('groupBy');
    }
    params.set('_ts', Date.now()); // tránh cache
    return params;
  }

  function highlightQuick(q){
    var norm = (q || '').toString().toLowerCase();
    if (norm === 'thisyear') norm = 'year';
    document.querySelectorAll('.btn-quick').forEach(function(b){
      b.classList.remove('active');
      if (b.getAttribute('data-quick') === norm) b.classList.add('active');
    });
  }

  function performFilter(page){
    normalizeDateOrder();
    var params = buildParams(page);
    loadingOverlay.style.display = 'flex';
    fetch(ctx + '/StockMovement?' + params.toString())
      .then(function(r){ if(!r.ok) throw new Error('HTTP '+r.status); return r.json(); })
      .then(function(res){
        if (isISO(res.startDate)) startEl.value = res.startDate;
        if (isISO(res.endDate))   endEl.value   = res.endDate;

        // Nếu server báo quick -> lưu & highlight
        if (res.quick) {
          quickEl.value = res.quick;
          highlightQuick(res.quick);
        } else {
          quickEl.value = '';
          highlightQuick('');
        }

        totalRecordsSpan.textContent = res.totalRecords || 0;
        totalsBadge.innerHTML = '';
        if (res.viewMode === 'list') {
          renderList(res.data || []);
        } else if (res.viewMode === 'grouped') {
          renderGrouped(res.data || {});
        } else if (res.viewMode === 'product') {
          renderByProduct(res.data || [], res.totals || {});
        }
        updatePagination(res.currentPage || 1, res.totalPages || 1);
      })
      .catch(function(e){
        resultsContent.innerHTML =
          '<div class="alert alert-danger">Failed to load data. Please try again.</div>';
        console.error(e);
      })
      .finally(function(){ loadingOverlay.style.display = 'none'; });
  }

  // Quick: chỉ set hidden và submit
  document.querySelectorAll('[data-quick]').forEach(function(btn){
    btn.addEventListener('click', function(){
      var q = this.getAttribute('data-quick');
      quickEl.value = q;
      // clear date để tránh bị gửi cùng
      startEl.value = ''; endEl.value = '';
      highlightQuick(q);
      if (form.requestSubmit) form.requestSubmit();
      else form.dispatchEvent(new Event('submit', { bubbles:true, cancelable:true }));
    });
  });

  // Khi user chỉnh tay ngày / search -> tắt quick
  ['change','input'].forEach(function(ev){
    startEl.addEventListener(ev, function(){ quickEl.value=''; highlightQuick(''); });
    endEl.addEventListener(ev,   function(){ quickEl.value=''; highlightQuick(''); });
    var s = document.getElementById('searchInput');
    if (s) s.addEventListener(ev, function(){ quickEl.value=''; });
  });
  var btnApply = document.getElementById('btnApply');
  if (btnApply) btnApply.addEventListener('click', function(){ /* giữ quick='' nếu user đã sửa ngày */ });

  // tabs
  document.querySelectorAll('.tabs [data-view]').forEach(function(btn){
    btn.addEventListener('click', function(){
      document.querySelectorAll('.tabs .btn').forEach(function(b){
        b.classList.remove('btn-primary'); b.classList.add('btn-outline-primary');
      });
      btn.classList.remove('btn-outline-primary'); btn.classList.add('btn-primary');

      viewEl.value = btn.getAttribute('data-view'); // list | grouped | product
      syncGroupByVisibility();
      performFilter(1);
    });
  });

  function updatePagination(cPage, tPages){
    paginationContainer.innerHTML = '';
    if (!tPages || tPages < 2) return;
    var html = '<ul class="pagination">';
    var prevDis = (cPage<=1) ? ' disabled' : '';
    html += '<li class="page-item'+prevDis+'"><a class="page-link" href="#" data-page="'+ (cPage-1) +'">&laquo;</a></li>';
    for (var i=1;i<=tPages;i++){
      html += '<li class="page-item'+(i===cPage?' active':'')+'"><a class="page-link" href="#" data-page="'+i+'">'+i+'</a></li>';
    }
    var nextDis = (cPage>=tPages) ? ' disabled' : '';
    html += '<li class="page-item'+nextDis+'"><a class="page-link" href="#" data-page="'+ (cPage+1) +'">&raquo;</a></li>';
    html += '</ul>';
    paginationContainer.innerHTML = html;
  }

  paginationContainer.addEventListener('click', function(e){
    if (e.target && e.target.matches('a.page-link')) {
      e.preventDefault();
      var p = parseInt(e.target.getAttribute('data-page'), 10);
      if (p) performFilter(p);
    }
  });

  form.addEventListener('submit', function(e){ e.preventDefault(); performFilter(1); });

  // Initial
  if (!groupEl.value) groupEl.value = 'purchase_order';
  if (!viewEl.value) viewEl.value = 'grouped';
  syncGroupByVisibility();

  // Lần đầu: để trống -> controller tự mặc định 30 ngày
  setTimeout(function(){ performFilter(1); }, 0);

  /* ===== Renderers giữ nguyên ===== */
  function renderList(movements){
    if(!movements || movements.length===0){
      resultsContent.innerHTML = '<div class="text-center text-muted py-4">No movements found.</div>';
      return;
    }
    var html = ''
      + '<div class="table-responsive"><table class="table table-striped table-hover">'
      + '<thead><tr>'
      + '<th>Timestamp</th><th>Product</th><th>SKU</th><th>Type</th>'
      + '<th class="text-end">Qty</th><th>Notes</th><th>Staff</th><th>Action</th>'
      + '</tr></thead><tbody>';
    for (var i=0;i<movements.length;i++){
      var m = movements[i] || {};
      var q = (m.quantityChanged || 0);
      var cls = q>0 ? 'text-success' : (q<0 ? 'text-danger' : '');
      html += '<tr>'
           +  '<td>'+ (m.createdAtFormatted||'') +'</td>'
           +  '<td>'+ (m.productName||'N/A') +' ('+(m.size||'N/A')+', '+(m.color||'N/A')+')</td>'
           +  '<td>'+ (m.sku||'') +'</td>'
           +  '<td><span class="badge bg-info">'+ (m.movementType||'') +'</span></td>'
           +  '<td class="text-end"><strong class="'+cls+'">'+ (q>0?'+':'') + q +'</strong></td>'
           +  '<td>'+ (m.notes||'') +'</td>'
           +  '<td>'+ (m.staffName||'System') +'</td>'
           +  '<td><a class="btn btn-sm btn-outline-primary" href="'+ ctx +'/StockDetail?variantId='+ (m.variantId||0) +'">Details</a></td>'
           +  '</tr>';
    }
    html += '</tbody></table></div>';
    resultsContent.innerHTML = html;
  }

  function renderGrouped(grouped){
    var keys = Object.keys(grouped||{});
    if(keys.length===0){
      resultsContent.innerHTML = '<div class="text-center text-muted py-4">No data for selected grouping.</div>';
      return;
    }
    var html = '<div class="accordion" id="acc">';
    for (var i=0;i<keys.length;i++){
      var k = keys[i];
      var list = grouped[k] || [];
      var cid = 'g' + i;
      html += ''
        + '<div class="accordion-item">'
        +   '<h2 class="accordion-header">'
        +     '<button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#'+cid+'">'
        +       '<strong>'+ k +'</strong>'
        +       '<span class="badge bg-secondary ms-2">'+ list.length +' items</span>'
        +     '</button>'
        +   '</h2>'
        +   '<div id="'+cid+'" class="accordion-collapse collapse">'
        +     '<div class="accordion-body">'
        +       '<div class="table-responsive"><table class="table table-sm align-middle">'
        +         '<thead class="table-light"><tr>'
        +           '<th>Timestamp</th><th>Product</th><th>SKU</th><th class="text-end">Qty</th>'
        +         '</tr></thead><tbody>';
      for (var j=0;j<list.length;j++){
        var m = list[j] || {};
        var q = (m.quantityChanged||0);
        var cls = q>0 ? 'text-success' : (q<0 ? 'text-danger' : '');
        html += '<tr>'
             +   '<td>'+ (m.createdAtFormatted||'') +'</td>'
             +   '<td>'+ (m.productName||'') +' ('+(m.size||'')+', '+(m.color||'')+')</td>'
             +   '<td>'+ (m.sku||'') +'</td>'
             +   '<td class="text-end"><strong class="'+cls+'">'+ (q>0?'+':'') + q +'</strong></td>'
             + '</tr>';
      }
      html +=        '</tbody></table></div>'
           +     '</div>'
           +   '</div>'
           + '</div>';
    }
    html += '</div>';
    resultsContent.innerHTML = html;
  }

  function renderByProduct(rows, totals){
    if(!rows || rows.length===0){
      resultsContent.innerHTML = '<div class="text-center text-muted py-4">No data for products.</div>';
      totalsBadge.innerHTML = '';
      return;
    }
    var totIn = (totals && totals.totalIn) ? totals.totalIn : 0;
    var totOut = (totals && totals.totalOut) ? totals.totalOut : 0;
    var net = (totals && totals.net) ? totals.net : (totIn - totOut);
    totalsBadge.innerHTML =
      '<span class="badge bg-success badge-mono">In: '+ totIn +'</span>'
      + '<span class="badge bg-danger ms-1 badge-mono">Out: '+ totOut +'</span>'
      + '<span class="badge bg-secondary ms-1 badge-mono">Net: '+ net +'</span>';

    var html = ''
      + '<div class="table-responsive"><table class="table table-hover">'
      + '<thead><tr>'
      + '<th>Product</th><th>SKU</th><th>Size</th><th>Color</th>'
      + '<th class="text-end">In</th><th class="text-end">Out</th><th class="text-end">Net</th>'
      + '</tr></thead><tbody>';

    for (var i=0;i<rows.length;i++){
      var r = rows[i] || {};
      var _in = r.inQty || 0, _out = r.outQty || 0, _net = r.netQty || (_in - _out);
      html += '<tr>'
           +   '<td>'+ (r.productName||'') +'</td>'
           +   '<td>'+ (r.sku||'') +'</td>'
           +   '<td>'+ (r.size||'') +'</td>'
           +   '<td>'+ (r.color||'') +'</td>'
           +   '<td class="text-end text-success">'+ _in +'</td>'
           +   '<td class="text-end text-danger">'+ _out +'</td>'
           +   '<td class="text-end"><strong>'+ _net +'</strong></td>'
           + '</tr>';
    }
    html += '</tbody></table></div>';
    resultsContent.innerHTML = html;
  }
})();
</script>
</body>
</html>
