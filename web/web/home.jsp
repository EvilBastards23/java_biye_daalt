<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">

<sql:setDataSource var="con" 
                   driver="com.mysql.cj.jdbc.Driver"
                   url="jdbc:mysql://localhost:3306/e_commerce" 
                   user="end_user" 
                   password="Irmuun2018"/>

<%
    String selectedCategory = request.getParameter("category");
    if (selectedCategory == null || selectedCategory.isEmpty()) {
        selectedCategory = "%";
    }
    pageContext.setAttribute("selectedCategory", selectedCategory);
%>

<sql:query dataSource="${con}" var="result">
    SELECT 
        p.model_number, 
        min(p.product_name) as product_name, 
       max(p.price) as price, 
        min(c.category_name) as category_name,
        GROUP_CONCAT(DISTINCT p.color) AS colors,
        GROUP_CONCAT(DISTINCT p.size) AS sizes,
        GROUP_CONCAT(DISTINCT TO_BASE64(p.image_blob)) AS images
    FROM 
        product p
    LEFT JOIN 
        category c 
    ON 
        p.category_id = c.category_id
    WHERE 
        c.category_name LIKE ?
    GROUP BY 
        p.model_number;
    <sql:param value="${selectedCategory}"/>
</sql:query>

<c:if test="${not empty sessionScope.user_id}">
    <sql:query dataSource="${con}" var="cart_items">
        SELECT 
            ci.cart_id,
            ci.cart_item_id, 
            ci.quantity, 
            ci.price, 
            p.product_name, 
            TO_BASE64(p.image_blob) AS image_blob
        FROM 
            cart_item ci 
        JOIN 
            product p 
        ON 
            ci.product_id = p.product_id
        WHERE 
            ci.cart_id = (
                SELECT cart_id 
                FROM cart 
                WHERE user_id = ${sessionScope.user_id}
            );
    </sql:query>
    <sql:query dataSource="${con}" var="total_price_number">
        SELECT total_price 
        FROM cart 
        WHERE cart_id = (
            SELECT cart_id 
            FROM cart 
            WHERE user_id = ${sessionScope.user_id}
        );
    </sql:query>
</c:if>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Muunee's</title>
  <link rel="stylesheet" href="new_home.css">
  <script>
    function toggleCart() {
      const cartSidebar = document.getElementById("cartSidebar");
      cartSidebar.classList.toggle("open");
    }
   function changeQuantity(productId, change) {
    // Find the quantity element for this specific product
    const quantityElement = document.querySelector(`.cart-item[data-product-id="${productId}"] .quantity`);
    
    // Get current quantity
    let currentQuantity = parseInt(quantityElement.textContent);
    
    // Calculate new quantity
    let newQuantity = currentQuantity + change;
    
    // Prevent quantity from going below 1
    if (newQuantity < 1) {
        return;
    }
    
    // Send AJAX request to update quantity
    fetch('UpdateCartServlet', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: `product_id=${productId}&quantity=${newQuantity}`
    })
    .then(response => {
        if (response.ok) {
            // Update quantity in UI
            quantityElement.textContent = newQuantity;
            
            // Optionally, refresh total price
            refreshCartTotal();
        } else {
            // Handle error (optional)
            console.error('Failed to update quantity');
        }
    })
    .catch(error => {
        console.error('Error:', error);
    });
}

function refreshCartTotal() {
    // This function would make an AJAX call to recalculate the total price
    // and update the total in the cart footer
    fetch('CalculateCartTotalServlet')
    .then(response => response.json())
    .then(data => {
        document.querySelector('.cart-footer p').textContent = `Total: $${data.totalPrice}`;
    })
    .catch(error => {
        console.error('Error refreshing total:', error);
    });
}
  </script>
  <style>
    .color-button {
        width: 20px;
        height: 20px;
        border-radius: 50%;
        border: none;
        margin: 0 5px;
        cursor: pointer;
    }
    .color-options {
        margin-top: 10px;
    }
    .cart-sidebar {
        position: fixed;
        right: -300px;
        top: 0;
        width: 300px;
        height: 100%;
        background: #f4f4f4;
        transition: right 0.3s;
    }
    .cart-sidebar.open {
        right: 0;
    }
  </style>
</head>
<body>
  <!-- Header -->
  <header class="header">
    <div class="logo">Muunee's</div>
    <nav class="nav">
      <ul>
        <li><a href="#">Home</a></li>
        <li><a href="#">Sale</a></li>
        <li><a href="#">About Us</a></li>
      </ul>
    </nav>
    <div class="icons">
      <i class="fas fa-search"></i>
      <i class="fas fa-shopping-cart" onclick="toggleCart()"></i>
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

  <!-- Filters -->
  <div class="filters">
    <form method="get" action="home.jsp">
      <select name="category" onchange="this.form.submit()">
        <option value="">All Categories</option>
        <option value="hat" ${selectedCategory == 'hat' ? 'selected' : ''}>Hat</option>
        <option value="scarf" ${selectedCategory == 'scarf' ? 'selected' : ''}>Scarf</option>
        <option value="hoodie" ${selectedCategory == 'hoodie' ? 'selected' : ''}>Hoodie</option>
        <option value="cardigan" ${selectedCategory == 'cardigan' ? 'selected' : ''}>Cardigan</option>
        <option value="gloves" ${selectedCategory == 'gloves' ? 'selected' : ''}>Gloves</option>
        <option value="sweater" ${selectedCategory == 'sweater' ? 'selected' : ''}>Sweater</option>
        <option value="vest" ${selectedCategory == 'vest' ? 'selected' : ''}>Vest</option>
      </select>
    </form>
  </div>

  <!-- Product Grid -->
  <div class="main-content">
    <section class="product-grid">
      <c:forEach var="product" items="${result.rows}">
        <a href="product_detail.jsp?model_number=${product.model_number}" class="product-card-link" id="product-link-${product.model_number}">
          <div class="product-card">
            <div class="image-container">
              <img id="product-image-${product.model_number}" 
                   src="data:image/jpg;base64,${fn:split(product.images, ',')[0]}" 
                   alt="${product.product_name}"
                   >
            </div>
            <p class="product-name">${product.product_name}</p>
            <p class="price">Price: $${product.price}</p>
            <div class="details">
              <p>Colors: ${fn:join(fn:split(product.colors, ','), ', ')}</p>
              <div class="color-options">
                <c:forEach var="color" items="${fn:split(product.colors, ',')}">
                  <button class="color-button" style="background-color: ${color};" 
                          onclick="changeImage(event, '${product.model_number}', '${color}', '${product.images}')"></button>
                </c:forEach>
              </div>
            </div>
          </div>
        </a>
      </c:forEach>
    </section>
  </div>

  <!-- Cart Sidebar -->
<c:if test="${not empty sessionScope.user_id}">
    <aside class="cart-sidebar" id="cartSidebar">
        <div class="cart-header">
            <h2>Your Cart</h2>
            <i class="fas fa-times" onclick="toggleCart()"></i>
        </div>
        <div class="cart-items">
            <c:forEach var="item" items="${cart_items.rows}">
                <div class="cart-item" data-product-id="${item.product_id}">
                    <img src="data:image/jpg;base64,${item.image_blob}" alt="${item.product_name}" style="width: 200px; height: 200px; object-fit: cover;">
                    <div class="cart-item-details">
                        <p>${item.product_name}</p>
                        <p>Price: $${item.price}</p>
                        <div class="quantity-control">
                            <button onclick="changeQuantity(${item.product_id}, -1)">-</button>
                            <span class="quantity">${item.quantity}</span>
                            <button onclick="changeQuantity(${item.product_id}, 1)">+</button>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
        <div class="cart-footer">
            <p>Total: $${total_price_number.rows[0].total_price}</p>
            <a href="checkout.jsp" class="button">Checkout</a>
        </div>
    </aside>
</c:if>

