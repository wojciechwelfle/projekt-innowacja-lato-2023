global with sharing class MedicalFacilityOpenHoursUpdate implements Schedulable, Database.Batchable<SObject>, Database.Stateful {
    
    public static final String JOB_NAME = 'Open Hours Update Job';
    private final Map<String, List<String>> errorToIDs = new Map<String, List<String>>();
    //Codziennie o 5 rano
    public static final String CRON_TIME = '0 0 5 * * ?';
    @TestVisible
    private static Boolean shouldForceException = false;


    public static Id scheduleMe() {
        MedicalFacilityOpenHoursUpdate schedule = new MedicalFacilityOpenHoursUpdate();
        return System.schedule(
          JOB_NAME,
          CRON_TIME,
          schedule
        );
      }
    
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new MedicalFacilityOpenHoursUpdate(), 100);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
          [
            SELECT Id, 
            Monday__c, Tuesday__c, Wednesday__c, Thursday__c, Friday__c, Saturday__c, Sunday__c
            FROM Medical_Facility__c
          ]
        );
    }

    public void execute(Database.BatchableContext bc, List<Medical_Facility__c> facilities) {  
      for (Medical_Facility__c facility : facilities) {
          facility.Monday__c = MedicalFacilityOpenHoursUpdate.generateOpenHours();
          facility.Tuesday__c = MedicalFacilityOpenHoursUpdate.generateOpenHours();
          facility.Wednesday__c = MedicalFacilityOpenHoursUpdate.generateOpenHours();
          facility.Thursday__c = MedicalFacilityOpenHoursUpdate.generateOpenHours();
          facility.Friday__c = MedicalFacilityOpenHoursUpdate.generateOpenHours();
          facility.Saturday__c = MedicalFacilityOpenHoursUpdate.generateOpenHours();
          facility.Sunday__c = MedicalFacilityOpenHoursUpdate.generateOpenHours();
      }

      if ((Test.isRunningTest() && shouldForceException)) {
        facilities[0].Monday__c = ' 12:00-12:30 2';
        // facilities[0].Monday__c = 2;
    } 
      
      Database.SaveResult[] fac = Database.update(facilities, false);
      for (Integer i = 0; i < fac.size(); i++) {
        if (!fac[i].isSuccess()) {
          String statusCode = fac[i].getErrors().get(0).getStatusCode().name();
          if (!errorToIDs.containsKey(statusCode)) {
            errorToIDs.put(statusCode, new List<String>());
          }
          errorToIDs.get(statusCode).add(facilities[i].Id);
        }
      }
    }

    public void finish(Database.BatchableContext bc) {
      if (!errorToIDs.isEmpty()) {
          sendErrorEmail();
      }
    }

    private void sendErrorEmail() {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject('Errors occurred during batch process.');
        mail.setTargetObjectId(UserInfo.getUserId());
        mail.setSaveAsActivity(false);
        List<String> body = new List<String>();
        for (String statusCode : errorToIDs.keySet()) {
            body.add('Status Code: ' + statusCode + ', Facility IDs: ' + 'error: ' + errorToIDs.get(statusCode));
        }
        mail.setPlainTextBody(body.toString());
        Messaging.sendEmail(new Messaging.Email[] { mail });
    }

    private static String generateOpenHours() {
        Integer openHour = (Integer)Math.floor(Math.random() * 24);
        Integer openMinute = (Integer)Math.floor(Math.random() * 60);

        Integer randomH = 8 + (Integer)Math.floor(Math.random() * (13 - 8));
        Integer closeHour = (openHour + randomH > 24 ? openHour + randomH - 24 : openHour + randomH);
        Integer closeMinute = (Integer)Math.floor(Math.random() * 60);

        String openMinuteString = (openMinute < 10 ? '0' + String.valueOf(openMinute) : String.valueOf(openMinute));
        String closeMinuteString = (closeMinute < 10 ? '0' + String.valueOf(closeMinute) : String.valueOf(closeMinute));

        return String.valueOf(openHour) + ':' + openMinuteString + '-' + String.valueOf(closeHour) + ':' + closeMinuteString;
    }
}