<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<html>
    <head>
        <title>Blog List</title>
        <link href="${pageContext.request.contextPath}/assets/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/admin-dashboard/css/admin-css.css">
        <%-- Link to the new blog-list specific CSS --%>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/admin-dashboard/css/blog-list.css">
    </head>
    <body>

        <%-- Biến để sidebar hoạt động đúng --%>
        <c:set var="currentAction" value="dashboard" scope="request"/>
        <c:set var="currentModule" value="admin" scope="request"/>
        <c:set var="pageTitle" value="Admin Dashboard" scope="request"/>

        <%-- Sidebar --%>
        <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp" />

        <div class="container-blog">
            <div class="header-action d-flex justify-content-between align-items-center mb-3">
                <h1 class="mb-0">Blog Post List</h1>
                <a href="${pageContext.request.contextPath}/StaffBlogController" class="btn btn-primary">
                    <i class="fa fa-plus"></i> Create Blog
                </a>
            </div>

            <div class="table-responsive">
                <table class="table table-striped table-hover">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Title</th>
                            <th>Category</th>
                            <th>Created At</th>
                            <th>Views</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="blog" items="${blogs}">
                            <tr>
                                <td>${blog.blogId}</td>
                                <td>${blog.title}</td>
                                <td>${blog.category}</td>
                                <td>${blog.createdAt}</td>
                                <td>${blog.viewCount}</td>
                                <td>${blog.status}</td>
                                <td class="action-icons">
                                    <a href="${pageContext.request.contextPath}/StaffBlogController?action=edit&blogId=${blog.blogId}" title="Edit"><i class="fa fa-pencil"></i></a>
                                    <a href="${pageContext.request.contextPath}/StaffBlogController?action=delete&blogId=${blog.blogId}" title="Delete" onclick="return confirm('Are you sure you want to delete this blog post?');"><i class="fa fa-trash"></i></a>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty blogs}">
                            <tr>
                                <td colspan="7" style="text-align: center; padding: 20px;">No blog posts found.</td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>

        <script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>
    </body>
</html>