<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" crossorigin="anonymous">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <title>${requestScope.pageTitle != null ? requestScope.pageTitle : "Admin Dashboard"}</title>

    <%-- Link đến thư viện ngoài --%>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">

    <%-- Link đến file CSS dùng chung của bạn --%>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/admin-dashboard/css/admin-css.css">
</head>
<body>

    <%-- Đặt các biến requestScope CẦN THIẾT cho sidebar/header --%>
    <c:set var="currentAction" value="dashboard" scope="request"/>
    <c:set var="currentModule" value="admin" scope="request"/>
    <c:set var="pageTitle" value="Admin Dashboard" scope="request"/>

    <%-- Nhúng Sidebar --%>
    <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp" />

    <div class="main-content-wrapper">
        <%-- Nhúng Header --%>
        <jsp:include page="/WEB-INF/includes/admin-header.jsp" />
        
        <%-- Nội dung chính của trang Dashboard --%>
        <div class="content-area">
            <div class="row">
                <div class="col-xs-12">
                    <div class="box box-primary">
                        <div class="box-header with-border">
                            <h3 class="box-title">Admin Dashboard Overview</h3>
                        </div>
                        <div class="box-body">
                            <p>Welcome to the administration page. You can view key statistics and access management functions from here.</p>
                            <div class="row">
                                <%-- Các small-box thống kê của bạn --%>
                                <div class="col-lg-3 col-xs-6">
                                     <div class="small-box" style="background-color: #00c0ef;">
                                         <div class="inner"><h3>150</h3><p>New Orders</p></div>
                                         <div class="icon"><i class="fa fa-shopping-cart"></i></div>
                                         <a href="#" class="small-box-footer">More info <i class="fa fa-arrow-circle-right"></i></a>
                                     </div>
                                 </div>
                                <%-- ... các .col khác ... --%>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%-- Link đến file JS dùng chung --%>
    
    <script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
    <%-- Phần JS để active menu, cần các biến của JSP nên sẽ để ở đây --%>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
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