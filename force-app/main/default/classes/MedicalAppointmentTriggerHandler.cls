public with sharing class MedicalAppointmentTriggerHandler {
  public void sendAppointmentEmail(
    List<Medical_Appointment__c> triggerNew,
    Map<Id, Medical_Appointment__c> oldMap
  ) {
    Map<Id, List<Medical_Appointment__c>> patientAppointments = new Map<Id, List<Medical_Appointment__c>>();
    for (Medical_Appointment__c appointment : triggerNew) {
      if (oldMap != null) {
        Medical_Appointment__c old = oldMap.get(appointment.Id);
        if (
          old.Name == appointment.Name &&
          old.Appointment_Date__c.format() ==
          appointment.Appointment_Date__c.format() &&
          old.Appointment_Status__c == appointment.Appointment_Status__c &&
          old.Doctor__c == appointment.Doctor__c &&
          old.Patient__c == appointment.Patient__c &&
          old.recordTypeId == appointment.recordTypeId &&
          old.Medical_Facility__c == appointment.Medical_Facility__c
        ) {
          continue;
        }
      }
      if (!patientAppointments.containsKey(appointment.Patient__c)) {
        patientAppointments.put(
          appointment.Patient__c,
          new List<Medical_Appointment__c>{ appointment }
        );
      } else {
        patientAppointments.get(appointment.Patient__c).add(appointment);
      }
    }

    List<Person__c> patients = [
      SELECT Id, Name, Last_Name__c, Email__c
      FROM Person__c
      WHERE Id IN :patientAppointments.keySet()
    ];

    List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
    for (Person__c patient : patients) {
      for (
        Medical_Appointment__c appointment : patientAppointments.get(patient.Id)
      ) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.setToAddresses(new List<String>{ patient.Email__c });
        mail.setSubject('Updated Appointment Information!');

        String template = 'Dear {0} {1},\n\nYour Medical Appointment has been updated!\nDetails from the visit:\n\tMedical Appointment Name: {2}\n\tPatient: {3} {4}\n\tAppointment Date: {5}\n\tAppointment Status: {6}\n\tAppointment ID: {7}\n\nIf something is not correct, please contact us!\nHealth Care App Team';
        List<Object> parameters = new List<Object>{
          patient.Name,
          patient.Last_Name__c,
          appointment.Name,
          patient.Name,
          patient.Last_Name__c,
          appointment.Appointment_Date__c.format(),
          appointment.Appointment_Status__c,
          appointment.Appointment_Id__c
        };
        String formatted = String.format(template, parameters);

        mail.setPlainTextBody(formatted);
        emailsToSend.add(mail);
      }
    }
    Messaging.sendEmail(emailsToSend);
  }

  public void firstVisitToAnInternistOnSite(
    List<Medical_Appointment__c> triggerNew
  ) {
    Id recType = Medical_Appointment__c.getSObjectType()
      .getDescribe()
      .getRecordTypeInfosByName()
      .get('Online')
      .getRecordTypeId();
    List<Id> doctors = new List<Id>();
    for (Medical_Appointment__c appointment : triggerNew) {
      doctors.add(appointment.Doctor__c);
    }

    List<Id> internistsIds = new List<Id>();
    List<Person__c> internists = [
      SELECT Id
      FROM Person__c
      WHERE Specialization__c = 'Internist' AND Id IN :doctors
    ];
    for (Person__c internist : internists) {
      internistsIds.add(internist.Id);
    }

    List<Medical_Appointment__c> appointments = new List<Medical_Appointment__c>();
    List<Id> patients = new List<Id>();
    for (Medical_Appointment__c appointment : triggerNew) {
      if (
        appointment.RecordTypeId == recType &&
        internistsIds.contains(appointment.Doctor__c)
      ) {
        appointments.add(appointment);
        patients.add(appointment.Patient__c);
      }
    }

    List<Id> patientsIds = new List<Id>();
    List<AggregateResult> appointmentsWithInternists = [
      SELECT COUNT(Id), Patient__c
      FROM Medical_Appointment__c
      WHERE
        Doctor__r.Specialization__c = 'Internist'
        AND Patient__c IN :patients
        AND RecordTypeId != :recType
      GROUP BY Patient__c
    ];

    for (AggregateResult ar : appointmentsWithInternists) {
      patientsIds.add(ar.get('Patient__c').toString());
    }

    for (Medical_Appointment__c appointment : appointments) {
      if (!patientsIds.contains(appointment.Patient__c)) {
        appointment.addError('First visit in Internist must be On Site');
      }
    }
  }
}
