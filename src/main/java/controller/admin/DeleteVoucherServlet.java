package controller.admin;

import dao.VoucherDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/deleteVoucher")
public class DeleteVoucherServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(DeleteVoucherServlet.class.getName());
    private VoucherDAO voucherDAO;

    @Override
    public void init() throws ServletException {
        voucherDAO = new VoucherDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String voucherIdParam = request.getParameter("voucherId");
        String successMessage = null;
        String errorMessage = null;

        try {
            long voucherId = Long.parseLong(voucherIdParam);
            boolean deleted = voucherDAO.deleteVoucher(voucherId);

            if (deleted) {
                successMessage = "Voucher deleted successfully!";
            } else {
                errorMessage = "Voucher not found or could not be deleted.";
            }
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Invalid voucher ID format: {0}", voucherIdParam);
            errorMessage = "Invalid voucher ID.";
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error deleting voucher: {0}", e.getMessage());
            errorMessage = "An error occurred while deleting the voucher.";
        }

        // Redirect to the voucher list page with a message
        String redirectUrl = request.getContextPath() + "/vouchers";
        if (successMessage != null) {
            redirectUrl += "?successMessage=" + java.net.URLEncoder.encode(successMessage, "UTF-8");
        } else if (errorMessage != null) {
            redirectUrl += "?errorMessage=" + java.net.URLEncoder.encode(errorMessage, "UTF-8");
        }

        response.sendRedirect(redirectUrl);
    }

    @Override
    public void destroy() {
        if (voucherDAO != null) {
            voucherDAO.closeConnection();
        }
    }
}