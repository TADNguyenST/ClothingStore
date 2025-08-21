<%@ page isELIgnored="false" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<c:set var="pageTitle" value="Stock History" scope="request"/>
<c:set var="currentModule" value="stock" scope="request"/>
<c:set var="currentAction" value="stock-history" scope="request"/>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>${pageTitle} - Admin Panel</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css"/>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/daterangepicker/daterangepicker.css"/>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/admin-dashboard/css/admin-css.css">
        <style>
            body {
                background-color: #f4f6f9;
            }
            .content-area {
                padding: 24px;
            }
            .page-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 16px 24px;
                background-color: #4A90E2;
                color: white;
                border-radius: 8px;
                margin-bottom: 24px;
            }
            .filter-form {
                display: flex;
                flex-wrap: wrap;
                gap: 15px;
                align-items: flex-end;
                padding: 20px;
                background-color: #ffffff;
                border-radius: 8px;
                margin-bottom: 24px;
                box-shadow: 0 1px 3px rgba(0,0,0,0.05);
            }
            .results-container {
                background-color: #ffffff;
                padding: 24px;
                border-radius: 8px;
                box-shadow: 0 1px 3px rgba(0,0,0,0.05);
            }
            .table thead th {
                background-color: #f8f9fa;
            }
            .accordion-button:not(.collapsed) {
                background-color: #e7f1ff;
                color: #0c63e4;
            }
            .loading-overlay {
                position: absolute;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background: rgba(255, 255, 255, 0.7);
                z-index: 10;
                display: flex;
                align-items: center;
                justify-content: center;
            }
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
        <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp"/>
        <div class="main-content-wrapper">
           
            <main class="content-area">
                <div class="page-header"><h3>Inventory Change History</h3></div>

                <form id="filterForm" class="filter-form">
                    <div>
                        <label for="dateRangePicker" class="form-label fw-bold">Date Range</label>
                        <input type="text" id="dateRangePicker" class="form-control">
                        <input type="hidden" name="startDate" id="startDate" value="${startDate}">
                        <input type="hidden" name="endDate" id="endDate" value="${endDate}">
                    </div>
                    <div>
                        <label for="groupBy" class="form-label fw-bold">Change Type</label>
                        <select name="groupBy" id="groupBy" class="form-select">
                            <option value="all_references" ${groupBy == 'all_references' ? 'selected' : ''}>All References</option>
                            <option value="purchase_order" ${groupBy == 'purchase_order' ? 'selected' : ''}>Purchase Order</option>
                            <option value="sale_order" ${groupBy == 'sale_order' ? 'selected' : ''}>Sale Order</option>
                            <option value="adjustment" ${groupBy == 'adjustment' ? 'selected' : ''}>Adjustment</option>
                        </select>
                    </div>
                    <div class="flex-grow-1">
                        <label for="searchInput" class="form-label fw-bold">Search Product/SKU</label>
                        <input type="text" id="searchInput" name="searchTerm" class="form-control" placeholder="Enter product name or SKU..." value="${searchTerm}">
                    </div>
                    <div class="ms-auto">
                        <button type="submit" class="btn btn-primary"><i class="fa-solid fa-search"></i> Apply</button>
                        <a href="StockMovement" class="btn btn-secondary"><i class="fa-solid fa-eraser"></i> Clear</a>
                    </div>
                </form>

                <div class="results-container position-relative">
                    <div id="loadingOverlay" class="loading-overlay d-none">
                        <div class="spinner-border text-primary" role="status"></div>
                    </div>
                    <p id="resultsCount" class="mb-3">Total Records: <strong id="totalRecords">${totalRecords}</strong></p>
                    <div id="resultsContent">
                        <c:choose>
                            <c:when test="${not empty groupBy && groupBy ne 'none'}">
                                <div class="accordion">
                                    <c:forEach var="entry" items="${groupedData}" varStatus="loop">
                                        <div class="accordion-item">
                                            <h2 class="accordion-header">
                                                <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#collapse-${loop.index}">
                                                    <strong>Order/Ref: ${entry.key}</strong>&nbsp;(${entry.value.size()} items)
                                                </button>
                                            </h2>
                                            <div id="collapse-${loop.index}" class="accordion-collapse collapse">
                                                <div class="accordion-body">
                                                    <ul class="list-group">
                                                        <c:forEach var="move" items="${entry.value}">
                                                            <li class="list-group-item d-flex justify-content-between align-items-center">
                                                                <div>
                                                                    <strong>${move.productName}</strong> (${move.sku})
                                                                    <br><small class="text-muted">${move.size}, ${move.color}</small>
                                                                </div>
                                                                <span class="badge ${move.quantityChanged > 0 ? 'text-success' : 'text-danger'} rounded-pill">
                                                                    ${move.quantityChanged > 0 ? '+' : ''}${move.quantityChanged}
                                                                </span>
                                                            </li>
                                                        </c:forEach>
                                                    </ul>
                                                </div>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <table class="table table-striped table-hover">
                                    <thead><tr><th>Timestamp</th><th>Product</th><th>SKU</th><th>Type</th><th>Quantity</th><th>Notes</th><th>Staff</th><th>Action</th></tr></thead>
                                    <tbody>
                                        <c:forEach var="move" items="${movementList}">
                                            <%-- Trong vòng lặp c:forEach của file stock-movements.jsp --%>
                                            <tr>
                                                <td><c:out value="${move.createdAtFormatted}" default="N/A"/></td>
                                                <td>
                                                    <c:out value="${move.productName}" default="Unknown"/> 
                                                    (<c:out value="${move.size}" default="N/A"/>, <c:out value="${move.color}" default="N/A"/>)
                                                </td>
                                                <td><c:out value="${move.sku}" default="N/A"/></td>
                                                <td>
                                                    <c:if test="${not empty move.movementType}">
                                                        <span class="badge bg-info"><c:out value="${move.movementType}"/></span>
                                                    </c:if>
                                                </td>
                                                <td>
                                                    <strong class="${move.quantityChanged > 0 ? 'text-success' : 'text-danger'}">
                                                        ${move.quantityChanged > 0 ? '+' : ''}<c:out value="${move.quantityChanged}"/>
                                                    </strong>
                                                </td>
                                                <td><c:out value="${move.notes}" default=""/></td>
                                                <td><c:out value="${move.staffName}" default="System"/></td>
                                                <td>
                                                    <a href="${pageContext.request.contextPath}/StockDetail?variantId=${move.variantId}" class="btn btn-sm btn-outline-primary">Details</a>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <nav id="paginationContainer" class="mt-4 d-flex justify-content-center"></nav>
                </div>

            </main>
        </div>

        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/moment@2.29.4/moment.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/daterangepicker/daterangepicker.min.js"></script> 
        <script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>

        <script>
            document.addEventListener('DOMContentLoaded', function () {
                // --- KHAI BÁO BIẾN ---
                var contextPath = '${pageContext.request.contextPath}';
                var filterForm = document.getElementById('filterForm');
                var resultsContent = document.getElementById('resultsContent');
                var paginationContainer = document.getElementById('paginationContainer');
                var totalRecordsSpan = document.getElementById('totalRecords');
                var loadingOverlay = document.getElementById('loadingOverlay');

                // --- HÀM GỌI AJAX ---
                function performFilter(page) {
                    if (page === void 0) {
                        page = 1;
                    }
                    var params = new URLSearchParams(new FormData(filterForm));
                    params.append('ajax', 'true');
                    params.set('page', page);

                    loadingOverlay.classList.remove('d-none');
                    var url = contextPath + '/StockMovement?' + params.toString();

                    console.log("Requesting URL:", url); // DEBUG: In ra URL đang được gọi

                    fetch(url)
                            .then(function (response) {
                                if (!response.ok) {
                                    throw new Error('Network response was not ok. Status: ' + response.status);
                                }
                                return response.json();
                            })
                            .then(function (result) {
                                console.log("Received data from server:", result); // DEBUG: In ra dữ liệu nhận được

                                totalRecordsSpan.textContent = result.totalRecords;

                                if (result.viewMode === 'grouped') {
                                    renderGroupedView(result.data);
                                    // Khi group by, không hiển thị phân trang
                                    paginationContainer.innerHTML = '';
                                } else {
                                    renderListView(result.data);
                                    updatePagination(result.currentPage, result.totalPages);
                                }
                            })
                            .catch(function (error) {
                                console.error('Filter error:', error);
                                resultsContent.innerHTML = '<div class="alert alert-danger">Failed to load data. Please try again.</div>';
                            })
                            .finally(function () {
                                loadingOverlay.classList.add('d-none');
                            });
                }

                // --- CÁC HÀM RENDER ---
                function renderListView(movements) {
                    var tableHeader = '<table class="table table-striped table-hover">' +
                            '<thead><tr><th>Timestamp</th><th>Product</th><th>SKU</th><th>Type</th><th>Quantity</th><th>Notes</th><th>Staff</th><th>Action</th></tr></thead>' +
                            '<tbody>';
                    var tableFooter = '</tbody></table>';
                    var tableRows = '';

                    if (movements && movements.length > 0) {
                        movements.forEach(function (move) {
                            var quantityClass = move.quantityChanged > 0 ? 'text-success' : 'text-danger';
                            var quantityPrefix = move.quantityChanged > 0 ? '+' : '';

                            tableRows += '<tr>' +
                                    '<td>' + (move.createdAtFormatted || '') + '</td>' +
                                    '<td>' + (move.productName || 'N/A') + ' (' + (move.size || 'N/A') + ', ' + (move.color || 'N/A') + ')</td>' +
                                    '<td>' + (move.sku || '') + '</td>' +
                                    '<td><span class="badge bg-info">' + (move.movementType || '') + '</span></td>' +
                                    '<td><strong class="' + quantityClass + '">' + quantityPrefix + move.quantityChanged + '</strong></td>' +
                                    '<td>' + (move.notes || '') + '</td>' +
                                    '<td>' + (move.staffName || 'System') + '</td>' +
                                    '<td><a href="' + contextPath + '/StockDetail?variantId=' + move.variantId + '" class="btn btn-sm btn-outline-primary">Details</a></td>' +
                                    '</tr>';
                        });
                    } else {
                        tableRows = '<tr><td colspan="8" class="text-center p-4">No movements found for the selected criteria.</td></tr>';
                    }

                    resultsContent.innerHTML = tableHeader + tableRows + tableFooter;
                }

                function renderGroupedView(groupedData) {
                    if (!groupedData || Object.keys(groupedData).length === 0) {
                        resultsContent.innerHTML = '<p class="text-center p-4">No data found for the selected grouping criteria.</p>';
                        return;
                    }

                    var html = '<div class="accordion">';
                    var index = 0;
                    for (var groupKey in groupedData) {
                        if (groupedData.hasOwnProperty(groupKey)) {
                            var movements = groupedData[groupKey];
                            var collapseId = 'collapse-' + index;

                            var listItemsHtml = movements.map(function (move) {
                                var quantityClass = move.quantityChanged > 0 ? 'text-success' : 'text-danger';
                                var quantityPrefix = move.quantityChanged > 0 ? '+' : '';
                                return (
                                        '<li class="list-group-item d-flex justify-content-between align-items-center">' +
                                        '    <div>' +
                                        '        <strong>' + (move.productName || '') + '</strong> (' + (move.sku || '') + ')' +
                                        '        <br><small class="text-muted">' + (move.size || '') + ', ' + (move.color || '') + '</small>' +
                                        '    </div>' +
                                        '    <span class="badge ' + quantityClass + ' rounded-pill">' + quantityPrefix + move.quantityChanged + '</span>' +
                                        '</li>'
                                        );
                            }).join('');

                            html +=
                                    '<div class="accordion-item">' +
                                    '    <h2 class="accordion-header">' +
                                    '        <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#' + collapseId + '">' +
                                    '            <strong>Order/Ref: ' + groupKey + '</strong>&nbsp;<span class="badge bg-secondary ms-2">' + movements.length + ' items</span>' +
                                    '        </button>' +
                                    '    </h2>' +
                                    '    <div id="' + collapseId + '" class="accordion-collapse collapse">' +
                                    '        <div class="accordion-body">' +
                                    '            <ul class="list-group">' + listItemsHtml + '</ul>' +
                                    '        </div>' +
                                    '    </div>' +
                                    '</div>';
                            index++;
                        }
                    }
                    html += '</div>';
                    resultsContent.innerHTML = html;
                }

                function updatePagination(cPage, tPages) {
                    paginationContainer.innerHTML = '';
                    if (tPages > 1) {
                        var html = '<ul class="pagination">';
                        // Nút Previous
                        html += '<li class="page-item ' + (cPage === 1 ? 'disabled' : '') + '"><a class="page-link" href="#" data-page="' + (cPage - 1) + '">&laquo;</a></li>';

                        // Các nút số trang
                        for (var i = 1; i <= tPages; i++) {
                            html += '<li class="page-item ' + (i === cPage ? 'active' : '') + '"><a class="page-link" href="#" data-page="' + i + '">' + i + '</a></li>';
                        }

                        // Nút Next
                        html += '<li class="page-item ' + (cPage === tPages ? 'disabled' : '') + '"><a class="page-link" href="#" data-page="' + (cPage + 1) + '">&raquo;</a></li>';

                        html += '</ul>';
                        paginationContainer.innerHTML = html;
                    }
                }

                // --- KHỞI TẠO & GẮN SỰ KIỆN ---
                var startDateInput = $('#startDate');
                var endDateInput = $('#endDate');
                $('#dateRangePicker').daterangepicker({
                    opens: 'left', autoUpdateInput: false, locale: {format: 'DD/MM/YYYY', cancelLabel: 'Clear'},
                    ranges: {'Today': [moment(), moment()], 'Last 7 Days': [moment().subtract(6, 'days'), moment()], 'Last 30 Days': [moment().subtract(29, 'days'), moment()]}
                });
                if (startDateInput.val() && endDateInput.val()) {
                    var start = moment(startDateInput.val(), 'YYYY-MM-DD');
                    var end = moment(endDateInput.val(), 'YYYY-MM-DD');
                    $('#dateRangePicker').val(start.format('DD/MM/YYYY') + ' - ' + end.format('DD/MM/YYYY'));
                }
                $('#dateRangePicker').on('apply.daterangepicker', function (ev, picker) {
                    $(this).val(picker.startDate.format('DD/MM/YYYY') + ' - ' + picker.endDate.format('DD/MM/YYYY'));
                    startDateInput.val(picker.startDate.format('YYYY-MM-DD'));
                    endDateInput.val(picker.endDate.format('YYYY-MM-DD'));
                }).on('cancel.daterangepicker', function (ev, picker) {
                    $(this).val('');
                    startDateInput.val('');
                    endDateInput.val('');
                });

                filterForm.addEventListener('submit', function (e) {
                    e.preventDefault();
                    performFilter(1);
                });

                paginationContainer.addEventListener('click', function (e) {
                    if (e.target.matches('a.page-link')) {
                        e.preventDefault();
                        var page = parseInt(e.target.dataset.page);
                        if (page)
                            performFilter(page);
                    }
                });

                // Tải dữ liệu lần đầu tiên dựa trên các tham số có sẵn trên URL (nếu có)
                var initialPage = ${not empty currentPage ? currentPage : 1};
                performFilter(initialPage);
            });
        </script>
    </body>
</html>