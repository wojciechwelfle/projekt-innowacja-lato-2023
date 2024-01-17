public with sharing class AppointmentController {

    @AuraEnabled(cacheable = true)
    public static List<Person__c> getAllPatients() {
        return 
            [
                select Id, Name from Person__c
                where RecordType.Name = 'Patient'
                with SECURITY_ENFORCED
            ];
    }
    
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

    @AuraEnabled
    public static void updateAppointment(
            String[] fieldsToUpdate
            // String appointmentId, String facilityId, String doctorId, String patientId, String isOnline, String dateTimeString, String appointmentStatus
        ) {
            System.debug(fieldsToUpdate);
            // Medical_Appointment__c appointmentToUpdate = [
            //     select Appointment_Date__c, Appointment_Status__c, Doctor__c, Patient__c, Medical_Facility__c, RecordTypeId from Medical_Appointment__c
            //     where Id = :appointmentId
            // ];

            // if (String.isBlank(facilityId)) {
            //     appointmentToUpdate.Medical_Facility__c = facilityId;
            // }

            // if (String.isBlank(doctorId)) {
            //     appointmentToUpdate.Doctor__c = doctorId;
            // }

            // if (String.isBlank(patientId)) {
            //     appointmentToUpdate.Patient__c = patientId;
            // }

            // if (String.isBlank(isOnline)) {
            //     Id recordId = isOnline == 'Online' ? 
            //     AppointmentController.getRecordTypeIdbyName('Medical_Appointment__c', 'Online')
            //     : AppointmentController.getRecordTypeIdbyName('Medical_Appointment__c', 'On Site');
            //     appointmentToUpdate.RecordTypeId = recordId;
            // }

            // if (String.isBlank(dateTimeString)) {
            //     appointmentToUpdate.Appointment_Date__c = DateTime.valueOf(dateTimeString.replace('T', ' '));
            // }

            // // if (String.isBlank(appointmentStatus)) {
            // //     appointmentToUpdate.Medical_Facility__c = appointmentStatus;
            // // }
            
            // update appointmentToUpdate;
    }

    // private static Boolean[] defineWhichFieldsToChange(String[] checkIfFieldToUpdateString) {
    //     Boolean[] fieldsToChange = {false, false, false, false, false, false};
    //     for(Integer i = 0; i<checkIfFieldToUpdateString.length(); i++) {
    //         fieldsToChange[i] = String.isBlank(checkIfFieldToUpdateString[i]) ? false : true;
    //     }
    //     return fieldsToChange;
    // }

    public static Id getRecordTypeIdbyName(String objectName, String strRecordTypeName){
        return  Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByName().get(strRecordTypeName).getRecordTypeId();
    }

}

