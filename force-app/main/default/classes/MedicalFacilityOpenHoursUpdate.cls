global with sharing class MedicalFacilityOpenHoursUpdate implements Schedulable {
    global void execute(SchedulableContext ctx) {
        MedicalFacilityOpenHoursUpdate.updateOpenHours();
    }

    public static void updateOpenHours() {
        List<Medical_Facility__c> facilities = [SELECT Id, Opening_Hours__c FROM Medical_Facility__c];

        for (Medical_Facility__c facility : facilities) {
            String newOpenHours = MedicalFacilityOpenHoursUpdate.generateOpenHours();
            facility.Opening_Hours__c = newOpenHours;
        }

        update facilities;
    }

    private static String generateOpenHours() {
        DateTime initialDayMonday = DateTime.newInstance(2023, 12, 4, 0, 0, 0);
        List<String> openHours = new List<String>();
        

        for (Integer i = 0; i < 7; ++i) {
            Integer openHour = (Integer)Math.floor(Math.random() * 24);
            Integer openMinute = (Integer)Math.floor(Math.random() * 60);

            Integer randomH = 8 + (Integer)Math.floor(Math.random() * (13 - 8));
            Integer closeHour = (openHour + randomH > 24 ? openHour + randomH - 24 : openHour + randomH);
            Integer closeMinute = (Integer)Math.floor(Math.random() * 60);

            String day = initialDayMonday.format('E');

            String openMinuteString = (openMinute < 10 ? '0' + String.valueOf(openMinute) : String.valueOf(openMinute));
            String closeMinuteString = (closeMinute < 10 ? '0' + String.valueOf(closeMinute) : String.valueOf(closeMinute));

            String line = day + ' ' + String.valueOf(openHour) + ':' + openMinuteString + '-' + String.valueOf(closeHour) + ':' + closeMinuteString;
            
            openHours.add(line);
            initialDayMonday = initialDayMonday.addDays(1);
        }

        return String.join(openHours, '\n');
    }
}