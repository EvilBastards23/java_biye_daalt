<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>




<% String email = request.getParameter("email");
ServletContext context = getServletContext();%>
    <sql:setDataSource var="con" 
                   driver="com.mysql.cj.jdbc.Driver"
                   url="jdbc:mysql://localhost:3306/e_commerce" 
                   user="end_user" 
                   password="Irmuun2018" />

<sql:query dataSource="${con}" var="email_result">
    select Count(*) as count from username where email = ?
    <sql:param value="<%=email%>"/>
</sql:query>
    
    <c:if test="${email_result.rows[0].count == 1}">
        
        <% 
            
            context.setAttribute("email_forgot_password", email);
            
            response.sendRedirect("forgot_password_page_3.jsp");%>
    </c:if>
    <c:if test="${result.rows[0].count == 0}">
        <%
             String error_massage = "email doesnt registered";
             request.setAttribute("error", error_massage);
             request.getRequestDispatcher("forgot_password_page_1.jsp").forward(request, response);
         %>
    </c:if>