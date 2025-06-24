<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<c:set var="pageTitle" value="Address Book" scope="request"/>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<style>
    /* CSS để các nút bấm trên 1 dòng đẹp hơn, đặc biệt trên mobile */
    .address-actions {
        display: flex;
        flex-wrap: wrap; /* Cho phép xuống dòng nếu không đủ chỗ */
        align-items: center;
        gap: 0.5rem; /* Khoảng cách giữa các nút */
        justify-content: flex-end; /* Căn lề phải */
    }
</style>

<div class="container my-5">
    <div class="row">
        <div class="col-md-3 mb-4">
            <div class="list-group">
                <a href="${pageContext.request.contextPath}/Profile" class="list-group-item list-group-item-action">My Profile</a>
                <a href="${pageContext.request.contextPath}/customer/address" class="list-group-item list-group-item-action active" aria-current="true">Address Book</a>
                <a href="#" class="list-group-item list-group-item-action">My Orders</a>
                <a href="${pageContext.request.contextPath}/logout" class="list-group-item list-group-item-action text-danger">Logout</a>
            </div>
        </div>

        <div class="col-md-9">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h3 class="mb-0">Address Book</h3>
                <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addAddressModal">
                    <i class="fas fa-plus"></i> Add New Address
                </button>
            </div>
            <p class="text-muted">Manage your shipping addresses.</p>
            <hr>

            <%-- Hiển thị thông báo (nếu có) --%>
            <c:if test="${not empty sessionScope.successMessage}">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    ${sessionScope.successMessage}
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
                <c:remove var="successMessage" scope="session"/>
            </c:if>
            <c:if test="${not empty sessionScope.errorMessage}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    ${sessionScope.errorMessage}
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
                <c:remove var="errorMessage" scope="session"/>
            </c:if>

            <c:if test="${empty addressList}">
                <div class="text-center p-5 border rounded bg-light">
                    <i class="fas fa-map-marker-alt fa-3x text-muted mb-3"></i>
                    <p class="fs-4">You haven't saved any addresses yet.</p>
                    <button class="btn btn-primary mt-3" data-bs-toggle="modal" data-bs-target="#addAddressModal">Add Your First Address</button>
                </div>
            </c:if>

            <c:forEach var="addr" items="${addressList}">
                <div class="card mb-3">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-start">
                            <div>
                                <h5 class="card-title mb-1">${addr.recipientName}
                                    <c:if test="${addr.isDefault}"><span class="badge bg-primary ms-2">Default</span></c:if>
                                    </h5>
                                    <p class="card-text text-muted mb-1">${addr.addressDetails}, ${addr.city}</p>
                                <p class="card-text text-muted small">Phone: ${addr.phoneNumber}</p>
                            </div>
                            <div class="address-actions">
                                <button type="button" class="btn btn-sm btn-outline-secondary edit-btn" 
                                        data-bs-toggle="modal" data-bs-target="#editAddressModal"
                                        data-id="${addr.addressId}" data-name="${addr.recipientName}"
                                        data-phone="${addr.phoneNumber}" data-details="${addr.addressDetails}"
                                        data-city="${addr.city}">
                                    <i class="fas fa-pencil-alt"></i> Edit
                                </button>
                                <c:if test="${not addr.isDefault}">
                                    <form action="${pageContext.request.contextPath}/customer/address/action" method="post" class="d-inline">
                                        <input type="hidden" name="addressId" value="${addr.addressId}"><input type="hidden" name="action" value="setDefault">
                                        <button type="submit" class="btn btn-sm btn-outline-success">Set as Default</button>
                                    </form>
                                </c:if>
                                <form action="${pageContext.request.contextPath}/customer/address/action" method="post" class="d-inline" onsubmit="return confirm('Are you sure you want to delete this address?');">
                                    <input type="hidden" name="addressId" value="${addr.addressId}"><input type="hidden" name="action" value="delete">
                                    <button type="submit" class="btn btn-sm btn-outline-danger"><i class="fas fa-trash"></i></button>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
    </div>
</div>

<div class="modal fade" id="addAddressModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header"><h5 class="modal-title">Add New Address</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
            <div class="modal-body">
                <form id="addForm" action="${pageContext.request.contextPath}/customer/address" method="post">
                    <div class="mb-3"><label class="form-label">Full Name</label><input type="text" name="recipientName" class="form-control" required></div>
                    <div class="mb-3"><label class="form-label">Phone Number</label><input type="tel" name="phoneNumber" class="form-control" required></div>
                    <div class="mb-3"><label class="form-label">Address</label><input type="text" name="addressDetails" class="form-control" required placeholder="e.g., 123 Nguyen Van Cu, An Binh Ward"></div>
                    <div class="mb-3"><label class="form-label">City/Province</label><input type="text" name="city" class="form-control" required value="Can Tho"></div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                <button type="submit" form="addForm" class="btn btn-primary">Save Address</button>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="editAddressModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header"><h5 class="modal-title">Edit Address</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
            <div class="modal-body">
                <form id="editForm" action="${pageContext.request.contextPath}/customer/edit-address" method="post">
                    <input type="hidden" name="addressId" id="editAddressId">
                    <div class="mb-3"><label class="form-label">Full Name</label><input type="text" id="editRecipientName" name="recipientName" class="form-control" required></div>
                    <div class="mb-3"><label class="form-label">Phone Number</label><input type="tel" id="editPhoneNumber" name="phoneNumber" class="form-control" required></div>
                    <div class="mb-3"><label class="form-label">Address</label><input type="text" id="editAddressDetails" name="addressDetails" class="form-control" required></div>
                    <div class="mb-3"><label class="form-label">City/Province</label><input type="text" id="editCity" name="city" class="form-control" required></div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                <button type="submit" form="editForm" class="btn btn-primary">Save Changes</button>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

<script>
// Script để truyền dữ liệu vào form Edit khi nhấn nút
    document.addEventListener('DOMContentLoaded', function () {
        var editModal = document.getElementById('editAddressModal');
        if (editModal) {
            editModal.addEventListener('show.bs.modal', function (event) {
                var button = event.relatedTarget;
                var id = button.getAttribute('data-id');
                var name = button.getAttribute('data-name');
                var phone = button.getAttribute('data-phone');
                var details = button.getAttribute('data-details');
                var city = button.getAttribute('data-city');
                editModal.querySelector('#editAddressId').value = id;
                editModal.querySelector('#editRecipientName').value = name;
                editModal.querySelector('#editPhoneNumber').value = phone;
                editModal.querySelector('#editAddressDetails').value = details;
                editModal.querySelector('#editCity').value = city;
            });
        }
    });
</script>