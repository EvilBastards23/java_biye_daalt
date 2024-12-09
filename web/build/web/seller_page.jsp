<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@page import="javax.servlet.http.HttpSession"%>
<%
    HttpSession ses = request.getSession();
    Boolean isLoggedIn = (Boolean) ses.getAttribute("loggedIn");
    String user_id = ses.getAttribute("user_id").toString();
    
    if (isLoggedIn == null || !isLoggedIn) {
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if (cookie.getName().equals("user_id")) {
                    user_id = cookie.getValue();
                }
            }
            
            if (user_id != null) {
                ses.setAttribute("loggedIn", true);
                ses.setAttribute("user_id", user_id);
            } else {
                response.sendRedirect("sign_in_page.jsp");
                return;
            }
        } else {
            response.sendRedirect("sign_in_page.jsp");
            return;
        }
    }
%>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Seller Dashboard</title>
        <style>
            .content {
                display: none;
                text-align: center;
                margin: 20px;
            }
            .content.active {
                display: block;
            }
            table {
                width: 100%;
                border-collapse: collapse;
                margin-top: 20px;
            }
            th, td {
                padding: 8px;
                border: 1px solid #ddd;
            }
            .menu {
                margin: 20px 0;
            }
            .menu-item {
                padding: 10px;
                margin: 0 5px;
            }
        </style>
    </head>
    Error processing product: Unknown column 'image_url' in 'field list'
    <body>
        <sql:setDataSource var="con" 
                          driver="com.mysql.cj.jdbc.Driver"
                          url="jdbc:mysql://localhost:3306/e_commerce" 
                          user="seller" 
                          password="Irmuun2018" />
        
        <!-- First get the seller_id for the logged-in user -->
        <sql:query dataSource="${con}" var="sellerResult">
            SELECT seller_id FROM seller WHERE user_id = ?
            <sql:param value="${user_id}"/>
        </sql:query>
        
        <!-- Store seller_id in a variable for later use -->
        <c:set var="seller_id" value="${sellerResult.rows[0].seller_id}"/>
        
        <div class="menu">
            <button class="menu-item" onclick="show_content('products_list')">View Products</button>
            <button class="menu-item" onclick="show_content('add_product')">Add Product</button>
            <a href="logout.jsp" class="menu-item">Logout</a>
        </div>

        <div id="products_list" class="content active">
            <h2>Your Products</h2>
            <sql:query dataSource="${con}" var="products">
                SELECT p.product_id, p.product_name, p.model_number, p.size, p.color, p.price, c.category_name, p.quantity 
                FROM product p
                JOIN category c ON p.category_id = c.category_id
                WHERE p.seller_id = ?
                <sql:param value="${seller_id}"/>
            </sql:query>

            <form action="update_product_servlet.jsp" method="post">
                <table>
                    <tr>
                        <th>Category</th>
                        <th>Product Name</th>
                        <th>Model Number</th>
                        <th>Size</th>
                        <th>Color</th>
                        <th>Price</th>
                        <th>Quantity</th>
                    </tr>
                    <c:forEach var="product" items="${products.rows}">
                        <tr>
                            <td>${product.category_name}</td>
                            <td>${product.product_name}</td>
                            <td>${product.model_number}</td>
                            <td>${product.size}</td>
                            <td>${product.color}</td>
                            <td>
                                <input type="number" name="price_${product.model_number}" 
                                       value="${product.price}" step="0.01" min="0">
                            </td>
                              <td>
                                <input type="number" name="quantity_${product.product_id}" 
                                       value="${product.quantity}" step="0.01" min="0">
                            </td>
                                                <!-- Existing columns -->
                            <td>
                                <form action="remove_product_servlet.jsp" method="post">
                                    <input type="hidden" name="product_id" value="${product.product_id}">
                                    <button type="submit" onclick="return confirm('Are you sure you want to remove this product?')">Remove</button>
                                </form>
                            </td>
                        </tr>
                        
                    </c:forEach>
                </table>
                <button type="submit" style="margin-top: 20px;">Update</button>
            </form>
                <c:if test="${not empty error}">
            <div style="color: red;">
                ${error}
            </div>
       </c:if> 
        </div>

        <div id="add_product" class="content">
            <h2>Add New Product</h2>
            <form method="post" action="AddProductServlet" enctype="multipart/form-data">
                <div>
                    <label for="product_name">Product Name:</label>
                    <input id="product_name" name="product_name" type="text" required>
                </div>
                
                <div>
                    <label for="size">Size:</label>
                    <select id="size" name="size">
                        <option value="XXXL">3XL</option>
                        <option value="XXL">2XL</option>
                        <option value="XL" selected>XL</option>
                        <option value="L">L</option>
                        <option value="M">M</option>
                        <option value="S">S</option>
                        <option value="XS">XS</option>
                        <option value="XXS">2XS</option>
                        <option value="XXXS">3XS</option>
                        <option value="F">F</option>
                    </select>
                </div>

                <div>
                    <label for="color">Color:</label>
                     <select id="color" name="color">
                        <option value="yellow">yellow</option>
                        <option value="red">red</option>
                        <option value="blue">blue</option>
                        <option value="green">green</option>
                        <option value="white">white</option>
                        <option value="dark">dark</option>
                        <option value="grey">grey</option>
                        <option value="brown">brown</option>
                        <option value="pink">pink</option>
                        <option value="purple">purple</option>
                    </select>
                </div>

                <div>
                    <sql:query dataSource="${con}" var="categories">
                        SELECT category_name FROM category
                    </sql:query>

                    <label for="categorySelect">Category:</label>
                    <select name="category" id="categorySelect" onchange="setModelPrefix()" required>
                        <c:forEach var="category" items="${categories.rows}">
                            <option value="${category.category_name}">
                                ${category.category_name}
                            </option>
                        </c:forEach>
                    </select>

                    <div>
                        <label for="modelNumber">Model Number:</label>
                        <input type="text" id="modelNumber" name="model_number" 
                               maxlength="10" minlength="10" placeholder="Model Number" 
                               oninput="enforcePrefix()" required="required">
                    </div>
                    <div>
                       image:   <input type="file" name="product_image" required />
                    </div>

                    <button type="submit" style="margin-top: 20px;">Add Product</button>
                </div>
            </form>
            <c:if test="${not empty error}">
            <div style="color: red;">
                ${error}
            </div>
       </c:if> 
        </div>

        <script>
            function show_content(content_id) {
                const contents = document.querySelectorAll('.content');
                contents.forEach(content => content.classList.remove('active'));
                document.getElementById(content_id).classList.add('active');
            }

            const categoryPrefixes = {
                "hat": "HA",
                "scarf": "SF",
                "hoodie": "HO",
                "polo": "PO",
                "cardigan": "CA",
                "gloves": "GL",
                "sweater": "SW",
                "vest": "VT"
            };

            function setModelPrefix() {
                const category = document.getElementById("categorySelect").value.toLowerCase();
                const prefix = categoryPrefixes[category] || "";
                const modelNumberInput = document.getElementById("modelNumber");
                modelNumberInput.value = prefix;
                modelNumberInput.dataset.prefix = prefix;
            }

            function enforcePrefix() {
                const modelNumberInput = document.getElementById("modelNumber");
                
                const prefix = modelNumberInput.dataset.prefix || "";
                let value = modelNumberInput.value;
                const prefixLength = prefix.length;
                const numericPart = value.slice(prefixLength).replace(/[^0-9]/g, '');
                value = prefix + numericPart;
                value = value.slice(0, 10);
                modelNumberInput.value = value;
            }

            // Set initial model prefix when page loads
            window.onload = function() {
                setModelPrefix();
            };
            window.addEventListener('load', function() {
                // Check if there is a fragment identifier in the URL
                const hash = window.location.hash;
                if (hash) {
                    const contentId = hash.substring(1); // Remove the '#' from the hash
                    show_content(contentId); // Call your function to display the specific section
                }
            });
        </script>
    </body>
</html>