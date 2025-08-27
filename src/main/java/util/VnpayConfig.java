// util/VnpayConfig.java
package util;

public class VnpayConfig {

    public static final String VNP_TMN_CODE = "IQQRWILO";
    public static final String VNP_HASH_SECRET = "SE0KJY4G396H57WZAR2GRNBFWKUJDUNN";
    public static final String VNP_PAY_URL = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";

    // Đổi <ClothingStore> đúng context của app
    public static final String VNP_RETURN_URL = "http://localhost:8080/ClothingStore/payments/vnpay-return";

    public static final String VNP_VERSION = "2.1.0";
    public static final String VNP_COMMAND = "pay";
    public static final String CURR_CODE = "VND";
    public static final String ORDER_TYPE = "other"; // dùng 'other' cho chắc chắn
}
