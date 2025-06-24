/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
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
import model.Users;

@WebServlet(name = "AddressActionController", urlPatterns = {"/customer/address/action"})
public class AddressActionController extends HttpServlet {

    private final ShippingAddressDAO addressDAO = new ShippingAddressDAO();
    private final CustomerDAO customerDAO = new CustomerDAO();

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
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Customer not found.");
            return;
        }

        String action = request.getParameter("action");
        long addressId = Long.parseLong(request.getParameter("addressId"));
        long customerId = customer.getCustomerId();

        boolean success = false;
        String message = "";

        if ("delete".equals(action)) {
            success = addressDAO.deleteAddress(addressId, customerId);
            message = success ? "Address deleted successfully." : "Failed to delete address.";
        } else if ("setDefault".equals(action)) {
            success = addressDAO.setDefaultAddress(addressId, customerId);
            message = success ? "Default address has been set." : "Failed to set default address.";
        }

        if (success) {
            session.setAttribute("successMessage", message);
        } else {
            session.setAttribute("errorMessage", message);
        }

        response.sendRedirect(request.getContextPath() + "/customer/address");
    }
}
