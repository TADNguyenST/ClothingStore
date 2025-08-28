<%-- 
    Document   : staff-dashbroad
    Created on : Jul 28, 2025, 10:11:46 PM
    Author     : default
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>${requestScope.pageTitle != null ? requestScope.pageTitle : "Staff Dashboard"}</title>

        <!-- Link thư viện icon -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">

        <!-- CSS dành cho giao diện nhân viên -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/admin-dashboard/css/admin-css.css">
    </head>
    <body>

        <!-- Biến cần thiết để active sidebar -->
        <c:set var="currentAction" value="dashboard" scope="request"/>
        <c:set var="currentModule" value="staff" scope="request"/>
        <c:set var="pageTitle" value="Staff Dashboard" scope="request"/>

        <!-- Sidebar dành cho nhân viên -->
        <jsp:include page="/WEB-INF/views/staff/staff-sidebar.jsp" />

        <div class="main-content-wrapper">

            <!-- Nội dung chính -->

        </div>

        <!-- JS -->
        <script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>

        <!-- JS active menu -->
        <script>
            document.addEventListener('DOMContentLoaded', function () {
                const currentAction = "${requestScope.currentAction}";
                const currentModule = "${requestScope.currentModule}";

                document.querySelectorAll('.sidebar-menu li.active').forEach(li => li.classList.remove('active'));
                document.querySelectorAll('.sidebar-menu .treeview.menu-open').forEach(li => li.classList.remove('menu-open'));

                if (currentAction && currentModule) {
                    const activeLink = document.querySelector(`.sidebar-menu a[href*="${currentAction}"][href*="${currentModule}"]`);
                    if (activeLink) {
                        activeLink.parentElement.classList.add('active');
                        const parentTreeview = activeLink.closest('.treeview');
                        if (parentTreeview) {
                            parentTreeview.classList.add('active');
                            parentTreeview.classList.add('menu-open');
                        }
                    }
                } else {
                    const dashboardLink = document.querySelector('.sidebar-menu a[href*="dashboard"]');
                    if (dashboardLink && !dashboardLink.closest('.treeview')) {
                        dashboardLink.parentElement.classList.add('active');
                    }
                }
            });
        </script>
    </body>
</html>

