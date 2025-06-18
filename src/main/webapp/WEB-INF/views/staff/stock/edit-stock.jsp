<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%-- Đặt các biến cho trang này --%>
<c:set var="pageTitle" value="Sửa Thông Tin Tồn Kho" scope="request"/>
<c:set var="pageSubtitle" value="SKU: ${variant.sku}" scope="request"/>
<c:set var="currentModule" value="stock" scope="request"/>
<c:set var="currentAction" value="stock-list" scope="request"/>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>${pageTitle} - Admin Panel</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css"/>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/admin-dashboard/css/admin-css.css">
    </head>
    <body>

        <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp"/>

        <div class="main-content-wrapper">
            <jsp:include page="/WEB-INF/includes/admin-header.jsp"/>

            <main class="content-area">
                <div class="box">
                    <div class="box-header with-border">
                        <h3 class="box-title">Sửa thông tin tồn kho cho SKU: <c:out value="${variant.sku}"/></h3>
                    </div>
                    <div class="box-body">

                        <%-- Hiển thị lỗi nếu có (ví dụ nhập chữ vào ô số) --%>
                        <c:if test="${not empty errorMessage}">
                            <div class="alert alert-warning"><c:out value="${errorMessage}"/></div>
                        </c:if>

                        <form action="${pageContext.request.contextPath}/EditStock" method="POST">
                            <input type="hidden" name="variantId" value="${variant.variantId}">
                            <input type="hidden" name="inventoryId" value="${inventory.inventoryId}">

                            <div class="mb-3">
                                <label class="form-label">Tên Sản Phẩm</label>
                                <input type="text" class="form-control" value="<c:out value='${product.name}'/>" disabled>
                                <small class="form-text text-muted d-block mb-1">Số lượng hiện tại trong kho: <strong><c:out value="${inventory.quantity}"/></strong></small>
                            </div>
                            <hr>

                            <div class="mb-3">
                                <label class="form-label fw-bold">Chọn hành động cho Tồn kho:</label>
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="updateAction" id="actionSet" value="set" checked>
                                    <label class="form-check-label" for="actionSet">
                                        Sửa số lượng (Ghi đè số lượng cũ bằng số mới)
                                    </label>
                                </div>
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="updateAction" id="actionAdd" value="add">
                                    <label class="form-check-label" for="actionAdd">
                                        Thêm vào kho (Cộng dồn vào số lượng hiện tại)
                                    </label>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label for="quantityValue" class="form-label">Giá trị thay đổi Tồn kho:</label>
                                    <input type="number" class="form-control" id="quantityValue" name="quantityValue" min="0" value="0" required>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label for="reservedQuantity" class="form-label">Sửa Số lượng đang đặt:</label>
                                    <input type="number" class="form-control" id="reservedQuantity" name="reservedQuantity"
                                           value="${inventory.reservedQuantity}" required>
                                </div>
                            </div>

                            <hr>
                            <button type="submit" class="btn btn-primary">Thực hiện thay đổi</button>
                            <a href="${pageContext.request.contextPath}/Stock" class="btn btn-secondary">Hủy</a>
                        </form>

                    </div>
                </div>
            </main>
        </div>

        <script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>
    </body>
</html>