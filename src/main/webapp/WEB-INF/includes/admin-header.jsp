<%-- src/main/webapp/WEB-INF/includes/admin-header.jsp --%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<div class="content-header">
    <h1>
        ${requestScope.pageTitle}
        <small>Control panel</small>
    </h1>
    <ol class="breadcrumb">
        <li><a href="${pageContext.request.contextPath}/admindashboard?action=dashboard&module=admin"><i class="fa fa-dashboard"></i> Home</a></li>
        <li class="active">${requestScope.pageTitle}</li>
    </ol>
</div>