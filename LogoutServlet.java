package apiary.servlet;

import apiary.util.DBConnection;

import java.io.IOException;
import java.sql.*;
import java.util.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;

/**
 * FeedingServlet.java
 * GET  /feeding               — loads feeding schedule
 * POST /feeding (no action)   — inserts new feeding entry (admin only)
 * POST /feeding?action=delete — deletes a feeding entry (admin only)
 */
@WebServlet("/feeding")
public class FeedingServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        if (req.getSession(false) == null || req.getSession(false).getAttribute("userId") == null) {
            res.sendRedirect("login.jsp");
            return;
        }

        String feedSql = "SELECT fs.schedule_id, h.hive_name, fs.feed_date, "
                       + "       fs.feed_type, fs.amount_lbs, fs.notes "
                       + "FROM Feeding_Schedule fs "
                       + "JOIN Hives h ON fs.hive_id = h.hive_id "
                       + "ORDER BY fs.feed_date DESC";

        List<Map<String, Object>> feedings = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection();
             Statement  stmt = conn.createStatement();
             ResultSet  rs   = stmt.executeQuery(feedSql)) {

            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("schedule_id", rs.getInt("schedule_id"));
                row.put("hive_name",   rs.getString("hive_name"));
                row.put("feed_date",   rs.getDate("feed_date"));
                row.put("feed_type",   rs.getString("feed_type"));
                row.put("amount_lbs",  rs.getBigDecimal("amount_lbs"));
                row.put("notes",       rs.getString("notes"));
                feedings.add(row);
            }

        } catch (SQLException e) {
            throw new ServletException("Error loading feeding schedule.", e);
        }

        List<Map<String, Object>> hives = new ArrayList<>();
        String hiveSql = "SELECT hive_id, hive_name FROM Hives ORDER BY hive_name";

        try (Connection conn = DBConnection.getConnection();
             Statement  stmt = conn.createStatement();
             ResultSet  rs   = stmt.executeQuery(hiveSql)) {

            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("hive_id",   rs.getInt("hive_id"));
                row.put("hive_name", rs.getString("hive_name"));
                hives.add(row);
            }

        } catch (SQLException e) {
            throw new ServletException("Error loading hives.", e);
        }

        req.setAttribute("feedings", feedings);
        req.setAttribute("hives",    hives);
        req.getRequestDispatcher("feeding.jsp").forward(req, res);
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
            String idStr = req.getParameter("schedule_id");
            if (idStr != null && !idStr.isEmpty()) {
                String sql = "DELETE FROM Feeding_Schedule WHERE schedule_id = ?";
                try (Connection conn = DBConnection.getConnection();
                     PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, Integer.parseInt(idStr));
                    ps.executeUpdate();
                } catch (SQLException e) {
                    throw new ServletException("Error deleting feeding entry.", e);
                }
            }

        } else {
            String hiveIdStr = req.getParameter("hive_id");
            String feedDate  = req.getParameter("feed_date");
            String feedType  = req.getParameter("feed_type");
            String amountStr = req.getParameter("amount_lbs");
            String notes     = req.getParameter("notes");

            if (hiveIdStr == null || feedDate == null || feedType == null
                    || feedDate.trim().isEmpty() || feedType.trim().isEmpty()) {
                req.setAttribute("error", "Hive, date, and feed type are required.");
                doGet(req, res);
                return;
            }

            String sql = "INSERT INTO Feeding_Schedule (hive_id, feed_date, feed_type, amount_lbs, notes) "
                       + "VALUES (?, ?, ?, ?, ?)";

            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {

                ps.setInt(1,    Integer.parseInt(hiveIdStr));
                ps.setDate(2,   java.sql.Date.valueOf(feedDate));
                ps.setString(3, feedType.trim());
                ps.setObject(4, (amountStr != null && !amountStr.isEmpty())
                                ? new java.math.BigDecimal(amountStr) : null);
                ps.setString(5, notes != null ? notes.trim() : null);
                ps.executeUpdate();

            } catch (SQLException e) {
                throw new ServletException("Error saving feeding entry.", e);
            }
        }

        res.sendRedirect("feeding");
    }
}
