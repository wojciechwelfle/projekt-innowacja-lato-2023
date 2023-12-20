@RestResource(UrlMapping='/Medical_Facility__c/*')
global with sharing class RESTMedicalFacilities {
    
    @HttpGet
    global static void getMedicalFacilities() {
        RestRequest request = RestContext.request;

        List<Medical_Facility__c> facilities = [
            SELECT Id, Name, Phone_Number__c,
            Monday_Open_Hours__c, Tuesday_Open_Hours__c, Wednesday_Open_Hours__c, Thursday_Open_Hours__c, Friday_Open_Hours__c, Saturday_Open_Hours__c, Sunday_Open_Hours__c,
            Monday_Close_Hours__c, Tuesday_Close_Hours__c, Wednesday_Close_Hours__c, Thursday_Close_Hours__c, Friday_Close_Hours__c, Saturday_Close_Hours__c, Sunday_Close_Hours__c,
            City__c, Street__c, Building_number__c, zip_code__c FROM Medical_Facility__c
        ];

        List<MedicalFacilityWrapper> wrapper = new List<MedicalFacilityWrapper>();
        
        for (Medical_Facility__c fac : facilities) {
            Map<String, String> openHours = RESTMedicalFacilities.createOpenHoursMap(fac);

            List<String> address = RESTMedicalFacilities.createAddress(
                fac.City__c, fac.Street__c, fac.Building_number__c, fac.zip_code__c
            );

            wrapper.add(
                new MedicalFacilityWrapper(fac.Name, openHours, fac.Phone_Number__c, address, fac.Id)
            );
        }

        RestContext.response.statusCode = 200;
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(wrapper));
    }
    
    @HttpPut
    global static List<Id> putMedicalFacilities() {
        String jsonBody = RestContext.request.requestBody.toString();

        try {
            List<MedicalFacilityWrapper> wrapperList = (List<MedicalFacilityWrapper>) JSON.deserializeStrict(jsonBody, List<MedicalFacilityWrapper>.class);
            List<Id> wrapperIds = new List<Id>();
            for (MedicalFacilityWrapper wrapper : wrapperList) {
                wrapperIds.add(wrapper.id);
            }
            
            List<Medical_Facility__c> facilities = [
            SELECT Id, Name, Monday_Open_Hours__c, Tuesday_Open_Hours__c, Wednesday_Open_Hours__c, Thursday_Open_Hours__c, Friday_Open_Hours__c, Saturday_Open_Hours__c, Sunday_Open_Hours__c,
            Monday_Close_Hours__c, Tuesday_Close_Hours__c, Wednesday_Close_Hours__c, Thursday_Close_Hours__c, Friday_Close_Hours__c, Saturday_Close_Hours__c, Sunday_Close_Hours__c
            FROM Medical_Facility__c WHERE Id in :wrapperIds];
    

            Map<Id, Medical_Facility__c> facilitiesMap = new Map<Id, Medical_Facility__c> ();
            for (Medical_Facility__c facility : facilities) {
                facilitiesMap.put(facility.Id, facility);
            }
    
            for (MedicalFacilityWrapper wrapper : wrapperList) {
                Medical_Facility__c facility = facilitiesMap.get(wrapper.Id);
    
                facility.Name = wrapper.name;

                facility.Monday_Open_Hours__c = RESTMedicalFacilities.createTimeFromString(wrapper.openingHours.get('Monday'), true);
                facility.Monday_Close_Hours__c = RESTMedicalFacilities.createTimeFromString(wrapper.openingHours.get('Monday'), false);

                facility.Tuesday_Open_Hours__c = RESTMedicalFacilities.createTimeFromString(wrapper.openingHours.get('Tuesday'), true);
                facility.Tuesday_Close_Hours__c = RESTMedicalFacilities.createTimeFromString(wrapper.openingHours.get('Tuesday'), false);

                facility.Wednesday_Open_Hours__c = RESTMedicalFacilities.createTimeFromString(wrapper.openingHours.get('Wednesday'), true);
                facility.Wednesday_Close_Hours__c = RESTMedicalFacilities.createTimeFromString(wrapper.openingHours.get('Wednesday'), false);

                facility.Thursday_Open_Hours__c = RESTMedicalFacilities.createTimeFromString(wrapper.openingHours.get('Thursday'), true);
                facility.Thursday_Close_Hours__c = RESTMedicalFacilities.createTimeFromString(wrapper.openingHours.get('Thursday'), false);

                facility.Friday_Open_Hours__c = RESTMedicalFacilities.createTimeFromString(wrapper.openingHours.get('Friday'), true);
                facility.Friday_Close_Hours__c = RESTMedicalFacilities.createTimeFromString(wrapper.openingHours.get('Friday'), false);

                facility.Saturday_Open_Hours__c = RESTMedicalFacilities.createTimeFromString(wrapper.openingHours.get('Saturday'), true);
                facility.Saturday_Close_Hours__c = RESTMedicalFacilities.createTimeFromString(wrapper.openingHours.get('Saturday'), false);

                facility.Sunday_Open_Hours__c = RESTMedicalFacilities.createTimeFromString(wrapper.openingHours.get('Sunday'), true);
                facility.Sunday_Close_Hours__c = RESTMedicalFacilities.createTimeFromString(wrapper.openingHours.get('Sunday'), false);
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

    private static Time createTimeFromString(String openAndCloseHours, Boolean openHours) {
        String[] hoursArray = openAndCloseHours.split('-');
        Time result;
        
        if (openHours) {
            result = RESTMedicalFacilities.createTime(hoursArray[0]);
        } else {
            result = RESTMedicalFacilities.createTime(hoursArray[1]);
        }
        
        return result;
    }

    public static Time createTime(String hourString) {
        Integer hour = Integer.valueOf(hourString.split(':')[0]);
        Integer minute = Integer.valueOf(hourString.split(':')[1]);
    
        return Time.newInstance(hour, minute, 0, 0);
    }


    @HttpPost
    global static void postMedicalFacilities() {
        try {
            String jsonBody = RestContext.request.requestBody.toString();
            OpeningHours wrapper = (OpeningHours) JSON.deserializeStrict(jsonBody, OpeningHours.class);

            DateTime fromDateTime = DateTime.valueOf(wrapper.fromDateTime);
            DateTime toDateTime = DateTime.valueOf(wrapper.toDateTime);
            List<String> daysofWeek = RESTMedicalFacilities.getDaysOfWeekBetweenDates(fromDateTime, toDateTime);
            String query = 'SELECT Id, Name FROM Medical_Facility__c';

            String criteria = RESTMedicalFacilities.createCriterias(daysOfWeek, fromDateTime, toDateTime);
            List<Medical_Facility__c> result;
            if(criteria != '') {
                query += criteria;
                result = Database.query(query);
            }

            List<String> resultName = new List<String>();
            for (Medical_Facility__c fac : result) {
                resultName.add(fac.Name);
            }

            RestResponse res = RestContext.response;
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(resultName));
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

    public static List<String> getDaysOfWeekBetweenDates(DateTime fromDateTime, DateTime toDateTime) {
        List<String> dayList = new List<String>();
    
        while (true) {
            if(dayList.size() == 7) {
                break;
            }
            String dayOfWeek = fromDateTime.format('EEEE');
            Integer dayOfMonth = fromDateTime.day();
            System.debug(dayOfWeek);
    
            dayList.add(dayOfWeek);
            
            if(fromDateTime.format('EEEE') == toDateTime.format('EEEE')) {
                break;
            }
            fromDateTime = fromDateTime.addDays(1);
        }
    
        return dayList;
    }

    public static String createCriterias(List<String> days, DateTime fromOpenHours, DateTime toOpenHours) {
        String criteria = '';

        Integer numberOfDays = days.size();
        for (Integer i = 0 ; i < numberOfDays; ++i) {
            Time openHours;
            Time closeHours;
            
           
            if(i == 0) {
                openHours = Time.newInstance(fromOpenHours.hour(), fromOpenHours.minute(), 0 ,0);
                if(numberOfDays == 1) {
                    closeHours = Time.newInstance(toOpenHours.hour(), toOpenHours.minute(), 0 ,0);
                } else {
                    closeHours = Time.newInstance(23, 59, 0 ,0);
                }
                
                criteria = ' WHERE (' + days[i] + '_Open_Hours__c < ' + String.valueOf(closeHours) + ' AND ' + days[i] + '_Close_Hours__c > ' + String.valueOf(openHours) + ')';
            } else if(numberOfDays - 1 == i) {
                openHours = Time.newInstance(0, 0, 0 ,0);
                closeHours = Time.newInstance(toOpenHours.hour(), toOpenHours.minute(), 0 ,0);

                criteria += ' OR (' + days[i] + '_Open_Hours__c < ' + String.valueOf(closeHours) + ' AND ' + days[i] + '_Close_Hours__c > ' + String.valueOf(openHours) + ')';
            } else {
                openHours = Time.newInstance(0, 0, 0 ,0);
                closeHours = Time.newInstance(23, 59, 0 ,0);

                criteria += ' OR (' + days[i] + '_Open_Hours__c < ' + String.valueOf(closeHours) + ' AND ' + days[i] + '_Close_Hours__c > ' + String.valueOf(openHours) + ')';
            }
                        
        }

        criteria = String.escapeSingleQuotes(criteria);
        return criteria;
    }
    
    @TestVisible
    public static Map<String, String> createOpenHoursMap(Medical_Facility__c facility) {
        Map<String, String> openHours = new Map<String, String>();
        openHours.put('Sunday', String.valueOf(facility.Sunday_Open_Hours__c).left(5) + '-' + String.valueOf(facility.Sunday_Close_Hours__c).left(5));
        openHours.put('Saturday', String.valueOf(facility.Saturday_Open_Hours__c).left(5) + '-' + String.valueOf(facility.Saturday_Close_Hours__c).left(5));
        openHours.put('Friday', String.valueOf(facility.Friday_Open_Hours__c).left(5) + '-' + String.valueOf(facility.Friday_Close_Hours__c).left(5));
        openHours.put('Thursday', String.valueOf(facility.Thursday_Open_Hours__c).left(5) + '-' + String.valueOf(facility.Thursday_Close_Hours__c).left(5));
        openHours.put('Wednesday', String.valueOf(facility.Wednesday_Open_Hours__c).left(5) + '-' + String.valueOf(facility.Wednesday_Close_Hours__c).left(5));
        openHours.put('Tuesday', String.valueOf(facility.Tuesday_Open_Hours__c).left(5) + '-' + String.valueOf(facility.Tuesday_Close_Hours__c).left(5));
        openHours.put('Monday', String.valueOf(facility.Monday_Open_Hours__c).left(5) + '-' + String.valueOf(facility.Monday_Close_Hours__c).left(5));

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
}