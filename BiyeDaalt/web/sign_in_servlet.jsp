<%-- sign_in_servlet.jsp --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.classes.User" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    User user = new User(null, request.getParameter("password"), request.getParameter("email"), null);
%>
<c:catch var="exception">
    <sql:setDataSource var="con" 
                   driver="com.mysql.cj.jdbc.Driver"
                   url="jdbc:mysql://localhost:3306/e_commerce" 
                   user="end_user" 
                   password="Irmuun2018" />
    <sql:query dataSource="${con}" var="result">
        Select Count(*) as count,role,user_id from username where email=? and password = ?
        <sql:param value="<%= user.get_email().trim()%>"/>
        <sql:param value="<%= user.get_password()%>"/>
    </sql:query>
        
    <c:if test="${result.rows[0].count == 0}">
        <%
             String error_massage = "email or password is wrong";
             request.setAttribute("error", error_massage);
             request.getRequestDispatcher("sign_in_page.jsp").forward(request, response);
         %>
    </c:if>
  
    <c:set var="Role" value="${result.rows[0].role}"/>
    <c:set var="user_id" value="${result.rows[0].user_id}"/>
        
    <c:if test="${result.rows[0].count ==1}">
         <%
             HttpSession ses = request.getSession();
             
            ses.setAttribute("loggedIn", true);
            ses.setAttribute("user_id", pageContext.getAttribute("user_id"));
            ses.setAttribute("Role", pageContext.getAttribute("Role"));
           
            // Create cookies for session persistence
            Cookie loginCookie = new Cookie("user_id", pageContext.getAttribute("user_id").toString());
            Cookie roleCookie = new Cookie("role", pageContext.getAttribute("Role").toString());
            
            // Set cookie expiry to 30 minutes (in seconds)
            loginCookie.setMaxAge(30 * 60);
            roleCookie.setMaxAge(30 * 60);
            
            // Set cookie path to be accessible across the application
            loginCookie.setPath("/");
            roleCookie.setPath("/");
            
            // Set secure flag if using HTTPS
            loginCookie.setSecure(request.isSecure());
            roleCookie.setSecure(request.isSecure());
            
            // Set HttpOnly flag to protect against XSS
            loginCookie.setHttpOnly(true);
            roleCookie.setHttpOnly(true);
            
            // Add cookies to response
            response.addCookie(loginCookie);
            response.addCookie(roleCookie);
            
            ses.setMaxInactiveInterval(30 * 60);
        %>
        
        <c:if test="${result.rows[0].role == 'user'}">
            <%response.sendRedirect("welcome.jsp");%>
        </c:if>
        <c:if test="${result.rows[0].role == 'admin'}">
            <%response.sendRedirect("admin.jsp");%>
        </c:if>
        <c:if test="${result.rows[0].role == 'seller'}">
            <%response.sendRedirect("seller_page.jsp");%>
        </c:if>
    </c:if>
</c:catch>
<c:if test="${exception != null}">
    <%
    request.setAttribute("errorMessage", "Database error occurred: " + 
        ((Throwable)pageContext.getAttribute("exception")).getMessage());
    request.getRequestDispatcher("error_page.jsp").forward(request, response);
    %>
</c:if>