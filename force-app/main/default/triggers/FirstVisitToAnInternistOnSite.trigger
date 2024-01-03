trigger FirstVisitToAnInternistOnSite on Medical_Appointment__c(before insert) {
  Id recType = Medical_Appointment__c.getSObjectType()
    .getDescribe()
    .getRecordTypeInfosByName()
    .get('Online')
    .getRecordTypeId();

  List<Id> internistsIds = new List<Id>();
  List<Person__c> internists = [
    SELECT Id
    FROM Person__c
    WHERE Specialization__c = 'Internist'
  ];
  for (Person__c internist : internists) {
    internistsIds.add(internist.Id);
  }

  List<Medical_Appointment__c> appointments = new List<Medical_Appointment__c>();
  List<Id> patients = new List<Id>();
  for (Medical_Appointment__c appointment : Trigger.new) {
    if (
      appointment.RecordTypeId == recType &&
      internistsIds.contains(appointment.Doctor__c)
    ) {
      appointments.add(appointment);
      patients.add(appointment.Patient__c);
    }
  }

  List<Id> patientsIds = new List<Id>();
  List<Medical_Appointment__c> appointmentsWithInternists = [
    SELECT Id
    FROM Medical_Appointment__c
    WHERE Doctor__c = :internistsIds AND Patient__c = :patients
  ];
  for (Medical_Appointment__c appointment : appointmentsWithInternists) {
    patientsIds.add(appointment.Patient__c);
  }

  for (Medical_Appointment__c appointment : appointments) {
    if (!patientsIds.contains(appointment.Patient__c)) {
      appointment.addError('First visit in Internist must be On Site');
    }
  }
}
