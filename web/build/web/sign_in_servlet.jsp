<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.classes.User" %>
<%@page import="org.mindrot.jbcrypt.BCrypt" %>
<%@page import="java.sql.*" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    User user = new User(null, request.getParameter("password"), request.getParameter("email"), null);
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    String storedHashedPassword = null;
    String userRole = null;
    int userId = -1;

    try {
        // Establish database connection
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/e_commerce", 
            "end_user", 
            "Irmuun2018"
        );

        // Prepare statement to fetch user details
        pstmt = conn.prepareStatement(
            "SELECT password, role, user_id FROM username WHERE email = ?"
        );
        pstmt.setString(1, user.get_email().trim());

        // Execute query
        rs = pstmt.executeQuery();

        // Check if user exists
        if (rs.next()) {
            storedHashedPassword = rs.getString("password");
            userRole = rs.getString("role");
            userId = rs.getInt("user_id");

            // Verify password
            if (BCrypt.checkpw(user.get_password(), storedHashedPassword)) {
                // Successful login
                HttpSession ses = request.getSession();
                ses.setAttribute("loggedIn", true);
                ses.setAttribute("user_id", userId);
                ses.setAttribute("Role", userRole);

                // Create cookies
                Cookie loginCookie = new Cookie("user_id", String.valueOf(userId));
                Cookie roleCookie = new Cookie("role", userRole);

                // Configure cookies
                loginCookie.setMaxAge(30 * 60);
                roleCookie.setMaxAge(30 * 60);
                loginCookie.setPath("/");
                roleCookie.setPath("/");
                loginCookie.setSecure(request.isSecure());
                roleCookie.setSecure(request.isSecure());
                loginCookie.setHttpOnly(true);
                roleCookie.setHttpOnly(true);

                // Add cookies to response
                response.addCookie(loginCookie);
                response.addCookie(roleCookie);

                // Set session timeout
                ses.setMaxInactiveInterval(30 * 60);

                // Redirect based on role
                if ("user".equals(userRole)) {
                    response.sendRedirect("home.jsp");
                } else if ("admin".equals(userRole)) {
                    response.sendRedirect("admin.jsp");
                } else if ("seller".equals(userRole)) {
                    response.sendRedirect("seller_page.jsp");
                }
            } else {
                // Incorrect password
                request.setAttribute("error", "Email or password is incorrect");
                request.getRequestDispatcher("sign_in_page.jsp").forward(request, response);
            }
        } else {
            // User not found
            request.setAttribute("error", "Email or password is incorrect");
            request.getRequestDispatcher("sign_in_page.jsp").forward(request, response);
        }
    } catch (Exception e) {
        // Handle any database errors
        request.setAttribute("errorMessage", "Database error occurred: " + e.getMessage());
        request.getRequestDispatcher("error_page.jsp").forward(request, response);
    } finally {
        // Close database resources
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
%>