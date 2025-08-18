<%@page import="dao.CategoryDAO"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page import="model.Category"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    CategoryDAO cateDAO = new CategoryDAO();
    List<Category> allCategories = cateDAO.getAllCategories();
    List<Category> parentCategories = new ArrayList<>();
    if (allCategories != null) {
        for (Category cat : allCategories) {
            if (cat.getParentCategoryId() == null) {
                parentCategories.add(cat);
            }
        }
    }
    String selectedParentCategoryId = request.getParameter("parentCategoryId");
    String selectedCategoryId = request.getParameter("categoryId");
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>ClothingStore - ${pageTitle}</title>

        <!-- CSS -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
        <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">

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
                transition:opacity .3s ease, transform .3s ease;
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
        </style>
    </head>
    <body class="d-flex flex-column min-vh-100">

        <header class="main-header sticky-top">
            <!-- navbar-light để hiện icon toggler của Bootstrap -->
            <nav class="navbar navbar-expand-lg navbar-light">
                <div class="container">
                    <a class="navbar-brand" href="${pageContext.request.contextPath}/home">ClothingStore</a>

                    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#mainNavbar"
                            aria-controls="mainNavbar" aria-expanded="false" aria-label="Toggle navigation">
                        <span class="navbar-toggler-icon"></span>
                    </button>

                    <div class="collapse navbar-collapse" id="mainNavbar">
                        <ul class="navbar-nav mx-auto mb-2 mb-lg-0">
                            <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/home">Home</a></li>

                            <% if (parentCategories != null && !parentCategories.isEmpty()) {
                                 for (Category parentCategory : parentCategories) {
                                   String selected = (selectedParentCategoryId != null && selectedParentCategoryId.equals(String.valueOf(parentCategory.getCategoryId()))) ? "active" : "";
                            %>
                            <li class="nav-item dropdown <%= selected %>">
                                <a class="nav-link dropdown-toggle" href="#" id="<%= parentCategory.getName().toLowerCase().replaceAll(" ", "") %>Dropdown"
                                   role="button" data-bs-toggle="dropdown" aria-expanded="false">
                                    <%= parentCategory.getName() %>
                                </a>
                                <ul class="dropdown-menu" aria-labelledby="<%= parentCategory.getName().toLowerCase().replaceAll(" ", "") %>Dropdown">
                                    <%  List<Category> subs = new ArrayList<>();
                                        for (Category cat : allCategories) {
                                            if (cat.getParentCategoryId() != null
                                                    && cat.getParentCategoryId().equals(parentCategory.getCategoryId())
                                                    && cat.isActive()) {
                                                subs.add(cat);
                                            }
                                        }
                                        if (!subs.isEmpty()) {
                                            for (Category sub : subs) { %>
                                    <li>
                                        <a class="dropdown-item"
                                           href="${pageContext.request.contextPath}/ProductList?categoryId=<%= sub.getCategoryId() %>&parentCategoryId=<%= parentCategory.getCategoryId() %>">
                                            <%= sub.getName() %>
                                        </a>
                                    </li>
                                    <%      }
                               } %>
                                    <li>
                                        <a class="dropdown-item"
                                           href="${pageContext.request.contextPath}/ProductList?parentCategoryId=<%= parentCategory.getCategoryId() %>">
                                            Shop All <%= parentCategory.getName() %>
                                        </a>
                                    </li>
                                </ul>
                            </li>
                            <% } } %>

                            <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/ProductList/sale">Sale</a></li>
                            <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/blog">Blog</a></li>
                            <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/VoucherPublic">Voucher</a></li>
                        </ul>

                        <div class="d-flex align-items-center header-actions">
                            <div class="search-bar position-relative me-3">
                                <input type="text" id="searchInput" class="form-control" placeholder="Search products...">
                                <div id="suggestions" class="position-absolute w-100"></div>
                            </div>

                            <a href="${pageContext.request.contextPath}/wishlist?action=view" class="nav-link me-3">
                                <i class="fas fa-heart"></i>
                            </a>

                            <!-- KHÔNG chặn guest: luôn cho vào trang Cart -->
                            <a href="${pageContext.request.contextPath}/customer/cart" class="nav-link position-relative cart-link">
                                <i class="fas fa-shopping-bag"></i>
                                <span id="cartCount" class="badge rounded-pill bg-primary text-white hide">0</span>
                            </a>

                            <div class="nav-item dropdown user-dropdown ms-3">
                                <a class="nav-link dropdown-toggle" href="#" id="userAccountDropdown" role="button" data-bs-toggle="dropdown">
                                    <i class="fas fa-user"></i>
                                </a>
                                <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="userAccountDropdown">
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

        <!-- Toasts -->
        <div class="toast-container position-fixed bottom-0 end-0 p-3">
            <div id="successToast" class="toast" role="alert" aria-live="assertive" aria-atomic="true">
                <div class="toast-header bg-success text-white">
                    <strong class="me-auto">Success</strong>
                    <button type="button" class="btn-close" data-bs-dismiss="toast" aria-label="Close"></button>
                </div>
                <div class="toast-body" id="successToastBody"></div>
            </div>
            <div id="errorToast" class="toast" role="alert" aria-live="assertive" aria-atomic="true">
                <div class="toast-header bg-danger text-white">
                    <strong class="me-auto">Error</strong>
                    <button type="button" class="btn-close" data-bs-dismiss="toast" aria-label="Close"></button>
                </div>
                <div class="toast-body" id="errorToastBody"></div>
            </div>
        </div>

        <main class="flex-grow-1">
            <!-- JS -->
            <script src="https://code.jquery.com/jquery-3.6.0.min.js" crossorigin="anonymous"></script>
            <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" crossorigin="anonymous"></script>

            <script>
                (function () {
                    // ===== Bootstrap dropdown đảm bảo hoạt động =====
                    document.addEventListener('DOMContentLoaded', function () {
                        var dds = document.querySelectorAll('.dropdown-toggle');
                        for (var i = 0; i < dds.length; i++) {
                            try {
                                new bootstrap.Dropdown(dds[i]);
                            } catch (e) {
                            }
                        }
                    });

                    // ===== Search autocomplete =====
                    $(function () {
                        $("#searchInput").on("input", function () {
                            var keyword = $(this).val().trim();
                            if (keyword.length >= 1) {
                                $.ajax({
                                    url: "${pageContext.request.contextPath}/ProductList",
                                    type: "GET",
                                    data: {action: "autocomplete", keyword: keyword},
                                    success: function (data) {
                                        $("#suggestions").html(data).show();
                                    },
                                    error: function () {
                                        $("#suggestions").hide();
                                    }
                                });
                            } else {
                                $("#suggestions").hide();
                            }
                        });
                        $(document).on('click', function (e) {
                            if (!$(e.target).closest('#searchInput,#suggestions').length) {
                                $("#suggestions").hide();
                            }
                        });
                    });

                    // ===== Xuất allCategories nếu cần lọc client =====
                    const allCategories = [
                <% if (allCategories != null) {
                            for (Category cat : allCategories) {
                                if (cat.getParentCategoryId() != null) { %>
                        {id: <%= cat.getCategoryId() %>, name: "<%= cat.getName() %>", parentId: <%= cat.getParentCategoryId() %>},
                <%  }
                           }
                        } %>
                    ];
                    window.populateChildCategories = function (parentId, selectedCategoryId) {
                        const sel = document.getElementById('categoryId');
                        if (!sel)
                            return;
                        sel.innerHTML = '<option value="">All Child Categories</option>';
                        const childs = allCategories.filter(function (c) {
                            return c.parentId == parentId;
                        });
                        for (var i = 0; i < childs.length; i++) {
                            var opt = document.createElement('option');
                            opt.value = childs[i].id;
                            opt.textContent = childs[i].name;
                            if (childs[i].id == selectedCategoryId)
                                opt.selected = true;
                            sel.appendChild(opt);
                        }
                    };

                    // ===== Toast helpers (dùng chung toàn site) =====
                    var toastSuccess, toastError;
                    document.addEventListener('DOMContentLoaded', function () {
                        var s = document.getElementById('successToast');
                        var e = document.getElementById('errorToast');
                        if (s)
                            toastSuccess = new bootstrap.Toast(s, {delay: 3000});
                        if (e)
                            toastError = new bootstrap.Toast(e, {delay: 3000});
                    });
                    function showToast(message, isSuccess) {
                        var toast = isSuccess ? toastSuccess : toastError;
                        var id = isSuccess ? 'successToastBody' : 'errorToastBody';
                        var body = document.getElementById(id);
                        if (body)
                            body.textContent = message || '';
                        if (toast)
                            toast.show();
                    }
                    window.showToast = showToast;

                    // ===== Cart badge: guest = 0; logged-in fetch count =====
                    var cartCountElement = null;
                    function applyBadge(n) {
                        if (!cartCountElement)
                            return;
                        cartCountElement.textContent = n;
                        cartCountElement.classList.toggle('show', n > 0);
                        cartCountElement.classList.toggle('hide', n <= 0);
                    }
                    function updateCartCount(count) {
                        if (typeof count === 'number') {
                            applyBadge(count);
                        } else {
                            fetch('${pageContext.request.contextPath}/customer/cart/count', {
                                method: 'GET',
                                headers: {'Accept': 'application/json', 'Cache-Control': 'no-cache'}
                            })
                                    .then(function (res) {
                                        return res.ok ? res.json() : {count: 0};
                                    })
                                    .then(function (data) {
                                        applyBadge((data && typeof data.count === 'number') ? data.count : 0);
                                    })
                                    .catch(function () {
                                        applyBadge(0);
                                    });
                        }
                    }
                    window.updateCartCount = updateCartCount;

                    // Gọi khi load trang
                    document.addEventListener('DOMContentLoaded', function () {
                        cartCountElement = document.getElementById('cartCount');
                        updateCartCount(); // auto fetch
                    });

                    // Hàm tiện ích gọi sau khi ADD TO CART (AJAX) ở bất kỳ trang nào
                    window.handleAddToCartResult = function (result) {
                        if (result && typeof result.cartCount !== 'undefined') {
                            updateCartCount(result.cartCount);
                        }
                        if (result && result.message)
                            showToast(result.message, !!result.success);
                    };
                })();
            </script>
        </main>
    </body>
</html>
