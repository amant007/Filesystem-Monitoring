<%@ page import="javax.mail.*, javax.mail.internet.*, java.util.*" %>
<%
    final String emailHost = "smtp.gmail.com";
    final String emailPort = "587"; 
    final String emailUser = "brian7skyline@gmail.com"; 
    final String emailPass = "bsqa oera ipej ncyf"; 
    final String recipientEmails = "brian7skyline@gmail.com"; 

    void sendEmail(String subject, String messageContent) throws MessagingException {
        Properties props = new Properties();
        props.put("mail.smtp.host", emailHost);
        props.put("mail.smtp.port", emailPort);
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");

        Session session = Session.getInstance(props, new javax.mail.Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(emailUser, emailPass);
            }
        });

        session.setDebug(true);

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(emailUser));
            for (String recipient : recipientEmails.split(",\\s*")) {
                message.addRecipient(Message.RecipientType.TO, new InternetAddress(recipient));
            }
            message.setSubject(subject);
            message.setText(messageContent);

            Transport.send(message);
            System.out.println("Email sent successfully");
        } catch (MessagingException e) {
            System.err.println("Error sending email: " + e.getMessage());
            throw e;
        }
    }

    try {
        sendEmail("Test Subject", "Test Email Content");
        response.setContentType("application/json");
        response.getWriter().write("{\"status\": \"Email sent successfully\"}");
    } catch (MessagingException e) {
        e.printStackTrace();
        response.setContentType("application/json");
        response.getWriter().write("{\"error\": \"Error sending email: " + e.getMessage() + "\"}");
    } catch (Exception e) {
        e.printStackTrace();
        response.setContentType("application/json");
        response.getWriter().write("{\"error\": \"Unexpected error: " + e.getMessage() + "\"}");
    }
%>
