@isTest
public without sharing class EmailManagerTests {

    @isTest
    static void testCreateSingleEmail() {
        Messaging.SingleEmailMessage email = EmailManager.createSingleEmail('test@example.com', 'Test Body', 'Test Subject');
        
        Assert.areNotEqual(null, email);
        
        Assert.areEqual('test@example.com', email.getToAddresses()[0]);
        Assert.areEqual('Test Subject', email.getSubject());
        Assert.areEqual('Test Body', email.getPlainTextBody());
    }

    @isTest
    static void testSendEmail() {
        Test.startTest();
        
        EmailManager.sendEmail('Test Subject', 'Test Body');
        Test.stopTest();
        
        List<EmailMessage> emails = [
        SELECT TextBody, Subject, ToAddress, Id
        FROM EmailMessage
        WHERE ToAddress =: UserInfo.getUserEmail()
        ];
        Assert.areNotEqual(0, emails.size());
        Assert.areEqual('Test Subject', emails[0].Subject);
        Assert.areEqual('Test Body', emails[0].TextBody);
    }

    @isTest
    static void testSendErrorEmail() {
        Test.startTest();
        
        Map<String, List<String>> errorsMap = new Map<String, List<String>>{
            '500' => new List<String>{'123', '456'},
            '404' => new List<String>{'789'}
        };
        
        EmailManager.sendErrorEmail('Error Subject', errorsMap);
        Test.stopTest();
        
        List<EmailMessage> emails = [
        SELECT TextBody, Subject, ToAddress, Id
        FROM EmailMessage
        WHERE ToAddress =: UserInfo.getUserEmail()
        ];
        Assert.areNotEqual(0, emails.size());
        Assert.areEqual('Error Subject', emails[0].Subject);
        Assert.areEqual('Status Code: 500, error: 123, 456\nStatus Code: 404, error: 789', emails[0].TextBody);
    }
}
