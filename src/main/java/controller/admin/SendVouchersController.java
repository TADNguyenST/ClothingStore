package controller.admin;

import service.VoucherService;
import model.Users;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet(name = "SendVouchersController", urlPatterns = {"/admin/sendvouchers"})
public class SendVouchersController extends HttpServlet {

    private VoucherService voucherService;

    @Override
    public void init() throws ServletException {
        super.init();
        voucherService = new VoucherService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            request.setAttribute("vouchers", voucherService.getAllVouchers());
            request.setAttribute("customers", voucherService.getAllCustomersWithUserDetails());
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error loading data: " + e.getMessage());
            e.printStackTrace();
        }
        request.getRequestDispatcher("/admin-dashboard/send-vouchers.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String[] selectedVoucherIds = request.getParameterValues("voucherIds");
        List<Integer> voucherIds = null;
        if (selectedVoucherIds != null) {
            try {
                voucherIds = Arrays.stream(selectedVoucherIds)
                               .map(Integer::parseInt)
                               .collect(Collectors.toList());
            } catch (NumberFormatException e) {
                request.setAttribute("errorMessage", "Invalid Voucher ID format.");
                request.getRequestDispatcher("/admin-dashboard/send-vouchers.jsp").forward(request, response);
                return;
            }
        } else {
            request.setAttribute("errorMessage", "No vouchers selected.");
            request.getRequestDispatcher("/admin-dashboard/send-vouchers.jsp").forward(request, response);
            return;
        }

        String[] selectedCustomerEmails = request.getParameterValues("customerEmails");
        List<String> customerEmails = null;
        if (selectedCustomerEmails != null) {
            customerEmails = Arrays.asList(selectedCustomerEmails);
        } else {
            customerEmails = new java.util.ArrayList<>();
        }

        if (customerEmails.isEmpty()) {
            request.setAttribute("errorMessage", "No customer emails provided.");
            request.getRequestDispatcher("/admin-dashboard/send-vouchers.jsp").forward(request, response);
            return;
        }

        boolean success = voucherService.sendVouchersToCustomers(voucherIds, customerEmails);

        if (success) {
            request.setAttribute("message", "Vouchers sent successfully!");
        } else {
            request.setAttribute("errorMessage", "Failed to send vouchers. Check server logs for details.");
        }
        request.getRequestDispatcher("/admin-dashboard/send-vouchers.jsp").forward(request, response);
    }
}
