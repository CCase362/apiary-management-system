package apiary.servlet;

import apiary.util.DBConnection;

import java.io.IOException;
import java.sql.*;
import java.util.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;

/**
 * HiveServlet.java
 * GET  /hives              — loads all hives and forwards to hives.jsp
 * POST /hives?action=add   — inserts a new hive (admin only)
 * POST /hives?action=delete — deletes a hive by ID (admin only)
 */
@WebServlet("/hives")
public class HiveServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        if (req.getSession(false) == null || req.getSession(false).getAttribute("userId") == null) {
            res.sendRedirect("login.jsp");
            return;
        }

        String sql = "SELECT * FROM Hives ORDER BY hive_name";
        List<Map<String, Object>> hives = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection();
             Statement  stmt = conn.createStatement();
             ResultSet  rs   = stmt.executeQuery(sql)) {

            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("hive_id",      rs.getInt("hive_id"));
                row.put("hive_name",    rs.getString("hive_name"));
                row.put("location",     rs.getString("location"));
                row.put("queen_age",    rs.getInt("queen_age"));
                row.put("status",       rs.getString("status"));
                row.put("install_date", rs.getDate("install_date"));
                hives.add(row);
            }

        } catch (SQLException e) {
            throw new ServletException("Error loading hives.", e);
        }

        req.setAttribute("hives", hives);
        req.getRequestDispatcher("hives.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("role"))) {
            res.sendError(HttpServletResponse.SC_FORBIDDEN, "Admin access required.");
            return;
        }

        String action = req.getParameter("action");

        if ("delete".equals(action)) {
            String hiveIdStr = req.getParameter("hive_id");
            if (hiveIdStr != null && !hiveIdStr.isEmpty()) {
                // Delete dependent records first to respect foreign keys
                try (Connection conn = DBConnection.getConnection()) {

                    // Delete feeding schedule entries for this hive
                    try (PreparedStatement ps = conn.prepareStatement(
                            "DELETE FROM Feeding_Schedule WHERE hive_id = ?")) {
                        ps.setInt(1, Integer.parseInt(hiveIdStr));
                        ps.executeUpdate();
                    }

                    // Delete inspections for this hive
                    try (PreparedStatement ps = conn.prepareStatement(
                            "DELETE FROM Inspections WHERE hive_id = ?")) {
                        ps.setInt(1, Integer.parseInt(hiveIdStr));
                        ps.executeUpdate();
                    }

                    // Delete the hive itself
                    try (PreparedStatement ps = conn.prepareStatement(
                            "DELETE FROM Hives WHERE hive_id = ?")) {
                        ps.setInt(1, Integer.parseInt(hiveIdStr));
                        ps.executeUpdate();
                    }

                } catch (SQLException e) {
                    throw new ServletException("Error deleting hive.", e);
                }
            }

        } else {
            // Default action: add new hive
            String name        = req.getParameter("hive_name");
            String location    = req.getParameter("location");
            String queenAgeStr = req.getParameter("queen_age");
            String status      = req.getParameter("status");
            String installDate = req.getParameter("install_date");

            if (name == null || name.trim().isEmpty() || installDate == null || installDate.trim().isEmpty()) {
                req.setAttribute("error", "Hive name and install date are required.");
                doGet(req, res);
                return;
            }

            String sql = "INSERT INTO Hives (hive_name, location, queen_age, status, install_date) "
                       + "VALUES (?, ?, ?, ?, ?)";

            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {

                ps.setString(1, name.trim());
                ps.setString(2, location != null ? location.trim() : null);
                ps.setObject(3, (queenAgeStr != null && !queenAgeStr.isEmpty())
                                ? Integer.parseInt(queenAgeStr) : null);
                ps.setString(4, status);
                ps.setDate(5,   java.sql.Date.valueOf(installDate));
                ps.executeUpdate();

            } catch (SQLException e) {
                throw new ServletException("Error inserting hive.", e);
            }
        }

        res.sendRedirect("hives");
    }
}
