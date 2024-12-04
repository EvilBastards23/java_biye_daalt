<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Error Page</title>
</head>
<body>
    <h1>Error</h1>

    <!-- Check if the error parameter exists and display the message -->
    <c:choose>
        <c:when test="${not empty param.message}">
            <p style="color: red;">${param.message}</p>
        </c:when>
        <c:otherwise>
            <p>No error message available.</p>
        </c:otherwise>
    </c:choose>
    
</body>
</html>
