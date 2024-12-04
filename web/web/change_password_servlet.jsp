<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%     ServletContext context = getServletContext(); // Get the application context

    // Retrieve the email from the ServletContext (stored during password reset process)
    String email = (String) context.getAttribute("email_forgot_password");

    // Retrieve the new password entered by the user
    String new_password = request.getParameter("new_password");

    // Remove the email from ServletContext as it's no longer needed
    context.removeAttribute("email_forgot_password"); 
%>

<sql:setDataSource var="con" 
                   driver="com.mysql.cj.jdbc.Driver"
                   url="jdbc:mysql://localhost:3306/e_commerce" 
                   user="end_user" 
                   password="Irmuun2018" />

<sql:update dataSource="${con}" var="updateCount">
    UPDATE username 
    SET password = ?
    WHERE email = ?
    <sql:param value="<%=new_password%>" />
    <sql:param value="<%=email%>" />
</sql:update>
    
 <c:if test="${updateCount > 0}">
    <%-- If update is successful, redirect to sign-in page --%>
    <script>
        window.location.href = "sign_in_page.jsp";
    </script>
</c:if>

<c:if test="${updateCount == 0}">
    <%-- If update fails, display error message --%>
    <p style="color: red;">Error: Password update failed. Please try again.</p>
    <%-- You can also forward to a specific JSP to display the error, or add the error to request attributes --%>
</c:if>
