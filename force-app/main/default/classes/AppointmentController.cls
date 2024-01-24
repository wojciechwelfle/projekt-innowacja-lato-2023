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
                order by Last_Name__c asc
            ]
        );
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getAppointmentStatusPicklistValues() {
        List<String> picklistValues = new List<String>();
        Schema.DescribeFieldResult fieldResult = Medical_Appointment__c.Appointment_Status__c.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry entry : picklistEntries) {
            picklistValues.add(entry.getLabel());
        }
        
        return picklistValues;
    }

    @AuraEnabled
    public static void saveAppointment(
            String facilityId, String doctorId, String patientId, String isOnline, String dateTimeString
        ) {
            Id recordId = isOnline == 'Online' ? 
            AppointmentController.getRecordTypeIdbyName('Online')
            : AppointmentController.getRecordTypeIdbyName('On Site');
            
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
            String appointmentId, String facilityId, String doctorId, String isOnline, String dateTimeString, String appointmentStatus
        ) {
            Integer flag = 0;
            Id recordId = isOnline == 'Online' ? 
            AppointmentController.getRecordTypeIdbyName('Online')
            : AppointmentController.getRecordTypeIdbyName('On Site');
            Medical_Appointment__c appointmentToUpdate = [
                select Appointment_Date__c, Appointment_Status__c, Doctor__c, Patient__c, Medical_Facility__c, RecordTypeId from Medical_Appointment__c
                where Id = :appointmentId
            ];

            if (!String.isBlank(facilityId) && facilityId != appointmentToUpdate.Medical_Facility__c) {
                System.debug('wyrzucam exception 1');
                appointmentToUpdate.Medical_Facility__c = facilityId;
                flag = 1;
            }

            if (!String.isBlank(doctorId) && doctorId != appointmentToUpdate.Doctor__c) {
                System.debug('wyrzucam exception 2');
                appointmentToUpdate.Doctor__c = doctorId;
                flag = 1;
            }

            if (!String.isBlank(isOnline) && appointmentToUpdate.RecordTypeId != recordId) {
                System.debug('wyrzucam exception 3');
                appointmentToUpdate.RecordTypeId = recordId;
                flag = 1;
            }

            if (
                !String.isBlank(dateTimeString) && 
                DateTime.valueOf(dateTimeString.replace('T', ' ')) != appointmentToUpdate.Appointment_Date__c
            ) {
                System.debug('wyrzucam exception 4');
                appointmentToUpdate.Appointment_Date__c = DateTime.valueOf(dateTimeString.replace('T', ' '));
                flag = 1;
            }

            if (!String.isBlank(appointmentStatus) && appointmentStatus != appointmentToUpdate.Appointment_Status__c) {
                System.debug('wyrzucam exception 5');
                appointmentToUpdate.Appointment_Status__c = appointmentStatus;
                flag = 1;
            }

            try {
                if (flag == 1) {
                    update appointmentToUpdate;
                } else {
                    System.debug('Throwing custom exception: No record has been updated!');
                    throw new AuraHandledException('No record has been updated!');
                }
            } catch (DmlException de) {
                System.debug('Caught DMLException: ' + de.getMessage());
                throw new AuraHandledException('Error updating record: ' + de.getMessage());
            } catch (Exception e) {
                System.debug('Caught generic Exception: ' + e.getMessage());
                throw new AuraHandledException('An unexpected error occurred: ' + e.getMessage());
            }
            
    }

    public static Id getRecordTypeIdbyName(String strRecordTypeName){
        return  Medical_Facility__c.getSObjectType().getDescribe().getRecordTypeInfosByName().get(strRecordTypeName).getRecordTypeId();
    }

}

