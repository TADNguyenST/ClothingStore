package controller.customer;

import dao.CustomerDAO;
import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.Customer;
import model.Users;

@WebServlet(name = "ProfileController", urlPatterns = {"/Profile"})
public class ProfileController extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final CustomerDAO customerDAO = new CustomerDAO(); 

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/Login");
            return;
        }

        Users sessionUser = (Users) session.getAttribute("user");

        // Lấy thông tin customer từ DB
        Customer customerInfo = customerDAO.getCustomerByUserId(sessionUser.getUserId());

        // Không cần lấy lại user từ DB vì đã có trong session, trừ khi bạn muốn dữ liệu mới nhất
        // Users userInfo = userDAO.getUserById(sessionUser.getUserId());

        if (customerInfo == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Customer profile data not found.");
            return;
        }
        
        request.setAttribute("user", sessionUser); // Dùng user từ session
        request.setAttribute("customer", customerInfo);
        
        request.setAttribute("pageTitle", "My Account");

        // Forward đến file jsp đã được tích hợp
        request.getRequestDispatcher("/WEB-INF/views/customer/profile/profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Hiện tại trang profile chỉ để xem. Logic update sẽ nằm ở EditProfileController.
        // Nếu có form nào post về đây, ta chỉ cần chuyển hướng lại trang profile.
        response.sendRedirect(request.getContextPath() + "/Profile");
    }
}