trigger FirstVisitToAnInternistOnSite on Medical_Appointment__c(before insert) {
  Map<Id, Medical_Appointment__c> appointments = new Map<Id, Medical_Appointment__c>();
  List<Id> patientsId = new List<Id>();

  Id recType = Schema.getGlobalDescribe()
    .get('Medical_Appointment__c')
    .getDescribe()
    .getRecordTypeInfosByName()
    .get('Online')
    .getRecordTypeId();
  for (Medical_Appointment__c appointment : Trigger.new) {
    if (appointment.RecordTypeId == recType) {
      appointments.put(appointment.id, appointment);
      patientsId.add(appointment.Patient__c);
    }
  }

  List<Id> appIds = new List<Id>();
  List<Medical_Appointment__c> apps = [
    SELECT Patient__c
    FROM Medical_Appointment__c
    WHERE
      Doctor__r.Specialization__c = 'Internist'
      AND Patient__c IN :patientsId
  ];
  for (Medical_Appointment__c app : apps) {
    appIds.add(app.Id);
  }

  for (Medical_Appointment__c appointment : appointments.values()) {
    if (!appIds.contains(appointment.Patient__c)) {
      appointment.addError('First Visit in internist must be onsite!');
    }
  }
}
