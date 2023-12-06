/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */



@isTest
public without sharing class RESTMedicalFacilitiesTests {

    @IsTest
    private static void testGetMethod() {
        Medical_Facility__c facility = new Medical_Facility__c(
            Name = 'Szpital dzieciecy', Phone_Number__c = '',
            Monday__c = '09:00-17:00', Tuesday__c = '09:30-18:00', Wednesday__c = '10:00-19:00', 
            Thursday__c = '08:00-16:30', Friday__c = '11:00-20:00', Saturday__c = '12:00-21:00', Sunday__c = '10:30-18:30',
            City__c = 'ExampleCity', Street__c = 'Main Street', Building_number__c = '123', zip_code__c = '12-345'
        );

        insert facility;

        RestRequest request = new RestRequest();
        request.requestURI = 'services/apexrest/Medical_Facility__c';
        RestResponse response = new RestResponse();

        RestContext.request = request;
        RestContext.response = response;


        test.startTest();
        RESTMedicalFacilities.getMedicalFacilities();
        test.stopTest();

        String responseBody = '[{"phoneNumber":null,"openingHours":{"Monday":"09:00-17:00","Tuesday":"09:30-18:00","Wednesday":"10:00-19:00","Thursday":"08:00-16:30","Friday":"11:00-20:00","Saturday":"12:00-21:00","Sunday":"10:30-18:30"},"name":"Szpital dzieciecy","id":"' + facility.id + '","address":["ExampleCity","Main Street","123","12-345"]}]';

        Assert.areEqual(200,response.statusCode);
        Assert.areEqual(responseBody, response.responseBody.toString());
    }

    @isTest
    private static void testPutMethod() {
        Medical_Facility__c facility = new Medical_Facility__c(
            Name = 'Izba pomocy', Phone_Number__c = '',
            Monday__c = '09:32-13:30', Tuesday__c = '06:30-18:00', Wednesday__c = '16:00-19:00', 
            Thursday__c = '06:00-16:30', Friday__c = '15:00-20:00', Saturday__c = '12:00-21:00', Sunday__c = '10:30-18:30',
            City__c = 'asdf', Street__c = 'erqw Street', Building_number__c = '321', zip_code__c = '23-385'
        );

        insert facility;

        RestRequest request = new RestRequest();
        request.requestURI = 'services/apexrest/Medical_Facility__c';
        RestResponse response = new RestResponse();

        request.requestBody = Blob.valueOf('[{"id":"' + facility.id + '","openingHours":{"Monday":"09:00-17:00","Tuesday":"09:30-18:00","Wednesday":"10:00-19:00","Thursday":"08:00-16:30","Friday":"11:00-20:00","Saturday":"12:00-21:00","Sunday":"10:30-18:30"},"name":"Bytom"}]');

        RestContext.request = request;
        RestContext.response = response;

        test.startTest();
        List<Id> output = RESTMedicalFacilities.putMedicalFacilities();
        test.stopTest();

        Assert.areEqual(output[0],facility.id);
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
        List<Medical_Facility__c> facilities = new List<Medical_Facility__c>();
        
        facilities.add(
            new Medical_Facility__c(
                Name = 'Szpital wojewodzki', Phone_Number__c = '789456123',
                Monday__c = '09:32-13:30', Tuesday__c = '06:30-18:00', Wednesday__c = '16:00-19:00', 
                Thursday__c = '06:00-15:30', Friday__c = '15:00-20:00', Saturday__c = '12:00-21:00', Sunday__c = '10:30-18:30',
                City__c = 'ABC', Street__c = 'abc', Building_number__c = '1', zip_code__c = '11-111'
            )
        );

        facilities.add(
            new Medical_Facility__c(
                Name = 'Izba pomocy', Phone_Number__c = '',
                Monday__c = '09:32-13:30', Tuesday__c = '06:30-18:00', Wednesday__c = '16:00-19:00', 
                Thursday__c = '06:00-16:30', Friday__c = '15:00-20:00', Saturday__c = '12:00-21:00', Sunday__c = '10:30-18:30',
                City__c = 'asdf', Street__c = 'erqw Street', Building_number__c = '321', zip_code__c = '23-385'
            )
        );

        insert facilities;

        List<Id> ids = new List<Id>();

        ids.add(facilities[0].id);
        ids.add(facilities[1].id);

        RestRequest request = new RestRequest();
        request.requestURI = 'services/apexrest/Medical_Facility__c';
        RestResponse response = new RestResponse();

        request.requestBody = Blob.valueOf('[{"openingHours":{"Monday":"00:00-17:00","Tuesday":"00:30-18:00","Wednesday":"10:00-19:00","Thursday":"00:00-16:30","Friday":"00:00-20:00","Saturday":"00:00-21:00","Sunday":"00:30-18:30"},"name":"Szpital dzieciecy","id":"' + ids[0] + '"},{"openingHours":{"Monday":"00:30-16:30","Tuesday":"00:30-16:30","Wednesday":"00:30-16:30","Thursday":"00:30-16:30","Friday":"00:30-16:30","Saturday":"00:30-16:30","Sunday":"00:30-16:30"},"name":"Szpital Lodz","id":"' + ids[1] + '"}]');


        RestContext.request = request;
        RestContext.response = response;

        test.startTest();
        List<Id> output = RESTMedicalFacilities.putMedicalFacilities();
        test.stopTest();

        Assert.areEqual(output, ids);
    }

}