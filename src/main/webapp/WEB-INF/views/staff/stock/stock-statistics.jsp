<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%-- 1. Đặt các biến cho trang này, sidebar và header sẽ dùng chúng --%>
<c:set var="pageTitle" value="Quản Lý Tồn Kho" scope="request"/>
<c:set var="currentModule" value="stock" scope="request"/>
<c:set var="currentAction" value="stock-list" scope="request"/>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>${pageTitle} - Admin Panel</title>

        <%-- 2. Link đến các thư viện và file CSS dùng chung --%>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css"/>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/admin-dashboard/css/admin-css.css">
    </head>
    <body>

        <%-- 3. Nhúng Sidebar --%>
        <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp"/>

        <%-- 4. Bọc toàn bộ nội dung trong .main-content-wrapper --%>
        <div class="main-content-wrapper">

            <%-- Nhúng Header --%>
            <jsp:include page="/WEB-INF/includes/admin-header.jsp"/>

            <%-- 5. Nội dung riêng của trang được đặt trong .content-area --%>
            <main class="content-area">
                <div class="box">
                    <div class="box-header with-border">
                        <h3 class="box-title">Danh sách sản phẩm trong kho</h3>
                    </div>
                    <div class="box-body">

                        <%-- Hiển thị thông báo (nếu có) --%>
                        <c:if test="${param.update == 'success'}">
                            <div class="alert alert-success alert-dismissible fade show" role="alert">
                                <strong>Thành công!</strong> Đã cập nhật thông tin tồn kho.
                                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                            </div>
                        </c:if>

                        <form action="${pageContext.request.contextPath}/Stock" method="GET" class="row g-3 align-items-center mb-4">
                            <div class="col-md-5">
                                <input type="text" class="form-control" name="searchTerm" placeholder="Tìm theo tên sản phẩm, SKU..." value="<c:out value='${searchTerm}'/>">
                            </div>
                            <div class="col-md-4">
                                <select class="form-select" name="filterCategory">
                                    <option value="${cat.categoryId}" ${filterCategory != 'all' && cat.categoryId == filterCategory ? 'selected' : ''}><c:out value="${cat.name}"/>--Tất Cả Danh Mục--</option>
                                    <c:forEach var="cat" items="${categories}">
                                        <option value="${cat.categoryId}" ${cat.categoryId == filterCategory ? 'selected' : ''}><c:out value="${cat.name}"/></option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="col-md-3 d-flex">
                                <button type="submit" class="btn btn-primary w-100 me-2"><i class="fa-solid fa-search"></i> Lọc / Tìm</button>
                                <a href="${pageContext.request.contextPath}/Stock" class="btn btn-secondary"><i class="fa-solid fa-eraser"></i></a>
                            </div>
                        </form>

                        <p><strong>Hiển thị ${displayList.size()} kết quả.</strong></p>

                        <div class="table-responsive">
                            <table class="table table-hover table-bordered table-sm">
                                <thead>
                                    <tr>
                                        <%-- Sửa lại các đường dẫn URL cho đúng --%>
                                        <th><a href="${pageContext.request.contextPath}/Stock?sortBy=sku&sortOrder=${sortBy == 'sku' && sortOrder == 'asc' ? 'desc' : 'asc'}&searchTerm=${searchTerm}&filterCategory=${filterCategory}">SKU <c:if test="${sortBy == 'sku'}"><i class="fa-solid ${sortOrder == 'asc' ? 'fa-sort-up' : 'fa-sort-down'} sort-icon"></i></c:if></a></th>
                                        <th><a href="${pageContext.request.contextPath}/Stock?sortBy=productName&sortOrder=${sortBy == 'productName' && sortOrder == 'asc' ? 'desc' : 'asc'}&searchTerm=${searchTerm}&filterCategory=${filterCategory}">Tên Sản Phẩm <c:if test="${sortBy == 'productName'}"><i class="fa-solid ${sortOrder == 'asc' ? 'fa-sort-up' : 'fa-sort-down'} sort-icon"></i></c:if></a></th>
                                        <th><a href="${pageContext.request.contextPath}/Stock?sortBy=categoryName&sortOrder=${sortBy == 'categoryName' && sortOrder == 'asc' ? 'desc' : 'asc'}&searchTerm=${searchTerm}&filterCategory=${filterCategory}">Danh Mục <c:if test="${sortBy == 'categoryName'}"><i class="fa-solid ${sortOrder == 'asc' ? 'fa-sort-up' : 'fa-sort-down'} sort-icon"></i></c:if></a></th>
                                            <th>Size</th>
                                            <th>Màu Sắc</th>
                                            <th><a href="${pageContext.request.contextPath}/Stock?sortBy=quantity&sortOrder=${sortBy == 'quantity' && sortOrder == 'asc' ? 'desc' : 'asc'}&searchTerm=${searchTerm}&filterCategory=${filterCategory}">Tồn Kho <c:if test="${sortBy == 'quantity'}"><i class="fa-solid ${sortOrder == 'asc' ? 'fa-sort-up' : 'fa-sort-down'} sort-icon"></i></c:if></a></th>
                                            <th>Hành động</th>
                                        </tr>
                                    </thead>
                                    <tbody>
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
                                                        <a href="${pageContext.request.contextPath}/EditStock?variantId=${item.variantId}" class="btn btn-warning btn-xs">
                                                            <i class="fa fa-pencil"></i> Sửa
                                                            <a href="${pageContext.request.contextPath}/StockDetail?variantId=${item.variantId}" class="btn btn-info btn-xs ms-1">
                                                                <i class="fa-solid fa-eye"></i> Chi tiết
                                                            </a>
                                                        </a>
                                                    </td>

                                                </tr>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <tr><td colspan="8" class="text-center p-4">Không tìm thấy sản phẩm nào.</td></tr>
                                        </c:otherwise>
                                    </c:choose>
                                </tbody>
                            </table>
                                             <c:if test="${totalPages > 1}">
            <nav aria-label="Page navigation" class="mt-4">
                <ul class="pagination justify-content-center">
                    <%-- Nút Về trang trước --%>
                    <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                        <a class="page-link" href="${pageContext.request.contextPath}/Stock?page=${currentPage - 1}&searchTerm=${searchTerm}&filterCategory=${filterCategory}&sortBy=${sortBy}&sortOrder=${sortOrder}">Trước</a>
                    </li>

                    <%-- Các nút số trang --%>
                    <c:forEach begin="1" end="${totalPages}" var="i">
                        <li class="page-item ${currentPage == i ? 'active' : ''}">
                            <a class="page-link" href="${pageContext.request.contextPath}/Stock?page=${i}&searchTerm=${searchTerm}&filterCategory=${filterCategory}&sortBy=${sortBy}&sortOrder=${sortOrder}">${i}</a>
                        </li>
                    </c:forEach>

                    <%-- Nút Đến trang sau --%>
                    <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                        <a class="page-link" href="${pageContext.request.contextPath}/Stock?page=${currentPage + 1}&searchTerm=${searchTerm}&filterCategory=${filterCategory}&sortBy=${sortBy}&sortOrder=${sortOrder}">Sau</a>
                    </li>
                </ul>
            </nav>
        </c:if>
                        </div>
                    </div>
                </div>
            </main>
        </div>
        <%-- Dán đoạn code này vào cuối phần box-body trong stock-statistics.jsp --%>
       
        <%-- 6. Link đến file JS dùng chung --%>
        <script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>

        <%-- Phần JS để active menu, cần các biến của JSP nên sẽ để ở đây --%>
        <script>
            document.addEventListener('DOMContentLoaded', function () {
                const currentAction = "${requestScope.currentAction}";
                const currentModule = "${requestScope.currentModule}";

                document.querySelectorAll('.sidebar-menu li.active').forEach(li => li.classList.remove('active'));
                document.querySelectorAll('.sidebar-menu .treeview.menu-open').forEach(li => li.classList.remove('menu-open'));

                if (currentAction && currentModule) {
                    // Tìm link có cả action và module
                    const activeLink = document.querySelector(`.sidebar-menu a[href*="${currentAction}"][href*="${currentModule}"]`);
                    if (activeLink) {
                        activeLink.parentElement.classList.add('active');
                        const parentTreeview = activeLink.closest('.treeview');
                        if (parentTreeview) {
                            parentTreeview.classList.add('active');
                            parentTreeview.classList.add('menu-open');
                        }
                    }
                } else if (!currentAction || currentAction === 'home' || currentAction === 'dashboard') {
                    // Mặc định active link dashboard
                    const dashboardLink = document.querySelector('.sidebar-menu a[href*="dashboard"]'); // Sửa lại để tìm link dashboard đơn giản hơn
                    if (dashboardLink && !dashboardLink.closest('.treeview')) { // Chỉ active nếu nó không nằm trong treeview
                        dashboardLink.parentElement.classList.add('active');
                    }
                }
            });
        </script>
    </body>
</html>