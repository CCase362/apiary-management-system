package apiary.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * DBConnection.java
 * Provides a shared JDBC connection to the apiary_db MySQL database.
 * Update URL, USER, and PASS to match your local MySQL setup.
 */
public class DBConnection {

    private static final String URL  = "jdbc:mysql://localhost:3306/apiary_db?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
    private static final String USER = "apiary_user";
    private static final String PASS = "apiary_pass";

    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("MySQL JDBC Driver not found. Add mysql-connector-j to /WEB-INF/lib", e);
        }
        return DriverManager.getConnection(URL, USER, PASS);
    }
}
