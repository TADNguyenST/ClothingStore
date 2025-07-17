<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="model.Blog" %>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<%
    Blog blog = (Blog) request.getAttribute("blog");
%>

<!DOCTYPE html>
<html>
    <head>
        <title><%= blog.getTitle()%></title>
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <!-- Bootstrap 5 CSS -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

    </head>
    <body class="bg-light">

        <div class="container py-5">
            <!-- Back to List -->
            <div class="mb-4">
                <a href="blog" class="btn btn-secondary"><i class="bi bi-arrow-left"></i> Back to Blog List</a>
            </div>

            <!-- Blog Details Card -->
            <div class="card shadow-sm">
                <div class="card-body">
                    <h1 class="card-title mb-3"><%= blog.getTitle()%></h1>
                    <p class="text-muted">Published on: <%= blog.getPublishedAt()%></p>

                    <img src="<%= blog.getThumbnailUrl()%>" class="img-fluid rounded mb-4" style="max-height: 400px; object-fit: cover;" alt="Thumbnail">

                    <h6 class="text-secondary mb-2">Category: <%= blog.getCategory()%></h6>
                    <p><strong>Tags:</strong> <%= blog.getTags()%></p>

                    <hr>

                    <div class="mt-4" style="line-height: 1.8;">
                        <%= blog.getContent()%>
                    </div>
                </div>
            </div>
        </div>

        <!-- Bootstrap 5 JS -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
<jsp:include page="/WEB-INF/views/common/footer.jsp" />
