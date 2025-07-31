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
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" integrity="sha512-DTOQO9RWCH3ppGqcWaEA1BIZOC6xxalwEsw9c2QQeAIftl+Vegovlnee1c9QX4TctnWMn13TZye+giMm8e2LwA==" crossorigin="anonymous" referrerpolicy="no-referrer" />
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <style>
            body {
                font-family: 'Poppins', sans-serif;
            }
            .main-header {
                background-color: #fff;
                border-bottom: 1px solid #e5e7eb;
                padding: 1rem 0;
            }
            .main-header .navbar-brand {
                font-size: 1.8rem;
                font-weight: 600;
                color: #1e3a8a;
            }
            .main-header .nav-link {
                color: #1e3a8a;
                font-weight: 500;
                padding: 0.5rem 1rem;
                text-transform: uppercase;
                font-size: 0.9rem;
                transition: color 0.3s ease;
            }
            .main-header .nav-link:hover {
                color: #3b82f6;
            }
            .header-actions .nav-link {
                font-size: 1.2rem;
                color: #1e3a8a;
            }
            .header-actions .nav-link:hover {
                color: #3b82f6;
            }
            .header-actions .badge {
                font-size: 0.6rem;
                padding: 0.3rem 0.5rem;
                background-color: #3b82f6;
                color: white;
            }
            .dropdown-menu {
                border-radius: 8px;
                border: 1px solid #e5e7eb;
                box-shadow: 0 4px 10px rgba(0,0,0,0.1);
                min-width: 200px;
            }
            .dropdown-item {
                font-size: 0.9rem;
                padding: 0.5rem 1.5rem;
            }
            .dropdown-item:hover {
                background-color: #f1f5f9;
                color: #1e3a8a;
            }
            .search-bar input {
                border-radius: 20px;
                padding: 0.5rem 1rem;
                font-size: 0.9rem;
            }
            #suggestions {
                border-radius: 8px;
                border: 1px solid #e5e7eb;
                background: white;
                max-height: 300px;
                overflow-y: auto;
                z-index: 1000;
                display: none;
            }
            .suggestion-item:hover {
                background-color: #f1f5f9;
            }
            .toast-container {
                z-index: 1055;
            }
        </style>
    </head>
    <body class="d-flex flex-column min-vh-100">
        <header class="main-header sticky-top">
            <nav class="navbar navbar-expand-lg">
                <div class="container">
                    <a class="navbar-brand" href="${pageContext.request.contextPath}/home">ClothingStore</a>
                    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#mainNavbar" aria-controls="mainNavbar" aria-expanded="false" aria-label="Toggle navigation">
                        <span class="navbar-toggler-icon"></span>
                    </button>
                    <div class="collapse navbar-collapse" id="mainNavbar">
                        <ul class="navbar-nav mx-auto mb-2 mb-lg-0">
                            <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/home">Home</a></li>
                                <% if (parentCategories != null && !parentCategories.isEmpty()) {
                                    for (Category parentCategory : parentCategories) {
                                        String selected = (selectedParentCategoryId != null && selectedParentCategoryId.equals(String.valueOf(parentCategory.getCategoryId()))) ? "active" : "";
                                %>
                            <li class="nav-item dropdown <%= selected%>">
                                <a class="nav-link dropdown-toggle" href="#" id="<%= parentCategory.getName().toLowerCase().replaceAll(" ", "")%>Dropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                                    <%= parentCategory.getName()%>
                                </a>
                                <ul class="dropdown-menu" aria-labelledby="<%= parentCategory.getName().toLowerCase().replaceAll(" ", "")%>Dropdown">
                                    <% List<Category> subCategories = new ArrayList<>();
                                        for (Category cat : allCategories) {
                                            if (cat.getParentCategoryId() != null && cat.getParentCategoryId().equals(parentCategory.getCategoryId()) && cat.isActive()) {
                                                subCategories.add(cat);
                                            }
                                        }
                                        if (!subCategories.isEmpty()) {
                                            for (Category subCategory : subCategories) {
                                    %>
                                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/ProductList?categoryId=<%= subCategory.getCategoryId()%>&parentCategoryId=<%= parentCategory.getCategoryId()%>"><%= subCategory.getName()%></a></li>
                                        <% }
                                            }
                                        %>
                                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/ProductList?parentCategoryId=<%= parentCategory.getCategoryId()%>">Shop All <%= parentCategory.getName()%></a></li>
                                </ul>
                            </li>
                            <% }
                        } %>
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
                            <a href="${pageContext.request.contextPath}/customer/cart" class="nav-link position-relative cart-link">
                                <i class="fas fa-shopping-bag"></i>
                                <span id="cartCount" class="badge rounded-pill bg-primary text-white">0</span>
                            </a>
                            <div class="nav-item dropdown user-dropdown ms-3">
                                <a class="nav-link dropdown-toggle" href="#" id="userAccountDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
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
            </nav>
        </header>

        <!-- Toast Container -->
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
            <script src="https://code.jquery.com/jquery-3.6.0.min.js" integrity="sha256-/xUj+3OJU5yExlq6GSYGSHk7tPXikynS7ogEvDej/m4=" crossorigin="anonymous"></script>
            <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-0pUGZvbkm6XF6gxjEnlmuGrJXVbNuzT9qBBavbLwCsOGabYfZo0T0to5eqruptLy" crossorigin="anonymous"></script>
            <script>
                $(document).ready(function () {
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
                $(document).click(function (e) {
                if (!$(e.target).closest('#searchInput, #suggestions').length) {
                $("#suggestions").hide();
                }
                });
                });
                const allCategories = [
                <% if (allCategories != null) {
                        for (Category cat : allCategories) {
                            if (cat.getParentCategoryId() != null) {
                %>
                { id: <%= cat.getCategoryId() %>, name: "<%= cat.getName() %>", parentId: <%= cat.getParentCategoryId() %> },
                <% }
                        }
                    } %>
                ];
                function populateChildCategories(parentId, selectedCategoryId) {
                const categorySelect = document.getElementById('categoryId');
                if (categorySelect) {
                categorySelect.innerHTML = '<option value="">All Child Categories</option>';
                const childCategories = allCategories.filter(cat => cat.parentId == parentId);
                childCategories.forEach(cat => {
                const option = document.createElement('option');
                option.value = cat.id;
                option.textContent = cat.name;
                if (cat.id == selectedCategoryId) option.selected = true;
                categorySelect.appendChild(option);
                });
                }
                }

                document.addEventListener('DOMContentLoaded', function () {
                const parentCategoryId = document.getElementById('parentCategoryId')?.value;
                if (parentCategoryId) {
                populateChildCategories(parentCategoryId, '<%= selectedCategoryId != null ? selectedCategoryId : "" %>');
                }

                var toastSuccess = new bootstrap.Toast(document.getElementById('successToast'), {delay: 3000});
                var toastError = new bootstrap.Toast(document.getElementById('errorToast'), {delay: 3000});
                var isLoggedIn = <%= session.getAttribute("user") != null ? "true" : "false" %>;
                function showToast(message, isSuccess) {
                var toast = isSuccess ? toastSuccess : toastError;
                var toastBody = document.getElementById(isSuccess ? 'successToastBody' : 'errorToastBody');
                toastBody.textContent = message;
                toast.show();
                }

                // Check login for cart link
                document.querySelectorAll('.cart-link').forEach(link => {
                link.addEventListener('click', function (e) {
                if (!isLoggedIn) {
                e.preventDefault();
                showToast('Please log in to view your cart.', false);
                setTimeout(() => {
                window.location.href = '${pageContext.request.contextPath}/Login';
                }, 1000);
                }
                });
                });
                // Handle cart count visibility based on login status
                const cartCountElement = document.getElementById('cartCount');
                if (cartCountElement) {
                if (!isLoggedIn) {
                cartCountElement.style.display = 'none';
                } else {
                cartCountElement.style.display = 'inline';
                }
                }
                // Update cart count
                function updateCartCount() {
                fetch('${pageContext.request.contextPath}/customer/cart/count', {
                method: 'GET',
                        headers: {
                        'Accept': 'application/json'
                        }
                })
                        .then(response => {
                        if (!response.ok) {
                        throw new Error('Network response was not ok: ' + response.statusText);
                        }
                        return response.json();
                        })
                        .then(data => {
                        const cartCountElement = document.getElementById('cartCount');
                        if (cartCountElement) {
                        cartCountElement.textContent = data.count || 0;
                        console.log('Cart count updated:', data.count);
                        }
                        })
                        .catch(error => {
                        console.error('Error updating cart count:', error);
                        const cartCountElement = document.getElementById('cartCount');
                        if (cartCountElement) {
                        cartCountElement.textContent = '0';
                        }
                        });
                }

                // Update cart count on page load and after cart operations
                updateCartCount();
                // Make updateCartCount globally available for other scripts
                window.updateCartCount = updateCartCount;
                });
            </script>
        </main>
    </body>
</html>