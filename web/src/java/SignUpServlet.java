import com.classes.PasswordUtil;
import com.classes.User;
import java.io.*;
import java.security.NoSuchAlgorithmException;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.annotation.WebServlet;


@WebServlet("/SignUpServlet")
public class SignUpServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String error_massage = "All fields are required.";
        String phonePattern = "^[0-9]{8,12}$";
        String emailPattern = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$";
        String hashedPassword = null;
        try {
            hashedPassword = PasswordUtil.hashPassword(request.getParameter("password"));
        } catch (NoSuchAlgorithmException ex) {
            Logger.getLogger(SignUpServlet.class.getName()).log(Level.SEVERE, null, ex);
        }
        
        // Create new User object
        User new_user = new User(request.getParameter("username"), hashedPassword, request.getParameter("email"), request.getParameter("phone"));

        // Validate user inputs
        if (new_user.get_username() == null || new_user.get_username().trim().isEmpty() ||
            new_user.get_email() == null || new_user.get_email().trim().isEmpty() ||
            new_user.get_password() == null || new_user.get_password().trim().isEmpty()) {
            request.setAttribute("error", error_massage);
            request.getRequestDispatcher("sign_up_page.jsp").forward(request, response);
            return;
        }

        if (!new_user.get_email().matches(emailPattern)) {
            error_massage = "Wrong email format.";
            request.setAttribute("error", error_massage);
            request.getRequestDispatcher("sign_up_page.jsp").forward(request, response);
            return;
        }

        if (new_user.get_password().length() < 8) {
            error_massage = "Password must be at least 8 characters long.";
            request.setAttribute("error", error_massage);
            request.getRequestDispatcher("sign_up_page.jsp").forward(request, response);
            return;
        }

        if (!new_user.get_phone_number().matches(phonePattern)) {
            error_massage = "Wrong phone number format.";
            request.setAttribute("error", error_massage);
            request.getRequestDispatcher("sign_up_page.jsp").forward(request, response);
            return;
        }

        // Database interaction
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            // Initialize DB connection
            String dbUrl = "jdbc:mysql://localhost:3306/e_commerce";
            String dbUser = "end_user";
            String dbPassword = "Irmuun2018";
            con = DriverManager.getConnection(dbUrl, dbUser, dbPassword);

            // Check if the email already exists in the database
            String checkEmailQuery = "SELECT COUNT(*) AS count FROM username WHERE email = ?";
            ps = con.prepareStatement(checkEmailQuery);
            ps.setString(1, new_user.get_email().trim());
            rs = ps.executeQuery();

            if (rs.next() && rs.getInt("count") > 0) {
                error_massage = "Email already taken.";
                request.setAttribute("error", error_massage);
                request.getRequestDispatcher("sign_up_page.jsp").forward(request, response);
                return;
            }

            // Insert new user into the database
            String insertUserQuery = "INSERT INTO username (username, email, password, phone_number) VALUES (?, ?, ?, ?)";
            ps = con.prepareStatement(insertUserQuery);
            ps.setString(1, new_user.get_username());
            ps.setString(2, new_user.get_email());
            ps.setString(3, new_user.get_password());
            ps.setString(4, new_user.get_phone_number());
            ps.executeUpdate();
            System.out.println(hashedPassword);

            // Get the newly inserted user_id
            String getUserIdQuery = "SELECT user_id FROM username WHERE email = ?";
            ps = con.prepareStatement(getUserIdQuery);
            ps.setString(1, new_user.get_email());
            rs = ps.executeQuery();

            int userId = -1;
            if (rs.next()) {
                userId = rs.getInt("user_id");
            }

            // Insert a cart for the new user
            String insertCartQuery = "INSERT INTO cart (user_id, total_price, create_time, update_time) VALUES (?, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)";
            ps = con.prepareStatement(insertCartQuery);
            ps.setInt(1, userId);
            ps.executeUpdate();

            // Redirect to the sign-in page
            response.sendRedirect("sign_in_page.jsp");

        } catch (SQLException e) {
            // Handle exceptions
            request.setAttribute("errorMessage", "Database error occurred: " + e.getMessage());
            request.getRequestDispatcher("error.jsp").forward(request, response);
        } finally {
            // Close resources
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (con != null) con.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    // For GET requests, you can forward to the sign-up page (if needed)
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("sign_up_page.jsp").forward(request, response);
    }
}
