package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

public class DBContext {

    // --- THÔNG TIN KẾT NỐI CLOUD DATABASE ---
    private final String serverName = "clothingstore-server-2025.database.windows.net"; 
    private final String dbName = "ClothingStore"; 
    private final String portNumber = "1433";
    private final String userID = "CloudSA62f9ded5"; 
    private final String password = "Dat13102004"; 

    // === PHẦN SỬA LẠI ĐỂ TƯƠNG THÍCH VỚI CÁC DAO CŨ ===
    
    // 1. Tạo lại biến 'conn' mà các file DAO cũ đang cần
    protected Connection conn = null;

    // 2. Thêm constructor để tự động kết nối khi một DAO được tạo ra
    public DBContext() {
        try {
            // Lấy kết nối từ phương thức getConnection() và gán vào biến conn
            this.conn = getConnection();
            System.out.println("Connection to Azure SQL established for DAO instance.");
        } catch (Exception e) {
            Logger.getLogger(DBContext.class.getName()).log(Level.SEVERE, "Failed to establish initial connection in DBContext constructor", e);
        }
    }
    
    // === PHẦN KẾT NỐI AZURE (CẢI THIỆN) ===

    /**
     * This method establishes a connection to the Azure Cloud Database, checking and reopening if necessary.
     * @return a Connection object on success, or null on failure.
     * @throws SQLException if connection cannot be established.
     */
    public Connection getConnection() throws SQLException {
        if (conn == null || conn.isClosed()) {
            System.out.println("Connection is closed or does not exist. Attempting to reconnect...");
            String url = "jdbc:sqlserver://" + serverName + ":" + portNumber +
                         ";databaseName=" + dbName +
                         ";encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;";
            try {
                Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
                conn = DriverManager.getConnection(url, userID, password);
                System.out.println("Reconnected to Azure SQL successfully.");
            } catch (ClassNotFoundException | SQLException ex) {
                Logger.getLogger(DBContext.class.getName()).log(Level.SEVERE, "CLOUD DATABASE CONNECTION ERROR", ex);
                throw new SQLException("Unable to establish database connection", ex);
            }
        }
        return conn;
    }

    // === PHƯƠNG THỨC ĐÓNG KẾT NỐI ===
    public void closeConnection() {
        try {
            if (conn != null && !conn.isClosed()) {
                conn.close();
                System.out.println("Connection has been closed.");
            }
        } catch (SQLException ex) {
            Logger.getLogger(DBContext.class.getName()).log(Level.SEVERE, "Error closing connection", ex);
        }
    }
}