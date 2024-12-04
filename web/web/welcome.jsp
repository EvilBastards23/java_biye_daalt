<%-- welcome.jsp --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="javax.servlet.http.HttpSession"%>
<%
    HttpSession ses = request.getSession();
    Boolean isLoggedIn = (Boolean) ses.getAttribute("loggedIn");
    String userId = null;
    String userRole = null;
    
    if (isLoggedIn == null || !isLoggedIn) {
        // Check cookies
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if (cookie.getName().equals("user_id")) {
                    userId = cookie.getValue();
                }
                if (cookie.getName().equals("role")) {
                    userRole = cookie.getValue();
                }
            }
            
            // If cookies exist, restore session
            if (userId != null && userRole != null) {
                ses.setAttribute("loggedIn", true);
                ses.setAttribute("user_id", userId);
                ses.setAttribute("Role", userRole);
            } else {
                response.sendRedirect("sign_in_page.jsp");
                return;
            }
        } else {
            response.sendRedirect("sign_in_page.jsp");
            return;
        }
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Welcome Page</title>
    </head>
    <body>
        <h1>Welcome User ID: <%= ses.getAttribute("user_id") %></h1>
        <p>Role: <%= session.getAttribute("Role") %></p>
        <a href="logout.jsp">Logout</a>
        <a href="home.jsp">Home</a>
    </body>
</html>

