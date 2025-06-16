<%--
    File: admin-dashboard.jsp
    Path: src/main/webapp/WEB-INF/views/admin/dashboard/admin-dashboard.jsp
    Description: Trang hiển thị tổng quan Dashboard dành cho quản trị viên.
                 Đã sửa lỗi bố cục bằng cách loại bỏ 'main-wrapper' DIV.
                 CSS và JavaScript được nhúng trực tiếp.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${requestScope.pageTitle != null ? requestScope.pageTitle : "Admin Dashboard"}</title>

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">

    <style>
        /*
         * TOÀN BỘ MÃ CSS ĐƯỢC DÁN TỪ admin-styles.css VÀO ĐÂY
         * LƯU Ý: body { display: flex; } sẽ sắp xếp các phần tử con trực tiếp của <body>
         * (tức là .sidebar và .main-content-wrapper) cạnh nhau.
         */
        body { margin: 0; font-family: Arial, sans-serif; display: flex; min-height: 100vh; }
        .sidebar { width: 250px; background-color: #222d32; color: #b8c7ce; padding-top: 20px; flex-shrink: 0; box-shadow: 2px 0 5px rgba(0,0,0,0.2); }
        .sidebar-header { color: white; padding: 10px 15px; text-align: center; font-size: 20px; font-weight: bold; border-bottom: 1px solid #4b646f; margin-bottom: 15px; }
        .sidebar-menu { list-style: none; padding: 0; margin: 0; }
        .sidebar-menu li a { display: block; padding: 12px 15px; color: #b8c7ce; text-decoration: none; }
        .sidebar-menu li a:hover, .sidebar-menu li.active > a { background-color: #1e282c; color: white; }
        .sidebar-menu .header { color: #4b646f; background-color: #1a2226; padding: 10px 15px; font-size: 12px; text-transform: uppercase; }
        .sidebar-menu .treeview-menu { list-style: none; padding-left: 20px; display: none; }
        .sidebar-menu .treeview.active.menu-open > .treeview-menu { display: block; }
        .sidebar-menu .pull-right-container { float: right; }

        .main-content-wrapper { flex-grow: 1; display: flex; flex-direction: column; }
        .content-header { background-color: #f8f8f8; padding: 15px 20px; border-bottom: 1px solid #eee; display: flex; justify-content: space-between; align-items: center; }
        .content-header h1 { margin: 0; font-size: 24px; color: #333; }
        .content-header ol.breadcrumb { padding: 0; margin: 0; background: none; list-style: none; }
        .content-header ol.breadcrumb li { display: inline-block; }
        .content-header ol.breadcrumb li + li::before { content: "/\00a0"; padding: 0 5px; color: #ccc; }
        .content-area { padding: 20px; background-color: #ecf0f5; flex-grow: 1; }
        .box { background: #fff; border-radius: 3px; border-top: 3px solid #d2d6de; margin-bottom: 20px; width: 100%; box-shadow: 0 1px 1px rgba(0,0,0,0.1); }
        .box-header { color: #444; display: block; padding: 10px; position: relative; border-bottom: 1px solid #f4f4f4; }
        .box-title { display: inline-block; font-size: 18px; margin: 0; line-height: 1; }
        .box-body { padding: 10px; }
        .box-tools { float: right; }
        .btn { display: inline-block; padding: 6px 12px; margin-bottom: 0; font-size: 14px; font-weight: 400; line-height: 1.42857143; text-align: center; white-space: nowrap; vertical-align: middle; cursor: pointer; border: 1px solid transparent; border-radius: 4px; }
        .btn-primary { color: #fff; background-color: #3c8dbc; border-color: #367fa9; }
        .btn-warning { color: #fff; background-color: #f39c12; border-color: #e08e0b; }
        .btn-danger { color: #fff; background-color: #dd4b39; border-color: #d73925; }
        .btn-xs { padding: 1px 5px; font-size: 12px; line-height: 1.5; border-radius: 3px; }
        .table { width: 100%; max-width: 100%; margin-bottom: 20px; border-collapse: collapse; border-spacing: 0; }
        .table th, .table td { padding: 8px; line-height: 1.42857143; vertical-align: top; border-top: 1px solid #ddd; text-align: left; }
        .table thead th { vertical-align: bottom; border-bottom: 2px solid #ddd; }
        .small-box {
            position: relative;
            display: block;
            border-radius: 2px;
            box-shadow: 0 1px 1px rgba(0,0,0,0.1);
            margin-bottom: 20px;
            color: white;
            padding: 15px;
        }
        .small-box .inner {
            padding: 10px;
        }
        .small-box h3 {
            font-size: 38px;
            font-weight: bold;
            margin: 0 0 10px 0;
            white-space: nowrap;
            padding: 0;
        }
        .small-box p {
            font-size: 15px;
        }
        .small-box .icon {
            position: absolute;
            top: auto;
            bottom: 5px;
            right: 5px;
            z-index: 0;
            font-size: 90px;
            color: rgba(0,0,0,0.15);
        }
        .small-box .small-box-footer {
            position: relative;
            text-align: center;
            padding: 3px 0;
            color: #fff;
            color: rgba(255,255,255,0.8);
            display: block;
            z-index: 10;
            background: rgba(0,0,0,0.1);
            text-decoration: none;
        }
        .small-box .small-box-footer:hover {
            color: #fff;
            background: rgba(0,0,0,0.15);
        }
    </style>
</head>
<body>

    <%-- Đặt các biến requestScope CẦN THIẾT cho sidebar/header --%>
    <%-- Các giá trị này sẽ được Controller đặt, nhưng để trang này hoạt động độc lập --%>
    <%-- và đánh dấu Dashboard là active, chúng ta set mặc định ở đây. --%>
    <c:set var="currentAction" value="dashboard" scope="request"/>
    <c:set var="currentModule" value="admin" scope="request"/>
    <c:set var="pageTitle" value="Admin Dashboard" scope="request"/>

    <%-- BẮT ĐẦU PHẦN BODY CHÍNH CỦA TRANG --%>
    <%-- LƯU Ý: Không có div "main-wrapper" bao bọc ở đây. --%>
    <%-- Sidebar và main-content-wrapper là con trực tiếp của <body> --%>

    <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp" />

    <div class="main-content-wrapper">
        <jsp:include page="/WEB-INF/includes/admin-header.jsp" />

        <div class="content-area">
            <div class="row">
                <div class="col-xs-12">
                    <%-- Nội dung cụ thể của Dashboard bắt đầu tại đây --%>
                    <div class="box box-primary">
                        <div class="box-header with-border">
                            <h3 class="box-title">Admin Dashboard Overview</h3>
                        </div>
                        <div class="box-body">
                            <p>Welcome to the administration page. You can view key statistics and access management functions from here.</p>
                            <div class="row">
                                <div class="col-lg-3 col-xs-6">
                                    <div class="small-box" style="background-color: #00c0ef; color: white; padding: 15px; border-radius: 5px; margin-bottom: 20px;">
                                        <div class="inner"><h3>150</h3><p>New Orders</p></div>
                                        <div class="icon" style="font-size: 70px; position: absolute; top: 5px; right: 10px; opacity: 0.7;"><i class="fa fa-shopping-cart"></i></div>
                                        <a href="${pageContext.request.contextPath}/admindashboard?action=orderList&module=order" class="small-box-footer" style="color: white; text-decoration: none; display: block; padding: 3px 0; background-color: rgba(0,0,0,0.1); text-align: center;">More info <i class="fa fa-arrow-circle-right"></i></a>
                                    </div>
                                </div>
                                <div class="col-lg-3 col-xs-6">
                                    <div class="small-box" style="background-color: #00a65a; color: white; padding: 15px; border-radius: 5px; margin-bottom: 20px;">
                                        <div class="inner"><h3>53<sup style="font-size: 20px">%</sup></h3><p>Conversion Rate</p></div>
                                        <div class="icon" style="font-size: 70px; position: absolute; top: 5px; right: 10px; opacity: 0.7;"><i class="fa fa-line-chart"></i></div>
                                        <a href="#" class="small-box-footer" style="color: white; text-decoration: none; display: block; padding: 3px 0; background-color: rgba(0,0,0,0.1); text-align: center;">More info <i class="fa fa-arrow-circle-right"></i></a>
                                    </div>
                                </div>
                                <div class="col-lg-3 col-xs-6">
                                    <div class="small-box" style="background-color: #f39c12; color: white; padding: 15px; border-radius: 5px; margin-bottom: 20px;">
                                        <div class="inner"><h3>44</h3><p>New User Registrations</p></div>
                                        <div class="icon" style="font-size: 70px; position: absolute; top: 5px; right: 10px; opacity: 0.7;"><i class="fa fa-user-plus"></i></div>
                                        <a href="${pageContext.request.contextPath}/admindashboard?action=customerList&module=customer" class="small-box-footer" style="color: white; text-decoration: none; display: block; padding: 3px 0; background-color: rgba(0,0,0,0.1); text-align: center;">More info <i class="fa fa-arrow-circle-right"></i></a>
                                    </div>
                                </div>
                                <div class="col-lg-3 col-xs-6">
                                    <div class="small-box" style="background-color: #dd4b39; color: white; padding: 15px; border-radius: 5px; margin-bottom: 20px;">
                                        <div class="inner"><h3>65</h3><p>Unique Visitors</p></div>
                                        <div class="icon" style="font-size: 70px; position: absolute; top: 5px; right: 10px; opacity: 0.7;"><i class="fa fa-pie-chart"></i></div>
                                        <a href="#" class="small-box-footer" style="color: white; text-decoration: none; display: block; padding: 3px 0; background-color: rgba(0,0,0,0.1); text-align: center;">More info <i class="fa fa-arrow-circle-right"></i></a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <%-- KẾT THÚC NỘI DUNG RIÊNG CỦA TRANG NÀY --%>
                </div>
            </div>
        </div>
    </div>


    <script>
        /* TOÀN BỘ MÃ JAVASCRIPT ĐƯỢC DÁN TỪ admin-scripts.js VÀO ĐÂY */
        document.addEventListener('DOMContentLoaded', function() {
            const treeviews = document.querySelectorAll('.sidebar-menu .treeview > a');
            treeviews.forEach(function(treeviewLink) {
                treeviewLink.addEventListener('click', function(e) {
                    const parentLi = this.parentElement;
                    if (parentLi.classList.contains('treeview')) {
                        e.preventDefault();
                        document.querySelectorAll('.sidebar-menu .treeview.menu-open').forEach(li => {
                            if (li !== parentLi) {
                                li.classList.remove('menu-open');
                                li.classList.remove('active');
                            }
                        });
                        parentLi.classList.toggle('menu-open');
                        parentLi.classList.toggle('active');
                    }
                });
            });

            const currentAction = "${requestScope.currentAction}";
            const currentModule = "${requestScope.currentModule}";

            document.querySelectorAll('.sidebar-menu li.active').forEach(li => li.classList.remove('active'));
            document.querySelectorAll('.sidebar-menu .treeview.menu-open').forEach(li => li.classList.remove('menu-open'));

            if (currentAction && currentModule) {
                const activeLink = document.querySelector(`.sidebar-menu a[href*="action=${currentAction}"][href*="module=${currentModule}"]`);
                if (activeLink) {
                    activeLink.parentElement.classList.add('active');
                    const parentTreeview = activeLink.closest('.treeview');
                    if (parentTreeview) {
                        parentTreeview.classList.add('active');
                        parentTreeview.classList.add('menu-open');
                    }
                }
            } else if (!currentAction || currentAction === 'home' || currentAction === 'dashboard') {
                const dashboardLink = document.querySelector('.sidebar-menu a[href*="action=dashboard"]');
                if (dashboardLink) {
                    dashboardLink.parentElement.classList.add('active');
                }
            }
        });
    </script>
</body>
</html>