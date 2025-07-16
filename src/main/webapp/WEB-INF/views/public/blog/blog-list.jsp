<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<!DOCTYPE html>
<html>
    <head>
        <title>Blog</title>
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <!-- Bootstrap CSS -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </head>
    <body class="bg-light">

        <div class="container py-5">
            <h2 class="text-center mb-4">All Blog Posts</h2>

            <!-- Error Message -->
            <c:if test="${not empty error}">
                <div class="alert alert-danger text-center">${error}</div>
            </c:if>

            <!-- Blog Grid -->
            <c:if test="${not empty blogs}">
                <div class="row row-cols-1 row-cols-md-2 g-4">
                    <c:forEach var="b" items="${blogs}">
                        <div class="col">
                            <div class="card h-100 shadow-sm">
                                <img src="${b.thumbnailUrl}" class="card-img-top" alt="Thumbnail"
                                     style="object-fit: cover; height: 200px;">
                                <div class="card-body d-flex flex-column">
                                    <h5 class="card-title">
                                        <a href="blog?id=${b.blogId}" class="text-decoration-none text-dark">
                                            ${b.title}
                                        </a>
                                    </h5>
                                    <p class="card-text mb-1">
                                        <small class="text-muted">
                                            Published on:
                                            <fmt:formatDate value="${b.publishedAt}" pattern="dd MMM yyyy"/>
                                        </small>
                                    </p>
                                    <p class="card-text">${b.excerpt}</p>
                                    <div class="mt-auto">
                                        <a href="blog?id=${b.blogId}" class="btn btn-outline-primary">Read More</a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:if>

            <!-- No Blogs -->
            <c:if test="${empty blogs}">
                <div class="alert alert-info text-center">There are no blog posts available.</div>
            </c:if>

            <!-- Pagination -->
            <c:if test="${totalPages > 1}">
                <nav aria-label="Page navigation" class="mt-5">
                    <ul class="pagination justify-content-center">
                        <li class="page-item ${page == 1 ? 'disabled' : ''}">
                            <a class="page-link" href="blog?page=${page - 1}" aria-label="Previous">
                                <span aria-hidden="true">&laquo;</span>
                            </a>
                        </li>
                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <li class="page-item ${i == page ? 'active' : ''}">
                                <a class="page-link" href="blog?page=${i}">${i}</a>
                            </li>
                        </c:forEach>
                        <li class="page-item ${page == totalPages ? 'disabled' : ''}">
                            <a class="page-link" href="blog?page=${page + 1}" aria-label="Next">
                                <span aria-hidden="true">&raquo;</span>
                            </a>
                        </li>
                    </ul>
                </nav>
            </c:if>

        </div>

        <!-- Bootstrap JS -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
<jsp:include page="/WEB-INF/views/common/footer.jsp" />