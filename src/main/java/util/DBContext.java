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
            + "databaseName=ClothingStore;"
            + "user=sa;"
            + "password=123;"
            + "encrypt=true;trustServerCertificate=true;";

    public DBContext() {
        connect();
    }

    // Connection method
    private void connect() {
        try {
            // Register SQL Server driver
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

            // Establish connection
            conn = DriverManager.getConnection(dbURL);

            // Check connection
            if (conn != null) {
                DatabaseMetaData dm = conn.getMetaData();
                System.out.println("Connection successful!");
                System.out.println("Driver name: " + dm.getDriverName());
                System.out.println("Driver version: " + dm.getDriverVersion());
                System.out.println("Product name: " + dm.getDatabaseProductName());
                System.out.println("Product version: " + dm.getDatabaseProductVersion());
            }
        } catch (SQLException ex) {
            Logger.getLogger(DBContext.class.getName()).log(Level.SEVERE, "Database connection error", ex);
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(DBContext.class.getName()).log(Level.SEVERE, "SQL Server driver not found", ex);
        }
    }
    
   
    // Method to get connection (checks and reopens if needed)
    public Connection getConnection() throws SQLException {
        if (conn == null || conn.isClosed()) {
            System.out.println("Connection is closed or does not exist. Attempting to reconnect...");
            connect();
            if (conn == null || conn.isClosed()) {
                throw new SQLException("Unable to reopen database connection");
            }
        }
        return conn;
    }

    // Method to close connection
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