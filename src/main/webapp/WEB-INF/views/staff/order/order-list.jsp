<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="cpath" value="${pageContext.request.contextPath}" />

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8" />
        <title>${pageTitle != null ? pageTitle : 'Orders'}</title>
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@500;600;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"/>

        <style>
            :root{
                --brand:#0E4BF1;
                --ink:#111827;
                --muted:#6b7280;
                --line:#e5e7eb;
                --panel:#ffffff;
                --bg:#f3f4f6;
                --success:#16a34a;
                --danger:#dc2626;
                --warn:#d97706;
                --info:#0ea5e9;
                --radius:14px;
            }
            *{
                box-sizing:border-box
            }
            html,body{
                background:var(--bg);
                margin:0;
                font-family:Inter,system-ui,-apple-system,Segoe UI,Roboto,Helvetica,Arial
            }
            a{
                color:inherit
            }

            /* Layout */
            .main-content{
                margin-left:230px;
                padding:24px;
                min-height:100vh;
            }
            @media (max-width: 991px){
                .main-content{
                    margin-left:0;
                    padding:16px
                }
            }

            .card{
                background:var(--panel);
                border-radius:var(--radius);
                box-shadow:0 10px 30px rgba(17,24,39,.08);
                padding:20px;
            }
            .head{
                display:flex;
                align-items:center;
                justify-content:space-between;
                gap:12px;
                margin-bottom:14px
            }
            .title{
                font-weight:700;
                font-size:22px;
                margin:0;
                color:var(--ink)
            }
            .sub{
                color:var(--muted);
                font-weight:500;
                font-size:13px
            }

            /* Filters */
            .filters{
                display:flex;
                gap:10px;
                flex-wrap:wrap;
                margin-bottom:14px
            }
            .i,.sel{
                height:40px;
                border:1px solid var(--line);
                border-radius:10px;
                padding:0 12px;
                background:#fff;
                font:500 14px Inter;
                color:var(--ink)
            }
            .i{
                min-width:260px;
                flex:1
            }
            .btn{
                height:40px;
                display:inline-flex;
                align-items:center;
                gap:8px;
                border-radius:10px;
                border:1px solid transparent;
                padding:0 14px;
                font:700 14px Inter;
                cursor:pointer;
                text-decoration:none
            }
            .btn-primary{
                background:var(--brand);
                color:#fff
            }
            .btn-ghost{
                background:#fff;
                border-color:var(--line);
                color:var(--ink)
            }
            .btn-ghost:hover{
                background:#f9fafb
            }

            /* Table */
            .table-wrap{
                width:100%;
                overflow:auto;
                border-radius:12px;
                border:1px solid var(--line)
            }
            table{
                width:100%;
                border-collapse:separate;
                border-spacing:0
            }
            thead th{
                position:sticky;
                top:0;
                background:#f8fafc;
                border-bottom:1px solid var(--line);
                text-align:left;
                padding:12px 14px;
                color:#475569;
                font:700 12px Inter;
                text-transform:uppercase;
                letter-spacing:.04em
            }
            tbody td{
                padding:14px;
                border-bottom:1px solid var(--line);
                font:500 14px Inter;
                color:var(--ink)
            }
            tbody tr:hover{
                background:#f9fbff
            }
            .link{
                color:var(--brand);
                text-decoration:none;
                font-weight:700
            }
            .muted{
                color:var(--muted)
            }
            .money{
                font-weight:800
            }

            /* Badges */
            .badge{
                display:inline-block;
                padding:6px 10px;
                border-radius:999px;
                font:800 11px Inter;
                letter-spacing:.02em
            }
            .b-soft{
                background:#eef3ff;
                color:#2451f5
            }
            .b-info{
                background:#e0f2fe;
                color:#0369a1
            }
            .b-success{
                background:#dcfce7;
                color:#166534
            }
            .b-danger{
                background:#fee2e2;
                color:#991b1b
            }
            .b-dark{
                background:#e5e7eb;
                color:#111827
            }
            .b-warn{
                background:#fef3c7;
                color:#92400e
            }

            /* Pagination */
            .pager{
                display:flex;
                gap:6px;
                flex-wrap:wrap;
                justify-content:flex-end;
                margin-top:16px
            }
            .page-btn{
                min-width:38px;
                height:38px;
                border:1px solid var(--line);
                border-radius:10px;
                background:#fff;
                font:700 13px Inter;
                color:#ink;
                display:inline-flex;
                align-items:center;
                justify-content:center;
                text-decoration:none
            }
            .page-btn.active{
                background:var(--brand);
                border-color:var(--brand);
                color:#fff
            }
            .count-chip{
                background:#f3f4f6;
                border:1px solid var(--line);
                border-radius:999px;
                padding:6px 10px;
                font:700 12px Inter;
                color:#111
            }
        </style>
    </head>
    <body>

        <!-- Staff Sidebar -->
        <jsp:include page="/WEB-INF/views/staff/staff-sidebar.jsp" />

        <!-- Header + Content -->
        <div class="main-content">

            <div class="card">
                <div class="head">
                    <div>
                        <h2 class="title">Orders</h2>
                        <div class="sub">All orders that meet your filters</div>
                    </div>
                    <div class="count-chip">Total: ${total}</div>
                </div>

                <!-- Filters -->
                <form class="filters" method="get" action="${cpath}/Staffdashboard">
                    <input type="hidden" name="action" value="orderList"/>
                    <input type="hidden" name="module" value="order"/>

                    <input class="i" type="text" name="q" value="${fn:escapeXml(param.q)}"
                           placeholder="Search by Order ID, Recipient, or Phone"/>

                    <select class="sel" name="status" title="Order Status">
                        <option value="">Order Status: All</option>
                        <c:forEach var="s" items="${['PENDING','PROCESSING','SHIPPED','COMPLETED','CANCELED']}">
                            <option value="${s}" ${param.status==s?'selected':''}>${s}</option>
                        </c:forEach>
                    </select>

                    <!-- Staff only manages paid flows: no UNPAID/FAILED in the UI -->
                    <select class="sel" name="pay" title="Payment">
                        <option value="">Payment: All</option>
                        <c:forEach var="p" items="${['PAID','REFUND_PENDING','REFUNDED']}">
                            <option value="${p}" ${param.pay==p?'selected':''}>${p}</option>
                        </c:forEach>
                    </select>

                    <button class="btn btn-primary" type="submit"><i class="fa fa-search"></i> Search</button>

                    <c:url var="resetUrl" value="/Staffdashboard">
                        <c:param name="action" value="orderList"/>
                        <c:param name="module" value="order"/>
                    </c:url>
                    <a class="btn btn-ghost" href="${resetUrl}"><i class="fa fa-rotate-left"></i> Reset</a>
                </form>

                <!-- Table -->
                <div class="table-wrap">
                    <table>
                        <thead>
                            <tr>
                                <th>Order #</th>
                                <th>Customer</th>
                                <th>Total</th>
                                <th>Order Status</th>
                                <th>Payment</th>
                                <th>Created</th>
                                <th></th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="row" items="${orders}">
                                <c:url var="detailUrl" value="/Staffdashboard">
                                    <c:param name="action" value="orderDetails"/>
                                    <c:param name="module" value="order"/>
                                    <c:param name="id" value="${row.orderId}"/>
                                </c:url>

                                <tr onclick="location.href = '${detailUrl}'" style="cursor:pointer">
                                    <td><a class="link" href="${detailUrl}">#${row.orderId}</a></td>
                                    <td class="muted">Customer #${row.customerId}</td>
                                    <td class="money"><fmt:formatNumber value="${row.totalPrice}" type="number" groupingUsed="true"/> ₫</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${row.status=='PENDING'}"><span class="badge b-soft">PENDING</span></c:when>
                                            <c:when test="${row.status=='PROCESSING'}"><span class="badge b-info">PROCESSING</span></c:when>
                                            <c:when test="${row.status=='SHIPPED'}"><span class="badge b-info">SHIPPED</span></c:when>
                                            <c:when test="${row.status=='COMPLETED'}"><span class="badge b-success">COMPLETED</span></c:when>
                                            <c:when test="${row.status=='CANCELED'}"><span class="badge b-dark">CANCELED</span></c:when>
                                            <c:otherwise><span class="badge b-dark">${row.status}</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${row.paymentStatus=='PAID'}"><span class="badge b-success">PAID</span></c:when>
                                            <c:when test="${row.paymentStatus=='REFUND_PENDING'}"><span class="badge b-warn">REFUND&nbsp;PENDING</span></c:when>
                                            <c:when test="${row.paymentStatus=='REFUNDED'}"><span class="badge b-dark">REFUNDED</span></c:when>
                                            <c:otherwise><span class="badge b-dark">${row.paymentStatus}</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="muted">
                                        <fmt:timeZone value="GMT+7">
                                            <fmt:formatDate value="${row.createdAt}" pattern="yyyy-MM-dd HH:mm"/>
                                        </fmt:timeZone>
                                    </td>
                                    <td><a class="link" href="${detailUrl}">View <i class="fa fa-arrow-right"></i></a></td>
                                </tr>
                            </c:forEach>

                            <c:if test="${empty orders}">
                                <tr><td colspan="7" class="muted" style="text-align:center;padding:22px">No orders found.</td></tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>

                <!-- Pagination -->
                <c:if test="${pageCount > 1}">
                    <div class="pager">
                        <c:forEach var="i" begin="1" end="${pageCount}">
                            <c:url var="pageHref" value="/Staffdashboard">
                                <c:param name="action" value="orderList"/>
                                <c:param name="module" value="order"/>
                                <c:param name="q" value="${param.q}"/>
                                <c:param name="status" value="${param.status}"/>
                                <c:param name="pay" value="${param.pay}"/>
                                <c:param name="size" value="${size}"/>
                                <c:param name="page" value="${i}"/>
                            </c:url>
                            <a class="page-btn ${i==page ? 'active' : ''}" href="${pageHref}">${i}</a>
                        </c:forEach>
                    </div>
                </c:if>
            </div>
        </div>
    </body>
</html>
