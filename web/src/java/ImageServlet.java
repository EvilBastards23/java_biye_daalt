import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.sql.*;

@WebServlet("/image")
public class ImageServlet extends HttpServlet {
    private static final String IMAGE_QUERY = "SELECT low_res, medium_res, high_res FROM images WHERE id = ?";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String id = request.getParameter("id");
        String resolution = request.getParameter("res");

        if (id == null || id.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Image ID is required");
            return;
        }

        try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/e_commerce?maxAllowedPacket=104857600", "end_user", "Irmuun2018");
             PreparedStatement statement = connection.prepareStatement(IMAGE_QUERY)) {

            // Ensure id is parsed as an integer
            int imageId = Integer.parseInt(id);
            statement.setInt(1, imageId);

            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    byte[] imageData = null;


                    if (imageData != null && imageData.length > 0) {
                        // Set content type to PNG
                        response.setContentType("image/png");
                        response.setContentLength(imageData.length);

                        // Write image data directly to response output stream
                        response.getOutputStream().write(imageData);
                        response.getOutputStream().flush();
                    } else {
                        response.sendError(HttpServletResponse.SC_NOT_FOUND, "Image data is empty");
                    }
                } else {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "Image not found");
                }
            }
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid image ID");
        } catch (SQLException e) {
            log("Database error", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error");
        }
    }
}