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
import java.util.List;
import model.Customer;
import model.ShippingAddress;
import model.Users;

@WebServlet(name = "AddressController", urlPatterns = {"/customer/address"})
public class AddressController extends HttpServlet {

    private final ShippingAddressDAO addressDAO = new ShippingAddressDAO();
    private final CustomerDAO customerDAO = new CustomerDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Users user = (Users) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Customer customer = customerDAO.getCustomerByUserId(user.getUserId());
        if (customer == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Customer data not found for this user.");
            return;
        }

        List<ShippingAddress> addressList = addressDAO.getAddressesByCustomerId(customer.getCustomerId());

        request.setAttribute("addressList", addressList);
        request.getRequestDispatcher("/WEB-INF/views/customer/address/address.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Users user = (Users) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Customer customer = customerDAO.getCustomerByUserId(user.getUserId());
        if (customer == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Customer data not found for this user.");
            return;
        }

        try {
            String recipientName = request.getParameter("recipientName");
            String phoneNumber = request.getParameter("phoneNumber");
            String addressDetails = request.getParameter("addressDetails");
            String city = request.getParameter("city");

            ShippingAddress newAddress = new ShippingAddress();
            newAddress.setCustomerId(customer.getCustomerId());
            newAddress.setRecipientName(recipientName);
            newAddress.setPhoneNumber(phoneNumber);
            newAddress.setAddressDetails(addressDetails);
            newAddress.setCity(city);
            newAddress.setCountry("Vietnam"); // Tạm thời
            newAddress.setIsDefault(false);

            addressDAO.addAddress(newAddress);

            session.setAttribute("successMessage", "New address added successfully!");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "Error adding new address.");
        }

        response.sendRedirect(request.getContextPath() + "/customer/address");
    }
}
