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

    // If cookies exist, redirect to welcome page
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
         response.sendRedirect("welcome.jsp");
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
        <form method="post" action="sign_in_servlet.jsp">
            <div>log in</div>
            <div>email <input name="email" type="text"></div>
            <div>password <input name="password" type="password"</div>
            <div><input type="submit"</div>
        </form>
        
       <c:if test="${not empty error}">
            <div style="color: red;">
                ${error}
            </div>
       </c:if> 
        
        
    </body>
</html>
