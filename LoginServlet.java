package apiary.servlet;

import apiary.util.DBConnection;

import java.io.*;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;

/**
 * ExportServlet.java
 * GET /export?type=inspections  — downloads inspections as CSV
 * GET /export?type=orders       — downloads orders as CSV
 */
@WebServlet("/export")
public class ExportServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        if (req.getSession(false) == null || req.getSession(false).getAttribute("userId") == null) {
            res.sendRedirect("login.jsp");
            return;
        }

        String type = req.getParameter("type");

        if ("inspections".equals(type)) {
            exportInspections(req, res);
        } else if ("orders".equals(type)) {
            exportOrders(req, res);
        } else {
            res.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unknown export type.");
        }
    }

    private void exportInspections(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        res.setContentType("text/csv");
        res.setHeader("Content-Disposition", "attachment; filename=\"inspections.csv\"");

        String sql = "SELECT i.inspection_id, h.hive_name, "
                   + "       CONCAT(u.first_name, ' ', u.last_name) AS inspector, "
                   + "       i.inspection_date, i.health_rating, "
                   + "       CASE WHEN i.queen_seen = 1 THEN 'Yes' ELSE 'No' END AS queen_seen, "
                   + "       i.notes "
                   + "FROM Inspections i "
                   + "JOIN Hives h ON i.hive_id = h.hive_id "
                   + "JOIN Users  u ON i.user_id  = u.user_id "
                   + "ORDER BY i.inspection_date DESC";

        try (Connection conn = DBConnection.getConnection();
             Statement  stmt = conn.createStatement();
             ResultSet  rs   = stmt.executeQuery(sql);
             PrintWriter out = res.getWriter()) {

            out.println("ID,Hive,Inspector,Date,Health Rating,Queen Seen,Notes");

            while (rs.next()) {
                out.printf("%d,\"%s\",\"%s\",%s,%d,%s,\"%s\"%n",
                    rs.getInt("inspection_id"),
                    escape(rs.getString("hive_name")),
                    escape(rs.getString("inspector")),
                    rs.getDate("inspection_date"),
                    rs.getInt("health_rating"),
                    rs.getString("queen_seen"),
                    escape(rs.getString("notes") != null ? rs.getString("notes") : "")
                );
            }

        } catch (SQLException e) {
            throw new ServletException("Error exporting inspections.", e);
        }
    }

    private void exportOrders(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        res.setContentType("text/csv");
        res.setHeader("Content-Disposition", "attachment; filename=\"orders.csv\"");

        String sql = "SELECT o.order_id, "
                   + "       CONCAT(c.first_name, ' ', c.last_name) AS customer_name, "
                   + "       o.order_date, o.total_amount, o.order_status "
                   + "FROM Orders o "
                   + "JOIN Customers c ON o.customer_id = c.customer_id "
                   + "ORDER BY o.order_date DESC";

        try (Connection conn = DBConnection.getConnection();
             Statement  stmt = conn.createStatement();
             ResultSet  rs   = stmt.executeQuery(sql);
             PrintWriter out = res.getWriter()) {

            out.println("Order ID,Customer,Date,Total ($),Status");

            while (rs.next()) {
                out.printf("%d,\"%s\",%s,%.2f,%s%n",
                    rs.getInt("order_id"),
                    escape(rs.getString("customer_name")),
                    rs.getDate("order_date"),
                    rs.getBigDecimal("total_amount").doubleValue(),
                    rs.getString("order_status")
                );
            }

        } catch (SQLException e) {
            throw new ServletException("Error exporting orders.", e);
        }
    }

    /** Escape double-quotes inside CSV fields */
    private String escape(String s) {
        return s == null ? "" : s.replace("\"", "\"\"");
    }
}
