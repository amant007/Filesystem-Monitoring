<%@ page import="javax.mail.*, javax.mail.internet.*, java.util.*, org.json.JSONObject" %>
<%
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

    Session session = Session.getInstance(props, new javax.mail.Authenticator() {
        protected PasswordAuthentication getPasswordAuthentication() {
            return new PasswordAuthentication(emailUser, emailPass);
        }
    });

    session.setDebug(true);

    try {
        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = request.getReader().readLine()) != null) {
            sb.append(line);
        }
        JSONObject json = new JSONObject(sb.toString());

        String serverName = json.getString("serverName");
        String filesystem = json.getString("filesystem");
        String usage = json.getString("usage");

        String subject = "High Filesystem Usage Alert";
        String messageContent = "Alert: High usage detected on " + serverName + " for filesystem " + filesystem + " with usage " + usage + "%.";

        // Create email message
        Message message = new MimeMessage(session);
        message.setFrom(new InternetAddress(emailUser));
        for (String recipient : recipientEmails.split(",\\s*")) {
            message.addRecipient(Message.RecipientType.TO, new InternetAddress(recipient));
        }
        message.setSubject(subject);
        message.setText(messageContent);

        // Send email
        Transport.send(message);
        System.out.println("Email sent successfully");

        // Send response
        response.setContentType("application/json");
        response.getWriter().write("{\"status\": \"Email sent successfully\"}");
    } catch (JSONException e) {
        e.printStackTrace();
        response.setContentType("application/json");
        response.getWriter().write("{\"error\": \"Invalid JSON data: " + e.getMessage() + "\"}");
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
