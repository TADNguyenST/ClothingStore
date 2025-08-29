package controller.customer;

import dao.AddressDAO;
import dao.CartItemDAO;
import dao.OrderDAO;
import dao.PaymentDAO;
import dao.VoucherLookupDAO;
import DTO.VoucherSummaryDTO;
import model.Address;
import model.CartItem;
import model.Voucher;
import model.Payment;
import util.VnpayService;

// NEW: server-side stock check for Buy Now
import util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.SQLException;
import java.util.*;
import java.util.stream.Collectors;

@WebServlet("/customer/checkout")
public class CheckoutController extends HttpServlet {

    private CartItemDAO cartItemDAO;
    private OrderDAO orderDAO;
    private PaymentDAO paymentDAO; // added

    @Override
    public void init() {
        cartItemDAO = new CartItemDAO();
        orderDAO = new OrderDAO();
        paymentDAO = new PaymentDAO(); // added
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setAttribute("error", "Please select items from your cart first.");
        req.getRequestDispatcher("/WEB-INF/views/customer/cart/cart.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Long userId = (session != null) ? (Long) session.getAttribute("userId") : null;
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        if ((action == null || action.trim().isEmpty()) && request.getParameter("cartItemIds") != null) {
            action = "checkoutSelected";
        }

        try {
            if ("checkoutSelected".equalsIgnoreCase(action)) {
                handleCheckoutSelected(request, response, userId);
            } else if ("placeOrder".equalsIgnoreCase(action)) {
                handlePlaceOrder(request, response, userId);
            } else if ("buyNow".equalsIgnoreCase(action)) {
                handleBuyNow(request, response, userId);
            } else if ("reviewDraft".equalsIgnoreCase(action)) {
                handleReviewDraft(request, response, userId);
            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action.");
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    // Helpers: base URL + client IP
    private static String baseUrl(HttpServletRequest r) {
        String port = (r.getServerPort() == 80 || r.getServerPort() == 443) ? "" : (":" + r.getServerPort());
        return r.getScheme() + "://" + r.getServerName() + port + r.getContextPath();
    }

    private static String clientIp(HttpServletRequest r) {
        String ip = r.getHeader("X-Forwarded-For");
        return (ip != null && !ip.isEmpty()) ? ip.split(",")[0].trim() : r.getRemoteAddr();
    }

    /* ===================== CART CHECKOUT ===================== */
    private void handleCheckoutSelected(HttpServletRequest req, HttpServletResponse resp, Long userId)
            throws ServletException, IOException {

        String idsStr = req.getParameter("cartItemIds");
        String voucherCode = req.getParameter("voucherCode");

        if (idsStr == null || idsStr.trim().isEmpty()) {
            req.setAttribute("error", "No items selected.");
            req.getRequestDispatcher("/WEB-INF/views/customer/cart/cart.jsp").forward(req, resp);
            return;
        }

        List<Long> ids = Arrays.stream(idsStr.split(","))
                .map(String::trim).filter(s -> !s.isEmpty())
                .map(Long::valueOf).collect(Collectors.toList());

        try {
            long customerId = cartItemDAO.getCustomerIdByUserId(userId);
            List<CartItem> items = cartItemDAO.findSelectedForCustomer(customerId, ids);
            if (items == null || items.isEmpty()) {
                req.setAttribute("error", "Selected items not found in your cart.");
                req.getRequestDispatcher("/WEB-INF/views/customer/cart/cart.jsp").forward(req, resp);
                return;
            }

            for (CartItem ci : items) {
                if (ci.getUnitPrice() == null) {
                    ci.setUnitPrice(BigDecimal.ZERO);
                }
                ci.setTotalPrice(ci.getUnitPrice().multiply(BigDecimal.valueOf(ci.getQuantity())));
            }

            BigDecimal subtotal = items.stream()
                    .map(ci -> ci.getTotalPrice() == null ? BigDecimal.ZERO : ci.getTotalPrice())
                    .reduce(BigDecimal.ZERO, BigDecimal::add);

            BigDecimal shippingFee = BigDecimal.ZERO;

            BigDecimal discount = BigDecimal.ZERO;
            VoucherSummaryDTO voucherSummary = null;
            String voucherViewType = null;
            String voucherViewValue = null;

            String voucherCodeTrim = (voucherCode == null ? "" : voucherCode.trim());
            if (!voucherCodeTrim.isEmpty() && subtotal.signum() > 0) {
                VoucherLookupDAO vdao = new VoucherLookupDAO();
                try {
                    Voucher v = vdao.findByCodeExact(voucherCodeTrim);
                    java.sql.Date today = new java.sql.Date(System.currentTimeMillis());

                    if (v == null) {
                        req.setAttribute("voucherError", "Voucher not found.");
                    } else if (!v.isIsActive() || (v.getExpirationDate() != null && v.getExpirationDate().before(today))) {
                        req.setAttribute("voucherError", "Voucher is inactive or expired.");
                    } else if (!v.isVisibility() && !vdao.isUsableByUserId(v.getVoucherId(), userId)) {
                        req.setAttribute("voucherError", "This voucher is not available for your account.");
                    } else if (v.getMinimumOrderAmount() != null && subtotal.compareTo(v.getMinimumOrderAmount()) < 0) {
                        req.setAttribute("voucherError", "Order total does not meet the minimum requirement.");
                    } else if (v.getDiscountValue() == null) {
                        req.setAttribute("voucherError", "Invalid voucher value.");
                    } else {
                        discount = computeDiscount(subtotal, v.getDiscountType(), v.getDiscountValue(), v.getMaximumDiscountAmount());
                        voucherSummary = new VoucherSummaryDTO(
                                v.getVoucherId(), v.getCode(), v.getName(), v.getDiscountType(),
                                v.getDiscountValue(), v.getMinimumOrderAmount(), v.getMaximumDiscountAmount(), v.isVisibility()
                        );
                        voucherViewType = v.getDiscountType();
                        voucherViewValue = buildVoucherValueLabel(v.getDiscountType(), v.getDiscountValue());
                    }
                } finally {
                    vdao.close();
                }
            }

            BigDecimal total = subtotal.subtract(discount).add(shippingFee);
            if (total.signum() < 0) {
                total = BigDecimal.ZERO;
            }

            AddressDAO addressDAO = new AddressDAO();
            List<Address> addresses = addressDAO.getAddressesByUserId(userId);

            req.setAttribute("items", items);
            req.setAttribute("subtotal", subtotal);
            req.setAttribute("discount", discount);
            req.setAttribute("shippingFee", shippingFee);
            req.setAttribute("total", total);

            req.setAttribute("voucher", voucherSummary);
            req.setAttribute("voucherViewType", voucherViewType);
            req.setAttribute("voucherViewValue", voucherViewValue);
            req.setAttribute("voucherCode", voucherCodeTrim);
            req.setAttribute("addresses", addresses);
            req.setAttribute("selectedCartItemIds", idsStr);
            req.setAttribute("isDraft", false);

            req.getRequestDispatcher("/WEB-INF/views/customer/checkout/checkout.jsp").forward(req, resp);

        } catch (SQLException e) {
            throw new ServletException("Checkout failed: database error", e);
        }
    }

    /* ========================= BUY NOW -> DRAFT ========================= */
    private void handleBuyNow(HttpServletRequest req, HttpServletResponse resp, Long userId)
            throws ServletException, IOException {
        try {
            long customerId = cartItemDAO.getCustomerIdByUserId(userId);

            String variantStr = req.getParameter("variantId");
            String qtyStr = req.getParameter("quantity");
            if (variantStr == null || qtyStr == null) {
                // NEW: redirect back to product page with error flag
                String ref = req.getHeader("Referer");
                if (ref != null && !ref.isEmpty()) {
                    String sep = ref.contains("?") ? "&" : "?";
                    resp.sendRedirect(ref + sep + "err=missing");
                    return;
                }
                // Fallback
                req.setAttribute("error", "Missing variant or quantity.");
                req.getRequestDispatcher("/WEB-INF/views/customer/cart/cart.jsp").forward(req, resp);
                return;
            }

            long variantId = Long.parseLong(variantStr);
            int quantity = Math.max(1, Integer.parseInt(qtyStr));

            // SERVER-SIDE STOCK CHECK (available = quantity - reserved_quantity)
            int available = 0;
            try ( Connection c = DBContext.getNewConnection();  PreparedStatement ps = c.prepareStatement(
                    "SELECT ISNULL(quantity,0) - ISNULL(reserved_quantity,0) AS available "
                    + "FROM inventory WHERE variant_id = ?")) {
                ps.setLong(1, variantId);
                try ( ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        available = rs.getInt("available");
                    }
                }
            }

            if (available < quantity) {
                // NEW: redirect back to product page with error flag
                String ref = req.getHeader("Referer");
                if (ref != null && !ref.isEmpty()) {
                    String sep = ref.contains("?") ? "&" : "?";
                    resp.sendRedirect(ref + sep + "err=oos");
                    return;
                }
                // Fallback
                req.setAttribute("error", "This product is out of stock or not enough quantity.");
                req.getRequestDispatcher("/WEB-INF/views/customer/cart/cart.jsp").forward(req, resp);
                return;
            }

            long draftOrderId = orderDAO.createDraftOrder(customerId);
            orderDAO.insertOrderItem(draftOrderId, variantId, quantity);
            List<CartItem> items = orderDAO.loadItemsViewForOrder(draftOrderId);

            BigDecimal subtotal = items.stream()
                    .map(ci -> (ci.getUnitPrice() == null ? BigDecimal.ZERO : ci.getUnitPrice())
                    .multiply(BigDecimal.valueOf(ci.getQuantity())))
                    .reduce(BigDecimal.ZERO, BigDecimal::add);
            BigDecimal discount = BigDecimal.ZERO, shippingFee = BigDecimal.ZERO;
            BigDecimal total = subtotal.subtract(discount).add(shippingFee);
            if (total.signum() < 0) {
                total = BigDecimal.ZERO;
            }

            AddressDAO addressDAO = new AddressDAO();
            List<Address> addresses = addressDAO.getAddressesByUserId(userId);

            req.setAttribute("items", items);
            req.setAttribute("subtotal", subtotal);
            req.setAttribute("discount", discount);
            req.setAttribute("shippingFee", shippingFee);
            req.setAttribute("total", total);
            req.setAttribute("addresses", addresses);
            req.setAttribute("isDraft", true);
            req.setAttribute("draftOrderId", draftOrderId);

            req.getRequestDispatcher("/WEB-INF/views/customer/checkout/checkout.jsp").forward(req, resp);
        } catch (Exception e) {
            throw new ServletException("Buy Now (draft) failed", e);
        }
    }

    /* ========== Review draft when applying/removing voucher ========== */
    private void handleReviewDraft(HttpServletRequest req, HttpServletResponse resp, Long userId)
            throws ServletException, IOException {
        String draftStr = req.getParameter("draftOrderId");
        if (draftStr == null || draftStr.trim().isEmpty()) {
            req.setAttribute("error", "Missing draft order.");
            req.getRequestDispatcher("/WEB-INF/views/customer/cart/cart.jsp").forward(req, resp);
            return;
        }
        long draftOrderId = Long.parseLong(draftStr);

        try {
            List<CartItem> items = orderDAO.loadItemsViewForOrder(draftOrderId);
            if (items == null || items.isEmpty()) {
                req.setAttribute("error", "Draft has no items.");
                req.getRequestDispatcher("/WEB-INF/views/customer/cart/cart.jsp").forward(req, resp);
                return;
            }

            for (CartItem ci : items) {
                if (ci.getUnitPrice() == null) {
                    ci.setUnitPrice(BigDecimal.ZERO);
                }
                ci.setTotalPrice(ci.getUnitPrice().multiply(BigDecimal.valueOf(ci.getQuantity())));
            }

            BigDecimal subtotal = items.stream()
                    .map(ci -> ci.getTotalPrice() == null ? BigDecimal.ZERO : ci.getTotalPrice())
                    .reduce(BigDecimal.ZERO, BigDecimal::add);

            String voucherCode = req.getParameter("voucherCode");
            BigDecimal discount = BigDecimal.ZERO;
            VoucherSummaryDTO voucherSummary = null;
            String voucherViewType = null, voucherViewValue = null;

            if (voucherCode != null && !voucherCode.trim().isEmpty() && subtotal.signum() > 0) {
                VoucherLookupDAO vdao = new VoucherLookupDAO();
                try {
                    Voucher v = vdao.findByCodeExact(voucherCode.trim());
                    java.sql.Date today = new java.sql.Date(System.currentTimeMillis());
                    if (v == null) {
                        req.setAttribute("voucherError", "Voucher not found.");
                    } else if (!v.isIsActive() || (v.getExpirationDate() != null && v.getExpirationDate().before(today))) {
                        req.setAttribute("voucherError", "Voucher is inactive or expired.");
                    } else if (v.getMinimumOrderAmount() != null && subtotal.compareTo(v.getMinimumOrderAmount()) < 0) {
                        req.setAttribute("voucherError", "Order total does not meet the minimum requirement.");
                    } else if (v.getDiscountValue() == null) {
                        req.setAttribute("voucherError", "Invalid voucher value.");
                    } else {
                        discount = computeDiscount(subtotal, v.getDiscountType(), v.getDiscountValue(), v.getMaximumDiscountAmount());
                        voucherSummary = new VoucherSummaryDTO(
                                v.getVoucherId(), v.getCode(), v.getName(), v.getDiscountType(),
                                v.getDiscountValue(), v.getMinimumOrderAmount(), v.getMaximumDiscountAmount(), v.isVisibility()
                        );
                        voucherViewType = v.getDiscountType();
                        voucherViewValue = buildVoucherValueLabel(v.getDiscountType(), v.getDiscountValue());
                    }
                } finally {
                    vdao.close();
                }
            }

            BigDecimal shippingFee = BigDecimal.ZERO;
            BigDecimal total = subtotal.subtract(discount).add(shippingFee);
            if (total.signum() < 0) {
                total = BigDecimal.ZERO;
            }

            AddressDAO addressDAO = new AddressDAO();
            List<Address> addresses = addressDAO.getAddressesByUserId(userId);

            req.setAttribute("items", items);
            req.setAttribute("subtotal", subtotal);
            req.setAttribute("discount", discount);
            req.setAttribute("shippingFee", shippingFee);
            req.setAttribute("total", total);

            req.setAttribute("voucher", voucherSummary);
            req.setAttribute("voucherViewType", voucherViewType);
            req.setAttribute("voucherViewValue", voucherViewValue);
            req.setAttribute("voucherCode", voucherCode == null ? "" : voucherCode.trim());

            req.setAttribute("addresses", addresses);
            req.setAttribute("isDraft", true);
            req.setAttribute("draftOrderId", draftOrderId);

            req.getRequestDispatcher("/WEB-INF/views/customer/checkout/checkout.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException("Review draft failed", e);
        }
    }

    /* ========================== PLACE ORDER ========================== */
    private void handlePlaceOrder(HttpServletRequest req, HttpServletResponse resp, Long userId)
            throws IOException, ServletException {
        try {
            long customerId = cartItemDAO.getCustomerIdByUserId(userId);

            // Shipping address
            String addrStr = req.getParameter("shippingAddressId");
            Long shippingAddressId = null;
            if (addrStr != null && addrStr.trim().length() > 0) {
                try {
                    shippingAddressId = Long.valueOf(addrStr.trim());
                } catch (NumberFormatException ignore) {
                }
            }
            if (shippingAddressId == null) {
                AddressDAO addressDAO = new AddressDAO();
                List<Address> addrs = addressDAO.getAddressesByUserId(userId);
                for (Address a : addrs) {
                    if (a.isDefault()) {
                        shippingAddressId = a.getAddressId();
                        break;
                    }
                }
                if (shippingAddressId == null && !addrs.isEmpty()) {
                    shippingAddressId = addrs.get(0).getAddressId();
                }
            }
            if (shippingAddressId == null) {
                req.setAttribute("error", "Please add a shipping address before placing an order.");
                req.getRequestDispatcher("/WEB-INF/views/customer/checkout/checkout.jsp").forward(req, resp);
                return;
            }

            String draftStr = req.getParameter("draftOrderId");
            String notes = req.getParameter("note");

            // ===== Branch 1: Finalize DRAFT (Buy Now) =====
            if (draftStr != null && !draftStr.trim().isEmpty()) {
                long orderId = Long.parseLong(draftStr);

                List<CartItem> items = orderDAO.loadItemsViewForOrder(orderId);
                if (items == null || items.isEmpty()) {
                    req.setAttribute("error", "Draft has no items to place.");
                    req.getRequestDispatcher("/WEB-INF/views/customer/cart/cart.jsp").forward(req, resp);
                    return;
                }

                BigDecimal subtotal = items.stream()
                        .map(ci -> (ci.getUnitPrice() == null ? BigDecimal.ZERO : ci.getUnitPrice())
                        .multiply(BigDecimal.valueOf(ci.getQuantity())))
                        .reduce(BigDecimal.ZERO, BigDecimal::add);

                String voucherCode = req.getParameter("voucherCode");
                Long voucherId = null;
                BigDecimal discount = BigDecimal.ZERO;
                if (voucherCode != null && !voucherCode.trim().isEmpty() && subtotal.signum() > 0) {
                    VoucherLookupDAO vdao = new VoucherLookupDAO();
                    try {
                        Voucher v = vdao.findByCodeExact(voucherCode.trim());
                        if (v != null && v.isIsActive()
                                && (v.getExpirationDate() == null || !v.getExpirationDate().before(new java.sql.Date(System.currentTimeMillis())))) {
                            boolean okForUser = true;
                            if (!v.isVisibility()) {
                                okForUser = vdao.isUsableByUserId(v.getVoucherId(), userId);
                            }
                            if (okForUser && (v.getMinimumOrderAmount() == null || subtotal.compareTo(v.getMinimumOrderAmount()) >= 0)
                                    && v.getDiscountValue() != null) {
                                discount = computeDiscount(subtotal, v.getDiscountType(), v.getDiscountValue(), v.getMaximumDiscountAmount());
                                voucherId = v.getVoucherId();
                            }
                        }
                    } finally {
                        vdao.close();
                    }
                }

                BigDecimal shippingFee = BigDecimal.ZERO;
                BigDecimal total = subtotal.subtract(discount).add(shippingFee);
                if (total.signum() < 0) {
                    total = BigDecimal.ZERO;
                }

                // Finalize draft only — reserve sẽ thực hiện 1 lần duy nhất trong markOrderPaid() sau khi thanh toán thành công
                orderDAO.finalizeDraftOrder(orderId, shippingAddressId, voucherId, subtotal, discount, total, notes);

                // Create pending payment and redirect to VNPay
                Payment payment = paymentDAO.createInitPayment(orderId, total);
                String txnRef = VnpayService.buildTxnRef(orderId);
                paymentDAO.insertVnpInitTxn(payment.getPaymentId(), txnRef, total);

                String returnUrl = baseUrl(req) + "/payments/vnpay-return";
                long amountVnd = total.setScale(0, RoundingMode.DOWN).longValue();
                String payUrl = VnpayService.buildPaymentUrl(
                        txnRef, amountVnd, clientIp(req),
                        "Pay order #" + orderId, // English
                        returnUrl
                );
                resp.sendRedirect(payUrl);
                return;
            }

            // ===== Branch 2: From CART =====
            String idsStr = req.getParameter("selectedCartItemIds");
            if (idsStr == null || idsStr.trim().isEmpty()) {
                idsStr = req.getParameter("cartItemIds");
            }
            if (idsStr == null || idsStr.trim().isEmpty()) {
                req.setAttribute("error", "No items to place order.");
                req.getRequestDispatcher("/WEB-INF/views/customer/cart/cart.jsp").forward(req, resp);
                return;
            }
            List<Long> ids = Arrays.stream(idsStr.split(","))
                    .map(String::trim).filter(s -> !s.isEmpty())
                    .map(Long::valueOf).collect(Collectors.toList());

            List<CartItem> items = cartItemDAO.findSelectedForCustomer(customerId, ids);
            if (items == null || items.isEmpty()) {
                req.setAttribute("error", "Selected items not found.");
                req.getRequestDispatcher("/WEB-INF/views/customer/cart/cart.jsp").forward(req, resp);
                return;
            }

            BigDecimal subtotal = items.stream()
                    .map(ci -> (ci.getUnitPrice() == null ? BigDecimal.ZERO : ci.getUnitPrice())
                    .multiply(BigDecimal.valueOf(ci.getQuantity())))
                    .reduce(BigDecimal.ZERO, BigDecimal::add);

            String voucherCode = req.getParameter("voucherCode");
            Long voucherId = null;
            BigDecimal discount = BigDecimal.ZERO;
            if (voucherCode != null && !voucherCode.trim().isEmpty() && subtotal.signum() > 0) {
                VoucherLookupDAO vdao = new VoucherLookupDAO();
                try {
                    Voucher v = vdao.findByCodeExact(voucherCode.trim());
                    if (v != null && v.isIsActive()
                            && (v.getExpirationDate() == null || !v.getExpirationDate().before(new java.sql.Date(System.currentTimeMillis())))) {
                        boolean okForUser = true;
                        if (!v.isVisibility()) {
                            okForUser = vdao.isUsableByUserId(v.getVoucherId(), userId);
                        }
                        if (okForUser && (v.getMinimumOrderAmount() == null || subtotal.compareTo(v.getMinimumOrderAmount()) >= 0)
                                && v.getDiscountValue() != null) {
                            discount = computeDiscount(subtotal, v.getDiscountType(), v.getDiscountValue(), v.getMaximumDiscountAmount());
                            voucherId = v.getVoucherId();
                        }
                    }
                } finally {
                    vdao.close();
                }
            }

            BigDecimal shippingFee = BigDecimal.ZERO;
            BigDecimal total = subtotal.subtract(discount).add(shippingFee);
            if (total.signum() < 0) {
                total = BigDecimal.ZERO;
            }

            long orderId;
            try {
                // create order + clear cart (DAO KHÔNG reserve ở bước này)
                orderId = orderDAO.createOrderAndClearCart(
                        customerId, shippingAddressId, voucherId,
                        subtotal, discount, total, notes, items, ids
                );
            } catch (Exception ex) {
                // Insufficient stock while placing from cart -> back to cart with message
                req.setAttribute("error",
                        "Some items in your cart are no longer available. Please refresh your cart or reduce the quantity.");
                req.getRequestDispatcher("/WEB-INF/views/customer/cart/cart.jsp").forward(req, resp);
                return;
            }

            // Create pending payment and redirect VNPay
            Payment payment = paymentDAO.createInitPayment(orderId, total);
            String txnRef = VnpayService.buildTxnRef(orderId);
            paymentDAO.insertVnpInitTxn(payment.getPaymentId(), txnRef, total);

            String returnUrl = baseUrl(req) + "/payments/vnpay-return";
            long amountVnd = total.setScale(0, RoundingMode.DOWN).longValue();
            String payUrl = VnpayService.buildPaymentUrl(
                    txnRef, amountVnd, clientIp(req),
                    "Pay order #" + orderId, // English
                    returnUrl
            );
            resp.sendRedirect(payUrl);

        } catch (SQLException e) {
            throw new ServletException("Checkout failed: database error", e);
        }
    }

    /* ====================== Helpers ====================== */
    private BigDecimal computeDiscount(BigDecimal subtotal, String type, BigDecimal value, BigDecimal maxCap) {
        if (subtotal == null || subtotal.signum() <= 0 || value == null) {
            return BigDecimal.ZERO;
        }

        BigDecimal discount;
        if ("percentage".equalsIgnoreCase(safe(type))) {
            if (value.compareTo(BigDecimal.ONE) <= 0 && value.compareTo(BigDecimal.ZERO) > 0) {
                discount = subtotal.multiply(value); // 0.12 -> 12%
            } else {
                discount = subtotal.multiply(value).divide(new BigDecimal("100"), 0, RoundingMode.DOWN);
            }
        } else {
            discount = value;
        }
        if (maxCap != null && discount.compareTo(maxCap) > 0) {
            discount = maxCap;
        }
        if (discount.compareTo(subtotal) > 0) {
            discount = subtotal;
        }
        if (discount.signum() < 0) {
            discount = BigDecimal.ZERO;
        }
        return discount.setScale(0, RoundingMode.DOWN);
    }

    private String buildVoucherValueLabel(String type, BigDecimal value) {
        if (value == null) {
            return "";
        }
        if ("percentage".equalsIgnoreCase(safe(type))) {
            BigDecimal pct = (value.compareTo(BigDecimal.ONE) <= 0 && value.compareTo(BigDecimal.ZERO) >= 0)
                    ? value.multiply(new BigDecimal("100"))
                    : value;
            pct = pct.setScale(2, RoundingMode.DOWN).stripTrailingZeros();
            return pct.toPlainString() + "%";
        } else {
            return value.setScale(0, RoundingMode.DOWN).toPlainString();
        }
    }

    private static String safe(String s) {
        return (s == null) ? "" : s;
    }
}
