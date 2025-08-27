package controller.payment;

import dao.OrderDAO;
import dao.PaymentDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import util.VnpayConfig;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.*;

@WebServlet("/payments/vnpay-return")
public class VnPayReturnController extends HttpServlet {

    private PaymentDAO paymentDAO;
    private OrderDAO orderDAO;

    @Override
    public void init() {
        paymentDAO = new PaymentDAO();
        orderDAO = new OrderDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Map<String, String[]> params = req.getParameterMap();
        String txnRef = req.getParameter("vnp_TxnRef");
        if (txnRef == null || txnRef.isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing vnp_TxnRef");
            return;
        }

        boolean verified = verifySignature(params, VnpayConfig.VNP_HASH_SECRET);
        String raw = req.getQueryString(); // keep raw query for audit

        try {
            paymentDAO.markReturn(txnRef, raw, verified);
        } catch (Exception e) {
            throw new ServletException(e);
        }

        Long orderId = paymentDAO.extractOrderIdFromTxnRef(txnRef);
        if (orderId == null) {
            resp.sendRedirect(req.getContextPath() + "/customer/orders");
            return;
        }

        String respCode = req.getParameter("vnp_ResponseCode");
        String transStatus = req.getParameter("vnp_TransactionStatus");
        boolean expectSuccess = verified && "00".equals(respCode) && "00".equals(transStatus);

        // UI needs a quick status; IPN will be the source of truth later.
        try {
            if (expectSuccess) {
                orderDAO.markOrderPaid(orderId, null); // payment_status=PAID
                resp.sendRedirect(req.getContextPath() + "/customer/orders/detail?orderId=" + orderId + "&paid=1");
            } else {
                orderDAO.markOrderFailed(orderId, respCode + "/" + transStatus);
                resp.sendRedirect(req.getContextPath() + "/customer/orders/detail?orderId=" + orderId + "&payfail=1");
            }
        } catch (Exception e) {
            // Fallback: just go to detail
            resp.sendRedirect(req.getContextPath() + "/customer/orders/detail?orderId=" + orderId);
        }
    }

    // ===== Helpers =====
    private boolean verifySignature(Map<String, String[]> params, String secret) {
        try {
            Map<String, String> map = new HashMap<>();
            for (Map.Entry<String, String[]> e : params.entrySet()) {
                if (e.getValue() != null && e.getValue().length > 0) {
                    map.put(e.getKey(), e.getValue()[0]);
                }
            }
            String secureHash = map.remove("vnp_SecureHash");
            map.remove("vnp_SecureHashType");

            List<String> keys = new ArrayList<>(map.keySet());
            Collections.sort(keys);
            StringBuilder hashData = new StringBuilder();
            for (int i = 0; i < keys.size(); i++) {
                String k = keys.get(i);
                String v = map.get(k);
                if (v == null) {
                    continue;
                }
                hashData.append(k).append("=")
                        .append(URLEncoder.encode(v, StandardCharsets.US_ASCII.name()));
                if (i < keys.size() - 1) {
                    hashData.append("&");
                }
            }
            String myHash = hmacSHA512(secret, hashData.toString());
            return secureHash != null && secureHash.equalsIgnoreCase(myHash);
        } catch (Exception e) {
            return false;
        }
    }

    private String hmacSHA512(String key, String data) throws Exception {
        Mac hmac = Mac.getInstance("HmacSHA512");
        SecretKeySpec secretKey = new SecretKeySpec(key.getBytes(StandardCharsets.UTF_8), "HmacSHA512");
        hmac.init(secretKey);
        byte[] bytes = hmac.doFinal(data.getBytes(StandardCharsets.UTF_8));
        StringBuilder sb = new StringBuilder(bytes.length * 2);
        for (byte b : bytes) {
            sb.append(String.format("%02x", b & 0xff));
        }
        return sb.toString();
    }
}
