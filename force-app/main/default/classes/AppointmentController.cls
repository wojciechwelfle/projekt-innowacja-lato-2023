public with sharing class AppointmentController {
    
    @AuraEnabled(cacheable = true)
    public static List<Medical_Facility__c> getAllFacilities() {
        return 
            [
                select Id, Name from Medical_Facility__c 
                with SECURITY_ENFORCED
            ];
    }

    @AuraEnabled(cacheable = true)
    public static List<AggregateResult> getAllSpecializationsFromDoctorsWorkingInAFacility(String facilityId) {
        return 
            [
                select Specialization__c from Person__c 
                where RecordType.Name = 'Doctor'
                and Medical_Facility__c =: facilityId
                with SECURITY_ENFORCED
                group by Specialization__c
            ];
    }

    @AuraEnabled(cacheable = true)
    public static List<Person__c> getAllDoctorsWorkingInCurrentFacility(String facilityId, String specialization) {
        return new List<Person__c>(
            [
                select Id, Name, Last_Name__c from Person__c 
                where RecordType.Name = 'Doctor'
                and Medical_Facility__c =: facilityId
                and Specialization__c =: specialization
                with SECURITY_ENFORCED
            ]
        );
    }

    //TODO: saving appointment

    // @AuraEnabled
    // public static List<Person__c> saveAppointment(
    //         String facilityId, String doctorId, String patientId, boolean isOnline, String DateTimee
    //     ) {
    //     return new List<Person__c>(
    //         [
    //             select Id, Name, Last_Name__c from Person__c 
    //             where RecordType.Name = 'Doctor'
    //             and Id in doctorId
    //             with SECURITY_ENFORCED

    //         ]
    //     );
    // }
}