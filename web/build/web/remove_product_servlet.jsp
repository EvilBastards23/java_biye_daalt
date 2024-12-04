<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    String productId = request.getParameter("product_id");
    HttpSession ses = request.getSession();
    
    if (productId != null) {
        try {
            // Set up database connection
            Class.forName("com.mysql.cj.jdbc.Driver");
            java.sql.Connection conn = java.sql.DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/e_commerce", "seller", "Irmuun2018");
            
            // Prepare delete statement
            java.sql.PreparedStatement pstmt = conn.prepareStatement(
                "DELETE FROM product WHERE product_id = ?");
            pstmt.setString(1, productId);
            
            // Execute delete
            int rowsAffected = pstmt.executeUpdate();
            
            // Close resources
            pstmt.close();
            conn.close();
            
            // Redirect back to seller dashboard
            response.sendRedirect("seller_page.jsp");
            return;
        } catch (Exception e) {
            // Handle any errors
            ses.setAttribute("error", "Error removing product: " + e.getMessage());
            response.sendRedirect("seller_page.jsp");
            return;
        }
    }
%>