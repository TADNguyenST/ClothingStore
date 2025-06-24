package controller.customer;

import dao.CustomerDAO;
import dao.ShippingAddressDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.Customer;
import model.ShippingAddress;
import model.Users;

@WebServlet(name = "EditAddressController", urlPatterns = {"/customer/edit-address"})
public class EditAddressController extends HttpServlet {

    private final ShippingAddressDAO addressDAO = new ShippingAddressDAO();
    private final CustomerDAO customerDAO = new CustomerDAO();

    // doGet: Hiển thị form với dữ liệu cũ
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Users user = (Users) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            long addressId = Long.parseLong(request.getParameter("id"));
            Customer customer = customerDAO.getCustomerByUserId(user.getUserId());

            ShippingAddress address = addressDAO.getAddressById(addressId, customer.getCustomerId());

            if (address != null) {
                request.setAttribute("address", address);
                request.getRequestDispatcher("/WEB-INF/views/customer/address/edit-address.jsp").forward(request, response);
            } else {
                // Không tìm thấy địa chỉ hoặc không đúng chủ sở hữu
                response.sendRedirect(request.getContextPath() + "/customer/address?error=notFound");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/customer/address?error=invalidId");
        }
    }

    // doPost: Xử lý cập nhật dữ liệu
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Users user = (Users) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            long addressId = Long.parseLong(request.getParameter("addressId"));
            Customer customer = customerDAO.getCustomerByUserId(user.getUserId());

            String recipientName = request.getParameter("recipientName");
            String phoneNumber = request.getParameter("phoneNumber");
            String addressDetails = request.getParameter("addressDetails");
            String city = request.getParameter("city");

            ShippingAddress addressToUpdate = new ShippingAddress();
            addressToUpdate.setAddressId(addressId);
            addressToUpdate.setCustomerId(customer.getCustomerId()); // Quan trọng để xác thực
            addressToUpdate.setRecipientName(recipientName);
            addressToUpdate.setPhoneNumber(phoneNumber);
            addressToUpdate.setAddressDetails(addressDetails);
            addressToUpdate.setCity(city);
            addressToUpdate.setCountry("Vietnam"); // Lấy từ DB nếu cần

            boolean success = addressDAO.updateAddress(addressToUpdate);
            if (success) {
                session.setAttribute("successMessage", "Address updated successfully!");
            } else {
                session.setAttribute("errorMessage", "Failed to update address.");
            }
        } catch (Exception e) {
            session.setAttribute("errorMessage", "An error occurred.");
            e.printStackTrace();
        }

        response.sendRedirect(request.getContextPath() + "/customer/address");
    }
}
