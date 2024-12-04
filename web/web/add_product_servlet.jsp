<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.classes.Product"%>
<%@page import="java.io.*"%>
<%@page import="javax.servlet.http.Part"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<%
    try {
        String user_id = (session.getAttribute("user_id") != null) 
            ? session.getAttribute("user_id").toString() 
            : null;
        if (user_id == null) {
            response.sendRedirect("sign_in_page.jsp");
            return;
        }

        String model_number = request.getParameter("model_number");
        String size = request.getParameter("size");
        String color = request.getParameter("color");
        String product_name = request.getParameter("product_name");
        String category = request.getParameter("category");

        if (model_number == null || size == null || color == null || 
            product_name == null || category == null) {
            request.setAttribute("error", "Missing required product information");
            request.getRequestDispatcher("seller_page.jsp#add_product").forward(request, response);
            return;
        }

        Part filePart = request.getPart("product_image");
        InputStream inputStream = null;
        String imagePath = "";

        if (filePart != null && filePart.getSize() > 0) {
            inputStream = filePart.getInputStream();
            String fileName = model_number + "_" + getSubmittedFileName(filePart);
            String uploadPath = request.getServletContext().getRealPath("") + File.separator + "product_images";
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdir();
            }
            String fullPath = uploadPath + File.separator + fileName;
            filePart.write(fullPath);
            imagePath = "product_images/" + fileName;
        } else {
            request.setAttribute("error", "Product image is required");
            request.getRequestDispatcher("seller_page.jsp#add_product").forward(request, response);
            return;
        }

        Product product = new Product(model_number, size, color, product_name, category);

        if (product.get_model_number().length() != 10) {
            request.setAttribute("error", "Model number must be 10 characters long");
            request.getRequestDispatcher("seller_page.jsp#add_product").forward(request, response);
            return;
        }

        if (product.get_color().trim().isEmpty() || product.get_product_name().trim().isEmpty()) {
            request.setAttribute("error", "Please fill in all fields");
            request.getRequestDispatcher("seller_page.jsp#add_product").forward(request, response);
            return;
        }
%>

<%! 
    private String getSubmittedFileName(Part part) {
        for (String cd : part.getHeader("content-disposition").split(";")) {
            if (cd.trim().startsWith("filename")) {
                String fileName = cd.substring(cd.indexOf('=') + 1).trim().replace("\"", "");
                return fileName.substring(fileName.lastIndexOf('/') + 1).substring(fileName.lastIndexOf('\\') + 1);
            }
        }
        return null;
    }
%>

<sql:setDataSource var="con" driver="com.mysql.cj.jdbc.Driver"
    url="jdbc:mysql://localhost:3306/e_commerce" user="seller" password="Irmuun2018" />

<sql:query dataSource="${con}" var="category_id">
    SELECT category_id FROM category WHERE category_name = ?
    <sql:param value="<%= product.get_category() %>" />
</sql:query>

<sql:query dataSource="${con}" var="seller_id">
    SELECT seller_id FROM seller WHERE user_id = ?
    <sql:param value="<%= user_id %>" />
</sql:query>

<sql:query dataSource="${con}" var="check">
    SELECT COUNT(*) AS count FROM product p 
    JOIN category c ON p.category_id = c.category_id 
    WHERE p.color = ? AND p.size = ? AND p.model_number = ? 
    AND p.product_name = ? AND c.category_name = ?
    <sql:param value="<%= product.get_color() %>" />
    <sql:param value="<%= product.get_size() %>" />
    <sql:param value="<%= product.get_model_number() %>" />
    <sql:param value="<%= product.get_product_name() %>" />
    <sql:param value="<%= product.get_category() %>" />
</sql:query>

<c:choose>
    <c:when test="${check.rows[0].count >= 1}">
        <c:redirect url="seller_page.jsp">
            <c:param name="error" value="Product is already entered" />
        </c:redirect>
    </c:when>
    <c:otherwise>
        <sql:query dataSource="${con}" var="count_of_model_number">
            SELECT COUNT(*) AS count, MAX(price) AS price 
            FROM product WHERE model_number = ?
            <sql:param value="<%= product.get_model_number() %>" />
        </sql:query>

        <sql:update dataSource="${con}">
            INSERT INTO product(model_number, size, color, product_name, category_id, 
                               seller_id, image_url, price)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            <sql:param value="<%= product.get_model_number() %>" />
            <sql:param value="<%= product.get_size() %>" />
            <sql:param value="<%= product.get_color() %>" />
            <sql:param value="<%= product.get_product_name() %>" />
            <sql:param value="${category_id.rows[0].category_id}" />
            <sql:param value="${seller_id.rows[0].seller_id}" />
            <sql:param value="<%= imagePath %>" />
            <sql:param value="${count_of_model_number.rows[0].count == 0 ? 0 : count_of_model_number.rows[0].price}" />
        </sql:update>
        <c:redirect url="seller_page.jsp" />
    </c:otherwise>
</c:choose>

<%
    } catch (Exception e) {
        e.printStackTrace();
        request.setAttribute("error", "Error processing product: " + e.getMessage());
        request.getRequestDispatcher("seller_page.jsp#add_product").forward(request, response);
        return;
    }
%>
