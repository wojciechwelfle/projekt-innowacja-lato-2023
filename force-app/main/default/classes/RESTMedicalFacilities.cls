@RestResource(UrlMapping='/Medical_Facility__c/*')
global with sharing class RESTMedicalFacilities {
    
    @HttpGet
    global static void getMedicalFacilities() {
       RestRequest request = RestContext.request;
       System.debug(request);
        
        Map<String, String> params = request.params;
        System.debug(params);

        List<Medical_Facility__c> facility = [SELECT Id, Name, Opening_Hours__c, Adress__c, Phone_Number__c	
                                              FROM Medical_Facility__c];

        List<MedicalFacilityWrapper> wrapper = new List<MedicalFacilityWrapper>();
        
        for (Medical_Facility__c fac : facility) {
            wrapper.add(
                new MedicalFacilityWrapper(fac.Name, fac.Opening_Hours__c, fac.Phone_Number__c, fac.Adress__c, fac.Id)
            );        
        }


        RestContext.response.statusCode = 200;
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(wrapper));
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
        return 'Object ' + wrapper.id + ' was updated!';
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
    
}