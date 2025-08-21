/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package util;

/**
 *
 * @author Khoa
 */
import jakarta.mail.*;
import jakarta.mail.internet.*;
import java.util.Properties;

public class EmailUtil {
    public static boolean sendEmail(String toEmail, String subject, String otp) {
        final String fromEmail = "clothingstoreg02@gmail.com";
        final String password = "ilgwgwamjbomishj"; // dùng App Password của Google

        Properties props = new Properties();
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");

        Session session = Session.getInstance(props, new Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(fromEmail, password);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(fromEmail));
            message.setRecipient(Message.RecipientType.TO, new InternetAddress(toEmail));
            message.setSubject(subject);

            // Nội dung HTML
            String htmlContent = ""
                + "<p>You have just submitted a request to verify an account at <strong>ClothingStore</strong>.</p>"
                + "<p>Your verification code (OTP) is:</p>"
                + "<h2 style='color: #667eea'>" + otp + "</h2>"
                + "<p>Please enter this code to complete registration. The code is valid for 5 minutes.</p>"
                + "<br><p>Sincerely,<br>ClothingStore Team</p>";

            message.setContent(htmlContent, "text/html; charset=UTF-8");

            Transport.send(message);
            return true;
        } catch (MessagingException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ================== HÀM MỚI THÊM ==================
    /**
     * Gửi email HTML với nội dung tuỳ chỉnh.
     * @param toEmail Người nhận
     * @param subject Tiêu đề email
     * @param htmlContent Nội dung HTML (full body)
     * @return true nếu gửi thành công
     */
    public static boolean sendEmailHtml(String toEmail, String subject, String htmlContent) {
        final String fromEmail = "clothingstoreg02@gmail.com";
        final String password = "ilgwgwamjbomishj"; // dùng App Password của Google

        Properties props = new Properties();
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");

        Session session = Session.getInstance(props, new Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(fromEmail, password);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(fromEmail));
            message.setRecipient(Message.RecipientType.TO, new InternetAddress(toEmail));
            message.setSubject(subject);

            // Nội dung HTML do caller truyền vào
            message.setContent(htmlContent, "text/html; charset=UTF-8");

            Transport.send(message);
            return true;
        } catch (MessagingException e) {
            e.printStackTrace();
            return false;
        }
    }
    // ==================================================
}
