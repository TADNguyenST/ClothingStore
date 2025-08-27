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
    .loading-overlay { position: absolute; inset: 0; background-color: rgba(255,255,255,0.8); display: none; justify-content: center; align-items: center; z-index: 1000; pointer-events:none; }
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
    .chart-wrap { position: relative; width: 100%; min-height: 260px; }
    #productPieChart, #productBarChart { display:block; width:100% !important; height:300px !important; max-height:320px !important; }
    #systemRevenueChart { display:block; width:100% !important; height:220px !important; max-height:240px !important; }

    /* Customer search styling */
    .customer-toolbar{ position:relative; display:flex; align-items:center; }
    .customer-toolbar input{ padding-left:2rem; padding-right:2rem; width:260px }
    .customer-toolbar .fa-magnifying-glass{
      position:absolute; left:.5rem; color:#94a3b8; pointer-events:none; font-size:.9rem
    }
    .customer-toolbar .btn-clear{
      position:absolute; right:.35rem; border:0; background:transparent; padding:.25rem .35rem;
      color:#64748b; border-radius:6px;
    }
    .customer-toolbar .btn-clear:hover{ background:#e2e8f0; color:#0f172a }
    .theme-dark .customer-toolbar .btn-clear:hover{ background:#1f2937; color:#e5e7eb }
    .pill-mono{ font-variant-numeric: tabular-nums; background:#eef2ff; color:#3730a3; border-radius:999px; padding:.15rem .45rem; font-size:.75rem }
    .content-area {
        position: relative;
        margin-left: 260px;
        padding: 1.5rem;
        width: calc(100% - 260px);
        transition: all 0.5s ease;
        min-height: 100vh;
    }
    .sidebar.close ~ .content-area {
        margin-left: 88px;
        width: calc(100% - 88px);
    }
    .sidebar.hidden ~ .content-area {
        margin-left: 0;
        width: 100%;
    }
  </style>
</head>
<body>
<c:choose>
    <c:when test="${not empty sessionScope.admin}">
        <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp"/>
    </c:when>
    <c:when test="${not empty sessionScope.staff}">
         <jsp:include page="/WEB-INF/views/staff/staff-sidebar.jsp" />
    </c:when>
</c:choose>


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
            <a href="javascript:void(0)" class="nav-link" data-section="section-product" data-type="revenue" id="tab-product-revenue" role="tab" aria-controls="section-product">
              <i class="fa fa-chart-column me-1"></i> Product – Revenue
            </a>
          </li>
          <li class="nav-item">
            <a href="javascript:void(0)" class="nav-link" data-section="section-product" data-type="bestselling" id="tab-product-bestselling" role="tab" aria-controls="section-product">
              <i class="fa fa-list-ol me-1"></i> Product – Best Selling
            </a>
          </li>
          <li class="nav-item">
            <a href="javascript:void(0)" class="nav-link" data-section="section-system" id="tab-system" role="tab" aria-controls="section-system">
              <i class="fa fa-wave-square me-1"></i> System Revenue
            </a>
          </li>
          <li class="nav-item">
            <a href="javascript:void(0)" class="nav-link" data-section="section-products-table" id="tab-products" role="tab" aria-controls="section-products-table">
              <i class="fa fa-boxes-stacked me-1"></i> All Products Sold
            </a>
          </li>
          <li class="nav-item">
            <a href="javascript:void(0)" class="nav-link" data-section="section-orders-table" id="tab-orders" role="tab" aria-controls="section-orders-table">
              <i class="fa fa-file-invoice-dollar me-1"></i> All Orders
            </a>
          </li>
          <li class="nav-item">
            <a href="javascript:void(0)" class="nav-link" data-section="section-customer" id="tab-customer" role="tab" aria-controls="section-customer">
              <i class="fa fa-user-group me-1"></i> Customer Report
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
                     <c:if test="${not empty startDate}"> value="${startDate}" </c:if>>
            </div>
            <div class="col-md-3">
              <label class="form-label fw-bold">To</label>
              <input type="date" id="endDate" name="endDate"
                     class="form-control"
                     <c:if test="${not empty endDate}"> value="${endDate}" </c:if>>
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

            <div class="row">
              <div class="col-lg-6 mb-4">
                <div class="card h-100">
                  <div class="card-body">
                    <h5 class="card-title">All Products (Pie)</h5>
                    <div class="chart-wrap">
                      <canvas id="productPieChart" aria-label="All products pie"></canvas>
                    </div>
                  </div>
                </div>
              </div>
              <div class="col-lg-6 mb-4">
                <div class="card h-100">
                  <div class="card-body">
                    <h5 class="card-title">Top 5 Products (Bar)</h5>
                    <div class="chart-wrap">
                      <canvas id="productBarChart" aria-label="Top 5 bar"></canvas>
                    </div>
                  </div>
                </div>
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
                <div class="chart-wrap">
                  <canvas id="systemRevenueChart" aria-label="Revenue trend"></canvas>
                </div>
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

          <!-- Customer Report -->
          <div id="section-customer" class="report-section" role="tabpanel" aria-labelledby="tab-customer">
            <h4 class="mb-3">Customer Report</h4>

            <div class="card">
              <div class="card-header d-flex align-items-center justify-content-between">
                <h5 class="card-title mb-0">Customers</h5>
                <div class="customer-toolbar">
                  <i class="fa fa-magnifying-glass"></i>
                  <input id="customerSearch" type="search" class="form-control form-control-sm" placeholder="Search customer…">
                  <button id="customerSearchClear" type="button" class="btn-clear" aria-label="Clear">
                    <i class="fa fa-times"></i>
                  </button>
                  <span class="text-muted small ms-2"><span id="customerTotalCount">0</span></span>
                </div>
              </div>
              <div class="card-body">
                <div id="customer-empty" class="text-center text-muted py-5">
                  <i class="fa fa-user-slash fa-2x mb-2"></i>
                  <div>No customers found.</div>
                </div>

                <div class="table-responsive">
                  <table class="table align-middle">
                    <thead class="table-light">
                      <tr>
                        <th style="width:42px"></th>
                        <th>Customer</th>
                        <th class="text-center">Orders</th>
                        <th class="text-end">Revenue</th>
                      </tr>
                    </thead>
                    <tbody id="customer-summary-body"></tbody>
                  </table>
                </div>

                <div class="accordion mt-3" id="customerAccordion"></div>
              </div>
            </div>
          </div>

        </div><!-- /report-content -->
      </div>
    </div>
  </main>


<!-- Chart.js & Bootstrap bundle -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<%
  String preloadJson = new com.google.gson.Gson().toJson(request.getAttribute("report"));
  preloadJson = preloadJson == null ? "null" : preloadJson.replace("</", "<\\/");
%>
<script id="initial-preload" type="application/json"><%= preloadJson %></script>

<script>
  const ctxPath = '${pageContext.request.contextPath}';
  const preloadEl = document.getElementById('initial-preload');
  const initialPreload = preloadEl ? JSON.parse(preloadEl.textContent) : null;

  document.addEventListener('DOMContentLoaded', function() {
    var form = document.getElementById('report-form');
    var loadingIndicator = document.getElementById('loading-indicator');
    var startDateInput = document.getElementById('startDate');
    var endDateInput = document.getElementById('endDate');
    var badgeType = document.getElementById('badgeType');
    var currencyFormatter = new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' });

    var toggleThemeBtn = document.getElementById('toggleTheme');
    if(localStorage.getItem('theme')==='dark') document.body.classList.add('theme-dark');
    toggleThemeBtn.onclick = function(){
      document.body.classList.toggle('theme-dark');
      localStorage.setItem('theme', document.body.classList.contains('theme-dark') ? 'dark' : 'light');
    };

    var SECTION_IDS = ['section-product','section-system','section-products-table','section-orders-table','section-customer'];
    var activeSection = sessionStorage.getItem('activeSection') || (location.hash ? location.hash.substring(1) : 'section-product');
    var reportType = sessionStorage.getItem('reportType') || document.getElementById('type').value || 'revenue';
    document.getElementById('type').value = reportType;

    var productPieInstance = null;
    var productBarInstance = null;
    var systemChartInstance = null;

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

    function safeParseDate(v) {
      if (v == null) return null;
      if (typeof v === 'number') { var dn = new Date(v); return isNaN(dn.getTime()) ? null : dn; }
      if (typeof v === 'string') {
        var s = v.trim(), d1 = new Date(s); if (!isNaN(d1.getTime())) return d1;
        s = s.replace(' ', 'T').replace(/\.\d+$/, ''); var d2 = new Date(s); if (!isNaN(d2.getTime())) return d2;
        var m = s.match(/^\d{4}-\d{2}-\d{2}/); if (m) { var d3 = new Date(m[0] + 'T00:00:00'); if (!isNaN(d3.getTime())) return d3; }
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
      SECTION_IDS.forEach(function(id){
        var el = document.getElementById(id);
        if(el) el.classList.toggle('active', id===sectionId);
      });
      document.querySelectorAll('.nav-report .nav-link').forEach(function(a){
        a.classList.remove('active'); a.setAttribute('aria-current','false');
      });
      if(sectionId==='section-product'){
        setProductTypeActive();
      } else {
        var map = {'section-system':'tab-system','section-products-table':'tab-products','section-orders-table':'tab-orders','section-customer':'tab-customer'};
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
        var response = await fetch(ctxPath + '/Reports?' + params.toString());
        if (!response.ok) throw new Error('Network response was not ok');
        var json = await response.json();
        window.__lastJson = json;
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

    function renderActiveSection(json) {
      if (!json) return;
      var type = form.elements.type.value;
      var hasDual = json.product && json.product.revenue && json.product.bestselling;
      var single = hasDual
        ? {
            productKpis: json.product[type].productKpis,
            productReportData: json.product[type].productReportData,
            systemKpis: json.systemKpis,
            systemRevenueChartData: json.systemRevenueChartData,
            ordersReportData: json.ordersReportData,
            customerSummary: json.customerSummary
          }
        : json;

      if (activeSection === 'section-product') {
        updateProductPerformance(single.productKpis, single.productReportData, type);
      } else if (activeSection === 'section-system') {
        updateSystemRevenue(single.systemKpis, single.systemRevenueChartData);
      } else if (activeSection === 'section-products-table') {
        renderFullProductTable(single.productReportData); updateSortableHeaders();
      } else if (activeSection === 'section-orders-table') {
        renderOrdersTable(single.ordersReportData); updateSortableHeaders();
      } else if (activeSection === 'section-customer') {
        renderCustomerSummary(single.customerSummary || []);
      }
    }

    function updateProductPerformance(kpis, data, type) {
      var cf = currencyFormatter;
      badgeType.textContent = (type==='revenue' ? 'Revenue' : 'Best Selling');
      if (type === 'revenue') {
        document.getElementById('product-kpi-1-label').textContent = 'Total Product Revenue';
        document.getElementById('product-kpi-1-value').textContent = cf.format((kpis && kpis.totalRevenue) || 0);
        document.getElementById('product-kpi-2-label').textContent = 'Unique Products Sold';
        document.getElementById('product-kpi-2-value').textContent = (kpis && kpis.uniqueProductsSold) || 0;
      } else {
        document.getElementById('product-kpi-1-label').textContent = 'Total Quantity Sold';
        document.getElementById('product-kpi-1-value').textContent = ((kpis && kpis.totalQuantitySold) || 0).toLocaleString('vi-VN');
        document.getElementById('product-kpi-2-label').textContent = 'Revenue from these products';
        document.getElementById('product-kpi-2-value').textContent = cf.format((kpis && kpis.totalRevenue) || 0);
      }
      document.getElementById('product-kpi-3-value').textContent = (data && data.length > 0) ? (data[0].productName || 'N/A') : 'N/A';
      updateProductCharts(data || [], type);
    }

   function updateProductCharts(data, type) {
  // ---- chọn tiêu chí & sắp xếp giảm dần
  var scored = (data || []).map(function (i) {
    return {
      label: i.productName || 'N/A',
      value: (type === 'revenue') ? (i.totalRevenue || 0) : (i.totalQuantitySold || 0)
    };
  }).sort(function (a, b) { return b.value - a.value; });

  // ---- cắt top 10 và gộp phần còn lại vào "Others"
  var top = scored.slice(0, 10);
  if (scored.length > 10) {
    var othersValue = scored.slice(10).reduce(function (s, x) { return s + x.value; }, 0);
    if (othersValue > 0) top.push({ label: 'Others', value: othersValue });
  }

  // ---- dữ liệu cho PIE
  var allLabels = top.map(function (x) { return x.label; });
  var allValues = top.map(function (x) { return x.value; });

  // palette có sẵn
  var palette = ['#4f46e5','#16a34a','#0284c7','#f59e0b','#ef4444','#8b5cf6','#ec4899','#14b8a6','#84cc16','#f43f5e','#0ea5e9','#22c55e','#a855f7','#fb7185','#eab308'];
  var pieColors = allLabels.map(function(_, i){ return palette[i % palette.length]; });

  // Hủy & vẽ lại PIE
  if (productPieInstance) productPieInstance.destroy();
  var pieCtx = document.getElementById('productPieChart').getContext('2d');
  productPieInstance = new Chart(pieCtx, {
    type:'doughnut',
    data:{ labels: allLabels, datasets:[{ data: allValues, backgroundColor: pieColors, borderColor:'#fff', borderWidth:2, hoverOffset:6 }] },
    options:{
      responsive:true, maintainAspectRatio:false, cutout:'55%',
      plugins:{
        legend:{ display:true, position:'bottom' },
        tooltip:{ callbacks:{ label:function(c){
          var v=c.parsed;
          return (type==='revenue')
            ? new Intl.NumberFormat('vi-VN',{style:'currency',currency:'VND'}).format(v)
            : v.toLocaleString('vi-VN');
        }}}
      }
    }
  });

  // BAR (giữ top 5 như cũ)
  if (productBarInstance) productBarInstance.destroy();
  var barCtx = document.getElementById('productBarChart').getContext('2d');
  var top5 = scored.slice(0,5);
  var barLabels = top5.map(function(i){ return i.label; });
  var barValues = top5.map(function(i){ return i.value; });
  productBarInstance = new Chart(barCtx, {
    type:'bar',
    data:{ labels:barLabels, datasets:[{ data:barValues, backgroundColor:'#60a5fa', borderRadius:6 }] },
    options:{
      responsive:true, maintainAspectRatio:false,
      plugins:{ legend:{ display:false } },
      scales:{ x:{ grid:{display:false} }, y:{ grid:{display:false}, ticks:{ callback:function(v){ 
        return (type==='revenue')
          ? new Intl.NumberFormat('vi-VN',{style:'currency',currency:'VND'}).format(v)
          : v.toLocaleString('vi-VN');
      } } } }
    }
  });
}

    function updateSystemRevenue(kpis, chartData) {
      var cf = currencyFormatter;
      document.getElementById('system-kpi-revenue').textContent = cf.format((kpis && kpis.totalRevenue) || 0);
      document.getElementById('system-kpi-orders').textContent = (kpis && kpis.totalOrders) || 0;
      document.getElementById('system-kpi-aov').textContent = cf.format((kpis && kpis.averageOrderValue) || 0);
      renderSystemChart(chartData || {});
    }

    function renderSystemChart(data) {
      if (systemChartInstance) systemChartInstance.destroy();
      var ctx = document.getElementById('systemRevenueChart').getContext('2d');
      systemChartInstance = new Chart(ctx, {
        type: 'line',
        data: { labels: Object.keys(data || {}), datasets: [{ label: 'Revenue', data: Object.values(data || {}), borderColor: '#16a34a', backgroundColor: 'rgba(22,163,74,0.12)', fill: true, tension: 0.18, pointRadius: 2 }] },
        options: { responsive:true, maintainAspectRatio:false, plugins:{ legend:{ display:false } }, scales:{ x:{ grid:{display:false} }, y:{ ticks:{ callback: function(v){ return shortNumber(v); } } } } }
      });
    }

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

    function updateSortableHeaders() {
      document.querySelectorAll('.sortable .fa').forEach(function(i){ i.className='fa fa-sort'; });
      var productSortBy = document.getElementById('productSortBy').value;
      var productSortOrder = document.getElementById('productSortOrder').value;
      var orderSortBy = document.getElementById('orderSortBy').value;
      var orderSortOrder = document.getElementById('orderSortOrder').value;

      var activeProductSort = document.querySelector('#product-table-header [data-sortby="'+productSortBy+'"]');
      if(activeProductSort){ activeProductSort.querySelector('.fa').className = 'fa fa-sort-'+ productSortOrder.toLowerCase(); }
      var activeOrderSort = document.querySelector('#order-table-header [data-sortby="'+orderSortBy+'"]');
      if(activeOrderSort){ activeOrderSort.querySelector('.fa').className = 'fa fa-sort-'+ orderSortOrder.toLowerCase(); }
    }
    document.querySelectorAll('.sortable').forEach(function(h){
      h.addEventListener('click', function(){
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
    });

    startDateInput.addEventListener('change', function(){ if (this.value && endDateInput.value && this.value > endDateInput.value) endDateInput.value = this.value; });
    endDateInput.addEventListener('change', function(){ if (this.value && startDateInput.value && this.value < startDateInput.value) startDateInput.value = this.value; });

    document.querySelectorAll('[data-range]').forEach(function(btn){
      btn.addEventListener('click', function(){
        var rtype = this.getAttribute('data-range');
        var now   = new Date();
        var from  = new Date(now);
        if (rtype === '7')  from.setDate(now.getDate() - 6);
        else if (rtype === '30') from.setDate(now.getDate() - 29);
        else if (rtype === 'ytd') { from = new Date(now.getFullYear(), 0, 1); }
        else if (rtype === 'year') { from = new Date(now.getFullYear(), 0, 1); }

        var toYMD = function (d) { var y=d.getFullYear(), m=String(d.getMonth()+1).padStart(2,'0'), dd=String(d.getDate()).padStart(2,'0'); return y+'-'+m+'-'+dd; };
        startDateInput.value = toYMD(from);
        endDateInput.value   = toYMD(now);

        if (form.requestSubmit) form.requestSubmit();
        else form.dispatchEvent(new Event('submit', { bubbles: true, cancelable: true }));
      });
    });

    document.querySelectorAll('.nav-report .nav-link').forEach(function(link){
      link.addEventListener('click', function(){
        var targetSection = this.getAttribute('data-section');
        var newType = this.getAttribute('data-type');
        if (newType) {
          reportType = newType;
          document.getElementById('type').value = reportType;
          sessionStorage.setItem('reportType', reportType);
        }
        setActiveSection(targetSection);
        if (window.__lastJson) renderActiveSection(window.__lastJson);
        else if (initialPreload) renderActiveSection(initialPreload);
      });
    });

    form.addEventListener('submit', submitDebounced);

    // ====== CUSTOMER UI helpers (sửa sạch) ======
    function renderCustomerSummary(list){
      var emptyEl = document.getElementById('customer-empty');
      var body    = document.getElementById('customer-summary-body');
      var acc     = document.getElementById('customerAccordion');
      var cf      = new Intl.NumberFormat('vi-VN',{style:'currency',currency:'VND'});

      var q = (document.getElementById('customerSearch')?.value || '').toLowerCase().trim();
      var src = Array.isArray(list) ? list : [];
      var filtered = src.filter(function(c){
        return !q || (c.customerName || '').toLowerCase().includes(q);
      });

      filtered.sort(function(a,b){ return (b.totalRevenue||0) - (a.totalRevenue||0); });

      if(filtered.length === 0){
        emptyEl.style.display = '';
        body.innerHTML = '';
        acc.innerHTML  = '';
        document.getElementById('customerTotalCount').textContent = '0 customers';
        return;
      }

      emptyEl.style.display = 'none';
      document.getElementById('customerTotalCount').textContent = filtered.length + ' customers';

      var rows = '';
      for (var i=0;i<filtered.length;i++){
        var c = filtered[i] || {};
        rows += '<tr data-customer-id="'+ (c.customerId||'') +'">'
              +   '<td class="text-center"><button class="btn btn-sm btn-outline-primary" data-action="open-accordion" title="Show orders for '+ (c.customerName||'') +'"><i class="fa fa-chevron-down"></i></button></td>'
              +   '<td><strong>'+ (c.customerName||'') +'</strong></td>'
              +   '<td class="text-center"><span class="pill-mono">'+ ((c.totalOrders||0).toLocaleString('vi-VN')) +'</span></td>'
              +   '<td class="text-end">'+ (c.totalRevenue!=null? cf.format(c.totalRevenue):'₫0') +'</td>'
              + '</tr>';
      }
      body.innerHTML = rows;

      var accHtml = '';
      for (var j=0;j<filtered.length;j++){
        var c2 = filtered[j] || {};
        accHtml += '<div class="accordion-item">'
                 +   '<h2 class="accordion-header" id="heading-'+j+'">'
                 +     '<button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#collapse-'+j+'" aria-expanded="false" aria-controls="collapse-'+j+'" data-customer-id="'+ (c2.customerId||'') +'">'
                 +       '<i class="fa fa-user me-2"></i> ' + (c2.customerName||'')
                 +       '<span class="ms-2 pill-mono">Orders: '+ ((c2.totalOrders||0).toLocaleString('vi-VN')) +'</span>'
                 +       '<span class="ms-2 pill-mono">Revenue: '+ (c2.totalRevenue!=null? cf.format(c2.totalRevenue):'₫0') +'</span>'
                 +     '</button>'
                 +   '</h2>'
                 +   '<div id="collapse-'+j+'" class="accordion-collapse collapse" aria-labelledby="heading-'+j+'" data-bs-parent="#customerAccordion">'
                 +     '<div class="accordion-body"><div class="text-muted">Click to load orders…</div></div>'
                 +   '</div>'
                 + '</div>';
      }
      acc.innerHTML = accHtml;

      body.querySelectorAll('[data-action="open-accordion"]').forEach(function(btn){
        btn.addEventListener('click', function(){
          var tr = this.closest('tr');
          var cid = tr.getAttribute('data-customer-id');
          var accBtn = document.querySelector('#customerAccordion .accordion-button[data-customer-id="'+cid+'"]');
          if(accBtn){ accBtn.click(); }
        });
      });

      document.querySelectorAll('#customerAccordion .accordion-button').forEach(function(btn){
        btn.addEventListener('click', async function(){
          var cid = this.getAttribute('data-customer-id');
          var target = this.getAttribute('data-bs-target');
          var collapse = document.querySelector(target);
          if(collapse && collapse.querySelector('.accordion-body')){
            var body = collapse.querySelector('.accordion-body');
            if(!collapse.classList.contains('loaded')){
              await loadOrdersForCustomer(cid, body);
              collapse.classList.add('loaded');
            }
          }
        });
      });
    }

    async function loadOrdersForCustomer(customerId, container){
      try{
        var url = ctxPath + '/Reports?ajax=true&customerId='+ encodeURIComponent(customerId)
                  + '&startDate='+ encodeURIComponent(startDateInput.value)
                  + '&endDate='+ encodeURIComponent(endDateInput.value);
        var res = await fetch(url);
        var data = await res.json();
        renderOrderListForCustomer(data, container);
      }catch(e){
        container.innerHTML = '<div class="text-danger">Failed to load orders.</div>';
      }
    }

    function renderOrderListForCustomer(orders, container){
      if(!Array.isArray(orders) || orders.length===0){
        container.innerHTML = '<div class="text-muted">No orders in this range.</div>';
        return;
      }
      var dateFmt = new Intl.DateTimeFormat('en-GB', { day:'2-digit', month:'2-digit', year:'numeric' });
      var cf = new Intl.NumberFormat('vi-VN',{style:'currency',currency:'VND'});

      var rows = '';
      for (var i=0;i<orders.length;i++){
        var o = orders[i] || {};
        rows += '<tr data-order-id="'+ (o.orderId||'') +'">'
              +   '<td class="text-center"><button class="btn btn-sm btn-outline-secondary" data-action="open-items"><i class="fa fa-chevron-down"></i></button></td>'
              +   '<td>#'+ (o.orderId||'') +'</td>'
              +   '<td>'+ (function(){var d = (typeof o.orderDate!=='undefined')? safeFormatDate(o.orderDate, dateFmt):''; return d || '';})() +'</td>'
              +   '<td class="text-center">'+ (o.itemCount||0) +'</td>'
              +   '<td class="text-end">'+ (cf.format(o.totalPrice||0)) +'</td>'
              + '</tr>'
              + '<tr class="d-none order-items-row"><td colspan="5"><div class="p-2 border rounded bg-white">Loading items…</div></td></tr>';
      }

      var html = ''
          + '<div class="table-responsive">'
          +   '<table class="table table-sm align-middle">'
          +     '<thead class="table-light">'
          +       '<tr>'
          +         '<th style="width:42px"></th>'
          +         '<th>Order #</th>'
          +         '<th>Date</th>'
          +         '<th class="text-center">Items</th>'
          +         '<th class="text-end">Total</th>'
          +       '</tr>'
          +     '</thead>'
          +     '<tbody>'+ rows +'</tbody>'
          +   '</table>'
          + '</div>';
      container.innerHTML = html;

      container.querySelectorAll('[data-action="open-items"]').forEach(function(btn){
        btn.addEventListener('click', async function(){
          var tr = this.closest('tr');
          var next = tr.nextElementSibling;
          var orderId = tr.getAttribute('data-order-id');
          if(next && next.classList.contains('order-items-row')){
            var box = next.querySelector('div');
            if(next.classList.contains('d-none')){
              if(!next.classList.contains('loaded')){
                await loadItemsForOrder(orderId, box);
                next.classList.add('loaded');
              }
              next.classList.remove('d-none');
            } else {
              next.classList.add('d-none');
            }
          }
        });
      });
    }

    async function loadItemsForOrder(orderId, box){
      try{
        var res = await fetch(ctxPath + '/Reports?ajax=true&orderId=' + encodeURIComponent(orderId));
        var items = await res.json();
        renderItems(items, box);
      }catch(e){
        box.innerHTML = '<div class="text-danger">Failed to load items.</div>';
      }
    }

    function renderItems(items, box){
      if(!Array.isArray(items) || items.length===0){
        box.innerHTML = '<div class="text-muted">No items.</div>';
        return;
      }
      var cf = new Intl.NumberFormat('vi-VN',{style:'currency',currency:'VND'});
      var rows = '';
      for (var i=0;i<items.length;i++){
        var it = items[i] || {};
        rows += '<tr>'
              +   '<td>'+ (it.productName||'') +'</td>'
              +   '<td>'+ (it.sku||'') +'</td>'
              +   '<td class="text-center">'+ (it.quantity||0) +'</td>'
              +   '<td class="text-end">'+ (cf.format(it.unitPrice||0)) +'</td>'
              +   '<td class="text-end">'+ (cf.format(it.totalPrice||0)) +'</td>'
              + '</tr>';
      }
      var html = ''
          + '<div class="table-responsive">'
          +   '<table class="table table-sm table-bordered mb-0">'
          +     '<thead class="table-light"><tr>'
          +       '<th>Product</th><th>SKU</th><th class="text-center">Qty</th><th class="text-end">Unit Price</th><th class="text-end">Total</th>'
          +     '</tr></thead>'
          +     '<tbody>'+ rows +'</tbody>'
          +   '</table>'
          + '</div>';
      box.innerHTML = html;
    }
    // ===== end customer helpers =====

    // Search realtime + Clear
    var customerSearchEl = document.getElementById('customerSearch');
    var customerSearchClear = document.getElementById('customerSearchClear');
    if (customerSearchEl) {
      customerSearchEl.addEventListener('keydown', function(e){ if (e.key === 'Enter') e.preventDefault(); });
      customerSearchEl.addEventListener('input', debounce(function () {
        var src = (window.__lastJson && window.__lastJson.customerSummary)
                  ? window.__lastJson.customerSummary
                  : (initialPreload && initialPreload.customerSummary) ? initialPreload.customerSummary : [];
        renderCustomerSummary(src);
      }, 200));
    }
    if (customerSearchClear) {
      customerSearchClear.addEventListener('click', function(){
        if (customerSearchEl) {
          customerSearchEl.value = '';
          var src = (window.__lastJson && window.__lastJson.customerSummary)
                    ? window.__lastJson.customerSummary
                    : (initialPreload && initialPreload.customerSummary) ? initialPreload.customerSummary : [];
          renderCustomerSummary(src);
          customerSearchEl.focus();
        }
      });
    }

    // initial render
    setActiveSection(activeSection, false);
    setProductTypeActive();
    if (initialPreload) { window.__lastJson = initialPreload; renderActiveSection(initialPreload); }
  });
</script>
</body>
</html>
