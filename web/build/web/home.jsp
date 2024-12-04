<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.SQLException"%>
<%@page import="javax.naming.Context"%>
<%@page import="javax.naming.InitialContext"%>
<%@page import="javax.sql.DataSource"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page session="false" %>

<%! 
    private static String convertBlobToBase64(java.sql.Blob blob) {
        if (blob == null) return "";
        try (java.io.InputStream inputStream = blob.getBinaryStream()) {
            byte[] imageBytes = inputStream.readAllBytes();
            return java.util.Base64.getEncoder().encodeToString(imageBytes);
        } catch (Exception e) {
            System.err.println("Error converting BLOB: " + e.getMessage());
            return "";
        }
    }
%>

<%
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Context initialContext = new InitialContext();
        Context environmentContext = (Context) initialContext.lookup("java:comp/env");
        DataSource dataSource = (DataSource) environmentContext.lookup("jdbc/ECommerceDB");
        conn = dataSource.getConnection();

        String selectedCategory = request.getParameter("category");
        selectedCategory = (selectedCategory == null || selectedCategory.isEmpty()) ? "%" : selectedCategory;

        String query = "SELECT " +
            "model_number, product_name, price, category_name, " +
            "GROUP_CONCAT(DISTINCT color) AS colors, " +
            "GROUP_CONCAT(DISTINCT size) AS sizes, " +
            "GROUP_CONCAT(DISTINCT image) AS images " +
            "FROM product_category_image " +
            "WHERE category_name LIKE ? " +
            "GROUP BY model_number";

        pstmt = conn.prepareStatement(query);
        pstmt.setString(1, selectedCategory);
        rs = pstmt.executeQuery();

        List<String> base64Images = new ArrayList<>();
        List<Map<String, Object>> products = new ArrayList<>();

        while (rs.next()) {
            java.sql.Blob imageBlob = rs.getBlob("image");
            String base64Image = convertBlobToBase64(imageBlob);
            base64Images.add(base64Image);

            Map<String, Object> product = new HashMap<>();
            product.put("modelNumber", rs.getString("model_number"));
            product.put("productName", rs.getString("product_name"));
            product.put("price", rs.getBigDecimal("price"));
            product.put("categoryName", rs.getString("category_name"));
            product.put("colors", rs.getString("colors"));
            product.put("sizes", rs.getString("sizes"));

            products.add(product);
        }

        request.setAttribute("base64Images", base64Images);
        request.setAttribute("products", products);

    } catch (SQLException e) {
        System.err.println("Database error: " + e.getMessage());
        response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database connection error");
    } catch (Exception e) {
        System.err.println("Unexpected error: " + e.getMessage());
        response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Unexpected error occurred");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Muunee's E-Commerce</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/home.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
</head>
<body>
    <header class="header">
        <div class="logo">Muunee's</div>
        <nav class="nav">
            <ul>
                <li><a href="${pageContext.request.contextPath}/home">Home</a></li>
                <li><a href="${pageContext.request.contextPath}/sale">Sale</a></li>
                <li><a href="${pageContext.request.contextPath}/about">About Us</a></li>
            </ul>
        </nav>
    </header>

    <div class="filters">
        <form method="get" action="${pageContext.request.contextPath}/home">
            <select name="category" onchange="this.form.submit()">
                <option value="">All Categories</option>
                <c:forEach var="cat" items="${['hat', 'scarf', 'hoodie', 'cardigan', 'gloves', 'sweater', 'vest']}">
                    <option value="${cat}" ${selectedCategory != null && selectedCategory.equals(cat) ? 'selected' : ''}>${fn:toUpperCase(fn:substring(cat, 0, 1))}${fn:substring(cat, 1)}</option>
                </c:forEach>
            </select>
        </form>
    </div>

    <div class="main-content">
        <section class="product-grid">
            <c:forEach var="product" items="${products}" varStatus="loop">
                <a href="${pageContext.request.contextPath}/product/${product.modelNumber}" class="product-card-link">
                    <div class="product-card">
                        <div class="image-container">
                            <img src="data:image/jpeg;base64,${base64Images[loop.index]}" 
                                 alt="${fn:escapeXml(product.productName)}">
                        </div>
                        <p class="product-name">${fn:escapeXml(product.productName)}</p>
                        <p class="price">Price: $${product.price}</p>
                        <div class="details">
                            <p>Colors: ${fn:join(fn:split(product.colors, ','), ', ')}</p>
                            <div class="color-options">
                                <c:forEach var="color" items="${fn:split(product.colors, ',')}">
                                    <button class="color-button" style="background-color: ${fn:escapeXml(color)};" 
                                            onclick="changeImage(event, '${product.modelNumber}', '${fn:escapeXml(color)}')"></button>
                                </c:forEach>
                            </div>
                        </div>
                    </div>
                </a>
            </c:forEach>
        </section>
    </div>

    <aside class="cart-sidebar">
        <div class="cart-header">
            <h2>Your Cart</h2>
            <i class="fas fa-times" onclick="toggleCart()"></i>
        </div>
        <div class="cart-items">
            <!-- Cart items will be dynamically populated -->
        </div>
        <div class="cart-footer">
            <button>Checkout</button>
        </div>
    </aside>

    <script>
        function toggleCart() {
            const cartSidebar = document.querySelector('.cart-sidebar');
            cartSidebar.classList.toggle('open');
        }

        function changeImage(event, modelNumber, color) {
            event.preventDefault();
            // Implement image change logic based on color
            // This would typically involve an AJAX call to fetch color-specific images
        }
    </script>
</body>
</html>
