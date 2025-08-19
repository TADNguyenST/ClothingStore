<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<c:set var="pageTitle" value="Overall Dashboard Report" scope="request"/>
<c:set var="currentModule" value="revenue" scope="request"/>
<c:set var="report" value="${requestScope.report}" />
<c:set var="gson" value="<%= new com.google.gson.Gson().toJson(request.getAttribute(\"report\")) %>" />

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>${pageTitle}</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/admin-dashboard/css/admin-css.css">
    <style>
        .kpi-card { border-left: 5px solid; box-shadow: 0 2px 10px rgba(0,0,0,0.05); }
        .kpi-card.border-primary { border-color: #0d6efd !important; }
        .kpi-card.border-success { border-color: #198754 !important; }
        .kpi-card.border-info { border-color: #0dcaf0 !important; }
        .kpi-card .kpi-value { font-size: 2rem; font-weight: bold; }
        .kpi-card .kpi-label { text-transform: uppercase; font-size: 0.9rem; color: #6c757d; }
        .loading-overlay { position: absolute; top: 0; left: 0; width: 100%; height: 100%; background-color: rgba(255, 255, 255, 0.8); display: none; justify-content: center; align-items: center; z-index: 1000; }
        .sortable { cursor: pointer; user-select: none; }
        .sortable:hover { color: #0d6efd; }
        .sortable .fa { margin-left: 8px; color: #ccc; font-size: 0.9em; }
        .sortable.asc .fa-sort-up { color: #0d6efd; }
        .sortable.desc .fa-sort-down { color: #0d6efd; }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp"/>
    <div class="main-content-wrapper">
        <jsp:include page="/WEB-INF/includes/admin-header.jsp"/>
        <main class="content-area">
            <div class="box">
                <div class="box-header"><h3 class="box-title">${pageTitle}</h3></div>
                <div class="box-body">
                    <form id="report-form" class="p-3 bg-light rounded border mb-4">
                        <input type="hidden" id="productSortBy" name="productSortBy" value="${productSortBy}">
                        <input type="hidden" id="productSortOrder" name="productSortOrder" value="${productSortOrder}">
                        <input type="hidden" id="orderSortBy" name="orderSortBy" value="${orderSortBy}">
                        <input type="hidden" id="orderSortOrder" name="orderSortOrder" value="${orderSortOrder}">
                        <div class="row align-items-end g-3">
                            <div class="col-md-3"><label class="form-label fw-bold">Report Type</label><select name="type" id="type" class="form-select"><option value="revenue" ${currentType eq 'revenue' ? 'selected' : ''}>Revenue by Product</option><option value="bestselling" ${currentType eq 'bestselling' ? 'selected' : ''}>Best Selling Products</option></select></div>
                            <div class="col-md-3"><label class="form-label fw-bold">From</label><input type="date" id="startDate" name="startDate" value="${startDate}" class="form-control"></div>
                            <div class="col-md-3"><label class="form-label fw-bold">To</label><input type="date" id="endDate" name="endDate" value="${endDate}" class="form-control"></div>
                            <div class="col-md-3"><button type="submit" class="btn btn-primary w-100"><i class="fa fa-search me-2"></i>View Report</button></div>
                        </div>
                    </form>

                    <div id="report-content" class="position-relative">
                        <div class="loading-overlay" id="loading-indicator"><div class="spinner-border text-primary" style="width: 3rem; height: 3rem;" role="status"></div></div>
                        
                        <%-- PHẦN 1: BÁO CÁO HIỆU SUẤT SẢN PHẨM --%>
                        <div class="mb-5">
                            <h4 class="mb-3">Product Performance Report</h4>
                            <div class="row g-4 mb-4">
                               <div class="col-md-4"><div class="card kpi-card border-primary"><div class="card-body"><div class="kpi-label" id="product-kpi-1-label"></div><div class="kpi-value" id="product-kpi-1-value"></div></div></div></div>
                                <div class="col-md-4"><div class="card kpi-card border-success"><div class="card-body"><div class="kpi-label" id="product-kpi-2-label"></div><div class="kpi-value" id="product-kpi-2-value"></div></div></div></div>
                                <div class="col-md-4"><div class="card kpi-card border-info"><div class="card-body"><div class="kpi-label">Top Product</div><div class="kpi-value fs-5" id="product-kpi-3-value"></div></div></div></div>
                            </div>
                            <div class="card"><div class="card-body"><h5 class="card-title" id="product-chart-title"></h5><canvas id="productChart"></canvas></div></div>
                        </div>
                        
                        <hr class="my-5">

                        <%-- PHẦN 2: BÁO CÁO DOANH THU HỆ THỐNG --%>
                        <div class="mb-5">
                            <h4 class="mb-3">Overall System Revenue</h4>
                            <div class="row g-4 mb-4">
                                <div class="col-md-4"><div class="card kpi-card border-primary"><div class="card-body"><div class="kpi-label">Total System Revenue</div><div class="kpi-value" id="system-kpi-revenue"></div></div></div></div>
                                <div class="col-md-4"><div class="card kpi-card border-success"><div class="card-body"><div class="kpi-label">Total Orders</div><div class="kpi-value" id="system-kpi-orders"></div></div></div></div>
                                <div class="col-md-4"><div class="card kpi-card border-info"><div class="card-body"><div class="kpi-label">Avg. Order Value</div><div class="kpi-value" id="system-kpi-aov"></div></div></div></div>
                            </div>
                            <div class="card"><div class="card-body"><h5 class="card-title">System Revenue Trend</h5><canvas id="systemRevenueChart"></canvas></div></div>
                        </div>

                        <hr class="my-5">

                        <%-- BẢNG DANH SÁCH SẢN PHẨM ĐÃ BÁN --%>
                        <div class="card mb-5">
                            <div class="card-header"><h5 class="card-title">All Products Sold</h5></div>
                            <div class="card-body table-responsive">
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

                        <%-- BẢNG DANH SÁCH ĐƠN HÀNG --%>
                        <div class="card">
                            <div class="card-header"><h5 class="card-title">All Orders</h5></div>
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
                </div>
            </div>
        </main>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>
    <script>
        const initialReport = <%= new com.google.gson.Gson().toJson(request.getAttribute("report")) %>;

        document.addEventListener('DOMContentLoaded', function() {
            const form = document.getElementById('report-form');
            const loadingIndicator = document.getElementById('loading-indicator');
            const startDateInput = document.getElementById('startDate');
            const endDateInput = document.getElementById('endDate');
            const currencyFormatter = new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' });
            let productChartInstance = null;
            let systemChartInstance = null;

            async function updateDashboard() {
                loadingIndicator.style.display = 'flex';
                const params = new URLSearchParams(new FormData(form));
                params.append('ajax', 'true');
                
                try {
                    const response = await fetch('${pageContext.request.contextPath}/Reports?' + params.toString());
                    if (!response.ok) throw new Error('Network response was not ok');
                    const json = await response.json();
                    updateUI(json);
                } catch (error) {
                    console.error('Failed to fetch report:', error);
                    alert('Could not load report data. Please try again.');
                } finally {
                    loadingIndicator.style.display = 'none';
                }
            }

            function updateUI(json) {
                if (!json) return;
                const reportType = form.elements.type.value;
                
                updateProductPerformance(json.productKpis, json.productReportData, reportType);
                updateSystemRevenue(json.systemKpis, json.systemRevenueChartData);
                renderFullProductTable(json.productReportData);
                renderOrdersTable(json.ordersReportData);
                updateSortableHeaders();
            }

            function updateProductPerformance(kpis, data, type) {
                if (type === 'revenue') {
                    document.getElementById('product-kpi-1-label').textContent = 'Total Product Revenue';
                    document.getElementById('product-kpi-1-value').textContent = currencyFormatter.format(kpis.totalRevenue || 0);
                    document.getElementById('product-kpi-2-label').textContent = 'Unique Products Sold';
                    document.getElementById('product-kpi-2-value').textContent = kpis.uniqueProductsSold || 0;
                } else {
                    document.getElementById('product-kpi-1-label').textContent = 'Total Quantity Sold';
                    document.getElementById('product-kpi-1-value').textContent = (kpis.totalQuantitySold || 0).toLocaleString();
                    document.getElementById('product-kpi-2-label').textContent = 'Revenue from these products';
                    document.getElementById('product-kpi-2-value').textContent = currencyFormatter.format(kpis.totalRevenue || 0);
                }
                document.getElementById('product-kpi-3-value').textContent = (data && data.length > 0) ? data[0].productName : 'N/A';
                renderProductChart(data, type);
            }

            function updateSystemRevenue(kpis, chartData) {
                document.getElementById('system-kpi-revenue').textContent = currencyFormatter.format(kpis.totalRevenue || 0);
                document.getElementById('system-kpi-orders').textContent = kpis.totalOrders || 0;
                document.getElementById('system-kpi-aov').textContent = currencyFormatter.format(kpis.averageOrderValue || 0);
                renderSystemChart(chartData);
            }

            function renderProductChart(data, type) {
                if (productChartInstance) productChartInstance.destroy();
                const ctx = document.getElementById('productChart').getContext('2d');
                const top5Data = data.slice(0, 5);
                const labels = top5Data.map(item => item.productName);
                const values = (type === 'revenue') ? top5Data.map(item => item.totalRevenue) : top5Data.map(item => item.totalQuantitySold);
                const chartLabel = (type === 'revenue') ? 'Revenue (VND)' : 'Quantity Sold';
                document.getElementById('product-chart-title').textContent = (type === 'revenue') ? 'Top 5 Products by Revenue' : 'Top 5 Products by Quantity';

                productChartInstance = new Chart(ctx, {
                    type: 'bar',
                    data: { labels: labels, datasets: [{ label: chartLabel, data: values, backgroundColor: '#0d6efd' }] },
                    options: { indexAxis: 'y', responsive: true, plugins: { legend: { display: false } } }
                });
            }
            
            function renderSystemChart(data) {
                if (systemChartInstance) systemChartInstance.destroy();
                const ctx = document.getElementById('systemRevenueChart').getContext('2d');
                systemChartInstance = new Chart(ctx, {
                    type: 'line',
                    data: {
                        labels: Object.keys(data),
                        datasets: [{
                            label: 'Revenue', data: Object.values(data),
                            borderColor: '#198754', backgroundColor: 'rgba(25, 135, 84, 0.1)',
                            fill: true, tension: 0.1
                        }]
                    },
                    options: { responsive: true, plugins: { legend: { display: false } } }
                });
            }

            function renderFullProductTable(data) {
                const tableBody = document.getElementById('full-product-table-body');
                tableBody.innerHTML = '';
                if (!data || data.length === 0) {
                    tableBody.innerHTML = '<tr><td colspan="4" class="text-center">No products sold.</td></tr>';
                    return;
                }
                let count = 1;
                let rowsHtml = '';
                data.forEach(item => {
                    rowsHtml += '<tr><td>' + (count++) + '</td><td>' + item.productName + '</td><td class="text-end">' + (item.totalQuantitySold || 0).toLocaleString() + '</td><td class="text-end">' + currencyFormatter.format(item.totalRevenue || 0) + '</td></tr>';
                });
                tableBody.innerHTML = rowsHtml;
            }

            function renderOrdersTable(data) {
                const tableBody = document.getElementById('full-order-table-body');
                tableBody.innerHTML = '';
                if (!data || data.length === 0) {
                    tableBody.innerHTML = '<tr><td colspan="5" class="text-center">No orders found.</td></tr>';
                    return;
                }
                const dateFormatter = new Intl.DateTimeFormat('vi-VN', { day: '2-digit', month: '2-digit', year: 'numeric' });
                let rowsHtml = '';
                data.forEach(item => {
                    rowsHtml += '<tr><td>#' + item.orderId + '</td><td>' + item.customerName + '</td><td>' + dateFormatter.format(new Date(item.orderDate)) + '</td><td class="text-center">' + item.itemCount + '</td><td class="text-end">' + currencyFormatter.format(item.totalPrice) + '</td></tr>';
                });
                tableBody.innerHTML = rowsHtml;
            }
            
            function updateSortableHeaders() {
                document.querySelectorAll('.sortable .fa').forEach(icon => { icon.className = 'fa fa-sort'; });
                const productSortBy = document.getElementById('productSortBy').value;
                const productSortOrder = document.getElementById('productSortOrder').value;
                const orderSortBy = document.getElementById('orderSortBy').value;
                const orderSortOrder = document.getElementById('orderSortOrder').value;
                
                let activeProductSort = document.querySelector(`#product-table-header [data-sortby="${productSortBy}"]`);
                if(activeProductSort) activeProductSort.querySelector('.fa').className = `fa fa-sort-${productSortOrder.toLowerCase()}`;
                
                let activeOrderSort = document.querySelector(`#order-table-header [data-sortby="${orderSortBy}"]`);
                if(activeOrderSort) activeOrderSort.querySelector('.fa').className = `fa fa-sort-${orderSortOrder.toLowerCase()}`;
            }

            document.querySelectorAll('.sortable').forEach(header => {
                header.addEventListener('click', function() {
                    const isProductTable = !!this.closest('#product-table-header');
                    const sortByInput = isProductTable ? document.getElementById('productSortBy') : document.getElementById('orderSortBy');
                    const sortOrderInput = isProductTable ? document.getElementById('productSortOrder') : document.getElementById('orderSortOrder');
                    
                    if (sortByInput.value === this.dataset.sortby) {
                        sortOrderInput.value = sortOrderInput.value === 'DESC' ? 'ASC' : 'DESC';
                    } else {
                        sortByInput.value = this.dataset.sortby;
                        sortOrderInput.value = 'DESC';
                    }
                    form.dispatchEvent(new Event('submit', { bubbles: true, cancelable: true }));
                });
            });

            startDateInput.addEventListener('change', function() {
                if (this.value > endDateInput.value) endDateInput.value = this.value;
            });

            endDateInput.addEventListener('change', function() {
                if (this.value < startDateInput.value) startDateInput.value = this.value;
            });
            
            form.addEventListener('submit', (e) => {
                e.preventDefault();
                updateDashboard();
            });

            // Tải dữ liệu lần đầu
            if (initialReport) {
                updateUI(initialReport);
            }
        });
    </script>
</body>
</html>