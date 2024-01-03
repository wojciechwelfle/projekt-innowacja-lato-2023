/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class MedicalFacilityOpenHoursUpdateTests {

    @TestSetup
    private static void setupTestData() {
        Medical_Facility__c facility1 = new Medical_Facility__c(
            Name = 'Szpital dzieciecy', Phone_Number__c = '',
            Monday_Open_Hours__c = Time.newInstance(9,0,0,0), Tuesday_Open_Hours__c = Time.newInstance(9,30,0,0), Wednesday_Open_Hours__c = Time.newInstance(10,0,0,0), Thursday_Open_Hours__c = Time.newInstance(8,0,0,0), 
            Friday_Open_Hours__c = Time.newInstance(11,0,0,0), Saturday_Open_Hours__c = Time.newInstance(12,0,0,0), Sunday_Open_Hours__c = Time.newInstance(10,30,0,0),
            Monday_Close_Hours__c = Time.newInstance(17,0,0,0), Tuesday_Close_Hours__c = Time.newInstance(18,0,0,0), Wednesday_Close_Hours__c = Time.newInstance(19,0,0,0), Thursday_Close_Hours__c = Time.newInstance(16,30,0,0),
            Friday_Close_Hours__c = Time.newInstance(20,0,0,0), Saturday_Close_Hours__c = Time.newInstance(21,0,0,0), Sunday_Close_Hours__c = Time.newInstance(18,30,0,0),
            City__c = 'ExampleCity', Street__c = 'Main Street', Building_number__c = '123', zip_code__c = '12-345'
        );
        insert facility1;

        Medical_Facility__c facility2 = new Medical_Facility__c(
            Name = 'Izba pomocy', Phone_Number__c = '',
            Monday_Open_Hours__c = Time.newInstance(9,32,0,0), Tuesday_Open_Hours__c = Time.newInstance(6,30,0,0), Wednesday_Open_Hours__c = Time.newInstance(16,0,0,0), Thursday_Open_Hours__c = Time.newInstance(6,0,0,0), 
            Friday_Open_Hours__c = Time.newInstance(15,0,0,0), Saturday_Open_Hours__c = Time.newInstance(12,0,0,0), Sunday_Open_Hours__c = Time.newInstance(10,30,0,0),
            Monday_Close_Hours__c = Time.newInstance(13,30,0,0), Tuesday_Close_Hours__c = Time.newInstance(18,0,0,0), Wednesday_Close_Hours__c = Time.newInstance(19,0,0,0), Thursday_Close_Hours__c = Time.newInstance(16,30,0,0),
            Friday_Close_Hours__c = Time.newInstance(20,0,0,0), Saturday_Close_Hours__c = Time.newInstance(21,0,0,0), Sunday_Close_Hours__c = Time.newInstance(18,30,0,0),
            City__c = 'asdf', Street__c = 'erqw Street', Building_number__c = '321', zip_code__c = '23-385'
        );
        insert facility2;
    }

    @isTest
    private static void testSchedulableOpenHoursUpdate() {
        List<Medical_Facility__c> facilities = [select Id, Name, Phone_Number__c,
        Monday_Open_Hours__c, Tuesday_Open_Hours__c, Wednesday_Open_Hours__c, Thursday_Open_Hours__c, Friday_Open_Hours__c, Saturday_Open_Hours__c, Sunday_Open_Hours__c,
        Monday_Close_Hours__c, Tuesday_Close_Hours__c, Wednesday_Close_Hours__c, Thursday_Close_Hours__c, Friday_Close_Hours__c, Saturday_Close_Hours__c, Sunday_Close_Hours__c
        FROM Medical_Facility__c];

        Test.startTest();

        MedicalFacilityOpenHoursUpdate schedulableInstance = new MedicalFacilityOpenHoursUpdate();
        schedulableInstance.execute(null);

        Test.stopTest();
        
        List<Medical_Facility__c> updatedFacilities = [
            SELECT Id, Name, Phone_Number__c,
            Monday_Open_Hours__c, Tuesday_Open_Hours__c, Wednesday_Open_Hours__c, Thursday_Open_Hours__c, Friday_Open_Hours__c, Saturday_Open_Hours__c, Sunday_Open_Hours__c,
            Monday_Close_Hours__c, Tuesday_Close_Hours__c, Wednesday_Close_Hours__c, Thursday_Close_Hours__c, Friday_Close_Hours__c, Saturday_Close_Hours__c, Sunday_Close_Hours__c
            FROM Medical_Facility__c
        ];
        
        for (Integer i = 0; i < facilities.size(); ++i) {
            Assert.areNotEqual(facilities[i].Monday_Open_Hours__c, updatedFacilities[i].Monday_Open_Hours__c);
            Assert.areNotEqual(facilities[i].Tuesday_Open_Hours__c, updatedFacilities[i].Tuesday_Open_Hours__c);
            Assert.areNotEqual(facilities[i].Wednesday_Open_Hours__c, updatedFacilities[i].Wednesday_Open_Hours__c);
            Assert.areNotEqual(facilities[i].Thursday_Open_Hours__c, updatedFacilities[i].Thursday_Open_Hours__c);
            Assert.areNotEqual(facilities[i].Friday_Open_Hours__c, updatedFacilities[i].Friday_Open_Hours__c);
            Assert.areNotEqual(facilities[i].Saturday_Open_Hours__c, updatedFacilities[i].Saturday_Open_Hours__c);
            Assert.areNotEqual(facilities[i].Sunday_Open_Hours__c, updatedFacilities[i].Sunday_Open_Hours__c);
        
            Assert.areNotEqual(facilities[i].Monday_Close_Hours__c, updatedFacilities[i].Monday_Close_Hours__c);
            Assert.areNotEqual(facilities[i].Tuesday_Close_Hours__c, updatedFacilities[i].Tuesday_Close_Hours__c);
            Assert.areNotEqual(facilities[i].Wednesday_Close_Hours__c, updatedFacilities[i].Wednesday_Close_Hours__c);
            Assert.areNotEqual(facilities[i].Thursday_Close_Hours__c, updatedFacilities[i].Thursday_Close_Hours__c);
            Assert.areNotEqual(facilities[i].Friday_Close_Hours__c, updatedFacilities[i].Friday_Close_Hours__c);
            Assert.areNotEqual(facilities[i].Saturday_Close_Hours__c, updatedFacilities[i].Saturday_Close_Hours__c);
            Assert.areNotEqual(facilities[i].Sunday_Close_Hours__c, updatedFacilities[i].Sunday_Close_Hours__c);
        }
        
    }

    @IsTest
    static void testScheduleMe() {
      Test.startTest();
      Id jobId = MedicalFacilityOpenHoursUpdate.scheduleMe();
      Test.stopTest();
  
      CronTrigger cronTrigger = [
        SELECT Id, CronExpression, CronJobDetail.Name
        FROM CronTrigger
        WHERE Id = :jobId
      ];
      Assert.areEqual(
        MedicalFacilityOpenHoursUpdate.JOB_NAME,
        cronTrigger.CronJobDetail.Name,
        'Invalid job name'
      );
      Assert.areEqual(
        MedicalFacilityOpenHoursUpdate.CRON_TIME,
        cronTrigger.CronExpression,
        'Inavlid cron expression'
      );
    }

    @IsTest
    static void testScheduleMeError() {
        String sub = 'Errors occurred during batch process.';
        MedicalFacilityOpenHoursUpdate medical = new MedicalFacilityOpenHoursUpdate();
        MedicalFacilityOpenHoursUpdate.shouldForceException = true;
        Test.startTest();
        medical.execute(null);
        Test.stopTest();
    
        List<EmailMessage> emails = [
        SELECT TextBody, Subject, ToAddress, Id
        FROM EmailMessage
        WHERE Subject =: sub
        ];

        Assert.areEqual(1, emails.size());
        Assert.areEqual(
        sub,
        emails[0].Subject
        );
    }
}