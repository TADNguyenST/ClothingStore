package util;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

public class DBContext {

    private static final Logger LOGGER = Logger.getLogger(DBContext.class.getName());

    // Thông tin kết nối mặc định (fallback)
    private static final String DEFAULT_SERVER_NAME = "clothingstore-server-2025.database.windows.net";
    private static final String DEFAULT_DB_NAME = "ClothingStore";
    private static final String DEFAULT_PORT_NUMBER = "1433";
    private static final String DEFAULT_USER_ID = "CloudSA62f9ded5";
    private static final String DEFAULT_PASSWORD = "Dat13102004";

    // Tải cấu hình từ file properties hoặc biến môi trường
    private static final Properties CONFIG = loadConfig();
    private static final String SERVER_NAME = getConfigValue("DB_SERVER_NAME", DEFAULT_SERVER_NAME);
    private static final String DB_NAME = getConfigValue("DB_NAME", DEFAULT_DB_NAME);
    private static final String PORT_NUMBER = getConfigValue("DB_PORT", DEFAULT_PORT_NUMBER);
    private static final String USER_ID = getConfigValue("DB_USER", DEFAULT_USER_ID);
    private static final String PASSWORD = getConfigValue("DB_PASSWORD", DEFAULT_PASSWORD);
    private static final String URL = String.format(
        "jdbc:sqlserver://%s:%s;databaseName=%s;encrypt=true;trustServerCertificate=true;hostNameInCertificate=*.database.windows.net;loginTimeout=30;",
        SERVER_NAME, PORT_NUMBER, DB_NAME
    );

    // --- PHẦN HỖ TRỢ CODE CŨ ---
    /**
     * @deprecated Biến này được giữ lại để tương thích với các DAO cũ.
     */
    @Deprecated
    protected Connection conn = null;

    public DBContext() {
        try {
            this.conn = getNewConnection();
            LOGGER.info("Initialized legacy connection for DBContext");
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to establish initial connection in DBContext constructor", ex);
        }
    }

    /**
     * @return 
     * @throws java.sql.SQLException
     * @deprecated Phương thức này được giữ lại để tương thích với các DAO cũ.
     */
    @Deprecated
    public Connection getConnection() throws SQLException {
        if (conn == null || conn.isClosed()) {
            LOGGER.info("Legacy connection is closed or null. Reconnecting...");
            conn = getNewConnection();
        }
        return conn;
    }

    /**
     * @deprecated Phương thức này được giữ lại để tương thích với các servlet cũ.
     */
    @Deprecated
    public void closeConnection() {
        try {
            if (conn != null && !conn.isClosed()) {
                conn.close();
                LOGGER.info("Closed legacy connection in DBContext");
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error closing legacy connection", ex);
        }
    }

    // --- PHẦN DÀNH CHO CODE MỚI ---
    /**
     * Lấy một kết nối mới đến database. Nên dùng trong khối try-with-resources.
     *
     * @return Connection mới.
     * @throws SQLException nếu không thể kết nối.
     */
    public static Connection getNewConnection() throws SQLException {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            Connection connection = DriverManager.getConnection(URL, USER_ID, PASSWORD);
            connection.setAutoCommit(true); // Đảm bảo auto-commit bật
            LOGGER.info("Established new database connection");
            return connection;
        } catch (ClassNotFoundException ex) {
            LOGGER.log(Level.SEVERE, "SQL Server driver not found", ex);
            throw new SQLException("Database driver not found", ex);
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to connect to database: " + URL, ex);
            throw ex;
        }
    }

    /**
     * Tải cấu hình từ file properties hoặc biến môi trường.
     *
     * @return Properties chứa cấu hình.
     */
    private static Properties loadConfig() {
        Properties props = new Properties();
        try (InputStream input = DBContext.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (input != null) {
                props.load(input);
                LOGGER.info("Loaded database configuration from db.properties");
            } else {
                LOGGER.warning("db.properties not found, falling back to environment variables or defaults");
            }
        } catch (IOException ex) {
            LOGGER.log(Level.SEVERE, "Error loading db.properties", ex);
        }
        return props;
    }

    /**
     * Lấy giá trị cấu hình từ biến môi trường hoặc file properties, với giá trị mặc định.
     *
     * @param key Khóa cấu hình.
     * @param defaultValue Giá trị mặc định.
     * @return Giá trị cấu hình.
     */
    private static String getConfigValue(String key, String defaultValue) {
        String envValue = System.getenv(key);
        if (envValue != null && !envValue.isEmpty()) {
            LOGGER.info("Using environment variable for " + key);
            return envValue;
        }
        String propValue = CONFIG.getProperty(key);
        if (propValue != null && !propValue.isEmpty()) {
            LOGGER.info("Using db.properties for " + key);
            return propValue;
        }
        LOGGER.info("Using default value for " + key);
        return defaultValue;
    }
}
