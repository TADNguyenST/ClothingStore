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
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.*;

@WebServlet("/payments/vnpay-ipn")
public class VnPayIpnController extends HttpServlet {

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

        resp.setContentType("text/plain; charset=UTF-8");

        Map<String, String[]> params = req.getParameterMap();
        String txnRef = req.getParameter("vnp_TxnRef");
        if (txnRef == null || txnRef.isEmpty()) {
            resp.getWriter().write("INVALID: missing vnp_TxnRef");
            return;
        }

        // 1) Verify checksum
        boolean verified = verifySignature(params, VnpayConfig.VNP_HASH_SECRET);
        if (!verified) {
            resp.getWriter().write("INVALID CHECKSUM");
            return;
        }

        // 2) Read main params
        String respCode = getParam(params, "vnp_ResponseCode");
        String transStatus = getParam(params, "vnp_TransactionStatus");
        String transNo = getParam(params, "vnp_TransactionNo");
        String amountStr = getParam(params, "vnp_Amount");
        String bankCode = getParam(params, "vnp_BankCode");
        String payDateStr = getParam(params, "vnp_PayDate");
        String secureHash = getParam(params, "vnp_SecureHash");
        String raw = req.getQueryString();

        // Parse amount from VNPay (vnp_Amount is x100)
        BigDecimal amountVnd = BigDecimal.ZERO;
        try {
            long a = Long.parseLong(amountStr == null ? "0" : amountStr);
            amountVnd = new BigDecimal(a).divide(new BigDecimal(100)); // VND
        } catch (Exception ignore) {
        }

        // Parse payDate (GMT+7)
        Timestamp payTs = null;
        try {
            if (payDateStr != null && !payDateStr.isEmpty()) {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");
                sdf.setTimeZone(TimeZone.getTimeZone("GMT+7"));
                payTs = new Timestamp(sdf.parse(payDateStr).getTime());
            }
        } catch (Exception ignore) {
        }

        try {
            // Extract orderId from TxnRef
            Long orderId = paymentDAO.extractOrderIdFromTxnRef(txnRef);

            // Validate amount vs order total (if we can resolve orderId)
            if (orderId != null) {
                try {
                    BigDecimal expected = orderDAO.getOrderTotal(orderId);
                    if (expected == null) {
                        expected = BigDecimal.ZERO;
                    }
                    // Compare as integer VND to avoid scale issues
                    if (amountVnd.setScale(0).compareTo(expected.setScale(0)) != 0) {
                        // Amount mismatch -> treat as failure no matter respCode
                        paymentDAO.markIpnFailed(txnRef, "AMOUNT_MISMATCH", respCode + "/" + transStatus, raw);
                        orderDAO.markOrderFailed(orderId, "AMOUNT_MISMATCH " + respCode + "/" + transStatus);
                        // IMPORTANT: release reserved stock since this payment is invalid
                        orderDAO.releaseReservation(orderId, "Release after VNPay amount mismatch");
                        resp.getWriter().write("INVALID AMOUNT");
                        return;
                    }
                } catch (Exception ignore) {
                    // If amount check fails unexpectedly, continue with VNPay codes
                }
            }

            boolean success = "00".equals(respCode) && "00".equals(transStatus);

            if (success) {
                // markIpnSuccess returns true only on first transition to Success
                boolean firstSuccess = paymentDAO.markIpnSuccess(
                        txnRef, transNo, amountVnd, bankCode, payTs, respCode, transStatus, secureHash, raw
                );

                if (orderId != null) {
                    // Only set payment_status=PAID (status flow is handled by staff)
                    orderDAO.markOrderPaid(orderId, amountVnd);

                    // Consume voucher once on the first success
                    if (firstSuccess) {
                        orderDAO.consumeVoucherIfAny(orderId);
                    }
                }
            } else {
                // Failure: persist and release reserved stock
                paymentDAO.markIpnFailed(txnRef, respCode, transStatus, raw);
                if (orderId != null) {
                    orderDAO.markOrderFailed(orderId, respCode + "/" + transStatus);
                    // IMPORTANT: free reserved inventory on failure
                    orderDAO.releaseReservation(orderId, "Release after VNPay failure: " + respCode + "/" + transStatus);
                }
            }

            resp.getWriter().write("OK");
        } catch (Exception e) {
            resp.getWriter().write("ERR");
        }
    }

    // ===== Helpers =====
    private String getParam(Map<String, String[]> m, String k) {
        String[] v = m.get(k);
        return (v != null && v.length > 0) ? v[0] : null;
    }

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
