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

    @AuraEnabled(cacheable=true)
    public static List<String> returnAllAvailableHoursForSingleDoctor(String dateTimeString, String medicalId, String doctorId) {
        DateTime appDate = DateTime.newInstance(Date.valueOf(dateTimeString), Time.newInstance(1, 0, 0, 0));
        String day = appDate.format('EEEE');
        String query = String.join(new List<String>{
            'SELECT ' + day + '_Open_Hours__c, ' + day + '_Close_Hours__c',
            'FROM Medical_Facility__c',
            'WHERE Id = \'' + medicalId + '\''
        }, ' ');
        
        List<Medical_Facility__c> result = Database.query(query);

        Time openHours = (Time) result[0].get(day + '_Open_Hours__c');
        Time closeHours = (Time) result[0].get(day + '_Close_Hours__c');

        List<String> availableTime = new List<String>();

        String appointmentQuery = String.join(new List<String>{
            'SELECT Appointment_Date__c FROM Medical_Appointment__c WHERE',
            'Doctor__c = \'' + doctorId + '\'',
            'AND Appointment_Date__c >= ' + String.valueOf(appDate.date()) + 'T00:00:00.000Z',
            'AND Appointment_Date__c <= ' + String.valueOf(appDate.date()) + 'T23:59:59.999Z'
        }, ' ');

        List<Medical_Appointment__c> appointments = Database.query(appointmentQuery);
        List<Time> appointmentsTime = new List<Time>();
        
        for(Medical_Appointment__c appointment : appointments) {
            appointmentsTime.add(Time.newInstance(appointment.Appointment_Date__c.hour(), appointment.Appointment_Date__c.minute(), 0, 0));
        }

        while(openHours < closeHours) {
            Integer i = canTimeBeAddedToVisit(appointmentsTime, openHours);
            if (i != -1) {
                appointmentsTime.remove(i);
            } else {
                availableTime.add(String.valueOf(openHours).substring(0, 5));
            }
            
            openHours = openHours.addMinutes(20);
        }

        return availableTime;
    }

    private static Integer canTimeBeAddedToVisit(List<Time> times, Time openHours) {
        for(Integer i = 0; i < times.size(); i++) {
            if (times[i] > openHours && times[i] < openHours.addMinutes(20)) {
                return i;
            }
        }
        return -1;
    }

    @AuraEnabled
    public static void saveAppointment(
            String facilityId, String doctorId, String patientId, String isOnline, String dateTimeString, String visitTime, String appointmentId, String appointmentStatus
        ) {
            Id recordId = isOnline == 'Online' ? 
            AppointmentController.getRecordTypeIdbyName('Online')
            : AppointmentController.getRecordTypeIdbyName('On Site');
            
            Person__c doctor = [select Name, Last_Name__c from Person__c where Id =: doctorId];

            Integer hour = Integer.valueOf(visitTime.substring(0,2));
            Integer minute = Integer.valueOf(visitTime.substring(3,5));

            DateTime timeOfVisit = DateTime.newInstance(Date.valueOf(dateTimeString), Time.newInstance(hour, minute, 0, 0));
            
            if (appointmentStatus == null) {
                Medical_Appointment__c appointment = new Medical_Appointment__c(
                    Name='Appointment visit with ' + doctor.Name + ' ' + doctor.Last_Name__c, 
                    Doctor__c=doctorId, 
                    Medical_Facility__c=facilityId, 
                    Patient__c=patientId, 
                    Appointment_Status__c='Upcoming', 
                    Appointment_Date__c = timeOfVisit,
                    RecordTypeId = recordId
                );

                insert appointment;
            } else {
                Medical_Appointment__c appointment = new Medical_Appointment__c(
                    Id = appointmentId,
                    Name='Appointment with ' + doctor.Name + ' ' + doctor.Last_Name__c, 
                    Doctor__c=doctorId, 
                    Medical_Facility__c=facilityId, 
                    Patient__c=patientId, 
                    Appointment_Status__c=appointmentStatus, 
                    Appointment_Date__c = timeOfVisit,
                    RecordTypeId = recordId
                );

                update appointment;
            }
    }

    public static Id getRecordTypeIdbyName(String strRecordTypeName){
        return Medical_Appointment__c.getSObjectType().getDescribe().getRecordTypeInfosByName().get(strRecordTypeName).getRecordTypeId();
    }

}

