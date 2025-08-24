<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<c:set var="pageTitle" value="Inventory Management" scope="request"/>
<c:set var="currentModule" value="stock" scope="request"/>
<c:set var="currentAction" value="stock-list" scope="request"/>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>${pageTitle} - Admin Panel</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css"/>
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
            .page-header h3 {
                margin: 0;
                font-size: 1.25rem;
                font-weight: 600;
            }
            .filter-bar {
                display: flex;
                gap: 16px;
                padding: 20px;
                background-color: #ffffff;
                border-radius: 8px;
                margin-bottom: 24px;
                box-shadow: 0 1px 3px rgba(0,0,0,0.05);
            }
            .list-container {
                background-color: #ffffff;
                padding: 24px;
                border-radius: 8px;
                box-shadow: 0 1px 3px rgba(0,0,0,0.05);
            }
            .products-table thead th {
                background-color: #f8f9fa;
                border-bottom: 2px solid #dee2e6;
                font-weight: 600;
                cursor: pointer;
            }
            .products-table td, .products-table th {
                vertical-align: middle;
            }
            .pagination .page-item .page-link {
                border-radius: 6px !important;
                margin: 0 4px;
                border: none;
            }
            .list-container .loading-overlay {
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
            .sort-icon {
                color: #ccc;
            }
            .sort-icon.active {
                color: #333;
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
                <div class="page-header">
                    <h3>Product List in Stock</h3>
                    <a href="${pageContext.request.contextPath}/PurchaseOrder?action=startNewPO" class="btn btn-success"><i class="fa-solid fa-plus"></i> New Purchase Order</a>
                </div>

                <form id="filterForm" class="filter-bar">
                    <div class="flex-grow-1">
                        <input id="searchTermInput" type="text" class="form-control" name="searchTerm" placeholder="Search by product name, SKU..." value="<c:out value='${searchTerm}'/>">
                    </div>
                    <div style="min-width: 200px;">
                        <select id="categorySelect" class="form-select" name="filterCategory">
                            <option value="all">All Categories</option>
                            <c:forEach var="cat" items="${categories}">
                                <option value="${cat.categoryId}" ${not empty filterCategory && cat.categoryId.toString() == filterCategory ? 'selected' : ''}>
                                    <c:out value="${cat.name}"/>
                                </option>

                            </c:forEach>
                        </select>
                    </div>
                    <button type="submit" class="btn btn-primary"><i class="fa-solid fa-search"></i> Filter</button>
                    <button type="button" id="clearFilterBtn" class="btn btn-secondary" title="Clear Filters"><i class="fa-solid fa-eraser"></i></button>
                </form>

                <div class="list-container position-relative">
                    <div id="loadingOverlay" class="loading-overlay" style="display: none;">
                        <div class="spinner-border text-primary" role="status"><span class="visually-hidden">Loading...</span></div>
                    </div>
                    <p id="resultsCount" class="mb-3"><strong>Showing ${displayList.size()} of ${totalItems} results.</strong></p>

                    <div class="table-responsive">
                        <table class="table table-hover products-table">
                            <thead>
                                <tr>
                                    <th data-sortby="sku">SKU <i class="fa-solid fa-sort sort-icon"></i></th>
                                    <th data-sortby="productName">Product Name <i class="fa-solid fa-sort sort-icon"></i></th>
                                    <th data-sortby="categoryName">Category <i class="fa-solid fa-sort sort-icon"></i></th>
                                    <th>Size</th>
                                    <th>Color</th>
                                    <th data-sortby="quantity">In Stock <i class="fa-solid fa-sort sort-icon"></i></th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody id="productTableBody">
                                <%-- Nội dung bảng ban đầu --%>
                                <c:choose>
                                    <c:when test="${not empty displayList}">
                                        <c:forEach var="item" items="${displayList}">
                                            <tr>
                                                <td><c:out value="${item.sku}"/></td>
                                                <td><c:out value="${item.productName}"/></td>
                                                <td><c:out value="${item.categoryName}"/></td>
                                                <td><c:out value="${item.size}"/></td>
                                                <td><c:out value="${item.color}"/></td>
                                                <td><c:out value="${item.quantity}"/></td>
                                                <td>
                                                    <button type="button" class="btn btn-info btn-sm action-btn"
                                                            data-bs-toggle="modal" data-bs-target="#productDetailModal"
                                                            data-variant-id="${item.variantId}" title="View Details">
                                                        <i class="fa-solid fa-eye"></i> View
                                                    </button>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr><td colspan="7" class="text-center p-4">No products found.</td></tr>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                        <nav id="paginationContainer" aria-label="Page navigation" class="mt-4 d-flex justify-content-center">
                            <%-- Nội dung phân trang ban đầu --%>
                            <c:if test="${totalPages > 1}">
                                <ul class="pagination">
                                    <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                                        <a class="page-link" href="#" data-page="${currentPage - 1}">&laquo;</a>
                                    </li>
                                    <c:forEach begin="1" end="${totalPages}" var="i">
                                        <li class="page-item ${currentPage == i ? 'active' : ''}">
                                            <a class="page-link" href="#" data-page="${i}">${i}</a>
                                        </li>
                                    </c:forEach>
                                    <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                        <a class="page-link" href="#" data-page="${currentPage + 1}">&raquo;</a>
                                    </li>
                                </ul>
                            </c:if>
                        </nav>
                    </div>
                </div>
            </main>
        </div>

        <%-- Modal hiển thị chi tiết sản phẩm --%>
        <div class="modal fade" id="productDetailModal" tabindex="-1" aria-labelledby="productDetailModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-xl modal-dialog-scrollable">
                <div class="modal-content">
                    <div class="modal-header"><h5 class="modal-title" id="productDetailModalLabel">Product Details</h5><button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button></div>
                    <div class="modal-body">
                        <div id="modal-loading" class="text-center p-5"><div class="spinner-border" role="status"><span class="visually-hidden">Loading...</span></div></div>
                        <div id="modal-content-area" class="d-none">
                            <div class="row">
                                <div class="col-md-6">
                                    <h4>Basic Information</h4>
                                    <ul class="list-group list-group-flush"><li class="list-group-item"><strong>Product Name:</strong> <span id="detail-product-name"></span></li><li class="list-group-item"><strong>Original Price:</strong> <span id="detail-price"></span></li><li class="list-group-item"><strong>Status:</strong> <span id="detail-status"></span></li></ul>
                                </div>
                                <div class="col-md-6">
                                    <h4>Variant & Inventory</h4>
                                    <ul class="list-group list-group-flush"><li class="list-group-item"><strong>SKU:</strong> <span id="detail-sku"></span></li><li class="list-group-item"><strong>Size:</strong> <span id="detail-size"></span></li><li class="list-group-item"><strong>Color:</strong> <span id="detail-color"></span></li><li class="list-group-item"><strong>In Stock:</strong> <span id="detail-quantity" class="fw-bold"></span></li></ul>
                                </div>
                            </div>
                            <hr>
                            <h4 class="mt-3">Inventory Change History</h4>
                            <div class="table-responsive">
                                <table class="table table-striped table-sm">
                                    <thead><tr><th>Timestamp</th><th>Change Type</th><th>Quantity Changed</th><th>Notes</th><th>Performed By</th></tr></thead>
                                    <tbody id="detail-history-body"></tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer"><button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button></div>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>

        <script>
            // SỬA LẠI: Gộp tất cả vào một hàm DOMContentLoaded duy nhất
            document.addEventListener('DOMContentLoaded', function () {
                const contextPath = '${pageContext.request.contextPath}';

                // --- Phần 1: Xử lý active sidebar menu ---
                const currentAction = "${requestScope.currentAction}";
                const currentModule = "${requestScope.currentModule}";
                document.querySelectorAll('.sidebar-menu li.active').forEach(li => li.classList.remove('active'));
                document.querySelectorAll('.sidebar-menu .treeview.menu-open').forEach(li => li.classList.remove('menu-open'));
                if (currentAction && currentModule) {
                    const activeLink = document.querySelector(`.sidebar-menu a[href*="\${currentAction}"][href*="\${currentModule}"]`);
                    if (activeLink) {
                        activeLink.parentElement.classList.add('active');
                        const parentTreeview = activeLink.closest('.treeview');
                        if (parentTreeview) {
                            parentTreeview.classList.add('active', 'menu-open');
                        }
                    }
                } else {
                    const dashboardLink = document.querySelector('.sidebar-menu a[href*="dashboard"]');
                    if (dashboardLink && !dashboardLink.closest('.treeview')) {
                        dashboardLink.parentElement.classList.add('active');
                    }
                }

                // --- Phần 2: Xử lý AJAX filter và Modal ---
                // === STATE MANAGEMENT ===
                let currentPage = 1;
                let currentSortBy = 'productName';
                let currentSortOrder = 'asc';

                // === ELEMENT REFERENCES ===
                const form = document.getElementById('filterForm');
                const searchTermInput = document.getElementById('searchTermInput');
                const categorySelect = document.getElementById('categorySelect');
                const clearBtn = document.getElementById('clearFilterBtn');
                const tableBody = document.getElementById('productTableBody');
                const paginationContainer = document.getElementById('paginationContainer');
                const resultsCount = document.getElementById('resultsCount');
                const loadingOverlay = document.getElementById('loadingOverlay');
                const sortHeaders = document.querySelectorAll('th[data-sortby]');
                const detailModal = document.getElementById('productDetailModal');

                // === MAIN AJAX FUNCTION ===
                function performSearch(page = 1) {
                    const searchTerm = searchTermInput.value;
                    const category = categorySelect.value;
                    currentPage = page;

                    const baseURL = contextPath + '/Stock';
                    const params = '?ajax=true' +
                            '&searchTerm=' + encodeURIComponent(searchTerm) +
                            '&filterCategory=' + category +
                            '&page=' + currentPage +
                            '&sortBy=' + currentSortBy +
                            '&sortOrder=' + currentSortOrder;
                    const finalURL = baseURL + params;

                    loadingOverlay.style.display = 'flex';
                    fetch(finalURL)
                            .then(response => response.ok ? response.json() : Promise.reject('Network response was not ok.'))
                            .then(data => {
                                updateTable(data.products);
                                updatePagination(data.currentPage, data.totalPages);
                                updateResultsCount(data.products.length, data.totalItems);
                                updateSortIcons();
                            })
                            .catch(error => console.error('Fetch error:', error))
                            .finally(() => {
                                loadingOverlay.style.display = 'none';
                            });
                }

                // === UI UPDATE FUNCTIONS ===
                function updateTable(products) {
                    tableBody.innerHTML = '';
                    if (products && products.length > 0) {
                        products.forEach(item => {
                            const rowHTML = '<tr><td>' + (item.sku || '') + '</td><td>' + (item.productName || '') + '</td><td>' + (item.categoryName || '') + '</td><td>' + (item.size || '') + '</td><td>' + (item.color || '') + '</td><td>' + (item.quantity || 0) + '</td><td><button type="button" class="btn btn-info btn-sm action-btn" data-bs-toggle="modal" data-bs-target="#productDetailModal" data-variant-id="' + item.variantId + '" title="View Details"><i class="fa-solid fa-eye"></i> View</button></td></tr>';
                            tableBody.insertAdjacentHTML('beforeend', rowHTML);
                        });
                    } else {
                        tableBody.innerHTML = '<tr><td colspan="7" class="text-center p-4">No products found.</td></tr>';
                    }
                }

                function updatePagination(cPage, tPages) {
                    paginationContainer.innerHTML = '';
                    if (tPages > 1) {
                        let html = '<ul class="pagination">';
                        html += '<li class="page-item ' + (cPage === 1 ? 'disabled' : '') + '"><a class="page-link" href="#" data-page="' + (cPage - 1) + '">&laquo;</a></li>';
                        for (let i = 1; i <= tPages; i++) {
                            html += '<li class="page-item ' + (i === cPage ? 'active' : '') + '"><a class="page-link" href="#" data-page="' + i + '">' + i + '</a></li>';
                        }
                        html += '<li class="page-item ' + (cPage === tPages ? 'disabled' : '') + '"><a class="page-link" href="#" data-page="' + (cPage + 1) + '">&raquo;</a></li>';
                        html += '</ul>';
                        paginationContainer.innerHTML = html;
                    }
                }

                function updateResultsCount(displayCount, totalCount) {
                    resultsCount.innerHTML = '<strong>Showing ' + displayCount + ' of ' + totalCount + ' results.</strong>';
                }

                function updateSortIcons() {
                    sortHeaders.forEach(header => {
                        const icon = header.querySelector('.sort-icon');
                        icon.classList.remove('fa-sort-up', 'fa-sort-down', 'active');
                        icon.classList.add('fa-sort');
                        if (header.dataset.sortby === currentSortBy) {
                            icon.classList.remove('fa-sort');
                            icon.classList.add(currentSortOrder === 'asc' ? 'fa-sort-up' : 'fa-sort-down', 'active');
                        }
                    });
                }

                // === EVENT LISTENERS ===
                if (form)
                    form.addEventListener('submit', e => {
                        e.preventDefault();
                        performSearch(1);
                    });
                if (clearBtn)
                    clearBtn.addEventListener('click', e => {
                        e.preventDefault();
                        searchTermInput.value = '';
                        categorySelect.value = 'all';
                        performSearch(1);
                    });
                if (paginationContainer)
                    paginationContainer.addEventListener('click', e => {
                        if (e.target.matches('a.page-link')) {
                            e.preventDefault();
                            const page = parseInt(e.target.dataset.page);
                            if (page && page >= 1 && page <= parseInt(paginationContainer.querySelector('li:nth-last-child(2) a').dataset.page)) {
                                performSearch(page);
                            }
                        }
                    });
                sortHeaders.forEach(header => {
                    header.addEventListener('click', e => {
                        e.preventDefault();
                        const sortBy = header.dataset.sortby;
                        if (currentSortBy === sortBy) {
                            currentSortOrder = currentSortOrder === 'asc' ? 'desc' : 'asc';
                        } else {
                            currentSortBy = sortBy;
                            currentSortOrder = 'asc';
                        }
                        performSearch(1);
                    });
                });

                if (detailModal) {
                    detailModal.addEventListener('show.bs.modal', function (event) {
                        const button = event.relatedTarget;
                        const selectedVariantId = button.getAttribute('data-variant-id');
                        const modalTitle = detailModal.querySelector('.modal-title');
                        const modalLoading = document.getElementById('modal-loading');
                        const modalContent = document.getElementById('modal-content-area');
                        const historyBody = document.getElementById('detail-history-body');

                        modalTitle.textContent = 'Loading Product Details...';
                        modalLoading.classList.remove('d-none');
                        modalContent.classList.add('d-none');
                        historyBody.innerHTML = '';

                        if (!selectedVariantId) {
                            modalTitle.textContent = 'Error';
                            modalLoading.innerHTML = '<p class="text-danger">Could not get Product ID.</p>';
                            return;
                        }
                        const baseURL = contextPath + '/StockDetail';
                        const finalURL = baseURL + "?variantId=" + selectedVariantId + "&ajax=true";
                        fetch(finalURL)
                                .then(response => response.ok ? response.json() : Promise.reject(response))
                                .then(data => {
                                    if (!data.product)
                                        throw new Error('Associated product data not found in response.');
                                    modalTitle.textContent = 'Product Details: ' + (data.variant.sku || '');
                                    document.getElementById('detail-product-name').textContent = data.product.name || 'N/A';
                                    document.getElementById('detail-price').textContent = data.product.price || 'N/A';
                                    document.getElementById('detail-status').textContent = data.product.status || 'N/A';
                                    document.getElementById('detail-sku').textContent = data.variant.sku || 'N/A';
                                    document.getElementById('detail-size').textContent = data.variant.size || 'N/A';
                                    document.getElementById('detail-color').textContent = data.variant.color || 'N/A';
                                    document.getElementById('detail-quantity').textContent = data.inventory.quantity;
                                    if (data.movementHistory && data.movementHistory.length > 0) {
                                        data.movementHistory.forEach(movement => {
                                            const quantityChanged = movement.quantityChanged > 0 ? '+' + movement.quantityChanged : movement.quantityChanged;
                                            const quantityClass = movement.quantityChanged > 0 ? 'text-success' : 'text-danger';
                                            const rowHTML = '<tr><td>' + (movement.createdAtFormatted || 'N/A') + '</td><td><span class="badge bg-info">' + (movement.movementType || 'N/A') + '</span></td><td><strong class="' + quantityClass + '">' + quantityChanged + '</strong></td><td>' + (movement.notes || '') + '</td><td>' + (movement.staffName || 'N/A') + '</td></tr>';
                                            historyBody.insertAdjacentHTML('beforeend', rowHTML);
                                        });
                                    } else {
                                        historyBody.innerHTML = '<tr><td colspan="5" class="text-center">No history found.</td></tr>';
                                    }
                                    modalLoading.classList.add('d-none');
                                    modalContent.classList.remove('d-none');
                                })
                                .catch(error => {
                                    console.error('Error fetching product details:', error);
                                    modalTitle.textContent = 'Error';
                                    modalLoading.innerHTML = '<p class="text-danger text-center">Failed to load product details.</p>';
                                });
                    });
                }
            });
        </script>
    </body>
</html>