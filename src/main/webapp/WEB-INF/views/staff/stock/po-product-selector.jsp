<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:set var="pageTitle" value="Select Products" scope="request"/>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>${pageTitle}</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet">
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
            .table {
                margin-top: 20px;
            }
            .table th, .table td {
                vertical-align: middle;
            }
            .table th {
                background-color: #f8f9fa;
                color: #495057;
                font-weight: 500;
            }
            .table-hover tbody tr:hover {
                background-color: #f1f3f5;
            }
            .btn-primary {
                background-color: #007bff;
                border: none;
                padding: 8px 20px;
                border-radius: 5px;
                transition: background-color 0.2s;
            }
            .btn-primary:hover {
                background-color: #0056b3;
            }
            .search-container {
                max-width: 300px;
            }
            .back-link {
                color: #6c757d;
                text-decoration: none;
                font-size: 0.9rem;
            }
            .back-link:hover {
                color: #007bff;
                text-decoration: underline;
            }
            /* CSS mới cho nút "Add" */
            .add-btn.selected {
                background-color: #28a745; /* Màu xanh lá khi được chọn */
                border-color: #28a745;
                color: white;
            }
        </style>
    </head>
    <body>
        <div class="main-content-wrapper">
            <main class="content-area">
                <div class="box">
                    <div class="box-header">
                        <h3 class="box-title">Select Products for PO #${poId}</h3>
                        <a href="PurchaseOrder?action=edit&poId=${poId}" class="back-link"><i class="fas fa-arrow-left me-1"></i>Back to Purchase Order</a>
                    </div>
                    <div class="box-body">
                        <%-- Form vẫn cần thiết để gửi dữ liệu đi --%>
                        <form action="PurchaseOrder" method="post" id="productForm">
                            <input type="hidden" name="action" value="addProducts">
                            <input type="hidden" name="poId" value="${poId}">
                            
                            <%-- Container cho các input hidden sẽ được JS tạo ra --%>
                            <div id="hidden-inputs-container"></div>

                            <div class="d-flex justify-content-between align-items-center mb-4">
                                <%-- Nút này giờ là type="button" và được xử lý bởi JS --%>
                                <button type="button" id="submitSelectionBtn" class="btn btn-primary">
                                    <i class="fas fa-plus me-1"></i>Add Selected Products
                                </button>
                                <div class="search-container">
                                    <input type="text" id="searchInput" class="form-control" placeholder="Search products..." onkeyup="filterTable()">
                                </div>
                            </div>

                            <table class="table table-bordered table-hover" id="productTable">
                                <thead>
                                    <tr>
                                        <th>Product</th>
                                        <th>SKU</th>
                                        <th>Size / Color</th>
                                        <th>Current Stock</th>
                                        <th style="width: 120px;">Action</th> <%-- Chuyển cột Action sang phải --%>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="item" items="${productDataList}">
                                        <tr>
                                            <td>${item.get("productName")}</td>
                                            <td>${item.get("sku")}</td>
                                            <td>${item.get("size")} / ${item.get("color")}</td>
                                            <td><strong>${item.get("currentStock")}</strong></td>
                                            <td>
                                                <%-- Thay thế checkbox bằng một button --%>
                                                <button type="button" class="btn btn-sm btn-outline-primary add-btn" data-variant-id="${item.get('variantId')}">
                                                    Add
                                                </button>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </form>
                    </div>
                </div>
            </main>
        </div>

        <%-- Các thư viện JS cần thiết --%>
        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        
        <script>
            // JavaScript để quản lý việc chọn sản phẩm bằng nút bấm
            $(document).ready(function() {
                // Dùng Set để lưu các ID đã chọn, tự động xử lý trùng lặp
                const selectedVariants = new Set();

                // 1. Xử lý khi bấm vào nút "Add" trên mỗi dòng
                $('#productTable').on('click', '.add-btn', function() {
                    const button = $(this);
                    const variantId = button.data('variant-id');

                    // Kiểm tra xem sản phẩm đã được chọn chưa
                    if (selectedVariants.has(variantId)) {
                        // Nếu đã chọn -> Hủy chọn
                        selectedVariants.delete(variantId);
                        button.removeClass('btn-success selected').addClass('btn-outline-primary');
                        button.html('Add');
                    } else {
                        // Nếu chưa chọn -> Chọn
                        selectedVariants.add(variantId);
                        button.removeClass('btn-outline-primary').addClass('btn-success selected');
                        button.html('<i class="fas fa-check"></i> Added');
                    }
                });

                // 2. Xử lý khi bấm nút "Add Selected Products"
                $('#submitSelectionBtn').on('click', function() {
                    const form = $('#productForm');
                    const hiddenInputsContainer = $('#hidden-inputs-container');
                    
                    // Xóa các input hidden cũ (nếu có)
                    hiddenInputsContainer.empty();

                    if (selectedVariants.size === 0) {
                        alert('Please select at least one product to add.');
                        return;
                    }

                    // Tạo các thẻ input hidden cho mỗi sản phẩm đã chọn
                    selectedVariants.forEach(variantId => {
                        const hiddenInput = $('<input>').attr({
                            type: 'hidden',
                            name: 'selectedVariants',
                            value: variantId
                        });
                        hiddenInputsContainer.append(hiddenInput);
                    });

                    // Gửi form đi
                    form.submit();
                });
            });

            // Hàm tìm kiếm live trên bảng (giữ nguyên)
            function filterTable() {
                const searchInput = document.getElementById('searchInput').value.toLowerCase();
                const table = document.getElementById('productTable');
                const rows = table.getElementsByTagName('tr');

                for (let i = 1; i < rows.length; i++) {
                    const cells = rows[i].getElementsByTagName('td');
                    let match = false;
                    // Bỏ qua cột cuối (cột Action) khi tìm kiếm
                    for (let j = 0; j < cells.length - 1; j++) {
                        if (cells[j].textContent.toLowerCase().includes(searchInput)) {
                            match = true;
                            break;
                        }
                    }
                    rows[i].style.display = match ? '' : 'none';
                }
            }
        </script>
    </body>
</html>