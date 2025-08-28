<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="cpath" value="${pageContext.request.contextPath}" />

<link href="https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css" rel="stylesheet"/>

<style>
    :root{
        --primary-color:#0E4BF1;
        --panel-color:#FFF;
        --text-color:#333;
        --black-light-color:#707070;
        --border-color:#E6E5E5;
        --tran-03:all .3s ease;
        --tran-05:all .5s ease
    }
    *{
        margin:0;
        padding:0;
        box-sizing:border-box;
        font-family:'Poppins',sans-serif
    }
    body{
        min-height:100vh;
        background:#f4f5f7;
        transition:var(--tran-05);
        overflow-x:hidden
    }
    a{
        text-decoration:none
    }
    .sidebar{
        position:fixed;
        top:0;
        left:0;
        height:100%;
        width:260px;
        padding:10px 14px;
        background:#fff;
        border-right:1px solid var(--border-color);
        transition:var(--tran-05);
        z-index:100
    }
    .sidebar.close{
        width:88px
    }
    .sidebar-header{
        position:relative;
        display:flex;
        justify-content:space-between;
        align-items:center;
        padding:10px 0
    }
    .sidebar .logo{
        display:flex;
        align-items:center
    }
    .sidebar .logo i{
        font-size:28px;
        margin-right:5px;
        color:var(--primary-color)
    }
    .sidebar .logo span{
        font-size:22px;
        font-weight:600;
        color:var(--text-color);
        transition:var(--tran-03)
    }
    .sidebar.close .logo span{
        opacity:0;
        pointer-events:none
    }
    #btn-toggle{
        position:absolute;
        top:50%;
        right:-25px;
        transform:translateY(-50%) rotate(180deg);
        height:25px;
        width:25px;
        background:var(--primary-color);
        color:#fff;
        border-radius:50%;
        display:flex;
        align-items:center;
        justify-content:center;
        font-size:22px;
        cursor:pointer;
        transition:var(--tran-05)
    }
    .sidebar.close #btn-toggle{
        transform:translateY(-50%) rotate(0deg);
        right:-10px
    }
    .sidebar-links{
        height:calc(100% - 90px);
        display:flex;
        flex-direction:column;
        justify-content:space-between;
        overflow-y:auto;
        padding-top:20px;
        list-style:none;
        padding-left:0
    }
    .sidebar-links a{
        display:flex;
        align-items:center;
        height:50px;
        width:100%;
        border-radius:8px;
        color:var(--black-light-color);
        transition:var(--tran-03);
        padding:0 10px
    }
    .sidebar-links a:hover,.sidebar-links a.active{
        background:var(--primary-color);
        color:#fff
    }
    .sidebar-links i{
        min-width:60px;
        font-size:20px;
        display:flex;
        align-items:center;
        justify-content:center
    }
    .link-name{
        font-size:16px;
        font-weight:400;
        transition:all .2s ease
    }
    .sidebar.close .link-name{
        opacity:0;
        pointer-events:none
    }
    @media (max-width:768px){
        .sidebar{
            left:-260px
        }
        .sidebar.close{
            left:0;
            width:88px
        }
        #btn-toggle{
            right:-20px
        }
    }
</style>

<nav class="sidebar">
    <div class="sidebar-header">
        <a href="${cpath}/Staffdashboard?action=dashboard&module=staff" class="logo">
            <i class='bx bxs-dashboard'></i><span>Staff</span>
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
            <!-- Orders (STAFF) -->
            <li>
                <a href="${cpath}/Staffdashboard?action=orderList&module=order"
                   class="${requestScope.currentModule == 'order' && requestScope.currentAction == 'orderList' ? 'active' : ''}">
                    <i class='bx bx-cart-alt'></i><span class="link-name">Orders</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/PurchaseOrderList">
                    <i class='bx bx-cart-add'></i>
                    <span class="link-name">Purchase Order Management</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/Admindashboard?action=supplierList&module=supplier">
                    <i class='bx bx-buildings'></i>
                    <span class="link-name">Supplier Management</span>
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
        </div>
                    

        <div class="logout-section">
            <li class="logout-link">
                <a href="${cpath}/StaffLogout"><i class='bx bx-log-out'></i><span class="link-name">Logout</span></a>
            </li>
        </div>
    </ul>
</nav>

<script>
    (function () {
        const sidebar = document.querySelector(".sidebar");
        const toggle = document.querySelector("#btn-toggle");
        if (toggle)
            toggle.addEventListener("click", () => sidebar.classList.toggle("close"));
        function handleResize() {
            if (window.innerWidth <= 768)
                sidebar.classList.add("close");
            else
                sidebar.classList.remove("close");
        }
        handleResize();
        window.addEventListener("resize", handleResize);
    })();
</script>
