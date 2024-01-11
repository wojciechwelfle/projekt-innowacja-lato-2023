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

    @AuraEnabled
    public static void saveAppointment(
            String facilityId, String doctorId, String patientId, String isOnline, String dateTimeString
        ) {
        Id recordId = isOnline == 'Online' ? 
        Medical_Appointment__c.getSObjectType()
        .getDescribe()
        .getRecordTypeInfosByName()
        .get('Online')
        .getRecordTypeId()
        :
        Medical_Appointment__c.getSObjectType()
        .getDescribe()
        .getRecordTypeInfosByName()
        .get('On-Site')
        .getRecordTypeId();

        insert new Medical_Appointment__c(
            Name='test visit', 
            Doctor__c=doctorId, 
            Medical_Facility__c=facilityId, 
            Patient__c=patientId, 
            Appointment_Status__c='Upcoming', 
            Appointment_Date__c = DateTime.valueOf(dateTimeString),
            RecordTypeId = recordId
        );
    }
}