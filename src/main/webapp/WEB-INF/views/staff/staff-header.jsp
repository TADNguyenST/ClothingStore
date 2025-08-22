<%-- 
    Document   : staff-header
    Created on : Aug 22, 2025, 7:55:30 AM
    Author     : default
--%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<div class="content-header" style="display:flex; justify-content:space-between; align-items:center;">
    <div>
        <h1>
            ${requestScope.pageTitle}
            <small>Staff Panel</small>
        </h1>
        <ol class="breadcrumb">
            <li>
                <a href="${pageContext.request.contextPath}/staffdashboard?action=dashboard&module=staff">
                    <i class="fa fa-dashboard"></i> Home
                </a>
            </li>
            <li class="active">${requestScope.pageTitle}</li>
        </ol>
    </div>

    <div>
        <a href="${pageContext.request.contextPath}/StaffLogout" 
           class="btn btn-danger" 
           style="margin-right:15px;">
            <i class="fa fa-sign-out"></i> Logout
        </a>
    </div>
</div>

