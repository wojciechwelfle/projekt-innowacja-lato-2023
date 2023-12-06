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
        RestRequest request = new RestRequest();
        request.requestURI = 'services/apexrest/Medical_Facility__c';
        RestResponse response = new RestResponse();

        RestContext.request = request;
        RestContext.response = response;

        List<Medical_Facility__c> facilities = [SELECT Id, Name, Opening_Hours__c, Adress__c, Phone_Number__c FROM Medical_Facility__c];

        test.startTest();
        List<Medical_Facility__c> facilitiesToCheck = RESTMedicalFacilities.getMedicalFacilities();
        test.stopTest();

        Assert.areEqual(200,response.statusCode );
        // Assert.areEqual('{"phoneNumber":null,"openingHours":"Mon 2:42-12:37\nTue 6:17-14:59\nWed 16:58-1:53\nThu 16:10-24:36\nFri 11:00-19:57\nSat 9:23-20:24\nSun 2:50-11:16","name":"Warszawa","id":"a013N000005hnfhQAA","address":"Warszawa"},{"phoneNumber":null,"openingHours":"Mon 14:31-22:30\nTue 5:10-14:02\nWed 5:10-13:44\nThu 1:16-13:27\nFri 3:52-11:22\nSat 3:27-13:58\nSun 15:40-2:40","name":"Szpital","id":"a013N000005hnhJQAQ","address":null},{"phoneNumber":null,"openingHours":"Mon 23:15-11:42\nTue 21:53-5:03\nWed 1:42-11:05\nThu 23:13-11:21\nFri 5:20-14:26\nSat 18:58-5:25\nSun 17:53-4:42","name":"Lodz","id":"a013N000005hnfcQAA","address":null}' ,
        // response.responseBody.toString());
        Assert.areEqual(facilities, facilitiesToCheck);
    }

    @isTest
    private static void testPutMethod() {
        RestRequest request = new RestRequest();
        request.requestURI = 'services/apexrest/Medical_Facility__c';
        RestResponse response = new RestResponse();
        request.requestBody = Blob.valueOf('{"id":"a013N000005hnfhQAA","openingHours":"Mon 10:13-22:11\nTue 10:13-14:57\nWed 10:38-18:54\nThu 7:45-19:49\nFri 16:11-4:57\nSat18:34-5:37\nSun 23:27-10:21","name":"Bytom"}');

        RestContext.request = request;
        RestContext.response = response;

        test.startTest();
        String output = RESTMedicalFacilities.putMedicalFacilities();
        test.stopTest();

        Assert.areEqual(output, 'Object a013N000005hnfhQAA has been updated!');
    }

}