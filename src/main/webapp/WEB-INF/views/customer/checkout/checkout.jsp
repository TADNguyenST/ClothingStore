<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<div class="container py-4">
    <h2 class="mb-3">Checkout</h2>

    <c:if test="${not empty error}">
        <div class="alert alert-danger">${error}</div>
    </c:if>

    <div class="card mb-3">
        <div class="card-header fw-bold">Shipping Address</div>
        <div class="card-body">
            <c:choose>
                <c:when test="${empty addresses}">
                    <div class="text-muted">
                        You have no saved addresses.
                        <a href="${pageContext.request.contextPath}/customer/address">Add one</a>.
                    </div>
                </c:when>
                <c:otherwise>
                    <form id="placeForm" method="post" action="${pageContext.request.contextPath}/customer/checkout">
                        <input type="hidden" name="action" value="placeOrder"/>
                        <!-- giữ lại dữ liệu để Place Order -->
                        <input type="hidden" name="selectedCartItemIds" value="${selectedCartItemIds}"/>
                        <input type="hidden" name="voucherCode" value="${voucherCode}"/>

                        <!-- Địa chỉ -->
                        <div class="vstack gap-2">
                            <c:forEach var="a" items="${addresses}">
                                <label class="border rounded p-2 d-flex align-items-start gap-2 w-100">
                                    <input type="radio"
                                           name="shippingAddressId"
                                           value="${a.addressId}"
                                           <c:if test="${a['default']}">checked="checked"</c:if> />
                                           <div>
                                               <div class="fw-semibold">
                                               ${a.recipientName}
                                               <span class="text-muted">(${a.phoneNumber})</span>
                                           </div>
                                           <div class="text-muted small">
                                               ${a.streetAddress}, ${a.wardName}, ${a.provinceName}
                                           </div>
                                           <c:if test="${a['default']}">
                                               <span class="badge bg-primary">Default</span>
                                           </c:if>
                                    </div>
                                </label>
                            </c:forEach>
                        </div>

                        <hr/>

                        <!-- Hàng hoá -->
                        <div class="table-responsive">
                            <table class="table align-middle">
                                <thead class="table-light">
                                    <tr>
                                        <th>Product</th>
                                        <th style="width:110px;">Size</th>
                                        <th style="width:110px;">Color</th>
                                        <th style="width:90px;">Qty</th>
                                        <th style="width:140px;">Unit</th>
                                        <th style="width:160px;">Line Total</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="it" items="${items}">
                                        <tr>
                                            <td>
                                                <div class="d-flex align-items-center gap-2">
                                                    <img src="${empty it.imageUrl ? 'https://placehold.co/56x56' : it.imageUrl}"
                                                         width="56" height="56" class="rounded"
                                                         onerror="this.src='https://placehold.co/56x56'"/>
                                                    <div class="fw-semibold">${it.productName}</div>
                                                </div>
                                            </td>
                                            <td>${it.size}</td>
                                            <td>${it.color}</td>
                                            <td>${it.quantity}</td>
                                            <td><span class="money" data-raw="${it.unitPrice}">₫</span></td>
                                            <td><span class="money" data-raw="${it.totalPrice}">₫</span></td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>

                        <!-- Tổng tiền -->
                        <div class="card mt-3">
                            <div class="card-body">
                                <div class="d-flex justify-content-between">
                                    <div>Subtotal</div>
                                    <div id="subtotal" class="money" data-raw="${empty subtotal ? 0 : subtotal}">₫</div>
                                </div>
                                <div class="d-flex justify-content-between">
                                    <div>Voucher discount</div>
                                    <div id="discount" class="money" data-raw="${empty discount ? 0 : discount}">₫</div>
                                </div>
                                <hr/>
                                <div class="d-flex justify-content-between fw-bold">
                                    <div>Payable</div>
                                    <div id="total" class="money" data-raw="${empty total ? 0 : total}">₫</div>
                                </div>
                            </div>
                        </div>

                        <div class="mt-3">
                            <label class="form-label">Note (optional)</label>
                            <textarea class="form-control" name="note" rows="2"
                                      placeholder="Any notes for this order..."></textarea>
                        </div>

                        <div class="d-grid gap-2 mt-3">
                            <button type="submit" class="btn btn-primary">Place Order</button>
                            <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/customer/cart">Back to Cart</a>
                        </div>
                    </form>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<script>
    (function () {
        function toNum(v) {
            if (v === null || v === undefined)
                return 0;
            if (v === 'null' || v === 'undefined' || v === '')
                return 0;
            var n = Number(String(v).replace(/[, ]+/g, ''));
            return isFinite(n) ? n : 0;
        }
        function dot(v) {
            return toNum(v).toLocaleString('vi-VN') + 'đ';
        }
        document.querySelectorAll('.money').forEach(function (el) {
            var raw = el.getAttribute('data-raw');
            el.textContent = dot(raw);
        });
    })();
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
