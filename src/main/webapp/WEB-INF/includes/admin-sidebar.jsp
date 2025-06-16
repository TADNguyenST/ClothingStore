<%-- src/main/webapp/WEB-INF/includes/admin-sidebar.jsp --%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<div class="sidebar">
    <div class="sidebar-header">Admin Panel</div>
    <ul class="sidebar-menu">
        <li class="header">MAIN NAVIGATION</li>

        <%-- Use requestScope.currentAction and requestScope.currentModule to activate menu items --%>
        <li class="${requestScope.currentAction eq 'home' || requestScope.currentAction == null || requestScope.currentAction eq 'dashboard' ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admindashboard?action=dashboard&module=admin">
                <i class="fa fa-dashboard"></i> <span>Dashboard</span>
            </a>
        </li>

        <li class="treeview ${requestScope.currentModule eq 'category' ? 'active menu-open' : ''}">
            <a href="#">
                <i class="fa fa-th"></i> <span>Category Management</span>
                <span class="pull-right-container"><i class="fa fa-angle-left pull-right"></i></span>
            </a>
            <ul class="treeview-menu">
                <li class="${requestScope.currentAction eq 'categoryList' ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/admindashboard?action=categoryList&module=category"><i class="fa fa-circle-o"></i> Category List</a>
                </li>
                <li class="${requestScope.currentAction eq 'categoryForm' ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/admindashboard?action=categoryForm&module=category"><i class="fa fa-circle-o"></i> Add New Category</a>
                </li>
                <li class="${requestScope.currentAction eq 'categoryDetails' ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/admindashboard?action=categoryDetails&module=category"><i class="fa fa-circle-o"></i> Category Details</a>
                </li>
            </ul>
        </li>

        <li class="treeview ${requestScope.currentModule eq 'mangestaff' ? 'active menu-open' : ''}">
            <a href="#">
                <i class="fa fa-user-secret"></i> <span>Staff Account Management</span>
                <span class="pull-right-container"><i class="fa fa-angle-left pull-right"></i></span>
            </a>
            <ul class="treeview-menu">
                <li class="${requestScope.currentAction eq 'staffList' ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/admindashboard?action=staffList&module=mangestaff"><i class="fa fa-circle-o"></i> Account List</a>
                </li>
                <li class="${requestScope.currentAction eq 'staffForm' ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/admindashboard?action=staffForm&module=mangestaff"><i class="fa fa-circle-o"></i> Add New Account</a>
                </li>
                <li class="${requestScope.currentAction eq 'staffDetails' ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/admindashboard?action=staffDetails&module=mangestaff"><i class="fa fa-circle-o"></i> Account Details</a>
                </li>
            </ul>
        </li>

        <li class="treeview ${requestScope.currentModule eq 'voucher' ? 'active menu-open' : ''}">
            <a href="#">
                <i class="fa fa-ticket"></i> <span>Voucher Management</span>
                <span class="pull-right-container"><i class="fa fa-angle-left pull-right"></i></span>
            </a>
            <ul class="treeview-menu">
                <li class="${requestScope.currentAction eq 'voucherList' ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/admindashboard?action=voucherList&module=voucher"><i class="fa fa-circle-o"></i> Voucher List</a>
                </li>
                <li class="${requestScope.currentAction eq 'voucherForm' ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/admindashboard?action=voucherForm&module=voucher"><i class="fa fa-circle-o"></i> Create New Voucher</a>
                </li>
                <li class="${requestScope.currentAction eq 'sendVoucher' ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/admindashboard?action=sendVoucher&module=voucher"><i class="fa fa-circle-o"></i> Send Voucher</a>
                </li>
                <li class="${requestScope.currentAction eq 'voucherDetails' ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/admindashboard?action=voucherDetails&module=voucher"><i class="fa fa-circle-o"></i> Voucher Details</a>
                </li>
            </ul>
        </li>

        <%-- NOTE: C c module d??i ? y (product, order, blog, customer, feedback, revenue, stock, supplier) --%>
        <%-- B?n ?  n i ch ng n?m trong th? m?c 'staff' trong WEB-INF/views/staff/ --%>
        <%-- V  v?y, ???ng d?n trong href c?a ch ng v?n l  /admindashboard v  module t??ng ?ng --%>
        <%-- ?i?u ch?nh `currentModule` trong Controller ?? kh?p v?i t n th? m?c `staff` khi c?n --%>

        <li class="treeview ${requestScope.currentModule eq 'product' ? 'active menu-open' : ''}">
            <a href="#">
                <i class="fa fa-cubes"></i> <span>Product Management</span>
                <span class="pull-right-container"><i class="fa fa-angle-left pull-right"></i></span>
            </a>
            <ul class="treeview-menu">
                <li class="${requestScope.currentAction eq 'productList' ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/admindashboard?action=productList&module=product"><i class="fa fa-circle-o"></i> Product List</a>
                </li>
                <li class="${requestScope.currentAction eq 'productForm' ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/admindashboard?action=productForm&module=product"><i class="fa fa-circle-o"></i> Add New Product</a>
                </li>
            </ul>
        </li>

        <li class="treeview ${requestScope.currentModule eq 'order' ? 'active menu-open' : ''}">
            <a href="#">
                <i class="fa fa-shopping-cart"></i> <span>Order Management</span>
                <span class="pull-right-container"><i class="fa fa-angle-left pull-right"></i></span>
            </a>
            <ul class="treeview-menu">
                <li class="${requestScope.currentAction eq 'orderList' ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/admindashboard?action=orderList&module=order"><i class="fa fa-circle-o"></i> Order List</a>
                </li>
                <li class="${requestScope.currentAction eq 'orderDetails' ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/admindashboard?action=orderDetails&module=order"><i class="fa fa-circle-o"></i> Order Details</a>
                </li>
            </ul>
        </li>

        <li class="treeview ${requestScope.currentModule eq 'blog' ? 'active menu-open' : ''}">
            <a href="#">
                <i class="fa fa-pencil-square-o"></i> <span>Blog Management</span>
                <span class="pull-right-container"><i class="fa fa-angle-left pull-right"></i></span>
            </a>
            <ul class="treeview-menu">
                <li class="${requestScope.currentAction eq 'blogList' ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/admindashboard?action=blogList&module=blog"><i class="fa fa-circle-o"></i> Blog List</a>
                </li>
                <li class="${requestScope.currentAction eq 'blogForm' ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/admindashboard?action=blogForm&module=blog"><i class="fa fa-circle-o"></i> Blog Form</a>
                </li>
            </ul>
        </li>

        <li class="treeview ${requestScope.currentModule eq 'customer' ? 'active menu-open' : ''}">
            <a href="#">
                <i class="fa fa-users"></i> <span>Customer Management</span>
                <span class="pull-right-container"><i class="fa fa-angle-left pull-right"></i></span>
            </a>
            <ul class="treeview-menu">
                <li class="${requestScope.currentAction eq 'customerList' ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/admindashboard?action=customerList&module=customer"><i class="fa fa-circle-o"></i> Customer List</a>
                </li>
                <li class="${requestScope.currentAction eq 'customerDetails' ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/admindashboard?action=customerDetails&module=customer"><i class="fa fa-circle-o"></i> Customer Details</a>
                </li>
                <li class="${requestScope.currentAction eq 'customerOrderHistory' ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/admindashboard?action=customerOrderHistory&module=customer"><i class="fa fa-circle-o"></i> Order History</a>
                </li>
            </ul>
        </li>

        <li class="treeview ${requestScope.currentModule eq 'feedback' ? 'active menu-open' : ''}">
            <a href="#">
                <i class="fa fa-comment"></i> <span>Feedback Management</span>
                <span class="pull-right-container"><i class="fa fa-angle-left pull-right"></i></span>
            </a>
            <ul class="treeview-menu">
                <li class="${requestScope.currentAction eq 'feedbackList' ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/admindashboard?action=feedbackList&module=feedback"><i class="fa fa-circle-o"></i> Feedback List</a>
                </li>
                <li class="${requestScope.currentAction eq 'viewFeedback' ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/admindashboard?action=viewFeedback&module=feedback"><i class="fa fa-circle-o"></i> View Feedback</a>
                </li>
                <li class="${requestScope.currentAction eq 'feedbackReplyForm' ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/admindashboard?action=feedbackReplyForm&module=feedback"><i class="fa fa-circle-o"></i> Reply Feedback</a>
                </li>
            </ul>
        </li>

        <li class="treeview ${requestScope.currentModule eq 'revenue' ? 'active menu-open' : ''}">
            <a href="#">
                <i class="fa fa-dollar"></i> <span>Revenue Management</span>
                <span class="pull-right-container"><i class="fa fa-angle-left pull-right"></i></span>
            </a>
            <ul class="treeview-menu">
                <li class="${requestScope.currentAction eq 'bestSellingProducts' ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/admindashboard?action=bestSellingProducts&module=revenue"><i class="fa fa-circle-o"></i> Best Selling Products</a>
                </li>
                <li class="${requestScope.currentAction eq 'revenueByProduct' ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/admindashboard?action=revenueByProduct&module=revenue"><i class="fa fa-circle-o"></i> Revenue by Product</a>
                </li>
            </ul>
        </li>

        <li class="treeview ${requestScope.currentModule eq 'stock' ? 'active menu-open' : ''}">
            <a href="#">
                <i class="fa fa-database"></i> <span>Stock Management</span>
                <span class="pull-right-container"><i class="fa fa-angle-left pull-right"></i></span>
            </a>
            <ul class="treeview-menu">
                <li class="${requestScope.currentAction eq 'stockList' ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/admindashboard?action=stockList&module=stock"><i class="fa fa-circle-o"></i> Stock List</a>
                </li>
                <li class="${requestScope.currentAction eq 'importStock' ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/admindashboard?action=importStock&module=stock"><i class="fa fa-circle-o"></i> Import Stock</a>
                </li>
                <li class="${requestScope.currentAction eq 'stockDetails' ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/admindashboard?action=stockDetails&module=stock"><i class="fa fa-circle-o"></i> Stock Details</a>
                </li>
                <li class="${requestScope.currentAction eq 'stockStatistics' ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/admindashboard?action=stockStatistics&module=stock"><i class="fa fa-circle-o"></i> Stock Statistics</a>
                </li>
            </ul>
        </li>
        <li class="treeview ${requestScope.currentModule eq 'supplier' ? 'active menu-open' : ''}">
            <a href="#">
                <i class="fa fa-truck"></i> <span>Supplier Management</span>
                <span class="pull-right-container"><i class="fa fa-angle-left pull-right"></i></span>
            </a>
            <ul class="treeview-menu">
                <li class="${requestScope.currentAction eq 'supplierList' ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/admindashboard?action=supplierList&module=supplier"><i class="fa fa-circle-o"></i> Supplier List</a>
                </li>
                <li class="${requestScope.currentAction eq 'supplierForm' ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/admindashboard?action=supplierForm&module=supplier"><i class="fa fa-circle-o"></i> Add New Supplier</a>
                </li>
                <li class="${requestScope.currentAction eq 'supplierDetails' ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/admindashboard?action=supplierDetails&module=supplier"><i class="fa fa-circle-o"></i> Supplier Details</a>
                </li>
            </ul>
        </li>
    </ul>
</div>