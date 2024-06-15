import javax.mail.*;
import javax.mail.internet.*;
import javax.net.ssl.SSLSession;

import java.util.Properties;

public class EmailTest {
    public static void main(String[] args) {
        final String emailHost = "smtp.gmail.com";
        final String emailPort = "587";
        final String emailUser = "brian7skyline@gmail.com";
        final String emailPass = "bsqa oera ipej ncyf";
        final String recipientEmails = "brian7skyline@gmail.com";

        Properties props = new Properties();
        props.put("mail.smtp.host", emailHost);
        props.put("mail.smtp.port", emailPort);
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");

        SSLSession session = Session.getInstance(props, new javax.mail.Authenticator() {
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
            message.setSubject("Test Email");
            message.setText("This is a test email.");

            Transport.send(message);
            System.out.println("Email sent successfully");
        } catch (MessagingException e) {
            e.printStackTrace();
            System.err.println("Error sending email: " + e.getMessage());
        }
    }
}
