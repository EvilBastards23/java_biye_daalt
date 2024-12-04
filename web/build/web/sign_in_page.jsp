<%-- 
    Document   : sign_in_page
    Created on : Nov 6, 2024, 3:44:15 PM
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
<html lang="en">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign In</title>
    <link rel="stylesheet" href="sig_in.css">
</head>
<body>
    <div class="container">
        <form method="post" action="sign_in_servlet.jsp" class="sign-in-form">
            <h1>Log In</h1>
            <div class="form-group">
                <label for="email">Email</label>
                <input id="email" name="email" type="text" placeholder="Enter your email">
            </div>
            <div class="form-group">
                <label for="password">Password</label>
                <input id="password" name="password" type="password" placeholder="Enter your password">
            </div>
            <div>
                <a href="forgot_password_page_1.jsp"> forgot password? </a>
            </div>
            <div>
                <a href="sign_up_page.jsp"> doesnt have account? </a>
            </div>
            <div class="form-group">
                <input type="submit" value="Sign In" class="btn">
            </div>
            <c:if test="${not empty error}">
                <div class="error-message">
                    ${error}
                </div>
            </c:if>
        </form>
    </div>
</body>
</html>
