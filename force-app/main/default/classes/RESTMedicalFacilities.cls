@RestResource(UrlMapping='/Medical_Facility__c/*')
global with sharing class RESTMedicalFacilities {
    
    @HttpGet
    global static List<Medical_Facility__c> getMedicalFacilities() {
        RestRequest request = RestContext.request;
        Map<String, String> params = request.params;

        List<Medical_Facility__c> facilities = [SELECT Id, Name, Opening_Hours__c, Adress__c, Phone_Number__c	
                                              FROM Medical_Facility__c];

        List<MedicalFacilityWrapper> wrapper = new List<MedicalFacilityWrapper>();
        
        for (Medical_Facility__c fac : facilities) {
            wrapper.add(
                new MedicalFacilityWrapper(fac.Name, fac.Opening_Hours__c, fac.Phone_Number__c, fac.Adress__c, fac.Id)
            );     
        }

        String responseBody = JSON.serialize(wrapper);

        // String 
        
        RestContext.response.statusCode = 200;
        // RestContext.response.responseBody = Blob.valueOf(responseBody);
        RestContext.response.responseBody = Blob.valueOf(responseBody);

        return facilities;
    }
    
    @HttpPut
    global static String putMedicalFacilities() {
        String jsonBody = RestContext.request.requestBody.toString();

        MedicalFacilityWrapper wrapper = (MedicalFacilityWrapper) JSON.deserialize(jsonBody, MedicalFacilityWrapper.class);
        
        Medical_Facility__c facility = [SELECT Name, Opening_Hours__c, Adress__c, Phone_Number__c	
        FROM Medical_Facility__c WHERE Id = :wrapper.id];

        facility.Name = wrapper.name;
        facility.Opening_Hours__c = wrapper.openingHours;

        update facility;
        return 'Object ' + wrapper.id + ' has been updated!';
    }

    @HttpPost
    global static void postMedicalFacilities() {
        String jsonBody = RestContext.request.requestBody.toString();
        OpeningHours wrapper = (OpeningHours) JSON.deserialize(jsonBody, OpeningHours.class);

        Map<Id, String> openFacilities = new Map<Id, String>();

        DateTime fromDateTime = DateTime.valueOf(wrapper.fromDateTime);
        DateTime toDateTime = DateTime.valueOf(wrapper.toDateTime);

        Map<Integer, Map<String, Integer>> daysOfWeek = RESTMedicalFacilities.getDaysOfWeekBetweenDates(fromDateTime, toDateTime);
        
        List<Medical_Facility__c> facilities = [SELECT Id, Name, Opening_Hours__c FROM Medical_Facility__c];

        Map<Id, String> facilitiesNamesOpenedInCertainTime = new Map<Id, String>();

        for (Medical_Facility__c facility : facilities) {
            
            Map<String, String[]> hours = RESTMedicalFacilities.openHours(facility.Opening_Hours__c);


            for (Integer month : daysOfWeek.keySet()) {
                Map<String, Integer> availableDays = daysOfWeek.get(month);

                for (String singleDay : availableDays.keySet()) {

                    String[] hoursForSingleDay = hours.get(singleDay);

                    Integer openH = Integer.valueOf(hoursForSingleDay[0].split(':')[0]);
                    Integer openM = Integer.valueOf(hoursForSingleDay[0].split(':')[1]);
                    Integer closeH = Integer.valueOf(hoursForSingleDay[1].split(':')[0]);

                    String closeMString = hoursForSingleDay[1].split(':')[1];
                    Integer closeM = Integer.valueOf(closeMString.substring(0,2));
                    
                    DateTime singleDayOpenHour = DateTime.newInstance(fromDateTime.year(), fromDateTime.month(), availableDays.get(singleDay), openH, openM, 0);
                    DateTime singleDayClosingHour = DateTime.newInstance(fromDateTime.year(), fromDateTime.month(), availableDays.get(singleDay), closeH, closeM, 0);


                    System.debug('singleDayOpenHour: ' + singleDayOpenHour);
                    System.debug('singleDayClosingHour' + singleDayClosingHour);

                    System.debug('fromDateTime: ' + fromDateTime);
                    System.debug('toDateTime' + toDateTime);
                    
                    if (
                        (singleDayOpenHour <= fromDateTime && singleDayClosingHour >= toDateTime) ||
                        (toDateTime >= singleDayOpenHour && toDateTime <= singleDayClosingHour) ||
                        (fromDateTime >= singleDayOpenHour && fromDateTime <= singleDayClosingHour)
                        ) {
                        facilitiesNamesOpenedInCertainTime.put(facility.Id, facility.Name);
                    }
                }
            }
            
        }

        System.debug(facilitiesNamesOpenedInCertainTime);
        RestResponse res = RestContext.response;
        res.statusCode = 200;
        res.responseBody = Blob.valueOf(JSON.serialize(facilitiesNamesOpenedInCertainTime));
    }

    private static Map<String, String[]> openHours(String hours) {
        Map<String, String[]> openHoursMap = new Map<String, String[]>();
        List<String> splittedDays = hours.split('\n');

        for (String day : splittedDays) {
            List<String> dayName = day.split(' ');
            openHoursMap.put(dayName[0], dayName[1].split('-'));
        }

        return openHoursMap;
    }

    public static Map<Integer, Map<String, Integer>> getDaysOfWeekBetweenDates(DateTime fromDateTime, DateTime toDateTime) {
        Map<Integer, Map<String, Integer>> monthDayMap = new Map<Integer, Map<String, Integer>>();
    
        while (fromDateTime <= toDateTime) {
            Integer month = fromDateTime.month();
            String dayOfWeek = fromDateTime.format('E');
            Integer dayOfMonth = fromDateTime.day();
    
            if (!monthDayMap.containsKey(month)) {
                monthDayMap.put(month, new Map<String, Integer>());
            }
    
            monthDayMap.get(month).put(dayOfWeek, dayOfMonth);
    
            fromDateTime = fromDateTime.addDays(1);
        }
    
        return monthDayMap;
    }
    

    public class MedicalFacilityWrapper {
        public String id;
        public String name;
        public String openingHours;
        public String phoneNumber;
        public String address;
        
        public MedicalFacilityWrapper(String name, String openingHours, String phoneNumber, String address, String id) {
            this.id = id;
            this.name = name;
            this.openingHours = openingHours;
            this.phoneNumber = phoneNumber;
            this.address = address;
        }
    }

    public class OpeningHours {
        public String fromDateTime;
        public String toDateTime;
    }

    
    
}