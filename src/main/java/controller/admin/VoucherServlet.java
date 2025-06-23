package controller.admin;

import dao.VoucherDAO;
import model.Voucher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/vouchers")
public class VoucherServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(VoucherServlet.class.getName());
    private VoucherDAO voucherDAO;

    @Override
    public void init() throws ServletException {
        voucherDAO = new VoucherDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Get search parameter
            String code = request.getParameter("code");
            List<Voucher> voucherList;
            
            // Apply filter if code is provided
            if (code != null && !code.trim().isEmpty()) {
                voucherList = voucherDAO.getVouchersByFilter(code, null, false);
            } else {
                voucherList = voucherDAO.getAllVouchers();
            }
            
            request.setAttribute("voucherList", voucherList);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error retrieving voucher list: {0}", e.getMessage());
            request.setAttribute("errorMessage", "Lỗi khi lấy dữ liệu voucher: " + e.getMessage());
        }

        // Forward to JSP
        request.getRequestDispatcher("WEB-INF/views/admin/voucher/voucher-list.jsp").forward(request, response);
    }

    @Override
    public void destroy() {
        if (voucherDAO != null) {
            voucherDAO.closeConnection();
        }
    }
}