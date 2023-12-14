trigger SendAppointmentEmail on Medical_Appointment__c(
  after insert,
  after update
) {
  Map<Id, Medical_Appointment__c> appointments = new Map<Id, Medical_Appointment__c>();
  for (Medical_Appointment__c appointment : Trigger.new) {
    appointments.put(appointment.Patient__c, appointment);
  }

  List<Person__c> persons = [
    SELECT Id, Name, Last_Name__c, Email__c
    FROM Person__c
    WHERE Id IN :appointments.keySet()
  ];

  List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
  for (Person__c person : persons) {
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

    mail.setToAddresses(new List<String>{ person.Email__c });
    mail.setSubject('Updated Appointment Information!');
    mail.setPlainTextBody(
      'Dear ' +
        person.Name +
        ' ' +
        person.Last_Name__c +
        ',\n\nYour Medical Appointment has been updated!\nDetails from the visit:' +
        '\n\tMedical Appointment Name: ' +
        appointments.get(person.Id).Name +
        '\n\tPatient: ' +
        person.Name +
        ' ' +
        person.Last_Name__c +
        '\n\tAppointment Date: ' +
        appointments.get(person.Id).Appointment_Date__c.format() +
        '\n\tAppointment Status: ' +
        appointments.get(person.Id).Appointment_Status__c +
        '\n\tAppointment ID: ' +
        appointments.get(person.Id).Appointment_Id__c +
        '\n\nIf something is not correct, please contact us!\nHealth Care App Team'
    );

    emailsToSend.add(mail);
  }
  Messaging.sendEmail(emailsToSend);
}
