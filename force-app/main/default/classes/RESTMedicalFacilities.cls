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
        } catch (Exception e) {
            RestContext.response.responseBody = Blob.valueOf('{"error": "' + e.getMessage() + '"}');
            RestContext.response.statusCode = 403;
            return null;
        }
       
    }

    @HttpPost
    global static void postMedicalFacilities() {
        try {
            String jsonBody = RestContext.request.requestBody.toString();
            OpeningHours wrapper = (OpeningHours) JSON.deserialize(jsonBody, OpeningHours.class);

            DateTime fromDateTime = DateTime.valueOf(wrapper.fromDateTime);
            DateTime toDateTime = DateTime.valueOf(wrapper.toDateTime);

            Map<String, Integer> daysOfWeek = RESTMedicalFacilities.getDaysOfWeekBetweenDates(fromDateTime, toDateTime);
            
            List<Medical_Facility__c> facilities = [SELECT Id, Name, 
            Monday__c, Tuesday__c, Wednesday__c, Thursday__c, Friday__c, Saturday__c, Sunday__c
            FROM Medical_Facility__c];

            List<String> facilitiesNamesOpenedInCertainTime = new List<String>();

            

            for (Medical_Facility__c facility : facilities) {
                
                Map<String, String> facilityOpenHoursMap = RESTMedicalFacilities.createOpenHoursMap(
                    facility.Monday__c, facility.Tuesday__c, facility.Wednesday__c, facility.Thursday__c, 
                    facility.Friday__c, facility.Saturday__c, facility.Sunday__c
                );

                Map<String, Integer> weekDaysAndNumber = RESTMedicalFacilities.getDaysOfWeekBetweenDates(fromDateTime, toDateTime);
                Date dateForDateTime = Date.newInstance(fromDateTime.year(), fromDateTime.month(), fromDateTime.day());

                for (String singleDay : weekDaysAndNumber.keySet()) {

                    List<Integer> hoursForSingleDay = RESTMedicalFacilities.getOpenAndCloseHoursAndMinutes(
                        facilityOpenHoursMap.get(singleDay)
                    );

                    DateTime singleDayOpenHour = DateTime.newInstance(
                        dateForDateTime.year(), dateForDateTime.month(), weekDaysAndNumber.get(singleDay), hoursForSingleDay[0], hoursForSingleDay[1], 0
                    );

                    DateTime singleDayClosingHour = DateTime.newInstance(
                        dateForDateTime.year(), dateForDateTime.month(), weekDaysAndNumber.get(singleDay), hoursForSingleDay[2], hoursForSingleDay[3], 0
                    );

                    if (
                        (toDateTime >= singleDayOpenHour && toDateTime <= singleDayClosingHour) ||
                        (fromDateTime >= singleDayOpenHour && fromDateTime <= singleDayClosingHour)
                        ) {
                        facilitiesNamesOpenedInCertainTime.add(facility.Name);
                    }

                    dateForDateTime.addDays(1);
                }
            }

            RestResponse res = RestContext.response;
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(facilitiesNamesOpenedInCertainTime));
        } catch (JSONException e) {
            RestContext.response.responseBody = Blob.valueOf('{"error": "' + e.getMessage() + '"}');
            RestContext.response.statusCode = 400;
        } catch (Exception e) {
            RestContext.response.responseBody = Blob.valueOf('{"error": "' + e.getMessage() + '"}');
            RestContext.response.statusCode = 403;
        }
        
    }


    public static List<Integer> getOpenAndCloseHoursAndMinutes(String openHoursAndCloseHours) {
        List<Integer> output = new List<Integer>();

        for (String part : openHoursAndCloseHours.split(':|-')) {
            output.add(Integer.valueOf(part));
        }     

        return output;
    }

    public static Map<String, Integer> getDaysOfWeekBetweenDates(DateTime fromDateTime, DateTime toDateTime) {
        Map<String, Integer> dayMap = new Map<String, Integer>();
    
        while (fromDateTime <= toDateTime || dayMap.size() != 7) {
            String dayOfWeek = fromDateTime.format('EEEE');
            Integer dayOfMonth = fromDateTime.day();
    
            dayMap.put(dayOfWeek, dayOfMonth);
    
            fromDateTime = fromDateTime.addDays(1);
        }
    
        return dayMap;
    }    
}