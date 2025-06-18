<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<c:set var="pageTitle" value="Chi Tiết Sản Phẩm" scope="request"/>
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
                        <h3 class="box-title">Thông tin chi tiết sản phẩm</h3>
                    </div>
                    <div class="box-body">
                        <div class="row">
                            <div class="col-md-6">
                                <h4>Thông tin cơ bản</h4>
                                <ul class="list-group list-group-flush">
                                    <li class="list-group-item"><strong>Product ID:</strong> <c:out value="${product.productId}"/></li>
                                    <li class="list-group-item"><strong>Tên sản phẩm:</strong> <c:out value="${product.name}"/></li>
                                    <li class="list-group-item"><strong>Chất liệu:</strong> <c:out value="${product.material}"/></li>
                                    <li class="list-group-item"><strong>Giá gốc:</strong> <c:out value="${product.price}"/></li>
                                    <li class="list-group-item"><strong>Trạng thái:</strong> <c:out value="${product.status}"/></li>
                                </ul>
                            </div>
                            <div class="col-md-6">
                                <h4>Thông tin biến thể</h4>
                                <ul class="list-group list-group-flush">
                                    <li class="list-group-item"><strong>Variant ID:</strong> <c:out value="${variant.variantId}"/></li>
                                    <li class="list-group-item"><strong>SKU:</strong> <c:out value="${variant.sku}"/></li>
                                    <li class="list-group-item"><strong>Size:</strong> <c:out value="${variant.size}"/></li>
                                    <li class="list-group-item"><strong>Màu sắc:</strong> <c:out value="${variant.color}"/></li>
                                    <li class="list-group-item"><strong>Giá thay đổi:</strong> <c:out value="${variant.priceModifier}"/></li>
                                </ul>
                            </div>
                        </div>
                        <hr>
                        <div class="row mt-3">
                            <div class="col-md-6">
                                <h4>Thông tin phân loại</h4>
                                <ul class="list-group list-group-flush">
                                    <li class="list-group-item"><strong>Category ID:</strong> <c:out value="${category.categoryId}"/></li>
                                    <li class="list-group-item"><strong>Tên danh mục:</strong> <c:out value="${category.name}"/></li>
                                    <li class="list-group-item"><strong>Brand ID:</strong> <c:out value="${brand.brandId}"/></li>
                                    <li class="list-group-item"><strong>Tên thương hiệu:</strong> <c:out value="${brand.name}"/></li>
                                </ul>
                            </div>
                            <div class="col-md-6">
                                <h4>Thông tin Kho</h4>
                                <ul class="list-group list-group-flush">
                                    <li class="list-group-item"><strong>Inventory ID:</strong> <c:out value="${inventory.inventoryId}"/></li>
                                    <li class="list-group-item"><strong>Số lượng tồn kho:</strong> <c:out value="${inventory.quantity}"/>                             
                                        <a href="${pageContext.request.contextPath}/EditStock?variantId=${variant.variantId}" class="btn btn-warning btn-xs"><i class="fa fa-pencil"></i> Sửa
                                        </a><li> 
                                    <li class="list-group-item"><strong>Số lượng đang đặt:</strong> <c:out value="${inventory.reservedQuantity}"/></li>
                                    <li class="list-group-item"><strong>Cập nhật lần cuối:</strong> <c:out value="${inventory.lastUpdated}"/></li>
                                </ul>
                            </div>
                        </div>
                        <%-- Thêm box này vào cuối trang product-details.jsp --%>
                        <div class="box mt-4">
                            <div class="box-header with-border">
                                <h3 class="box-title">Lịch sử thay đổi kho</h3>
                            </div>
                            <div class="box-body">
                                <div class="table-responsive">
                                    <table class="table table-striped table-sm">
                                        <thead>
                                            <tr>
                                                <th>Thời gian</th>
                                                <th>Loại thay đổi</th>
                                                <th>Số lượng thay đổi</th>
                                                <th>Ghi chú</th>
                                                <th>Người thực hiện (ID)</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:choose>
                                                <c:when test="${not empty movementHistory}">
                                                    <c:forEach var="movement" items="${movementHistory}">
                                                        <tr>
                                                            <%-- Bây giờ chỉ cần hiển thị chuỗi đã được định dạng sẵn --%>
                                                            <td><c:out value="${movement.createdAtFormatted}"/></td>

                                                            <td>
                                                                <c:choose>
                                                                    <c:when test="${movement.movementType == 'In'}"><span class="badge bg-success">Nhập kho</span></c:when>
                                                                    <c:when test="${movement.movementType == 'Out'}"><span class="badge bg-danger">Xuất kho</span></c:when>
                                                                    <c:when test="${movement.movementType == 'Adjustment'}"><span class="badge bg-warning text-dark">Điều chỉnh</span></c:when>
                                                                    <c:otherwise><c:out value="${movement.movementType}"/></c:otherwise>
                                                                </c:choose>
                                                            </td>
                                                            <td>
                                                                <strong class="${movement.quantityChanged > 0 ? 'text-success' : 'text-danger'}">
                                                                    ${movement.quantityChanged > 0 ? '+' : ''}<c:out value="${movement.quantityChanged}"/>
                                                                </strong>
                                                            </td>
                                                            <td><c:out value="${movement.notes}"/></td>

                                                            <%-- Hiển thị Tên nhân viên thay vì ID --%>
                                                            <td><c:out value="${movement.staffName}"/></td>
                                                        </tr>
                                                    </c:forEach>
                                                </c:when>
                                                <c:otherwise>
                                                    <tr>
                                                        <td colspan="5" class="text-center text-muted p-3">
                                                            Chưa có lịch sử thay đổi nào cho sản phẩm này.
                                                        </td>
                                                    </tr>
                                                </c:otherwise>
                                            </c:choose>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                        <hr>
                        <a href="${pageContext.request.contextPath}/Stock" class="btn btn-secondary">
                            <i class="fa fa-arrow-left"></i> Quay lại danh sách
                        </a>
                        <a href="${pageContext.request.contextPath}/StockMovement" class="btn btn-secondary">
                            Xem Stock Movement <i class="fa fa-arrow-right"></i> 
                        </a>
                    </div>
                </div>
            </main>
        </div>
        <script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>
    </body>
</html>