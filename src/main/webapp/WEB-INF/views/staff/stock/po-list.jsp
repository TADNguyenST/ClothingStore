<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<c:set var="pageTitle" value="Purchase Orders" scope="request"/>
<c:set var="currentModule" value="stock" scope="request"/>
<c:set var="currentAction" value="po-list" scope="request"/>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Purchase Order List</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css"/>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/daterangepicker/daterangepicker.css"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/admin-dashboard/css/admin-css.css">

  <style>
    :root{
      --brand:#4f46e5; --ink:#0f172a; --soft:#f8fafc; --hair:#e5e7eb;
      --radius:14px; --shadow:0 8px 30px rgba(2,6,23,.06);
    }
    body{ color:var(--ink); background:#fff; }

    /* layout khớp dashboard */
    .content-area{
      position:relative; margin-left:260px; padding:1.5rem;
      width:calc(100% - 260px); transition:all .5s ease; min-height:100vh;
      background:var(--soft);
    }
    .sidebar.close ~ .content-area{ margin-left:88px; width:calc(100% - 88px); }
    .sidebar.hidden ~ .content-area{ margin-left:0; width:100%; }

    /* card/box */
    .box{ background:#fff; border:1px solid var(--hair); border-radius:var(--radius); box-shadow:var(--shadow); }
    .box-header{ padding:1rem 1.25rem; border-bottom:1px solid var(--hair); }
    .box-title{ font-weight:700; letter-spacing:.2px; }

    /* filter bar */
    .filter-bar .form-control, .filter-bar .form-select{ border-radius:12px; }
    .btn-brand{ background:var(--brand); border-color:var(--brand); color:#fff; border-radius:12px; }
    .btn-brand:hover{ filter:brightness(.96); color:#fff; }
    .btn-soft{ border-radius:12px; }

    /* table modern */
    .table-modern thead th{
      background:#f3f4f6; border-bottom:1px solid var(--hair); font-weight:600; color:#374151;
    }
    .table-modern th, .table-modern td{ vertical-align:middle; padding:.85rem 1rem; }
    .table-modern tbody tr{ transition:background .2s ease; }
    .table-modern tbody tr:hover{ background:#fafafa; }

    /* status chip */
    .status-chip{ font-size:.8rem; padding:.32rem .55rem; border-radius:999px; font-weight:600; }
    .st-draft{ background:rgba(107,114,128,.18); color:#374151; }
    .st-sent{ background:rgba(59,130,246,.15); color:#1d4ed8; }
    .st-confirmed{ background:rgba(99,102,241,.15); color:#4f46e5; }
    .st-delivered{ background:rgba(34,197,94,.16); color:#166534; }
    .st-cancelled{ background:rgba(239,68,68,.16); color:#991b1b; }

    /* pagination */
    .pagination .page-link{ border-radius:10px; }
    .pagination .page-item.active .page-link{ background:var(--brand); border-color:var(--brand); }
  </style>
</head>
<body>
  <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp"/>

  <div class="main-content-wrapper">
    <main class="content-area">
      <div class="d-flex justify-content-between align-items-center mb-3">
        <h2 class="mb-0">Purchase Order List</h2>
        <a href="${pageContext.request.contextPath}/PurchaseOrder?action=startNewPO" class="btn btn-brand">
          <i class="fa-solid fa-plus me-2"></i> New Purchase Order
        </a>
      </div>

      <div class="box">
        <div class="box-body">
          <!-- Filters -->
          <form action="PurchaseOrderList" method="GET" class="filter-bar">
            <div class="row g-3 align-items-center">
              <div class="col-lg-5">
                <input type="text" class="form-control" name="searchTerm"
                       placeholder="Search by name, supplier..." value="${searchTerm}">
              </div>

              <div class="col-lg-3">
                <select name="status" class="form-select">
                  <option value="all" ${empty param.status || param.status == 'all' ? 'selected' : ''}>-- All Statuses --</option>
                  <option value="Draft" ${param.status == 'Draft' ? 'selected' : ''}>Draft</option>
                  <option value="Sent" ${param.status == 'Sent' ? 'selected' : ''}>Sent</option>
                  <option value="Confirmed" ${param.status == 'Confirmed' ? 'selected' : ''}>Confirmed</option>
                  <option value="Delivered" ${param.status == 'Delivered' ? 'selected' : ''}>Delivered</option>
                  <option value="Cancelled" ${param.status == 'Cancelled' ? 'selected' : ''}>Cancelled</option>
                </select>
              </div>

              <div class="col-lg-3">
                <input type="text" id="dateRangePicker" class="form-control" placeholder="Filter by creation date...">
                <input type="hidden" id="startDate" name="startDate" value="${startDate}">
                <input type="hidden" id="endDate" name="endDate" value="${endDate}">
              </div>

              <div class="col-lg-1 d-grid">
                <button type="submit" class="btn btn-brand btn-soft"><i class="fa-solid fa-magnifying-glass me-1"></i>Filter</button>
              </div>
            </div>
          </form>

          <!-- Table -->
          <div class="table-responsive mt-4">
            <table class="table table-modern table-hover align-middle mb-0">
              <thead>
                <tr>
                  <th style="width:10%">PO ID</th>
                  <th style="width:30%">Name/Notes</th>
                  <th style="width:20%">Supplier</th>
                  <th style="width:20%">Creation Date</th>
                  <th style="width:10%">Status</th>
                  <th style="width:10%">Actions</th>
                </tr>
              </thead>
              <tbody>
                <c:forEach var="po" items="${poList}">
                  <tr>
                    <td>#${po.get("poId")}</td>
                    <td>${po.get("notes")}</td>
                    <td>${not empty po.get("supplierName") ? po.get("supplierName") : "Unassigned"}</td>
                    <td><fmt:formatDate value="${po.get('orderDate')}" pattern="HH:mm dd/MM/yyyy"/></td>
                    <td>
                      <c:set var="status" value="${po.get('status')}"/>
                      <span class="status-chip
                        ${status == 'Draft' ? 'st-draft' : ''}
                        ${status == 'Sent' ? 'st-sent' : ''}
                        ${status == 'Confirmed' ? 'st-confirmed' : ''}
                        ${status == 'Delivered' ? 'st-delivered' : ''}
                        ${status == 'Cancelled' ? 'st-cancelled' : ''}">
                        ${status}
                      </span>
                    </td>
                    <td>
                      <a href="PurchaseOrder?action=edit&poId=${po.get('poId')}"
                         class="btn btn-outline-primary btn-sm btn-soft">
                        <c:choose>
                          <c:when test="${po.get('status') == 'Draft'}">Edit</c:when>
                          <c:otherwise>View</c:otherwise>
                        </c:choose>
                      </a>
                    </td>
                  </tr>
                </c:forEach>
              </tbody>
            </table>
          </div>

          <!-- Pagination -->
          <nav aria-label="Page navigation" class="mt-4">
            <ul class="pagination justify-content-center">
              <c:url var="prevUrl" value="PurchaseOrderList">
                <c:param name="page" value="${currentPage - 1}"/>
                <c:if test="${not empty searchTerm}"><c:param name="searchTerm" value="${searchTerm}"/></c:if>
                <c:if test="${not empty startDate}"><c:param name="startDate" value="${startDate}"/></c:if>
                <c:if test="${not empty endDate}"><c:param name="endDate" value="${endDate}"/></c:if>
                <c:if test="${not empty param.status && param.status != 'all'}"><c:param name="status" value="${param.status}"/></c:if>
              </c:url>
              <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                <a class="page-link" href="${prevUrl}">Previous</a>
              </li>

              <c:forEach begin="1" end="${totalPages}" var="i">
                <c:url var="pageUrl" value="PurchaseOrderList">
                  <c:param name="page" value="${i}"/>
                  <c:if test="${not empty searchTerm}"><c:param name="searchTerm" value="${searchTerm}"/></c:if>
                  <c:if test="${not empty startDate}"><c:param name="startDate" value="${startDate}"/></c:if>
                  <c:if test="${not empty endDate}"><c:param name="endDate" value="${endDate}"/></c:if>
                  <c:if test="${not empty param.status && param.status != 'all'}"><c:param name="status" value="${param.status}"/></c:if>
                </c:url>
                <li class="page-item ${currentPage == i ? 'active' : ''}">
                  <a class="page-link" href="${pageUrl}">${i}</a>
                </li>
              </c:forEach>

              <c:url var="nextUrl" value="PurchaseOrderList">
                <c:param name="page" value="${currentPage + 1}"/>
                <c:if test="${not empty searchTerm}"><c:param name="searchTerm" value="${searchTerm}"/></c:if>
                <c:if test="${not empty startDate}"><c:param name="startDate" value="${startDate}"/></c:if>
                <c:if test="${not empty endDate}"><c:param name="endDate" value="${endDate}"/></c:if>
                <c:if test="${not empty param.status && param.status != 'all'}"><c:param name="status" value="${param.status}"/></c:if>
              </c:url>
              <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                <a class="page-link" href="${nextUrl}">Next</a>
              </li>
            </ul>
          </nav>
        </div>
      </div>
    </main>
  </div>

  <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/moment@2.29.4/moment.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/daterangepicker/daterangepicker.min.js"></script>
  <script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>
  <script>
    $(function () {
      const startDateParam = "${startDate}";
      const endDateParam   = "${endDate}";

      $('#dateRangePicker').daterangepicker({
        opens: 'left',
        locale: { format: 'DD/MM/YYYY', cancelLabel: 'Clear' },
        ranges: {
          'Today': [moment(), moment()],
          'Last 7 Days': [moment().subtract(6, 'days'), moment()],
          'Last 30 Days': [moment().subtract(29, 'days'), moment()],
          'This Month': [moment().startOf('month'), moment().endOf('month')]
        },
        autoUpdateInput: false
      });

      if (startDateParam && endDateParam) {
        const s = moment(startDateParam, 'YYYY-MM-DD');
        const e = moment(endDateParam, 'YYYY-MM-DD');
        $('#dateRangePicker').val(s.format('DD/MM/YYYY') + ' - ' + e.format('DD/MM/YYYY'));
      }

      $('#dateRangePicker').on('apply.daterangepicker', function (ev, picker) {
        $(this).val(picker.startDate.format('DD/MM/YYYY') + ' - ' + picker.endDate.format('DD/MM/YYYY'));
        $('#startDate').val(picker.startDate.format('YYYY-MM-DD'));
        $('#endDate').val(picker.endDate.format('YYYY-MM-DD'));
        $(this).closest('form')[0].submit();
      });

      $('#dateRangePicker').on('cancel.daterangepicker', function () {
        $(this).val('');
        $('#startDate').val('');
        $('#endDate').val('');
        $(this).closest('form')[0].submit();
      });
    });
  </script>
</body>
</html>
