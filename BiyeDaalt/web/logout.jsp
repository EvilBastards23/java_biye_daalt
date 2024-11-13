<%@page import="javax.servlet.http.HttpSession"%>
<%@page import="javax.servlet.http.Cookie"%>
<%
    // Invalidate the session to clear session attributes
    HttpSession ses = request.getSession(false);
    if (ses != null) {
        ses.invalidate();
    }

    // Clear cookies by setting their max age to 0
    Cookie[] cookies = request.getCookies();
    if (cookies != null) {
        for (Cookie cookie : cookies) {
            if ("user_id".equals(cookie.getName()) || "role".equals(cookie.getName())) {
                cookie.setMaxAge(0); // Expire the cookie
                cookie.setPath("/"); // Ensure it applies to the entire app
                response.addCookie(cookie);
            }
        }
    }
    response.sendRedirect("sign_in_page.jsp");
    %>