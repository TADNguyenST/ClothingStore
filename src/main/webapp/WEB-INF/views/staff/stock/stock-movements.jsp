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
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>${pageTitle} - Admin Panel</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css"/>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/daterangepicker/daterangepicker.css"/>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/admin-dashboard/css/admin-css.css">
        <style>
            body {
                background-color: #f5f7fa;
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            }
            .main-content-wrapper {
                padding: 20px;
                max-width: 1200px;
                margin: 0 auto;
            }
            .content-area {
                background: white;
                border-radius: 10px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
                padding: 20px;
            }
            .box-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding-bottom: 15px;
                border-bottom: 1px solid #e9ecef;
            }
            .box-title {
                font-size: 1.5rem;
                font-weight: 600;
                color: #2c3e50;
            }
            .table th {
                background-color: #f8f9fa;
                color: #495057;
                font-weight: 500;
            }
            .table-hover tbody tr:hover {
                background-color: #f1f3f5;
            }
            .btn-info {
                background-color: #17a2b8;
                border: none;
                padding: 6px 12px;
                border-radius: 5px;
                font-size: 0.85rem;
                transition: background-color 0.2s;
            }
            .btn-info:hover {
                background-color: #138496;
            }
            .badge {
                font-size: 0.85rem;
                padding: 6px 12px;
                border-radius: 12px;
            }
            .search-container {
                max-width: 300px;
            }
            .filter-container {
                max-width: 250px;
            }
            .pagination {
                margin-top: 20px;
            }
            .page-link {
                border-radius: 5px;
                color: #007bff;
            }
            .page-item.active .page-link {
                background-color: #007bff;
                border-color: #007bff;
            }
            #dateRangePicker {
                width: 100%;
                border-radius: 5px;
            }
            .time-period-display {
                font-size: 1rem;
                color: #495057;
                margin-bottom: 15px;
                background-color: #e9ecef;
                padding: 10px;
                border-radius: 5px;
            }
            .daterangepicker .ranges li.active {
                background-color: #007bff;
                color: white;
            }
        </style>
    </head>
    <body>
        <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp"/>
        <div class="main-content-wrapper">
            <jsp:include page="/WEB-INF/includes/admin-header.jsp"/>
            <main class="content-area">
                <div class="box">
                    <div class="box-header">
                        <h3 class="box-title">Inventory Change History</h3>
                    </div>
                    <div class="box-body">
                        <div class="d-flex justify-content-between mb-4">
                            <div class="filter-container">
                                <input type="text" id="dateRangePicker" class="form-control" placeholder="Select time period...">
                            </div>
                            <div class="search-container">
                                <input type="text" id="searchInput" class="form-control" placeholder="Search by product or SKU..." onkeyup="filterTable()">
                            </div>
                            <div class="filter-container">
                                <select name="filterType" id="filterType" class="form-select" onchange="applyTypeFilter()">
                                    <option value="all" ${empty param.filterType || param.filterType == 'all' ? 'selected' : ''}>-- All Change Types --</option>
                                    <option value="In" ${param.filterType == 'In' ? 'selected' : ''}>Stock In</option>
                                    <option value="Out" ${param.filterType == 'Out' ? 'selected' : ''}>Stock Out</option>
                                    <option value="Adjustment" ${param.filterType == 'Adjustment' ? 'selected' : ''}>Adjustment</option>
                                </select>
                            </div>
                        </div>
                        <div class="table-responsive">
                            <table class="table table-bordered table-striped table-sm" id="movementTable">
                                <thead>
                                    <tr>
                                        <th>Timestamp</th>
                                        <th>Product</th>
                                        <th>SKU</th>
                                        <th>Change Type</th>
                                        <th>Quantity</th>
                                        <th>Notes</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="move" items="${movementList}">
                                        <tr>
                                            <td>
                                                <c:if test="${not empty move.createdAt}">
                                                    <fmt:parseDate value="${move.createdAt}" pattern="yyyy-MM-dd'T'HH:mm:ss" var="parsedDateTime" type="both"/>
                                                    <fmt:formatDate value="${parsedDateTime}" pattern="HH:mm:ss dd/MM/yyyy"/>
                                                </c:if>
                                            </td>
                                            <td><c:out value="${move.productName}"/> (<c:out value="${move.size}"/>, <c:out value="${move.color}"/>)</td>
                                            <td><c:out value="${move.sku}"/></td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${move.movementType == 'In'}"><span class="badge bg-success">Stock In</span></c:when>
                                                    <c:when test="${move.movementType == 'Out'}"><span class="badge bg-danger">Stock Out</span></c:when>
                                                    <c:when test="${move.movementType == 'Adjustment'}"><span class="badge bg-warning text-dark">Adjustment</span></c:when>
                                                    <c:otherwise><c:out value="${move.movementType}"/></c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <strong class="${move.quantityChanged > 0 ? 'text-success' : 'text-danger'}">
                                                    ${move.quantityChanged > 0 ? '+' : ''}<c:out value="${move.quantityChanged}"/>
                                                </strong>
                                            </td>
                                            <td><c:out value="${move.notes}"/></td>
                                            <td>
                                                <a href="${pageContext.request.contextPath}/StockDetail?variantId=${move.variantId}" class="btn btn-info btn-xs ms-1">
                                                    <i class="fa-solid fa-eye"></i> Details
                                                </a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>

                        <nav aria-label="Page navigation">
                            <ul class="pagination justify-content-center">

                                <%-- Nút Previous --%>
                                <c:url var="prevUrl" value="StockMovement">
                                    <c:param name="page" value="${currentPage - 1}"/>
                                    <c:if test="${not empty param.startDate}"><c:param name="startDate" value="${param.startDate}"/></c:if>
                                    <c:if test="${not empty param.endDate}"><c:param name="endDate" value="${param.endDate}"/></c:if>
                                </c:url>
                                <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                                    <a class="page-link" href="${prevUrl}">Previous</a>
                                </li>

                                <%-- Các nút số trang --%>
                                <c:forEach begin="1" end="${totalPages}" var="i">
                                    <c:url var="pageUrl" value="StockMovement">
                                        <c:param name="page" value="${i}"/>
                                        <c:if test="${not empty param.startDate}"><c:param name="startDate" value="${param.startDate}"/></c:if>
                                        <c:if test="${not empty param.endDate}"><c:param name="endDate" value="${param.endDate}"/></c:if>
                                    </c:url>
                                    <li class="page-item ${currentPage == i ? 'active' : ''}">
                                        <a class="page-link" href="${pageUrl}">${i}</a>
                                    </li>
                                </c:forEach>

                                <%-- Nút Next --%>
                                <c:url var="nextUrl" value="StockMovement">
                                    <c:param name="page" value="${currentPage + 1}"/>
                                    <c:if test="${not empty param.startDate}"><c:param name="startDate" value="${param.startDate}"/></c:if>
                                    <c:if test="${not empty param.endDate}"><c:param name="endDate" value="${param.endDate}"/></c:if>
                                    <c:if test="${not empty param.filterType}"><c:param name="filterType" value="${param.filterType}"/></c:if>
                                </c:url>
                                <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                    <a class="page-link" href="${nextUrl}">Next</a>
                                </li>
                            </ul>
                        </nav>
                    </div>
                </div>
            </main>
        </div>
        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/moment@2.29.4/moment.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/daterangepicker/daterangepicker.min.js"></script>
        <script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>
        <script>
                                    // Hàm filter table bằng ô tìm kiếm (giữ nguyên)

                                    function filterTable() {
                                        const searchInput = document.getElementById('searchInput').value.toLowerCase();
                                        const table = document.getElementById('movementTable');
                                        const rows = table.getElementsByTagName('tr');

                                        for (let i = 1; i < rows.length; i++) {
                                            const cells = rows[i].getElementsByTagName('td');
                                            let match = false;
                                            // Chỉ tìm kiếm ở cột Product và SKU (cột thứ 2 và 3)
                                            for (let j of [1, 2]) {
                                                if (cells[j].textContent.toLowerCase().includes(searchInput)) {
                                                    match = true;
                                                    break;
                                                }
                                            }
                                            rows[i].style.display = match ? '' : 'none';
                                        }
                                    }
                                    function applyTypeFilter() {
                                        const selectedType = document.getElementById('filterType').value;

                                        // Lấy các tham số hiện tại trên URL
                                        const urlParams = new URLSearchParams(window.location.search);

                                        // Đặt lại trang về 1 khi áp dụng bộ lọc mới
                                        urlParams.set('page', '1');

                                        // Cập nhật hoặc xóa tham số filterType
                                        if (selectedType && selectedType !== 'all') {
                                            urlParams.set('filterType', selectedType);
                                        } else {
                                            urlParams.delete('filterType');
                                        }

                                        // Chuyển hướng đến URL mới
                                        window.location.href = window.location.pathname + '?' + urlParams.toString();
                                    }


                                    // Khởi tạo và xử lý DateRangePicker
                                    $(function () {
                                        // Lấy các tham số ngày tháng từ URL hiện tại (nếu có)
                                        const urlParams = new URLSearchParams(window.location.search);
                                        const startDateParam = urlParams.get('startDate');
                                        const endDateParam = urlParams.get('endDate');

                                        // Khởi tạo DateRangePicker
                                        $('#dateRangePicker').daterangepicker({
                                            opens: 'left',
                                            locale: {
                                                format: 'DD/MM/YYYY',
                                                cancelLabel: 'Clear'
                                            },
                                            ranges: {
                                                'Today': [moment(), moment()],
                                                'Last 7 Days': [moment().subtract(6, 'days'), moment()],
                                                'Last 30 Days': [moment().subtract(29, 'days'), moment()],
                                                'This Month': [moment().startOf('month'), moment().endOf('month')],
                                                'Last Month': [moment().subtract(1, 'month').startOf('month'), moment().subtract(1, 'month').endOf('month')]
                                            },
                                            autoUpdateInput: false,
                                            showDropdowns: true
                                        });

                                        // Hàm cập nhật dòng chữ hiển thị khoảng thời gian
                                        function updateTimePeriodDisplay(start, end) {
                                            let displayText = 'All Time';
                                            if (start && end) {
                                                displayText = `${start.format('DD/MM/YYYY')} - ${end.format('DD/MM/YYYY')}`;
                                                            }
                                                            $('#timePeriodDisplay').text(`Showing results for: ${displayText}`);
                                                        }

                                                        // Thiết lập giá trị ban đầu cho date picker nếu có trong URL
                                                        if (startDateParam && endDateParam) {
                                                            const start = moment(startDateParam, 'YYYY-MM-DD');
                                                            const end = moment(endDateParam, 'YYYY-MM-DD');
                                                            $('#dateRangePicker').val(start.format('DD/MM/YYYY') + ' - ' + end.format('DD/MM/YYYY'));
                                                            updateTimePeriodDisplay(start, end);
                                                        } else {
                                                            updateTimePeriodDisplay(null, null);
                                                        }

                                                        // Xử lý sự kiện khi người dùng chọn ngày và bấm "Apply"
                                                        $('#dateRangePicker').on('apply.daterangepicker', function (ev, picker) {
                                                            const startDate = picker.startDate.format('YYYY-MM-DD');
                                                            const endDate = picker.endDate.format('YYYY-MM-DD');

                                                            // Lấy giá trị filterType hiện tại
                                                            const filterType = $('#filterType').val();

                                                            // Xây dựng URL mới, giữ lại filterType nếu có
                                                            const currentParams = new URLSearchParams(window.location.search);
                                                            currentParams.set('page', '1');
                                                            currentParams.set('startDate', startDate);
                                                            currentParams.set('endDate', endDate);

                                                            if (filterType && filterType !== 'all') {
                                                                currentParams.set('filterType', filterType);
                                                            } else {
                                                                currentParams.delete('filterType');
                                                            }

                                                            window.location.href = window.location.pathname + '?' + currentParams.toString();
                                                        });

                                                        // Xử lý sự kiện khi người dùng bấm "Cancel" hoặc "Clear"
                                                        $('#dateRangePicker').on('cancel.daterangepicker', function (ev, picker) {
                                                            $(this).val('');

                                                            const currentParams = new URLSearchParams(window.location.search);
                                                            currentParams.set('page', '1');
                                                            currentParams.delete('startDate');
                                                            currentParams.delete('endDate');

                                                            // Vẫn giữ lại filterType khi xóa bộ lọc ngày
                                                            window.location.href = window.location.pathname + '?' + currentParams.toString();
                                                        });
                                                    });
        </script>
    </body>
</html>