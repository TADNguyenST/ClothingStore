<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="cpath" value="${pageContext.request.contextPath}" />

<aside class="main-sidebar">
  <section class="sidebar">
    <ul class="sidebar-menu" data-widget="tree">

      <!-- Dashboard -->
      <li class="${requestScope.currentModule == 'staff' && requestScope.currentAction == 'dashboard' ? 'active' : ''}">
        <a href="${cpath}/Staffdashboard?action=dashboard&module=staff">
          <i class="fa fa-home"></i> <span>Dashboard</span>
        </a>
      </li>

      <!-- Orders: nhấn là mở danh sách ngay (không dropdown) -->
      <li class="${requestScope.currentModule == 'order' && requestScope.currentAction == 'orderList' ? 'active' : ''}">
        <a href="${cpath}/Staffdashboard?action=orderList&module=order">
          <i class="fa fa-shopping-cart"></i> <span>Orders</span>
        </a>
      </li>

      <!-- (để nhóm bạn thêm sau) -->

      <!-- Logout -->
      <li>
        <a href="${cpath}/StaffLogout">
          <i class="fa fa-sign-out"></i> <span>Logout</span>
        </a>
      </li>
    </ul>
  </section>
</aside>
