package apiary.servlet;

import apiary.util.DBConnection;

import java.io.IOException;
import java.sql.*;
import java.util.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;

/**
 * ProductServlet.java
 * GET  /products               — lists all products with batch info
 * POST /products               — adds a new product (admin only)
 * POST /products?action=delete — deletes a product (admin only)
 */
@WebServlet("/products")
public class ProductServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        if (req.getSession(false) == null || req.getSession(false).getAttribute("userId") == null) {
            res.sendRedirect("login.jsp");
            return;
        }

        String sql = "SELECT p.product_id, p.product_name, p.category, p.price, "
                   + "       p.stock_quantity, b.honey_type "
                   + "FROM Products p "
                   + "LEFT JOIN Honey_Batches b ON p.batch_id = b.batch_id "
                   + "ORDER BY p.category, p.product_name";

        List<Map<String, Object>> products = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection();
             Statement  stmt = conn.createStatement();
             ResultSet  rs   = stmt.executeQuery(sql)) {

            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("product_id",     rs.getInt("product_id"));
                row.put("product_name",   rs.getString("product_name"));
                row.put("category",       rs.getString("category"));
                row.put("price",          rs.getBigDecimal("price"));
                row.put("stock_quantity", rs.getInt("stock_quantity"));
                row.put("honey_type",     rs.getString("honey_type"));
                products.add(row);
            }

        } catch (SQLException e) {
            throw new ServletException("Error loading products.", e);
        }

        req.setAttribute("products", products);
        req.getRequestDispatcher("products.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("role"))) {
            res.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String action = req.getParameter("action");

        if ("delete".equals(action)) {
            String productIdStr = req.getParameter("product_id");
            if (productIdStr != null && !productIdStr.isEmpty()) {
                try (Connection conn = DBConnection.getConnection()) {
                    int productId = Integer.parseInt(productIdStr);

                    try (PreparedStatement ps = conn.prepareStatement(
                            "DELETE FROM Order_Items WHERE product_id = ?")) {
                        ps.setInt(1, productId);
                        ps.executeUpdate();
                    }

                    try (PreparedStatement ps = conn.prepareStatement(
                            "DELETE FROM Products WHERE product_id = ?")) {
                        ps.setInt(1, productId);
                        ps.executeUpdate();
                    }
                } catch (SQLException e) {
                    throw new ServletException("Error deleting product.", e);
                }
            }
        } else {
            String sql = "INSERT INTO Products (product_name, category, price, stock_quantity, batch_id) "
                       + "VALUES (?, ?, ?, ?, ?)";

            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {

                ps.setString(1, req.getParameter("product_name"));
                ps.setString(2, req.getParameter("category"));
                ps.setBigDecimal(3, new java.math.BigDecimal(req.getParameter("price")));
                ps.setInt(4, Integer.parseInt(req.getParameter("stock_quantity")));
                String batchId = req.getParameter("batch_id");
                ps.setObject(5, (batchId != null && !batchId.isEmpty()) ? Integer.parseInt(batchId) : null);
                ps.executeUpdate();

            } catch (SQLException e) {
                throw new ServletException("Error adding product.", e);
            }
        }

        res.sendRedirect("products");
    }
}
