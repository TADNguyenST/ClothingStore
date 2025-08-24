<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<c:set var="pageTitle" value="Overall Dashboard Report" scope="request"/>
<c:set var="currentModule" value="revenue" scope="request"/>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>${pageTitle}</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/admin-dashboard/css/admin-css.css">
  <style>
    :root{
      --brand:#4f46e5; --ok:#16a34a; --info:#0284c7; --soft:#f8fafc; --ink:#0f172a;
      --radius:14px; --shadow:0 6px 24px rgba(2,6,23,.06);
    }
    body{ background:#fff; color:var(--ink); }
    .kpi-card { border-left: 6px solid; border-radius: var(--radius); box-shadow: var(--shadow); background:#fff }
    .kpi-card.border-primary { border-color: var(--brand) !important; }
    .kpi-card.border-success { border-color: var(--ok) !important; }
    .kpi-card.border-info { border-color: var(--info) !important; }
    .kpi-card .kpi-value { font-size: 2rem; font-weight: bold; }
    .kpi-card .kpi-label { text-transform: uppercase; font-size: 0.85rem; color: #6b7280; letter-spacing:.02em }
    .loading-overlay { position: absolute; inset: 0; background-color: rgba(255,255,255,0.8); display: none; justify-content: center; align-items: center; z-index: 1000; }
    .sortable { cursor: pointer; user-select: none; }
    .sortable:hover { color: var(--brand); }
    .sortable .fa { margin-left: 8px; color: #9ca3af; font-size: 0.9em; }
    .report-section { display: none; }
    .report-section.active { display: block; }
    .nav-report .nav-link { cursor: pointer; border-radius: var(--radius); padding:.55rem 1rem }
    .nav-report .nav-link.active{ background:var(--brand); color:#fff; box-shadow: var(--shadow) }
    .box-body{ background:var(--soft); border-radius: var(--radius); padding:1.25rem }
    #report-form{ position: sticky; top: .75rem; z-index: 5; box-shadow: var(--shadow); background:#fff }
    .badge-type{ font-size:.75rem; background:#eef2ff; color:#3730a3; border-radius:999px; padding:.25rem .6rem }
    .content-area{ position:relative; margin-left:260px; padding:1.5rem; width:calc(100% - 260px); transition:all .5s ease; min-height:100vh }
    .sidebar.close ~ .content-area{ margin-left:88px; width:calc(100% - 88px) }
    .sidebar.hidden ~ .content-area{ margin-left:0; width:100% }
    .theme-dark{ --soft:#0b1220; --ink:#e5e7eb; background:#0b1220; color:var(--ink) }
    .theme-dark .box-body, .theme-dark #report-form{ background:#0f172a }
    .theme-dark .card{ background:#0f172a; color:var(--ink) }
    .theme-dark .kpi-card{ box-shadow:none }
  </style>
</head>
<body>
<jsp:include page="/WEB-INF/includes/admin-sidebar.jsp"/>
<div class="main-content-wrapper">
  <jsp:include page="/WEB-INF/includes/admin-header.jsp"/>
  <main class="content-area">
    <div class="box">
      <div class="box-header d-flex align-items-center justify-content-between">
        <h3 class="box-title mb-0">${pageTitle}</h3>
        <button id="toggleTheme" class="btn btn-sm btn-outline-secondary" title="Toggle dark mode">
          <i class="fa fa-moon"></i>
        </button>
      </div>
      <div class="box-body">

        <!-- Top menu -->
        <ul class="nav nav-pills nav-report gap-2 mb-3" role="tablist">
          <li class="nav-item">
            <a class="nav-link" data-section="section-product" data-type="revenue" id="tab-product-revenue" role="tab" aria-controls="section-product">
              <i class="fa fa-chart-column me-1"></i> Product – Revenue
            </a>
          </li>
          <li class="nav-item">
            <a class="nav-link" data-section="section-product" data-type="bestselling" id="tab-product-bestselling" role="tab" aria-controls="section-product">
              <i class="fa fa-list-ol me-1"></i> Product – Best Selling
            </a>
          </li>
          <li class="nav-item">
            <a class="nav-link" data-section="section-system" id="tab-system" role="tab" aria-controls="section-system">
              <i class="fa fa-wave-square me-1"></i> System Revenue
            </a>
          </li>
          <li class="nav-item">
            <a class="nav-link" data-section="section-products-table" id="tab-products" role="tab" aria-controls="section-products-table">
              <i class="fa fa-boxes-stacked me-1"></i> All Products Sold
            </a>
          </li>
          <li class="nav-item">
            <a class="nav-link" data-section="section-orders-table" id="tab-orders" role="tab" aria-controls="section-orders-table">
              <i class="fa fa-file-invoice-dollar me-1"></i> All Orders
            </a>
          </li>
        </ul>

        <!-- Filters -->
        <form id="report-form" class="p-3 rounded border mb-4" aria-live="polite">
          <input type="hidden" id="type" name="type" value="${empty currentType ? 'revenue' : currentType}">
          <input type="hidden" id="productSortBy" name="productSortBy" value="${productSortBy}">
          <input type="hidden" id="productSortOrder" name="productSortOrder" value="${productSortOrder}">
          <input type="hidden" id="orderSortBy" name="orderSortBy" value="${orderSortBy}">
          <input type="hidden" id="orderSortOrder" name="orderSortOrder" value="${orderSortOrder}">
          <div class="row align-items-end g-3">
            <div class="col-md-3">
              <label class="form-label fw-bold">From</label>
              <input type="date" id="startDate" name="startDate"
                class="form-control"
                <c:if test="${not empty startDate}"> value="${startDate}" </c:if>
              >
            </div>
            <div class="col-md-3">
              <label class="form-label fw-bold">To</label>
              <input type="date" id="endDate" name="endDate"
                class="form-control"
                <c:if test="${not empty endDate}"> value="${endDate}" </c:if>
              >
            </div>
            <div class="col-md-3">
              <div class="btn-group btn-group-sm ms-1 mt-2 mt-md-4" role="group" aria-label="Quick ranges">
                <button type="button" class="btn btn-outline-secondary" data-range="7">7 days</button>
                <button type="button" class="btn btn-outline-secondary" data-range="30">30 days</button>
                <button type="button" class="btn btn-outline-secondary" data-range="ytd">YTD</button>
                <button type="button" class="btn btn-outline-secondary" data-range="year">This year</button>
              </div>
            </div>
            <div class="col-md-3">
              <button type="submit" class="btn btn-primary w-100 mt-2 mt-md-0">
                <i class="fa fa-search me-2"></i>View report
              </button>
            </div>
          </div>
        </form>

        <!-- Content -->
        <div id="report-content" class="position-relative" aria-busy="false">
          <div class="loading-overlay" id="loading-indicator">
            <div class="spinner-border text-primary" style="width: 3rem; height: 3rem;" role="status"></div>
          </div>

          <!-- Product performance -->
          <div id="section-product" class="report-section" role="tabpanel" aria-labelledby="tab-product-revenue tab-product-bestselling">
            <h4 class="mb-3">
              Product Performance Report
              <span class="badge-type" id="badgeType">Revenue</span>
            </h4>

            <div class="row g-4 mb-4">
              <div class="col-md-4">
                <div class="card kpi-card border-primary">
                  <div class="card-body">
                    <div class="kpi-label" id="product-kpi-1-label"></div>
                    <div class="kpi-value" id="product-kpi-1-value"></div>
                  </div>
                </div>
              </div>
              <div class="col-md-4">
                <div class="card kpi-card border-success">
                  <div class="card-body">
                    <div class="kpi-label" id="product-kpi-2-label"></div>
                    <div class="kpi-value" id="product-kpi-2-value"></div>
                  </div>
                </div>
              </div>
              <div class="col-md-4">
                <div class="card kpi-card border-info">
                  <div class="card-body">
                    <div class="kpi-label">Top Product</div>
                    <div class="kpi-value fs-5" id="product-kpi-3-value"></div>
                  </div>
                </div>
              </div>
            </div>
            <div class="card">
              <div class="card-body">
                <h5 class="card-title" id="product-chart-title"></h5>
                <canvas id="productChart" height="260" aria-label="Top products chart"></canvas>
              </div>
            </div>
          </div>

          <!-- System revenue -->
          <div id="section-system" class="report-section" role="tabpanel" aria-labelledby="tab-system">
            <h4 class="mb-3">Overall System Revenue</h4>
            <div class="row g-4 mb-4">
              <div class="col-md-4"><div class="card kpi-card border-primary"><div class="card-body"><div class="kpi-label">Total System Revenue</div><div class="kpi-value" id="system-kpi-revenue"></div></div></div></div>
              <div class="col-md-4"><div class="card kpi-card border-success"><div class="card-body"><div class="kpi-label">Total Orders</div><div class="kpi-value" id="system-kpi-orders"></div></div></div></div>
              <div class="col-md-4"><div class="card kpi-card border-info"><div class="card-body"><div class="kpi-label">Avg. Order Value</div><div class="kpi-value" id="system-kpi-aov"></div></div></div></div>
            </div>
            <div class="card">
              <div class="card-body">
                <h5 class="card-title">System Revenue Trend</h5>
                <canvas id="systemRevenueChart" height="260" aria-label="Revenue trend"></canvas>
              </div>
            </div>
          </div>

          <!-- Products table -->
          <div id="section-products-table" class="report-section" role="tabpanel" aria-labelledby="tab-products">
            <div class="card mb-5">
              <div class="card-header d-flex align-items-center justify-content-between">
                <h5 class="card-title mb-0">All Products Sold</h5>
                <div class="table-tools d-flex align-items-center gap-2">
                  <input id="prodSearch" type="search" class="form-control form-control-sm" placeholder="Search products…">
                  <select id="prodPageSize" class="form-select form-select-sm w-auto">
                    <option>10</option><option selected>25</option><option>50</option>
                  </select>
                </div>
              </div>
              <div class="card-body table-responsive">
                <div id="product-empty" class="text-center text-muted py-4 d-none">
                  <i class="fa fa-box-open fa-2x mb-2"></i><div>No products sold.</div>
                </div>
                <table class="table table-hover">
                  <thead>
                  <tr id="product-table-header">
                    <th>#</th>
                    <th>Product Name</th>
                    <th class="text-end sortable" data-sortby="quantity">Quantity Sold<i class="fa fa-sort"></i></th>
                    <th class="text-end sortable" data-sortby="revenue">Total Revenue<i class="fa fa-sort"></i></th>
                  </tr>
                  </thead>
                  <tbody id="full-product-table-body"></tbody>
                </table>
              </div>
            </div>
          </div>

          <!-- Orders table -->
          <div id="section-orders-table" class="report-section" role="tabpanel" aria-labelledby="tab-orders">
            <div class="card">
              <div class="card-header"><h5 class="card-title mb-0">All Orders</h5></div>
              <div class="card-body table-responsive">
                <table class="table table-hover">
                  <thead>
                  <tr id="order-table-header">
                    <th>Order ID</th>
                    <th>Customer</th>
                    <th class="sortable" data-sortby="date">Order Date<i class="fa fa-sort"></i></th>
                    <th class="text-center">Items</th>
                    <th class="text-end sortable" data-sortby="total">Total Value<i class="fa fa-sort"></i></th>
                  </tr>
                  </thead>
                  <tbody id="full-order-table-body"></tbody>
                </table>
              </div>
            </div>
          </div>

        </div><!-- /report-content -->
      </div>
    </div>
  </main>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>
<script>
  // NHẬN PRELOAD từ server (có đủ revenue & bestselling cho product)
  const initialPreload = <%= new com.google.gson.Gson().toJson(request.getAttribute("report")) %>;

  document.addEventListener('DOMContentLoaded', function() {
    var form = document.getElementById('report-form');
    var loadingIndicator = document.getElementById('loading-indicator');
    var startDateInput = document.getElementById('startDate');
    var endDateInput = document.getElementById('endDate');
    var badgeType = document.getElementById('badgeType');
    var currencyFormatter = new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' });

    // theme
    var toggleThemeBtn = document.getElementById('toggleTheme');
    if(localStorage.getItem('theme')==='dark') document.body.classList.add('theme-dark');
    toggleThemeBtn.onclick = function(){
      document.body.classList.toggle('theme-dark');
      localStorage.setItem('theme', document.body.classList.contains('theme-dark') ? 'dark' : 'light');
    };

    var SECTION_IDS = ['section-product','section-system','section-products-table','section-orders-table'];
    var activeSection = sessionStorage.getItem('activeSection') || (location.hash ? location.hash.substring(1) : 'section-product');
    var reportType = sessionStorage.getItem('reportType') || document.getElementById('type').value || 'revenue';
    document.getElementById('type').value = reportType;

    var productChartInstance = null;
    var systemChartInstance = null;

    // ensure date validity
    function setDateIfIso(inputEl, raw){
      if(!inputEl || !raw) return;
      if(/^\d{4}-\d{2}-\d{2}$/.test(raw)){ inputEl.value = raw; return; }
      var m = String(raw).match(/^(\d{2})\/(\d{2})\/(\d{4})$/);
      if(m){ inputEl.value = m[3]+'-'+m[2]+'-'+m[1]; }
    }
    setDateIfIso(startDateInput, '${startDate}');
    setDateIfIso(endDateInput, '${endDate}');

    function shortNumber(n){
      if(n>=1e9) return (n/1e9).toFixed(1)+' tỷ';
      if(n>=1e6) return (n/1e6).toFixed(1)+' tr';
      if(n>=1e3) return (n/1e3).toFixed(1)+' k';
      return (n!=null ? n : 0).toLocaleString('vi-VN');
    }
    function debounce(fn,ms){ var t; ms=ms||300; return function(){ var a=arguments; clearTimeout(t); t=setTimeout(function(){ fn.apply(null,a); },ms); } }

    // Safe date helpers
    function safeParseDate(v) {
      if (v == null) return null;
      if (typeof v === 'number') {
        var dn = new Date(v);
        return isNaN(dn.getTime()) ? null : dn;
      }
      if (typeof v === 'string') {
        var s = v.trim();
        var d1 = new Date(s);
        if (!isNaN(d1.getTime())) return d1;
        s = s.replace(' ', 'T').replace(/\.\d+$/, '');
        var d2 = new Date(s);
        if (!isNaN(d2.getTime())) return d2;
        var m = s.match(/^\d{4}-\d{2}-\d{2}/);
        if (m) {
          var d3 = new Date(m[0] + 'T00:00:00');
          if (!isNaN(d3.getTime())) return d3;
        }
      }
      return null;
    }
    function safeFormatDate(v, formatter) {
      var d = safeParseDate(v);
      return d ? formatter.format(d) : (typeof v === 'string' ? v : '');
    }

    function setProductTypeActive(){
      var t1 = document.getElementById('tab-product-revenue');
      var t2 = document.getElementById('tab-product-bestselling');
      if(t1){
        t1.classList.toggle('active', reportType==='revenue' && activeSection==='section-product');
        t1.setAttribute('aria-current', (reportType==='revenue' && activeSection==='section-product')?'page':'false');
      }
      if(t2){
        t2.classList.toggle('active', reportType==='bestselling' && activeSection==='section-product');
        t2.setAttribute('aria-current', (reportType==='bestselling' && activeSection==='section-product')?'page':'false');
      }
    }

    function setActiveSection(sectionId, persist){
      if(typeof persist==='undefined') persist=true;
      for(var i=0;i<SECTION_IDS.length;i++){
        var id = SECTION_IDS[i];
        var el = document.getElementById(id);
        if(el) el.classList.toggle('active', id===sectionId);
      }
      var links = document.querySelectorAll('.nav-report .nav-link');
      for(var j=0;j<links.length;j++){ links[j].classList.remove('active'); links[j].setAttribute('aria-current','false'); }
      if(sectionId==='section-product'){
        setProductTypeActive();
      } else {
        var map = {'section-system':'tab-system','section-products-table':'tab-products','section-orders-table':'tab-orders'};
        var tab = document.getElementById(map[sectionId]);
        if(tab){ tab.classList.add('active'); tab.setAttribute('aria-current','page'); }
      }
      activeSection = sectionId;
      if(persist){ sessionStorage.setItem('activeSection', sectionId); location.hash = sectionId; }
    }

    async function updateDashboard() {
      document.getElementById('report-content').setAttribute('aria-busy','true');
      loadingIndicator.style.display = 'flex';
      var params = new URLSearchParams(new FormData(form));
      params.append('ajax', 'true');
      try {
        var response = await fetch('${pageContext.request.contextPath}/Reports?' + params.toString());
        if (!response.ok) throw new Error('Network response was not ok');
        var json = await response.json();
        window.__lastJson = json;     // single (theo type)
        renderActiveSection(json);
      } catch (error) {
        console.error('Failed to fetch report:', error);
        alert('Could not load report data. Please try again.');
      } finally {
        loadingIndicator.style.display = 'none';
        document.getElementById('report-content').setAttribute('aria-busy','false');
      }
    }
    var submitDebounced = debounce(async function(e){ e.preventDefault(); await updateDashboard(); }, 250);

    // ====== CHỌN BLOCK ĐÚNG KHI PRELOAD 2 LOẠI ======
    function renderActiveSection(json) {
      if (!json) return;
      var type = form.elements.type.value;

      // preload có cấu trúc: json.product.revenue / json.product.bestselling
      var hasDual = json.product && json.product.revenue && json.product.bestselling;

      // Chuẩn hoá thành "single" để tái dùng các hàm cũ
      var single = hasDual
        ? {
            productKpis: json.product[type].productKpis,
            productReportData: json.product[type].productReportData,
            systemKpis: json.systemKpis,
            systemRevenueChartData: json.systemRevenueChartData,
            ordersReportData: json.ordersReportData
          }
        : json;

      if (activeSection === 'section-product') {
        updateProductPerformance(single.productKpis, single.productReportData, type);
      } else if (activeSection === 'section-system') {
        updateSystemRevenue(single.systemKpis, single.systemRevenueChartData);
      } else if (activeSection === 'section-products-table') {
        renderFullProductTable(single.productReportData);
        updateSortableHeaders();
      } else if (activeSection === 'section-orders-table') {
        renderOrdersTable(single.ordersReportData);
        updateSortableHeaders();
      }
    }

    function updateProductPerformance(kpis, data, type) {
      badgeType.textContent = (type==='revenue' ? 'Revenue' : 'Best Selling');
      if (type === 'revenue') {
        document.getElementById('product-kpi-1-label').textContent = 'Total Product Revenue';
        document.getElementById('product-kpi-1-value').textContent = currencyFormatter.format((kpis && kpis.totalRevenue) || 0);
        document.getElementById('product-kpi-2-label').textContent = 'Unique Products Sold';
        document.getElementById('product-kpi-2-value').textContent = (kpis && kpis.uniqueProductsSold) || 0;
      } else {
        document.getElementById('product-kpi-1-label').textContent = 'Total Quantity Sold';
        document.getElementById('product-kpi-1-value').textContent = ((kpis && kpis.totalQuantitySold) || 0).toLocaleString('vi-VN');
        document.getElementById('product-kpi-2-label').textContent = 'Revenue from these products';
        document.getElementById('product-kpi-2-value').textContent = currencyFormatter.format((kpis && kpis.totalRevenue) || 0);
      }
      document.getElementById('product-kpi-3-value').textContent = (data && data.length > 0) ? data[0].productName : 'N/A';
      renderProductChart(data || [], type);
      document.getElementById('product-chart-title').textContent =
        (type === 'revenue') ? 'Top 5 Products by Revenue' : 'Top 5 Products by Quantity';
    }

    function updateSystemRevenue(kpis, chartData) {
      document.getElementById('system-kpi-revenue').textContent = currencyFormatter.format((kpis && kpis.totalRevenue) || 0);
      document.getElementById('system-kpi-orders').textContent = (kpis && kpis.totalOrders) || 0;
      document.getElementById('system-kpi-aov').textContent = currencyFormatter.format((kpis && kpis.averageOrderValue) || 0);
      renderSystemChart(chartData || {});
    }

    function renderProductChart(data, type) {
      if (productChartInstance) productChartInstance.destroy();
      var ctx = document.getElementById('productChart').getContext('2d');
      var top5 = (data || []).slice(0, 5);
      var labels = top5.map(function(item){ return item.productName; });
      var values = (type === 'revenue') ? top5.map(function(item){ return item.totalRevenue; }) : top5.map(function(item){ return item.totalQuantitySold; });

      productChartInstance = new Chart(ctx, {
        type: 'bar',
        data: { labels: labels, datasets: [{ data: values, borderRadius: 8, barThickness: 24, backgroundColor: '#4f46e5' }] },
        options: {
          indexAxis:'y', responsive:true, animation:{duration:350},
          scales:{
            x:{ grid:{display:false}, ticks:{ callback: function(v){ return shortNumber(v); } } },
            y:{ grid:{display:false} }
          },
          plugins:{
            legend:{ display:false },
            tooltip:{ callbacks:{ label: function(c){ return (type==='revenue'
              ? currencyFormatter.format(c.parsed.x)
              : c.parsed.x.toLocaleString('vi-VN')); } } }
          }
        }
      });
    }

    function renderSystemChart(data) {
      if (systemChartInstance) systemChartInstance.destroy();
      var ctx = document.getElementById('systemRevenueChart').getContext('2d');
      systemChartInstance = new Chart(ctx, {
        type: 'line',
        data: {
          labels: Object.keys(data || {}),
          datasets: [{
            label: 'Revenue', data: Object.values(data || {}),
            borderColor: '#16a34a', backgroundColor: 'rgba(22,163,74,0.12)',
            fill: true, tension: 0.18
          }]
        },
        options: {
          responsive:true,
          plugins:{ legend:{ display:false } },
          scales:{ x:{ grid:{display:false} }, y:{ ticks:{ callback: function(v){ return shortNumber(v); } } } }
        }
      });
    }

    // ===== Products table helpers =====
    var _productDataRaw = [];
    function renderFullProductTable(data) {
      _productDataRaw = data || [];
      applyProductTableView();
    }
    function applyProductTableView() {
      var qEl = document.getElementById('prodSearch');
      var sizeEl = document.getElementById('prodPageSize');
      var q = (qEl && qEl.value ? qEl.value : '').toLowerCase();
      var size = parseInt(sizeEl && sizeEl.value ? sizeEl.value : 25, 10);
      var filtered = _productDataRaw.filter(function(x){ return !q || (x.productName || '').toLowerCase().includes(q); });
      var rows = filtered.slice(0, size).map(function(item, i){
        return '<tr><td>'+ (i+1) +'</td><td>'+ (item.productName || '') +
               '</td><td class="text-end">'+ ((item.totalQuantitySold || 0).toLocaleString('vi-VN')) +
               '</td><td class="text-end">'+ currencyFormatter.format(item.totalRevenue || 0) +'</td></tr>';
      }).join('');
      var body = document.getElementById('full-product-table-body');
      body.innerHTML = rows || '';
      var emptyEl = document.getElementById('product-empty');
      if(emptyEl) emptyEl.classList.toggle('d-none', filtered.length > 0);
    }
    var prodSearchEl = document.getElementById('prodSearch'); if(prodSearchEl) prodSearchEl.addEventListener('input', debounce(applyProductTableView, 200));
    var prodPageSizeEl = document.getElementById('prodPageSize'); if(prodPageSizeEl) prodPageSizeEl.addEventListener('change', applyProductTableView);

    // ===== Orders table renderer (safe date) =====
    function renderOrdersTable(data) {
      var tbody = document.getElementById('full-order-table-body');
      if (!tbody) return;

      var currency = new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' });
      var dateFmt  = new Intl.DateTimeFormat('en-GB', { day: '2-digit', month: '2-digit', year: 'numeric' });

      if (!Array.isArray(data) || data.length === 0) {
        tbody.innerHTML = '<tr><td colspan="5" class="text-center text-muted py-4">No orders found.</td></tr>';
        return;
      }

      var rows = '';
      for (var i = 0; i < data.length; i++) {
        var o = data[i];
        rows += '<tr>'
              +   '<td>#' + (o.orderId ?? '') + '</td>'
              +   '<td>' + (o.customerName ?? '') + '</td>'
              +   '<td>' + safeFormatDate(o.orderDate, dateFmt) + '</td>'
              +   '<td class="text-center">' + (o.itemCount ?? 0) + '</td>'
              +   '<td class="text-end">' + currency.format(o.totalPrice ?? 0) + '</td>'
              + '</tr>';
      }
      tbody.innerHTML = rows;
    }

    // ===== sorting headers =====
    function updateSortableHeaders() {
      var icons = document.querySelectorAll('.sortable .fa');
      for(var i=0;i<icons.length;i++){ icons[i].className = 'fa fa-sort'; }
      var productSortBy = document.getElementById('productSortBy').value;
      var productSortOrder = document.getElementById('productSortOrder').value;
      var orderSortBy = document.getElementById('orderSortBy').value;
      var orderSortOrder = document.getElementById('orderSortOrder').value;

      var activeProductSort = document.querySelector('#product-table-header [data-sortby="'+productSortBy+'"]');
      if(activeProductSort){ activeProductSort.querySelector('.fa').className = 'fa fa-sort-'+ productSortOrder.toLowerCase(); }

      var activeOrderSort = document.querySelector('#order-table-header [data-sortby="'+orderSortBy+'"]');
      if(activeOrderSort){ activeOrderSort.querySelector('.fa').className = 'fa fa-sort-'+ orderSortOrder.toLowerCase(); }
    }
    var sortableHeaders = document.querySelectorAll('.sortable');
    for(var s=0;s<sortableHeaders.length;s++){
      sortableHeaders[s].addEventListener('click', function(){
        var isProductTable = !!this.closest('#product-table-header');
        var sortByInput = isProductTable ? document.getElementById('productSortBy') : document.getElementById('orderSortBy');
        var sortOrderInput = isProductTable ? document.getElementById('productSortOrder') : document.getElementById('orderSortOrder');
        if (sortByInput.value === this.dataset.sortby) {
          sortOrderInput.value = sortOrderInput.value === 'DESC' ? 'ASC' : 'DESC';
        } else {
          sortByInput.value = this.dataset.sortby;
          sortOrderInput.value = 'DESC';
        }
        form.dispatchEvent(new Event('submit', { bubbles: true, cancelable: true }));
      });
    }

    // date guards
    startDateInput.addEventListener('change', function(){ if (this.value && endDateInput.value && this.value > endDateInput.value) endDateInput.value = this.value; });
    endDateInput.addEventListener('change', function(){ if (this.value && startDateInput.value && this.value < startDateInput.value) startDateInput.value = this.value; });

    // quick ranges
    var rangeBtns = document.querySelectorAll('[data-range]');
    for(var r=0;r<rangeBtns.length;r++){
      rangeBtns[r].addEventListener('click', function(){
        var rtype = this.getAttribute('data-range'); var now = new Date(); var from = new Date(now);
        if(rtype==='7') from.setDate(now.getDate()-6);
        else if(rtype==='30') from.setDate(now.getDate()-29);
        else if(rtype==='ytd'){ from = new Date(now.getFullYear(),0,1); }
        else if(rtype==='year'){ from = new Date(now.getFullYear(),0,1); now = new Date(now.getFullYear(),11,31); }
        startDateInput.value = from.toISOString().slice(0,10);
        endDateInput.value = now.toISOString().slice(0,10);
        form.dispatchEvent(new Event('submit', { bubbles:true, cancelable:true }));
      });
    }

    // menu clicks
    var navLinks = document.querySelectorAll('.nav-report .nav-link');
    for(var k=0;k<navLinks.length;k++){
      navLinks[k].addEventListener('click', function(){
        var targetSection = this.getAttribute('data-section');
        var newType = this.getAttribute('data-type');
        if (newType) {
          reportType = newType;
          document.getElementById('type').value = reportType;
          sessionStorage.setItem('reportType', reportType);
        }
        setActiveSection(targetSection);
        // render lại từ cache hiện có (preload hoặc lần fetch gần nhất)
        if (window.__lastJson) renderActiveSection(window.__lastJson);
        else if (initialPreload) renderActiveSection(initialPreload);
      });
    }

    // submit debounced
    form.addEventListener('submit', submitDebounced);

    // initial render: dùng preload (đã có đủ revenue + bestselling)
    setActiveSection(activeSection, false);
    setProductTypeActive();
    if (initialPreload) { window.__lastJson = initialPreload; renderActiveSection(initialPreload); }
  });
</script>
</body>
</html>
