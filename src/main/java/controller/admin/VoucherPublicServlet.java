
package controller.admin;

import dao.VoucherDAO;
import model.Voucher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/VoucherPublic")
public class VoucherPublicServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(VoucherPublicServlet.class.getName());
    private VoucherDAO voucherDAO;

    @Override
    public void init() throws ServletException {
        voucherDAO = new VoucherDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Get search parameters
            String code = request.getParameter("code");
            String name = request.getParameter("name");
            List<Voucher> voucherList;
            
            // Apply filter for public vouchers (visibility = 1)
            if ((code != null && !code.trim().isEmpty()) || (name != null && !name.trim().isEmpty())) {
                voucherList = voucherDAO.getVouchersByFilter(code, name, true, true);
            } else {
                voucherList = voucherDAO.getPublicVouchers();
            }
            
            request.setAttribute("voucherList", voucherList);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error retrieving public voucher list: {0}", e.getMessage());
            request.setAttribute("errorMessage", "Lỗi khi lấy dữ liệu voucher công khai: " + e.getMessage());
        }

        // Forward to JSP
        request.getRequestDispatcher("WEB-INF/views/customer/voucher/public-voucher-list.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        Long customerId = (session != null && session.getAttribute("customerId") != null) 
                ? (Long) session.getAttribute("customerId") : null;

        try {
            String voucherIdStr = request.getParameter("voucherId");

            if (voucherIdStr == null || customerId == null) {
                request.setAttribute("errorMessage", "Vui lòng đăng nhập và chọn voucher hợp lệ!");
            } else {
                long voucherId = Long.parseLong(voucherIdStr);
                
                // Check if voucher is already saved by the customer
                if (voucherDAO.isVoucherSavedByCustomer(voucherId, customerId)) {
                    request.setAttribute("errorMessage", "Bạn đã lưu voucher này rồi!");
                } else {
                    boolean saved = voucherDAO.saveVoucherForCustomer(voucherId, customerId);
                    if (saved) {
                        request.setAttribute("successMessage", "Lưu voucher thành công!");
                    } else {
                        request.setAttribute("errorMessage", "Lỗi khi lưu voucher!");
                    }
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error saving voucher: {0}", e.getMessage());
            request.setAttribute("errorMessage", "Lỗi khi lưu voucher: " + e.getMessage());
        } catch (NumberFormatException e) {
            LOGGER.log(Level.SEVERE, "Invalid voucher ID format: {0}", e.getMessage());
            request.setAttribute("errorMessage", "Mã voucher không hợp lệ!");
        }
        
        // Refresh the voucher list after saving
        doGet(request, response);
    }

    @Override
    public void destroy() {
        if (voucherDAO != null) {
            voucherDAO.closeConnection();
        }
    }
}
