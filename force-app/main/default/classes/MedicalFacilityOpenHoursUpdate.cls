global with sharing class MedicalFacilityOpenHoursUpdate implements Schedulable {
    global void execute(SchedulableContext ctx) {
        MedicalFacilityOpenHoursUpdate.updateOpenHours();
    }

    public static void updateOpenHours() {
        List<Medical_Facility__c> facilities = [SELECT Id, 
        Monday__c, Tuesday__c, Wednesday__c, Thursday__c, Friday__c, Saturday__c, Sunday__c FROM Medical_Facility__c];

        for (Medical_Facility__c facility : facilities) {
            List<String> newOpenHours = MedicalFacilityOpenHoursUpdate.generateOpenHours();
            facility.Monday__c = newOpenHours[0];
            facility.Tuesday__c = newOpenHours[1];
            facility.Wednesday__c = newOpenHours[2];
            facility.Thursday__c = newOpenHours[3];
            facility.Friday__c = newOpenHours[4];
            facility.Saturday__c = newOpenHours[5];
            facility.Sunday__c = newOpenHours[6];
        }

        if (!facilities.isEmpty()) {
            update facilities;
        }
    }

    private static List<String> generateOpenHours() {
        DateTime initialDayMonday = DateTime.newInstance(2023, 12, 4, 0, 0, 0);
        List<String> openHours = new List<String>();
        

        for (Integer i = 0; i < 7; ++i) {
            Integer openHour = (Integer)Math.floor(Math.random() * 24);
            Integer openMinute = (Integer)Math.floor(Math.random() * 60);

            Integer randomH = 8 + (Integer)Math.floor(Math.random() * (13 - 8));
            Integer closeHour = (openHour + randomH > 24 ? openHour + randomH - 24 : openHour + randomH);
            Integer closeMinute = (Integer)Math.floor(Math.random() * 60);

            String openMinuteString = (openMinute < 10 ? '0' + String.valueOf(openMinute) : String.valueOf(openMinute));
            String closeMinuteString = (closeMinute < 10 ? '0' + String.valueOf(closeMinute) : String.valueOf(closeMinute));

            String line = String.valueOf(openHour) + ':' + openMinuteString + '-' + String.valueOf(closeHour) + ':' + closeMinuteString;
            
            openHours.add(line);
            initialDayMonday = initialDayMonday.addDays(1);
        }

        return openHours;
    }
}