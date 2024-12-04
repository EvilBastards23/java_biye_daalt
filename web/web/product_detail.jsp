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
    model_number, 
    MIN(product_name) AS product_name, -- Pick the first name alphabetically
    MIN(price) AS price,               -- Minimum price
    MIN(category_name) AS category_name,
    GROUP_CONCAT(DISTINCT color) AS colors,
    GROUP_CONCAT(DISTINCT size) AS sizes,
    GROUP_CONCAT(DISTINCT image_url) AS images
FROM 
    product_category_image
WHERE 
    model_number = ? -- Filter before grouping
GROUP BY 
    model_number;
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

<!-- Product Details -->
<!-- Product Details -->
<form method="get" action="add_cart.jsp">
  <c:forEach var="product" items="${result.rows}">
    <div class="product-details">
      <div class="product-image">
        <img name="product_image" id="product-image-${product.model_number}" 
             src="${fn:split(product.images, ',')[0]}" 
             alt="${product.product_name}">
      </div>
      <input type="hidden" name="model_number" value="${param.model_number}">
      <p name="product_name" class="product-name">${product.product_name}</p>
      <p name="price" class="price">Price: $${product.price}</p>
      <div class="details">
        <div class="color-options">
          colors:
          <c:forEach var="color" items="${fn:split(product.colors, ',')}"> 
            <input id="${color}" type="radio" name="color" class="color-button" value="${color}" style="display: none;" />
            <label for="${color}" class="colorLabel" style="background-color: ${color};"></label>
        </c:forEach>
        </div>
         <div class="size-selector">
          <label>Select Sizes:</label>
          <c:forEach var="size" items="${fn:split(product.sizes, ',')}">
            <div>
              <input type="radio" name="sizes" value="${size}" id="size-${product.model_number}-${size}">
              <label for="size-${product.model_number}-${size}">${size}</label>
            </div>
          </c:forEach>
        </div>
        </select>

    </div>
    
  </c:forEach>
      <input type="submit" class="add-to-cart">Add to cart
</form>

</body>
</html>
