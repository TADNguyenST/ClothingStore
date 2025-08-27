package util;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.*;

public class VnpayService {

    /**
     * Build VNPAY payment URL (custom returnUrl).
     */
    public static String buildPaymentUrl(String vnpTxnRef,
            long amountVND,
            String ipAddr,
            String orderInfo,
            String returnUrl) {
        try {
            // Use sorted map to ensure deterministic order for hashing
            Map<String, String> vnpParams = new TreeMap<>();

            vnpParams.put("vnp_Version", VnpayConfig.VNP_VERSION);
            vnpParams.put("vnp_Command", VnpayConfig.VNP_COMMAND);
            vnpParams.put("vnp_TmnCode", VnpayConfig.VNP_TMN_CODE);

            // amount must be in VND * 100
            long safeAmount = Math.max(0L, amountVND) * 100L;
            vnpParams.put("vnp_Amount", String.valueOf(safeAmount));
            vnpParams.put("vnp_CurrCode", VnpayConfig.CURR_CODE);

            vnpParams.put("vnp_TxnRef", vnpTxnRef);

            String info = (orderInfo == null || orderInfo.trim().isEmpty())
                    ? ("Thanh toan don " + vnpTxnRef)
                    : orderInfo;
            vnpParams.put("vnp_OrderInfo", info);

            vnpParams.put("vnp_OrderType", VnpayConfig.ORDER_TYPE);

            String ret = (returnUrl == null || returnUrl.trim().isEmpty())
                    ? VnpayConfig.VNP_RETURN_URL
                    : returnUrl;
            vnpParams.put("vnp_ReturnUrl", ret);

            // Prefer IPv4; fallback to localhost
            String ip = (ipAddr == null || ipAddr.trim().isEmpty() || ipAddr.indexOf(':') >= 0)
                    ? "127.0.0.1" : ipAddr;
            vnpParams.put("vnp_IpAddr", ip);

            vnpParams.put("vnp_Locale", "vn");

            // Timestamps (GMT+7)
            SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");
            sdf.setTimeZone(TimeZone.getTimeZone("GMT+7"));
            String createDate = sdf.format(new Date());
            Calendar cal = Calendar.getInstance(TimeZone.getTimeZone("GMT+7"));
            cal.add(Calendar.MINUTE, 15);
            String expireDate = sdf.format(cal.getTime());
            vnpParams.put("vnp_CreateDate", createDate);
            vnpParams.put("vnp_ExpireDate", expireDate);

            // Build query & hash data
            StringBuilder query = new StringBuilder();
            StringBuilder hashData = new StringBuilder();

            for (Map.Entry<String, String> e : vnpParams.entrySet()) {
                String k = e.getKey();
                String val = e.getValue();
                if (val == null) {
                    continue;
                }

                // Per spec: URL-encode key and value (use ASCII)
                String kEnc = URLEncoder.encode(k, StandardCharsets.US_ASCII.name());
                String vEnc = URLEncoder.encode(val, StandardCharsets.US_ASCII.name());

                query.append(kEnc).append('=').append(vEnc).append('&');
                hashData.append(kEnc).append('=').append(vEnc).append('&');
            }

            // remove trailing '&'
            if (query.length() > 0) {
                query.setLength(query.length() - 1);
            }
            if (hashData.length() > 0) {
                hashData.setLength(hashData.length() - 1);
            }

            String secureHash = hmacSHA512(VnpayConfig.VNP_HASH_SECRET.trim(), hashData.toString());
            return VnpayConfig.VNP_PAY_URL + "?" + query + "&vnp_SecureHash=" + secureHash;

        } catch (Exception ex) {
            throw new RuntimeException("Build VNPAY URL failed", ex);
        }
    }

    /**
     * Backward-compatible overload (uses default return URL in config).
     */
    public static String buildPaymentUrl(String vnpTxnRef,
            long amountVND,
            String ipAddr,
            String orderInfo) {
        return buildPaymentUrl(
                vnpTxnRef,
                amountVND,
                ipAddr,
                orderInfo,
                VnpayConfig.VNP_RETURN_URL
        );
    }

    /**
     * Generate a simple transaction ref: ORD{orderId}-{yyyyMMddHHmmss}
     */
    public static String buildTxnRef(long orderId) {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");
        sdf.setTimeZone(TimeZone.getTimeZone("GMT+7"));
        return "ORD" + orderId + "-" + sdf.format(new Date());
    }

    private static String hmacSHA512(String key, String data) throws Exception {
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
