trigger SendAppointmentEmail on Medical_Appointment__c(
  after insert,
  after update
) {
  Map<Id, List<Medical_Appointment__c>> patientAppointments = new Map<Id, List<Medical_Appointment__c>>();
  for (Medical_Appointment__c appointment : Trigger.new) {
    if (Trigger.isUpdate) {
      Medical_Appointment__c old = Trigger.oldMap.get(appointment.Id);
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
