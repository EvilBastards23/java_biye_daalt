<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<sql:setDataSource var="con" 
                   driver="com.mysql.cj.jdbc.Driver"
                   url="jdbc:mysql://localhost:3306/e_commerce" 
                   user="end_user" 
                   password="Irmuun2018"/>

<sql:query dataSource="${con}" var="result">
SELECT 
    p.model_number, 
    MIN(p.product_name) as product_name, 
    MIN(p.price) as price,               
    c.category_name,
    GROUP_CONCAT(DISTINCT p.color) AS colors,
    GROUP_CONCAT(DISTINCT p.size) AS sizes,
    GROUP_CONCAT(DISTINCT TO_BASE64(p.image_blob)) AS images
FROM 
    product p
JOIN 
    category c ON p.category_id = c.category_id
WHERE 
    p.model_number = ? 
GROUP BY 
    p.model_number, c.category_name;
    <sql:param value="${param.model_number}"/>
</sql:query>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Product Details</title>
  <link rel="stylesheet" href="detail.css">
</head>
<body>
<header class="header">
    <div class="logo">Muunee's</div>
    <nav class="nav">
      <ul>
        <li><a href="#">Women</a></li>
        <li><a href="#">Men</a></li>
        <li><a href="#">Home</a></li>
        <li><a href="#">Sale</a></li>
        <li><a href="#">About Us</a></li>
      </ul>
    </nav>
    <div class="icons">
      <i class="fas fa-search"></i>
      <i class="fas fa-shopping-cart"></i>
      <c:choose>
        <c:when test="${empty sessionScope.user_id}">
          <a href="sign_in_page.jsp" class="button">Sign In</a>
          <a href="sign_up_page.jsp" class="button">Sign Up</a>
        </c:when>
        <c:otherwise>
          <a href="profile.jsp" class="button">My Profile</a>
          <a href="logout.jsp" class="button">Logout</a>
        </c:otherwise>
      </c:choose>
    </div>
</header>

<form method="get" action="add_cart.jsp">
  <c:forEach var="product" items="${result.rows}">
    <div class="product-details">
      <div class="product_image">
              <img id="product-image-${product.model_number}" 
                   src="data:image/jpg;base64,${fn:split(product.images, ',')[0]}" 
                   alt="${product.product_name}"
                   >
            </div>
      <input type="hidden" name="model_number" value="${param.model_number}">
      <p class="product-name">${product.product_name}</p>
      <p class="category-name">Category: ${product.category_name}</p>
      <p class="price">Price: $${product.price}</p>
      <div class="details">
        <div class="color-options">
          <p>Colors:</p>
          <c:forEach var="color" items="${fn:split(product.colors, ',')}"> 
            <input id="${color}" type="radio" name="color" class="color-button" value="${color}" style="display: none;">
            <label for="${color}" class="colorLabel" style="background-color: ${color};"></label>
          </c:forEach>
        </div>
        <div class="size-selector">
          <p>Select Sizes:</p>
          <c:forEach var="size" items="${fn:split(product.sizes, ',')}">
            <div>
              <input type="radio" name="sizes" value="${size}" id="size-${product.model_number}-${size}">
              <label for="size-${product.model_number}-${size}">${size}</label>
            </div>
          </c:forEach>
        </div>
      </div>
    </div>
  </c:forEach>
  <input type="submit" class="add-to-cart" value="Add to Cart">
</form>

</body>
</html>
