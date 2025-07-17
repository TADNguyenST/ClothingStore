package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

public class DBContext {

    // --- THÔNG TIN KẾT NỐI (PRIVATE ST ATIC FINAL) ---
    private static final String SERVER_NAME = "clothingstore-server-2025.database.windows.net";
    private static final String DB_NAME = "ClothingStore";
    private static final String PORT_NUMBER = "1433";
    private static final String USER_ID = "CloudSA62f9ded5";
    private static final String PASSWORD = "Dat13102004";
    private static final String URL = "jdbc:sqlserver://" + SERVER_NAME + ":" + PORT_NUMBER
            + ";databaseName=" + DB_NAME
            + ";encrypt=true;trustServerCertificate=true;hostNameInCertificate=*.database.windows.net;loginTimeout=30;";

    // --- PHẦN HỖ TRỢ CODE CŨ (ĐỂ KHÔNG GÂY LỖI) ---
    /**
     * @deprecated Biến này được giữ lại để tương thích với các DAO cũ.
     */
    @Deprecated
    protected Connection conn = null;

    public DBContext() {
        try {
            // Constructor này vẫn khởi tạo 'conn' để các DAO cũ không bị lỗi
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            this.conn = DriverManager.getConnection(URL, USER_ID, PASSWORD);
        } catch (ClassNotFoundException | SQLException ex) {
            Logger.getLogger(DBContext.class.getName()).log(Level.SEVERE, "Failed to establish initial connection in DBContext constructor", ex);
        }
    }

    /**
     * @deprecated Phương thức này được giữ lại để tương thích với các DAO cũ.
     */
    @Deprecated
    public Connection getConnection() {
        return this.conn;
    }

    /**
     * @deprecated Phương thức này được thêm lại để các servlet cũ không bị lỗi
     * khi gọi destroy().
     */
    @Deprecated
    public void closeConnection() {
        try {
            if (this.conn != null && !this.conn.isClosed()) {
                this.conn.close();
            }
        } catch (SQLException ex) {
            Logger.getLogger(DBContext.class.getName()).log(Level.SEVERE, "Error closing legacy connection", ex);
        }
    }

    // --- PHẦN DÀNH CHO CODE MỚI (AN TOÀN VÀ ĐÚNG CHUẨN) ---
    /**
     * Lấy một kết nối MỚI đến database. Luôn dùng phương thức này cho code mới
     * bên trong khối try-with-resources.
     *
     * @return Một đối tượng Connection mới.
     * @throws SQLException nếu không thể kết nối.
     */
    public static Connection getNewConnection() throws SQLException {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            return DriverManager.getConnection(URL, USER_ID, PASSWORD);
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(DBContext.class.getName()).log(Level.SEVERE, "SQL Server driver not found.", ex);
            throw new SQLException("Database Driver not found.", ex);
        }
    }
}