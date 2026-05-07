package apiary.servlet;

import apiary.util.DBConnection;

import java.io.IOException;
import java.sql.*;
import java.util.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;

/**
 * InspectionServlet.java
 * GET  /inspections               — lists all inspections
 * POST /inspections (no action)   — logs new inspection via stored procedure
 * POST /inspections?action=delete — deletes an inspection (admin only)
 */
@WebServlet("/inspections")
public class InspectionServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        if (req.getSession(false) == null || req.getSession(false).getAttribute("userId") == null) {
            res.sendRedirect("login.jsp");
            return;
        }

        // Use the ActiveHiveInspections view for active hives,
        // union with inactive/queenless for full list
        String sql = "SELECT i.inspection_id, h.hive_name, "
                   + "       CONCAT(u.first_name, ' ', u.last_name) AS inspector, "
                   + "       i.inspection_date, i.health_rating, i.queen_seen, i.notes "
                   + "FROM Inspections i "
                   + "JOIN Hives h ON i.hive_id = h.hive_id "
                   + "JOIN Users  u ON i.user_id  = u.user_id "
                   + "ORDER BY i.inspection_date DESC";

        List<Map<String, Object>> inspections = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection();
             Statement  stmt = conn.createStatement();
             ResultSet  rs   = stmt.executeQuery(sql)) {

            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("inspection_id",   rs.getInt("inspection_id"));
                row.put("hive_name",       rs.getString("hive_name"));
                row.put("inspector",       rs.getString("inspector"));
                row.put("inspection_date", rs.getDate("inspection_date"));
                row.put("health_rating",   rs.getInt("health_rating"));
                row.put("queen_seen",      rs.getBoolean("queen_seen") ? "Yes" : "No");
                row.put("notes",           rs.getString("notes"));
                inspections.add(row);
            }

        } catch (SQLException e) {
            throw new ServletException("Error loading inspections.", e);
        }

        List<Map<String, Object>> hives = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             Statement  stmt = conn.createStatement();
             ResultSet  rs   = stmt.executeQuery("SELECT hive_id, hive_name FROM Hives ORDER BY hive_name")) {
            while (rs.next()) {
                Map<String, Object> h = new LinkedHashMap<>();
                h.put("hive_id",   rs.getInt("hive_id"));
                h.put("hive_name", rs.getString("hive_name"));
                hives.add(h);
            }
        } catch (SQLException e) {
            throw new ServletException("Error loading hive list.", e);
        }

        req.setAttribute("inspections", inspections);
        req.setAttribute("hives",       hives);
        req.getRequestDispatcher("inspections.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            res.sendRedirect("login.jsp");
            return;
        }

        String action = req.getParameter("action");

        if ("delete".equals(action)) {
            // Admin-only delete
            if (!"admin".equals(session.getAttribute("role"))) {
                res.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            String idStr = req.getParameter("inspection_id");
            if (idStr != null && !idStr.isEmpty()) {
                String sql = "DELETE FROM Inspections WHERE inspection_id = ?";
                try (Connection conn = DBConnection.getConnection();
                     PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, Integer.parseInt(idStr));
                    ps.executeUpdate();
                } catch (SQLException e) {
                    throw new ServletException("Error deleting inspection.", e);
                }
            }

        } else {
            // Log new inspection via stored procedure
            // The procedure also auto-flags hive as queenless if health < 4 and no queen seen
            int    userId    = (int) session.getAttribute("userId");
            String hiveIdStr = req.getParameter("hive_id");
            String date      = req.getParameter("inspection_date");
            String ratingStr = req.getParameter("health_rating");
            String queenSeen = req.getParameter("queen_seen");
            String notes     = req.getParameter("notes");

            String sql = "{CALL LogInspectionAndUpdateStatus(?, ?, ?, ?, ?, ?)}";

            try (Connection conn = DBConnection.getConnection();
                 CallableStatement cs = conn.prepareCall(sql)) {

                cs.setInt(1,    Integer.parseInt(hiveIdStr));
                cs.setInt(2,    userId);
                cs.setDate(3,   java.sql.Date.valueOf(date));
                cs.setInt(4,    Integer.parseInt(ratingStr));
                cs.setInt(5,    "1".equals(queenSeen) ? 1 : 0);
                cs.setString(6, notes);
                cs.execute();

            } catch (SQLException e) {
                throw new ServletException("Error saving inspection via procedure.", e);
            }
        }

        res.sendRedirect("inspections");
    }
}
