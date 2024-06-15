import javax.mail.*;
import javax.mail.internet.*;
import java.util.*;

public class EmailSender {
    private static final String emailHost = "smtp.gmail.com";
    private static final String emailPort = "587"; 
    private static final String emailUser = "brian7skyline@gmail.com"; 
    private static final String emailPass = "bsqa oera ipej ncyf"; 
    private static final String recipientEmails = "brian7skyline@gmail.com"; 

    public static void sendEmail(String subject, String messageContent) throws MessagingException {
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
}
