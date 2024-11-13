<%-- 
    Document   : sign_up_servlet
    Created on : Nov 5, 2024, 4:03:39 PM
    Author     : dell
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="com.classes.User"%>
<%@page errorPage="error_page.jsp" %>
        <%
        String error_massage = "all field have to required";
        String phonePattern = "^[0-9]{8,12}$";
        String emailPattern = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$";
        User new_user = new User(request.getParameter("username"),request.getParameter("password"),request.getParameter("email"),request.getParameter("phone"));
        if(new_user.get_username() == null || new_user.get_username().trim().isEmpty() ||
           new_user.get_email() == null || new_user.get_email().trim().isEmpty()||
           new_user.get_password() == null || new_user.get_password().trim().isEmpty())
        {
          request.setAttribute("error", error_massage);
          request.getRequestDispatcher("sign_up_page.jsp").forward(request,response);
          return;
         }
         if(!new_user.get_email().matches(emailPattern)){
           
          error_massage = "wrong email";
          request.setAttribute("error", error_massage);
          request.getRequestDispatcher("sign_up_page.jsp").forward(request,response);
          return;
        }
        if(new_user.get_password().length()<8){
           error_massage = "password must be 8 character long ";
           request.setAttribute("error", error_massage);
           request.getRequestDispatcher("sign_up_page.jsp").forward(request,response);
           return;
        }
        if(!new_user.get_phone_number().matches(phonePattern)){
           error_massage = "wrong phone number ";
           request.setAttribute("error", error_massage);
           request.getRequestDispatcher("sign_up_page.jsp").forward(request,response);
           return;
        }
        
         %>
        
    <c:catch var="exception">
        
        <sql:setDataSource var="con" 
                   driver="com.mysql.cj.jdbc.Driver"
                   url="jdbc:mysql://localhost:3306/e_commerce" 
                   user="end_user" 
                   password="Irmuun2018" />
        
        <sql:query dataSource="${con}" var="result">
            
            Select Count(*) as count From username Where email = ?
            <sql:param value="<%= new_user.get_email().trim()%>"/>
            
        </sql:query>
            
            
        <c:if test="${result.rows[0].count > 0}">
             <%
             error_massage = "email already taken";
             request.setAttribute("error", error_massage);
             request.getRequestDispatcher("sign_up_page.jsp").forward(request, response);
 
             %>
            
                
        </c:if>
        
      
        <c:if test="${result.rows[0].count == 0}">
           
            <sql:update dataSource="${con}">
                Insert Into username(username, email, password, phone_number)
                Values (?, ?, ?, ?)
                <sql:param value="<%= new_user.get_username() %>" />
                <sql:param value="<%= new_user.get_email() %>" />
                <sql:param value="<%= new_user.get_password() %>" />
                <sql:param value="<%= new_user.get_phone_number() %>" />
            </sql:update>
              
        </c:if>
    </c:catch>  
            
    <c:if test="${exception != null}">
    <%
    request.setAttribute("errorMessage", "Database error occurred: " + 
        ((Throwable)pageContext.getAttribute("exception")).getMessage());
    request.getRequestDispatcher("error_page.jsp").forward(request, response);
    %>
</c:if>
