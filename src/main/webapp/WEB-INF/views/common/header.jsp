<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
    <head>
        <title>Clothing Store</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    </head>
    <body>
        <nav class="navbar navbar-expand-lg navbar-light bg-light fixed-top">
            <div class="container-fluid">
                <a class="navbar-brand" href="${pageContext.request.contextPath}/Homepage">
                    <img src="${pageContext.request.contextPath}/assets/images/logo.png" alt="Clothing Store Logo" height="40" style="margin-right: 10px;">
                    Clothing Store
                </a>
                <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
                    <span class="navbar-toggler-icon"></span>
                </button>
                <div class="collapse navbar-collapse" id="navbarNav">
                    <ul class="navbar-nav mx-auto">
                        <li class="nav-item">
                            <a class="nav-link" href="${pageContext.request.contextPath}/Homepage">Home</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="#">Shop</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="#">Blog</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="#">About</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="#">Contact</a>
                        </li>
                    </ul>
                    <form class="d-flex" role="search">
                        <input class="form-control me-2" type="search" placeholder="Search" aria-label="Search">
                        <button class="btn btn-outline-success" type="submit">Search</button>
                    </form>
                    <ul class="navbar-nav">
                        <!-- Check if user is logged in (session exists) -->
                        <% if (session != null && session.getAttribute("user") != null) {%>
                        <!-- User is logged in - show dropdown menu -->
                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle" href="#" id="userDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                                <i class="bi bi-person-circle"></i> 
                                <%= session.getAttribute("username") != null ? session.getAttribute("username") : "User"%>
                            </a>
                            <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="userDropdown">
                                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/ViewProfile">
                                        <i class="bi bi-person"></i> View Profile
                                    </a></li>
                                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/ChangePassword">
                                        <i class="bi bi-key"></i> Change Password
                                    </a></li>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/Logout">
                                        <i class="bi bi-box-arrow-right"></i> Logout
                                    </a></li>
                            </ul>
                        </li>
                        <% } else { %>
                        <!-- User is not logged in - show login/register links -->
                        <li class="nav-item">
                            <a class="nav-link" href="${pageContext.request.contextPath}/Login">Login</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="${pageContext.request.contextPath}/Register">Register</a>
                        </li>
                        <% }%>

                        <!-- Cart link (always visible) -->
                        <li class="nav-item">
                            <a class="nav-link" href="${pageContext.request.contextPath}/Cart">
                                <i class="bi bi-cart-fill"></i> Cart (0)
                            </a>
                        </li>
                    </ul>
                </div>
            </div>
        </nav>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    </body>
</html>