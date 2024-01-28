trigger MedicalAppointmentTrigger on Medical_Appointment__c(
  before insert,
  after insert,
  after update
) {
  MedicalAppointmentTriggerHandler handler = new MedicalAppointmentTriggerHandler();
  if (Trigger.isInsert) {
    if (Trigger.isBefore) {
      handler.firstVisitToAnInternistOnSite(Trigger.new);
    } else {
      handler.sendAppointmentEmail(Trigger.new, Trigger.oldMap);
    }
  } else if (Trigger.isUpdate) {
    if (Trigger.isAfter) {
      handler.sendAppointmentEmail(Trigger.new, Trigger.oldMap);
    }
  }
}
