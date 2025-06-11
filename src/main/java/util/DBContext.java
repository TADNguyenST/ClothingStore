package util;

import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;


public class DBContext {

    protected Connection conn = null;
    private final String dbURL = "jdbc:sqlserver://localhost:1433;"
            + "databaseName=Clothing;"
            + "user=sa;"
            + "password=123;"
            + "encrypt=true;trustServerCertificate=true;";

    public DBContext() {
        connect();
    }

    // Phương thức kết nối
    private void connect() {
        try {
            // Đăng ký driver SQL Server
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

            // Thiết lập kết nối
            conn = DriverManager.getConnection(dbURL);

            // Kiểm tra kết nối
            if (conn != null) {
                DatabaseMetaData dm = conn.getMetaData();
                System.out.println("Kết nối thành công!");
                System.out.println("Driver name: " + dm.getDriverName());
                System.out.println("Driver version: " + dm.getDriverVersion());
                System.out.println("Product name: " + dm.getDatabaseProductName());
                System.out.println("Product version: " + dm.getDatabaseProductVersion());
            }
        } catch (SQLException ex) {
            Logger.getLogger(DBContext.class.getName()).log(Level.SEVERE, "Lỗi kết nối cơ sở dữ liệu", ex);
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(DBContext.class.getName()).log(Level.SEVERE, "Không tìm thấy driver SQL Server", ex);
        }
    }

    // Phương thức lấy kết nối (kiểm tra và mở lại nếu cần)
    public Connection getConnection() throws SQLException {
        if (conn == null || conn.isClosed()) {
            System.out.println("Kết nối đã bị đóng hoặc không tồn tại. Thử mở lại kết nối...");
            connect();
            if (conn == null || conn.isClosed()) {
                throw new SQLException("Không thể mở lại kết nối cơ sở dữ liệu");
            }
        }
        return conn;
    }

    // Phương thức đóng kết nối
    public void closeConnection() {
        try {
            if (conn != null && !conn.isClosed()) {
                conn.close();
                System.out.println("Kết nối đã được đóng.");
            }
        } catch (SQLException ex) {
            Logger.getLogger(DBContext.class.getName()).log(Level.SEVERE, "Lỗi khi đóng kết nối", ex);
        }
    }
}
