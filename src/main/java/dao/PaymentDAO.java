package dao;

import model.Payment;
import util.DBContext;

import java.math.BigDecimal;
import java.sql.*;

public class PaymentDAO {

    /**
     * Tạo bản ghi payments = Pending
     */
    // PaymentDAO.java
    public Payment createInitPayment(long orderId, BigDecimal amount) throws SQLException {
        String sql
                = "INSERT INTO payments (order_id, amount, payment_status, transaction_id, payment_date, provider, updated_at) "
                + "VALUES (?, ?, 'Pending', NULL, SYSDATETIME(), 'VNPAY', SYSDATETIME())";

        try ( Connection c = DBContext.getNewConnection();  PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setLong(1, orderId);
            ps.setBigDecimal(2, amount == null ? BigDecimal.ZERO : amount);
            ps.executeUpdate();

            try ( ResultSet rs = ps.getGeneratedKeys()) {
                if (!rs.next()) {
                    throw new SQLException("No payment_id returned");
                }
                long pid = rs.getLong(1);
                Payment p = new Payment();
                p.setPaymentId(pid);
                p.setOrderId(orderId);
                p.setAmount(amount);
                p.setPaymentStatus("Pending");
                p.setProvider("VNPAY");
                return p;
            }
        }
    }

    /**
     * Ghi log init VNPAY (vnp_TxnRef)
     */
    public void insertVnpInitTxn(long paymentId, String vnpTxnRef, BigDecimal amount) throws SQLException {
        String sql = "INSERT INTO payment_vnpay_txns (payment_id, vnp_TxnRef, vnp_Amount, created_at, updated_at) "
                + "VALUES (?, ?, ?, SYSDATETIME(), SYSDATETIME())";
        try ( Connection c = DBContext.getNewConnection();  PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, paymentId);
            ps.setString(2, vnpTxnRef);
            ps.setBigDecimal(3, amount == null ? BigDecimal.ZERO : amount);
            ps.executeUpdate();
        }
    }

    /**
     * Lưu raw params từ trang return + flag đã verify chữ ký
     */
    public void markReturn(String txnRef, String rawParams, boolean verified) throws SQLException {
        String up = "UPDATE payment_vnpay_txns SET raw_params_return=?, return_verified=?, updated_at=SYSDATETIME() WHERE vnp_TxnRef=?";
        try ( Connection c = DBContext.getNewConnection();  PreparedStatement ps = c.prepareStatement(up)) {
            ps.setString(1, rawParams);
            ps.setBoolean(2, verified);
            ps.setString(3, txnRef);
            ps.executeUpdate();
        }
    }

    /**
     * IPN thành công: cập nhật cả bảng txn & payments
     */
    // PaymentDAO.java
    public boolean markIpnSuccess(String vnpTxnRef, String transNo, BigDecimal amountVnd,
            String bankCode, Timestamp payTs,
            String respCode, String transStatus,
            String secureHash, String rawParams) throws SQLException {
        String upTxn
                = "UPDATE payment_vnpay_txns SET "
                + "  vnp_TransactionNo=?, vnp_Amount=?, vnp_BankCode=?, vnp_PayDate=?, "
                + "  vnp_ResponseCode=?, vnp_TransactionStatus=?, vnp_SecureHash=?, "
                + "  ipn_verified=1, raw_params_ipn=?, updated_at=SYSDATETIME() "
                + "WHERE vnp_TxnRef=? AND (ipn_verified IS NULL OR ipn_verified=0)";

        String upPay
                = "UPDATE payments SET payment_status='Success', amount=?, transaction_id=?, payment_date=?, updated_at=SYSDATETIME() "
                + "WHERE payment_id=(SELECT payment_id FROM payment_vnpay_txns WHERE vnp_TxnRef=?)";

        try ( Connection c = DBContext.getNewConnection()) {
            c.setAutoCommit(false);
            int rows;
            try ( PreparedStatement ps1 = c.prepareStatement(upTxn)) {
                int i = 1;
                ps1.setString(i++, transNo);
                ps1.setBigDecimal(i++, (amountVnd == null ? BigDecimal.ZERO : amountVnd));
                ps1.setString(i++, bankCode);
                if (payTs != null) {
                    ps1.setTimestamp(i++, payTs);
                } else {
                    ps1.setNull(i++, Types.TIMESTAMP);
                }
                ps1.setString(i++, respCode);
                ps1.setString(i++, transStatus);
                ps1.setString(i++, secureHash);
                ps1.setString(i++, rawParams);
                ps1.setString(i, vnpTxnRef);
                rows = ps1.executeUpdate();
            }
            if (rows > 0) {
                try ( PreparedStatement ps2 = c.prepareStatement(upPay)) {
                    ps2.setBigDecimal(1, (amountVnd == null ? BigDecimal.ZERO : amountVnd));
                    ps2.setString(2, transNo);
                    if (payTs != null) {
                        ps2.setTimestamp(3, payTs);
                    } else {
                        ps2.setNull(3, Types.TIMESTAMP);
                    }
                    ps2.setString(4, vnpTxnRef);
                    ps2.executeUpdate();
                }
            }
            c.commit();
            return rows > 0; // true = lần đầu cập nhật sang success
        }
    }

    /**
     * IPN thất bại: ghi nhận kết quả
     */
    public void markIpnFailed(String txnRef, String respCode, String transStatus, String rawParams) throws SQLException {
        String upTxn = "UPDATE payment_vnpay_txns SET vnp_ResponseCode=?, vnp_TransactionStatus=?, raw_params_ipn=?, ipn_verified=1, updated_at=SYSDATETIME() "
                + "WHERE vnp_TxnRef=?";
        String upPay = "UPDATE payments SET payment_status='Failed', updated_at=SYSDATETIME() "
                + "WHERE payment_id=(SELECT payment_id FROM payment_vnpay_txns WHERE vnp_TxnRef=?)";
        try ( Connection c = DBContext.getNewConnection()) {
            c.setAutoCommit(false);
            try ( PreparedStatement ps1 = c.prepareStatement(upTxn)) {
                ps1.setString(1, respCode);
                ps1.setString(2, transStatus);
                ps1.setString(3, rawParams);
                ps1.setString(4, txnRef);
                ps1.executeUpdate();
            }
            try ( PreparedStatement ps2 = c.prepareStatement(upPay)) {
                ps2.setString(1, txnRef);
                ps2.executeUpdate();
            }
            c.commit();
        }
    }

    /**
     * Hỗ trợ dùng với TxnRef dạng ORD{orderId}-yyyyMMddHHmmss
     */
    public Long extractOrderIdFromTxnRef(String txnRef) {
        try {
            if (txnRef != null && txnRef.startsWith("ORD")) {
                String mid = txnRef.substring(3);
                int dash = mid.indexOf('-');
                String idStr = (dash > 0) ? mid.substring(0, dash) : mid;
                return Long.valueOf(idStr);
            }
        } catch (Exception ignore) {
        }
        return null;
    }

    // ===== Giữ lại 2 hàm cũ để có thể tái sử dụng nếu cần =====
    public void markSuccess(long paymentId, String txnNo) throws SQLException {
        String sql = "UPDATE payments SET payment_status='Success', transaction_id=?, payment_date=SYSDATETIME(), updated_at=SYSDATETIME() WHERE payment_id=?";
        try ( Connection c = DBContext.getNewConnection();  PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, txnNo);
            ps.setLong(2, paymentId);
            ps.executeUpdate();
        }
    }

    public void markFailed(long paymentId) throws SQLException {
        String sql = "UPDATE payments SET payment_status='Failed', updated_at=SYSDATETIME() WHERE payment_id=?";
        try ( Connection c = DBContext.getNewConnection();  PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, paymentId);
            ps.executeUpdate();
        }
    }
}
