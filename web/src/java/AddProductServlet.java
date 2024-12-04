
import java.io.File;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import java.sql.*;

@WebServlet("/AddProductServlet")
@MultipartConfig // Required for handling file uploads
public class AddProductServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("user_id") == null) {
                response.sendRedirect("sign_in_page.jsp");
                return;
            }
            String userId = session.getAttribute("user_id").toString();

            // Retrieve form parameters
            String modelNumber = request.getParameter("model_number");
            String size = request.getParameter("size");
            String color = request.getParameter("color");
            String productName = request.getParameter("product_name");
            String category = request.getParameter("category");

            if (modelNumber == null || size == null || color == null || productName == null || category == null) {
                request.setAttribute("error", "Missing required product information");
                request.getRequestDispatcher("seller_page.jsp#add_product").forward(request, response);
                return;
            }

            // Handle file upload
            Part filePart = request.getPart("product_image");
            String imagePath = null;
            if (filePart != null && filePart.getSize() > 0) {
                String fileName = modelNumber + "_" + getSubmittedFileName(filePart);
                String uploadPath = getServletContext().getRealPath("") + File.separator + "product_images";
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) uploadDir.mkdir();
                filePart.write(uploadPath + File.separator + fileName);
                imagePath = "product_images/" + fileName;
            } else {
                request.setAttribute("error", "Product image is required");
                request.getRequestDispatcher("seller_page.jsp#add_product").forward(request, response);
                return;
            }

            // Insert product into database
            try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/e_commerce", "seller", "Irmuun2018")) {
                String categoryQuery = "SELECT category_id FROM category WHERE category_name = ?";
                String sellerQuery = "SELECT seller_id FROM seller WHERE user_id = ?";
                String insertQuery = "INSERT INTO product (model_number, size, color, product_name, category_id, seller_id, image_blob) VALUES (?, ?, ?, ?, ?, ?, ?)";

                // Fetch category_id
                int categoryId;
                try (PreparedStatement stmt = conn.prepareStatement(categoryQuery)) {
                    stmt.setString(1, category);
                    try (ResultSet rs = stmt.executeQuery()) {
                        if (rs.next()) {
                            categoryId = rs.getInt("category_id");
                        } else {
                            throw new Exception("Invalid category");
                        }
                    }
                }

                // Fetch seller_id
                int sellerId;
                try (PreparedStatement stmt = conn.prepareStatement(sellerQuery)) {
                    stmt.setString(1, userId);
                    try (ResultSet rs = stmt.executeQuery()) {
                        if (rs.next()) {
                            sellerId = rs.getInt("seller_id");
                        } else {
                            throw new Exception("Invalid seller");
                        }
                    }
                }

                // Insert product
                try (PreparedStatement stmt = conn.prepareStatement(insertQuery)) {
                    stmt.setString(1, modelNumber);
                    stmt.setString(2, size);
                    stmt.setString(3, color);
                    stmt.setString(4, productName);
                    stmt.setInt(5, categoryId);
                    stmt.setInt(6, sellerId);
                    stmt.setString(7, imagePath);
                    stmt.executeUpdate();
                }
            }

            response.sendRedirect("seller_page.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error processing product: " + e.getMessage());
            request.getRequestDispatcher("seller_page.jsp#add_product").forward(request, response);
        }
    }

    private String getSubmittedFileName(Part part) {
        for (String cd : part.getHeader("content-disposition").split(";")) {
            if (cd.trim().startsWith("filename")) {
                return cd.substring(cd.indexOf('=') + 1).trim().replace("\"", "");
            }
        }
        return null;
    }
}
