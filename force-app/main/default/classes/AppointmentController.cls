public with sharing class AppointmentController {
    
    @AuraEnabled(cacheable = true)
    public static List<Person__c> getAllDoctors() {
        return new List<Person__c>(
            [select Id, Name, Specialization__c from Person__c where RecordType.Name = 'Doctor']
        );
    }
}