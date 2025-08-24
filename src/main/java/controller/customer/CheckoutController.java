package controller.customer;

import dao.AddressDAO;
import dao.CartItemDAO;
import dao.OrderDAO;
import dao.VoucherLookupDAO;

import DTO.VoucherSummaryDTO;
import model.Address;
import model.CartItem;
import model.Voucher;

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

    @Override
    public void init() {
        cartItemDAO = new CartItemDAO();
        orderDAO = new OrderDAO();
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
        if ("checkoutSelected".equalsIgnoreCase(action)) {
            handleCheckoutSelected(request, response, userId);
            return;
        } else if ("placeOrder".equalsIgnoreCase(action)) {
            handlePlaceOrder(request, response, userId);
            return;
        }

        response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action.");
    }

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
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .map(Long::valueOf)
                .collect(Collectors.toList());

        try {
            long customerId = cartItemDAO.getCustomerIdByUserId(userId);
            List<CartItem> items = cartItemDAO.findSelectedForCustomer(customerId, ids);
            if (items == null || items.isEmpty()) {
                req.setAttribute("error", "Selected items not found in your cart.");
                req.getRequestDispatcher("/WEB-INF/views/customer/cart/cart.jsp").forward(req, resp);
                return;
            }

            BigDecimal subtotal = items.stream()
                    .map(ci -> (ci.getUnitPrice() == null ? BigDecimal.ZERO : ci.getUnitPrice())
                    .multiply(BigDecimal.valueOf(ci.getQuantity())))
                    .reduce(BigDecimal.ZERO, BigDecimal::add);

            // free ship theo yêu cầu
            BigDecimal shippingFee = BigDecimal.ZERO;

            // Voucher (nếu có)
            BigDecimal discount = BigDecimal.ZERO;
            VoucherSummaryDTO voucherSummary = null;
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
                            voucherSummary = new VoucherSummaryDTO(
                                    v.getVoucherId(), v.getCode(), v.getName(), v.getDiscountType(),
                                    v.getDiscountValue(), v.getMinimumOrderAmount(), v.getMaximumDiscountAmount(), v.isVisibility()
                            );
                        }
                    }
                } finally {
                    vdao.close();
                }
            }

            BigDecimal total = subtotal.subtract(discount).add(shippingFee);
            if (total.signum() < 0) {
                total = BigDecimal.ZERO;
            }

            // NẠP địa chỉ của user
            AddressDAO addressDAO = new AddressDAO();
            List<Address> addresses = addressDAO.getAddressesByUserId(userId);

            // Gửi dữ liệu sang JSP
            req.setAttribute("items", items);
            req.setAttribute("subtotal", subtotal);
            req.setAttribute("discount", discount);
            req.setAttribute("shippingFee", shippingFee);
            req.setAttribute("total", total);
            req.setAttribute("voucher", voucherSummary);
            req.setAttribute("addresses", addresses);

            // giữ lại mã voucher & danh sách id cho bước placeOrder
            req.setAttribute("voucherCode", voucherCode);
            req.setAttribute("selectedCartItemIds", idsStr);

            req.getRequestDispatcher("/WEB-INF/views/customer/checkout/checkout.jsp").forward(req, resp);

        } catch (SQLException e) {
            throw new ServletException("Checkout failed: database error", e);
        }
    }

    private void handlePlaceOrder(HttpServletRequest req, HttpServletResponse resp, Long userId)
            throws IOException, ServletException {
        try {
            long customerId = cartItemDAO.getCustomerIdByUserId(userId);

            // Lấy shippingAddressId nếu user đã chọn; nếu không, fallback địa chỉ mặc định
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
                    shippingAddressId = addrs.get(0).getAddressId(); // fallback lấy dòng đầu
                }
            }
            if (shippingAddressId == null) {
                req.setAttribute("error", "Please add a shipping address before placing an order.");
                req.getRequestDispatcher("/WEB-INF/views/customer/checkout/checkout.jsp").forward(req, resp);
                return;
            }

            // Đọc danh sách cart item id: ưu tiên selectedCartItemIds, fallback cartItemIds
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
                    .map(String::trim)
                    .filter(s -> !s.isEmpty())
                    .map(Long::valueOf)
                    .collect(Collectors.toList());

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

            BigDecimal shippingFee = BigDecimal.ZERO; // free ship
            BigDecimal total = subtotal.subtract(discount).add(shippingFee);
            if (total.signum() < 0) {
                total = BigDecimal.ZERO;
            }

            String notes = req.getParameter("note");

            long orderId = orderDAO.createOrderAndClearCart(
                    customerId,
                    shippingAddressId,
                    voucherId,
                    subtotal,
                    discount,
                    total,
                    notes,
                    items,
                    ids
            );

            resp.sendRedirect(req.getContextPath() + "/customer/orders/detail?orderId=" + orderId);

        } catch (SQLException e) {
            throw new ServletException("Checkout failed: database error", e);
        }
    }

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

    private static String safe(String s) {
        return s == null ? "" : s;
    }
}
