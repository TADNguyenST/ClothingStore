/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.customer;

import dao.ShippingAddressDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.ShippingAddress;
import model.Users; // Assuming 'Users' is your User model
import java.io.IOException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Handles all actions related to the customer's address book.
 */
@WebServlet(name = "AddressController", urlPatterns = {"/customer/address"})
public class AddressController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(AddressController.class.getName());
    private final ShippingAddressDAO addressDAO = new ShippingAddressDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action") == null ? "list" : request.getParameter("action");

        // Basic user authentication check for all GET requests
        Users user = getAuthenticatedUser(request);
        if (user == null) {
            LOGGER.log(Level.WARNING, "Unauthenticated access attempt to /customer/address. Redirecting to login.");
            response.sendRedirect(request.getContextPath() + "/login?message=pleaseLogin");
            return;
        }

        switch (action) {
            case "add":
                showAddForm(request, response);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            default: // "list"
                listAddresses(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            LOGGER.log(Level.WARNING, "POST request to /customer/address with no action parameter.");
            response.sendRedirect(request.getContextPath() + "/customer/address?error=unknownAction");
            return;
        }

        // Basic user authentication check for all POST requests
        Users user = getAuthenticatedUser(request);
        if (user == null) {
            LOGGER.log(Level.WARNING, "Unauthenticated access attempt (POST) to /customer/address. Redirecting to login.");
            response.sendRedirect(request.getContextPath() + "/login?message=pleaseLogin");
            return;
        }

        switch (action) {
            case "add":
                addAddress(request, response);
                break;
            case "update":
                updateAddress(request, response);
                break;
            case "delete":
                deleteAddress(request, response);
                break;
            case "setDefault":
                setDefaultAddress(request, response);
                break;
            default:
                LOGGER.log(Level.WARNING, "Unknown action parameter received: {0}", action);
                response.sendRedirect(request.getContextPath() + "/customer/address?error=unknownAction");
                break;
        }
    }

    // ================== HELPER METHODS ==================
    /**
     * Retrieves the authenticated user from the session. Includes a mock user
     * for development/testing if no user is in session.
     */
    private Users getAuthenticatedUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            LOGGER.log(Level.INFO, "No user found in session. Creating mock user for testing.");
            Users mockUser = new Users();
            mockUser.setUserId(1); // Use a test user ID (e.g., ID 1)
            mockUser.setFullName("Test User");
            // Optionally, put mock user in session for subsequent requests in the same session
            if (session != null) {
                session.setAttribute("user", mockUser);
            }
            return mockUser;
        }
        return (Users) session.getAttribute("user");
    }

    /**
     * Lists all shipping addresses for the authenticated user.
     */
    private void listAddresses(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Users user = getAuthenticatedUser(request);
        long customerId = user.getUserId();
        LOGGER.log(Level.INFO, "Listing addresses for customer ID: {0}", customerId);

        List<ShippingAddress> addresses = addressDAO.getAddressesByCustomerId(customerId);
        request.setAttribute("addressList", addresses);
        request.getRequestDispatcher("/WEB-INF/views/customer/address/address-list.jsp").forward(request, response);
    }

    /**
     * Shows the form to add a new address.
     */
    private void showAddForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/customer/address/add-address.jsp").forward(request, response);
    }

    /**
     * Shows the form to edit an existing address.
     */
    private void showEditForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Users user = getAuthenticatedUser(request);
        try {
            long addressId = Long.parseLong(request.getParameter("id"));
            long customerId = user.getUserId();

            ShippingAddress address = addressDAO.getAddressById(addressId);

            // Security check: Ensure the address belongs to the current user
            if (address != null && address.getCustomerId() == customerId) {
                request.setAttribute("address", address);
                request.getRequestDispatcher("/WEB-INF/views/customer/address/edit-address.jsp").forward(request, response);
                LOGGER.log(Level.INFO, "Displaying edit form for address ID: {0}", addressId);
            } else {
                LOGGER.log(Level.WARNING, "Access denied: Customer {0} attempted to edit address {1} which does not belong to them or does not exist.", new Object[]{customerId, addressId});
                response.sendRedirect(request.getContextPath() + "/customer/address?error=accessDenied");
            }
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Invalid address ID format for edit: {0}", request.getParameter("id"));
            response.sendRedirect(request.getContextPath() + "/customer/address?error=invalidId");
        }
    }

    /**
     * Processes the request to add a new address.
     */
    private void addAddress(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Users user = getAuthenticatedUser(request);
        long customerId = user.getUserId();

        ShippingAddress address = new ShippingAddress();
        address.setCustomerId(customerId);
        address.setRecipientName(request.getParameter("recipientName"));
        address.setPhoneNumber(request.getParameter("phoneNumber"));
        address.setAddressDetails(request.getParameter("addressDetails"));
        address.setCity(request.getParameter("city"));
        address.setCountry(request.getParameter("country"));
        address.setPostalCode(request.getParameter("postalCode"));
        address.setIsDefault("on".equals(request.getParameter("isDefault"))); // Checkbox value is "on" if checked

        LOGGER.log(Level.INFO, "Attempting to add new address for customer {0}: {1}", new Object[]{customerId, address});

        long newAddressId = addressDAO.addAddress(address);

        if (newAddressId > 0) {
            if (address.isIsDefault()) {
                // If it's explicitly set as default, call setDefaultAddress
                boolean defaultSet = addressDAO.setDefaultAddress(newAddressId, customerId);
                if (!defaultSet) {
                    LOGGER.log(Level.WARNING, "Failed to set new address {0} as default for customer {1}", new Object[]{newAddressId, customerId});
                    // You might want to add an error message here
                }
            }
            response.sendRedirect(request.getContextPath() + "/customer/address?status=addSuccess");
        } else {
            LOGGER.log(Level.SEVERE, "Failed to add address for customer {0}. No ID generated.", customerId);
            response.sendRedirect(request.getContextPath() + "/customer/address?error=addFailed");
        }
    }

    /**
     * Processes the request to update an existing address.
     */
    private void updateAddress(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Users user = getAuthenticatedUser(request);
        try {
            long addressId = Long.parseLong(request.getParameter("addressId"));
            long customerId = user.getUserId();

            ShippingAddress existingAddress = addressDAO.getAddressById(addressId);

            // Security check: Ensure the address exists and belongs to the current user
            if (existingAddress == null || existingAddress.getCustomerId() != customerId) {
                LOGGER.log(Level.WARNING, "Access denied: Customer {0} attempted to update address {1} which does not belong to them or does not exist.", new Object[]{customerId, addressId});
                response.sendRedirect(request.getContextPath() + "/customer/address?error=accessDenied");
                return;
            }

            // Update fields from request parameters
            existingAddress.setRecipientName(request.getParameter("recipientName"));
            existingAddress.setPhoneNumber(request.getParameter("phoneNumber"));
            existingAddress.setAddressDetails(request.getParameter("addressDetails"));
            existingAddress.setCity(request.getParameter("city"));
            existingAddress.setCountry(request.getParameter("country"));
            existingAddress.setPostalCode(request.getParameter("postalCode"));
            boolean isDefault = "on".equals(request.getParameter("isDefault"));
            // Note: We don't set existingAddress.setIsDefault(isDefault) directly here.
            // The default logic is handled by setDefaultAddress method if needed.

            LOGGER.log(Level.INFO, "Attempting to update address ID {0} for customer {1}", new Object[]{addressId, customerId});
            boolean updateSuccess = addressDAO.updateAddress(existingAddress);

            if (updateSuccess) {
                if (isDefault) {
                    // If the user checked "Set as default", call the DAO method to manage defaults
                    boolean defaultSet = addressDAO.setDefaultAddress(addressId, customerId);
                    if (!defaultSet) {
                        LOGGER.log(Level.WARNING, "Failed to set updated address {0} as default for customer {1}", new Object[]{addressId, customerId});
                        // Consider adding an error message for default setting failure
                    }
                }
                response.sendRedirect(request.getContextPath() + "/customer/address?status=updateSuccess");
            } else {
                LOGGER.log(Level.SEVERE, "Failed to update address ID {0} for customer {1}", new Object[]{addressId, customerId});
                response.sendRedirect(request.getContextPath() + "/customer/address?error=updateFailed");
            }

        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Invalid address ID format for update: {0}", request.getParameter("addressId"));
            response.sendRedirect(request.getContextPath() + "/customer/address?error=invalidId");
        }
    }

    /**
     * Processes the request to delete an address.
     */
    private void deleteAddress(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Users user = getAuthenticatedUser(request);
        try {
            long addressId = Long.parseLong(request.getParameter("id"));
            long customerId = user.getUserId();

            ShippingAddress address = addressDAO.getAddressById(addressId);
            // Security check
            if (address != null && address.getCustomerId() == customerId) {
                LOGGER.log(Level.INFO, "Attempting to delete address ID {0} for customer {1}", new Object[]{addressId, customerId});
                boolean deleteSuccess = addressDAO.deleteAddress(addressId);
                if (deleteSuccess) {
                    response.sendRedirect(request.getContextPath() + "/customer/address?status=deleted");
                } else {
                    LOGGER.log(Level.SEVERE, "Failed to delete address ID {0} for customer {1}", new Object[]{addressId, customerId});
                    response.sendRedirect(request.getContextPath() + "/customer/address?error=deleteFailed");
                }
            } else {
                LOGGER.log(Level.WARNING, "Access denied: Customer {0} attempted to delete address {1} which does not belong to them or does not exist.", new Object[]{customerId, addressId});
                response.sendRedirect(request.getContextPath() + "/customer/address?error=accessDenied");
            }
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Invalid address ID format for delete: {0}", request.getParameter("id"));
            response.sendRedirect(request.getContextPath() + "/customer/address?error=invalidId");
        }
    }

    /**
     * Processes the request to set an address as default.
     */
    private void setDefaultAddress(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Users user = getAuthenticatedUser(request);
        try {
            long addressId = Long.parseLong(request.getParameter("id"));
            long customerId = user.getUserId();

            ShippingAddress address = addressDAO.getAddressById(addressId);
            // Security check
            if (address != null && address.getCustomerId() == customerId) {
                LOGGER.log(Level.INFO, "Attempting to set address ID {0} as default for customer {1}", new Object[]{addressId, customerId});
                boolean defaultSet = addressDAO.setDefaultAddress(addressId, customerId);
                if (defaultSet) {
                    response.sendRedirect(request.getContextPath() + "/customer/address?status=defaultSet");
                } else {
                    LOGGER.log(Level.SEVERE, "Failed to set address ID {0} as default for customer {1}", new Object[]{addressId, customerId});
                    response.sendRedirect(request.getContextPath() + "/customer/address?error=setDefaultFailed");
                }
            } else {
                LOGGER.log(Level.WARNING, "Access denied: Customer {0} attempted to set address {1} as default which does not belong to them or does not exist.", new Object[]{customerId, addressId});
                response.sendRedirect(request.getContextPath() + "/customer/address?error=accessDenied");
            }
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Invalid address ID format for set default: {0}", request.getParameter("id"));
            response.sendRedirect(request.getContextPath() + "/customer/address?error=invalidId");
        }
    }
}
