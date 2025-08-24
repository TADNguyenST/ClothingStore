package controller.customer;

import dao.CustomerVoucherDAO;
import model.CustomerVoucher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.stream.Collectors;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/customerVoucher")
public class CustomerVoucherServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(CustomerVoucherServlet.class.getName());
    private CustomerVoucherDAO customerVoucherDAO;

    @Override
    public void init() throws ServletException {
        customerVoucherDAO = new CustomerVoucherDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Get customerId parameter
            String customerIdParam = request.getParameter("customerId");
            List<CustomerVoucher> voucherList;

            // Apply filter if customerId is provided
            if (customerIdParam != null && !customerIdParam.trim().isEmpty()) {
                long customerId = Long.parseLong(customerIdParam);
                voucherList = customerVoucherDAO.getCustomerVouchers(customerId);
            } else {
                // Optionally, handle case where no customerId is provided
                voucherList = customerVoucherDAO.getAllCustomerVouchers();
            }

            // Filter out used vouchers
            voucherList = voucherList.stream()
                                    .filter(voucher -> !voucher.isIsUsed())
                                    .collect(Collectors.toList());

            request.setAttribute("voucherList", voucherList);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error retrieving customer voucher list: {0}", e.getMessage());
            request.setAttribute("errorMessage", "Lỗi khi lấy dữ liệu voucher của khách hàng: " + e.getMessage());
        } catch (NumberFormatException e) {
            LOGGER.log(Level.SEVERE, "Invalid customer ID format: {0}", e.getMessage());
            request.setAttribute("errorMessage", "ID khách hàng không hợp lệ: " + e.getMessage());
        }
        
        // Forward to JSP
        request.getRequestDispatcher("WEB-INF/views/customer/voucher/customer_voucher.jsp").forward(request, response);
    }

    @Override
    public void destroy() {
        if (customerVoucherDAO != null) {
            customerVoucherDAO.closeConnection();
        }
    }
}