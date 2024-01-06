global with sharing class MedicalFacilityOpenHoursUpdate implements Schedulable, Database.Batchable<SObject>, Database.Stateful {
    
    public static final String JOB_NAME = 'Open Hours Update Job';
    private final Map<String, List<String>> errorToIDs = new Map<String, List<String>>();
    //Codziennie o 5 rano
    public static final String CRON_TIME = '0 0 5 * * ?';
    @TestVisible
    public static Boolean shouldForceException = false;


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
            Monday_Open_Hours__c, Tuesday_Open_Hours__c, Wednesday_Open_Hours__c, Thursday_Open_Hours__c, Friday_Open_Hours__c, Saturday_Open_Hours__c, Sunday_Open_Hours__c,
            Monday_Close_Hours__c, Tuesday_Close_Hours__c, Wednesday_Close_Hours__c, Thursday_Close_Hours__c, Friday_Close_Hours__c, Saturday_Close_Hours__c, Sunday_Close_Hours__c
            FROM Medical_Facility__c
          ]
        );
    }

    public void execute(Database.BatchableContext bc, List<Medical_Facility__c> facilities) {  
      for (Medical_Facility__c facility : facilities) {
        facility.Monday_Open_Hours__c = MedicalFacilityOpenHoursUpdate.generateOpenHours(true);
        facility.Monday_Close_Hours__c = MedicalFacilityOpenHoursUpdate.generateOpenHours(false);

        facility.Tuesday_Open_Hours__c = MedicalFacilityOpenHoursUpdate.generateOpenHours(true);
        facility.Tuesday_Close_Hours__c = MedicalFacilityOpenHoursUpdate.generateOpenHours(false);

        facility.Wednesday_Open_Hours__c = MedicalFacilityOpenHoursUpdate.generateOpenHours(true);
        facility.Wednesday_Close_Hours__c = MedicalFacilityOpenHoursUpdate.generateOpenHours(false);

        facility.Thursday_Open_Hours__c = MedicalFacilityOpenHoursUpdate.generateOpenHours(true);
        facility.Thursday_Close_Hours__c = MedicalFacilityOpenHoursUpdate.generateOpenHours(false);

        facility.Friday_Open_Hours__c = MedicalFacilityOpenHoursUpdate.generateOpenHours(true);
        facility.Friday_Close_Hours__c = MedicalFacilityOpenHoursUpdate.generateOpenHours(false);

        facility.Saturday_Open_Hours__c = MedicalFacilityOpenHoursUpdate.generateOpenHours(true);
        facility.Saturday_Close_Hours__c = MedicalFacilityOpenHoursUpdate.generateOpenHours(false);

        facility.Sunday_Open_Hours__c = MedicalFacilityOpenHoursUpdate.generateOpenHours(true);
        facility.Sunday_Close_Hours__c = MedicalFacilityOpenHoursUpdate.generateOpenHours(false);
      }

      if ((Test.isRunningTest() && shouldForceException)) {
        facilities[0].Sunday_Open_Hours__c = Time.newInstance(21,0,0,0);
        facilities[0].Sunday_Close_Hours__c = Time.newInstance(8,0,0,0);
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
        EmailManager.sendErrorEmail('Errors occurred during batch process.', errorToIDs);
      }
    }

    private static Time generateOpenHours(Boolean openHours) {
      return openHours == true ? 
      Time.newInstance(Math.round(Math.random() * 4) + 8, (Integer)Math.floor(Math.random() * 60), 0, 0) :
      Time.newInstance(Math.round(Math.random() * 4) + 18, (Integer)Math.floor(Math.random() * 60), 0, 0);
    }
}