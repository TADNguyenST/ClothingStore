/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.auth;

import dao.UserDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import util.EmailUtil;

/**
 *
 * @author Khoa
 */
@WebServlet(name="ForgotPasswordController", urlPatterns={"/ForgotPassword"})
public class ForgotPasswordController extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");

        /* ----------------------------------------------------------
           Custom logic: nếu POST thì xử lý gửi OTP,
           nếu GET thì hiển thị form forgot‑password.jsp
        ---------------------------------------------------------- */
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String email = request.getParameter("email");
            UserDAO dao = new UserDAO();
            if (!dao.isEmailExists(email)) {
                request.setAttribute("error", "Email does not exist.");
                request.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(request, response);
                return;
            }

            int otp = (int) (Math.random() * 900000) + 100000;      // 6‑digit OTP
            boolean sent = EmailUtil.sendEmail(email, "Password Reset OTP", String.valueOf(otp));

            if (!sent) {
                request.setAttribute("error", "Failed to send email. Please try again.");
                request.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(request, response);
                return;
            }

            HttpSession session = request.getSession();
            session.setAttribute("otp", otp);
            session.setAttribute("otpPurpose", "forgot");
            session.setAttribute("emailForgot", email);
            response.sendRedirect("VerifyOTP");
            return;   // kết thúc POST
        }

        /* ------------------ GET: hiển thị form ------------------ */
        request.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(request, response);

        /* --------- HTML mẫu NetBeans (giữ nguyên template) -------- */
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet ForgotPasswordController</title>");  
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ForgotPasswordController at " + request.getContextPath () + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    } 

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        processRequest(request, response);
    } 

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>
}
