
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
        overflow-x: hidden; /* Ngăn thanh kéo ngang toàn trang */
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
        width: 88px; /* Thu gọn thành 88px */
        padding: 10px 0; /* Giảm padding để tránh cắt xén */
    }
    .sidebar.hidden {
        left: -260px; /* Ẩn hoàn toàn trên mobile */
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
    /* Nút thu gọn/mở rộng sidebar */
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
        right: -10px; /* Điều chỉnh vị trí nút khi thu gọn */
    }
    /* --- Sidebar Links --- */
    .sidebar-links {
        height: calc(100% - 90px);
    margin-left: -17px; /* Kéo sang trái 14px */
        flex-direction: column;
        justify-content: space-between;
        overflow-y: auto; /* Chỉ cho phép cuộn dọc nếu cần */
        padding-top: 20px;
        list-style: none;
    }
    .sidebar-links a {
    display: flex;
    align-items: center;
    height: 50px;
    width: 100%; /* Mặc định chiều rộng là 100% */
    border-radius: 8px; /* Tăng bo góc cho đẹp hơn */
    color: var(--black-light-color);
    transition: var(--tran-03);
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
    /* Responsive cho thiết bị di động */
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
                <a href="#">
                    <i class='bx bx-grid-alt'></i>
                    <span class="link-name">Tổng quan</span>
                </a>
            </li>
            <li>
                <a href="#">
                    <i class='bx bx-user'></i>
                    <span class="link-name">Người dùng</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/ProductListAdmin?action=list">
                    <i class='bx bx-box'></i>
                    <span class="link-name">Sản phẩm</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/CategoryListAdmin">
                    <i class='bx bx-category'></i>
                    <span class="link-name">Danh mục</span>
                </a>
            </li>
             <li>
                <a href="${pageContext.request.contextPath}/BrandListAdmin">
                    <i class='bx bx-purchase-tag-alt'></i>
                    <span class="link-name">Thương hiệu</span>
                </a>
            </li>
            <li>
                <a href="#">
                    <i class='bx bx-cart-alt'></i>
                    <span class="link-name">Đơn hàng</span>
                </a>
            </li>
            <li>
                <a href="#">
                    <i class='bx bx-pie-chart-alt-2'></i>
                    <span class="link-name">Phân tích</span>
                </a>
            </li>
            <li>
                <a href="#">
                    <i class='bx bx-cog'></i>
                    <span class="link-name">Cài đặt</span>
                </a>
            </li>
        </div>
        <li class="logout-link">
            <a href="#">
                <i class='bx bx-log-out'></i>
                <span class="link-name">Đăng xuất</span>
            </a>
        </li>
    </ul>
</nav>
<script>
    const body = document.querySelector("body"),
          sidebar = body.querySelector(".sidebar"),
          toggle = body.querySelector("#btn-toggle");

    toggle.addEventListener("click", () => {
        sidebar.classList.toggle("close");
        if (window.innerWidth <= 768) {
            sidebar.classList.toggle("hidden");
        }
    });

    // Ẩn sidebar mặc định trên màn hình nhỏ
    if (window.innerWidth <= 768) {
        sidebar.classList.add("hidden");
    }

    // Điều chỉnh khi thay đổi kích thước cửa sổ
    window.addEventListener("resize", () => {
        if (window.innerWidth <= 768) {
            sidebar.classList.add("hidden");
            sidebar.classList.remove("close");
        } else {
            sidebar.classList.remove("hidden");
        }
    });
</script>
