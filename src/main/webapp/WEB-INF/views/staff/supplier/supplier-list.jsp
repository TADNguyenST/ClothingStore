<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<c:set var="pageTitle" value="Supplier Management" scope="request"/>
<c:set var="currentModule" value="supplier" scope="request"/>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Supplier Management</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/admin-dashboard/css/admin-css.css">
    <style>
        .modal-overlay {
            position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background-color: rgba(0, 0, 0, 0.5); display: flex;
            justify-content: center; align-items: center;
            /* SỬA LỖI BỊ CHE: Đảm bảo z-index cao nhất */
            z-index: 1055; 
        }
        .modal-content-custom {
            background: white; padding: 25px; border-radius: 8px;
            width: 50%; max-width: 800px; box-shadow: 0 5px 15px rgba(0,0,0,0.3);
        }
        .po-list-container {
            max-height: 300px; overflow-y: auto;
            border: 1px solid #dee2e6; border-radius: .375rem;
        }
    </style>
</head>
<body>

    <%-- ================== START: CÁC MODAL (BẢNG NỔI) ================== --%>

    <%-- Bảng nổi cho Form Add/Edit --%>
 <%-- Bảng nổi cho Form Add/Edit --%>
<c:if test="${viewMode == 'form'}">
    <div class="modal-overlay">
        <div class="modal-content-custom">
            <h3>${empty supplier.supplierId ? 'Add New Supplier' : 'Edit Supplier'}</h3>
            <hr>
            <form action="Supplier" method="post">
                <input type="hidden" name="action" value="save">
                <input type="hidden" name="id" value="${supplier.supplierId}">
                
                <div class="mb-3">
                    <label class="form-label">Name (*)</label>
                    <input type="text" name="name" class="form-control" value="<c:out value='${supplier.name}'/>" required>
                </div>
                <div class="mb-3">
                    <label class="form-label">Email (*)</label>
                    <%-- SỬA ĐỔI: Thêm 'required' --%>
                    <input type="email" name="email" class="form-control" value="<c:out value='${supplier.contactEmail}'/>" required>
                </div>
                <div class="mb-3">
                    <label class="form-label">Phone (*)</label>
                    <%-- SỬA ĐỔI: Thêm 'required' --%>
                    <input type="text" name="phone" class="form-control" value="<c:out value='${supplier.phoneNumber}'/>" required>
                </div>
                 <div class="mb-3">
                    <label class="form-label">Address (*)</label>
                    <%-- SỬA ĐỔI: Thêm 'required' --%>
                    <textarea name="address" class="form-control" rows="3" required><c:out value='${supplier.address}'/></textarea>
                </div>
                <div class="mb-3">
                    <label class="form-label">Status</label>
                    <select name="isActive" class="form-select">
                        <option value="true" ${supplier.isActive ? 'selected' : ''}>Active</option>
                        <option value="false" ${!supplier.isActive ? 'selected' : ''}>Inactive</option>
                    </select>
                </div>
                <hr>
                <button type="submit" class="btn btn-primary">Save</button>
                <a href="Supplier?action=list" class="btn btn-secondary">Cancel</a>
            </form>
        </div>
    </div>
</c:if>

    <%-- Bảng nổi cho Xem Chi Tiết --%>
    <c:if test="${viewMode == 'detail'}">
        <div class="modal-overlay">
            <div class="modal-content-custom">
                <h3>Details for: ${supplier.name}</h3>
                <hr>
                <p><strong>Email:</strong> ${supplier.contactEmail}</p>
                <p><strong>Phone:</strong> ${supplier.phoneNumber}</p>
                <p><strong>Address:</strong> ${supplier.address}</p>
                <p><strong>Status:</strong> <span class="badge ${supplier.isActive ? 'bg-success' : 'bg-danger'}">${supplier.isActive ? 'Active' : 'Inactive'}</span></p>
                <hr>
                <h4>Associated Purchase Orders</h4>
                <div class="po-list-container">
                    <table class="table table-sm table-striped">
                        <thead><tr><th>PO ID</th><th>Notes</th><th>Date</th><th>Status</th><th>Action</th></tr></thead>
                        <tbody>
                            <c:forEach var="po" items="${poList}">
                                <tr>
                                    <td>#${po.get("poId")}</td><td>${po.get("notes")}</td>
                                    <td><fmt:formatDate value="${po.get('orderDate')}" pattern="dd/MM/yyyy"/></td>
                                    <td><span class="badge bg-secondary">${po.get("status")}</span></td>
                                    <td><a href="PurchaseOrder?action=edit&poId=${po.get('poId')}" class="btn btn-sm btn-outline-primary">View</a></td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty poList}"><tr><td colspan="5" class="text-center">No purchase orders found.</td></tr></c:if>
                        </tbody>
                    </table>
                </div>
                <br>
                <a href="Supplier?action=list" class="btn btn-secondary">Close</a>
            </div>
        </div>
    </c:if>

    <%-- MỚI: Bảng nổi chung cho các xác nhận Deactivate/Reactivate --%>
    <div class="modal-overlay" id="confirmationModal" style="display: none;">
        <div class="modal-content-custom" style="width: 500px;">
            <h4 id="confirmModalTitle"></h4>
            <hr>
            <p id="confirmModalBody" class="my-3"></p>
            <hr>
            <div class="text-end">
                <button type="button" class="btn btn-secondary" id="confirmModalCancelBtn">Cancel</button>
                <button type="button" class="btn btn-danger" id="confirmModalConfirmBtn">Confirm</button>
            </div>
        </div>
    </div>
    
    <%-- MỚI: Bảng nổi chung cho các lỗi validation --%>
    <c:if test="${not empty errorMessages}">
        <div class="modal-overlay" id="errorModalOverlay">
            <div class="modal-content-custom" style="width: 450px;">
                <h4 class="text-danger"><i class="fas fa-times-circle me-2"></i>Invalid Information</h4><hr>
                <div class="text-start p-2">
                    <p>Please correct the following errors:</p>
                    <ul><c:forEach var="error" items="${errorMessages}"><li class="text-danger">${error}</li></c:forEach></ul>
                </div><hr>
                <button class="btn btn-danger" onclick="document.getElementById('errorModalOverlay').style.display='none'">Close</button>
            </div>
        </div>
    </c:if>

    <%-- ================== END: CÁC MODAL ================== --%>


    <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp"/>
    <div class="main-content-wrapper">
        <jsp:include page="/WEB-INF/includes/admin-header.jsp"/>
        <main class="content-area">
            <div class="box">
                <div class="box-header with-border">
                    <h3 class="box-title">Suppliers</h3>
                    <a href="Supplier?action=add" class="btn btn-success"><i class="fas fa-plus me-1"></i> Add New Supplier</a>
                </div>
                <div class="box-body" id="supplier-table-body"> <%-- MỚI: Thêm ID để bắt sự kiện --%>
                    <table class="table table-bordered table-hover">
                        <thead>
                            <tr><th>Name</th><th>Email</th><th>Phone</th><th>Status</th><th>Actions</th></tr>
                        </thead>
                        <tbody>
                            <c:forEach var="s" items="${supplierList}">
                                <tr>
                                    <td>${s.name}</td>
                                    <td>${s.contactEmail}</td>
                                    <td>${s.phoneNumber}</td>
                                    <td><span class="badge ${s.isActive ? 'bg-success' : 'bg-danger'}">${s.isActive ? 'Active' : 'Inactive'}</span></td>
                                    <td>
                                        <a href="Supplier?action=detail&id=${s.supplierId}" class="btn btn-info btn-sm">Details</a>
                                        <a href="Supplier?action=edit&id=${s.supplierId}" class="btn btn-warning btn-sm">Edit</a>
                                        
                                        <c:if test="${s.isActive}">
                                            <%-- SỬA LỖI: Bỏ onsubmit, form sẽ được xử lý bằng JavaScript --%>
                                            <form action="Supplier" method="post" style="display:inline;">
                                                <input type="hidden" name="action" value="deactivate">
                                                <input type="hidden" name="id" value="${s.supplierId}">
                                                <button type="submit" class="btn btn-danger btn-sm">Deactivate</button>
                                            </form>
                                        </c:if>
                                        
                                        <c:if test="${!s.isActive}">
                                            <%-- SỬA LỖI: Bỏ onsubmit, form sẽ được xử lý bằng JavaScript --%>
                                            <form action="Supplier" method="post" style="display:inline;">
                                                <input type="hidden" name="action" value="reactivate">
                                                <input type="hidden" name="id" value="${s.supplierId}">
                                                <button type="submit" class="btn btn-success btn-sm">Reactivate</button>
                                            </form>
                                        </c:if>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </main>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>

    <%-- ================== START: SCRIPT MỚI XỬ LÝ MODAL XÁC NHẬN ================== --%>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Lấy các element của modal xác nhận
            const confirmModal = document.getElementById('confirmationModal');
            const confirmModalTitle = document.getElementById('confirmModalTitle');
            const confirmModalBody = document.getElementById('confirmModalBody');
            let confirmModalConfirmBtn = document.getElementById('confirmModalConfirmBtn');
            const confirmModalCancelBtn = document.getElementById('confirmModalCancelBtn');

            // Hàm hiển thị modal chung
            function showConfirmationModal(title, body, btnClass, onConfirm) {
                confirmModalTitle.textContent = title;
                confirmModalBody.innerHTML = body; // Dùng innerHTML để có thể chèn <br>
                confirmModalConfirmBtn.className = 'btn ' + btnClass; // Đổi màu nút confirm
                
                // Xử lý sự kiện click, dùng {once: true} để listener tự xóa sau 1 lần click
                const newConfirmBtn = confirmModalConfirmBtn.cloneNode(true);
                confirmModalConfirmBtn.parentNode.replaceChild(newConfirmBtn, confirmModalConfirmBtn);
                confirmModalConfirmBtn = newConfirmBtn;

                confirmModalConfirmBtn.addEventListener('click', () => {
                    onConfirm();
                    confirmModal.style.display = 'none';
                }, { once: true });

                confirmModalCancelBtn.addEventListener('click', () => {
                    confirmModal.style.display = 'none';
                }, { once: true });
                
                confirmModal.style.display = 'flex'; // Hiển thị modal
            }

            // Bắt sự kiện submit trên toàn bộ khu vực bảng
            const tableBody = document.getElementById('supplier-table-body');
            if (tableBody) {
                tableBody.addEventListener('submit', function(event) {
                    const form = event.target;
                    const actionInput = form.querySelector('input[name="action"]');
                    
                    if (actionInput && (actionInput.value === 'deactivate' || actionInput.value === 'reactivate')) {
                        event.preventDefault(); // Ngăn form submit ngay lập tức

                        let title, body, btnClass;

                        if (actionInput.value === 'deactivate') {
                            title = 'Deactivate Supplier';
                            body = 'The activities you are doing with this supplier may be interrupted. <br><b>Are you sure you want to deactivate?</b>';
                            btnClass = 'btn-danger';
                        } else {
                            title = 'Reactivate Supplier';
                            body = 'Are you sure you want to reactivate this provider?';
                            btnClass = 'btn-success';
                        }
                        
                        // Gọi modal và truyền vào hành động submit form
                        showConfirmationModal(title, body, btnClass, () => {
                            form.submit();
                        });
                    }
                });
            }
        });
    </script>
    <%-- ================== END: SCRIPT MỚI ================== --%>

</body>
</html>