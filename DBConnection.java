package apiary.servlet;

import apiary.util.DBConnection;

import java.io.IOException;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;

/**
 * LoginServlet.java
 * Handles POST /login — validates credentials and creates a session.
 */
@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        // Show the login page on GET
        req.getRequestDispatcher("login.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        String email    = req.getParameter("email");
        String password = req.getParameter("password");

        // Basic input guard
        if (email == null || password == null || email.trim().isEmpty()) {
            req.setAttribute("error", "Please enter your email and password.");
            req.getRequestDispatcher("login.jsp").forward(req, res);
            return;
        }

        String sql = "SELECT user_id, first_name, role FROM Users "
                   + "WHERE email = ? AND password = SHA2(?, 256)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email.trim());
            ps.setString(2, password);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                HttpSession session = req.getSession(true);
                session.setAttribute("userId",    rs.getInt("user_id"));
                session.setAttribute("firstName", rs.getString("first_name"));
                session.setAttribute("role",      rs.getString("role"));
                res.sendRedirect("dashboard.jsp");
            } else {
                req.setAttribute("error", "Invalid email or password.");
                req.getRequestDispatcher("login.jsp").forward(req, res);
            }

        } catch (SQLException e) {
            throw new ServletException("Database error during login.", e);
        }
    }
}
