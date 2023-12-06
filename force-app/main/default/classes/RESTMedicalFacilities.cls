@RestResource(UrlMapping='/Medical_Facility__c/*')
global with sharing class RESTMedicalFacilities {
    
    @HttpGet
    global static void getMedicalFacilities() {
        RestRequest request = RestContext.request;

        List<Medical_Facility__c> facilities = [
            SELECT Id, Name, Phone_Number__c,
            Monday__c, Tuesday__c, Wednesday__c, Thursday__c, Friday__c, Saturday__c, Sunday__c,
            City__c, Street__c, Building_number__c, zip_code__c FROM Medical_Facility__c
        ];

        List<MedicalFacilityWrapper> wrapper = new List<MedicalFacilityWrapper>();
        
        for (Medical_Facility__c fac : facilities) {
            Map<String, String> openHours = RESTMedicalFacilities.createOpenHoursMap(
                fac.Monday__c, fac.Tuesday__c, fac.Wednesday__c, fac.Thursday__c, fac.Friday__c, fac.Saturday__c, fac.Sunday__c
            );

            List<String> address = RESTMedicalFacilities.createAddress(
                fac.City__c, fac.Street__c, fac.Building_number__c, fac.zip_code__c
            );

            wrapper.add(
                new MedicalFacilityWrapper(fac.Name, openHours, fac.Phone_Number__c, address, fac.Id)
            );     
        }

        String responseBody = JSON.serialize(wrapper);

        RestContext.response.statusCode = 200;
        RestContext.response.responseBody = Blob.valueOf(responseBody);
    }

    @TestVisible
    public static Map<String, String> createOpenHoursMap(String Monday, String Tuesday, String Wednesday, String Thursday, String Friday, String Saturday, String Sunday) {
        Map<String, String> openHours = new Map<String, String>();
        openHours.put('Sunday', Sunday);
        openHours.put('Saturday', Saturday);
        openHours.put('Friday', Friday);
        openHours.put('Thursday', Thursday);
        openHours.put('Wednesday', Wednesday);
        openHours.put('Tuesday', Tuesday);
        openHours.put('Monday', Monday);

        return openHours;
    }

    @TestVisible
    public static List<String> createAddress(String city, String street, String BuildingNumber, String zipCode) {
        List<String> address = new List<String>();
        address.add(city);
        address.add(street);
        address.add(BuildingNumber);
        address.add(zipCode);

        return address;
    }

    @TestVisible
    public class MedicalFacilityWrapper {
        public String id;
        public String name;
        public Map<String, String> openingHours;
        public String phoneNumber;
        public List<String> address;
        
        @TestVisible
        public MedicalFacilityWrapper(String name, Map<String, String> hours, String phoneNumber, List<String> address, String id) {
            this.id = id;
            this.name = name;
            this.phoneNumber = phoneNumber;
            this.address = address;
            this.openingHours = hours;
        }
    }

    public class OpeningHours {
        public String fromDateTime;
        public String toDateTime;
    }
    
    @HttpPut
    global static List<Id> putMedicalFacilities() {
        String jsonBody = RestContext.request.requestBody.toString();

        try {
            List<MedicalFacilityWrapper> wrapperList = (List<MedicalFacilityWrapper>) JSON.deserialize(jsonBody, List<MedicalFacilityWrapper>.class);
            List<Id> wrapperIds = new List<Id>();
            for (MedicalFacilityWrapper wrapper : wrapperList) {
                wrapperIds.add(wrapper.id);
            }
            
            List<Medical_Facility__c> facilities = [
            SELECT Id, Name, Monday__c, Tuesday__c, Wednesday__c, Thursday__c, Friday__c, Saturday__c, Sunday__c
            FROM Medical_Facility__c WHERE Id in :wrapperIds];
    
            Integer i = 0;
    
            for (Medical_Facility__c facility : facilities) {
                MedicalFacilityWrapper wrapper = wrapperList[i];
    
                facility.Name = wrapper.name;
                facility.Monday__c = wrapper.openingHours.get('Monday');
                facility.Tuesday__c = wrapper.openingHours.get('Tuesday');
                facility.Wednesday__c = wrapper.openingHours.get('Wednesday');
                facility.Thursday__c = wrapper.openingHours.get('Thursday');
                facility.Friday__c = wrapper.openingHours.get('Friday');
                facility.Saturday__c = wrapper.openingHours.get('Saturday');
                facility.Sunday__c = wrapper.openingHours.get('Sunday');
                ++i;
            }
            
            update facilities;

            return wrapperIds;
        } catch (JSONException e) {
            RestContext.response.responseBody = Blob.valueOf('{"error": "' + e.getMessage() + '"}');
            RestContext.response.statusCode = 400;
            return null;
        }
       
    }

    // @HttpPost
    // global static void postMedicalFacilities() {
    //     String jsonBody = RestContext.request.requestBody.toString();
    //     OpeningHours wrapper = (OpeningHours) JSON.deserialize(jsonBody, OpeningHours.class);

    //     Map<Id, String> openFacilities = new Map<Id, String>();

    //     DateTime fromDateTime = DateTime.valueOf(wrapper.fromDateTime);
    //     DateTime toDateTime = DateTime.valueOf(wrapper.toDateTime);

    //     Map<Integer, Map<String, Integer>> daysOfWeek = RESTMedicalFacilities.getDaysOfWeekBetweenDates(fromDateTime, toDateTime);
        
    //     List<Medical_Facility__c> facilities = [SELECT Id, Name, Opening_Hours__c FROM Medical_Facility__c];

    //     Map<Id, String> facilitiesNamesOpenedInCertainTime = new Map<Id, String>();

    //     for (Medical_Facility__c facility : facilities) {
            
    //         Map<String, String[]> hours = RESTMedicalFacilities.openHours(facility.Opening_Hours__c);


    //         for (Integer month : daysOfWeek.keySet()) {
    //             Map<String, Integer> availableDays = daysOfWeek.get(month);

    //             for (String singleDay : availableDays.keySet()) {

    //                 String[] hoursForSingleDay = hours.get(singleDay);

    //                 Integer openH = Integer.valueOf(hoursForSingleDay[0].split(':')[0]);
    //                 Integer openM = Integer.valueOf(hoursForSingleDay[0].split(':')[1]);
    //                 Integer closeH = Integer.valueOf(hoursForSingleDay[1].split(':')[0]);

    //                 String closeMString = hoursForSingleDay[1].split(':')[1];
    //                 Integer closeM = Integer.valueOf(closeMString.substring(0,2));
                    
    //                 DateTime singleDayOpenHour = DateTime.newInstance(fromDateTime.year(), fromDateTime.month(), availableDays.get(singleDay), openH, openM, 0);
    //                 DateTime singleDayClosingHour = DateTime.newInstance(fromDateTime.year(), fromDateTime.month(), availableDays.get(singleDay), closeH, closeM, 0);


    //                 System.debug('singleDayOpenHour: ' + singleDayOpenHour);
    //                 System.debug('singleDayClosingHour' + singleDayClosingHour);

    //                 System.debug('fromDateTime: ' + fromDateTime);
    //                 System.debug('toDateTime' + toDateTime);
                    
    //                 if (
    //                     (singleDayOpenHour <= fromDateTime && singleDayClosingHour >= toDateTime) ||
    //                     (toDateTime >= singleDayOpenHour && toDateTime <= singleDayClosingHour) ||
    //                     (fromDateTime >= singleDayOpenHour && fromDateTime <= singleDayClosingHour)
    //                     ) {
    //                     facilitiesNamesOpenedInCertainTime.put(facility.Id, facility.Name);
    //                 }
    //             }
    //         }
            
    //     }

    //     System.debug(facilitiesNamesOpenedInCertainTime);
    //     RestResponse res = RestContext.response;
    //     res.statusCode = 200;
    //     res.responseBody = Blob.valueOf(JSON.serialize(facilitiesNamesOpenedInCertainTime));
    // }

    // private static Map<String, String[]> openHours(String hours) {
    //     Map<String, String[]> openHoursMap = new Map<String, String[]>();
    //     List<String> splittedDays = hours.split('\n');

    //     for (String day : splittedDays) {
    //         List<String> dayName = day.split(' ');
    //         openHoursMap.put(dayName[0], dayName[1].split('-'));
    //     }

    //     return openHoursMap;
    // }

    // public static Map<Integer, Map<String, Integer>> getDaysOfWeekBetweenDates(DateTime fromDateTime, DateTime toDateTime) {
    //     Map<Integer, Map<String, Integer>> monthDayMap = new Map<Integer, Map<String, Integer>>();
    
    //     while (fromDateTime <= toDateTime) {
    //         Integer month = fromDateTime.month();
    //         String dayOfWeek = fromDateTime.format('E');
    //         Integer dayOfMonth = fromDateTime.day();
    
    //         if (!monthDayMap.containsKey(month)) {
    //             monthDayMap.put(month, new Map<String, Integer>());
    //         }
    
    //         monthDayMap.get(month).put(dayOfWeek, dayOfMonth);
    
    //         fromDateTime = fromDateTime.addDays(1);
    //     }
    
    //     return monthDayMap;
    // }
    
   

    
    
}