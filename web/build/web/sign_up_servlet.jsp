<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="com.classes.User"%>
<%@ page import="org.mindrot.jbcrypt.BCrypt" %>


<%
    String error_massage = "All fields are required";
    String phonePattern = "^[0-9]{8,12}$";
    String emailPattern = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$";
    User new_user = new User(request.getParameter("username"), request.getParameter("password"), request.getParameter("email"), request.getParameter("phone"));

    // Check if fields are empty
    if (new_user.get_username() == null || new_user.get_username().trim().isEmpty() ||
        new_user.get_email() == null || new_user.get_email().trim().isEmpty() ||
        new_user.get_password() == null || new_user.get_password().trim().isEmpty()) {
        
        request.setAttribute("error", error_massage);
        request.getRequestDispatcher("sign_up_page.jsp").forward(request, response);
        return;
    }

    // Validate email
    if (!new_user.get_email().matches(emailPattern)) {
        error_massage = "Invalid email format";
        request.setAttribute("error", error_massage);
        request.getRequestDispatcher("sign_up_page.jsp").forward(request, response);
        return;
    }

    // Validate password length
    if (new_user.get_password().length() < 8) {
        error_massage = "Password must be at least 8 characters long";
        request.setAttribute("error", error_massage);
        request.getRequestDispatcher("sign_up_page.jsp").forward(request, response);
        return;
    }

    // Validate phone number
    if (!new_user.get_phone_number().matches(phonePattern)) {
        error_massage = "Invalid phone number";
        request.setAttribute("error", error_massage);
        request.getRequestDispatcher("sign_up_page.jsp").forward(request, response);
        return;
    }

    // Hash the password using bcrypt
    String hashedPassword = BCrypt.hashpw(new_user.get_password(), BCrypt.gensalt());

    // Continue with the rest of the logic
%>

    <sql:setDataSource var="con" 
                       driver="com.mysql.cj.jdbc.Driver"
                       url="jdbc:mysql://localhost:3306/e_commerce" 
                       user="end_user" 
                       password="Irmuun2018" />
    
    <sql:query dataSource="${con}" var="result">
        SELECT Count(*) as count FROM username WHERE email = ?
        <sql:param value="<%= new_user.get_email().trim() %>" />
    </sql:query>

    <c:if test="${result.rows[0].count > 0}">
        <%
            error_massage = "Email already taken";
            request.setAttribute("error", error_massage);
            request.getRequestDispatcher("sign_up_page.jsp").forward(request, response);
        %>
    </c:if>

    <c:if test="${result.rows[0].count == 0}">
        <sql:update dataSource="${con}">
            INSERT INTO username(username, email, password, phone_number)
            VALUES (?, ?, ?, ?)
            <sql:param value="<%= new_user.get_username() %>" />
            <sql:param value="<%= new_user.get_email() %>" />
            <sql:param value="<%= hashedPassword %>" /> 
            <sql:param value="<%= new_user.get_phone_number() %>" />
        </sql:update>

        <!-- Automatically create a cart for the new user -->
        <sql:query dataSource="${con}" var="newUserId">
            SELECT user_id FROM username WHERE email = ?
            <sql:param value="<%= new_user.get_email() %>" />
        </sql:query>

        <sql:update dataSource="${con}">
            INSERT INTO cart(user_id, total_price, create_time, update_time)
            VALUES (?, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
            <sql:param value="${newUserId.rows[0].user_id}" />
        </sql:update>
    </c:if>



<% response.sendRedirect("sign_in_page.jsp"); %>
