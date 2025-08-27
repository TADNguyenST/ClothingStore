<%@page import="dao.CategoryDAO"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page import="model.Category"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    // Lấy danh mục cha/con cho menu
    CategoryDAO cateDAO = new CategoryDAO();
    List<Category> allCategories = cateDAO.getAllCategories();
    List<Category> parentCategories = new ArrayList<Category>();
    if (allCategories != null) {
        for (Category cat : allCategories) {
            if (cat.getParentCategoryId() == null) {
                parentCategories.add(cat);
            }
        }
    }
    String selectedParentCategoryId = request.getParameter("parentCategoryId");
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>ClothingStore - ${pageTitle}</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">

        <!-- CSS -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet"
              href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
        <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap"
              rel="stylesheet">

        <!-- JS (defer) : đảm bảo Bootstrap/Popper sẵn sàng trước DOMContentLoaded -->
        <script src="https://code.jquery.com/jquery-3.6.0.min.js" defer></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" defer></script>

        <style>
            body {
                font-family: 'Poppins', sans-serif;
            }
            .main-header {
                background:#fff;
                border-bottom:1px solid #e5e7eb;
                padding:1rem 0;
            }
            .main-header .navbar-brand {
                font-size:1.8rem;
                font-weight:600;
                color:#1e3a8a;
            }
            .main-header .nav-link {
                color:#1e3a8a;
                font-weight:500;
                padding:.5rem 1rem;
                text-transform:uppercase;
                font-size:.9rem;
            }
            .main-header .nav-link:hover {
                color:#3b82f6;
            }
            .header-actions .nav-link {
                font-size:1.2rem;
                color:#1e3a8a;
            }
            .header-actions .nav-link:hover {
                color:#3b82f6;
            }
            .header-actions .badge {
                font-size:.6rem;
                padding:.3rem .5rem;
                background:#3b82f6;
                color:#fff;
                transition:opacity .3s, transform .3s;
            }
            .header-actions .badge.show {
                opacity:1;
                transform:scale(1);
            }
            .header-actions .badge.hide {
                opacity:0;
                transform:scale(.8);
            }
            .dropdown-menu {
                border-radius:8px;
                border:1px solid #e5e7eb;
                box-shadow:0 4px 10px rgba(0,0,0,.1);
                min-width:200px;
            }
            .dropdown-item {
                font-size:.9rem;
                padding:.5rem 1.5rem;
            }
            .dropdown-item:hover {
                background:#f1f5f9;
                color:#1e3a8a;
            }
            .search-bar input {
                border-radius:20px;
                padding:.5rem 1rem;
                font-size:.9rem;
            }
            .search-bar input:focus {
                border-color:#3b82f6;
                box-shadow:0 0 5px rgba(59,130,246,.5);
            }
            #suggestions {
                border-radius:8px;
                border:1px solid #e5e7eb;
                background:#fff;
                max-height:300px;
                overflow-y:auto;
                z-index:1000;
                display:none;
            }
            .suggestion-item:hover {
                background:#f1f5f9;
            }
            .toast-container {
                z-index:1055;
            }
            /* Giúp dropdown luôn ở trên mọi banner/hero */
            .main-header.sticky-top {
                z-index: 1060;
            }
        </style>
    </head>
    <body class="d-flex flex-column min-vh-100">
        <header class="main-header sticky-top">
            <nav class="navbar navbar-expand-lg" data-bs-theme="light">
                <div class="container">
                    <a class="navbar-brand" href="${pageContext.request.contextPath}/home">ClothingStore</a>

                    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#mainNavbar"
                            aria-controls="mainNavbar" aria-expanded="false" aria-label="Toggle navigation">
                        <span class="navbar-toggler-icon"></span> <!-- bật icon mặc định -->
                    </button>

                    <div class="collapse navbar-collapse" id="mainNavbar">
                        <ul class="navbar-nav mx-auto mb-2 mb-lg-0">
                            <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/home">Home</a></li>

                            <% if (parentCategories != null && !parentCategories.isEmpty()) {
                                   for (Category parentCategory : parentCategories) {
                                       String selected = (selectedParentCategoryId != null
                                           && selectedParentCategoryId.equals(String.valueOf(parentCategory.getCategoryId()))) ? "active" : "";
                            %>
                            <li class="nav-item dropdown <%= selected %>">
                                <a class="nav-link dropdown-toggle" href="#" role="button"
                                   data-bs-toggle="dropdown" data-bs-auto-close="outside"
                                   aria-expanded="false">
                                    <%= parentCategory.getName() %>
                                </a>
                                <ul class="dropdown-menu">
                                    <%
                                        for (Category cat : allCategories) {
                                            if (cat.getParentCategoryId() != null
                                                    && cat.getParentCategoryId().equals(parentCategory.getCategoryId())
                                                    && cat.isActive()) {
                                    %>
                                    <li>
                                        <a class="dropdown-item"
                                           href="${pageContext.request.contextPath}/ProductList?categoryId=<%= cat.getCategoryId() %>&parentCategoryId=<%= parentCategory.getCategoryId() %>">
                                            <%= cat.getName() %>
                                        </a>
                                    </li>
                                    <%      }
                                        }
                                    %>
                                    <li><a class="dropdown-item"
                                           href="${pageContext.request.contextPath}/ProductList?parentCategoryId=<%= parentCategory.getCategoryId() %>">
                                            Shop All <%= parentCategory.getName() %></a></li>
                                </ul>
                            </li>
                            <%   }
                       } %>

                            <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/ProductList/sale">Sale</a></li>
                            <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/blog">Blog</a></li>
                            <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/VoucherPublic">Voucher</a></li>
                            <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/feedback">Feedback</a></li>
                        </ul>

                        <div class="d-flex align-items-center header-actions">
                            <div class="search-bar position-relative me-3">
                                <input type="text" id="searchInput" class="form-control" placeholder="Search products...">
                                <div id="suggestions" class="position-absolute w-100"></div>
                            </div>

                            <a href="${pageContext.request.contextPath}/wishlist?action=view" class="nav-link me-3">
                                <i class="fas fa-heart"></i>
                            </a>

                            <!-- Cho guest truy cập Cart bình thường -->
                            <a href="${pageContext.request.contextPath}/customer/cart" class="nav-link position-relative cart-link">
                                <i class="fas fa-shopping-bag"></i>
                                <span id="cartCount" class="badge rounded-pill bg-primary text-white hide">0</span>
                            </a>

                            <div class="nav-item dropdown user-dropdown ms-3">
                                <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown">
                                    <i class="fas fa-user"></i>
                                </a>
                                <ul class="dropdown-menu dropdown-menu-end">
                                    <c:choose>
                                        <c:when test="${not empty sessionScope.user}">
                                            <li><h6 class="dropdown-header">Hi, ${sessionScope.user.fullName}</h6></li>
                                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/Profile">My Account</a></li>
                                            <li><a class="dropdown-item" href="#">My Orders</a></li>
                                            <li><hr class="dropdown-divider"></li>
                                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/Logout">Logout</a></li>
                                            </c:when>
                                            <c:otherwise>
                                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/Login">Login</a></li>
                                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/Register">Register</a></li>
                                            </c:otherwise>
                                        </c:choose>
                                </ul>
                            </div>
                        </div>
                    </div>
                </div>
            </nav>
        </header>

        <!-- Toasts dùng chung -->
        <div class="toast-container position-fixed bottom-0 end-0 p-3">
            <div id="successToast" class="toast" role="alert" aria-live="assertive" aria-atomic="true">
                <div class="toast-header bg-success text-white">
                    <strong class="me-auto">Success</strong>
                    <button type="button" class="btn-close" data-bs-dismiss="toast"></button>
                </div>
                <div class="toast-body" id="successToastBody"></div>
            </div>
            <div id="errorToast" class="toast" role="alert" aria-live="assertive" aria-atomic="true">
                <div class="toast-header bg-danger text-white">
                    <strong class="me-auto">Error</strong>
                    <button type="button" class="btn-close" data-bs-dismiss="toast"></button>
                </div>
                <div class="toast-body" id="errorToastBody"></div>
            </div>
        </div>

        <main class="flex-grow-1">
            <script>
                // Chạy sau khi Bootstrap (defer) đã nạp xong
                document.addEventListener('DOMContentLoaded', function () {
                    // 1) Safety: chủ động init tất cả dropdown
                    var toggles = document.querySelectorAll('[data-bs-toggle="dropdown"]');
                    for (var i = 0; i < toggles.length; i++) {
                        try {
                            new bootstrap.Dropdown(toggles[i]);
                        } catch (e) {
                        }
                    }

                    // 2) Search autocomplete
                    var searchInput = document.getElementById('searchInput');
                    var suggestions = document.getElementById('suggestions');
                    if (searchInput && suggestions) {
                        searchInput.addEventListener('input', function () {
                            var keyword = (searchInput.value || '').trim();
                            if (keyword.length >= 1) {
                                fetch('${pageContext.request.contextPath}/ProductList?action=autocomplete&keyword=' + encodeURIComponent(keyword))
                                        .then(function (res) {
                                            if (!res.ok)
                                                throw new Error('HTTP ' + res.status);
                                            return res.text();
                                        })
                                        .then(function (html) {
                                            suggestions.innerHTML = html;
                                            suggestions.style.display = 'block';
                                        })
                                        .catch(function () {
                                            suggestions.style.display = 'none';
                                        });
                            } else {
                                suggestions.style.display = 'none';
                            }
                        });
                        document.addEventListener('click', function (e) {
                            if (!e.target.closest('#searchInput') && !e.target.closest('#suggestions')) {
                                suggestions.style.display = 'none';
                            }
                        });
                    }

                    // 3) Toast helpers (có thể gọi từ trang con)
                    var toastSuccess = document.getElementById('successToast') ? new bootstrap.Toast(document.getElementById('successToast'), {delay: 3000}) : null;
                    var toastError = document.getElementById('errorToast') ? new bootstrap.Toast(document.getElementById('errorToast'), {delay: 3000}) : null;
                    window.showToast = function (message, isSuccess) {
                        var el = isSuccess ? document.getElementById('successToastBody') : document.getElementById('errorToastBody');
                        if (el)
                            el.textContent = message || '';
                        var t = isSuccess ? toastSuccess : toastError;
                        if (t)
                            t.show();
                    };

                    // 4) Badge giỏ hàng (global)
                    var cartCountElement = document.getElementById('cartCount');
                    window.updateCartCount = function (count) {
                        if (!cartCountElement)
                            return;
                        function apply(n) {
                            cartCountElement.textContent = n;
                            cartCountElement.classList.toggle('show', n > 0);
                            cartCountElement.classList.toggle('hide', n <= 0);
                        }
                        if (typeof count === 'number') {
                            apply(count);
                            return;
                        }
                        // fetch khi không có tham số
                        fetch('${pageContext.request.contextPath}/customer/cart/count', {
                            method: 'GET',
                            headers: {'Accept': 'application/json', 'Cache-Control': 'no-cache'}
                        })
                                .then(function (res) {
                                    if (!res.ok)
                                        throw new Error('HTTP ' + res.status);
                                    return res.json();
                                })
                                .then(function (data) {
                                    apply((data && typeof data.count === 'number') ? data.count : 0);
                                })
                                .catch(function () {
                                    apply(0);
                                });
                    };

                    // Hàm tiện ích dùng cho trang Home khi add-to-cart xong
                    window.handleAddToCartResult = function (result) {
                        if (!result)
                            return;
                        if (typeof result.cartCount !== 'undefined')
                            window.updateCartCount(result.cartCount);
                        else
                            window.updateCartCount();
                    };

                    // Đồng bộ badge lần đầu vào site
                    window.updateCartCount();
                });
            </script>
