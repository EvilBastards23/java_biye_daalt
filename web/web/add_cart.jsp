<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page import="java.sql.SQLException" %>

<%-- Set up database connection --%>
<sql:setDataSource var="con" 
                   driver="com.mysql.cj.jdbc.Driver"
                   url="jdbc:mysql://localhost:3306/e_commerce" 
                   user="end_user" 
                   password="Irmuun2018"/>

<%-- Validate input parameters --%>
<c:catch var="exception">
    <c:choose>
        <c:when test="${not empty sessionScope.user_id and 
                        not empty param.model_number and 
                        not empty param.color and 
                        not empty param.sizes}">
            
            <%-- Find the specific product --%>
            <sql:query dataSource="${con}" var="productQuery">
                SELECT product_id, price 
                FROM product 
                WHERE model_number = ? AND color = ? AND size = ?
                <sql:param value="${param.model_number}" />
                <sql:param value="${param.color}" />
                <sql:param value="${param.sizes}" />
            </sql:query>

            <c:choose>
                <c:when test="${not empty productQuery.rows}">
                    <%-- Extract product details --%>
                    <c:set var="productId" value="${productQuery.rows[0].product_id}" />
                    <c:set var="price" value="${productQuery.rows[0].price}" />
                    <c:set var="userId" value="${sessionScope.user_id}" />

                    <%-- Check if cart exists, if not create one --%>
                    <sql:query dataSource="${con}" var="cartQuery">
                        SELECT cart_id 
                        FROM cart 
                        WHERE user_id = ?
                        <sql:param value="${userId}" />
                    </sql:query>

                    <c:choose>
                        <c:when test="${empty cartQuery.rows}">
                            <%-- Create new cart --%>
                            <sql:update dataSource="${con}" var="newCartInsert">
                                INSERT INTO cart (user_id, total_price, create_time, update_time) 
                                VALUES (?, 0, NOW(), NOW())
                                <sql:param value="${userId}" />
                            </sql:update>
                            <c:set var="cartId" value="${newCartInsert.generatedKey}" />
                        </c:when>
                        <c:otherwise>
                            <c:set var="cartId" value="${cartQuery.rows[0].cart_id}" />
                        </c:otherwise>
                    </c:choose>

                    <%-- Check if product already in cart --%>
                    <sql:query dataSource="${con}" var="cartItemQuery">
                        SELECT cart_item_id, quantity 
                        FROM cart_item 
                        WHERE cart_id = ? AND product_id = ?
                        <sql:param value="${cartId}" />
                        <sql:param value="${productId}" />
                    </sql:query>

                    <c:choose>
                        <c:when test="${not empty cartItemQuery.rows}">
                            <%-- Update existing cart item quantity --%>
                            <sql:update dataSource="${con}">
                                UPDATE cart_item 
                                SET quantity = quantity + 1 
                                WHERE cart_id = ? AND product_id = ?
                                <sql:param value="${cartId}" />
                                <sql:param value="${productId}" />
                            </sql:update>
                        </c:when>
                        <c:otherwise>
                            <%-- Insert new cart item --%>
                            <sql:update dataSource="${con}">
                                INSERT INTO cart_item 
                                (cart_id, product_id, price, quantity) 
                                VALUES (?, ?, ?, 1)
                                <sql:param value="${cartId}" />
                                <sql:param value="${productId}" />
                                <sql:param value="${price}" />
                            </sql:update>
                        </c:otherwise>
                    </c:choose>

                    <%-- Update cart total price --%>
                    <sql:update dataSource="${con}">
                        UPDATE cart 
                        SET total_price = (
                            SELECT SUM(price * quantity) 
                            FROM cart_item 
                            WHERE cart_id = ?
                        ), update_time = NOW() 
                        WHERE cart_id = ?
                        <sql:param value="${cartId}" />
                        <sql:param value="${cartId}" />
                    </sql:update>

                    <%-- Redirect to welcome page --%>
                    <c:redirect url="home.jsp?success=true" />
                </c:when>
                <c:otherwise>
                    <%-- Product not found --%>
                    <c:redirect url="error.jsp?error=true&message=Product%20not%20found" />
                </c:otherwise>
            </c:choose>
        </c:when>
        <c:otherwise>
            <%-- Invalid input or not logged in --%>
            <c:redirect url="error.jsp?error=true&message=Invalid%20Input" />
        </c:otherwise>
    </c:choose>
</c:catch>

<%-- Error Handling --%>
<c:if test="${not empty exception}">
    <%
        // Print error to server console
        if (pageContext.getException() != null) {
            pageContext.getException().printStackTrace(System.out);
        }
    %>
    <%-- Redirect to error page --%>
    <c:redirect url="error.jsp">
        <c:param name="errorMsg" value="${exception.message}" />
    </c:redirect>
</c:if>