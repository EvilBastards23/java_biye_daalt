<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.io.File"%>
<%@page import="java.io.IOException"%>
<%@page import="javax.servlet.ServletException"%>
<%@page import="javax.servlet.annotation.MultipartConfig"%>
<%@page import="javax.servlet.http.Part"%>
<%@page import="java.util.UUID"%>
<%@page import="com.classes.Product" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%
    // Check if form is submitted as multipart
    if (request.getContentType() != null && request.getContentType().startsWith("multipart/form-data")) {

        // Get form parameters
        Product product = new Product(
            request.getParameter("model_number"),
            request.getParameter("size"),
            request.getParameter("color"),
            request.getParameter("product_name"),
            request.getParameter("category")
        );

        String user_id = session.getAttribute("user_id").toString();
        Part filePart = request.getPart("product_image"); // Retrieve file part

        // Validate fields
        if (product.get_model_number().length() != 10) {
            request.setAttribute("error", "Cannot add product because model number is wrong");
            request.getRequestDispatcher("seller_page.jsp#add_product").forward(request, response);
            return;
        }

        if (product.get_color().trim().isEmpty() || product.get_product_name().trim().isEmpty()) {
            request.setAttribute("error", "Please fill all fields");
            request.getRequestDispatcher("seller_page.jsp#add_product").forward(request, response);
            return;
        }

        // Define upload directory for images
        String uploadPath = application.getRealPath("") + File.separator + "uploads";
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) uploadDir.mkdir();

        // Save file with unique name
        String fileName = UUID.randomUUID().toString() + "_" + filePart.getSubmittedFileName();
        String filePath = uploadPath + File.separator + fileName;
        filePart.write(filePath); // Save file

        // Set image URL to be saved in DB
        String imageUrl = "uploads/" + fileName;

        // Database queries
%>

<sql:setDataSource var="con" 
                   driver="com.mysql.cj.jdbc.Driver"
                   url="jdbc:mysql://localhost:3306/e_commerce" 
                   user="seller" 
                   password="Irmuun2018" />

<sql:query dataSource="${con}" var="category_id">
    select category_id from category where category_name = ?
    <sql:param value="<%= product.get_category() %>"/>
</sql:query>

<sql:query dataSource="${con}" var="seller_id">
    select seller_id from seller where user_id = ?
    <sql:param value="<%= user_id %>"/>
</sql:query>

<sql:query dataSource="${con}" var="check">
    SELECT COUNT(*) as count  
    FROM product p
    JOIN category c ON p.category_id = c.category_id
    WHERE p.color = ? AND p.size = ? AND p.model_number = ? AND p.product_name = ? AND c.category_name = ?
    <sql:param value="<%= product.get_color() %>"/>
    <sql:param value="<%= product.get_size() %>"/>
    <sql:param value="<%= product.get_model_number() %>"/>
    <sql:param value="<%= product.get_product_name() %>"/>
    <sql:param value="<%= product.get_category() %>"/>
</sql:query>

<c:if test="${check.rows[0].count >= 1}">
    <%
        request.setAttribute("error", "Product is already entered");
        request.getRequestDispatcher("seller_page.jsp").forward(request, response);
        return;
    %>
</c:if>

<c:if test="${check.rows[0].count == 0}">
    <sql:update dataSource="${con}">
        INSERT INTO product (model_number, size, color, product_name, category_id, seller_id, image_url)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        <sql:param value="<%= product.get_model_number() %>"/>
        <sql:param value="<%= product.get_size() %>"/>
        <sql:param value="<%= product.get_color() %>"/>
        <sql:param value="<%= product.get_product_name() %>"/>
        <sql:param value="${category_id.rows[0].category_id}"/>
        <sql:param value="${seller_id.rows[0].seller_id}"/>
        <sql:param value="<%= imageUrl %>"/>
    </sql:update>
</c:if>

<%
        response.sendRedirect("seller_page.jsp");
    } else {
        response.sendRedirect("seller_page.jsp");
    }
%>
