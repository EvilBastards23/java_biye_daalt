<%-- 
    Document   : sign_up_page
    Created on : Nov 5, 2024, 2:22:38 PM
    Author     : dell
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
    </head>
    <body>
        
        
        <form action="sign_up_servlet.jsp" method="post">
            <div>
                Username : <input name="username" type="text">
                Email : <input name="email"type="text">
                Password : <input name="password"type="password">
                Phone Number : <input name="phone"type="text">
                <input type="submit">
                
          
            </div>
        </form>
        
        <c:if test="${not empty error}">
            <div style="color: red;">
                ${error}
            </div>
        </c:if>
        
        
        

        
</table>
    </body>
</html>
