@isTest
public without sharing class RESTMedicalFacilitiesTests {

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

    @IsTest
    private static void testGetMethod() {

        List<Medical_Facility__c> ids = [SELECT Id from Medical_Facility__c];

        RestRequest request = new RestRequest();
        request.requestURI = 'services/apexrest/Medical_Facility__c';
        RestResponse response = new RestResponse();

        RestContext.request = request;
        RestContext.response = response;


        test.startTest();
        RESTMedicalFacilities.getMedicalFacilities();
        test.stopTest();

        String responseBody = '[{"phoneNumber":null,"openingHours":{"Monday":"09:00-17:00","Tuesday":"09:30-18:00","Wednesday":"10:00-19:00","Thursday":"08:00-16:30","Friday":"11:00-20:00","Saturday":"12:00-21:00","Sunday":"10:30-18:30"},"name":"Szpital dzieciecy","id":"' + String.valueOf(ids[0].Id) + '","address":["ExampleCity","Main Street","123","12-345"]},{"phoneNumber":null,"openingHours":{"Monday":"09:32-13:30","Tuesday":"06:30-18:00","Wednesday":"16:00-19:00","Thursday":"06:00-16:30","Friday":"15:00-20:00","Saturday":"12:00-21:00","Sunday":"10:30-18:30"},"name":"Izba pomocy","id":"' + String.valueOf(ids[1].Id) + '","address":["asdf","erqw Street","321","23-385"]}]';

        Assert.areEqual(200,response.statusCode);
        Assert.areEqual(responseBody, response.responseBody.toString());
    }

    @isTest
    private static void testPutMethod() {
        List<Medical_Facility__c> ids = [SELECT Id from Medical_Facility__c];

        RestRequest request = new RestRequest();
        request.requestURI = 'services/apexrest/Medical_Facility__c';
        RestResponse response = new RestResponse();

        request.requestBody = Blob.valueOf('[{"id":"' + String.valueOf(ids[0].Id) + '","openingHours":{"Monday":"09:00-17:00","Tuesday":"09:30-18:00","Wednesday":"10:00-19:00","Thursday":"08:00-16:30","Friday":"11:00-20:00","Saturday":"12:00-21:00","Sunday":"10:30-18:30"},"name":"Bytom"}]');

        RestContext.request = request;
        RestContext.response = response;

        test.startTest();
        List<Id> output = RESTMedicalFacilities.putMedicalFacilities();
        test.stopTest();

        Assert.areEqual(output[0],String.valueOf(ids[0].Id));
    }

    @isTest
    private static void emptyBodyPutMethod() {

        RestRequest request = new RestRequest();
        request.requestURI = 'services/apexrest/Medical_Facility__c';
        RestResponse response = new RestResponse();

        request.requestBody = Blob.valueOf('');

        RestContext.request = request;
        RestContext.response = response;

        test.startTest();
        List<Id> output = RESTMedicalFacilities.putMedicalFacilities();
        test.stopTest();

        System.assertEquals('{"error": "No content to map to Object due to end of input"}', response.responseBody.toString());
        System.assertEquals(400, response.statusCode);
    }

    @isTest
    private static void listPutMethod() {

        List<Medical_Facility__c> ids = [SELECT Id from Medical_Facility__c];

        List<Id> idsList = new List<Id>();

        idsList.add(ids[0].Id);
        idsList.add(ids[1].Id);

        RestRequest request = new RestRequest();
        request.requestURI = 'services/apexrest/Medical_Facility__c';
        RestResponse response = new RestResponse();

        request.requestBody = Blob.valueOf('[{"openingHours":{"Monday":"00:00-17:00","Tuesday":"00:30-18:00","Wednesday":"10:00-19:00","Thursday":"00:00-16:30","Friday":"00:00-20:00","Saturday":"00:00-21:00","Sunday":"00:30-18:30"},"name":"Szpital dzieciecy","id":"' + String.valueOf(ids[0].Id) + '"},{"openingHours":{"Monday":"00:30-16:30","Tuesday":"00:30-16:30","Wednesday":"00:30-16:30","Thursday":"00:30-16:30","Friday":"00:30-16:30","Saturday":"00:30-16:30","Sunday":"00:30-16:30"},"name":"Szpital Lodz","id":"' + String.valueOf(ids[1].Id) + '"}]');


        RestContext.request = request;
        RestContext.response = response;

        test.startTest();
        List<Id> output = RESTMedicalFacilities.putMedicalFacilities();
        test.stopTest();

        Assert.areEqual(idsList, output);
    }

    @isTest
    private static void testPostMethod() {
        RestRequest request = new RestRequest();
        request.requestURI = 'services/apexrest/Medical_Facility__c';
        RestResponse response = new RestResponse();

        request.requestBody = Blob.valueOf('{"fromDateTime":"2023-12-07 10:00:00","toDateTime":"2023-12-07 17:00:00"}');

        RestContext.request = request;
        RestContext.response = response;


        test.startTest();
        RESTMedicalFacilities.postMedicalFacilities();
        test.stopTest();

        Assert.areEqual('["Szpital dzieciecy","Izba pomocy"]', response.responseBody.toString());
    }

    @isTest
    private static void testPostMethodOneFacility() {
        RestRequest request = new RestRequest();
        request.requestURI = 'services/apexrest/Medical_Facility__c';
        RestResponse response = new RestResponse();

        request.requestBody = Blob.valueOf('{"fromDateTime":"2023-12-06 10:00:00","toDateTime":"2023-12-06 13:00:00"}');

        RestContext.request = request;
        RestContext.response = response;


        test.startTest();
        RESTMedicalFacilities.postMedicalFacilities();
        test.stopTest();

        Assert.areEqual('["Szpital dzieciecy"]', response.responseBody.toString());
    }

    @isTest
    private static void testPostMethodError() {
        RestRequest request = new RestRequest();
        request.requestURI = 'services/apexrest/Medical_Facility__c';
        RestResponse response = new RestResponse();

        request.requestBody = Blob.valueOf('{"fromDateTime":"2023-12-06 10:00:","toDateTime":"2023-12-06 13:00:00"}');

        RestContext.request = request;
        RestContext.response = response;


        test.startTest();
        RESTMedicalFacilities.postMedicalFacilities();
        test.stopTest();

        Assert.areEqual('{"error": "Invalid date/time: 2023-12-06 10:00:"}', response.responseBody.toString());
        Assert.areEqual(403, response.statusCode);
    }



}