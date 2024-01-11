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
        AppointmentController.getRecordTypeIdbyName('Medical_Appointment__c', 'Online')
        : AppointmentController.getRecordTypeIdbyName('Medical_Appointment__c', 'On Site');
        
        AggregateResult name = [select count(Patient__c) from Medical_Appointment__c where Medical_Facility__c =: facilityId and Patient__c =: patientId];
        System.debug('recordId: ' + recordId + ' doctor: ' + doctorId + ' patient: ' + patientId + ' isonline: ' + isOnline + ' date: ' + dateTimeString);

        Medical_Appointment__c appointment = new Medical_Appointment__c(
            Name=String.valueOf((Integer)name.get('expr0')) + ' visit', 
            Doctor__c=doctorId, 
            Medical_Facility__c=facilityId, 
            Patient__c=patientId, 
            Appointment_Status__c='Upcoming', 
            Appointment_Date__c = DateTime.valueOf(dateTimeString.replace('T', ' ')),
            RecordTypeId = recordId
        );

        insert appointment;
    }
    public static Id getRecordTypeIdbyName(String objectName, String strRecordTypeName){
        return  Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByName().get(strRecordTypeName).getRecordTypeId();
    }
}



//     @AuraEnabled
// public static void saveAppointment(
//     String facilityId, String doctorId, String patientId, String isOnline, String dateTimeString
// ) {
//     String recordTypeName = (isOnline == 'Online') ? 'Online' : 'On-Site';

//     Schema.DescribeSObjectResult describeResult = Medical_Appointment__c.sObjectType.getDescribe();
//     System.debug(describeResult);
//     Map<String, Schema.RecordTypeInfo> recordTypeInfosByName = describeResult.getRecordTypeInfosByName();

//     if (recordTypeInfosByName != null && recordTypeInfosByName.containsKey(recordTypeName)) {
//         Id recordId = recordTypeInfosByName.get(recordTypeName).getRecordTypeId();
//         System.debug('recordId: ' + recordId + ' doctor: ' + doctorId + ' patient: ' + patientId + ' isonline: ' + isOnline + ' date: ' + dateTimeString);

//         Medical_Appointment__c appointment = new Medical_Appointment__c(
//             Name='test visit', 
//             Doctor__c=doctorId, 
//             Medical_Facility__c=facilityId, 
//             Patient__c=patientId, 
//             Appointment_Status__c='Upcoming', 
//             Appointment_Date__c = DateTime.valueOf(dateTimeString.replace('T', ' ')),
//             RecordTypeId = recordId
//         );

//         insert appointment;
//     } else {
//         // Handle the case where the record type info is not available
//         System.debug('Record type info not found for: ' + recordTypeName);
//     }
// }

// }