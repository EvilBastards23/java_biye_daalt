<%-- 
    Document   : forgot_password_page_3
    Created on : Nov 20, 2024, 10:28:24 AM
    Author     : dell
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
    </head>
    <body>
      <form id="changePasswordForm" action="change_password_servlet.jsp" method="post" onsubmit="return validatePasswords();">
    <div>
        Enter New Password:
    </div>
    <div>
        <input type="password" id="newPassword" name="new_password" required>
    </div>
    <div>
        Enter Again New Password:
    </div>
    <div>
        <input type="password" id="confirmPassword" required>
    </div>
    <div>
        <button type="submit">Change Password</button>
    </div>
</form>

<script>
    function validatePasswords() {
        const newPassword = document.getElementById("newPassword").value;
        const confirmPassword = document.getElementById("confirmPassword").value;

        if (newPassword !== confirmPassword) {
            alert("Passwords do not match. Please try again.");
            return false; // Prevent form submission
        }

        return true; // Allow form submission
    }
</script>
        
        
    </body>
</html>
