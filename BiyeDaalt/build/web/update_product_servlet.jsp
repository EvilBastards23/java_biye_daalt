<%-- 
    Document   : update_product_servlet
    Created on : Nov 11, 2024, 9:10:31 AM
    Author     : dell
--%>

<%@ page import="java.util.Enumeration" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
        <sql:setDataSource var="con" 
                   driver="com.mysql.cj.jdbc.Driver"
                   url="jdbc:mysql://localhost:3306/e_commerce" 
                   user="seller" 
                   password="Irmuun2018" />
        
  <% 
    Enumeration<String> paramNames = request.getParameterNames();
    while (paramNames.hasMoreElements()) {
        String paramName = paramNames.nextElement();

        // Check if the parameter is a price field
        if (paramName.startsWith("price_")) {
            // Extract the model number by removing "price_" from the parameter name
            String modelNumber = paramName.substring(6); // Gets the part after "price_"
            String price = request.getParameter(paramName); // Get the price value entered by the user
           
            // Use these values to update the product in the database
            // SQL query to update the price based on the model number
          %>
           <sql:update dataSource="${con}">
                UPDATE product SET price = ? WHERE model_number = ?
                <sql:param value="<%=price%>" />
                <sql:param value="<%=modelNumber%>" />
           </sql:update>
       <%
        }
        if(paramName.startsWith("quantity_")){

            String quantity = request.getParameter(paramName);
            String product_id = paramName.substring(9);

        %>
          <sql:update dataSource="${con}">
                UPDATE product SET quantity = ? WHERE product_id = ?
                <sql:param value="<%=quantity%>" />
                <sql:param value="<%=product_id%>" />
             
           </sql:update>
   <%
       }
    }
    

response.sendRedirect("seller_page.jsp");
%>

      
        
  