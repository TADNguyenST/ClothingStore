<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<link href='https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css' rel='stylesheet'>
<style>
    /* --- CSS Variables --- */
    :root {
        --primary-color: #0E4BF1;
        --panel-color: #FFF;
        --text-color: #333;
        --black-light-color: #707070;
        --border-color: #E6E5E5;
        --toggle-color: #DDD;
        --title-icon-color: #FFF;
        --tran-03: all 0.3s ease;
        --tran-05: all 0.5s ease;
    }
    /* --- Global Styles --- */
    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
        font-family: 'Poppins', sans-serif;
    }
    body {
        min-height: 100vh;
        background-color: #f4f5f7;
        transition: var(--tran-05);
        margin: 0;
        overflow-x: hidden; /* Prevent horizontal scrollbar */
    }
    a {
        text-decoration: none;
    }
    /* --- Sidebar --- */
    .sidebar {
        position: fixed;
        top: 0;
        left: 0;
        height: 100%;
        width: 260px;
        padding: 10px 14px;
        background-color: white;
        border-right: 1px solid var(--border-color);
        transition: var(--tran-05);
        z-index: 100;
    }
    .sidebar.close {
        width: 88px; /* Collapse to 88px */
    }
    .sidebar.hidden {
        left: -260px; /* Completely hidden on mobile */
    }
    /* --- Sidebar Header --- */
    .sidebar-header {
        position: relative;
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 10px 0;
    }
    .sidebar .logo {
        display: flex;
        align-items: center;
    }
    .sidebar .logo i {
        font-size: 28px;
        margin-right: 5px;
        color: var(--primary-color);
    }
    .sidebar .logo span {
        font-size: 22px;
        font-weight: 600;
        color: var(--text-color);
        opacity: 1;
        transition: var(--tran-03);
    }
    .sidebar.close .logo span {
        opacity: 0;
        pointer-events: none;
    }
    /* Toggle button for sidebar */
    #btn-toggle {
        position: absolute;
        top: 50%;
        right: -25px;
        transform: translateY(-50%) rotate(180deg);
        height: 25px;
        width: 25px;
        background-color: var(--primary-color);
        color: var(--panel-color);
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 22px;
        cursor: pointer;
        transition: var(--tran-05);
    }
    .sidebar.close #btn-toggle {
        transform: translateY(-50%) rotate(0deg);
        right: -10px; /* Adjust button position when collapsed */
    }
    /* --- Sidebar Links --- */
    .sidebar-links {
        height: calc(100% - 90px);
        display: flex; /* Use flexbox to push logout to the bottom */
        flex-direction: column;
        justify-content: space-between;
        overflow-y: auto; /* Allow vertical scrolling if needed */
        padding-top: 20px;
        list-style: none;
        padding-left: 0; /* Reset padding left */
    }
    .sidebar-links a {
        display: flex;
        align-items: center;
        height: 50px;
        width: 100%;
        border-radius: 8px;
        color: var(--black-light-color);
        transition: var(--tran-03);
        padding: 0 10px; /* Add padding to avoid icon and text sticking to the edge */
    }

    .sidebar.close .sidebar-links a {
        padding: 0; /* Reset padding when collapsed */
    }

    .sidebar-links a:hover {
        background-color: var(--primary-color);
        color: var(--panel-color);
    }
    .sidebar-links i {
        min-width: 60px;
        font-size: 20px;
        display: flex;
        align-items: center;
        justify-content: center;
    }
    
    .sidebar .link-name {
        font-size: 16px;
        font-weight: 400;
        opacity: 1;
        transition: all 0.2s ease;
    }
    .sidebar.close .link-name {
        opacity: 0;
        pointer-events: none;
    }
    /* Responsive for mobile devices */
    @media (max-width: 768px) {
        .sidebar {
            left: -260px;
        }
        .sidebar.close {
            left: 0;
            width: 88px;
        }
        #btn-toggle {
            right: -20px;
        }
    }
</style>
<nav class="sidebar">
    <div class="sidebar-header">
        <a href="#" class="logo">
            <i class='bx bxs-dashboard'></i>
            <span>Admin</span>
        </a>
        <i class='bx bx-menu' id="btn-toggle"></i>
    </div>
    <ul class="sidebar-links">
        <div>
            <li>
                <a href="${pageContext.request.contextPath}/Reports">
                    <i class='bx bx-grid-alt'></i>
                    <span class="link-name">Report</span>
                </a>
            </li>
            
            <li>
                <a href="${pageContext.request.contextPath}/CustomerManagement">
                    <i class='bx bx-group'></i>
                    <span class="link-name">Customer Management</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/StaffManagement">
                    <i class='bx bx-id-card'></i>
                    <span class="link-name">Staff Management</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/ProductListAdmin?action=list">
                    <i class='bx bx-box'></i>
                    <span class="link-name">Products</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/CategoryListAdmin">
                    <i class='bx bx-category'></i>
                    <span class="link-name">Categories</span>
                </a>
            </li>
             <li>
                <a href="${pageContext.request.contextPath}/BrandListAdmin">
                    <i class='bx bx-purchase-tag-alt'></i>
                    <span class="link-name">Brands</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/Admindashboard?action=stockList&module=stock">
                    <i class='bx bx-package'></i>
                    <span class="link-name">Inventory Management</span>
                </a>
            </li>
             <li>
                <a href="${pageContext.request.contextPath}/Admindashboard?action=supplierList&module=supplier">
                    <i class='bx bx-buildings'></i>
                    <span class="link-name">Supplier Management</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/Admindashboard?action=voucherList&module=voucher">
                    <i class='bx bx-receipt'></i>
                    <span class="link-name">Voucher Management</span>
                </a>
            </li>
            <li>
                 <a href="${pageContext.request.contextPath}/StockMovement">
                    <i class='bx bxs-truck'></i>
                    <span class="link-name">Stock Movement</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/PurchaseOrderList">
                    <i class='bx bx-cart-add'></i>
                    <span class="link-name">Purchase Order Management</span>
                </a>
            </li>
            
            <div class="logout-section">
             <li class="logout-link">
                <a href="${pageContext.request.contextPath}/AdminLogout">
                    <i class='bx bx-log-out'></i>
                    <span class="link-name">Logout</span>
                </a>
            </li>
        </div>
        </div>
        
    </ul>
</nav>
<script>
    const body = document.querySelector("body"),
          sidebar = body.querySelector(".sidebar"),
          toggle = body.querySelector("#btn-toggle");

    toggle.addEventListener("click", () => {
        sidebar.classList.toggle("close");
    });

    function handleResize() {
        if (window.innerWidth <= 768) {
            sidebar.classList.add("close");
        } else {
            sidebar.classList.remove("close");
        }
    }

    // Run on page load
    handleResize();

    // Listen for resize event
    window.addEventListener("resize", handleResize);
</script>