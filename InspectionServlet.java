package apiary.servlet;

import apiary.util.DBConnection;

import java.io.IOException;
import java.sql.*;
import java.util.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;

/**
 * ChartsServlet.java
 * GET /charts — loads chart data and forwards to charts.jsp
 */
@WebServlet("/charts")
public class ChartsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        if (req.getSession(false) == null || req.getSession(false).getAttribute("userId") == null) {
            res.sendRedirect("login.jsp");
            return;
        }

        // ── Chart 1: Average health rating per hive ───────────────
        String healthSql = "SELECT h.hive_name, ROUND(AVG(i.health_rating), 1) AS avg_health "
                         + "FROM Inspections i "
                         + "JOIN Hives h ON i.hive_id = h.hive_id "
                         + "GROUP BY h.hive_name "
                         + "ORDER BY h.hive_name";

        List<String> hiveLabels   = new ArrayList<>();
        List<Double> hiveHealths  = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection();
             Statement  stmt = conn.createStatement();
             ResultSet  rs   = stmt.executeQuery(healthSql)) {
            while (rs.next()) {
                hiveLabels.add(rs.getString("hive_name"));
                hiveHealths.add(rs.getDouble("avg_health"));
            }
        } catch (SQLException e) {
            throw new ServletException("Error loading health data.", e);
        }

        // ── Chart 2: Inspections per month ────────────────────────
        String monthSql = "SELECT DATE_FORMAT(inspection_date, '%Y-%m') AS month, COUNT(*) AS total "
                        + "FROM Inspections "
                        + "GROUP BY month "
                        + "ORDER BY month";

        List<String>  monthLabels = new ArrayList<>();
        List<Integer> monthCounts = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection();
             Statement  stmt = conn.createStatement();
             ResultSet  rs   = stmt.executeQuery(monthSql)) {
            while (rs.next()) {
                monthLabels.add(rs.getString("month"));
                monthCounts.add(rs.getInt("total"));
            }
        } catch (SQLException e) {
            throw new ServletException("Error loading monthly data.", e);
        }

        // ── Chart 3: Product stock by category ───────────────────
        String stockSql = "SELECT category, SUM(stock_quantity) AS total_stock "
                        + "FROM Products "
                        + "GROUP BY category "
                        + "ORDER BY category";

        List<String>  stockLabels = new ArrayList<>();
        List<Integer> stockCounts = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection();
             Statement  stmt = conn.createStatement();
             ResultSet  rs   = stmt.executeQuery(stockSql)) {
            while (rs.next()) {
                stockLabels.add(rs.getString("category"));
                stockCounts.add(rs.getInt("total_stock"));
            }
        } catch (SQLException e) {
            throw new ServletException("Error loading stock data.", e);
        }

        req.setAttribute("hiveLabels",   hiveLabels);
        req.setAttribute("hiveHealths",  hiveHealths);
        req.setAttribute("monthLabels",  monthLabels);
        req.setAttribute("monthCounts",  monthCounts);
        req.setAttribute("stockLabels",  stockLabels);
        req.setAttribute("stockCounts",  stockCounts);
        req.getRequestDispatcher("charts.jsp").forward(req, res);
    }
}
