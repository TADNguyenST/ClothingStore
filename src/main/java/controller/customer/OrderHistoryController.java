/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.customer;

import dao.OrderHistoryDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import model.OrderHistory;

@WebServlet("/OrderHistory")
public class OrderHistoryController extends HttpServlet {
    private OrderHistoryDAO orderHistoryDao; // đổi tên

    @Override
    public void init() {
        orderHistoryDao = new OrderHistoryDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession();
        Object userIdAttr = session.getAttribute("user_id");
        if (userIdAttr == null) {
            userIdAttr = session.getAttribute("userId");
        }
        Long userId = null;
        if (userIdAttr instanceof Number) {
            userId = ((Number) userIdAttr).longValue();
        } else if (userIdAttr instanceof String) {
            try {
                userId = Long.parseLong((String) userIdAttr);
            } catch (NumberFormatException ignored) {}
        }

        if (userId == null) {
            resp.sendRedirect(req.getContextPath() + "/Login");
            return;
        }

        // gọi method DAO (sửa lại biến)
        List<OrderHistory> historyList = orderHistoryDao.getOrderHistoryByUserId(userId);
        req.setAttribute("historyList", historyList);
        req.getRequestDispatcher("/WEB-INF/views/customer/profile/historyorder.jsp").forward(req, resp);
    }
}





