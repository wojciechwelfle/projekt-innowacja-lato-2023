 public with sharing class EmailManager {
  
    public static Messaging.SingleEmailMessage createSingleEmail(
      String emailAddress,
      String emailTextBody,
      String emailSubject
    ) {
      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
      String[] toAddresses = new List<String>{ emailAddress };
      mail.setToAddresses(toAddresses);
      mail.setSubject(emailSubject);
      mail.setPlainTextBody(emailTextBody);
      return mail;
    }

    public static void sendEmail(String subject, String body) {
        Messaging.sendEmail(
          new Messaging.Email[] {EmailManager.createSingleEmail(
              UserInfo.getUserEmail(), body, subject
            )}
        );
    }

    public static void sendErrorEmail(String subject, Map<String, List<String>> errorsMap) {

        List<String> body = new List<String>();
        for (String statusCode : errorsMap.keySet()) {
            body.add('Status Code: ' + statusCode + ', Facility IDs: ' + 'error: ' + errorsMap.get(statusCode));
        }
        Messaging.sendEmail(
          new Messaging.Email[] {EmailManager.createSingleEmail(
              UserInfo.getUserEmail(), body.toString(), subject
            )}
        );
    }
  }