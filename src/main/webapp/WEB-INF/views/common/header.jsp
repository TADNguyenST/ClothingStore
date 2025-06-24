<%-- ================ FILE: /WEB-INF/views/common/header.jsp ================ --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>ClothingStore - ${pageTitle}</title>

        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">

        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Jost:wght@300;400;500;600;700&display=swap" rel="stylesheet">

        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">

        <style>
            /* CSS cho Header */
            body {
                font-family: 'Jost', sans-serif;
            }
            .announcement-bar {
                background-color: #111;
                color: #fff;
                text-align: center;
                padding: 0.75rem 1rem;
                font-size: 0.9rem;
                letter-spacing: 0.5px;
            }
            .main-header {
                background-color: #fff;
                border-bottom: 1px solid #e9e9e9;
                padding: 1.5rem 0;
            }
            .main-header .navbar-brand {
                font-size: 2rem;
                font-weight: 600;
                letter-spacing: 1px;
                color: #111;
            }
            .main-header .nav-link {
                color: #333;
                font-weight: 500;
                padding: 0.5rem 1rem !important;
                position: relative;
                text-transform: uppercase;
                font-size: 0.95rem;
                letter-spacing: 0.5px;
            }
            .main-header .nav-link::after {
                content: '';
                position: absolute;
                bottom: -5px;
                left: 50%;
                transform: translateX(-50%);
                width: 0;
                height: 2px;
                background-color: #111;
                transition: width 0.3s ease;
            }
            .main-header .nav-link:hover::after, .main-header .nav-item.active .nav-link::after {
                width: 80%;
            }
            .header-actions .nav-link {
                font-size: 1.2rem;
                color: #111;
            }
            .header-actions .nav-link:hover {
                color: #777;
            }
            .user-dropdown .dropdown-menu {
                border: 1px solid #eee;
                box-shadow: 0 0.5rem 1.5rem rgba(0,0,0,.08);
                border-radius: 0;
                padding: 0.5rem 0;
            }
            .dropdown-item {
                font-weight: 400;
                padding: 0.6rem 1.5rem;
            }
            .dropdown-item:active {
                background-color: #f0f0f0;
                color: #111;
            }
            .dropdown-menu {
                border-radius: 0;
                border: 1px solid #f0f0f0;
                box-shadow: 0 10px 20px rgba(0,0,0,0.05);
            }
        </style>
    </head>
    <body class="d-flex flex-column min-vh-100">

        <div class="announcement-bar">
            FREE SHIPPING ON ORDERS OVER $50
        </div>

        <header class="main-header sticky-top">
            <nav class="navbar navbar-expand-lg">
                <div class="container">
                    <a class="navbar-brand" href="${pageContext.request.contextPath}/home">CLOTHING</a>
                    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#mainNavbar" aria-controls="mainNavbar" aria-expanded="false" aria-label="Toggle navigation">
                        <span class="navbar-toggler-icon"></span>
                    </button>
                    <div class="collapse navbar-collapse" id="mainNavbar">
                        <ul class="navbar-nav mx-auto mb-2 mb-lg-0">
                            <li class="nav-item">
                                <a class="nav-link" href="${pageContext.request.contextPath}/home">Home</a>
                            </li>
                            <li class="nav-item dropdown">
                                <a class="nav-link dropdown-toggle" href="#" id="menDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">Men</a>
                                <ul class="dropdown-menu" aria-labelledby="menDropdown">
                                    <li><a class="dropdown-item" href="#">T-Shirts</a></li>
                                    <li><a class="dropdown-item" href="#">Jeans</a></li>
                                    <li><a class="dropdown-item" href="#">Jackets & Coats</a></li>
                                    <li><hr class="dropdown-divider"></li>
                                    <li><a class="dropdown-item" href="#">Shop All Men</a></li>
                                </ul>
                            </li>
                            <li class="nav-item dropdown">
                                <a class="nav-link dropdown-toggle" href="#" id="womenDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">Women</a>
                                <ul class="dropdown-menu" aria-labelledby="womenDropdown">
                                    <li><a class="dropdown-item" href="#">Dresses</a></li>
                                    <li><a class="dropdown-item" href="#">Tops</a></li>
                                    <li><a class="dropdown-item" href="#">Skirts</a></li>
                                    <li><hr class="dropdown-divider"></li>
                                    <li><a class="dropdown-item" href="#">Shop All Women</a></li>
                                </ul>
                            </li>
                            <li class="nav-item"><a class="nav-link" href="#">Sale</a></li>
                            <li class="nav-item"><a class="nav-link" href="#">Blog</a></li>
                        </ul>
                        <div class="d-flex align-items-center header-actions">
                            <a href="#" class="nav-link d-none d-lg-inline-block"><i class="fas fa-search"></i></a>
                            <div class="nav-item dropdown user-dropdown">
                                <a class="nav-link dropdown-toggle" href="#" id="userAccountDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false"><i class="fas fa-user"></i></a>
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
                            <a href="#" class="nav-link d-none d-lg-inline-block"><i class="fas fa-heart"></i></a>
                            <a href="${pageContext.request.contextPath}/customer/cart" class="nav-link position-relative">
                                <i class="fas fa-shopping-bag"></i>
                                <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-dark" style="font-size: 0.6em;">
                                    ${not empty cartItemCount ? cartItemCount : '0'}
                                </span>
                            </a>
                        </div>
                    </div>
                </div>
            </nav>
        </header>

        <main class="flex-grow-1">