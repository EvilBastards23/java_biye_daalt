<%-- 
    Document   : forgot_password_servlet
    Created on : Nov 19, 2024, 4:36:04 PM
    Author     : dell
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="javax.servlet.http.Cookie" %>
<%
    // Check if login cookies are present
    String userId = null;
    String userRole = null;
    Cookie[] cookies = request.getCookies();
    if (cookies != null) {
        for (Cookie cookie : cookies) {
            if ("user_id".equals(cookie.getName())) {
                userId = cookie.getValue();
            }
            if ("role".equals(cookie.getName())) {
                userRole = cookie.getValue();
            }
        }
    }


    if (userId != null && userRole != null) {
        HttpSession ses = request.getSession();
        ses.setAttribute("loggedIn", true);
        ses.setAttribute("user_id", userId);
        ses.setAttribute("Role", userRole);
        if(userRole.equals("seller")){
            response.sendRedirect("seller_page.jsp");
            return;
         }
        else{
         response.sendRedirect("home.jsp");
        return;
    }
    }
    
%>



<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
    </head>
    <body>
      <div class="container">
        <h2>Forgot Password</h2>
        <p class="description">Enter your email address and we'll send you instructions to reset your password.</p>
        
        <% if (request.getAttribute("message") != null) { %>
            <div class="alert alert-<%= request.getAttribute("messageType") %>">
                <%= request.getAttribute("message") %>
            </div>
        <% } %>
        
        <form action="forgot_password_page_2.jsp" method="POST" ">
            <div class="form-group">
                <input type="email" 
                       name="email" 
                       id="email" 
                       placeholder="Enter your email"
                       required>
            </div>
            <button type="submit" id="submitBtn">Send Reset Instructions</button>
        </form>
    </body>
</html>
