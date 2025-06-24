<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:set var="pageTitle" value="Edit Address" scope="request"/>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="container my-5">
    <div class="row">
        <div class="col-md-3">
             <div class="list-group">
                <a href="${pageContext.request.contextPath}/Profile" class="list-group-item list-group-item-action">My Profile</a>
                <a href="${pageContext.request.contextPath}/customer/address" class="list-group-item list-group-item-action active" aria-current="true">Address Book</a>
                <a href="#" class="list-group-item list-group-item-action">My Orders</a>
                <a href="${pageContext.request.contextPath}/logout" class="list-group-item list-group-item-action text-danger">Logout</a>
            </div>
        </div>
        <div class="col-md-9">
            <h3>Edit Shipping Address</h3>
            <p>Update your address details below and save changes.</p>
            <hr>
            <div class="card">
                <div class="card-body">
                    <form action="${pageContext.request.contextPath}/customer/edit-address" method="post">
                        <input type="hidden" name="addressId" value="${address.addressId}">
                        <div class="mb-3"><label class="form-label">Full Name</label><input type="text" name="recipientName" class="form-control" value="${address.recipientName}" required></div>
                        <div class="mb-3"><label class="form-label">Phone Number</label><input type="tel" name="phoneNumber" class="form-control" value="${address.phoneNumber}" required></div>
                        <div class="mb-3"><label class="form-label">Address</label><input type="text" name="addressDetails" class="form-control" value="${address.addressDetails}" required></div>
                        <div class="mb-3"><label class="form-label">City/Province</label><input type="text" name="city" class="form-control" value="${address.city}" required></div>
                        <button type="submit" class="btn btn-primary">Save Changes</button>
                        <a href="${pageContext.request.contextPath}/customer/address" class="btn btn-secondary">Cancel</a>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />