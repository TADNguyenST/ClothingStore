<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<c:set var="pageTitle" value="Purchase Orders" scope="request"/>
<c:set var="currentModule" value="stock" scope="request"/>
<c:set var="currentAction" value="po-list" scope="request"/>

<!DOCTYPE html>
<style>
   .content-area {
        position: relative;
        margin-left: 260px;
        padding: 1.5rem;
        width: calc(100% - 260px);
        transition: all 0.5s ease;
        min-height: 100vh;
    }
    .sidebar.close ~ .content-area {
        margin-left: 88px;
        width: calc(100% - 88px);
    }
    .sidebar.hidden ~ .content-area {
        margin-left: 0;
        width: 100%;
    }
   </style> 
<html lang="en">
    <head>
        <title>Purchase Order List</title>
        <%-- Your CSS links --%>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css"/>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/daterangepicker/daterangepicker.css"/>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/admin-dashboard/css/admin-css.css">
    </head>
    <body>
        <jsp:include page="/WEB-INF/includes/admin-sidebar.jsp"/>
        <div class="main-content-wrapper">
            
            <main class="content-area">
                <div class="box">
                    <div class="box-header with-border">
                        <h3 class="box-title">Purchase Order List</h3>
                    </div>
                    <div class="box-body">
                        <div class="d-flex justify-content-end mb-4">
                            <a href="${pageContext.request.contextPath}/PurchaseOrder?action=startNewPO" class="btn btn-success">
                                <i class="fa-solid fa-plus"></i> New Purchase Order
                            </a>
                        </div>
                        
                        <%-- Updated filter form --%>
                        <form action="PurchaseOrderList" method="GET">
                            <div class="row g-3 align-items-center mb-4">
                                <div class="col-md-4">
                                    <input type="text" class="form-control" name="searchTerm" placeholder="Search by name, supplier..." value="${searchTerm}">
                                </div>
                                
                                <div class="col-md-3">
                                    <select name="status" class="form-select">
                                        <option value="all" ${empty param.status || param.status == 'all' ? 'selected' : ''}>-- All Statuses --</option>
                                        <option value="Draft" ${param.status == 'Draft' ? 'selected' : ''}>Draft</option>
                                        <option value="Sent" ${param.status == 'Sent' ? 'selected' : ''}>Sent</option>
                                        <option value="Confirmed" ${param.status == 'Confirmed' ? 'selected' : ''}>Confirmed</option>
                                        <option value="Delivered" ${param.status == 'Delivered' ? 'selected' : ''}>Delivered</option>
                                        <option value="Cancelled" ${param.status == 'Cancelled' ? 'selected' : ''}>Cancelled</option>
                                    </select>
                                </div>
                                <div class="col-md-3">
                                    <input type="text" id="dateRangePicker" class="form-control" placeholder="Filter by creation date...">
                                    <input type="hidden" id="startDate" name="startDate" value="${startDate}">
                                    <input type="hidden" id="endDate" name="endDate" value="${endDate}">
                                </div>
                                <div class="col-md-2 d-flex">
                                    <button type="submit" class="btn btn-primary w-100 me-2"><i class="fa-solid fa-search"></i> Filter</button>
                                    <a href="PurchaseOrderList" class="btn btn-secondary"><i class="fa-solid fa-eraser"></i></a>
                                </div>
                            </div>
                        </form>

                        <table class="table table-hover table-bordered">
                            <thead>
                                <tr>
                                    <th>PO ID</th>
                                    <th>Name/Notes</th>
                                    <th>Supplier</th>
                                    <th>Creation Date</th>
                                    <th>Status</th>
                                    <th>Actions</th>
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
                                            <%-- Updated status display for more variety --%>
                                            <c:set var="status" value="${po.get('status')}"/>
                                            <span class="badge 
                                                ${status == 'Draft' ? 'bg-secondary' : ''}
                                                ${status == 'Sent' ? 'bg-info' : ''}
                                                ${status == 'Confirmed' ? 'bg-primary' : ''}
                                                ${status == 'Delivered' ? 'bg-success' : ''}
                                                ${status == 'Cancelled' ? 'bg-danger' : ''}
                                            ">${status}</span>
                                        </td>
                                        <td>
                                            <a href="PurchaseOrder?action=edit&poId=${po.get('poId')}" class="btn btn-info btn-sm">
                                                <c:choose>
                                                    <c:when test="${po.get('status') == 'Draft'}">Edit</c:when>
                                                    <c:otherwise>View Details</c:otherwise>
                                                </c:choose>
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>

                        <%-- Updated pagination block --%>
                        <nav aria-label="Page navigation">
                            <ul class="pagination justify-content-center">
                                <%-- Previous Button --%>
                                <c:url var="prevUrl" value="PurchaseOrderList">
                                    <c:param name="page" value="${currentPage - 1}"/>
                                    <c:if test="${not empty searchTerm}"><c:param name="searchTerm" value="${searchTerm}"/></c:if>
                                    <c:if test="${not empty startDate}"><c:param name="startDate" value="${startDate}"/></c:if>
                                    <c:if test="${not empty endDate}"><c:param name="endDate" value="${endDate}"/></c:if>
                                    <%-- NEW: Keep status filter on page change --%>
                                    <c:if test="${not empty param.status && param.status != 'all'}"><c:param name="status" value="${param.status}"/></c:if>
                                </c:url>
                                <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                                    <a class="page-link" href="${prevUrl}">Previous</a>
                                </li>

                                <%-- Page number buttons --%>
                                <c:forEach begin="1" end="${totalPages}" var="i">
                                    <c:url var="pageUrl" value="PurchaseOrderList">
                                        <c:param name="page" value="${i}"/>
                                        <c:if test="${not empty searchTerm}"><c:param name="searchTerm" value="${searchTerm}"/></c:if>
                                        <c:if test="${not empty startDate}"><c:param name="startDate" value="${startDate}"/></c:if>
                                        <c:if test="${not empty endDate}"><c:param name="endDate" value="${endDate}"/></c:if>
                                        <%-- NEW: Keep status filter on page change --%>
                                        <c:if test="${not empty param.status && param.status != 'all'}"><c:param name="status" value="${param.status}"/></c:if>
                                    </c:url>
                                    <li class="page-item ${currentPage == i ? 'active' : ''}">
                                        <a class="page-link" href="${pageUrl}">${i}</a>
                                    </li>
                                </c:forEach>

                                <%-- Next Button --%>
                                <c:url var="nextUrl" value="PurchaseOrderList">
                                    <c:param name="page" value="${currentPage + 1}"/>
                                    <c:if test="${not empty searchTerm}"><c:param name="searchTerm" value="${searchTerm}"/></c:if>
                                    <c:if test="${not empty startDate}"><c:param name="startDate" value="${startDate}"/></c:if>
                                    <c:if test="${not empty endDate}"><c:param name="endDate" value="${endDate}"/></c:if>
                                    <%-- NEW: Keep status filter on page change --%>
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

        <%-- Your scripts --%>
        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/moment@2.29.4/moment.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/daterangepicker/daterangepicker.min.js"></script>
        <script src="${pageContext.request.contextPath}/admin-dashboard/js/admin-js.js"></script>
        <script>
            $(function () {
                const startDateParam = "${startDate}";
                const endDateParam = "${endDate}";

                $('#dateRangePicker').daterangepicker({
                    opens: 'left',
                    locale: {format: 'DD/MM/YYYY', cancelLabel: 'Clear'},
                    ranges: {
                        'Today': [moment(), moment()],
                        'Last 7 Days': [moment().subtract(6, 'days'), moment()],
                        'Last 30 Days': [moment().subtract(29, 'days'), moment()],
                        'This Month': [moment().startOf('month'), moment().endOf('month')]
                    },
                    autoUpdateInput: false
                });

                if (startDateParam && endDateParam) {
                    const start = moment(startDateParam, 'YYYY-MM-DD');
                    const end = moment(endDateParam, 'YYYY-MM-DD');
                    $('#dateRangePicker').val(start.format('DD/MM/YYYY') + ' - ' + end.format('DD/MM/YYYY'));
                }

                $('#dateRangePicker').on('apply.daterangepicker', function (ev, picker) {
                    $(this).val(picker.startDate.format('DD/MM/YYYY') + ' - ' + picker.endDate.format('DD/MM/YYYY'));
                    $('#startDate').val(picker.startDate.format('YYYY-MM-DD'));
                    $('#endDate').val(picker.endDate.format('YYYY-MM-DD'));
                    // Auto-submit form on date selection
                    $(this).closest('form').submit();
                });

                $('#dateRangePicker').on('cancel.daterangepicker', function (ev, picker) {
                    $(this).val('');
                    $('#startDate').val('');
                    $('#endDate').val('');
                    // Auto-submit form on clearing date
                    $(this).closest('form').submit();
                });
            });
        </script>
    </body>
</html>